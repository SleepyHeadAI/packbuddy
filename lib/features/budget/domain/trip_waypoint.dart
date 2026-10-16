import 'dart:convert';

/// Waypoint / stop along a travel route (Feature F-2)
class TripWaypoint {
  final String id;
  final String tripId;
  final String name;
  final String category; // 'airport', 'hotel', 'attraction', 'restaurant', 'station', 'other'
  final String? address;
  final double? latitude;
  final double? longitude;
  final int orderIndex;
  final String? notes;

  const TripWaypoint({
    required this.id,
    required this.tripId,
    required this.name,
    this.category = 'attraction',
    this.address,
    this.latitude,
    this.longitude,
    this.orderIndex = 0,
    this.notes,
  });

  TripWaypoint copyWith({
    String? id,
    String? tripId,
    String? name,
    String? category,
    String? address,
    double? latitude,
    double? longitude,
    int? orderIndex,
    String? notes,
  }) {
    return TripWaypoint(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      orderIndex: orderIndex ?? this.orderIndex,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'name': name,
        'category': category,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'orderIndex': orderIndex,
        'notes': notes,
      };

  factory TripWaypoint.fromJson(Map<String, dynamic> json) => TripWaypoint(
        id: json['id'] as String,
        tripId: json['tripId'] as String,
        name: json['name'] as String,
        category: (json['category'] as String?) ?? 'attraction',
        address: json['address'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        orderIndex: ((json['orderIndex'] as num?) ?? 0).toInt(),
        notes: json['notes'] as String?,
      );

  static String encodeList(List<TripWaypoint> waypoints) =>
      jsonEncode(waypoints.map((w) => w.toJson()).toList());

  static List<TripWaypoint> decodeList(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson) as List;
      return decoded.map((e) => TripWaypoint.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }
}
