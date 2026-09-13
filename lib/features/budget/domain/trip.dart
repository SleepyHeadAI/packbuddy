/// Domain entity representing a travel Trip with soft-delete and two-way sync support
class Trip {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String defaultCurrency;
  final double? budgetLimit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.defaultCurrency = 'USD',
    this.budgetLimit,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Creates a copy with optionally modified fields
  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? defaultCurrency,
    double? budgetLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Serialization for Cloud Firestore / JSON APIs
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'defaultCurrency': defaultCurrency,
      'budgetLimit': budgetLimit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Deserialization from Cloud Firestore / JSON APIs
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      title: json['title'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      defaultCurrency: json['defaultCurrency'] as String? ?? 'USD',
      budgetLimit: (json['budgetLimit'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  /// Serialization for local SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'default_currency': defaultCurrency,
      'budget_limit': budgetLimit,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Deserialization from local SQLite database
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      title: map['title'] as String,
      destination: map['destination'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      defaultCurrency: map['default_currency'] as String? ?? 'USD',
      budgetLimit: (map['budget_limit'] as num?)?.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }
}
