import 'dart:convert';

/// Status of a friendship connection between two users
enum FriendshipStatus {
  pending,
  accepted,
  declined,
  blocked;

  static FriendshipStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'accepted':
        return FriendshipStatus.accepted;
      case 'declined':
        return FriendshipStatus.declined;
      case 'blocked':
        return FriendshipStatus.blocked;
      case 'pending':
      default:
        return FriendshipStatus.pending;
    }
  }

  String toDbString() => name;
}

/// Domain model representing a friendship relationship in Firestore
class Friendship {
  final String id;
  final List<String> users;
  final String requesterId;
  final String receiverId;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Friendship({
    required this.id,
    required this.users,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Canonical composite ID sorted alphabetically: minUid_maxUid
  static String generateId(String uidA, String uidB) {
    if (uidA.compareTo(uidB) <= 0) {
      return '${uidA}_$uidB';
    }
    return '${uidB}_$uidA';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'users': users,
      'requesterId': requesterId,
      'receiverId': receiverId,
      'status': status.toDbString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Friendship.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    final id = docId ?? (map['id'] as String? ?? '');
    final usersRaw = map['users'];
    final List<String> usersList = usersRaw is List
        ? usersRaw.map((e) => e.toString()).toList()
        : const [];

    return Friendship(
      id: id,
      users: usersList,
      requesterId: (map['requesterId'] as String?) ?? '',
      receiverId: (map['receiverId'] as String?) ?? '',
      status: FriendshipStatus.fromString(map['status'] as String?),
      createdAt: map['createdAt'] != null ? parseDate(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : DateTime.now(),
    );
  }
}

/// Lightweight profile summary of a travel buddy for fast listing and caching
class FriendUserSummary {
  final String uid;
  final String? displayName;
  final String? username;
  final String? photoUrl;
  final String? travelStatus;
  final String? homeCountryCode;
  final String? homeCity;
  final DateTime? lastActiveAt;
  final bool isPro;
  final List<String> travelStyles;
  final Map<String, dynamic>? travelMapCountries;
  final String? bio;

  const FriendUserSummary({
    required this.uid,
    this.displayName,
    this.username,
    this.photoUrl,
    this.travelStatus,
    this.homeCountryCode,
    this.homeCity,
    this.lastActiveAt,
    this.isPro = false,
    this.travelStyles = const [],
    this.travelMapCountries,
    this.bio,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'travelStatus': travelStatus,
      'homeCountryCode': homeCountryCode,
      'homeCity': homeCity,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isPro': isPro,
      'travelStyles': travelStyles,
      'travelMapCountries': travelMapCountries,
      'bio': bio,
    };
  }

  factory FriendUserSummary.fromMap(Map<String, dynamic> map, {String? fallbackUid}) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final isPremium = map['isPro'] == true ||
        map['isPremium'] == true ||
        map['pro'] == true;

    final stylesRaw = map['travelStyles'] ?? map['travelStyle'];
    final List<String> parsedStyles = stylesRaw is List
        ? stylesRaw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : const [];

    final rawCountries = map['travelMapCountries'] ?? map['countries'] ?? map['travelMap'];
    final Map<String, dynamic>? parsedCountries = rawCountries is Map
        ? Map<String, dynamic>.from(rawCountries)
        : null;

    return FriendUserSummary(
      uid: (map['uid'] ?? map['id'] ?? fallbackUid ?? '').toString(),
      displayName: (map['displayName'] ?? map['name']) as String?,
      username: (map['username'] ?? map['userName'] ?? map['buddyId']) as String?,
      photoUrl: (map['photoUrl'] ?? map['photoURL']) as String?,
      travelStatus: (map['travelStatus'] ?? map['status']) as String?,
      homeCountryCode: (map['homeCountryCode'] ?? map['countryCode']) as String?,
      homeCity: (map['homeCity'] ?? map['city']) as String?,
      lastActiveAt: parseDate(map['lastActiveAt']),
      isPro: isPremium,
      travelStyles: parsedStyles,
      travelMapCountries: parsedCountries,
      bio: (map['bio'] ?? map['about']) as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FriendUserSummary.fromJson(String source) =>
      FriendUserSummary.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

/// Represents an incoming or outgoing pending friendship request
class FriendRequestItem {
  final String friendshipId;
  final FriendUserSummary user;
  final bool isIncoming;
  final DateTime createdAt;

  const FriendRequestItem({
    required this.friendshipId,
    required this.user,
    required this.isIncoming,
    required this.createdAt,
  });
}

