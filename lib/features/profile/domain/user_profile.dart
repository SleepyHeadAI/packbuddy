import 'dart:convert';

/// Domain entity representing a user's personal travel profile
class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? bio;
  final String? homeCountryCode;
  final String? homeCity;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isPro;
  final String? username;
  final String? travelStatus;
  final List<String> travelStyles;

  const UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.bio,
    this.homeCountryCode,
    this.homeCity,
    required this.createdAt,
    this.lastActiveAt,
    this.isPro = false,
    this.username,
    this.travelStatus,
    this.travelStyles = const [],
  });

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    bool clearPhoto = false,
    String? bio,
    String? homeCountryCode,
    String? homeCity,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isPro,
    String? username,
    bool clearUsername = false,
    String? travelStatus,
    bool clearTravelStatus = false,
    List<String>? travelStyles,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      bio: bio ?? this.bio,
      homeCountryCode: homeCountryCode ?? this.homeCountryCode,
      homeCity: homeCity ?? this.homeCity,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isPro: isPro ?? this.isPro,
      username: clearUsername ? null : (username ?? this.username),
      travelStatus: clearTravelStatus ? null : (travelStatus ?? this.travelStatus),
      travelStyles: travelStyles ?? this.travelStyles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'homeCountryCode': homeCountryCode,
      'homeCity': homeCity,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isPro': isPro,
      'username': username,
      'travelStatus': travelStatus,
      'travelStyles': travelStyles,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, {String? fallbackUid}) {
    DateTime parseDate(dynamic val) {
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    final isPremium = map['isPremium'] == true ||
        map['is_premium'] == true ||
        map['isPro'] == true ||
        map['pro'] == true;

    final stylesRaw = map['travelStyles'] ?? map['travelStyle'];
    final List<String> parsedStyles = stylesRaw is List
        ? stylesRaw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : const [];

    return UserProfile(
      uid: (map['uid'] ?? map['id'] ?? fallbackUid ?? '').toString(),
      displayName: (map['displayName'] ?? map['name']) as String?,
      email: map['email'] as String?,
      photoUrl: (map['photoUrl'] ?? map['photoURL']) as String?,
      bio: map['bio'] as String?,
      homeCountryCode: (map['homeCountryCode'] ?? map['countryCode']) as String?,
      homeCity: (map['homeCity'] ?? map['city']) as String?,
      createdAt: map['createdAt'] != null ? parseDate(map['createdAt']) : DateTime.now(),
      lastActiveAt: map['lastActiveAt'] != null ? parseDate(map['lastActiveAt']) : null,
      isPro: isPremium,
      username: (map['username'] ?? map['userName'] ?? map['buddyId']) as String?,
      travelStatus: (map['travelStatus'] ?? map['status']) as String?,
      travelStyles: parsedStyles,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserProfile.fromJson(String source, {String? fallbackUid}) =>
      UserProfile.fromMap(jsonDecode(source) as Map<String, dynamic>, fallbackUid: fallbackUid);
}

