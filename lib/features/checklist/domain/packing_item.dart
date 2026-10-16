/// Packing Item domain entity representing luggage/checklist items
/// with support for collaborative assignment (Feature F-1) and weight-free architecture.
class PackingItem {
  final String id;
  final String userId;
  final String? tripId;
  final String name;
  final String category;
  final int quantity;
  final bool isPacked;
  final String tag; // e.g. "CARRY-ON", "CABIN ONLY", "CHECK-IN", "ESSENTIAL"
  final String compartment; // e.g. "Main Cabin", "Carry-on", "Front Pocket", "Toiletry Kit"
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // Collaboration fields (F-1)
  final String? assignedTo; // e.g. "Alex", "Mom", "Me"
  final String? packedBy;

  const PackingItem({
    required this.id,
    this.userId = '',
    this.tripId,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isPacked = false,
    this.tag = 'CARRY-ON',
    this.compartment = 'Main Cabin',
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.assignedTo,
    this.packedBy,
  });

  PackingItem copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? name,
    String? category,
    int? quantity,
    bool? isPacked,
    String? tag,
    String? compartment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    String? assignedTo,
    String? packedBy,
  }) {
    return PackingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isPacked: isPacked ?? this.isPacked,
      tag: tag ?? this.tag,
      compartment: compartment ?? this.compartment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      assignedTo: assignedTo ?? this.assignedTo,
      packedBy: packedBy ?? this.packedBy,
    );
  }

  /// Serialization for SQLite database
  Map<String, dynamic> toMap() {
    String effectiveTag = tag;
    if (assignedTo != null && assignedTo!.isNotEmpty && !effectiveTag.contains('[ASSIGNED:')) {
      effectiveTag = '$effectiveTag [ASSIGNED:$assignedTo]';
    }
    if (packedBy != null && packedBy!.isNotEmpty && !effectiveTag.contains('[PACKED_BY:')) {
      effectiveTag = '$effectiveTag [PACKED_BY:$packedBy]';
    }

    return {
      'id': id,
      'user_id': userId,
      'trip_id': tripId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'is_packed': isPacked ? 1 : 0,
      'tag': effectiveTag,
      'compartment': compartment,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
      'assigned_to': assignedTo,
      'packed_by': packedBy,
    };
  }

  /// Deserialization from SQLite database or Firestore
  factory PackingItem.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      return false;
    }

    final rawTag = (map['tag'] as String?) ?? 'CARRY-ON';
    String cleanTag = rawTag;
    String? parsedAssignedTo = (map['assignedTo'] ?? map['assigned_to']) as String?;
    String? parsedPackedBy = (map['packedBy'] ?? map['packed_by']) as String?;

    if (cleanTag.contains('[ASSIGNED:')) {
      final startIndex = cleanTag.indexOf('[ASSIGNED:') + '[ASSIGNED:'.length;
      final endIndex = cleanTag.indexOf(']', startIndex);
      if (endIndex > startIndex) {
        parsedAssignedTo ??= cleanTag.substring(startIndex, endIndex).trim();
        cleanTag = cleanTag.replaceAll(RegExp(r'\[ASSIGNED:[^\]]*\]'), '').trim();
      }
    }

    if (cleanTag.contains('[PACKED_BY:')) {
      final startIndex = cleanTag.indexOf('[PACKED_BY:') + '[PACKED_BY:'.length;
      final endIndex = cleanTag.indexOf(']', startIndex);
      if (endIndex > startIndex) {
        parsedPackedBy ??= cleanTag.substring(startIndex, endIndex).trim();
        cleanTag = cleanTag.replaceAll(RegExp(r'\[PACKED_BY:[^\]]*\]'), '').trim();
      }
    }

    return PackingItem(
      id: (map['id'] ?? '') as String,
      userId: (map['user_id'] ?? map['userId'] ?? '') as String,
      tripId: (map['trip_id'] ?? map['tripId']) as String?,
      name: (map['name'] ?? '') as String,
      category: (map['category'] ?? 'Diğer') as String,
      quantity: ((map['quantity'] as num?) ?? 1).toInt(),
      isPacked: parseBool(map['is_packed'] ?? map['isPacked']),
      tag: cleanTag.isEmpty ? 'CARRY-ON' : cleanTag,
      compartment: (map['compartment'] as String?) ?? 'Main Cabin',
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedAt']),
      isDeleted: parseBool(map['is_deleted'] ?? map['isDeleted']),
      assignedTo: parsedAssignedTo,
      packedBy: parsedPackedBy,
    );
  }

  /// Cloud Firestore & JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tripId': tripId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'isPacked': isPacked,
      'is_packed': isPacked ? 1 : 0,
      'tag': tag,
      'compartment': compartment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'assignedTo': assignedTo,
      'packedBy': packedBy,
    };
  }

  factory PackingItem.fromJson(Map<String, dynamic> json) => PackingItem.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackingItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          tripId == other.tripId &&
          name == other.name &&
          category == other.category &&
          quantity == other.quantity &&
          isPacked == other.isPacked &&
          tag == other.tag &&
          compartment == other.compartment &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isDeleted == other.isDeleted &&
          assignedTo == other.assignedTo &&
          packedBy == other.packedBy;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      tripId.hashCode ^
      name.hashCode ^
      category.hashCode ^
      quantity.hashCode ^
      isPacked.hashCode ^
      tag.hashCode ^
      compartment.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isDeleted.hashCode ^
      assignedTo.hashCode ^
      packedBy.hashCode;
}
