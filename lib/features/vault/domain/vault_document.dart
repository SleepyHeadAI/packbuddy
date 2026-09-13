/// Domain entity representing a travel document stored in Document Vault
class VaultDocument {
  final String id;
  final String? tripId;
  final String title;
  final String filePath;
  final String category;
  final String? notes;
  final bool isDeleted;
  final String syncStatus;
  final DateTime updatedAt;

  const VaultDocument({
    required this.id,
    this.tripId,
    required this.title,
    required this.filePath,
    required this.category,
    this.notes,
    this.isDeleted = false,
    this.syncStatus = 'synced',
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'title': title,
      'file_path': filePath,
      'category': category,
      'notes': notes,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory VaultDocument.fromMap(Map<String, dynamic> map) {
    return VaultDocument(
      id: map['id'] as String,
      tripId: map['trip_id'] as String?,
      title: map['title'] as String,
      filePath: map['file_path'] as String,
      category: map['category'] as String,
      notes: map['notes'] as String?,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
