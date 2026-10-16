import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/domain/expense.dart';
import '../../features/checklist/domain/packing_item.dart';
import '../utils/currency_formatter.dart';

/// App Widget Payload model for iOS WidgetKit / Android AppWidgets (Feature F-9)
class AppWidgetData {
  final String? tripTitle;
  final String? destination;
  final int daysUntil;
  final int totalItems;
  final int packedItems;
  final int packingPercent;
  final String? budgetSpent;
  final String? budgetTotal;
  final DateTime updatedAt;

  const AppWidgetData({
    this.tripTitle,
    this.destination,
    this.daysUntil = 0,
    this.totalItems = 0,
    this.packedItems = 0,
    this.packingPercent = 0,
    this.budgetSpent,
    this.budgetTotal,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'tripTitle': tripTitle,
        'destination': destination,
        'daysUntil': daysUntil,
        'totalItems': totalItems,
        'packedItems': packedItems,
        'packingPercent': packingPercent,
        'budgetSpent': budgetSpent,
        'budgetTotal': budgetTotal,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory AppWidgetData.fromJson(Map<String, dynamic> json) => AppWidgetData(
        tripTitle: json['tripTitle'] as String?,
        destination: json['destination'] as String?,
        daysUntil: (json['daysUntil'] as num?)?.toInt() ?? 0,
        totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
        packedItems: (json['packedItems'] as num?)?.toInt() ?? 0,
        packingPercent: (json['packingPercent'] as num?)?.toInt() ?? 0,
        budgetSpent: json['budgetSpent'] as String?,
        budgetTotal: json['budgetTotal'] as String?,
        updatedAt: json['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
            : DateTime.now(),
      );
}

/// Service managing glanceable widget state synchronization (Feature F-9)
class AppWidgetService {
  AppWidgetService._();

  static const String keyWidgetPayload = 'packbuddy_widget_payload_data';

  /// Serializes and stores latest upcoming trip and checklist metrics for home widgets
  static Future<void> updateWidgetPayload({
    Trip? upcomingTrip,
    List<PackingItem> items = const [],
    List<Expense> expenses = const [],
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (upcomingTrip == null) {
        await prefs.remove(keyWidgetPayload);
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tripStart = DateTime(
        upcomingTrip.startDate.year,
        upcomingTrip.startDate.month,
        upcomingTrip.startDate.day,
      );
      final daysUntil = tripStart.difference(today).inDays;

      final tripItems = items.where((i) => i.tripId == upcomingTrip.id && !i.isDeleted).toList();
      final totalItems = tripItems.length;
      final packedItems = tripItems.where((i) => i.isPacked).length;
      final packingPercent = totalItems > 0 ? ((packedItems / totalItems) * 100).toInt() : 0;

      final totalSpent = expenses.where((e) => e.tripId == upcomingTrip.id && !e.isDeleted).fold<double>(
            0.0,
            (sum, e) => sum + e.amount,
          );

      final payload = AppWidgetData(
        tripTitle: upcomingTrip.title.isNotEmpty ? upcomingTrip.title : upcomingTrip.destination,
        destination: upcomingTrip.destination,
        daysUntil: daysUntil > 0 ? daysUntil : 0,
        totalItems: totalItems,
        packedItems: packedItems,
        packingPercent: packingPercent,
        budgetSpent: CurrencyFormatter.format(totalSpent, currency: upcomingTrip.defaultCurrency),
        budgetTotal: upcomingTrip.budgetLimit != null
            ? CurrencyFormatter.format(upcomingTrip.budgetLimit!, currency: upcomingTrip.defaultCurrency)
            : null,
        updatedAt: DateTime.now(),
      );

      await prefs.setString(keyWidgetPayload, jsonEncode(payload.toJson()));
    } catch (_) {}
  }

  /// Retrieves cached widget payload
  static Future<AppWidgetData?> getWidgetPayload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(keyWidgetPayload);
      if (raw != null && raw.isNotEmpty) {
        return AppWidgetData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }
}
