import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
import '../../core/services/security_service.dart';
import '../../core/services/notification_service.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/settings/data/mock_revenuecat_service.dart';
import '../../features/vault/presentation/controllers/vault_controller.dart';
import '../../features/travel_map/data/travel_map_service.dart';
import '../../features/travel_map/presentation/controllers/travel_map_controller.dart';
import '../../features/budget/presentation/controllers/trip_controller.dart';
import '../../features/budget/presentation/controllers/expense_controller.dart';
import '../../features/checklist/presentation/controllers/checklist_controller.dart';

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
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final Map<String, List<StreamSubscription>> _sharedTripSubscriptions = {};
  Timer? _debounceTimer;
  Timer? _heartbeatTimer;
  Timer? _retryTimer;
  int _retryCount = 0;

  SyncEngine({
    DatabaseHelper? dbHelper,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    this.ref,
    this.onProStatusSynced,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _firestoreInstance = firestore,
        _authInstance = auth,
        super(const SyncState()) {
    _initConnectivityListener();
    _startPeriodicHeartbeat();
  }

  bool get _isTestEnvironment {
    return Platform.environment.containsKey('FLUTTER_TEST') ||
        WidgetsBinding.instance.runtimeType.toString().toLowerCase().contains('test');
  }

  /// Automatically monitors device network connectivity and schedules sync on restore
  void _initConnectivityListener() {
    if (_isTestEnvironment) return;
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          final isConnected = results.any((r) => r != ConnectivityResult.none);
          if (isConnected) {
            debugPrint('[SyncEngine] Connectivity restored ($results) -> scheduling debounced auto-sync');
            _scheduleDebouncedSync(delay: const Duration(milliseconds: 1500));
          } else {
            debugPrint('[SyncEngine] Connectivity lost -> state set to offlineReady');
            if (mounted && state.status != SyncStatus.syncing) {
              state = state.copyWith(status: SyncStatus.noInternet);
            }
          }
        },
        onError: (err) {
          debugPrint('[SyncEngine] Connectivity listener notice: $err');
        },
      );
    } catch (e) {
      debugPrint('[SyncEngine] Failed to initialize connectivity listener: $e');
    }
  }

  /// Debounces rapid network triggers or back-to-back writes
  void _scheduleDebouncedSync({Duration delay = const Duration(milliseconds: 1500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      if (mounted && !_isSyncing) {
        performSync();
      }
    });
  }

  /// Periodic silent background heartbeat (every 5 minutes) to sync multi-device modifications
  void _startPeriodicHeartbeat() {
    if (_isTestEnvironment) return;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted && !_isSyncing && state.status != SyncStatus.syncing) {
        performSync();
      }
    });
  }

  /// Schedules exponential backoff retry upon sync errors (15s, 30s, 45s...)
  void _scheduleRetry() {
    if (_isTestEnvironment) return;
    _retryTimer?.cancel();
    if (_retryCount < 5) {
      _retryCount++;
      final delaySeconds = _retryCount * 15;
      debugPrint('[SyncEngine] Scheduling automatic retry #$_retryCount in $delaySeconds seconds...');
      _retryTimer = Timer(Duration(seconds: delaySeconds), () {
        if (mounted && !_isSyncing) {
          performSync();
        }
      });
    }
  }

  /// Listens to real-time changes to the user's profile in Firestore (e.g., remote Admin Pro grants/revokes)
  void listenToUserDoc(String uid) {
    _userDocSubscription?.cancel();
    bool isFirebaseReady = false;
    try {
      isFirebaseReady = Firebase.apps.isNotEmpty;
    } catch (_) {}
    if (!isFirebaseReady && _firestoreInstance == null) return;
    final firestore = _firestoreInstance ?? FirebaseFirestore.instance;

    bool isInitialSnapshot = true;

    _userDocSubscription = firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
      (snapshot) {
        final isFirst = isInitialSnapshot;
        isInitialSnapshot = false;
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          final bool hasProKey = data.containsKey('isPremium') ||
              data.containsKey('is_premium') ||
              data.containsKey('isPro') ||
              data.containsKey('pro');
          if (hasProKey) {
            final isPro = (data['isPremium'] == true) ||
                (data['is_premium'] == true) ||
                (data['isPro'] == true) ||
                (data['pro'] == true);
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
          if (data.containsKey('latestAdminWarning')) {
            final warningMap = data['latestAdminWarning'];
            if (warningMap is Map) {
              final wId = warningMap['id']?.toString() ?? '';
              final wTitle = warningMap['title']?.toString() ?? 'PackBuddy Bildirimi';
              final wBody = warningMap['message']?.toString() ?? '';
              final wTimestamp = (warningMap['timestamp'] as num?)?.toInt() ?? 0;
              final cloudLastSeen = (data['lastSeenAdminWarningAt'] as num?)?.toInt() ?? 0;
              final localLastSeen = PreferencesService.instance.getLastSeenAdminWarningAt(uid: uid);
              final effectiveLastSeen = cloudLastSeen > localLastSeen ? cloudLastSeen : localLastSeen;

              final nowMs = DateTime.now().millisecondsSinceEpoch;
              final isOldWarning = (nowMs - wTimestamp) > 180000; // > 3 minutes old

              if (wTimestamp > effectiveLastSeen) {
                PreferencesService.instance.setLastSeenAdminWarningAt(wTimestamp, uid: uid);
                try {
                  firestore.collection('users').doc(uid).set({
                    'lastSeenAdminWarningAt': wTimestamp,
                  }, SetOptions(merge: true));
                } catch (_) {}

                final recordJson = jsonEncode({
                  'id': wId.isNotEmpty ? wId : '${DateTime.now().millisecondsSinceEpoch}',
                  'title': wTitle,
                  'body': wBody,
                  'timestamp': wTimestamp > 0 ? wTimestamp : DateTime.now().millisecondsSinceEpoch,
                  'type': 'admin_warning',
                });
                PreferencesService.instance.addNotificationHistoryItem(recordJson);

                // Do not pop instant heads-up alert if this is an old historical warning on first app load / reinstall
                final shouldAlert = !isOldWarning && !isFirst;
                if (shouldAlert) {
                  try {
                    final notifService = ref?.read(notificationServiceProvider);
                    notifService?.showInstantNotification(
                      id: (wTimestamp % 1000000000).abs(),
                      title: wTitle,
                      body: wBody,
                      payload: 'admin_warning:$wId',
                    );
                  } catch (_) {}
                }
              }
            }
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
    cancelAllSharedTripListeners();
  }

  /// Subscribes to real-time changes for a shared trip and its items & expenses (Phase 2)
  void listenToSharedTrip(String tripId) {
    if (_sharedTripSubscriptions.containsKey(tripId)) return;
    bool isFirebaseReady = false;
    try {
      isFirebaseReady = Firebase.apps.isNotEmpty;
    } catch (_) {}
    if (!isFirebaseReady && _firestoreInstance == null) return;
    final firestore = _firestoreInstance ?? FirebaseFirestore.instance;

    final subs = <StreamSubscription>[];

    // 1. Listen to shared trip document itself
    final tripSub = firestore.collection('trips').doc(tripId).snapshots().listen((snap) async {
      if (!snap.exists || snap.data() == null) return;
      try {
        final updatedTrip = Trip.fromJson(snap.data()!);
        if (updatedTrip.isDeleted) {
          await _dbHelper.hardDeleteTrip(tripId);
        } else {
          final localDeleted = await _dbHelper.getDeletedTrips();
          final isLocallyDeleted = localDeleted.any((d) => d.id == updatedTrip.id && !updatedTrip.updatedAt.isAfter(d.updatedAt));
          if (!isLocallyDeleted) {
            await _dbHelper.insertTrip(updatedTrip);
          }
        }
        final currentUid = _authInstance?.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
        if (currentUid != null) {
          ref?.read(tripControllerProvider.notifier).loadTrips(userId: currentUid);
        }
      } catch (e) {
        debugPrint('[SyncEngine] Real-time trip update error: $e');
      }
    }, onError: (e) => debugPrint('[SyncEngine] Trip snapshot error: $e'));
    subs.add(tripSub);

    // 2. Listen to checklist items for this trip
    final itemsSub = firestore
        .collection('checklist_items')
        .where('trip_id', isEqualTo: tripId)
        .snapshots()
        .listen((snap) async {
      bool changed = false;
      for (final docChange in snap.docChanges) {
        try {
          final data = docChange.doc.data();
          if (data == null) continue;
          if (docChange.type == DocumentChangeType.removed) {
            await _dbHelper.hardDeleteChecklistItem(docChange.doc.id);
            changed = true;
          } else {
            final item = PackingItem.fromJson(data);
            if (item.isDeleted) {
              await _dbHelper.hardDeleteChecklistItem(docChange.doc.id);
            } else {
              final localDeleted = await _dbHelper.getDeletedChecklistItems();
              final isLocallyDeleted = localDeleted.any((d) => d.id == item.id && !item.updatedAt.isAfter(d.updatedAt));
              if (!isLocallyDeleted) {
                await _dbHelper.insertChecklistItem(item);
              }
            }
            changed = true;
          }
        } catch (e) {
          debugPrint('[SyncEngine] Real-time checklist item sync error: $e');
        }
      }
      if (changed) {
        final currentUid = _authInstance?.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
        if (currentUid != null) {
          ref?.read(checklistControllerProvider.notifier).loadItems(userId: currentUid);
        }
      }
    }, onError: (e) => debugPrint('[SyncEngine] Checklist snapshot error: $e'));
    subs.add(itemsSub);

    // 3. Listen to expenses for this trip
    final expensesSub = firestore
        .collection('expenses')
        .where('trip_id', isEqualTo: tripId)
        .snapshots()
        .listen((snap) async {
      bool changed = false;
      for (final docChange in snap.docChanges) {
        try {
          final data = docChange.doc.data();
          if (data == null) continue;
          if (docChange.type == DocumentChangeType.removed) {
            await _dbHelper.hardDeleteExpense(docChange.doc.id);
            changed = true;
          } else {
            final exp = Expense.fromJson(data);
            if (exp.isDeleted) {
              await _dbHelper.hardDeleteExpense(docChange.doc.id);
            } else {
              final localDeleted = await _dbHelper.getDeletedExpenses();
              final isLocallyDeleted = localDeleted.any((d) => d.id == exp.id && !exp.updatedAt.isAfter(d.updatedAt));
              if (!isLocallyDeleted) {
                await _dbHelper.insertExpense(exp);
              }
            }
            changed = true;
          }
        } catch (e) {
          debugPrint('[SyncEngine] Real-time expense sync error: $e');
        }
      }
      if (changed) {
        try {
          ref?.read(expenseControllerProvider(tripId).notifier).loadExpenses();
        } catch (_) {}
      }
    }, onError: (e) => debugPrint('[SyncEngine] Expense snapshot error: $e'));
    subs.add(expensesSub);

    _sharedTripSubscriptions[tripId] = subs;
    debugPrint('[SyncEngine] Started real-time live stream for shared trip $tripId');
  }

  /// Cancels live listeners for a specific shared trip
  void cancelSharedTripListener(String tripId) {
    final subs = _sharedTripSubscriptions.remove(tripId);
    if (subs != null) {
      for (final s in subs) {
        s.cancel();
      }
    }
  }

  /// Cancels all active shared trip listeners to prevent memory leaks
  void cancelAllSharedTripListeners() {
    for (final subs in _sharedTripSubscriptions.values) {
      for (final s in subs) {
        s.cancel();
      }
    }
    _sharedTripSubscriptions.clear();
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    _connectivitySubscription?.cancel();
    cancelAllSharedTripListeners();
    _debounceTimer?.cancel();
    _heartbeatTimer?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  /// Simple, fast, and resilient check for internet connection with multi-host fallback
  Future<bool> hasInternetConnection() async {
    if (_isTestEnvironment) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 6),
      );
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    try {
      final result = await InternetAddress.lookup('cloudflare.com').timeout(
        const Duration(seconds: 4),
      );
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _isSyncing = false;
  Future<void>? _activeSyncFuture;

  /// Returns true if a synchronization process is actively executing
  bool get isSyncing => _isSyncing;

  /// Executes two-way bidirectional sync between local SQLite and Cloud Firestore.
  /// Uses Future Memoization: multiple concurrent callers await the single active synchronization.
  Future<void> performSync() {
    if (_activeSyncFuture != null) {
      debugPrint('[SyncEngine] Sync already in progress, awaiting active sync Future');
      return _activeSyncFuture!;
    }

    _activeSyncFuture = _executeSync().whenComplete(() {
      _activeSyncFuture = null;
    });

    return _activeSyncFuture!;
  }

  Future<void> _executeSync() async {
    _isSyncing = true;

    try {
      // 1. Check network connectivity
      final isOnline = await hasInternetConnection();
      if (!isOnline) {
        state = state.copyWith(status: SyncStatus.noInternet);
        _scheduleRetry();
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
          errorMessage: 'user_session_not_found',
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

      // Remote Pro Status Sync: Fetch users/{uid} and synchronize isPremium without demoting active local Pro
      try {
        final userDoc = await firestore.collection('users').doc(uid).get();
        final localIsPro = PreferencesService.instance.isProUser(uid: uid) ||
            PreferencesService.instance.isProUser();
        bool effectiveIsPro = localIsPro;
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          final bool hasRemotePro = userData.containsKey('isPremium') ||
              userData.containsKey('is_premium') ||
              userData.containsKey('isPro') ||
              userData.containsKey('pro');
          if (hasRemotePro) {
            final remoteIsPro = (userData['isPremium'] == true) ||
                (userData['is_premium'] == true) ||
                (userData['isPro'] == true) ||
                (userData['pro'] == true);
            effectiveIsPro = remoteIsPro || localIsPro;
          }
          if (userData.containsKey('vaultPin')) {
            final remotePin = userData['vaultPin'] as String?;
            await PreferencesService.instance.setVaultPin(remotePin, uid: uid);
          }
          if (userData.containsKey('vaultBiometricEnabled')) {
            final remoteBio = userData['vaultBiometricEnabled'] == true;
            await PreferencesService.instance.setVaultBiometricEnabled(remoteBio, uid: uid);
          }
        }
        await PreferencesService.instance.setProUser(effectiveIsPro, uid: uid);
        onProStatusSynced?.call(effectiveIsPro);
        final r = ref;
        if (r != null) {
          r.read(proSubscriptionProvider.notifier).updateProStatus(effectiveIsPro, uid: uid);
          r.read(vaultControllerProvider.notifier).refreshSecurityState();
        }
      } catch (e) {
        debugPrint('[SyncEngine] Pro status sync notice: $e');
      }

      // World Travel Map Two-Way Cloud Sync
      try {
        await TravelMapService.instance.syncWithCloud(uid: uid);
      } catch (e) {
        debugPrint('[SyncEngine] Travel map sync in performSync notice: $e');
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
          // Delete any chunks subcollection in Firestore to keep database clean
          try {
            final chunksSnap = await firestore.collection('documents').doc(doc.id).collection('chunks').get();
            for (final c in chunksSnap.docs) {
              batch.delete(c.reference);
              await queueBatchOp();
            }
          } catch (_) {}

          batch.delete(firestore.collection('documents').doc(doc.id));
          await queueBatchOp();
          docIdsToHardDelete.add(doc.id);
          processedItems++;
        }
      }

      // 1.4 Soft-deleted Checklist Items strictly filtered by user_id
      final deletedItems = await _dbHelper.getDeletedChecklistItems(userId: uid);
      final deletedCanonicalMap = <String, PackingItem>{};
      for (final di in deletedItems) {
        final dKey = CanonicalPackingCatalog.resolveCanonicalKey(di.name) ?? CanonicalPackingCatalog.normalize(di.name);
        deletedCanonicalMap['${di.tripId ?? ""}:::$dKey'] = di;
      }

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

      // Commit pending deletions immediately to Firestore before Step 2 reconciliation
      if (batchOpCount > 0) {
        await batch.commit();
        batch = firestore.batch();
        batchOpCount = 0;
      }

      // ===================================================================
      // ALGORITHM STEP 2: Bidirectional Reconciliation with Last-Write-Wins (LWW)
      // Multi-tenant & Delta Sync with WriteBatch & SQLite Transactions
      // ===================================================================

      // Helper to fetch documents from Firestore supporting both snake_case (user_id) and camelCase (userId).
      // Uses single-field equality filters to avoid requiring Firestore composite indexes (FAILED_PRECONDITION).
      Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchDualDocs(
        String collectionName,
      ) async {
        final results = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

        // Query 1: user_id == uid (primary snake_case column)
        try {
          final snap1 = await firestore
              .collection(collectionName)
              .where('user_id', isEqualTo: uid)
              .get();
          for (final doc in snap1.docs) {
            results[doc.id] = doc;
          }
        } catch (e) {
          debugPrint('[SyncEngine] Query by user_id on $collectionName notice: $e');
        }

        // Query 2: userId == uid (legacy / cross-platform camelCase compatibility)
        try {
          final snap2 = await firestore
              .collection(collectionName)
              .where('userId', isEqualTo: uid)
              .get();
          for (final doc in snap2.docs) {
            results[doc.id] = doc;
          }
        } catch (e) {
          debugPrint('[SyncEngine] Query by userId on $collectionName notice: $e');
        }

        return results.values.toList();
      }

      // 2.1 Reconcile Trips with Delta Sync & LWW (Owner trips + Shared collaborative trips)
      final remoteTripsDocs = await fetchDualDocs('trips');
      final remoteTripsMap = <String, Trip>{};
      for (final doc in remoteTripsDocs) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = (data['id'] != null && data['id'].toString().isNotEmpty) ? data['id'] : doc.id;
          data['user_id'] = data['user_id'] ?? data['userId'] ?? uid;
          data['userId'] = data['userId'] ?? data['user_id'] ?? uid;
          final trip = Trip.fromJson(data);
          if (trip.isDeleted || tripIdsToHardDelete.contains(trip.id)) {
            continue;
          }
          remoteTripsMap[doc.id] = trip;
        } catch (e) {
          debugPrint('[SyncEngine] Trip parsing notice: $e');
        }
      }

      // Also pull collaborative trips where user is a participant
      try {
        final collabSnap = await firestore
            .collection('trips')
            .where('collaborators', arrayContains: uid)
            .get();
        for (final doc in collabSnap.docs) {
          try {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = (data['id'] != null && data['id'].toString().isNotEmpty) ? data['id'] : doc.id;
            data['user_id'] = data['user_id'] ?? data['userId'] ?? uid;
            data['userId'] = data['userId'] ?? data['user_id'] ?? uid;
            final trip = Trip.fromJson(data);
            if (trip.isDeleted || tripIdsToHardDelete.contains(trip.id)) {
              continue;
            }
            remoteTripsMap[doc.id] = trip;
          } catch (_) {}
        }
      } catch (_) {}

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
        if (tripIdsToHardDelete.contains(entry.key)) continue;
        if (!localTripsMap.containsKey(entry.key)) {
          tripsToUpsertLocal.add(entry.value);
          processedItems++;
        }
      }

      // 2.2 Reconcile Expenses with Delta Sync & LWW
      final remoteExpensesDocs = await fetchDualDocs('expenses');
      final remoteExpensesMap = <String, Expense>{};
      for (final doc in remoteExpensesDocs) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = (data['id'] != null && data['id'].toString().isNotEmpty) ? data['id'] : doc.id;
          data['user_id'] = data['user_id'] ?? data['userId'] ?? uid;
          data['userId'] = data['userId'] ?? data['user_id'] ?? uid;
          final exp = Expense.fromJson(data);
          if (exp.isDeleted || expenseIdsToHardDelete.contains(exp.id)) {
            continue;
          }
          remoteExpensesMap[doc.id] = exp;
        } catch (e) {
          debugPrint('[SyncEngine] Expense parsing notice: $e');
        }
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
        if (expenseIdsToHardDelete.contains(entry.key)) continue;
        if (!localExpensesMap.containsKey(entry.key)) {
          expensesToUpsertLocal.add(entry.value);
          processedItems++;
        }
      }

      // 2.3 Reconcile Documents with Delta Sync & LWW
      final remoteDocsList = await fetchDualDocs('documents');
      final remoteDocsMap = <String, Document>{};
      for (final doc in remoteDocsList) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = (data['id'] != null && data['id'].toString().isNotEmpty) ? data['id'] : doc.id;
          data['user_id'] = data['user_id'] ?? data['userId'] ?? uid;
          data['userId'] = data['userId'] ?? data['user_id'] ?? uid;
          final d = Document.fromJson(data);
          if (d.isDeleted || docIdsToHardDelete.contains(d.id)) {
            continue;
          }
          remoteDocsMap[doc.id] = d;
        } catch (e) {
          debugPrint('[SyncEngine] Document parsing notice: $e');
        }
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
              const maxDirectBytes = 700 * 1024;
              final ext = p.extension(docToPush.localImagePath).replaceAll('.', '').toLowerCase();
              if (bytes.length <= maxDirectBytes) {
                final payload = base64Encode(bytes);
                docToPush = docToPush.copyWith(
                  cloudDataBase64: payload,
                  fileSizeBytes: bytes.length,
                  fileExtension: ext.isNotEmpty ? ext : (docToPush.isPdf ? 'pdf' : 'jpg'),
                );
                docsToUpsertLocal.add(docToPush);
              } else {
                // Large document (>700KB up to 10MB): chunk into Firestore subcollection
                final payload = base64Encode(bytes);
                docToPush = docToPush.copyWith(
                  fileSizeBytes: bytes.length,
                  fileExtension: ext.isNotEmpty ? ext : (docToPush.isPdf ? 'pdf' : 'jpg'),
                  cloudDataBase64: '',
                );
                if (bytes.length <= 10 * 1024 * 1024) {
                  const chunkSize = 400 * 1024;
                  final totalChunks = (payload.length / chunkSize).ceil();
                  for (int i = 0; i < totalChunks; i++) {
                    final start = i * chunkSize;
                    final end = (start + chunkSize < payload.length) ? start + chunkSize : payload.length;
                    final chunkStr = payload.substring(start, end);
                    batch.set(
                      firestore.collection('documents').doc(docToPush.id).collection('chunks').doc('chunk_$i'),
                      {
                        'index': i,
                        'total': totalChunks,
                        'chunk': chunkStr,
                        'updated_at': docToPush.updatedAt.millisecondsSinceEpoch,
                      },
                      SetOptions(merge: true),
                    );
                    await queueBatchOp();
                  }
                }
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
        if (docIdsToHardDelete.contains(entry.key)) continue;
        if (!localDocsMap.containsKey(entry.key)) {
          docsToUpsertLocal.add(entry.value);
          processedItems++;
        }
      }

      // 2.4 Reconcile Checklist Items with Delta Sync & LWW (with Cross-ID Canonical Deduplication)
      await _dbHelper.deduplicateChecklistItems(userId: uid);
      final remoteItemsDocs = await fetchDualDocs('checklist_items');
      final remoteItemsMap = <String, PackingItem>{};
      for (final doc in remoteItemsDocs) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = (data['id'] != null && data['id'].toString().isNotEmpty) ? data['id'] : doc.id;
          data['user_id'] = data['user_id'] ?? data['userId'] ?? uid;
          data['userId'] = data['userId'] ?? data['user_id'] ?? uid;
          final item = PackingItem.fromJson(data);
          if (item.isDeleted || itemIdsToHardDelete.contains(item.id)) {
            continue;
          }
          remoteItemsMap[doc.id] = item;
        } catch (e) {
          debugPrint('[SyncEngine] PackingItem parsing notice: $e');
        }
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

        // Check if this item was deleted locally
        final deletedMatch = deletedCanonicalMap[groupKey];
        if (deletedMatch != null && !rItem.updatedAt.isAfter(deletedMatch.updatedAt)) {
          // User deleted this canonical item locally and remote is not newer!
          // Purge duplicate remote doc from Firestore and skip upsert
          batch.delete(firestore.collection('checklist_items').doc(rItem.id));
          await queueBatchOp();
          continue;
        }

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
          final isCleared = PreferencesService.instance.hasClearedChecklist(uid: uid);
          if (isCleared && localItem.id.startsWith('default_')) {
            itemIdsToHardDelete.add(localItem.id);
            continue;
          }
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
        if (itemIdsToHardDelete.contains(entry.key)) continue;
        if (!localItemsMap.containsKey(entry.key)) {
          final rItem = entry.value;
          final rKey = CanonicalPackingCatalog.resolveCanonicalKey(rItem.name) ?? CanonicalPackingCatalog.normalize(rItem.name);
          final groupKey = '${rItem.tripId ?? ""}:::$rKey';

          final deletedMatch = deletedCanonicalMap[groupKey];
          if (deletedMatch != null && !rItem.updatedAt.isAfter(deletedMatch.updatedAt)) {
            batch.delete(firestore.collection('checklist_items').doc(rItem.id));
            await queueBatchOp();
            continue;
          }

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

          if (!fileExists) {
            Uint8List? fileBytes;
            if (doc.cloudDataBase64 != null && doc.cloudDataBase64!.isNotEmpty) {
              try {
                fileBytes = base64Decode(doc.cloudDataBase64!);
              } catch (_) {}
            } else if (doc.fileSizeBytes > 0) {
              // Try restoring from chunks subcollection in Firestore
              try {
                final chunksSnap = await firestore
                    .collection('documents')
                    .doc(doc.id)
                    .collection('chunks')
                    .orderBy('index')
                    .get();
                if (chunksSnap.docs.isNotEmpty) {
                  final buffer = StringBuffer();
                  for (final c in chunksSnap.docs) {
                    final piece = c.data()['chunk'] as String?;
                    if (piece != null) buffer.write(piece);
                  }
                  fileBytes = base64Decode(buffer.toString());
                }
              } catch (e) {
                debugPrint('[SyncEngine] Error restoring chunked document: $e');
              }
            }

            if (fileBytes != null) {
              try {
                final ext = doc.fileExtension ?? (doc.filePath.split('.').length > 1 ? doc.filePath.split('.').last : 'bin');
                final restoredPath = p.join(vaultDir.path, '${doc.id}_restored.$ext');
                final restoredFile = File(restoredPath);
                final encryptedBytes = await SecurityService.instance.encryptBytes(fileBytes);
                await restoredFile.writeAsBytes(encryptedBytes);
                updatedDoc = doc.copyWith(filePath: restoredPath);
              } catch (e) {
                debugPrint('[SyncEngine] Error writing restored file: $e');
              }
            }
          }
          resolvedDocsToUpsert.add(updatedDoc);
        }
      } catch (e) {
        debugPrint('[SyncEngine] Error preparing vault directory for restore: $e');
        resolvedDocsToUpsert.addAll(docsToUpsertLocal);
      }

      // Final sanity filtering: ensure no queued deleted IDs are in upsert lists!
      tripsToUpsertLocal.removeWhere((t) => tripIdsToHardDelete.contains(t.id));
      expensesToUpsertLocal.removeWhere((e) => expenseIdsToHardDelete.contains(e.id));
      resolvedDocsToUpsert.removeWhere((d) => docIdsToHardDelete.contains(d.id));
      itemsToUpsertLocal.removeWhere((i) => itemIdsToHardDelete.contains(i.id));

      // SQLite Transactions: Atomic update on local SQLite to avoid UI freezing
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        // 1. Execute queued local hard deletes
        for (final id in tripIdsToHardDelete) {
          await txn.delete(
            AppConstants.tableTrips,
            where: 'id = ?',
            whereArgs: [id],
          );
        }
        for (final id in expenseIdsToHardDelete) {
          await txn.delete(
            AppConstants.tableExpenses,
            where: 'id = ?',
            whereArgs: [id],
          );
        }
        for (final id in docIdsToHardDelete) {
          await txn.delete(
            AppConstants.tableDocuments,
            where: 'id = ?',
            whereArgs: [id],
          );
        }
        for (final id in itemIdsToHardDelete) {
          await txn.delete(
            AppConstants.tableChecklistItems,
            where: 'id = ?',
            whereArgs: [id],
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

      // Reset retry count on successful sync
      _retryCount = 0;
      _retryTimer?.cancel();

      // Ensure real-time live listeners are active for all shared collaborative trips
      for (final trip in tripsToUpsertLocal) {
        if (trip.isShared || trip.collaborators.isNotEmpty) {
          listenToSharedTrip(trip.id);
        }
      }

      // Refresh active domain UI controllers when remote mutations occurred
      final r = ref;
      if (r != null) {
        try {
          if (tripsToUpsertLocal.isNotEmpty || tripIdsToHardDelete.isNotEmpty) {
            r.read(tripControllerProvider.notifier).loadTrips(userId: uid);
          }
          if (itemsToUpsertLocal.isNotEmpty || itemIdsToHardDelete.isNotEmpty) {
            r.read(checklistControllerProvider.notifier).loadItems(userId: uid);
          }
          if (docsToUpsertLocal.isNotEmpty || docIdsToHardDelete.isNotEmpty) {
            r.read(vaultControllerProvider.notifier).loadDocuments(userId: uid);
          }
          r.read(travelMapControllerProvider.notifier).loadCountries(userId: uid);
        } catch (_) {}
      }
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.failed,
        errorMessage: e.toString(),
      );
      _scheduleRetry();
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
      // Auto-trigger full two-way sync as soon as user logs in or switches
      engine.performSync();
    } else {
      engine.cancelUserDocSubscription();
    }
  });
  final initialUser = ref.read(authUserProvider);
  if (initialUser != null) {
    engine.listenToUserDoc(initialUser.uid);
    // Cold start auto-sync if user is already authenticated
    Future.microtask(() => engine.performSync());
  }
  return engine;
});
