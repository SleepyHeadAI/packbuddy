import 'dart:convert';

/// Represents a single logged synchronization event for audit and diagnostics
class SyncLogEntry {
  final String id;
  final DateTime timestamp;
  final String status; // 'upToDate', 'failed', 'noInternet'
  final int itemsSynced;
  final int conflictsResolved;
  final String? errorMessage;

  const SyncLogEntry({
    required this.id,
    required this.timestamp,
    required this.status,
    this.itemsSynced = 0,
    this.conflictsResolved = 0,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status,
      'itemsSynced': itemsSynced,
      'conflictsResolved': conflictsResolved,
      'errorMessage': errorMessage,
    };
  }

  factory SyncLogEntry.fromMap(Map<String, dynamic> map) {
    return SyncLogEntry(
      id: map['id']?.toString() ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['timestamp'] as num).toInt())
          : DateTime.now(),
      status: map['status']?.toString() ?? 'upToDate',
      itemsSynced: (map['itemsSynced'] as num?)?.toInt() ?? 0,
      conflictsResolved: (map['conflictsResolved'] as num?)?.toInt() ?? 0,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SyncLogEntry.fromJson(String source) =>
      SyncLogEntry.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

