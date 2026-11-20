import 'dart:convert';
import 'country.dart';

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
    bool clearCountryCode = false,
    String? transportMode,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isShared,
    String? inviteCode,
    List<String>? collaborators,
    String? sharedRole,
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
      countryCode: clearCountryCode ? null : (countryCode ?? this.countryCode),
      transportMode: transportMode ?? this.transportMode,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isShared: isShared ?? this.isShared,
      inviteCode: inviteCode ?? this.inviteCode,
      collaborators: collaborators ?? this.collaborators,
      sharedRole: sharedRole ?? this.sharedRole,
    );
  }

  /// Whether this trip is currently collaborative (actively shared with other travelers)
  bool get isCollaborative => isShared || collaborators.isNotEmpty;

  /// Extracts all active unique countries belonging to this trip in route order.
  /// Seamlessly parses destinations in all 20 languages and extracts flags.
  /// If a country was removed from the itinerary, it will NOT be included here.
  List<Country> get countries {
    final list = <Country>[];
    final seenCodes = <String>{};

    if (destination.trim().isNotEmpty) {
      final stops = destination.split(RegExp(r'\s*(?:➔|\s-\s)\s*'));
      for (final stop in stops) {
        final c = Country.resolveFromStop(stop);
        if (c != null && !seenCodes.contains(c.code.toUpperCase())) {
          seenCodes.add(c.code.toUpperCase());
          list.add(c);
        }
      }
    }

    // Fallback: ONLY if destination is completely empty and countryCode is set
    // (for legacy trips that didn't have destination text)
    if (list.isEmpty && destination.trim().isEmpty && countryCode != null && countryCode!.trim().isNotEmpty) {
      final c = Country.findByCode(countryCode);
      if (c != null) {
        list.add(c);
      }
    }

    return list;
  }

  /// Extracts all unique country flags for the trip (e.g. ['🇹🇷', '🇩🇪']).
  List<String> get countryFlags {
    return countries.map((c) => c.flag).toList();
  }

  /// Primary country object for the trip (first stop's country or countryCode).
  Country? get primaryCountry {
    final cList = countries;
    if (cList.isNotEmpty) return cList.first;
    if (destination.trim().isEmpty && countryCode != null) {
      return Country.findByCode(countryCode);
    }
    return null;
  }

  /// Primary country code for the trip.
  String? get primaryCountryCode {
    return primaryCountry?.code ?? (destination.trim().isEmpty ? countryCode : null);
  }

  /// Helper to encode collaboration metadata into SQLite notes column safely
  static String? _encodeNotes(
    String? cleanNotes,
    bool isShared,
    String? inviteCode,
    List<String> collaborators,
    String sharedRole,
  ) {
    if (!isShared && inviteCode == null && collaborators.isEmpty) {
      return cleanNotes;
    }
    final meta = <String, dynamic>{
      'isShared': isShared,
      'inviteCode': inviteCode,
      'collaborators': collaborators,
      'sharedRole': sharedRole,
    };
    final metaStr = '<!--PB_COLLAB:${jsonEncode(meta)}-->';
    if (cleanNotes == null || cleanNotes.isEmpty) {
      return metaStr;
    }
    return '$cleanNotes\n$metaStr';
  }

  /// Helper to decode collaboration metadata from SQLite notes column safely
  static (
    String? cleanNotes,
    bool isShared,
    String? inviteCode,
    List<String> collaborators,
    String sharedRole,
  ) _decodeNotes(String? rawNotes) {
    if (rawNotes == null || !rawNotes.contains('<!--PB_COLLAB:')) {
      return (rawNotes, false, null, const <String>[], 'owner');
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

        return (clean.isEmpty ? null : clean, isShared, inviteCode, collaborators, role);
      }
    } catch (_) {}

    return (rawNotes, false, null, const <String>[], 'owner');
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
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'is_deleted': isDeleted ? 1 : 0,
      'isShared': isShared,
      'is_shared': isShared ? 1 : 0,
      'inviteCode': inviteCode,
      'invite_code': inviteCode,
      'collaborators': collaborators,
      'sharedRole': sharedRole,
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
    final (cleanNotes, decodedShared, decodedCode, decodedCollabs, decodedRole) =
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

    return Trip(
      id: (json['id'] ?? '') as String,
      userId: (json['user_id'] ?? json['userId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      destination: (json['destination'] ?? '') as String,
      startDate: parseDate(json['startDate'] ?? json['start_date']),
      endDate: parseDate(json['endDate'] ?? json['end_date']),
      defaultCurrency: (json['defaultCurrency'] ?? json['default_currency'] ?? 'USD') as String,
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
    );
  }

  /// Serialization for local SQLite database
  Map<String, dynamic> toMap() {
    final encodedNotes = _encodeNotes(notes, isShared, inviteCode, collaborators, sharedRole);
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
    final (cleanNotes, isShared, inviteCode, collaborators, sharedRole) =
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
    );
  }
}

/// Operational state of a trip relative to the current local calendar date
enum TripStatus {
  ongoing,
  upcoming,
  past,
}

/// Extension providing clear temporal status and day counts for Trips
extension TripStatusX on Trip {
  TripStatus get status {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if ((today.isAfter(start) || today.isAtSameMomentAs(start)) &&
        (today.isBefore(end) || today.isAtSameMomentAs(end))) {
      return TripStatus.ongoing;
    } else if (start.isAfter(today)) {
      return TripStatus.upcoming;
    } else {
      return TripStatus.past;
    }
  }

  bool get isOngoing => status == TripStatus.ongoing;
  bool get isUpcoming => status == TripStatus.upcoming;
  bool get isPast => status == TripStatus.past;

  int get daysUntilStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return start.difference(today).inDays;
  }

  int get totalDays {
    final diff = endDate.difference(startDate).inDays;
    return diff <= 0 ? 1 : diff + 1;
  }
}

