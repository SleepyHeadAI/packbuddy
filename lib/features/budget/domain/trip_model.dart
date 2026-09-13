/// Domain model representing a travel trip with budget tracking
class TripModel {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String defaultCurrency;
  final double? budgetLimit;
  final bool isDeleted;
  final String syncStatus;
  final DateTime updatedAt;

  const TripModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.defaultCurrency = 'USD',
    this.budgetLimit,
    this.isDeleted = false,
    this.syncStatus = 'synced',
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'default_currency': defaultCurrency,
      'budget_limit': budgetLimit,
      'is_deleted': isDeleted ? 1 : 0,
      'sync_status': syncStatus,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] as String,
      title: map['title'] as String,
      destination: map['destination'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      defaultCurrency: map['default_currency'] as String? ?? 'USD',
      budgetLimit: (map['budget_limit'] as num?)?.toDouble(),
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
