/// Domain entity representing a travel Expense with soft-delete and two-way sync support
class Expense {
  final String id;
  final String tripId;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final DateTime date;
  final String? receiptPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.receiptPath,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Creates a copy with optionally modified fields
  Expense copyWith({
    String? id,
    String? tripId,
    String? title,
    double? amount,
    String? currency,
    String? category,
    DateTime? date,
    String? receiptPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Serialization for Cloud Firestore / JSON APIs
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date.toIso8601String(),
      'receiptPath': receiptPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Deserialization from Cloud Firestore / JSON APIs
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      category: json['category'] as String? ?? 'General',
      date: DateTime.parse(json['date'] as String),
      receiptPath: json['receiptPath'] as String?,
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
      'trip_id': tripId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date.toIso8601String(),
      'receipt_path': receiptPath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Deserialization from local SQLite database
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      category: map['category'] as String? ?? 'General',
      date: DateTime.parse(map['date'] as String),
      receiptPath: map['receipt_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }
}
