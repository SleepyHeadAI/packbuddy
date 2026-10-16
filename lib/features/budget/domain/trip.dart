import 'dart:convert';
import 'trip_waypoint.dart';

/// Domain entity representing a travel Trip with soft-delete, two-way sync,
/// and collaborative shared travel list support (Feature F-1).
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

  // Collaborative Shared Travel List fields (F-1)
  final bool isShared;
  final String? inviteCode;
  final List<String> collaborators;
  final String sharedRole; // 'owner', 'editor', 'viewer'

  // Travel Map & Waypoints Route (Feature F-2)
  final List<TripWaypoint> waypoints;

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
    this.isShared = false,
    this.inviteCode,
    this.collaborators = const [],
    this.sharedRole = 'owner',
    this.waypoints = const [],
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
    bool? isShared,
    String? inviteCode,
    List<String>? collaborators,
    String? sharedRole,
    List<TripWaypoint>? waypoints,
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
      isShared: isShared ?? this.isShared,
      inviteCode: inviteCode ?? this.inviteCode,
      collaborators: collaborators ?? this.collaborators,
      sharedRole: sharedRole ?? this.sharedRole,
      waypoints: waypoints ?? this.waypoints,
    );
  }

  /// Helper to encode collaboration and waypoint metadata into SQLite notes column safely
  static String? _encodeNotes(
    String? cleanNotes,
    bool isShared,
    String? inviteCode,
    List<String> collaborators,
    String sharedRole, [
    List<TripWaypoint> waypoints = const [],
  ]) {
    if (!isShared && inviteCode == null && collaborators.isEmpty && waypoints.isEmpty) {
      return cleanNotes;
    }
    final meta = <String, dynamic>{
      'isShared': isShared,
      'inviteCode': inviteCode,
      'collaborators': collaborators,
      'sharedRole': sharedRole,
    };
    if (waypoints.isNotEmpty) {
      meta['waypoints'] = TripWaypoint.encodeList(waypoints);
    }
    final metaStr = '<!--PB_COLLAB:${jsonEncode(meta)}-->';
    if (cleanNotes == null || cleanNotes.isEmpty) {
      return metaStr;
    }
    return '$cleanNotes\n$metaStr';
  }

  /// Helper to decode collaboration and waypoint metadata from SQLite notes column safely
  static (
    String? cleanNotes,
    bool isShared,
    String? inviteCode,
    List<String> collaborators,
    String sharedRole,
    List<TripWaypoint> waypoints,
  ) _decodeNotes(String? rawNotes) {
    if (rawNotes == null || !rawNotes.contains('<!--PB_COLLAB:')) {
      return (rawNotes, false, null, const <String>[], 'owner', const <TripWaypoint>[]);
    }

    try {
      final startIndex = rawNotes.indexOf('<!--PB_COLLAB:') + '<!--PB_COLLAB:'.length;
      final endIndex = rawNotes.indexOf('-->', startIndex);
      if (endIndex > startIndex) {
        final jsonStr = rawNotes.substring(startIndex, endIndex);
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

        final clean = rawNotes
            .substring(0, rawNotes.indexOf('<!--PB_COLLAB:'))
            .trim();

        final isShared = decoded['isShared'] == true;
        final inviteCode = decoded['inviteCode'] as String?;
        final rawCollabs = decoded['collaborators'];
        final collaborators = (rawCollabs is List)
            ? rawCollabs.map((e) => e.toString()).toList()
            : const <String>[];
        final role = decoded['sharedRole'] as String? ?? 'owner';
        final rawWaypoints = decoded['waypoints'] as String?;
        final waypoints = rawWaypoints != null && rawWaypoints.isNotEmpty
            ? TripWaypoint.decodeList(rawWaypoints)
            : const <TripWaypoint>[];

        return (clean.isEmpty ? null : clean, isShared, inviteCode, collaborators, role, waypoints);
      }
    } catch (_) {}

    return (rawNotes, false, null, const <String>[], 'owner', const <TripWaypoint>[]);
  }

  /// Serialization for Cloud Firestore / JSON APIs
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
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
      'isDeleted': isDeleted,
      'isShared': isShared,
      'inviteCode': inviteCode,
      'collaborators': collaborators,
      'sharedRole': sharedRole,
      'waypoints': TripWaypoint.encodeList(waypoints),
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

    final rawNotes = json['notes'] as String?;
    final (cleanNotes, decodedShared, decodedCode, decodedCollabs, decodedRole, decodedWaypoints) =
        _decodeNotes(rawNotes);

    final isShared = json['isShared'] as bool? ??
        (json['is_shared'] == true || json['is_shared'] == 1 || decodedShared);
    final inviteCode = (json['inviteCode'] ?? json['invite_code'] ?? decodedCode) as String?;
    final rawCollab = json['collaborators'];
    final List<String> collaborators;
    if (rawCollab is List) {
      collaborators = rawCollab.map((e) => e.toString()).toList();
    } else {
      collaborators = decodedCollabs;
    }
    final sharedRole =
        (json['sharedRole'] ?? json['shared_role'] ?? decodedRole) as String? ?? 'owner';

    final rawWaypoints = json['waypoints'];
    final List<TripWaypoint> waypoints;
    if (rawWaypoints is String && rawWaypoints.isNotEmpty) {
      waypoints = TripWaypoint.decodeList(rawWaypoints);
    } else if (rawWaypoints is List) {
      waypoints = rawWaypoints
          .map((e) => TripWaypoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      waypoints = decodedWaypoints;
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
      notes: cleanNotes,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? parseDate(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? parseDate(json['updatedAt'] ?? json['updated_at'])
          : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? json['is_deleted'] == true || json['is_deleted'] == 1,
      isShared: isShared,
      inviteCode: inviteCode,
      collaborators: collaborators,
      sharedRole: sharedRole,
      waypoints: waypoints,
    );
  }

  /// Serialization for local SQLite database
  Map<String, dynamic> toMap() {
    final encodedNotes = _encodeNotes(notes, isShared, inviteCode, collaborators, sharedRole, waypoints);
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
      'notes': encodedNotes,
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

    final rawNotes = map['notes'] as String?;
    final (cleanNotes, isShared, inviteCode, collaborators, sharedRole, waypoints) =
        _decodeNotes(rawNotes);

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
      notes: cleanNotes,
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedAt']),
      isDeleted: map['is_deleted'] == 1 || map['isDeleted'] == 1 || map['isDeleted'] == true,
      isShared: isShared,
      inviteCode: inviteCode,
      collaborators: collaborators,
      sharedRole: sharedRole,
      waypoints: waypoints,
    );
  }
}
