/// Packing Item domain entity representing luggage/checklist items
class PackingItem {
  final String id;
  final String? tripId;
  final String name;
  final String category;
  final int quantity;
  final double weightKg; // Unit weight in kilograms
  final bool isPacked;
  final String tag; // e.g. "CARRY-ON", "CABIN ONLY", "CHECK-IN", "ESSENTIAL"
  final String compartment; // e.g. "Main Cabin", "Carry-on", "Front Pocket", "Toiletry Kit"
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const PackingItem({
    required this.id,
    this.tripId,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.weightKg = 0.5,
    this.isPacked = false,
    this.tag = 'CARRY-ON',
    this.compartment = 'Main Cabin',
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Total combined weight for this item (unit weight * quantity)
  double get totalWeightKg => weightKg * quantity;

  PackingItem copyWith({
    String? id,
    String? tripId,
    String? name,
    String? category,
    int? quantity,
    double? weightKg,
    bool? isPacked,
    String? tag,
    String? compartment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return PackingItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      weightKg: weightKg ?? this.weightKg,
      isPacked: isPacked ?? this.isPacked,
      tag: tag ?? this.tag,
      compartment: compartment ?? this.compartment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Serialization for SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'weight_kg': weightKg,
      'is_packed': isPacked ? 1 : 0,
      'tag': tag,
      'compartment': compartment,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
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

    return PackingItem(
      id: (map['id'] ?? '') as String,
      tripId: (map['trip_id'] ?? map['tripId']) as String?,
      name: (map['name'] ?? '') as String,
      category: (map['category'] ?? 'Diğer') as String,
      quantity: ((map['quantity'] as num?) ?? 1).toInt(),
      weightKg: ((map['weight_kg'] ?? map['weightKg']) as num?)?.toDouble() ?? 0.5,
      isPacked: parseBool(map['is_packed'] ?? map['isPacked']),
      tag: (map['tag'] as String?) ?? 'CARRY-ON',
      compartment: (map['compartment'] as String?) ?? 'Main Cabin',
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedAt']),
      isDeleted: parseBool(map['is_deleted'] ?? map['isDeleted']),
    );
  }

  /// Cloud Firestore & JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'trip_id': tripId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'weightKg': weightKg,
      'weight_kg': weightKg,
      'isPacked': isPacked,
      'is_packed': isPacked ? 1 : 0,
      'tag': tag,
      'compartment': compartment,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory PackingItem.fromJson(Map<String, dynamic> json) => PackingItem.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackingItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          quantity == other.quantity &&
          weightKg == other.weightKg &&
          isPacked == other.isPacked &&
          tag == other.tag &&
          compartment == other.compartment &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      quantity.hashCode ^
      weightKg.hashCode ^
      isPacked.hashCode ^
      tag.hashCode ^
      compartment.hashCode ^
      isDeleted.hashCode;
}
