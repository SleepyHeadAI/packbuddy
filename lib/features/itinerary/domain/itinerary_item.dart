import 'dart:convert';
import 'package:flutter/material.dart';

/// Serene Voyage Day-by-Day Activity domain entity
class ItineraryItem {
  final String id;
  final String userId;
  final String tripId;
  final int dayNumber;
  final String date;
  final String? time;
  final String title;
  final String? description;
  final String? location;
  final String category;
  final double? cost;
  final String? currency;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const ItineraryItem({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.dayNumber,
    required this.date,
    this.time,
    required this.title,
    this.description,
    this.location,
    this.category = 'sightseeing',
    this.cost,
    this.currency,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  ItineraryItem copyWith({
    String? id,
    String? userId,
    String? tripId,
    int? dayNumber,
    String? date,
    String? time,
    String? title,
    String? description,
    String? location,
    String? category,
    double? cost,
    String? currency,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      time: time ?? this.time,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'trip_id': tripId,
      'day_number': dayNumber,
      'date': date,
      'time': time,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'cost': cost,
      'currency': currency,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory ItineraryItem.fromMap(Map<String, dynamic> map) {
    return ItineraryItem(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      tripId: map['trip_id'] as String? ?? '',
      dayNumber: (map['day_number'] as num?)?.toInt() ?? 1,
      date: map['date'] as String? ?? '',
      time: map['time'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      location: map['location'] as String?,
      category: map['category'] as String? ?? 'sightseeing',
      cost: (map['cost'] as num?)?.toDouble(),
      currency: map['currency'] as String?,
      isCompleted: (map['is_completed'] as num?)?.toInt() == 1,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['created_at'] as num).toInt())
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as num).toInt())
          : DateTime.now(),
      isDeleted: (map['is_deleted'] as num?)?.toInt() == 1,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ItineraryItem.fromJson(String source) =>
      ItineraryItem.fromMap(jsonDecode(source) as Map<String, dynamic>);

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'transit':
      case 'flight':
      case 'transport':
      case 'train':
        return Icons.directions_transit_filled_rounded;
      case 'activity':
      case 'nature':
      case 'adventure':
        return Icons.hiking_rounded;
      case 'lodging':
      case 'hotel':
        return Icons.hotel_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'sightseeing':
      default:
        return Icons.attractions_rounded;
    }
  }

  Color get color {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
      case 'restaurant':
        return const Color(0xFFF59E0B);
      case 'transit':
      case 'flight':
      case 'transport':
      case 'train':
        return const Color(0xFF0284C7);
      case 'activity':
      case 'nature':
      case 'adventure':
        return const Color(0xFF10B981);
      case 'lodging':
      case 'hotel':
        return const Color(0xFF8B5CF6);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'sightseeing':
      default:
        return const Color(0xFF3B82F6);
    }
  }
}

