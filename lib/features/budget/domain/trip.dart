/// Domain entity representing a travel Trip with soft-delete and two-way sync support
class Trip {
  final String id;
  final String userId;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String defaultCurrency;
  final double? budgetLimit;
  final String? countryCode;
  final String? transportMode;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Trip({
    required this.id,
    this.userId = '',
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.defaultCurrency = 'USD',
    this.budgetLimit,
    this.countryCode,
    this.transportMode,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Creates a copy with optionally modified fields
  Trip copyWith({
    String? id,
    String? userId,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? defaultCurrency,
    double? budgetLimit,
    String? countryCode,
    String? transportMode,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      countryCode: countryCode ?? this.countryCode,
      transportMode: transportMode ?? this.transportMode,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Serialization for Cloud Firestore / JSON APIs
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user_id': userId,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'defaultCurrency': defaultCurrency,
      'budgetLimit': budgetLimit,
      'countryCode': countryCode,
      'transportMode': transportMode,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'is_deleted': isDeleted,
    };
  }

  /// Deserialization from Cloud Firestore / JSON APIs
  factory Trip.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return Trip(
      id: json['id'] as String,
      userId: (json['user_id'] ?? json['userId'] ?? '') as String,
      title: json['title'] as String,
      destination: json['destination'] as String,
      startDate: parseDate(json['startDate'] ?? json['start_date']),
      endDate: parseDate(json['endDate'] ?? json['end_date']),
      defaultCurrency: json['defaultCurrency'] as String? ?? 'USD',
      budgetLimit: (json['budgetLimit'] as num?)?.toDouble(),
      countryCode: json['countryCode'] as String?,
      transportMode: json['transportMode'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? parseDate(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? parseDate(json['updatedAt'] ?? json['updated_at'])
          : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? json['is_deleted'] == true || json['is_deleted'] == 1,
    );
  }

  /// Serialization for local SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'default_currency': defaultCurrency,
      'budget_limit': budgetLimit,
      'country_code': countryCode,
      'transport_mode': transportMode,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Deserialization from local SQLite database
  factory Trip.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return Trip(
      id: (map['id'] ?? '') as String,
      userId: (map['user_id'] ?? map['userId'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      destination: (map['destination'] ?? '') as String,
      startDate: parseDate(map['start_date'] ?? map['startDate']),
      endDate: parseDate(map['end_date'] ?? map['endDate']),
      defaultCurrency: (map['default_currency'] ?? map['defaultCurrency'] ?? 'USD') as String,
      budgetLimit: ((map['budget_limit'] ?? map['budgetLimit']) as num?)?.toDouble(),
      countryCode: (map['country_code'] ?? map['countryCode']) as String?,
      transportMode: (map['transport_mode'] ?? map['transportMode']) as String?,
      notes: map['notes'] as String?,
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedAt']),
      isDeleted: map['is_deleted'] == 1 || map['isDeleted'] == 1 || map['isDeleted'] == true,
    );
  }
}
