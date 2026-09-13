/// Sync Status representation for two-way offline-first synchronization
enum SyncStatus {
  synced,
  pendingUpload,
  pendingDelete,
  syncing,
  failed,
}

/// Sync Result payload returned after a sync cycle
class SyncResult {
  final bool isSuccess;
  final int uploadedCount;
  final int downloadedCount;
  final int deletedCount;
  final String? errorMessage;
  final DateTime timestamp;

  const SyncResult({
    required this.isSuccess,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.deletedCount = 0,
    this.errorMessage,
    required this.timestamp,
  });
}

/// Abstract contract for the Two-Way Sync Engine (Local SQLite <-> Cloud Firestore)
abstract class ISyncEngine {
  /// Initiates a full bidirectional synchronization
  /// Rule: Locally deleted items cascade-delete from Firestore to conserve cloud storage
  Future<SyncResult> performSync();

  /// Observes real-time sync status
  Stream<SyncStatus> get syncStatusStream;

  /// Retrieves the last recorded sync time
  Future<DateTime?> getLastSyncTime();
}

/// Mock / Skeleton Sync Engine implementation prepared for Phase 2
class SyncEngine implements ISyncEngine {
  @override
  Future<SyncResult> performSync() async {
    // In Phase 1, return ready baseline status
    // Full Firestore bidirectional two-way logic will be implemented in Phase 2
    return SyncResult(
      isSuccess: true,
      uploadedCount: 0,
      downloadedCount: 0,
      deletedCount: 0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<SyncStatus> get syncStatusStream async* {
    yield SyncStatus.synced;
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return DateTime.now();
  }
}
