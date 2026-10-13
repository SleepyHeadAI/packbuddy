import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local_db/database_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/domain/expense.dart';
import '../../features/vault/domain/document.dart';
import '../../features/checklist/domain/packing_item.dart';
import '../../core/services/currency_service.dart';

/// Sync Status enumeration for UI and State Management
enum SyncStatus {
  idle,
  syncing,
  upToDate,
  failed,
  noInternet,
}

/// State representation of the Sync Engine
class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final int syncedCount;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncTime,
    this.errorMessage,
    this.syncedCount = 0,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    String? errorMessage,
    int? syncedCount,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage,
      syncedCount: syncedCount ?? this.syncedCount,
    );
  }
}

/// Two-Way Sync Engine implementing the offline-first synchronization algorithm with Delta Sync & Batching
class SyncEngine extends StateNotifier<SyncState> {
  final DatabaseHelper _dbHelper;
  final FirebaseFirestore? _firestoreInstance;
  final FirebaseAuth? _authInstance;

  SyncEngine({
    DatabaseHelper? dbHelper,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _firestoreInstance = firestore,
        _authInstance = auth,
        super(const SyncState());

  /// Simple and fast check for internet connection
  Future<bool> hasInternetConnection() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 3),
      );
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _isSyncing = false;

  /// Returns true if a synchronization process is actively executing
  bool get isSyncing => _isSyncing;

