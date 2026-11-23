import '../../../core/services/currency_service.dart';

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
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final String? createdByName;

  /// Member who paid (v16). NULL on legacy rows → falls back to [createdByName].
  final String? paidByName;

  /// Rate frozen at entry time: 1 [currency] = [exchangeRateToTrip] [tripCurrencySnapshot] (v16).
  /// NULL on legacy rows → conversions keep using the live rate.
  final double? exchangeRateToTrip;
  final String? tripCurrencySnapshot;

  const Expense({
    required this.id,
    this.userId = '',
    required this.tripId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.createdByName,
    this.paidByName,
    this.exchangeRateToTrip,
    this.tripCurrencySnapshot,
  });

  /// Payer shown in the UI: explicit payer, else the creator, else empty.
  String get effectivePayer {
    final payer = paidByName?.trim() ?? '';
    if (payer.isNotEmpty) return payer;
    return createdByName?.trim() ?? '';
  }

  /// True when this expense carries a usable rate frozen at entry time.
  bool get hasLockedRate => _validRate(exchangeRateToTrip) != null && (tripCurrencySnapshot?.trim().isNotEmpty ?? false);

  /// Amount expressed in [target]. Uses the rate frozen at entry; only the leg from the trip
  /// currency snapshot to a different [target] (and legacy NULL-rate rows) use live rates.
  double amountIn(String target) {
    if (currency.toUpperCase().trim() == target.toUpperCase().trim()) return amount;
    if (hasLockedRate) {
      return CurrencyService.convert(
        amount: amount * exchangeRateToTrip!,
        fromCurrency: tripCurrencySnapshot!,
        toCurrency: target,
      );
    }
    return CurrencyService.convert(amount: amount, fromCurrency: currency, toCurrency: target);
  }

  /// Current rate for 1 [currency] in [tripCurrency], or null when it is not trustworthy
  /// (unknown currency, non-positive or non-finite), so the expense stays on live rates.
  static double? rateAtEntry(String currency, String tripCurrency) {
    final from = currency.toUpperCase().trim();
    final to = tripCurrency.toUpperCase().trim();
    if (from.isEmpty || to.isEmpty) return null;
    if (from == to) return 1.0;
    final rates = CurrencyService.ratesAgainstUsd;
    if ((rates[from] ?? 0) <= 0 || (rates[to] ?? 0) <= 0) return null;
    return _validRate(CurrencyService.convert(amount: 1.0, fromCurrency: from, toCurrency: to));
  }

  static double? _validRate(dynamic value) =>
      (value is num && value > 0 && value.isFinite) ? value.toDouble() : null;

  static String? _str(dynamic value) => value is String ? value : null;

  /// Creates a copy with optionally modified fields.
  /// [clearExchangeRate] drops the frozen rate (e.g. currency changed and no new rate is available).
  Expense copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? title,
    double? amount,
    String? currency,
    String? category,
    DateTime? date,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    String? createdByName,
    String? paidByName,
    double? exchangeRateToTrip,
    String? tripCurrencySnapshot,
    bool clearExchangeRate = false,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      createdByName: createdByName ?? this.createdByName,
      paidByName: paidByName ?? this.paidByName,
      exchangeRateToTrip: clearExchangeRate ? null : (exchangeRateToTrip ?? this.exchangeRateToTrip),
      tripCurrencySnapshot: clearExchangeRate ? null : (tripCurrencySnapshot ?? this.tripCurrencySnapshot),
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
      'paymentMethod': paymentMethod,
      'payment_method': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'is_deleted': isDeleted ? 1 : 0,
      'createdByName': createdByName,
      'created_by_name': createdByName,
      'paidByName': paidByName,
      'paid_by_name': paidByName,
      'exchangeRateToTrip': exchangeRateToTrip,
      'exchange_rate_to_trip': exchangeRateToTrip,
      'tripCurrencySnapshot': tripCurrencySnapshot,
      'trip_currency_snapshot': tripCurrencySnapshot,
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
      id: (json['id'] ?? '') as String,
      userId: (json['user_id'] ?? json['userId'] ?? '') as String,
      tripId: (json['tripId'] ?? json['trip_id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      amount: ((json['amount'] as num?) ?? 0.0).toDouble(),
      currency: (json['currency'] as String?) ?? 'USD',
      category: json['category'] as String? ?? 'General',
      date: parseDate(json['date']),
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? parseDate(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? parseDate(json['updatedAt'] ?? json['updated_at'])
          : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? json['is_deleted'] == true || json['is_deleted'] == 1,
      createdByName: (json['createdByName'] ?? json['created_by_name']) as String?,
      paidByName: _str(json['paidByName'] ?? json['paid_by_name']),
      exchangeRateToTrip: _validRate(json['exchangeRateToTrip'] ?? json['exchange_rate_to_trip']),
      tripCurrencySnapshot: _str(json['tripCurrencySnapshot'] ?? json['trip_currency_snapshot']),
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
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
      'created_by_name': createdByName,
      'paid_by_name': paidByName,
      'exchange_rate_to_trip': exchangeRateToTrip,
      'trip_currency_snapshot': tripCurrencySnapshot,
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
      paymentMethod: (map['payment_method'] ?? map['paymentMethod']) as String?,
      notes: map['notes'] as String?,
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedAt']),
      isDeleted: map['is_deleted'] == 1 || map['isDeleted'] == 1 || map['isDeleted'] == true,
      createdByName: (map['created_by_name'] ?? map['createdByName']) as String?,
      paidByName: _str(map['paid_by_name'] ?? map['paidByName']),
      exchangeRateToTrip: _validRate(map['exchange_rate_to_trip'] ?? map['exchangeRateToTrip']),
      tripCurrencySnapshot: _str(map['trip_currency_snapshot'] ?? map['tripCurrencySnapshot']),
    );
  }
}
