import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local_db/database_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/domain/expense.dart';
import '../../features/itinerary/domain/itinerary_item.dart';
import '../../features/itinerary/presentation/controllers/itinerary_controller.dart';
import '../../features/vault/domain/document.dart';
import '../../features/checklist/domain/packing_item.dart';
import '../../features/checklist/domain/canonical_packing_catalog.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/security_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/pro_entitlement_service.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/settings/data/mock_revenuecat_service.dart';
import '../../features/vault/presentation/controllers/vault_controller.dart';
import '../../features/travel_map/data/travel_map_service.dart';
import '../../features/travel_map/presentation/controllers/travel_map_controller.dart';
import '../../features/budget/presentation/controllers/trip_controller.dart';
import '../../features/budget/presentation/controllers/expense_controller.dart';
import '../../features/checklist/presentation/controllers/checklist_controller.dart';
import '../../features/connectivity/domain/sync_log_entry.dart';

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
  final FirebaseStorage? _storageInstance;
  final Ref? ref;
  final void Function(bool isPro)? onProStatusSynced;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _broadcastSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final Map<String, List<StreamSubscription>> _sharedTripSubscriptions = {};
  Timer? _debounceTimer;
  Timer? _heartbeatTimer;
  Timer? _retryTimer;
  int _retryCount = 0;
  bool _wasOffline = false;

  SyncEngine({
    DatabaseHelper? dbHelper,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    this.ref,
    this.onProStatusSynced,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _firestoreInstance = firestore,
        _authInstance = auth,
        _storageInstance = storage,
        super(const SyncState()) {
    _initConnectivityListener();
    _startPeriodicHeartbeat();
  }

  bool get _isTestEnvironment {
    return Platform.environment.containsKey('FLUTTER_TEST') ||
        WidgetsBinding.instance.runtimeType.toString().toLowerCase().contains('test');
  }

  /// Automatically monitors device network connectivity and schedules sync ONLY on genuine offline-to-online reconnection
  void _initConnectivityListener() {
    if (_isTestEnvironment) return;
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          final isConnected = results.any((r) => r != ConnectivityResult.none);
          if (!isConnected) {
            _wasOffline = true;
            debugPrint('[SyncEngine] Connectivity lost -> state set to noInternet');
            if (mounted && state.status != SyncStatus.syncing) {
              state = state.copyWith(status: SyncStatus.noInternet);
            }
          } else {
            // Only trigger sync if we were previously offline (reconnection event)
            if (_wasOffline) {
              _wasOffline = false;
              debugPrint('[SyncEngine] Connectivity restored from offline -> scheduling debounced auto-sync');
              _scheduleDebouncedSync(delay: const Duration(milliseconds: 2000));
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
          forceSync();
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

    _userDocSubscription = firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
      (snapshot) async {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          // A1: only react when a Pro entitlement field is actually present; a false remote
          // flag never revokes a store (Google Play) purchase.
          if (ProEntitlementService.hasRemoteProKey(data)) {
            final isPro = await ProEntitlementService.instance.applyRemoteEntitlement(
              remoteIsPro: ProEntitlementService.remoteProValue(data),
              expiresAt: ProEntitlementService.remoteExpiresAt(data),
              source: data['adminGrantedPro'] == true ? 'admin_live_grant' : 'firestore_live_sync',
              uid: uid,
            );
            onProStatusSynced?.call(isPro);
            final r = ref;
            if (r != null) {
              r.read(proSubscriptionProvider.notifier).setResolvedProStatus(isPro);
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
              final wId = warningMap['id']?.toString() ?? 'warn_${warningMap['timestamp'] ?? DateTime.now().millisecondsSinceEpoch}';
              final wTitle = warningMap['title']?.toString() ?? 'PackBuddy Bildirimi';
              final wBody = warningMap['message']?.toString() ?? '';
              final wTimestamp = (warningMap['timestamp'] as num?)?.toInt() ?? 0;
              final cloudLastSeen = (data['lastSeenAdminWarningAt'] as num?)?.toInt() ?? 0;
              final localLastSeen = PreferencesService.instance.getLastSeenAdminWarningAt(uid: uid);
              final effectiveLastSeen = cloudLastSeen > localLastSeen ? cloudLastSeen : localLastSeen;

              // Anti-repeat deduplication: Ensure each warning ID is delivered exactly once
              final bool isDelivered = PreferencesService.instance.hasDeliveredNotification(wId);
              final bool isNewTimestamp = wTimestamp > effectiveLastSeen;

              if (!isDelivered && (isNewTimestamp || effectiveLastSeen == 0)) {
                await PreferencesService.instance.markNotificationDelivered(wId);
                await PreferencesService.instance.setLastSeenAdminWarningAt(wTimestamp, uid: uid);
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
                await PreferencesService.instance.addNotificationHistoryItem(recordJson);

                // Show phone notification immediately so user ALWAYS receives it
                try {
                  final notifService = ref?.read(notificationServiceProvider);
                  await notifService?.showInstantNotification(
                    id: (wId.hashCode % 1000000000).abs(),
                    title: wTitle,
                    body: wBody,
                    payload: 'admin_warning:$wId',
                  );
                } catch (e) {
                  debugPrint('[SyncEngine] Warning notification error: $e');
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

    // Also start real-time listener for active broadcast announcements & marketing campaigns
    _listenToBroadcastAnnouncements(uid, firestore);
  }

  /// Listens to active broadcast campaigns & announcements with deduplication
  void _listenToBroadcastAnnouncements(String uid, FirebaseFirestore firestore) {
    _broadcastSubscription?.cancel();
    try {
      _broadcastSubscription = firestore
          .collection('broadcast_announcements')
          .where('active', isEqualTo: true)
          .snapshots()
          .listen((snapshot) async {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final bId = doc.id;
          final targetAudience = data['targetAudience']?.toString() ?? 'all';
          final isPro = PreferencesService.instance.isProUser(uid: uid);

          // Target audience segmentation filter
          if (targetAudience == 'free_only' && isPro) continue;
          if (targetAudience == 'pro_only' && !isPro) continue;

          // Deduplication: Only alert if not already delivered to this device
          if (!PreferencesService.instance.hasDeliveredNotification(bId)) {
            await PreferencesService.instance.markNotificationDelivered(bId);

            final title = data['title']?.toString() ?? 'PackBuddy Fırsatı 🚀';
            final body = data['message']?.toString() ?? data['body']?.toString() ?? '';
            final type = data['type']?.toString() ?? 'broadcast_discount';
            final targetAction = data['targetAction']?.toString() ?? 'paywall';
            final discount = (data['discountPercent'] as num?)?.toInt();
            final ts = (data['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;

            final recordJson = jsonEncode({
              'id': bId,
              'title': title,
              'body': body,
              'timestamp': ts,
              'type': type,
              'targetAction': targetAction,
              'discountPercent': ?discount,
            });
            await PreferencesService.instance.addNotificationHistoryItem(recordJson);

            try {
              final notifService = ref?.read(notificationServiceProvider);
              await notifService?.showInstantNotification(
                id: (bId.hashCode % 1000000000).abs(),
                title: title,
                body: body,
                payload: 'broadcast:$targetAction:$bId',
              );
            } catch (e) {
              debugPrint('[SyncEngine] Broadcast notification error: $e');
            }
          }
        }
      }, onError: (err) {
        debugPrint('[SyncEngine] Broadcast listener notice: $err');
      });
    } catch (e) {
      debugPrint('[SyncEngine] Error attaching broadcast listener: $e');
    }
  }

  /// Cancels any active Firestore user profile and broadcast listener
  void cancelUserDocSubscription() {
    _userDocSubscription?.cancel();
    _userDocSubscription = null;
    _broadcastSubscription?.cancel();
    _broadcastSubscription = null;
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

    // 4. Listen to itinerary items for this shared trip
    final itinSub = firestore
        .collection('itinerary_items')
        .where('trip_id', isEqualTo: tripId)
        .snapshots()
        .listen((snap) async {
      bool changed = false;
      for (final docChange in snap.docChanges) {
        try {
          final data = docChange.doc.data();
          if (data == null) continue;
          if (docChange.type == DocumentChangeType.removed) {
            await _dbHelper.hardDeleteItineraryItem(docChange.doc.id);
            changed = true;
          } else {
            data['id'] = docChange.doc.id;
            final item = ItineraryItem.fromMap(data);
            if (item.isDeleted) {
              await _dbHelper.hardDeleteItineraryItem(docChange.doc.id);
            } else {
              final localDeleted = await _dbHelper.getDeletedItineraryItems();
              final isLocallyDeleted = localDeleted.any((d) =>
                  d['id'] == item.id &&
                  !item.updatedAt.isAfter(DateTime.fromMillisecondsSinceEpoch((d['updated_at'] as num).toInt())));
              if (!isLocallyDeleted) {
                await _dbHelper.insertItineraryItem(item.toMap());
              }
            }
            changed = true;
          }
        } catch (e) {
          debugPrint('[SyncEngine] Real-time itinerary item sync error: $e');
        }
      }
      if (changed) {
        try {
          ref?.read(itineraryControllerFamily(tripId).notifier).loadItinerary();
        } catch (_) {}
      }
    }, onError: (e) => debugPrint('[SyncEngine] Itinerary snapshot error: $e'));
    subs.add(itinSub);

    _sharedTripSubscriptions[tripId] = subs;
    debugPrint('[SyncEngine] Started real-time live stream for shared trip $tripId');
  }

  /// Immediately pushes a trip update to Cloud Firestore (for instant collaboration sync)
  Future<void> pushTrip(Trip trip) async {
    try {
      bool isFirebaseReady = false;
      try {
        isFirebaseReady = Firebase.apps.isNotEmpty;
      } catch (_) {}
      if (!isFirebaseReady && _firestoreInstance == null) return;
      final firestore = _firestoreInstance ?? FirebaseFirestore.instance;
      await firestore
          .collection('trips')
          .doc(trip.id)
          .set(trip.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[SyncEngine] pushTrip error: $e');
    }
  }

  /// Immediately pushes an expense update to Cloud Firestore (for instant collaboration sync)
  Future<void> pushExpense(Expense expense) async {
    try {
      bool isFirebaseReady = false;
      try {
        isFirebaseReady = Firebase.apps.isNotEmpty;
      } catch (_) {}
      if (!isFirebaseReady && _firestoreInstance == null) return;
      final firestore = _firestoreInstance ?? FirebaseFirestore.instance;
      await firestore
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[SyncEngine] pushExpense error: $e');
    }
  }

  /// Immediately pushes an itinerary item update to Cloud Firestore (for instant collaboration sync)
  Future<void> pushItineraryItem(ItineraryItem item) async {
    try {
      bool isFirebaseReady = false;
      try {
        isFirebaseReady = Firebase.apps.isNotEmpty;
      } catch (_) {}
      if (!isFirebaseReady && _firestoreInstance == null) return;
      final firestore = _firestoreInstance ?? FirebaseFirestore.instance;
      await firestore
          .collection('itinerary_items')
          .doc(item.id)
          .set(item.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[SyncEngine] pushItineraryItem error: $e');
    }
  }

  /// Immediately marks an expense as deleted in Cloud Firestore
  Future<void> deleteRemoteExpense(String id) async {
    try {
      bool isFirebaseReady = false;
      try {
        isFirebaseReady = Firebase.apps.isNotEmpty;
      } catch (_) {}
      if (!isFirebaseReady && _firestoreInstance == null) return;
      final firestore = _firestoreInstance ?? FirebaseFirestore.instance;
      await firestore
          .collection('expenses')
          .doc(id)
          .set({
            'is_deleted': 1,
            'isDeleted': true,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Immediately marks an itinerary item as deleted in Cloud Firestore
  Future<void> deleteRemoteItineraryItem(String id) async {
    try {
      bool isFirebaseReady = false;
      try {
        isFirebaseReady = Firebase.apps.isNotEmpty;
      } catch (_) {}
      if (!isFirebaseReady && _firestoreInstance == null) return;
      final firestore = _firestoreInstance ?? FirebaseFirestore.instance;
      await firestore
          .collection('itinerary_items')
          .doc(id)
          .set({
            'is_deleted': 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          }, SetOptions(merge: true));
    } catch (_) {}
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
    _broadcastSubscription?.cancel();
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
  bool _hasPendingSyncRequest = false;

  /// Returns true if a synchronization process is actively executing
  bool get isSyncing => _isSyncing;

  /// Executes two-way bidirectional sync between local SQLite and Cloud Firestore.
  /// Uses Future Memoization with pending request queueing so concurrent callers trigger a follow-up sync.
  Future<void> performSync() => _performSyncInternal(force: false);

  /// Forces immediate cloud sync bypassing cooldowns (e.g. manual user interaction)
  Future<void> forceSync() => _performSyncInternal(force: true);

  Future<void> _performSyncInternal({bool force = false}) {
    _retryCount = 0;
    _retryTimer?.cancel();

    // Prevent hammering / redundant auto-sync within 10 seconds unless forced or previous sync failed
    if (!force &&
        !_isSyncing &&
        state.status == SyncStatus.upToDate &&
        state.lastSyncTime != null) {
      final elapsed = DateTime.now().difference(state.lastSyncTime!).inSeconds;
      if (elapsed < 10) {
        debugPrint('[SyncEngine] Skipping redundant sync (synced $elapsed s ago)');
        return Future.value();
      }
    }

    if (_activeSyncFuture != null) {
      debugPrint('[SyncEngine] Sync already in progress, queuing follow-up sync');
      _hasPendingSyncRequest = true;
      return _activeSyncFuture!;
    }

    _activeSyncFuture = _executeSync().whenComplete(() async {
      _activeSyncFuture = null;
      if (_hasPendingSyncRequest) {
        _hasPendingSyncRequest = false;
        debugPrint('[SyncEngine] Executing queued follow-up sync');
        await _performSyncInternal(force: force);
      }
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
        _recordSyncLog(status: 'noInternet', itemsSynced: 0, errorMessage: 'No internet connection');
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

      // Remote Pro Status Sync (A3): server data is applied through the Keystore-backed
      // entitlement service. Plaintext SharedPreferences is never an input, and
      // `lastVerifiedAt` is only refreshed when the server actually grants Pro.
      try {
        final userDoc = await firestore.collection('users').doc(uid).get();
        bool? resolvedIsPro;
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          if (ProEntitlementService.hasRemoteProKey(userData)) {
            resolvedIsPro = await ProEntitlementService.instance.applyRemoteEntitlement(
              remoteIsPro: ProEntitlementService.remoteProValue(userData),
              expiresAt: ProEntitlementService.remoteExpiresAt(userData),
              source: 'firestore_sync',
              uid: uid,
            );
          }
          // The vault PIN is device-local only (C3); never read it from Firestore.
          if (userData.containsKey('vaultBiometricEnabled')) {
            final remoteBio = userData['vaultBiometricEnabled'] == true;
            await PreferencesService.instance.setVaultBiometricEnabled(remoteBio, uid: uid);
          }
        }
        final effectiveIsPro =
            resolvedIsPro ?? await ProEntitlementService.instance.resolveEffectivePro(uid: uid);
        onProStatusSynced?.call(effectiveIsPro);
        final r = ref;
        if (r != null) {
          r.read(proSubscriptionProvider.notifier).setResolvedProStatus(effectiveIsPro);
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
      // D1: any failed batch means remote state is incomplete, so last_synced_at must not advance
      // (otherwise the failed local changes would be skipped by the next delta sync forever).
      bool batchCommitFailed = false;

      Future<void> commitPendingBatch() async {
        if (batchOpCount == 0) return;
        try {
          await batch.commit();
        } catch (e) {
          batchCommitFailed = true;
          debugPrint('[SyncEngine] Batch commit FAILED (last_synced_at will not advance): $e');
        } finally {
          batch = firestore.batch();
          batchOpCount = 0;
        }
      }

      Future<void> queueBatchOp() async {
        batchOpCount++;
        if (batchOpCount >= 450) {
          await commitPendingBatch();
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

      final itinIdsToHardDelete = <String>[];
      final itinToUpsertLocal = <ItineraryItem>[];

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
            batch.delete(firestore.collection('trips').doc(trip.id));
            await queueBatchOp();
          }
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
            batch.delete(firestore.collection('expenses').doc(expense.id));
            await queueBatchOp();
          }
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
            // Delete any chunks subcollection in Firestore to keep database clean
            try {
              final chunksSnap = await firestore.collection('documents').doc(doc.id).collection('chunks').get();
              for (final c in chunksSnap.docs) {
                batch.delete(c.reference);
                await queueBatchOp();
              }
            } catch (_) {}

            // Delete binary file from Firebase Storage
            if (isFirebaseReady) {
              try {
                final storage = _storageInstance ?? FirebaseStorage.instance;
                final sp = (doc.storagePath != null && doc.storagePath!.isNotEmpty)
                    ? doc.storagePath!
                    : 'users/$uid/vault/${doc.id}.bin';
                await storage.ref(sp).delete();
              } catch (_) {}
            }

            batch.delete(firestore.collection('documents').doc(doc.id));
            await queueBatchOp();
          }
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
            batch.delete(firestore.collection('checklist_items').doc(item.id));
            await queueBatchOp();
          }
          itemIdsToHardDelete.add(item.id);
          processedItems++;
        }
      }

      // 1.5 Soft-deleted Itinerary Items
      final deletedItin = await _dbHelper.getDeletedItineraryItems(userId: uid);
      if (deletedItin.isNotEmpty) {
        for (final raw in deletedItin) {
          final id = raw['id'] as String;
          try {
            batch.delete(firestore.collection('itinerary_items').doc(id));
            await queueBatchOp();
          } catch (_) {}
          itinIdsToHardDelete.add(id);
          processedItems++;
        }
      }

      // Commit pending deletions immediately to Firestore before Step 2 reconciliation
      await commitPendingBatch();

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
            final trip = Trip.fromJson(data);
            if (trip.isDeleted || tripIdsToHardDelete.contains(trip.id)) {
              continue;
            }
            remoteTripsMap[doc.id] = trip;
          } catch (_) {}
        }
      } catch (_) {}

      final userEmail = _authInstance?.currentUser?.email ?? FirebaseAuth.instance.currentUser?.email;
      if (userEmail != null && userEmail.isNotEmpty) {
        try {
          final collabEmailSnap = await firestore
              .collection('trips')
              .where('collaborators', arrayContains: userEmail)
              .get();
          for (final doc in collabEmailSnap.docs) {
            try {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = (data['id'] != null && data['id'].toString().isNotEmpty) ? data['id'] : doc.id;
              final trip = Trip.fromJson(data);
              if (trip.isDeleted || tripIdsToHardDelete.contains(trip.id)) {
                continue;
              }
              remoteTripsMap[doc.id] = trip;
            } catch (_) {}
          }
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
              localTrip.toJson(),
              SetOptions(merge: true),
            );
            await queueBatchOp();
            processedItems++;
          }
        } else if (localTrip.updatedAt.isAfter(remoteTrip.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          batch.set(
            firestore.collection('trips').doc(localTrip.id),
            localTrip.toJson(),
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
          final exp = Expense.fromJson(data);
          if (exp.isDeleted || expenseIdsToHardDelete.contains(exp.id)) {
            continue;
          }
          remoteExpensesMap[doc.id] = exp;
        } catch (e) {
          debugPrint('[SyncEngine] Expense parsing notice: $e');
        }
      }

      // Also pull expenses for active shared trips
      for (final t in localTrips) {
        if (t.isCollaborative) {
          try {
            final sharedExpSnap = await firestore
                .collection('expenses')
                .where('trip_id', isEqualTo: t.id)
                .get();
            for (final doc in sharedExpSnap.docs) {
              try {
                final data = Map<String, dynamic>.from(doc.data());
                data['id'] = doc.id;
                final exp = Expense.fromJson(data);
                if (exp.isDeleted || expenseIdsToHardDelete.contains(exp.id)) {
                  continue;
                }
                remoteExpensesMap[doc.id] = exp;
              } catch (_) {}
            }
          } catch (_) {}
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
              localExpense.toJson(),
              SetOptions(merge: true),
            );
            await queueBatchOp();
            processedItems++;
          }
        } else if (localExpense.updatedAt.isAfter(remoteExpense.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          batch.set(
            firestore.collection('expenses').doc(localExpense.id),
            localExpense.toJson(),
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

      final isProUser = PreferencesService.instance.isProUser(uid: uid);
      int runningVaultBytes = await _dbHelper.getTotalVaultStorageBytes(userId: uid);

      for (final localDoc in localDocs) {
        var docToPush = localDoc;
        var uploadedThisSync = false;
        // Upload to Firebase Storage with AES-256 binary encryption. If the upload can't happen
        // now, the document is left for the next sync: file bytes are never written to Firestore (C4).
        if ((docToPush.storagePath == null || docToPush.storagePath!.isEmpty) &&
            docToPush.localImagePath.isNotEmpty) {
          if (!isFirebaseReady) continue;
          try {
            final f = File(docToPush.localImagePath);
            if (f.existsSync()) {
              var bytes = f.readAsBytesSync();
              final rawBytes = SecurityService.instance.isEncrypted(bytes)
                  ? await SecurityService.instance.decryptBytes(bytes, userId: docToPush.userId)
                  : bytes;

              // Enforce 10 MB single file size limit & storage quota (50MB Free / 5GB Pro)
              if (rawBytes.length > ProFeatureGate.kMaxSingleFileBytes ||
                  !ProFeatureGate.canSyncToCloud(isPro: isProUser, totalCloudBytes: runningVaultBytes + rawBytes.length)) {
                debugPrint('[SyncEngine] Storage quota or file size limit reached for doc ${docToPush.id}. Skipping upload.');
                continue;
              }

              runningVaultBytes += rawBytes.length;
              final encryptedBytes = await SecurityService.instance.encryptBytes(rawBytes, userId: uid);
              final ext = p.extension(docToPush.localImagePath).replaceAll('.', '').toLowerCase();
              final storagePath = 'users/$uid/vault/${docToPush.id}.bin';

              try {
                final storage = _storageInstance ?? FirebaseStorage.instance;
                await storage.ref(storagePath).putData(
                  encryptedBytes,
                  SettableMetadata(contentType: 'application/octet-stream'),
                );
              } catch (storageErr) {
                debugPrint('[SyncEngine] Storage upload failed for ${docToPush.id}; retry on next sync: $storageErr');
                runningVaultBytes -= rawBytes.length;
                continue;
              }
              docToPush = docToPush.copyWith(
                storagePath: storagePath,
                fileSizeBytes: rawBytes.length,
                fileExtension: ext.isNotEmpty ? ext : (docToPush.isPdf ? 'pdf' : 'jpg'),
                clearCloudData: true,
              );
              docsToUpsertLocal.add(docToPush);
              uploadedThisSync = true;
            }
          } catch (e) {
            debugPrint('[SyncEngine] Vault upload preparation failed for ${docToPush.id}; retry on next sync: $e');
            continue;
          }
        }

        // Metadata only: any legacy plaintext payload is stripped (and cleared remotely via merge).
        final docJson = docToPush.copyWith(userId: uid, clearCloudData: true).toJson();

        final remoteDoc = remoteDocsMap[docToPush.id];
        final bool remoteMissingStorage = remoteDoc != null &&
            (remoteDoc.storagePath == null || remoteDoc.storagePath!.isEmpty) &&
            (docToPush.storagePath != null && docToPush.storagePath!.isNotEmpty);
        final bool remoteHasPlaintext = remoteDoc != null &&
            remoteDoc.cloudDataBase64 != null &&
            remoteDoc.cloudDataBase64!.isNotEmpty;

        if (remoteDoc == null || remoteMissingStorage || remoteHasPlaintext || uploadedThisSync) {
          if (lastSyncedAt == 0 ||
              docToPush.updatedAt.millisecondsSinceEpoch > lastSyncedAt ||
              remoteMissingStorage ||
              remoteHasPlaintext ||
              uploadedThisSync) {
            batch.set(
              firestore.collection('documents').doc(docToPush.id),
              docJson,
              SetOptions(merge: true),
            );
            await queueBatchOp();
            processedItems++;
          }
        } else if (docToPush.updatedAt.isAfter(remoteDoc.updatedAt)) {
          // LWW: Local modification is newer -> Overwrite Firestore
          batch.set(
            firestore.collection('documents').doc(docToPush.id),
            docJson,
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

      // 2.5 Reconcile Itinerary Items with Delta Sync & LWW
      final remoteItinDocs = await fetchDualDocs('itinerary_items');
      final remoteItinMap = <String, ItineraryItem>{};
      for (final doc in remoteItinDocs) {
        try {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          final item = ItineraryItem.fromMap(data);
          if (item.isDeleted || itinIdsToHardDelete.contains(item.id)) {
            continue;
          }
          remoteItinMap[doc.id] = item;
        } catch (e) {
          debugPrint('[SyncEngine] Itinerary item parsing notice: $e');
        }
      }

      // Also pull itinerary items for active shared collaborative trips
      for (final t in localTrips) {
        if (t.isCollaborative) {
          try {
            final sharedItinSnap = await firestore
                .collection('itinerary_items')
                .where('trip_id', isEqualTo: t.id)
                .get();
            for (final doc in sharedItinSnap.docs) {
              try {
                final data = Map<String, dynamic>.from(doc.data());
                data['id'] = doc.id;
                final item = ItineraryItem.fromMap(data);
                if (item.isDeleted || itinIdsToHardDelete.contains(item.id)) {
                  continue;
                }
                remoteItinMap[doc.id] = item;
              } catch (_) {}
            }
          } catch (_) {}
        }
      }

      final rawLocalItin = await _dbHelper.getItineraryItems(userId: uid, includeDeleted: false);
      final localItin = rawLocalItin.map((m) => ItineraryItem.fromMap(m)).toList();
      final localItinMap = <String, ItineraryItem>{for (final i in localItin) i.id: i};

      for (final localItem in localItin) {
        final remoteItem = remoteItinMap[localItem.id];
        if (remoteItem == null) {
          if (lastSyncedAt == 0 || localItem.updatedAt.millisecondsSinceEpoch > lastSyncedAt) {
            batch.set(
              firestore.collection('itinerary_items').doc(localItem.id),
              localItem.toMap(),
              SetOptions(merge: true),
            );
            await queueBatchOp();
            processedItems++;
          }
        } else if (localItem.updatedAt.isAfter(remoteItem.updatedAt)) {
          batch.set(
            firestore.collection('itinerary_items').doc(localItem.id),
            localItem.toMap(),
            SetOptions(merge: true),
          );
          await queueBatchOp();
          processedItems++;
        } else if (remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
          itinToUpsertLocal.add(remoteItem);
          processedItems++;
        }
      }

      for (final entry in remoteItinMap.entries) {
        if (itinIdsToHardDelete.contains(entry.key)) continue;
        if (!localItinMap.containsKey(entry.key)) {
          itinToUpsertLocal.add(entry.value);
          processedItems++;
        }
      }

      // Commit any pending Firestore WriteBatch operations
      await commitPendingBatch();

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

            // 1. Prioritize restoring from Firebase Storage
            if (isFirebaseReady) {
              try {
                final storage = _storageInstance ?? FirebaseStorage.instance;
                final sp = (doc.storagePath != null && doc.storagePath!.isNotEmpty)
                    ? doc.storagePath!
                    : 'users/${doc.userId}/vault/${doc.id}.bin';
                final data = await storage.ref(sp).getData();
                if (data != null && data.isNotEmpty) {
                  fileBytes = SecurityService.instance.isEncrypted(data)
                      ? await SecurityService.instance.decryptBytes(data, userId: doc.userId)
                      : data;
                }
              } catch (e) {
                debugPrint('[SyncEngine] Storage download notice, falling back to legacy chunks: $e');
              }
            }

            // 2. Legacy fallback: cloudDataBase64
            if (fileBytes == null && doc.cloudDataBase64 != null && doc.cloudDataBase64!.isNotEmpty) {
              try {
                fileBytes = base64Decode(doc.cloudDataBase64!);
              } catch (_) {}
            } else if (fileBytes == null && doc.fileSizeBytes > 0) {
              // 3. Legacy fallback: chunks subcollection in Firestore
              try {
                QuerySnapshot<Map<String, dynamic>>? chunksSnap;
                try {
                  chunksSnap = await firestore
                      .collection('documents')
                      .doc(doc.id)
                      .collection('chunks')
                      .orderBy('index')
                      .get();
                } catch (e) {
                  debugPrint('[SyncEngine] ordered chunks query notice, trying unindexed get: $e');
                  chunksSnap = await firestore
                      .collection('documents')
                      .doc(doc.id)
                      .collection('chunks')
                      .get();
                }

                if (chunksSnap.docs.isNotEmpty) {
                  final sortedDocs = chunksSnap.docs.toList()
                    ..sort((a, b) {
                      final idxA = (a.data()['index'] as num?)?.toInt() ?? 0;
                      final idxB = (b.data()['index'] as num?)?.toInt() ?? 0;
                      return idxA.compareTo(idxB);
                    });
                  final buffer = StringBuffer();
                  for (final c in sortedDocs) {
                    final piece = c.data()['chunk'] as String?;
                    if (piece != null && piece.isNotEmpty) buffer.write(piece);
                  }
                  final chunkedStr = buffer.toString().trim();
                  if (chunkedStr.isNotEmpty) {
                    var cleanChunked = chunkedStr;
                    if (cleanChunked.contains(',')) cleanChunked = cleanChunked.split(',').last;
                    fileBytes = base64Decode(cleanChunked);
                  }
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
                final encryptedBytes = await SecurityService.instance.encryptBytes(fileBytes, userId: doc.userId);
                await restoredFile.writeAsBytes(encryptedBytes);

                String? migratedStoragePath = doc.storagePath;
                // Auto-migration: if document was recovered from legacy chunks/base64, migrate to Firebase Storage
                if ((migratedStoragePath == null || migratedStoragePath.isEmpty) && isFirebaseReady) {
                  try {
                    final storage = _storageInstance ?? FirebaseStorage.instance;
                    final sp = 'users/${doc.userId}/vault/${doc.id}.bin';
                    await storage.ref(sp).putData(
                      encryptedBytes,
                      SettableMetadata(contentType: 'application/octet-stream'),
                    );
                    migratedStoragePath = sp;
                  } catch (migErr) {
                    debugPrint('[SyncEngine] Auto-migration to Firebase Storage notice: $migErr');
                  }
                }

                updatedDoc = doc.copyWith(
                  filePath: restoredPath,
                  storagePath: migratedStoragePath,
                );
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
        for (final id in itinIdsToHardDelete) {
          await txn.delete(
            AppConstants.tableItineraryItems,
            where: 'id = ?',
            whereArgs: [id],
          );
        }

        // 2. Execute queued local upserts (LWW remote wins & new remote items)
        for (final trip in tripsToUpsertLocal) {
          try {
            final effectiveTrip = trip.userId.isNotEmpty ? trip : trip.copyWith(userId: uid);
            await txn.insert(
              AppConstants.tableTrips,
              effectiveTrip.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } catch (e) {
            debugPrint('[SyncEngine] Local trip upsert error: $e');
          }
        }
        for (final expense in expensesToUpsertLocal) {
          try {
            final effectiveExpense = expense.userId.isNotEmpty ? expense : expense.copyWith(userId: uid);
            await txn.insert(
              AppConstants.tableExpenses,
              effectiveExpense.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } catch (e) {
            debugPrint('[SyncEngine] Local expense upsert error: $e');
          }
        }
        for (final doc in resolvedDocsToUpsert) {
          try {
            await txn.insert(
              AppConstants.tableDocuments,
              doc.copyWith(userId: uid).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } catch (e) {
            debugPrint('[SyncEngine] Local document upsert error: $e');
          }
        }
        for (final item in itemsToUpsertLocal) {
          try {
            await txn.insert(
              AppConstants.tableChecklistItems,
              item.copyWith(userId: uid).toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } catch (e) {
            debugPrint('[SyncEngine] Local checklist item upsert error: $e');
          }
        }
        for (final item in itinToUpsertLocal) {
          try {
            final effectiveItem = item.userId.isNotEmpty ? item : item.copyWith(userId: uid);
            await txn.insert(
              AppConstants.tableItineraryItems,
              effectiveItem.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } catch (e) {
            debugPrint('[SyncEngine] Local itinerary upsert error: $e');
          }
        }

        // Deduplicate checklist items atomically in SQLite after sync upsert
        await _dbHelper.deduplicateChecklistItems(executor: txn, userId: uid);

        // 3. Advance last_synced_at only when every Firestore batch committed (D1)
        if (!batchCommitFailed) {
          await txn.insert(
            AppConstants.tableSyncMetadata,
            {
              'key': 'sync_engine_last_synced_at',
              'value': DateTime.fromMillisecondsSinceEpoch(syncStartTime).toIso8601String(),
              'last_synced_at': syncStartTime,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } else {
          debugPrint('[SyncEngine] Skipping last_synced_at update: at least one batch failed.');
        }
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
      _recordSyncLog(
        status: 'upToDate',
        itemsSynced: processedItems,
        timestamp: DateTime.fromMillisecondsSinceEpoch(syncStartTime),
      );

      // Reset retry count on successful sync
      _retryCount = 0;
      _retryTimer?.cancel();

      // Ensure real-time live listeners are active for all shared collaborative trips
      for (final trip in localTrips) {
        if (trip.isCollaborative) {
          listenToSharedTrip(trip.id);
        }
      }
      for (final trip in tripsToUpsertLocal) {
        if (trip.isCollaborative) {
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
          if (itinToUpsertLocal.isNotEmpty || itinIdsToHardDelete.isNotEmpty) {
            for (final t in localTrips) {
              r.read(itineraryControllerFamily(t.id).notifier).loadItinerary();
            }
          }
          r.read(travelMapControllerProvider.notifier).loadCountries(userId: uid);
        } catch (_) {}
      }
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.failed,
        errorMessage: e.toString(),
      );
      _recordSyncLog(
        status: 'failed',
        itemsSynced: 0,
        errorMessage: e.toString(),
      );
      _scheduleRetry();
    } finally {
      _isSyncing = false;
    }
  }

  /// Appends diagnostic sync attempt log into persistent local preferences
  void _recordSyncLog({
    required String status,
    int itemsSynced = 0,
    int conflictsResolved = 0,
    String? errorMessage,
    DateTime? timestamp,
  }) {
    try {
      final now = timestamp ?? DateTime.now();
      final entry = SyncLogEntry(
        id: 'sync_${now.millisecondsSinceEpoch}',
        timestamp: now,
        status: status,
        itemsSynced: itemsSynced,
        conflictsResolved: conflictsResolved,
        errorMessage: errorMessage,
      );
      PreferencesService.instance.addSyncHistoryItem(entry.toJson());
    } catch (e) {
      debugPrint('[SyncEngine] Log record notice: $e');
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