  /// Executes two-way bidirectional sync between local SQLite and Cloud Firestore
  Future<void> performSync() async {
    // Concurrency guard: Prevent race condition if triggered multiple times simultaneously
    if (_isSyncing || state.status == SyncStatus.syncing) {
      return;
    }

    _isSyncing = true;

    try {
      // 1. Check network connectivity
      final isOnline = await hasInternetConnection();
      if (!isOnline) {
        state = state.copyWith(status: SyncStatus.noInternet);
        return;
      }

      // Automatically sync latest exchange rates in background when online
      CurrencyService.syncRates();

      // Set status to syncing
      state = state.copyWith(status: SyncStatus.syncing);

      // Safely check if Firebase is initialized
      final bool isFirebaseReady = Firebase.apps.isNotEmpty;
      if (!isFirebaseReady && _firestoreInstance == null) {
        // Firebase credentials are not yet configured in this environment (offline mock sync)
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(
          status: SyncStatus.upToDate,
          lastSyncTime: DateTime.now(),
        );
        return;
      }

      // User Isolation (Critical): Fetch current user UID; return early if null
      final uid = _authInstance?.currentUser?.uid ??
          (isFirebaseReady ? FirebaseAuth.instance.currentUser?.uid : null);
      if (uid == null) {
        state = state.copyWith(
          status: SyncStatus.idle,
          errorMessage: 'Kullanıcı oturumu bulunamadı.',
        );
        return;
      }

      final firestore = _firestoreInstance ?? FirebaseFirestore.instance;
      int processedItems = 0;
      final syncStartTime = DateTime.now().millisecondsSinceEpoch;

      // Delta Sync: Fetch last_synced_at timestamp from local SQLite tableSyncMetadata
      final lastSyncedAt = await _dbHelper.getLastSyncedAt() ?? 0;

      // Firestore WriteBatch: Queue all remote mutations into batches
      WriteBatch batch = firestore.batch();
      int batchOpCount = 0;

      Future<void> queueBatchOp() async {
        batchOpCount++;
        if (batchOpCount >= 450) {
          await batch.commit();
          batch = firestore.batch();
          batchOpCount = 0;
        }
      }

      // Queue lists for local SQLite atomic transaction
      final tripIdsToHardDelete = <String>[];
      final tripsToUpsertLocal = <Trip>[];

      final expenseIdsToHardDelete = <String>[];
      final expensesToUpsertLocal = <Expense>[];

      final docIdsToHardDelete = <String>[];
      final docsToUpsertLocal = <Document>[];

      final itemIdsToHardDelete = <String>[];
      final itemsToUpsertLocal = <PackingItem>[];

      // ===================================================================
      // ALGORITHM STEP 1: Process Soft-Deleted Records with LWW Conflict Check
      // If a remote edit is newer than the local deletion, remote edit wins.
      // Otherwise, batch delete from Firestore and queue hard delete in local SQLite.
      // ===================================================================

      // 1.1 Soft-deleted Trips strictly filtered by user_id
      final deletedTrips = await _dbHelper.getDeletedTrips(userId: uid);
      for (final trip in deletedTrips) {
        try {
          final doc = await firestore.collection('trips').doc(trip.id).get();
          if (doc.exists && doc.data() != null) {
            final remoteTrip = Trip.fromJson(doc.data()!);
            if (remoteTrip.updatedAt.isAfter(trip.updatedAt)) {
              // Remote edit occurred after local deletion: Remote wins
              tripsToUpsertLocal.add(remoteTrip);
              processedItems++;
              continue;
            }
          }
          batch.delete(firestore.collection('trips').doc(trip.id));
          await queueBatchOp();
        } catch (_) {}
        tripIdsToHardDelete.add(trip.id);
        processedItems++;
      }

      // 1.2 Soft-deleted Expenses strictly filtered by user_id
      final deletedExpenses = await _dbHelper.getDeletedExpenses(userId: uid);
      for (final expense in deletedExpenses) {
        try {
          final doc = await firestore.collection('expenses').doc(expense.id).get();
          if (doc.exists && doc.data() != null) {
            final remoteExpense = Expense.fromJson(doc.data()!);
            if (remoteExpense.updatedAt.isAfter(expense.updatedAt)) {
              // Remote edit occurred after local deletion: Remote wins
              expensesToUpsertLocal.add(remoteExpense);
              processedItems++;
              continue;
            }
          }
          batch.delete(firestore.collection('expenses').doc(expense.id));
          await queueBatchOp();
        } catch (_) {}
        expenseIdsToHardDelete.add(expense.id);
        processedItems++;
      }

      // 1.3 Soft-deleted Documents strictly filtered by user_id
      final deletedDocs = await _dbHelper.getDeletedDocuments(userId: uid);
      for (final doc in deletedDocs) {
        try {
          final docSnap = await firestore.collection('documents').doc(doc.id).get();
          if (docSnap.exists && docSnap.data() != null) {
            final remoteDoc = Document.fromJson(docSnap.data()!);
            if (remoteDoc.updatedAt.isAfter(doc.updatedAt)) {
              // Remote edit occurred after local deletion: Remote wins
              docsToUpsertLocal.add(remoteDoc);
              processedItems++;
              continue;
            }
          }
          batch.delete(firestore.collection('documents').doc(doc.id));
          await queueBatchOp();
        } catch (_) {}
        docIdsToHardDelete.add(doc.id);
        processedItems++;
      }

      // 1.4 Soft-deleted Checklist Items strictly filtered by user_id
      final deletedItems = await _dbHelper.getDeletedChecklistItems(userId: uid);
      for (final item in deletedItems) {
        try {
          final doc = await firestore.collection('checklist_items').doc(item.id).get();
          if (doc.exists && doc.data() != null) {
            final remoteItem = PackingItem.fromJson(doc.data()!);
            if (remoteItem.updatedAt.isAfter(item.updatedAt)) {
              // Remote edit occurred after local deletion: Remote wins
              itemsToUpsertLocal.add(remoteItem);
              processedItems++;
              continue;
            }
          }
          batch.delete(firestore.collection('checklist_items').doc(item.id));
          await queueBatchOp();
        } catch (_) {}
        itemIdsToHardDelete.add(item.id);
        processedItems++;
      }

      // ===================================================================
      // ALGORITHM STEP 2: Bidirectional Reconciliation with Last-Write-Wins (LWW)
      // Multi-tenant & Delta Sync with WriteBatch & SQLite Transactions
      // ===================================================================

      // 2.1 Reconcile Trips with Delta Sync & LWW
      Query<Map<String, dynamic>> tripsQuery = firestore
          .collection('trips')
          .where('user_id', isEqualTo: uid);
      if (lastSyncedAt > 0) {
        tripsQuery = tripsQuery.where('updated_at', isGreaterThan: lastSyncedAt);
      }
      final remoteTripsSnapshot = await tripsQuery.get();
      final remoteTripsMap = <String, Trip>{};
      for (final doc in remoteTripsSnapshot.docs) {
        try {
          remoteTripsMap[doc.id] = Trip.fromJson(doc.data());
        } catch (_) {}
      }

      final localTrips = await _dbHelper.getTrips(userId: uid, includeDeleted: false);
      final localTripsMap = <String, Trip>{for (final t in localTrips) t.id: t};

      for (final localTrip in localTrips) {
        final remoteTrip = remoteTripsMap[localTrip.id];
        if (remoteTrip == null) {
          // If remote not returned by delta query, check if local was updated since last sync
          if (lastSyncedAt == 0 || localTrip.updatedAt.millisecondsSinceEpoch > lastSyncedAt) {
            batch.set(
              firestore.collection('trips').doc(localTrip.id),
              localTrip.copyWith(userId: uid).toJson(),
              SetOptions(merge: true),
            );
            await queueBatchOp();
            processedItems++;
          }
        } else if (localTrip.updatedAt.isAfter(remoteTrip.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          batch.set(
            firestore.collection('trips').doc(localTrip.id),
            localTrip.copyWith(userId: uid).toJson(),
            SetOptions(merge: true),
          );
          await queueBatchOp();
          processedItems++;
        } else if (remoteTrip.updatedAt.isAfter(localTrip.updatedAt)) {
          // LWW: Remote modification is newer -> Overwrite local SQLite
          tripsToUpsertLocal.add(remoteTrip);
          processedItems++;
        }
      }

      for (final entry in remoteTripsMap.entries) {
        if (!localTripsMap.containsKey(entry.key)) {
          tripsToUpsertLocal.add(entry.value);
          processedItems++;
        }
      }

      // 2.2 Reconcile Expenses with Delta Sync & LWW
      Query<Map<String, dynamic>> expensesQuery = firestore
          .collection('expenses')
          .where('user_id', isEqualTo: uid);
      if (lastSyncedAt > 0) {
        expensesQuery = expensesQuery.where('updated_at', isGreaterThan: lastSyncedAt);
      }
      final remoteExpensesSnapshot = await expensesQuery.get();
      final remoteExpensesMap = <String, Expense>{};
      for (final doc in remoteExpensesSnapshot.docs) {
        try {
          remoteExpensesMap[doc.id] = Expense.fromJson(doc.data());
        } catch (_) {}
      }

      final localExpenses = await _dbHelper.getExpenses(userId: uid, includeDeleted: false);
      final localExpensesMap = <String, Expense>{for (final e in localExpenses) e.id: e};

      for (final localExpense in localExpenses) {
        final remoteExpense = remoteExpensesMap[localExpense.id];
        if (remoteExpense == null) {
          if (lastSyncedAt == 0 || localExpense.updatedAt.millisecondsSinceEpoch > lastSyncedAt) {
            batch.set(
              firestore.collection('expenses').doc(localExpense.id),
              localExpense.copyWith(userId: uid).toJson(),
              SetOptions(merge: true),
            );
            await queueBatchOp();
            processedItems++;
          }
        } else if (localExpense.updatedAt.isAfter(remoteExpense.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          batch.set(
            firestore.collection('expenses').doc(localExpense.id),
            localExpense.copyWith(userId: uid).toJson(),
            SetOptions(merge: true),
          );
          await queueBatchOp();
          processedItems++;
        } else if (remoteExpense.updatedAt.isAfter(localExpense.updatedAt)) {
          // LWW: Remote modification is newer -> Overwrite local SQLite
          expensesToUpsertLocal.add(remoteExpense);
          processedItems++;
        }
      }

      for (final entry in remoteExpensesMap.entries) {
        if (!localExpensesMap.containsKey(entry.key)) {
          expensesToUpsertLocal.add(entry.value);
          processedItems++;
        }
      }

      // 2.3 Reconcile Documents with Delta Sync & LWW
      Query<Map<String, dynamic>> docsQuery = firestore
          .collection('documents')
          .where('user_id', isEqualTo: uid);
      if (lastSyncedAt > 0) {
        docsQuery = docsQuery.where('updated_at', isGreaterThan: lastSyncedAt);
      }
      final remoteDocsSnapshot = await docsQuery.get();
      final remoteDocsMap = <String, Document>{};
      for (final doc in remoteDocsSnapshot.docs) {
        try {
          remoteDocsMap[doc.id] = Document.fromJson(doc.data());
        } catch (_) {}
      }

      final localDocs = await _dbHelper.getDocuments(userId: uid, includeDeleted: false);
      final localDocsMap = <String, Document>{for (final d in localDocs) d.id: d};

      for (final localDoc in localDocs) {
        final remoteDoc = remoteDocsMap[localDoc.id];
        if (remoteDoc == null) {
          if (lastSyncedAt == 0 || localDoc.updatedAt.millisecondsSinceEpoch > lastSyncedAt) {
            batch.set(
              firestore.collection('documents').doc(localDoc.id),
              localDoc.copyWith(userId: uid).toJson(),
              SetOptions(merge: true),
            );
            await queueBatchOp();
            processedItems++;
          }
        } else if (localDoc.updatedAt.isAfter(remoteDoc.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          batch.set(
            firestore.collection('documents').doc(localDoc.id),
            localDoc.copyWith(userId: uid).toJson(),
            SetOptions(merge: true),
          );
          await queueBatchOp();
          processedItems++;
        } else if (remoteDoc.updatedAt.isAfter(localDoc.updatedAt)) {
          // LWW: Remote modification is newer -> Overwrite local SQLite
          docsToUpsertLocal.add(remoteDoc);
          processedItems++;
        }
      }

      for (final entry in remoteDocsMap.entries) {
        if (!localDocsMap.containsKey(entry.key)) {
          docsToUpsertLocal.add(entry.value);
          processedItems++;
        }
      }

      // 2.4 Reconcile Checklist Items with Delta Sync & LWW
      Query<Map<String, dynamic>> itemsQuery = firestore
          .collection('checklist_items')
          .where('user_id', isEqualTo: uid);
      if (lastSyncedAt > 0) {
        itemsQuery = itemsQuery.where('updated_at', isGreaterThan: lastSyncedAt);
      }
      final remoteItemsSnapshot = await itemsQuery.get();
      final remoteItemsMap = <String, PackingItem>{};
      for (final doc in remoteItemsSnapshot.docs) {
        try {
          remoteItemsMap[doc.id] = PackingItem.fromJson(doc.data());
        } catch (_) {}
      }

      final localItems = await _dbHelper.getChecklistItems(userId: uid, includeDeleted: false);
      final localItemsMap = <String, PackingItem>{for (final i in localItems) i.id: i};

      for (final localItem in localItems) {
        final remoteItem = remoteItemsMap[localItem.id];
        if (remoteItem == null) {
          if (lastSyncedAt == 0 || localItem.updatedAt.millisecondsSinceEpoch > lastSyncedAt) {
            batch.set(
              firestore.collection('checklist_items').doc(localItem.id),
              localItem.copyWith(userId: uid).toJson(),
              SetOptions(merge: true),
            );
            await queueBatchOp();
            processedItems++;
          }
        } else if (localItem.updatedAt.isAfter(remoteItem.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          batch.set(
            firestore.collection('checklist_items').doc(localItem.id),
            localItem.copyWith(userId: uid).toJson(),
            SetOptions(merge: true),
          );
          await queueBatchOp();
          processedItems++;
        } else if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
          // LWW: Remote modification is newer -> Overwrite local SQLite
          itemsToUpsertLocal.add(remoteItem);
          processedItems++;
        }
      }

      for (final entry in remoteItemsMap.entries) {
        if (!localItemsMap.containsKey(entry.key)) {
          itemsToUpsertLocal.add(entry.value);
          processedItems++;
        }
      }

      // Commit any pending Firestore WriteBatch operations
      if (batchOpCount > 0) {
        await batch.commit();
      }

      // SQLite Transactions: Atomic update on local SQLite to avoid UI freezing
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        // 1. Execute queued local hard deletes
        for (final id in tripIdsToHardDelete) {
          await txn.delete(
            AppConstants.tableTrips,
            where: 'id = ? AND user_id = ?',
            whereArgs: [id, uid],
          );
        }
        for (final id in expenseIdsToHardDelete) {
          await txn.delete(
            AppConstants.tableExpenses,
            where: 'id = ? AND user_id = ?',
            whereArgs: [id, uid],
          );
        }
        for (final id in docIdsToHardDelete) {
          await txn.delete(
            AppConstants.tableDocuments,
            where: 'id = ? AND user_id = ?',
            whereArgs: [id, uid],
          );
        }
        for (final id in itemIdsToHardDelete) {
          await txn.delete(
            AppConstants.tableChecklistItems,
            where: 'id = ? AND user_id = ?',
            whereArgs: [id, uid],
          );
        }

        // 2. Execute queued local upserts (LWW remote wins & new remote items)
        for (final trip in tripsToUpsertLocal) {
          await txn.insert(
            AppConstants.tableTrips,
            trip.copyWith(userId: uid).toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final expense in expensesToUpsertLocal) {
          await txn.insert(
            AppConstants.tableExpenses,
            expense.copyWith(userId: uid).toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final doc in docsToUpsertLocal) {
          await txn.insert(
            AppConstants.tableDocuments,
            doc.copyWith(userId: uid).toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (final item in itemsToUpsertLocal) {
          await txn.insert(
            AppConstants.tableChecklistItems,
            item.copyWith(userId: uid).toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // 3. Update last_synced_at metadata in SQLite upon successful sync
        await txn.insert(
          AppConstants.tableSyncMetadata,
          {
            'key': 'sync_engine_last_synced_at',
            'value': DateTime.fromMillisecondsSinceEpoch(syncStartTime).toIso8601String(),
            'last_synced_at': syncStartTime,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      // Mark sync as completed and up to date
      state = state.copyWith(
        status: SyncStatus.upToDate,
        lastSyncTime: DateTime.fromMillisecondsSinceEpoch(syncStartTime),
        syncedCount: processedItems,
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.failed,
        errorMessage: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }
}

/// Riverpod Provider exposing the two-way sync engine
final syncEngineProvider = StateNotifierProvider<SyncEngine, SyncState>((ref) {
  return SyncEngine();
});
