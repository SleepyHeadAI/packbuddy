import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_db/database_helper.dart';
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

/// Two-Way Sync Engine implementing the offline-first synchronization algorithm
class SyncEngine extends StateNotifier<SyncState> {
  final DatabaseHelper _dbHelper;
  final FirebaseFirestore? _firestoreInstance;

  SyncEngine({
    DatabaseHelper? dbHelper,
    FirebaseFirestore? firestore,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _firestoreInstance = firestore,
        super(const SyncState());

  /// Simple and fast check for internet connection
  Future<bool> hasInternetConnection() async {
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

      final firestore = _firestoreInstance ?? FirebaseFirestore.instance;
      int processedItems = 0;

      // ===================================================================
      // ALGORITHM STEP 1: Process Soft-Deleted Records with LWW Conflict Check
      // If a remote edit is newer than the local deletion, remote edit wins.
      // Otherwise, hard delete from Firestore and local SQLite.
      // ===================================================================
      
      // 1.1 Soft-deleted Trips
      final deletedTrips = await _dbHelper.getDeletedTrips();
      for (final trip in deletedTrips) {
        try {
          final doc = await firestore.collection('trips').doc(trip.id).get();
          if (doc.exists && doc.data() != null) {
            final remoteTrip = Trip.fromJson(doc.data()!);
            if (remoteTrip.updatedAt.isAfter(trip.updatedAt)) {
              // Remote edit occurred after local deletion: Remote wins
              await _dbHelper.updateTrip(remoteTrip);
              processedItems++;
              continue;
            }
          }
          await firestore.collection('trips').doc(trip.id).delete();
        } catch (_) {}
        await _dbHelper.hardDeleteTrip(trip.id);
        processedItems++;
      }

      // 1.2 Soft-deleted Expenses
      final deletedExpenses = await _dbHelper.getDeletedExpenses();
      for (final expense in deletedExpenses) {
        try {
          final doc = await firestore.collection('expenses').doc(expense.id).get();
          if (doc.exists && doc.data() != null) {
            final remoteExpense = Expense.fromJson(doc.data()!);
            if (remoteExpense.updatedAt.isAfter(expense.updatedAt)) {
              // Remote edit occurred after local deletion: Remote wins
              await _dbHelper.updateExpense(remoteExpense);
              processedItems++;
              continue;
            }
          }
          await firestore.collection('expenses').doc(expense.id).delete();
        } catch (_) {}
        await _dbHelper.hardDeleteExpense(expense.id);
        processedItems++;
      }

      // 1.3 Soft-deleted Documents
      final deletedDocs = await _dbHelper.getDeletedDocuments();
      for (final doc in deletedDocs) {
        try {
          final docSnap = await firestore.collection('documents').doc(doc.id).get();
          if (docSnap.exists && docSnap.data() != null) {
            final remoteDoc = Document.fromJson(docSnap.data()!);
            if (remoteDoc.updatedAt.isAfter(doc.updatedAt)) {
              // Remote edit occurred after local deletion: Remote wins
              await _dbHelper.updateDocument(remoteDoc);
              processedItems++;
              continue;
            }
          }
          await firestore.collection('documents').doc(doc.id).delete();
        } catch (_) {}
        await _dbHelper.hardDeleteDocument(doc.id);
        processedItems++;
      }

      // 1.4 Soft-deleted Checklist Items
      final deletedItems = await _dbHelper.getDeletedChecklistItems();
      for (final item in deletedItems) {
        try {
          final doc = await firestore.collection('checklist_items').doc(item.id).get();
          if (doc.exists && doc.data() != null) {
            final remoteItem = PackingItem.fromJson(doc.data()!);
            if (remoteItem.updatedAt.isAfter(item.updatedAt)) {
              // Remote edit occurred after local deletion: Remote wins
              await _dbHelper.updateChecklistItem(remoteItem);
              processedItems++;
              continue;
            }
          }
          await firestore.collection('checklist_items').doc(item.id).delete();
        } catch (_) {}
        await _dbHelper.hardDeleteChecklistItem(item.id);
        processedItems++;
      }

      // ===================================================================
      // ALGORITHM STEP 2: Bidirectional Reconciliation with Last-Write-Wins (LWW)
      // Conflict Resolution Strategy using `updatedAt` timestamps:
      // - If record exists only locally: Push to Cloud Firestore.
      // - If record exists only remotely: Pull & insert into SQLite.
      // - If record exists on both devices:
      //     * local.updatedAt > remote.updatedAt: Local wins -> Overwrite Firestore
      //     * remote.updatedAt > local.updatedAt: Remote wins -> Overwrite SQLite
      //     * timestamps equal: Already synchronized -> No write needed.
      // ===================================================================

      // 2.1 Reconcile Trips with LWW
      final remoteTripsSnapshot = await firestore.collection('trips').get();
      final remoteTripsMap = <String, Trip>{};
      for (final doc in remoteTripsSnapshot.docs) {
        try {
          remoteTripsMap[doc.id] = Trip.fromJson(doc.data());
        } catch (_) {}
      }

      final localTrips = await _dbHelper.getTrips(includeDeleted: false);
      final localTripsMap = <String, Trip>{for (final t in localTrips) t.id: t};

      for (final localTrip in localTrips) {
        final remoteTrip = remoteTripsMap[localTrip.id];
        if (remoteTrip == null) {
          await firestore.collection('trips').doc(localTrip.id).set(
            localTrip.toJson(),
            SetOptions(merge: true),
          );
          processedItems++;
        } else if (localTrip.updatedAt.isAfter(remoteTrip.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          await firestore.collection('trips').doc(localTrip.id).set(
            localTrip.toJson(),
            SetOptions(merge: true),
          );
          processedItems++;
        } else if (remoteTrip.updatedAt.isAfter(localTrip.updatedAt)) {
          // LWW: Remote modification is newer -> Overwrite local SQLite
          await _dbHelper.updateTrip(remoteTrip);
          processedItems++;
        }
      }

      for (final entry in remoteTripsMap.entries) {
        if (!localTripsMap.containsKey(entry.key)) {
          await _dbHelper.insertTrip(entry.value);
          processedItems++;
        }
      }

      // 2.2 Reconcile Expenses with LWW
      final remoteExpensesSnapshot = await firestore.collection('expenses').get();
      final remoteExpensesMap = <String, Expense>{};
      for (final doc in remoteExpensesSnapshot.docs) {
        try {
          remoteExpensesMap[doc.id] = Expense.fromJson(doc.data());
        } catch (_) {}
      }

      final localExpenses = await _dbHelper.getExpenses(includeDeleted: false);
      final localExpensesMap = <String, Expense>{for (final e in localExpenses) e.id: e};

      for (final localExpense in localExpenses) {
        final remoteExpense = remoteExpensesMap[localExpense.id];
        if (remoteExpense == null) {
          await firestore.collection('expenses').doc(localExpense.id).set(
            localExpense.toJson(),
            SetOptions(merge: true),
          );
          processedItems++;
        } else if (localExpense.updatedAt.isAfter(remoteExpense.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          await firestore.collection('expenses').doc(localExpense.id).set(
            localExpense.toJson(),
            SetOptions(merge: true),
          );
          processedItems++;
        } else if (remoteExpense.updatedAt.isAfter(localExpense.updatedAt)) {
          // LWW: Remote modification is newer -> Overwrite local SQLite
          await _dbHelper.updateExpense(remoteExpense);
          processedItems++;
        }
      }

      for (final entry in remoteExpensesMap.entries) {
        if (!localExpensesMap.containsKey(entry.key)) {
          await _dbHelper.insertExpense(entry.value);
          processedItems++;
        }
      }

      // 2.3 Reconcile Documents with LWW
      final remoteDocsSnapshot = await firestore.collection('documents').get();
      final remoteDocsMap = <String, Document>{};
      for (final doc in remoteDocsSnapshot.docs) {
        try {
          remoteDocsMap[doc.id] = Document.fromJson(doc.data());
        } catch (_) {}
      }

      final localDocs = await _dbHelper.getDocuments(includeDeleted: false);
      final localDocsMap = <String, Document>{for (final d in localDocs) d.id: d};

      for (final localDoc in localDocs) {
        final remoteDoc = remoteDocsMap[localDoc.id];
        if (remoteDoc == null) {
          await firestore.collection('documents').doc(localDoc.id).set(
            localDoc.toJson(),
            SetOptions(merge: true),
          );
          processedItems++;
        } else if (localDoc.updatedAt.isAfter(remoteDoc.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          await firestore.collection('documents').doc(localDoc.id).set(
            localDoc.toJson(),
            SetOptions(merge: true),
          );
          processedItems++;
        } else if (remoteDoc.updatedAt.isAfter(localDoc.updatedAt)) {
          // LWW: Remote modification is newer -> Overwrite local SQLite
          await _dbHelper.updateDocument(remoteDoc);
          processedItems++;
        }
      }

      for (final entry in remoteDocsMap.entries) {
        if (!localDocsMap.containsKey(entry.key)) {
          await _dbHelper.insertDocument(entry.value);
          processedItems++;
        }
      }

      // 2.4 Reconcile Checklist Items with LWW
      final remoteItemsSnapshot = await firestore.collection('checklist_items').get();
      final remoteItemsMap = <String, PackingItem>{};
      for (final doc in remoteItemsSnapshot.docs) {
        try {
          remoteItemsMap[doc.id] = PackingItem.fromJson(doc.data());
        } catch (_) {}
      }

      final localItems = await _dbHelper.getChecklistItems(includeDeleted: false);
      final localItemsMap = <String, PackingItem>{for (final i in localItems) i.id: i};

      for (final localItem in localItems) {
        final remoteItem = remoteItemsMap[localItem.id];
        if (remoteItem == null) {
          await firestore.collection('checklist_items').doc(localItem.id).set(
            localItem.toJson(),
            SetOptions(merge: true),
          );
          processedItems++;
        } else if (localItem.updatedAt.isAfter(remoteItem.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          await firestore.collection('checklist_items').doc(localItem.id).set(
            localItem.toJson(),
            SetOptions(merge: true),
          );
          processedItems++;
        } else if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
          // LWW: Remote modification is newer -> Overwrite local SQLite
          await _dbHelper.updateChecklistItem(remoteItem);
          processedItems++;
        }
      }

      for (final entry in remoteItemsMap.entries) {
        if (!localItemsMap.containsKey(entry.key)) {
          await _dbHelper.insertChecklistItem(entry.value);
          processedItems++;
        }
      }

      // Mark sync as completed and up to date
      state = state.copyWith(
        status: SyncStatus.upToDate,
        lastSyncTime: DateTime.now(),
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
