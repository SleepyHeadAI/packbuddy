import 'package:flutter/material.dart';

enum SearchResultType {
  trip,
  packingItem,
  document,
  expense,
}

/// Unified domain entity representing a search result from any app domain
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchResultType type;
  final String? tripId;
  final String? category;
  final double? amount;
  final String? currency;
  final String? date;
  final DateTime? updatedAt;
  final bool isPacked;
  final int quantity;
  final String? localImagePath;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.tripId,
    this.category,
    this.amount,
    this.currency,
    this.date,
    this.updatedAt,
    this.isPacked = false,
    this.quantity = 1,
    this.localImagePath,
  });

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    final searchTypeStr = map['search_type'] as String? ?? 'trip';
    final updatedAtMs = (map['updated_at'] as num?)?.toInt();
    final updated = updatedAtMs != null ? DateTime.fromMillisecondsSinceEpoch(updatedAtMs) : null;

    switch (searchTypeStr) {
      case 'packingItem':
        final qty = (map['quantity'] as num?)?.toInt() ?? 1;
        final isPacked = (map['is_packed'] as num?)?.toInt() == 1;
        final cat = map['category'] as String? ?? '';
        return SearchResult(
          id: map['id'] as String? ?? '',
          title: map['title'] as String? ?? map['name'] as String? ?? '',
          subtitle: '$cat • $qty adet ${isPacked ? "✓ Hazır" : "○ Bekliyor"}',
          type: SearchResultType.packingItem,
          tripId: map['trip_id'] as String?,
          category: cat,
          isPacked: isPacked,
          quantity: qty,
          updatedAt: updated,
        );

      case 'document':
        final cat = map['category'] as String? ?? '';
        final fileType = map['file_type'] as String? ?? '';
        return SearchResult(
          id: map['id'] as String? ?? '',
          title: map['title'] as String? ?? '',
          subtitle: cat.isNotEmpty ? (fileType.isNotEmpty ? '$cat • $fileType' : cat) : fileType,
          type: SearchResultType.document,
          tripId: map['trip_id'] as String?,
          category: cat,
          localImagePath: map['local_image_path'] as String?,
          updatedAt: updated,
        );

      case 'expense':
        final amt = (map['amount'] as num?)?.toDouble() ?? 0.0;
        final curr = map['currency'] as String? ?? 'USD';
        final cat = map['category'] as String? ?? '';
        final date = map['date'] as String? ?? '';
        return SearchResult(
          id: map['id'] as String? ?? '',
          title: map['title'] as String? ?? '',
          subtitle: '$cat • ${amt.toStringAsFixed(2)} $curr ${date.isNotEmpty ? "• $date" : ""}',
          type: SearchResultType.expense,
          tripId: map['trip_id'] as String?,
          category: cat,
          amount: amt,
          currency: curr,
          date: date,
          updatedAt: updated,
        );

      case 'trip':
      default:
        final dest = map['destination'] as String? ?? '';
        final startDate = map['start_date'] as String? ?? '';
        final endDate = map['end_date'] as String? ?? '';
        String dateSpan = '';
        if (startDate.isNotEmpty) {
          dateSpan = endDate.isNotEmpty ? '$startDate - $endDate' : startDate;
        }
        return SearchResult(
          id: map['id'] as String? ?? '',
          title: map['title'] as String? ?? '',
          subtitle: dest.isNotEmpty ? (dateSpan.isNotEmpty ? '$dest • $dateSpan' : dest) : dateSpan,
          type: SearchResultType.trip,
          tripId: map['id'] as String?,
          date: startDate,
          updatedAt: updated,
        );
    }
  }

  IconData get icon {
    switch (type) {
      case SearchResultType.trip:
        return Icons.flight_takeoff_rounded;
      case SearchResultType.packingItem:
        return isPacked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded;
      case SearchResultType.document:
        return Icons.description_rounded;
      case SearchResultType.expense:
        return Icons.receipt_long_rounded;
    }
  }

  Color get color {
    switch (type) {
      case SearchResultType.trip:
        return const Color(0xFF0284C7);
      case SearchResultType.packingItem:
        return isPacked ? const Color(0xFF10B981) : const Color(0xFF8B5CF6);
      case SearchResultType.document:
        return const Color(0xFFF59E0B);
      case SearchResultType.expense:
        return const Color(0xFFEF4444);
    }
  }
}

