/// Domain entity representing a travel Expense with soft-delete and two-way sync support
class Expense {
  final String id;
  final String userId;
  final String tripId;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final String? receiptPath;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Expense({
    required this.id,
    this.userId = '',
    required this.tripId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.receiptPath,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Creates a copy with optionally modified fields
  Expense copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? title,
    double? amount,
    String? currency,
    String? category,
    DateTime? date,
    String? receiptPath,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptPath: receiptPath ?? this.receiptPath,
      paymentMethod: paymentMethod ?? this.paymentMethod,
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
      'tripId': tripId,
      'trip_id': tripId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date.toIso8601String(),
      'receiptPath': receiptPath,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'is_deleted': isDeleted,
    };
  }

  /// Deserialization from Cloud Firestore / JSON APIs
  factory Expense.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    return Expense(
      id: json['id'] as String,
      userId: (json['user_id'] ?? json['userId'] ?? '') as String,
      tripId: (json['tripId'] ?? json['trip_id'] ?? '') as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      category: json['category'] as String? ?? 'General',
      date: parseDate(json['date']),
      receiptPath: json['receiptPath'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
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
      'trip_id': tripId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date.toIso8601String(),
      'receipt_path': receiptPath,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Deserialization from local SQLite database
  factory Expense.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.parse(val);
      return DateTime.now();
    }

    return Expense(
      id: (map['id'] ?? '') as String,
      userId: (map['user_id'] ?? map['userId'] ?? '') as String,
      tripId: (map['trip_id'] ?? map['tripId'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      amount: ((map['amount'] as num?) ?? 0).toDouble(),
      currency: (map['currency'] as String?) ?? 'USD',
      category: (map['category'] as String?) ?? 'General',
      date: parseDate(map['date']),
      receiptPath: (map['receipt_path'] ?? map['receiptPath']) as String?,
      paymentMethod: (map['payment_method'] ?? map['paymentMethod']) as String?,
      notes: map['notes'] as String?,
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedAt']),
      isDeleted: map['is_deleted'] == 1 || map['isDeleted'] == 1 || map['isDeleted'] == true,
    );
  }
}
