import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local_db/database_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/domain/expense.dart';
import '../../features/vault/domain/document.dart';
import '../../features/checklist/domain/packing_item.dart';
import '../../features/checklist/domain/canonical_packing_catalog.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/preferences_service.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/settings/data/mock_revenuecat_service.dart';

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
  final Ref? ref;
  final void Function(bool isPro)? onProStatusSynced;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSubscription;

  SyncEngine({
    DatabaseHelper? dbHelper,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    this.ref,
    this.onProStatusSynced,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _firestoreInstance = firestore,
        _authInstance = auth,
        super(const SyncState());

  /// Listens to real-time changes to the user's profile in Firestore (e.g., remote Admin Pro grants/revokes)
  void listenToUserDoc(String uid) {
    _userDocSubscription?.cancel();
    bool isFirebaseReady = false;
    try {
      isFirebaseReady = Firebase.apps.isNotEmpty;
    } catch (_) {}
    if (!isFirebaseReady && _firestoreInstance == null) return;
    final firestore = _firestoreInstance ?? FirebaseFirestore.instance;

    _userDocSubscription = firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          if (data.containsKey('isPremium')) {
            final isPro = data['isPremium'] == true;
            PreferencesService.instance.setProUser(isPro, uid: uid);
            onProStatusSynced?.call(isPro);
            final r = ref;
            if (r != null) {
              r.read(proSubscriptionProvider.notifier).updateProStatus(isPro, uid: uid);
            }
          }
          if (data.containsKey('restrictedFeatures')) {
            final feats = (data['restrictedFeatures'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                <String>[];
            PreferencesService.instance.setRestrictedFeatures(feats, uid: uid);
          }
          if (data.containsKey('banStatus')) {
            PreferencesService.instance.setBanStatus((data['banStatus'] as String?) ?? 'none', uid: uid);
            PreferencesService.instance.setBanExpiresAt(data['banExpiresAt'] as String?, uid: uid);
            PreferencesService.instance.setBanReason(data['banReason'] as String?, uid: uid);
          }
        }
      },
      onError: (err) {
        debugPrint('[SyncEngine] userDoc subscription error: $err');
      },
    );
  }

  /// Cancels any active Firestore user profile listener
  void cancelUserDocSubscription() {
    _userDocSubscription?.cancel();
    _userDocSubscription = null;
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    super.dispose();
  }

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

      // Feature restriction guard (Phase 3): Skip cloud sync if restricted by admin
      if (PreferencesService.instance.getRestrictedFeatures(uid: uid).contains('cloud_sync')) {
        state = state.copyWith(
          status: SyncStatus.idle,
          errorMessage: 'cloud_sync_restricted',
        );
        return;
      }

      final firestore = _firestoreInstance ?? FirebaseFirestore.instance;

      // Update lastActiveAt in Firestore
      try {
        await firestore.collection('users').doc(uid).set({
          'lastActiveAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (_) {}

      // Remote Pro Status Sync: Fetch users/{uid} and synchronize isPremium
      try {
        final userDoc = await firestore.collection('users').doc(uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          if (userData.containsKey('isPremium')) {
            final remoteIsPro = userData['isPremium'] == true;
            await PreferencesService.instance.setProUser(remoteIsPro, uid: uid);
            onProStatusSynced?.call(remoteIsPro);
            final r = ref;
            if (r != null) {
              r.read(proSubscriptionProvider.notifier).updateProStatus(remoteIsPro, uid: uid);
            }
          }
        }
      } catch (e) {
        debugPrint('[SyncEngine] Pro status sync notice: $e');
      }

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
      if (deletedTrips.isNotEmpty) {
        final tripDocs = await Future.wait(
          deletedTrips.map((trip) async {
            try {
              return await firestore.collection('trips').doc(trip.id).get();
            } catch (e) {
              debugPrint('[SyncEngine] fetch deleted trip notice: $e');
              return null;
            }
          }),
        );
        for (var i = 0; i < deletedTrips.length; i++) {
          final trip = deletedTrips[i];
          final doc = tripDocs[i];
          if (doc != null && doc.exists && doc.data() != null) {
            try {
              final remoteTrip = Trip.fromJson(doc.data()!);
              if (remoteTrip.updatedAt.isAfter(trip.updatedAt)) {
                tripsToUpsertLocal.add(remoteTrip);
                processedItems++;
                continue;
              }
            } catch (e) {
              debugPrint('[SyncEngine] parse remote trip notice: $e');
            }
          }
          batch.delete(firestore.collection('trips').doc(trip.id));
          await queueBatchOp();
          tripIdsToHardDelete.add(trip.id);
          processedItems++;
        }
      }

      // 1.2 Soft-deleted Expenses strictly filtered by user_id
      final deletedExpenses = await _dbHelper.getDeletedExpenses(userId: uid);
      if (deletedExpenses.isNotEmpty) {
        final expenseDocs = await Future.wait(
          deletedExpenses.map((expense) async {
            try {
              return await firestore.collection('expenses').doc(expense.id).get();
            } catch (e) {
              debugPrint('[SyncEngine] fetch deleted expense notice: $e');
              return null;
            }
          }),
        );
        for (var i = 0; i < deletedExpenses.length; i++) {
          final expense = deletedExpenses[i];
          final doc = expenseDocs[i];
          if (doc != null && doc.exists && doc.data() != null) {
            try {
              final remoteExpense = Expense.fromJson(doc.data()!);
              if (remoteExpense.updatedAt.isAfter(expense.updatedAt)) {
                expensesToUpsertLocal.add(remoteExpense);
                processedItems++;
                continue;
              }
            } catch (e) {
              debugPrint('[SyncEngine] parse remote expense notice: $e');
            }
          }
          batch.delete(firestore.collection('expenses').doc(expense.id));
          await queueBatchOp();
          expenseIdsToHardDelete.add(expense.id);
          processedItems++;
        }
      }

      // 1.3 Soft-deleted Documents strictly filtered by user_id
      final deletedDocs = await _dbHelper.getDeletedDocuments(userId: uid);
      if (deletedDocs.isNotEmpty) {
        final docSnaps = await Future.wait(
          deletedDocs.map((doc) async {
            try {
              return await firestore.collection('documents').doc(doc.id).get();
            } catch (e) {
              debugPrint('[SyncEngine] fetch deleted doc notice: $e');
              return null;
            }
          }),
        );
        for (var i = 0; i < deletedDocs.length; i++) {
          final doc = deletedDocs[i];
          final docSnap = docSnaps[i];
          if (docSnap != null && docSnap.exists && docSnap.data() != null) {
            try {
              final remoteDoc = Document.fromJson(docSnap.data()!);
              if (remoteDoc.updatedAt.isAfter(doc.updatedAt)) {
                docsToUpsertLocal.add(remoteDoc);
                processedItems++;
                continue;
              }
            } catch (e) {
              debugPrint('[SyncEngine] parse remote doc notice: $e');
            }
          }
          batch.delete(firestore.collection('documents').doc(doc.id));
          await queueBatchOp();
          docIdsToHardDelete.add(doc.id);
          processedItems++;
        }
      }

      // 1.4 Soft-deleted Checklist Items strictly filtered by user_id
      final deletedItems = await _dbHelper.getDeletedChecklistItems(userId: uid);
      if (deletedItems.isNotEmpty) {
        final itemDocs = await Future.wait(
          deletedItems.map((item) async {
            try {
              return await firestore.collection('checklist_items').doc(item.id).get();
            } catch (e) {
              debugPrint('[SyncEngine] fetch deleted item notice: $e');
              return null;
            }
          }),
        );
        for (var i = 0; i < deletedItems.length; i++) {
          final item = deletedItems[i];
          final doc = itemDocs[i];
          if (doc != null && doc.exists && doc.data() != null) {
            try {
              final remoteItem = PackingItem.fromJson(doc.data()!);
              if (remoteItem.updatedAt.isAfter(item.updatedAt)) {
                itemsToUpsertLocal.add(remoteItem);
                processedItems++;
                continue;
              }
            } catch (e) {
              debugPrint('[SyncEngine] parse remote item notice: $e');
            }
          }
          batch.delete(firestore.collection('checklist_items').doc(item.id));
          await queueBatchOp();
          itemIdsToHardDelete.add(item.id);
          processedItems++;
        }
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
        var docToPush = localDoc;
        // Ensure local document bytes are encoded for cloud backup
        if ((docToPush.cloudDataBase64 == null || docToPush.cloudDataBase64!.isEmpty) &&
            docToPush.localImagePath.isNotEmpty) {
          try {
            final f = File(docToPush.localImagePath);
            if (f.existsSync()) {
              final bytes = f.readAsBytesSync();
              const maxBytes = 700 * 1024;
              final ext = p.extension(docToPush.localImagePath).replaceAll('.', '').toLowerCase();
              if (bytes.length <= maxBytes) {
                final payload = base64Encode(bytes);
                docToPush = docToPush.copyWith(
                  cloudDataBase64: payload,
                  fileSizeBytes: bytes.length,
                  fileExtension: ext.isNotEmpty ? ext : (docToPush.isPdf ? 'pdf' : 'jpg'),
                );
                docsToUpsertLocal.add(docToPush);
              } else {
                debugPrint('[SyncEngine] Document "${docToPush.title}" exceeds 700KB limit (${bytes.length} bytes). Preserving local copy without byte corruption.');
                docToPush = docToPush.copyWith(
                  fileSizeBytes: bytes.length,
                  fileExtension: ext.isNotEmpty ? ext : (docToPush.isPdf ? 'pdf' : 'jpg'),
                );
              }
            }
          } catch (_) {}
        }

        final remoteDoc = remoteDocsMap[docToPush.id];
        if (remoteDoc == null) {
          if (lastSyncedAt == 0 || docToPush.updatedAt.millisecondsSinceEpoch > lastSyncedAt) {
            batch.set(
              firestore.collection('documents').doc(docToPush.id),
              docToPush.copyWith(userId: uid).toJson(),
              SetOptions(merge: true),
            );
            await queueBatchOp();
            processedItems++;
          }
        } else if (docToPush.updatedAt.isAfter(remoteDoc.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          batch.set(
            firestore.collection('documents').doc(docToPush.id),
            docToPush.copyWith(userId: uid).toJson(),
            SetOptions(merge: true),
          );
          await queueBatchOp();
          processedItems++;
        } else if (remoteDoc.updatedAt.isAfter(docToPush.updatedAt)) {
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

      // 2.4 Reconcile Checklist Items with Delta Sync & LWW (with Cross-ID Canonical Deduplication)
      await _dbHelper.deduplicateChecklistItems(userId: uid);
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

      // Map local items by canonical key for cross-id deduplication
      final localCanonicalMap = <String, PackingItem>{};
      for (final i in localItems) {
        final key = CanonicalPackingCatalog.resolveCanonicalKey(i.name) ?? CanonicalPackingCatalog.normalize(i.name);
        localCanonicalMap['${i.tripId ?? ""}:::$key'] = i;
      }

      // Remote items deduplication against duplicate Firestore documents
      final remoteGroups = <String, List<PackingItem>>{};
      for (final rItem in remoteItemsMap.values) {
        final rKey = CanonicalPackingCatalog.resolveCanonicalKey(rItem.name) ?? CanonicalPackingCatalog.normalize(rItem.name);
        final groupKey = '${rItem.tripId ?? ""}:::$rKey';
        remoteGroups.putIfAbsent(groupKey, () => []).add(rItem);
      }

      final sanitizedRemoteMap = <String, PackingItem>{};
      for (final entry in remoteGroups.entries) {
        final group = entry.value;
        if (group.length > 1) {
          group.sort((a, b) {
            if (a.isPacked != b.isPacked) return a.isPacked ? -1 : 1;
            final aDet = a.id.startsWith('default_') || a.id.startsWith('tpl_');
            final bDet = b.id.startsWith('default_') || b.id.startsWith('tpl_');
            if (aDet != bDet) return aDet ? -1 : 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });
          // Delete remote duplicate docs from Firestore
          for (var i = 1; i < group.length; i++) {
            batch.delete(firestore.collection('checklist_items').doc(group[i].id));
            await queueBatchOp();
          }
        }
        sanitizedRemoteMap[group.first.id] = group.first;
      }

      for (final localItem in localItems) {
        final remoteItem = sanitizedRemoteMap[localItem.id];
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

      for (final entry in sanitizedRemoteMap.entries) {
        if (!localItemsMap.containsKey(entry.key)) {
          final rItem = entry.value;
          final rKey = CanonicalPackingCatalog.resolveCanonicalKey(rItem.name) ?? CanonicalPackingCatalog.normalize(rItem.name);
          final groupKey = '${rItem.tripId ?? ""}:::$rKey';
          if (localCanonicalMap.containsKey(groupKey)) {
            // Duplicate item with different ID between remote and local!
            // Prefer packed state and delete legacy remote doc from Firestore
            final matchingLocal = localCanonicalMap[groupKey]!;
            if (rItem.isPacked && !matchingLocal.isPacked) {
              final updatedLocal = matchingLocal.copyWith(isPacked: true, updatedAt: DateTime.now());
              itemsToUpsertLocal.add(updatedLocal);
              batch.set(
                firestore.collection('checklist_items').doc(matchingLocal.id),
                updatedLocal.copyWith(userId: uid).toJson(),
                SetOptions(merge: true),
              );
              await queueBatchOp();
            }
            batch.delete(firestore.collection('checklist_items').doc(rItem.id));
            await queueBatchOp();
          } else {
            itemsToUpsertLocal.add(rItem);
            processedItems++;
          }
        }
      }

      // Commit any pending Firestore WriteBatch operations
      if (batchOpCount > 0) {
        await batch.commit();
      }

      // Restore missing files for documents pulled from cloud vault
      final resolvedDocsToUpsert = <VaultDocument>[];
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final vaultDir = Directory(p.join(appDir.path, 'vault_docs'));
        if (!await vaultDir.exists()) {
          await vaultDir.create(recursive: true);
        }

        for (final doc in docsToUpsertLocal) {
          var updatedDoc = doc;
          final localFile = File(doc.filePath);
          final fileExists = await localFile.exists();

          if (!fileExists && doc.cloudDataBase64 != null && doc.cloudDataBase64!.isNotEmpty) {
            try {
              final bytes = base64Decode(doc.cloudDataBase64!);
              final ext = doc.fileExtension ?? (doc.filePath.split('.').length > 1 ? doc.filePath.split('.').last : 'bin');
              final restoredPath = p.join(vaultDir.path, '${doc.id}_restored.$ext');
              final restoredFile = File(restoredPath);
              await restoredFile.writeAsBytes(bytes);
              updatedDoc = doc.copyWith(filePath: restoredPath);
            } catch (e) {
              debugPrint('[SyncEngine] Error restoring document file: $e');
            }
          }
          resolvedDocsToUpsert.add(updatedDoc);
        }
      } catch (e) {
        debugPrint('[SyncEngine] Error preparing vault directory for restore: $e');
        resolvedDocsToUpsert.addAll(docsToUpsertLocal);
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
        for (final doc in resolvedDocsToUpsert) {
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

        // Deduplicate checklist items atomically in SQLite after sync upsert
        await _dbHelper.deduplicateChecklistItems(executor: txn, userId: uid);

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

      // 4. Meter and sync aggregate vault storage to users/{uid} profile in Firestore
      try {
        final totalStorage = await _dbHelper.getTotalVaultStorageBytes(userId: uid);
        await firestore.collection('users').doc(uid).set(
          {
            'totalVaultStorageBytes': totalStorage,
            'storage_updated_at': syncStartTime,
          },
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('[SyncEngine] Storage metering update notice: $e');
      }

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
  final engine = SyncEngine(ref: ref);
  ref.listen<User?>(authUserProvider, (prev, next) {
    if (next != null) {
      engine.listenToUserDoc(next.uid);
    } else {
      engine.cancelUserDocSubscription();
    }
  });
  final initialUser = ref.read(authUserProvider);
  if (initialUser != null) {
    engine.listenToUserDoc(initialUser.uid);
  }
  return engine;
});
