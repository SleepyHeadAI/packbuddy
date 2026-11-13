import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/connectivity/domain/sync_log_entry.dart';

/// State representation for device connectivity, live sync progress, and diagnostics
class ConnectivityControllerState {
  final bool isOnline;
  final SyncStatus syncStatus;
  final DateTime? lastSyncTime;
  final String? errorMessage;
  final int pendingChangesCount;
  final Map<String, int> pendingBreakdown;
  final List<SyncLogEntry> syncHistory;

  const ConnectivityControllerState({
    this.isOnline = true,
    this.syncStatus = SyncStatus.idle,
    this.lastSyncTime,
    this.errorMessage,
    this.pendingChangesCount = 0,
    this.pendingBreakdown = const {},
    this.syncHistory = const [],
  });

  ConnectivityControllerState copyWith({
    bool? isOnline,
    SyncStatus? syncStatus,
    DateTime? lastSyncTime,
    String? errorMessage,
    int? pendingChangesCount,
    Map<String, int>? pendingBreakdown,
    List<SyncLogEntry>? syncHistory,
  }) {
    return ConnectivityControllerState(
      isOnline: isOnline ?? this.isOnline,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingChangesCount: pendingChangesCount ?? this.pendingChangesCount,
      pendingBreakdown: pendingBreakdown ?? this.pendingBreakdown,
      syncHistory: syncHistory ?? this.syncHistory,
    );
  }
}

/// Riverpod StateNotifier controlling connectivity telemetry, pending change calculation, and sync logs
class ConnectivityController extends StateNotifier<ConnectivityControllerState> {
  final Ref _ref;
  final DatabaseHelper _dbHelper;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConnectivityController(this._ref, {DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        super(const ConnectivityControllerState()) {
    _init();
  }

  void _init() {
    _initConnectivityListener();
    loadSyncHistory();
    refreshPendingChanges();
  }

  void _initConnectivityListener() {
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
        final isConnected = results.any((r) => r != ConnectivityResult.none);
        state = state.copyWith(isOnline: isConnected);
        if (isConnected) {
          refreshPendingChanges();
        }
      });
    } catch (_) {}
  }

  /// Updates internal sync status matching the SyncEngine state
  void updateSyncEngineState(SyncState syncState) {
    state = state.copyWith(
      syncStatus: syncState.status,
      lastSyncTime: syncState.lastSyncTime,
      errorMessage: syncState.errorMessage,
      isOnline: syncState.status != SyncStatus.noInternet,
    );
  }

  /// Calculates real-time count of locally modified records waiting to be synced to cloud
  Future<void> refreshPendingChanges({String? userId}) async {
    try {
      final breakdown = await _dbHelper.getPendingChangesBreakdown(userId: userId);
      final total = breakdown['total'] ?? 0;
      state = state.copyWith(
        pendingChangesCount: total,
        pendingBreakdown: breakdown,
      );
    } catch (_) {}
  }

  /// Loads stored sync logs from persistent local preferences
  void loadSyncHistory() {
    try {
      final rawList = PreferencesService.instance.getSyncHistory();
      final history = rawList
          .map((jsonStr) {
            try {
              return SyncLogEntry.fromJson(jsonStr);
            } catch (_) {
              return null;
            }
          })
          .whereType<SyncLogEntry>()
          .toList();

      state = state.copyWith(syncHistory: history);
    } catch (_) {}
  }

  /// Clears stored sync history logs
  Future<void> clearSyncHistory() async {
    await PreferencesService.instance.clearSyncHistory();
    state = state.copyWith(syncHistory: const []);
  }

  /// Triggers immediate cloud synchronization via SyncEngine
  Future<void> triggerManualSync() async {
    await _ref.read(syncEngineProvider.notifier).performSync();
    loadSyncHistory();
    await refreshPendingChanges();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Global provider for Connectivity and Sync telemetry
final connectivityControllerProvider =
    StateNotifierProvider<ConnectivityController, ConnectivityControllerState>((ref) {
  final syncState = ref.watch(syncEngineProvider);
  final controller = ConnectivityController(ref);
  controller.updateSyncEngineState(syncState);
  return controller;
});
