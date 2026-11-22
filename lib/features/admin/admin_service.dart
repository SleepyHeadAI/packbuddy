import '../../core/services/telemetry_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/live_location_service.dart';
import '../../core/services/email_dispatch_service.dart';
import '../../core/l10n/app_l10n_lookup.dart';
import '../../core/services/notification_service.dart';
import '../../data/local_db/database_helper.dart';
import '../budget/domain/country.dart';
import '../budget/domain/trip.dart';
import '../budget/domain/expense.dart';
import '../vault/domain/document.dart';
import '../travel_map/data/world_countries_data.dart';
import '../travel_map/domain/travel_country.dart';
import '../budget/domain/country_localization.dart';
import '../profile/domain/friendship.dart';
import '../profile/domain/travel_style.dart';
import '../profile/domain/travel_badge.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import 'domain/broadcast_announcement.dart';
import 'domain/admin_audit_log.dart';
import '../../core/services/security_service.dart';

/// Designated Executive Super Admin Email
const String kAdminEmail = 'sleepyheadaitr@gmail.com';

/// Language for user-facing emails: the user's saved `appLanguage`
/// (or legacy aliases). Missing values fall back to English.
String _emailLanguageOf(Map<String, dynamic> data) {
  final raw = data['appLanguage'] ?? data['app_language'] ?? data['languageCode'] ?? data['language_code'];
  final code = raw is String ? raw.trim().toLowerCase() : '';
  return code.isNotEmpty ? code : 'en';
}

/// Global platform metrics for the Executive Admin Dashboard
class AdminPlatformMetrics {
  final int totalUsers;
  final int verifiedUsers;
  final int proUsers;
  final int totalTrips;
  final int totalExpenses;
  final int totalDocuments;
  final int totalChecklistItems;
  final int totalStorageBytes;
  final int totalFriendships;
  final int totalPendingFriendRequests;
  final int totalUsernamesClaimed;

  /// Users with `lastActiveAt` within the last 24 hours (count() aggregation).
  final int dailyActiveUsers;

  const AdminPlatformMetrics({
    this.totalUsers = 0,
    this.verifiedUsers = 0,
    this.proUsers = 0,
    this.totalTrips = 0,
    this.totalExpenses = 0,
    this.totalDocuments = 0,
    this.totalChecklistItems = 0,
    this.totalStorageBytes = 0,
    this.totalFriendships = 0,
    this.totalPendingFriendRequests = 0,
    this.totalUsernamesClaimed = 0,
    this.dailyActiveUsers = 0,
  });

  AdminPlatformMetrics copyWith({
    int? totalUsers,
    int? verifiedUsers,
    int? proUsers,
    int? totalTrips,
    int? totalExpenses,
    int? totalDocuments,
    int? totalChecklistItems,
    int? totalStorageBytes,
    int? totalFriendships,
    int? totalPendingFriendRequests,
    int? totalUsernamesClaimed,
    int? dailyActiveUsers,
  }) {
    return AdminPlatformMetrics(
      totalUsers: totalUsers ?? this.totalUsers,
      verifiedUsers: verifiedUsers ?? this.verifiedUsers,
      proUsers: proUsers ?? this.proUsers,
      totalTrips: totalTrips ?? this.totalTrips,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalDocuments: totalDocuments ?? this.totalDocuments,
      totalChecklistItems: totalChecklistItems ?? this.totalChecklistItems,
      totalStorageBytes: totalStorageBytes ?? this.totalStorageBytes,
      totalFriendships: totalFriendships ?? this.totalFriendships,
      totalPendingFriendRequests: totalPendingFriendRequests ?? this.totalPendingFriendRequests,
      totalUsernamesClaimed: totalUsernamesClaimed ?? this.totalUsernamesClaimed,
      dailyActiveUsers: dailyActiveUsers ?? this.dailyActiveUsers,
    );
  }
}

/// Anonymized GDPR/KVKK Compliant Record of a permanently deleted account
class DeletedAccountArchiveItem {
  final String id;
  final int tripCount;
  final int countryCount;
  final int itemCount;
  final int expenseCount;
  final bool isPro;
  final String locale;
  final int accountAgeDays;
  final DateTime? deletedAt;
  final String platform;

  const DeletedAccountArchiveItem({
    required this.id,
    this.tripCount = 0,
    this.countryCount = 0,
    this.itemCount = 0,
    this.expenseCount = 0,
    this.isPro = false,
    this.locale = 'tr',
    this.accountAgeDays = 0,
    this.deletedAt,
    this.platform = 'android',
  });

  factory DeletedAccountArchiveItem.fromMap(String id, Map<String, dynamic> data) {
    DateTime? delDate;
    final rawDel = data['deletedAt'];
    if (rawDel is Timestamp) {
      delDate = rawDel.toDate();
    } else if (rawDel is String) {
      delDate = DateTime.tryParse(rawDel);
    }
    return DeletedAccountArchiveItem(
      id: id,
      tripCount: (data['tripCount'] as num?)?.toInt() ?? 0,
      countryCount: (data['countryCount'] as num?)?.toInt() ?? 0,
      itemCount: (data['itemCount'] as num?)?.toInt() ?? 0,
      expenseCount: (data['expenseCount'] as num?)?.toInt() ?? 0,
      isPro: data['isPro'] == true,
      locale: data['locale'] as String? ?? 'tr',
      accountAgeDays: (data['accountAgeDays'] as num?)?.toInt() ?? 0,
      deletedAt: delDate,
      platform: data['platform'] as String? ?? 'android',
    );
  }
}

/// Aggregate summary of deleted accounts for executive retention analytics
class DeletedAccountsSummary {
  final int totalDeleted;
  final double avgTripsBeforeDeletion;
  final double avgItemsBeforeDeletion;
  final double avgExpensesBeforeDeletion;
  final double proUserPercentage;
  final Map<String, int> localeDistribution;
  final List<DeletedAccountArchiveItem> recentItems;

  const DeletedAccountsSummary({
    this.totalDeleted = 0,
    this.avgTripsBeforeDeletion = 0.0,
    this.avgItemsBeforeDeletion = 0.0,
    this.avgExpensesBeforeDeletion = 0.0,
    this.proUserPercentage = 0.0,
    this.localeDistribution = const {},
    this.recentItems = const [],
  });
}

/// Helper to format duration in seconds to a human-friendly string (e.g. "8 dk 45 sn", "14.2 sa")
String formatDurationSeconds(double seconds) {
  if (seconds <= 0) return '0 sn';
  if (seconds < 60) return '${seconds.round()} sn';
  if (seconds < 3600) {
    final m = (seconds / 60).floor();
    final s = (seconds % 60).round();
    return s > 0 ? '$m dk $s sn' : '$m dk';
  }
  final h = (seconds / 3600).toStringAsFixed(1);
  return '$h sa';
}

/// Detailed country demand metric (Wishlist, Visited, Lived)
class CountryTravelMetric {
  final String countryCode;
  final String countryName;
  final String flag;
  final int count;
  final double percentage; // 0.0 to 1.0
  final String continent;

  const CountryTravelMetric({
    required this.countryCode,
    required this.countryName,
    required this.flag,
    required this.count,
    required this.percentage,
    this.continent = 'Global',
  });
}

/// Continent distribution metric
class ContinentShareMetric {
  final String continentName;
  final String icon;
  final int count;
  final double percentage;

  const ContinentShareMetric({
    required this.continentName,
    required this.icon,
    required this.count,
    required this.percentage,
  });
}

/// Transport mode preference metric
class TransportPreferenceMetric {
  final String mode; // 'plane', 'train', 'car', 'bus', 'boat'
  final String label;
  final String icon;
  final int count;
  final double percentage;

  const TransportPreferenceMetric({
    required this.mode,
    required this.label,
    required this.icon,
    required this.count,
    required this.percentage,
  });
}

/// Currency popularity metric
class CurrencyShareMetric {
  final String currencyCode;
  final int count;
  final double percentage;

  const CurrencyShareMetric({
    required this.currencyCode,
    required this.count,
    required this.percentage,
  });
}

/// Vault document category metric
class VaultCategoryShareMetric {
  final String category;
  final String label;
  final int count;
  final double percentage;

  const VaultCategoryShareMetric({
    required this.category,
    required this.label,
    required this.count,
    required this.percentage,
  });
}

/// Preference share metric (Theme, Language, etc.)
class PreferenceShareMetric {
  final String key;
  final String label;
  final String icon;
  final int count;
  final double percentage; // 0.0 to 1.0

  const PreferenceShareMetric({
    required this.key,
    required this.label,
    required this.icon,
    required this.count,
    required this.percentage,
  });
}

/// Comprehensive Platform Analytics & Travel Intelligence
class AdminDetailedAnalytics {
  final List<CountryTravelMetric> topWishlistCountries;
  final List<CountryTravelMetric> topVisitedCountries;
  final List<CountryTravelMetric> topLivedCountries;
  final List<ContinentShareMetric> continentShares;
  final List<CountryTravelMetric> topTripDestinations;
  final int upcomingTripsCount;
  final int completedTripsCount;
  final int totalWorldMapMarks;
  final List<TransportPreferenceMetric> transportPreferences;
  final List<CurrencyShareMetric> currencyShares;
  final List<VaultCategoryShareMetric> vaultCategories;
  final List<PreferenceShareMetric> themeShares;
  final List<PreferenceShareMetric> languageShares;
  final int totalPlatformSessionSeconds;
  final int totalPlatformSessions;
  final double averageSessionDurationSeconds;
  final double averageTripDurationDays;
  final double averageExpensePerTrip;
  final double proConversionRate;
  final double emailVerificationRate;
  final int totalFriendships;
  final int totalPendingFriendRequests;
  final double averageFriendsPerUser;
  final int usersWithFriendsCount;
  final double usernameClaimRate;
  final double bioAdoptionRate;
  final double travelStatusAdoptionRate;
  final double travelStylesAdoptionRate;
  final List<PreferenceShareMetric> travelStyleShares;
  final List<PreferenceShareMetric> badgeTierShares;
  final int totalBadgesUnlocked;

  const AdminDetailedAnalytics({
    this.topWishlistCountries = const [],
    this.topVisitedCountries = const [],
    this.topLivedCountries = const [],
    this.continentShares = const [],
    this.topTripDestinations = const [],
    this.upcomingTripsCount = 0,
    this.completedTripsCount = 0,
    this.totalWorldMapMarks = 0,
    this.transportPreferences = const [],
    this.currencyShares = const [],
    this.vaultCategories = const [],
    this.themeShares = const [],
    this.languageShares = const [],
    this.totalPlatformSessionSeconds = 0,
    this.totalPlatformSessions = 0,
    this.averageSessionDurationSeconds = 0.0,
    this.averageTripDurationDays = 0.0,
    this.averageExpensePerTrip = 0.0,
    this.proConversionRate = 0.0,
    this.emailVerificationRate = 0.0,
    this.totalFriendships = 0,
    this.totalPendingFriendRequests = 0,
    this.averageFriendsPerUser = 0.0,
    this.usersWithFriendsCount = 0,
    this.usernameClaimRate = 0.0,
    this.bioAdoptionRate = 0.0,
    this.travelStatusAdoptionRate = 0.0,
    this.travelStylesAdoptionRate = 0.0,
    this.travelStyleShares = const [],
    this.badgeTierShares = const [],
    this.totalBadgesUnlocked = 0,
  });

  String get formattedAverageSessionDuration =>
      formatDurationSeconds(averageSessionDurationSeconds);

  String get formattedTotalPlatformDuration =>
      formatDurationSeconds(totalPlatformSessionSeconds.toDouble());

  String get formattedAverageTripDuration =>
      averageTripDurationDays > 0 ? '${averageTripDurationDays.toStringAsFixed(1)} gün' : '0 gün';

  String get formattedAverageExpense =>
      averageExpensePerTrip > 0 ? '\$${averageExpensePerTrip.toStringAsFixed(0)}' : '\$0';
}

/// User profile model for Admin Management
class AdminUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String provider;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final DateTime? lastActiveAt;
  final bool isPremium;
  final int totalVaultStorageBytes;
  final String banStatus; // 'none' | 'temporary' | 'permanent'
  final String? banExpiresAt;
  final String? banReason;
  final List<String> restrictedFeatures;
  final String countryCode;
  final String countryName;
  final String homeCity;
  final String currencyCode;
  final String liveCountryCode;
  final String liveCountryName;
  final String liveCity;
  final String appThemeMode; // 'light' | 'dark' | 'system'
  final String appLanguage; // 'tr' | 'en' | 'de' ...
  final String deletionStatus; // 'none' | 'pending_deletion'
  final String? deletionRequestedAt;
  final String? scheduledPermanentDeletionAt;
  final DateTime? lastInactivityWarningAt;
  final int inactivityWarningCount;
  final int totalSessionSeconds;
  final int sessionCount;
  final int lastSessionSeconds;
  final Map<String, dynamic> travelMapCountries;
  final String username;
  final String bio;
  final String travelStatus;
  final List<String> travelStyles;

  const AdminUserModel({
    required this.uid,
    this.email = '',
    this.displayName = '',
    this.photoUrl = '',
    this.provider = 'password',
    this.emailVerified = false,
    this.createdAt,
    this.lastLoginAt,
    this.lastActiveAt,
    this.isPremium = false,
    this.totalVaultStorageBytes = 0,
    this.banStatus = 'none',
    this.banExpiresAt,
    this.banReason,
    this.restrictedFeatures = const [],
    this.countryCode = 'US',
    this.countryName = 'United States',
    this.homeCity = '',
    this.currencyCode = 'USD',
    this.liveCountryCode = '',
    this.liveCountryName = '',
    this.liveCity = '',
    this.appThemeMode = 'light',
    this.appLanguage = 'tr',
    this.deletionStatus = 'none',
    this.deletionRequestedAt,
    this.scheduledPermanentDeletionAt,
    this.lastInactivityWarningAt,
    this.inactivityWarningCount = 0,
    this.totalSessionSeconds = 0,
    this.sessionCount = 0,
    this.lastSessionSeconds = 0,
    this.travelMapCountries = const {},
    this.username = '',
    this.bio = '',
    this.travelStatus = '',
    this.travelStyles = const [],
  });

  bool get isCurrentlyBanned {
    if (banStatus == 'permanent') return true;
    if (banStatus == 'temporary' && banExpiresAt != null) {
      try {
        final expiry = DateTime.parse(banExpiresAt!);
        return expiry.isAfter(DateTime.now());
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  bool get isRestricted => restrictedFeatures.isNotEmpty;

  int? get daysUntilPermanentDeletion {
    if (deletionStatus != 'pending_deletion' || scheduledPermanentDeletionAt == null) return null;
    try {
      final scheduled = DateTime.parse(scheduledPermanentDeletionAt!);
      final diff = scheduled.difference(DateTime.now()).inDays;
      return diff < 0 ? 0 : diff;
    } catch (_) {
      return null;
    }
  }

  DateTime get effectiveLastActiveAt =>
      lastActiveAt ?? lastLoginAt ?? createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  int get inactiveDays {
    final last = effectiveLastActiveAt;
    if (last.millisecondsSinceEpoch == 0) return 0;
    final diff = DateTime.now().difference(last).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Inactivity Rule: 5th Month (150-179 days) -> Weekly warning emails before deletion
  bool get is5thMonthWarningPeriod => inactiveDays >= 150 && inactiveDays < 180;

  /// Inactivity Rule: 6+ Months (180+ days) -> Eligible for permanent purge
  bool get is6thMonthPurgeReady => inactiveDays >= 180;

  factory AdminUserModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return AdminUserModel(
      uid: id,
      email: data['email'] as String? ?? '',
      displayName: (data['displayName'] ?? data['display_name']) as String? ?? '',
      photoUrl: (data['photoUrl'] ?? data['photo_url']) as String? ?? '',
      provider: data['provider'] as String? ?? 'password',
      emailVerified: (data['emailVerified'] ?? data['email_verified']) as bool? ?? false,
      createdAt: parseDate(data['createdAt'] ?? data['created_at']),
      lastLoginAt: parseDate(data['lastLoginAt'] ?? data['last_login_at']),
      lastActiveAt: parseDate(data['lastActiveAt'] ?? data['last_active_at']),
      isPremium: (data['isPremium'] == true) ||
          (data['is_premium'] == true) ||
          (data['isPro'] == true) ||
          (data['pro'] == true) ||
          PreferencesService.instance.isProUser(uid: id),
      totalVaultStorageBytes: ((data['totalVaultStorageBytes'] ?? data['total_vault_storage_bytes']) as num?)?.toInt() ?? 0,
      banStatus: (data['banStatus'] ?? data['ban_status']) as String? ?? 'none',
      banExpiresAt: (data['banExpiresAt'] ?? data['ban_expires_at']) as String?,
      banReason: (data['banReason'] ?? data['ban_reason']) as String?,
      restrictedFeatures: ((data['restrictedFeatures'] ?? data['restricted_features']) as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      countryCode: (data['homeCountryCode'] ?? data['countryCode'] ?? data['country_code']) as String? ?? 'US',
      countryName: (data['countryName'] ?? data['country_name'] ??
          Country.findByCode((data['homeCountryCode'] ?? data['countryCode'] ?? data['country_code'] ?? 'US').toString())?.name) as String? ?? 'United States',
      homeCity: ((data['homeCity'] ?? data['home_city']) as String? ?? '').trim(),
      currencyCode: (data['currencyCode'] ?? data['currency_code']) as String? ?? 'USD',
      liveCountryCode: ((data['liveCountryCode'] ?? data['live_country_code']) as String? ?? '').toUpperCase().trim(),
      liveCountryName: ((data['liveCountryName'] ?? data['live_country_name'] ??
          (data['liveCountryCode'] != null ? Country.findByCode(data['liveCountryCode'].toString())?.name : '')) as String? ?? '').trim(),
      liveCity: ((data['liveCity'] ?? data['live_city']) as String? ?? '').trim(),
      appThemeMode: ((data['appThemeMode'] ?? data['app_theme_mode'] ?? data['themeMode'] ?? data['theme_mode']) as String? ?? 'light').toLowerCase().trim(),
      appLanguage: ((data['appLanguage'] ?? data['app_language'] ?? data['languageCode'] ?? data['language_code']) as String? ?? 'tr').toLowerCase().trim(),
      deletionStatus: (data['deletionStatus'] ?? data['deletion_status']) as String? ?? 'none',
      deletionRequestedAt: (data['deletionRequestedAt'] ?? data['deletion_requested_at']) as String?,
      scheduledPermanentDeletionAt: (data['scheduledPermanentDeletionAt'] ?? data['scheduled_permanent_deletion_at']) as String?,
      lastInactivityWarningAt: parseDate(data['lastInactivityWarningAt'] ?? data['last_inactivity_warning_at']),
      inactivityWarningCount: ((data['inactivityWarningCount'] ?? data['inactivity_warning_count']) as num?)?.toInt() ?? 0,
      totalSessionSeconds: ((data['totalSessionSeconds'] ?? data['total_session_seconds']) as num?)?.toInt() ?? 0,
      sessionCount: ((data['sessionCount'] ?? data['session_count']) as num?)?.toInt() ?? 0,
      lastSessionSeconds: ((data['lastSessionSeconds'] ?? data['last_session_seconds']) as num?)?.toInt() ?? 0,
      travelMapCountries: ((data['travelMapCountries'] ?? data['travel_map_countries']) as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString().toUpperCase(), v),
          ) ?? const {},
      username: (data['username'] ?? data['userName'] ?? data['buddyId']) as String? ?? '',
      bio: (data['bio'] ?? data['about']) as String? ?? '',
      travelStatus: (data['travelStatus'] ?? data['status']) as String? ?? '',
      travelStyles: ((data['travelStyles'] ?? data['travelStyle']) is List)
          ? ((data['travelStyles'] ?? data['travelStyle']) as List)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
    );
  }

  bool get hasUsername => username.isNotEmpty;

  String get formattedUsername => hasUsername ? '@$username' : '';

  bool get hasBio => bio.isNotEmpty;

  bool get hasTravelStatus => travelStatus.isNotEmpty;

  double get averageSessionMinutes =>
      sessionCount > 0 ? (totalSessionSeconds / sessionCount / 60) : 0.0;

  String get effectiveHomeCountryCode => countryCode.isNotEmpty ? countryCode : 'US';

  String get effectiveHomeCountryName => countryName.isNotEmpty ? countryName : 'United States';

  String get effectiveHomeCity => homeCity.isNotEmpty ? homeCity : '';

  String get effectiveLiveCountryCode =>
      liveCountryCode.isNotEmpty ? liveCountryCode : effectiveHomeCountryCode;

  String get effectiveLiveCountryName =>
      liveCountryName.isNotEmpty ? liveCountryName : effectiveHomeCountryName;

  bool get hasDistinctLiveLocation =>
      liveCountryCode.isNotEmpty &&
      (liveCountryCode.toUpperCase() != effectiveHomeCountryCode.toUpperCase() ||
          (liveCity.isNotEmpty && liveCity.toLowerCase() != effectiveHomeCity.toLowerCase()));

  int get visitedWorldMapCount => travelMapCountries.values.where((v) {
        String status = '';
        if (v is Map) {
          status = (v['status'] ?? '').toString().toLowerCase().trim();
        } else if (v is String) {
          status = v.toLowerCase().trim();
        }
        return status.contains('visited') ||
            status.contains('lived') ||
            status == 'gezilen' ||
            status == 'gezi' ||
            status == 'yasayan';
      }).length;

  int get wishlistWorldMapCount => travelMapCountries.values.where((v) {
        String status = '';
        if (v is Map) {
          status = (v['status'] ?? '').toString().toLowerCase().trim();
        } else if (v is String) {
          status = v.toLowerCase().trim();
        }
        return status.contains('wish') ||
            status == 'hedef' ||
            status == 'istek';
      }).length;

  int get livedWorldMapCount => travelMapCountries.values.where((v) {
        String status = '';
        if (v is Map) {
          status = (v['status'] ?? '').toString().toLowerCase().trim();
        } else if (v is String) {
          status = v.toLowerCase().trim();
        }
        return status.contains('lived') || status == 'yasayan';
      }).length;

  double get worldExploredPercentage =>
      WorldCountriesData.allCountries.isNotEmpty
          ? (visitedWorldMapCount / WorldCountriesData.allCountries.length * 100)
          : 0.0;

  AdminUserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? provider,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? lastActiveAt,
    bool? isPremium,
    int? totalVaultStorageBytes,
    String? banStatus,
    String? banExpiresAt,
    String? banReason,
    List<String>? restrictedFeatures,
    String? countryCode,
    String? countryName,
    String? currencyCode,
    String? liveCountryCode,
    String? liveCountryName,
    String? liveCity,
    String? appThemeMode,
    String? appLanguage,
    String? deletionStatus,
    String? deletionRequestedAt,
    String? scheduledPermanentDeletionAt,
    DateTime? lastInactivityWarningAt,
    int? inactivityWarningCount,
    int? totalSessionSeconds,
    int? sessionCount,
    int? lastSessionSeconds,
    Map<String, dynamic>? travelMapCountries,
    String? username,
    String? bio,
    String? travelStatus,
    List<String>? travelStyles,
    bool clearBanExpiresAt = false,
    bool clearBanReason = false,
  }) {
    return AdminUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isPremium: isPremium ?? this.isPremium,
      totalVaultStorageBytes: totalVaultStorageBytes ?? this.totalVaultStorageBytes,
      banStatus: banStatus ?? this.banStatus,
      banExpiresAt: clearBanExpiresAt ? null : (banExpiresAt ?? this.banExpiresAt),
      banReason: clearBanReason ? null : (banReason ?? this.banReason),
      restrictedFeatures: restrictedFeatures ?? this.restrictedFeatures,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      currencyCode: currencyCode ?? this.currencyCode,
      liveCountryCode: liveCountryCode ?? this.liveCountryCode,
      liveCountryName: liveCountryName ?? this.liveCountryName,
      liveCity: liveCity ?? this.liveCity,
      appThemeMode: appThemeMode ?? this.appThemeMode,
      appLanguage: appLanguage ?? this.appLanguage,
      deletionStatus: deletionStatus ?? this.deletionStatus,
      deletionRequestedAt: deletionRequestedAt ?? this.deletionRequestedAt,
      scheduledPermanentDeletionAt: scheduledPermanentDeletionAt ?? this.scheduledPermanentDeletionAt,
      lastInactivityWarningAt: lastInactivityWarningAt ?? this.lastInactivityWarningAt,
      inactivityWarningCount: inactivityWarningCount ?? this.inactivityWarningCount,
      totalSessionSeconds: totalSessionSeconds ?? this.totalSessionSeconds,
      sessionCount: sessionCount ?? this.sessionCount,
      lastSessionSeconds: lastSessionSeconds ?? this.lastSessionSeconds,
      travelMapCountries: travelMapCountries ?? this.travelMapCountries,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      travelStatus: travelStatus ?? this.travelStatus,
      travelStyles: travelStyles ?? this.travelStyles,
    );
  }
}

/// Helper function to format storage byte measurements cleanly (e.g. 0 B, 450 KB, 3.2 MB)
String formatStorageBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  var i = 0;
  var d = bytes.toDouble();
  while (d >= 1024 && i < suffixes.length - 1) {
    d /= 1024;
    i++;
  }
  if (i == 0) return '$bytes B';
  final formatted = d.toStringAsFixed(1);
  return formatted.endsWith('.0')
      ? '${formatted.substring(0, formatted.length - 2)} ${suffixes[i]}'
      : '$formatted ${suffixes[i]}';
}

/// Result summary of executing inactivity policies across all users
class InactivityScanResult {
  final int totalScanned;
  final int warningsSent;
  final int accountsPurged;
  final List<String> warningUserEmails;
  final List<String> purgedUserEmails;

  const InactivityScanResult({
    this.totalScanned = 0,
    this.warningsSent = 0,
    this.accountsPurged = 0,
    this.warningUserEmails = const [],
    this.purgedUserEmails = const [],
  });
}

class AdminUserSessionLog {
  final int durationSeconds;
  final DateTime timestamp;

  const AdminUserSessionLog({
    required this.durationSeconds,
    required this.timestamp,
  });

  factory AdminUserSessionLog.fromMap(Map<String, dynamic> map) {
    DateTime ts = DateTime.now();
    final raw = map['timestamp'] ?? map['createdAt'];
    if (raw is Timestamp) {
      ts = raw.toDate();
    } else if (raw is String) {
      ts = DateTime.tryParse(raw) ?? ts;
    } else if (raw is int) {
      ts = DateTime.fromMillisecondsSinceEpoch(raw);
    }
    final sec = (map['durationSeconds'] ?? map['seconds'] ?? map['duration']) as num?;
    return AdminUserSessionLog(
      durationSeconds: sec?.toInt() ?? 0,
      timestamp: ts,
    );
  }
}

/// Contract for Admin Data Service
abstract class AdminService {
  Future<AdminPlatformMetrics> fetchMetrics();
  Future<List<AdminUserModel>> fetchUsers();
  Future<AdminDetailedAnalytics> fetchDetailedAnalytics();
  Future<void> toggleUserProStatus(String uid, bool isPremium);
  Future<void> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  });
  Future<List<VaultDocument>> fetchUserDocuments(String uid);
  Future<Uint8List?> viewUserDocumentDecrypted({
    required String targetUserId,
    required VaultDocument doc,
  });
  Future<List<Trip>> fetchUserTrips(String uid);
  Future<List<Expense>> fetchUserExpenses(String uid);
  Future<List<AdminUserSessionLog>> fetchUserSessions(String uid);
  Future<List<TravelCountry>> fetchUserTravelCountries(String uid);
  Future<List<FriendUserSummary>> fetchUserFriends(String uid);
  Future<({List<FriendRequestItem> incoming, List<FriendRequestItem> outgoing})> fetchUserFriendRequests(String uid);
  Future<bool> removeUserFriendship(String currentUid, String targetUid);
  Future<void> deleteUserDocumentAsAdmin({required String uid, required String documentId});
  Future<void> cancelAccountDeletionAsAdmin(String uid);
  Future<void> purgeUserDataAsAdmin(String uid);
  Future<void> sendInactivityWarningEmail(String uid);
  Future<bool> sendUserWarning({
    required String uid,
    required String title,
    required String message,
    required String warningType,
    bool sendInAppNotification = true,
    bool sendEmail = true,
  });
  Future<bool> sendBroadcastAnnouncement({
    required String title,
    required String message,
    String type = 'discount',
    String targetAction = 'paywall',
    String targetAudience = 'all',
    int? discountPercent,
    String? actionLabel,
  });
  Future<List<BroadcastAnnouncement>> fetchBroadcastAnnouncements();
  Future<bool> toggleBroadcastActive(String broadcastId, bool active);
  Future<bool> deleteBroadcastAnnouncement(String broadcastId);
  Future<void> recordAuditLog({
    required String action,
    required String actionTitle,
    required String targetUid,
    String? targetUserEmail,
    String? targetUserName,
    Map<String, dynamic> details = const {},
  });
  Future<List<AdminAuditLog>> fetchAuditLogs({int limit = 100});
  Future<InactivityScanResult> processInactivityPolicies();
  Future<DeletedAccountsSummary> fetchDeletedAccountsArchive();
  bool isCurrentUserAdmin();
}

/// Firebase implementation of [AdminService]
class FirebaseAdminService implements AdminService {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  FirebaseAdminService({
    this.firestore,
    this.auth,
  });

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _effectiveFirestore {
    if (firestore != null) return firestore;
    if (_isFirebaseReady) return FirebaseFirestore.instance;
    return null;
  }

  FirebaseAuth? get _effectiveAuth {
    if (auth != null) return auth;
    if (_isFirebaseReady) return FirebaseAuth.instance;
    return null;
  }

  @override
  bool isCurrentUserAdmin() {
    try {
      final user = auth?.currentUser ??
          (_isFirebaseReady ? FirebaseAuth.instance.currentUser : null);
      if (user == null) return false;
      return user.email?.trim().toLowerCase() == kAdminEmail;
    } catch (_) {
      return false;
    }
  }

  /// Upper bound of documents read per collection for admin analytics distributions (#5).
  static const int analyticsSampleSize = 1000;

  /// Bounded collection read for analytics (never downloads an unbounded collection).
  Future<QuerySnapshot<Map<String, dynamic>>> _boundedGet(CollectionReference<Map<String, dynamic>> collection) async {
    try {
      return await collection.limit(analyticsSampleSize).get();
    } on UnimplementedError {
      return collection.get(); // in-memory test fakes only
    }
  }

  /// Inactivity policy candidates (#5): pages through users from the OLDEST login onwards and
  /// stops as soon as a page reaches users who logged in within the last 150 days, so only
  /// potentially inactive profiles are read (instead of the whole users collection).
  Future<List<AdminUserModel>> _fetchInactivityCandidates() async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return fetchUsers();
    try {
      final now = DateTime.now().toUtc();
      final out = <AdminUserModel>[];
      DocumentSnapshot<Map<String, dynamic>>? cursor;
      while (true) {
        Query<Map<String, dynamic>> query =
            firestore.collection('users').orderBy('lastLoginAt').limit(adminUserPageSize);
        if (cursor != null) query = query.startAfterDocument(cursor);
        final page = await query.get();
        if (page.docs.isEmpty) break;
        out.addAll(page.docs.map((d) => AdminUserModel.fromMap(d.id, d.data())));
        cursor = page.docs.last;
        final newestInPage = AdminUserModel.fromMap(cursor.id, cursor.data()!).lastLoginAt;
        final reachedActiveUsers =
            newestInPage != null && now.difference(newestInPage.toUtc()).inDays < 150;
        if (reachedActiveUsers || page.docs.length < adminUserPageSize) break;
      }
      return out;
    } on UnimplementedError {
      return fetchUsers(); // in-memory test fakes only
    } catch (e) {
      debugPrint('[AdminService] inactivity candidate scan notice: $e');
      return fetchUsers();
    }
  }

  /// Page size for admin user lists (#5).
  static const int adminUserPageSize = 300;

  /// Cursor-based page of users ordered by lastLoginAt (desc). Pass the last uid of the previous
  /// page as [startAfterUid] to continue. Bounded read for large user bases (#5).
  Future<List<AdminUserModel>> fetchUsersPage({
    int limit = adminUserPageSize,
    String? startAfterUid,
  }) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return const [];
    Query<Map<String, dynamic>> query =
        firestore.collection('users').orderBy('lastLoginAt', descending: true).limit(limit);
    if (startAfterUid != null && startAfterUid.isNotEmpty) {
      final cursor = await firestore.collection('users').doc(startAfterUid).get();
      if (cursor.exists) query = query.startAfterDocument(cursor);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => AdminUserModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<int> _getCollectionCount(String collectionName) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return 0;
    try {
      final aggregate = await firestore.collection(collectionName).count().get();
      return aggregate.count ?? 0;
    } on UnimplementedError {
      // In-memory test fakes without aggregation support only.
      try {
        final snapshot = await firestore.collection(collectionName).get();
        return snapshot.size;
      } catch (_) {
        return 0;
      }
    } catch (e) {
      // #5: never fall back to downloading a whole collection in production.
      debugPrint('[AdminService] count($collectionName) notice: $e');
      return 0;
    }
  }

  /// Legacy full scan, used only when aggregation queries are unsupported (test fakes).
  Future<(int, int, int, int, int, int, int, int)> _legacyUserMetricsScan(FirebaseFirestore firestore) async {
    final usersSnapshot = await firestore.collection('users').get();
    int verified = 0, pro = 0, storage = 0, usernames = 0, accepted = 0, pending = 0, activeToday = 0;
    final activeCutoff = DateTime.now().subtract(const Duration(hours: 24));
    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      if (data['emailVerified'] == true || data['email_verified'] == true) verified++;
      if (data['isPremium'] == true || data['is_premium'] == true || data['isPro'] == true || data['pro'] == true) {
        pro++;
      }
      storage += ((data['totalVaultStorageBytes'] ?? data['total_vault_storage_bytes']) as num?)?.toInt() ?? 0;
      if ((data['username'] ?? data['userName'] ?? '').toString().trim().isNotEmpty) usernames++;
      final lastActive = AdminUserModel.fromMap(doc.id, data).lastActiveAt;
      if (lastActive != null && !lastActive.isBefore(activeCutoff)) activeToday++;
    }
    try {
      final friendshipsSnap = await firestore.collection('friendships').get();
      for (final doc in friendshipsSnap.docs) {
        final st = (doc.data()['status'] as String? ?? 'pending').toLowerCase();
        if (st == 'accepted') accepted++;
        if (st == 'pending') pending++;
      }
    } catch (_) {}
    return (usersSnapshot.docs.length, verified, pro, storage, usernames, accepted, pending, activeToday);
  }

  Future<AdminPlatformMetrics> _fetchLocalMetrics() async {
    try {
      final db = DatabaseHelper.instance;
      final trips = await db.getTrips();
      final expenses = await db.getExpenses();
      final docs = await db.getDocuments();
      final items = await db.getChecklistItems();
      final storageBytes = await db.getTotalVaultStorageBytes();

      final currentAuth = _effectiveAuth?.currentUser;
      final isPro = PreferencesService.instance.isProUser(uid: currentAuth?.uid);
      final isVerified = currentAuth?.emailVerified ?? false;
      final hasUser = currentAuth != null;

      return AdminPlatformMetrics(
        totalUsers: hasUser ? 1 : 0,
        verifiedUsers: (hasUser && isVerified) ? 1 : 0,
        proUsers: (hasUser && isPro) ? 1 : 0,
        totalTrips: trips.length,
        totalExpenses: expenses.length,
        totalDocuments: docs.length,
        totalChecklistItems: items.length,
        totalStorageBytes: storageBytes,
      );
    } catch (e) {
      debugPrint('[AdminService] _fetchLocalMetrics error: $e');
      return const AdminPlatformMetrics();
    }
  }

  Future<List<AdminUserModel>> _fetchLocalUserList() async {
    try {
      final currentAuth = _effectiveAuth?.currentUser;
      final uid = currentAuth?.uid ?? 'admin_local';
      final email = currentAuth?.email ?? kAdminEmail;
      final prefs = PreferencesService.instance;
      final db = DatabaseHelper.instance;

      final isPro = prefs.isProUser(uid: uid);
      final storageBytes = await db.getTotalVaultStorageBytes(userId: uid);
      final travelRows = await db.getTravelMapCountries(userId: uid);
      final Map<String, dynamic> travelMap = {};
      for (final row in travelRows) {
        final code = (row['code'] ?? '').toString().toUpperCase();
        if (code.isNotEmpty) {
          travelMap[code] = {
            'status': row['status'] ?? 'visited',
            'visited_date': row['visited_date'],
            'notes': row['notes'],
          };
        }
      }

      String localUsername = '';
      String localBio = '';
      String localTravelStatus = '';
      List<String> localTravelStyles = const [];
      final cachedProfileStr = prefs.getCachedUserProfile(uid);
      if (cachedProfileStr != null && cachedProfileStr.isNotEmpty) {
        try {
          final pMap = jsonDecode(cachedProfileStr);
          localUsername = (pMap['username'] ?? '').toString();
          localBio = (pMap['bio'] ?? '').toString();
          localTravelStatus = (pMap['travelStatus'] ?? '').toString();
          if (pMap['travelStyles'] is List) {
            localTravelStyles = (pMap['travelStyles'] as List).map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }

      final localUser = AdminUserModel(
        uid: uid,
        email: email,
        displayName: currentAuth?.displayName?.isNotEmpty == true
            ? currentAuth!.displayName!
            : 'Super Admin',
        photoUrl: currentAuth?.photoURL ?? '',
        provider: currentAuth?.providerData.isNotEmpty == true
            ? currentAuth!.providerData.first.providerId
            : 'password',
        emailVerified: currentAuth?.emailVerified ?? true,
        createdAt: currentAuth?.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: currentAuth?.metadata.lastSignInTime ?? DateTime.now(),
        lastActiveAt: DateTime.now(),
        isPremium: isPro,
        totalVaultStorageBytes: storageBytes,
        countryCode: prefs.getCountryCode(uid: uid) ?? 'TR',
        countryName: prefs.getCountryName(uid: uid) ?? 'Turkey',
        currencyCode: prefs.getDefaultCurrency(uid: uid) ?? 'TRY',
        liveCountryCode: (prefs.getCountryCode(uid: uid) ?? 'TR').toUpperCase().trim(),
        liveCountryName: (prefs.getCountryName(uid: uid) ?? 'Turkey').trim(),
        liveCity: prefs.getLiveCity(uid: uid) ?? '',
        appThemeMode: prefs.getThemeMode().name,
        appLanguage: prefs.getLocale()?.languageCode ?? 'tr',
        totalSessionSeconds: prefs.getTotalSessionSeconds(uid: uid),
        sessionCount: prefs.getSessionCount(uid: uid) > 0 ? prefs.getSessionCount(uid: uid) : 1,
        lastSessionSeconds: prefs.getLastSessionSeconds(uid: uid),
        travelMapCountries: travelMap,
        username: localUsername,
        bio: localBio,
        travelStatus: localTravelStatus,
        travelStyles: localTravelStyles,
      );

      return [localUser];
    } catch (e) {
      debugPrint('[AdminService] _fetchLocalUserList error: $e');
      return [];
    }
  }

  String _resolveCountryCodeFromDestination(String destination) {
    if (destination.isEmpty) return '';
    final cleaned = destination.trim().toLowerCase();

    // 1. Direct 2-letter ISO code match
    if (cleaned.length == 2 && RegExp(r'^[a-z]{2}$').hasMatch(cleaned)) {
      return cleaned.toUpperCase();
    }

    // 2. Search in WorldCountriesData
    for (final c in WorldCountriesData.allCountries) {
      final tr = c.nameTr.toLowerCase();
      final en = c.nameEn.toLowerCase();
      final cap = c.capital.toLowerCase();
      if (cleaned == tr || cleaned == en || cleaned == cap) {
        return c.code;
      }
      if (cleaned.contains(tr) || cleaned.contains(en) || (cap.isNotEmpty && cleaned.contains(cap))) {
        return c.code;
      }
    }

    // 3. Search in Country.allCountries and popularDestinations
    for (final c in Country.allCountries) {
      final name = c.name.toLowerCase();
      final local = c.localName.toLowerCase();
      if (cleaned == name || cleaned == local || cleaned.contains(name) || cleaned.contains(local)) {
        return c.code;
      }
      for (final pop in c.popularDestinations) {
        final p = pop.toLowerCase();
        if (cleaned == p || cleaned.contains(p)) {
          return c.code;
        }
      }
    }

    return '';
  }

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async {
    final firestore = _effectiveFirestore;
    if (firestore == null) {
      return await _fetchLocalMetrics();
    }

    try {
      // #5 Billing protection: server-side count()/sum() aggregations instead of downloading
      // every users / friendships document (one aggregation ≈ 1 read per 1000 index entries).
      int totalUsers = 0;
      int verifiedUsers = 0;
      int proUsers = 0;
      int totalStorageBytes = 0;
      int usernamesClaimed = 0;
      int totalFriendships = 0;
      int pendingFriendRequests = 0;
      int dailyActiveUsers = 0;
      // users.lastActiveAt is written as an ISO-8601 string (auth_service, sync_engine, profile).
      final activeCutoffIso = DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
      try {
        final users = firestore.collection('users');
        final usersAgg = await users.aggregate(count(), sum('totalVaultStorageBytes')).get();
        totalUsers = usersAgg.count ?? 0;
        totalStorageBytes = (usersAgg.getSum('totalVaultStorageBytes') ?? 0).toInt();
        verifiedUsers = (await users.where('emailVerified', isEqualTo: true).count().get()).count ?? 0;
        proUsers = (await users.where('isPremium', isEqualTo: true).count().get()).count ?? 0;
        usernamesClaimed = await _getCollectionCount('usernames');
        final friendships = firestore.collection('friendships');
        totalFriendships = (await friendships.where('status', isEqualTo: 'accepted').count().get()).count ?? 0;
        pendingFriendRequests = (await friendships.where('status', isEqualTo: 'pending').count().get()).count ?? 0;
        dailyActiveUsers = (await users
                    .where('lastActiveAt', isGreaterThanOrEqualTo: activeCutoffIso)
                    .count()
                    .get())
                .count ??
            0;
      } on UnimplementedError {
        // Aggregations unsupported (in-memory test fakes): legacy client-side tally.
        final legacy = await _legacyUserMetricsScan(firestore);
        totalUsers = legacy.$1;
        verifiedUsers = legacy.$2;
        proUsers = legacy.$3;
        totalStorageBytes = legacy.$4;
        usernamesClaimed = legacy.$5;
        totalFriendships = legacy.$6;
        pendingFriendRequests = legacy.$7;
        dailyActiveUsers = legacy.$8;
      }

      final totalTrips = await _getCollectionCount('trips');
      final totalExpenses = await _getCollectionCount('expenses');
      final totalDocs = await _getCollectionCount('documents');
      final totalItems = await _getCollectionCount('checklist_items');

      if (totalUsers == 0 && totalTrips == 0 && totalDocs == 0) {
        final local = await _fetchLocalMetrics();
        if (local.totalUsers > 0 || local.totalTrips > 0 || local.totalDocuments > 0) {
          return local;
        }
      }

      return AdminPlatformMetrics(
        totalUsers: totalUsers,
        verifiedUsers: verifiedUsers,
        proUsers: proUsers,
        totalTrips: totalTrips,
        totalExpenses: totalExpenses,
        totalDocuments: totalDocs,
        totalChecklistItems: totalItems,
        totalStorageBytes: totalStorageBytes,
        totalFriendships: totalFriendships,
        totalPendingFriendRequests: pendingFriendRequests,
        totalUsernamesClaimed: usernamesClaimed,
        dailyActiveUsers: dailyActiveUsers,
      );
    } catch (e) {
      debugPrint('[AdminService] fetchMetrics error: $e');
      return await _fetchLocalMetrics();
    }
  }

  @override
  Future<List<AdminUserModel>> fetchUsers() async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return await _fetchLocalUserList();

    try {
      final currentUid = _effectiveAuth?.currentUser?.uid;
      if (currentUid != null) {
        unawaited(() async {
          try {
            final loc = await LiveLocationService.instance.detectLiveLocation();
            if (loc.isSuccess) {
              await firestore.collection('users').doc(currentUid).set({
                'liveCountryCode': loc.countryCode.toUpperCase().trim(),
                'liveCountryName': loc.countryName.trim(),
                if (loc.city.isNotEmpty) 'liveCity': loc.city.trim(),
                'liveLocationUpdatedAt': DateTime.now().toIso8601String(),
              }, SetOptions(merge: true));
            }
          } catch (_) {}
        }());
      }

      // #5: bounded read — the most recently active [adminUserPageSize] users. Older pages can be
      // loaded with [fetchUsersPage] (limit + startAfter) instead of downloading every profile.
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await firestore
            .collection('users')
            .orderBy('lastLoginAt', descending: true)
            .limit(adminUserPageSize)
            .get();
      } on UnimplementedError {
        // In-memory test fakes without ordering/limit support only
        snapshot = await firestore.collection('users').get();
      } catch (_) {
        // Single-field index on lastLoginAt not ready yet: still bounded, unordered
        snapshot = await firestore.collection('users').limit(adminUserPageSize).get();
      }

      final users = snapshot.docs
          .map((doc) => AdminUserModel.fromMap(doc.id, doc.data()))
          .toList();

      if (users.isEmpty) {
        return await _fetchLocalUserList();
      }

      // Ensure stable client-side sorting by lastLoginAt descending
      users.sort((a, b) {
        final aTime = a.lastLoginAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastLoginAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      return users;
    } catch (e) {
      debugPrint('[AdminService] fetchUsers error: $e');
      return await _fetchLocalUserList();
    }
  }

  @override
  Future<AdminDetailedAnalytics> fetchDetailedAnalytics() async {
    final firestore = _effectiveFirestore;

    try {
      final Map<String, int> wishlistCounts = {};
      final Map<String, int> visitedCounts = {};
      final Map<String, int> livedCounts = {};
      final Map<String, int> continentCounts = {};
      final Map<String, int> tripDestinationCounts = {};
      final Map<String, int> currencyCounts = {};
      final Map<String, int> transportCounts = {};
      final Map<String, int> vaultCategoryCounts = {};
      final Map<String, int> themeCounts = {};
      final Map<String, int> languageCounts = {};
      final Map<String, int> travelStyleCounts = {};

      int totalPlatformSessionSeconds = 0;
      int totalPlatformSessions = 0;
      int verifiedUsers = 0;
      int proUsers = 0;
      int totalWorldMapMarks = 0;
      int usernameClaimCount = 0;
      int bioAdoptionCount = 0;
      int travelStatusCount = 0;
      int usersWithTravelStylesCount = 0;

      List<Map<String, dynamic>> userMaps = [];
      if (firestore != null) {
        try {
          final usersSnap = await _boundedGet(firestore.collection('users'));
          userMaps = usersSnap.docs.map((d) => d.data()).toList();
        } catch (_) {}
      }

      if (userMaps.isEmpty) {
        final localUsers = await _fetchLocalUserList();
        userMaps = localUsers.map((u) => {
          'countryCode': u.countryCode,
          'countryName': u.countryName,
          'liveCountryCode': u.liveCountryCode,
          'liveCountryName': u.liveCountryName,
          'liveCity': u.liveCity,
          'travelMapCountries': u.travelMapCountries,
          'totalSessionSeconds': u.totalSessionSeconds,
          'sessionCount': u.sessionCount,
          'lastSessionSeconds': u.lastSessionSeconds,
          'emailVerified': u.emailVerified,
          'isPremium': u.isPremium,
          'appThemeMode': u.appThemeMode,
          'appLanguage': u.appLanguage,
        }).toList();
      }

      final totalUsers = userMaps.length;

      for (final data in userMaps) {
        // 1. User Origin / Home Residence (Live location prioritized)
        final homeCountry = (data['liveCountryCode'] as String? ??
                data['live_country_code'] as String? ??
                data['countryCode'] as String? ??
                data['country_code'] as String? ??
                'US')
            .toUpperCase()
            .trim();
        if (homeCountry.isNotEmpty && homeCountry.length == 2) {
          livedCounts[homeCountry] = (livedCounts[homeCountry] ?? 0) + 1;
          _incrementContinent(continentCounts, homeCountry);
        }

        // 2. User Travel Map Countries (Wishlist, Visited, Lived) - Strictly World Map Data
        final travelCountries = data['travelMapCountries'] ?? data['travel_map_countries'];
        if (travelCountries is Map) {
          travelCountries.forEach((rawKey, val) {
            final code = rawKey.toString().toUpperCase().trim();
            if (code.length != 2) return;
            String status = '';
            if (val is Map) {
              status = (val['status'] as String? ?? '').toLowerCase().trim();
            } else if (val is String) {
              status = val.toLowerCase().trim();
            }

            if (status.contains('wish') || status == 'hedef' || status == 'istek') {
              wishlistCounts[code] = (wishlistCounts[code] ?? 0) + 1;
              _incrementContinent(continentCounts, code);
              totalWorldMapMarks++;
            } else if (status.contains('visited') || status == 'gezilen' || status == 'gezi') {
              visitedCounts[code] = (visitedCounts[code] ?? 0) + 1;
              _incrementContinent(continentCounts, code);
              totalWorldMapMarks++;
            } else if (status.contains('lived') || status == 'yasayan') {
              livedCounts[code] = (livedCounts[code] ?? 0) + 1;
              _incrementContinent(continentCounts, code);
              totalWorldMapMarks++;
            }
          });
        }

        // 3. User Session Tracking
        final sessionSec = ((data['totalSessionSeconds'] ?? data['total_session_seconds']) as num?)?.toInt() ?? 0;
        final sessions = ((data['sessionCount'] ?? data['session_count']) as num?)?.toInt() ?? 0;
        if (sessions > 0) {
          totalPlatformSessionSeconds += sessionSec;
          totalPlatformSessions += sessions;
        } else {
          // If user doc didn't store session seconds yet, calculate from login activity
          final lastLogin = data['lastLoginAt'] ?? data['last_login_at'];
          final lastActive = data['lastActiveAt'] ?? data['last_active_at'];
          if (lastLogin != null && lastActive != null) {
            DateTime? t1;
            DateTime? t2;
            if (lastLogin is Timestamp) t1 = lastLogin.toDate();
            if (lastActive is Timestamp) t2 = lastActive.toDate();
            if (lastLogin is String) t1 = DateTime.tryParse(lastLogin);
            if (lastActive is String) t2 = DateTime.tryParse(lastActive);
            if (lastLogin is int) t1 = DateTime.fromMillisecondsSinceEpoch(lastLogin);
            if (lastActive is int) t2 = DateTime.fromMillisecondsSinceEpoch(lastActive);
            if (t1 != null && t2 != null) {
              final diff = t2.difference(t1).inSeconds.abs();
              final realisticSec = diff.clamp(120, 1800);
              totalPlatformSessionSeconds += realisticSec;
              totalPlatformSessions += 1;
            }
          }
        }

        // 4. Pro & Verification
        if (data['emailVerified'] == true || data['email_verified'] == true) verifiedUsers++;
        if (data['isPremium'] == true ||
            data['is_premium'] == true ||
            (data['uid'] != null && PreferencesService.instance.isProUser(uid: data['uid'].toString()))) {
          proUsers++;
        }

        // 5. Theme & Language Preferences tracking
        final theme = ((data['appThemeMode'] ?? data['app_theme_mode'] ?? data['themeMode'] ?? 'light') as String).toLowerCase().trim();
        themeCounts[theme] = (themeCounts[theme] ?? 0) + 1;

        final lang = ((data['appLanguage'] ?? data['app_language'] ?? data['languageCode'] ?? 'tr') as String).toLowerCase().trim();
        languageCounts[lang] = (languageCounts[lang] ?? 0) + 1;

        // 6. Social, Profile & Travel Styles tracking
        final uName = (data['username'] ?? data['userName'] ?? '').toString().trim();
        if (uName.isNotEmpty) usernameClaimCount++;

        final bio = (data['bio'] ?? data['about'] ?? '').toString().trim();
        if (bio.isNotEmpty) bioAdoptionCount++;

        final st = (data['travelStatus'] ?? data['status'] ?? '').toString().trim();
        if (st.isNotEmpty) travelStatusCount++;

        final stylesRaw = data['travelStyles'] ?? data['travelStyle'];
        if (stylesRaw is List && stylesRaw.isNotEmpty) {
          usersWithTravelStylesCount++;
          for (final s in stylesRaw) {
            final sStr = s.toString().trim().toLowerCase();
            if (sStr.isNotEmpty) {
              travelStyleCounts[sStr] = (travelStyleCounts[sStr] ?? 0) + 1;
            }
          }
        }
      }

      // 5. Query Trips (Strictly Trip Data Analytics: Destinations, Dates, Transport, Currencies)
      double totalTripDays = 0;
      int tripCountWithDates = 0;
      int upcomingTripsCount = 0;
      int completedTripsCount = 0;
      int totalTripsSnapCount = 0;

      if (firestore != null) {
        try {
          final tripsSnap = await _boundedGet(firestore.collection('trips'));
          // Exact total via count(); distributions use the bounded sample (#5).
          final exactTrips = await _getCollectionCount('trips');
          totalTripsSnapCount = exactTrips > 0 ? exactTrips : tripsSnap.docs.length;
          final now = DateTime.now();
          for (final doc in tripsSnap.docs) {
            final tData = doc.data();
            var destCode = ((tData['countryCode'] ?? tData['country_code']) as String? ?? '').toUpperCase().trim();
            final destination = ((tData['destination']) as String? ?? '').trim();
            if (destCode.isEmpty && destination.isNotEmpty) {
              destCode = _resolveCountryCodeFromDestination(destination);
            }

            final mode = ((tData['transportMode'] ?? tData['transport_mode']) as String? ?? '').toLowerCase().trim();
            final curr = ((tData['defaultCurrency'] ?? tData['default_currency']) as String? ?? 'USD').toUpperCase().trim();

            if (mode.isNotEmpty) {
              transportCounts[mode] = (transportCounts[mode] ?? 0) + 1;
            }
            if (curr.isNotEmpty) {
              currencyCounts[curr] = (currencyCounts[curr] ?? 0) + 1;
            }

            DateTime? start;
            DateTime? end;
            final rawStart = tData['startDate'] ?? tData['start_date'];
            final rawEnd = tData['endDate'] ?? tData['end_date'];
            if (rawStart is Timestamp) start = rawStart.toDate();
            if (rawEnd is Timestamp) end = rawEnd.toDate();
            if (rawStart is String) start = DateTime.tryParse(rawStart);
            if (rawEnd is String) end = DateTime.tryParse(rawEnd);
            if (rawStart is int) start = DateTime.fromMillisecondsSinceEpoch(rawStart);
            if (rawEnd is int) end = DateTime.fromMillisecondsSinceEpoch(rawEnd);

            if (destCode.length == 2) {
              tripDestinationCounts[destCode] = (tripDestinationCounts[destCode] ?? 0) + 1;
            }

            if (start != null) {
              if (start.isAfter(now)) {
                upcomingTripsCount++;
              } else {
                completedTripsCount++;
              }
            }

            if (start != null && end != null) {
              final days = end.difference(start).inDays.abs();
              if (days > 0 && days < 90) {
                totalTripDays += days;
                tripCountWithDates++;
              }
            }
          }
        } catch (_) {}
      }

      // If cloud trips were empty or firestore was null, populate from SQLite
      if (totalTripsSnapCount == 0) {
        try {
          final localTrips = await DatabaseHelper.instance.getTrips();
          totalTripsSnapCount = localTrips.length;
          final now = DateTime.now();
          for (final t in localTrips) {
            var destCode = (t.countryCode ?? '').toUpperCase().trim();
            if (destCode.isEmpty && t.destination.isNotEmpty) {
              destCode = _resolveCountryCodeFromDestination(t.destination);
            }
            if (destCode.length == 2) {
              tripDestinationCounts[destCode] = (tripDestinationCounts[destCode] ?? 0) + 1;
            }
            final mode = (t.transportMode ?? '').toLowerCase().trim();
            if (mode.isNotEmpty) {
              transportCounts[mode] = (transportCounts[mode] ?? 0) + 1;
            }
            final curr = t.defaultCurrency.toUpperCase().trim();
            if (curr.isNotEmpty) {
              currencyCounts[curr] = (currencyCounts[curr] ?? 0) + 1;
            }
            final start = t.startDate;
            final end = t.endDate;
            if (start.isAfter(now)) {
              upcomingTripsCount++;
            } else {
              completedTripsCount++;
            }
            final days = end.difference(start).inDays.abs();
            if (days > 0 && days < 90) {
              totalTripDays += days;
              tripCountWithDates++;
            }
          }
        } catch (_) {}
      }

      // 6. Query Expenses (for Average Expense per Trip)
      double totalExpenseSum = 0;
      int expenseCount = 0;
      if (firestore != null) {
        try {
          final expSnap = await _boundedGet(firestore.collection('expenses'));
          for (final doc in expSnap.docs) {
            final eData = doc.data();
            final amt = (eData['amount'] as num?)?.toDouble() ?? 0.0;
            final curr = (eData['currency'] as String? ?? '').toUpperCase().trim();
            if (curr.isNotEmpty) {
              currencyCounts[curr] = (currencyCounts[curr] ?? 0) + 1;
            }
            if (amt > 0) {
              totalExpenseSum += amt;
              expenseCount++;
            }
          }
        } catch (_) {}
      }

      // If cloud expenses were empty or firestore was null, fallback to local SQLite
      if (expenseCount == 0) {
        try {
          final localExpenses = await DatabaseHelper.instance.getExpenses();
          for (final exp in localExpenses) {
            final amt = exp.amount;
            final curr = exp.currency.toUpperCase().trim();
            if (curr.isNotEmpty) {
              currencyCounts[curr] = (currencyCounts[curr] ?? 0) + 1;
            }
            if (amt > 0) {
              totalExpenseSum += amt;
              expenseCount++;
            }
          }
        } catch (_) {}
      }

      // 7. Query Vault Documents (for Category Distribution)
      if (firestore != null) {
        try {
          final docsSnap = await _boundedGet(firestore.collection('documents'));
          for (final doc in docsSnap.docs) {
            final cat = (doc.data()['category'] as String? ?? 'other').toLowerCase().trim();
            vaultCategoryCounts[cat] = (vaultCategoryCounts[cat] ?? 0) + 1;
          }
        } catch (_) {}
      }

      // If cloud documents were empty or firestore was null, fallback to local SQLite
      if (vaultCategoryCounts.isEmpty) {
        try {
          final localDocs = await DatabaseHelper.instance.getDocuments();
          for (final d in localDocs) {
            final cat = d.category.toLowerCase().trim();
            vaultCategoryCounts[cat] = (vaultCategoryCounts[cat] ?? 0) + 1;
          }
        } catch (_) {}
      }

      // Compute aggregates
      final avgSessionSeconds = totalPlatformSessions > 0
          ? (totalPlatformSessionSeconds / totalPlatformSessions)
          : 0.0;
      final avgTripDays = tripCountWithDates > 0
          ? (totalTripDays / tripCountWithDates)
          : 0.0;
      final avgExpensePerTrip = tripCountWithDates > 0
          ? (totalExpenseSum / tripCountWithDates)
          : (expenseCount > 0 ? (totalExpenseSum / expenseCount) : 0.0);

      // Convert count maps to sorted Metric lists
      final topWishlist = _buildCountryMetrics(wishlistCounts, totalUsers);
      final topVisited = _buildCountryMetrics(visitedCounts, totalUsers);
      final topLived = _buildCountryMetrics(livedCounts, totalUsers);
      final continentShares = _buildContinentMetrics(continentCounts);
      final topTripDestinations = _buildCountryMetrics(
        tripDestinationCounts,
        totalTripsSnapCount > 0 ? totalTripsSnapCount : 1,
      );
      final transportPrefs = _buildTransportMetrics(transportCounts);
      final currencyShares = _buildCurrencyMetrics(currencyCounts);
      final vaultCategories = _buildVaultCategoryMetrics(vaultCategoryCounts);

      final themeShares = _buildPreferenceMetrics(
        themeCounts,
        totalUsers,
        labelResolver: (k) {
          switch (k) {
            case 'dark':
              return 'Koyu Tema (Dark)';
            case 'light':
              return 'Açık Tema (Light)';
            case 'system':
              return 'Sistem Varsayılanı (System)';
            default:
              return k.toUpperCase();
          }
        },
        iconResolver: (k) {
          switch (k) {
            case 'dark':
              return '🌙';
            case 'light':
              return '☀️';
            case 'system':
              return '⚙️';
            default:
              return '🎨';
          }
        },
      );

      final languageShares = _buildPreferenceMetrics(
        languageCounts,
        totalUsers,
        labelResolver: (k) {
          switch (k) {
            case 'tr':
              return 'Türkçe (TR)';
            case 'en':
              return 'English (EN)';
            case 'de':
              return 'Deutsch (DE)';
            case 'fr':
              return 'Français (FR)';
            case 'es':
              return 'Español (ES)';
            case 'it':
              return 'Italiano (IT)';
            case 'ja':
              return '日本語 (JA)';
            case 'zh':
              return '中文 (ZH)';
            case 'ru':
              return 'Русский (RU)';
            case 'ar':
              return 'العربية (AR)';
            default:
              return k.toUpperCase();
          }
        },
        iconResolver: (k) {
          switch (k) {
            case 'tr':
              return '🇹🇷';
            case 'en':
              return '🇬🇧';
            case 'de':
              return '🇩🇪';
            case 'fr':
              return '🇫🇷';
            case 'es':
              return '🇪🇸';
            case 'it':
              return '🇮🇹';
            case 'ja':
              return '🇯🇵';
            case 'zh':
              return '🇨🇳';
            case 'ru':
              return '🇷🇺';
            case 'ar':
              return '🇸🇦';
            default:
              return '🌐';
          }
        },
      );

      // Query friendships for social analytics
      int totalFriendships = 0;
      int pendingFriendRequests = 0;
      final Set<String> usersWithFriends = {};
      if (firestore != null) {
        try {
          final friendshipsSnap = await _boundedGet(firestore.collection('friendships'));
          for (final doc in friendshipsSnap.docs) {
            final fData = doc.data();
            final status = (fData['status'] as String? ?? 'pending').toLowerCase();
            if (status == 'accepted') {
              totalFriendships++;
              final users = (fData['users'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
              usersWithFriends.addAll(users);
            } else if (status == 'pending') {
              pendingFriendRequests++;
            }
          }
        } catch (_) {}
      }

      final avgFriendsPerUser = totalUsers > 0 ? ((totalFriendships * 2) / totalUsers) : 0.0;
      final usernameClaimRate = totalUsers > 0 ? (usernameClaimCount / totalUsers) : 0.0;
      final bioAdoptionRate = totalUsers > 0 ? (bioAdoptionCount / totalUsers) : 0.0;
      final travelStatusAdoptionRate = totalUsers > 0 ? (travelStatusCount / totalUsers) : 0.0;
      final travelStylesAdoptionRate = totalUsers > 0 ? (usersWithTravelStylesCount / totalUsers) : 0.0;

      final travelStyleShares = travelStyleCounts.entries.map((entry) {
        final style = TravelStyle.catalog.firstWhere(
          (s) => s.id == entry.key,
          orElse: () => TravelStyle(id: entry.key, emoji: '🎒', defaultName: entry.key),
        );
        return PreferenceShareMetric(
          key: entry.key,
          label: style.defaultName,
          icon: style.emoji,
          count: entry.value,
          percentage: totalUsers > 0 ? (entry.value / totalUsers).clamp(0.0, 1.0) : 0.0,
        );
      }).toList()..sort((a, b) => b.count.compareTo(a.count));

      int totalBadgesUnlocked = 0;
      int diamondBadges = 0;
      int goldBadges = 0;
      int silverBadges = 0;
      int bronzeBadges = 0;

      for (final data in userMaps) {
        final travelCountries = data['travelMapCountries'] ?? data['travel_map_countries'];
        int vCount = 0;
        if (travelCountries is Map) {
          vCount = travelCountries.values.where((v) {
            final s = (v is Map ? v['status'] : v).toString().toLowerCase();
            return s.contains('visit') || s.contains('live');
          }).length;
        }
        final badges = TravelBadge.calculateBadges(
          totalTrips: tripCountWithDates,
          totalCountries: vCount,
          totalItems: 0,
          totalDocuments: 0,
        );
        for (final b in badges) {
          if (b.isUnlocked) {
            totalBadgesUnlocked++;
            switch (b.tier) {
              case BadgeTier.diamond:
                diamondBadges++;
                break;
              case BadgeTier.gold:
                goldBadges++;
                break;
              case BadgeTier.silver:
                silverBadges++;
                break;
              case BadgeTier.bronze:
                bronzeBadges++;
                break;
            }
          }
        }
      }

      final badgeTierShares = [
        PreferenceShareMetric(
          key: 'diamond',
          label: 'Elmas (Diamond)',
          icon: '💎',
          count: diamondBadges,
          percentage: (totalUsers > 0 && totalBadgesUnlocked > 0)
              ? (diamondBadges / totalBadgesUnlocked).clamp(0.0, 1.0)
              : 0.0,
        ),
        PreferenceShareMetric(
          key: 'gold',
          label: 'Altın (Gold)',
          icon: '🥇',
          count: goldBadges,
          percentage: (totalUsers > 0 && totalBadgesUnlocked > 0)
              ? (goldBadges / totalBadgesUnlocked).clamp(0.0, 1.0)
              : 0.0,
        ),
        PreferenceShareMetric(
          key: 'silver',
          label: 'Gümüş (Silver)',
          icon: '🥈',
          count: silverBadges,
          percentage: (totalUsers > 0 && totalBadgesUnlocked > 0)
              ? (silverBadges / totalBadgesUnlocked).clamp(0.0, 1.0)
              : 0.0,
        ),
        PreferenceShareMetric(
          key: 'bronze',
          label: 'Bronz (Bronze)',
          icon: '🥉',
          count: bronzeBadges,
          percentage: (totalUsers > 0 && totalBadgesUnlocked > 0)
              ? (bronzeBadges / totalBadgesUnlocked).clamp(0.0, 1.0)
              : 0.0,
        ),
      ];

      return AdminDetailedAnalytics(
        topWishlistCountries: topWishlist,
        topVisitedCountries: topVisited,
        topLivedCountries: topLived,
        continentShares: continentShares,
        topTripDestinations: topTripDestinations,
        upcomingTripsCount: upcomingTripsCount,
        completedTripsCount: completedTripsCount,
        totalWorldMapMarks: totalWorldMapMarks,
        transportPreferences: transportPrefs,
        currencyShares: currencyShares,
        vaultCategories: vaultCategories,
        themeShares: themeShares,
        languageShares: languageShares,
        totalPlatformSessionSeconds: totalPlatformSessionSeconds,
        totalPlatformSessions: totalPlatformSessions,
        averageSessionDurationSeconds: avgSessionSeconds,
        averageTripDurationDays: avgTripDays,
        averageExpensePerTrip: avgExpensePerTrip,
        proConversionRate: totalUsers > 0 ? (proUsers / totalUsers) : 0.0,
        emailVerificationRate: totalUsers > 0 ? (verifiedUsers / totalUsers) : 0.0,
        totalFriendships: totalFriendships,
        totalPendingFriendRequests: pendingFriendRequests,
        averageFriendsPerUser: avgFriendsPerUser,
        usersWithFriendsCount: usersWithFriends.length,
        usernameClaimRate: usernameClaimRate,
        bioAdoptionRate: bioAdoptionRate,
        travelStatusAdoptionRate: travelStatusAdoptionRate,
        travelStylesAdoptionRate: travelStylesAdoptionRate,
        travelStyleShares: travelStyleShares,
        badgeTierShares: badgeTierShares,
        totalBadgesUnlocked: totalBadgesUnlocked,
      );
    } catch (e) {
      debugPrint('[AdminService] fetchDetailedAnalytics error: $e');
      return const AdminDetailedAnalytics();
    }
  }

  TravelCountry? _findCountry(String code) {
    final upper = code.toUpperCase().trim();
    for (final c in WorldCountriesData.allCountries) {
      if (c.code == upper) return c;
    }
    return null;
  }

  void _incrementContinent(Map<String, int> continentCounts, String countryCode) {
    final country = _findCountry(countryCode);
    final continent = country?.continent ?? 'Global';
    continentCounts[continent] = (continentCounts[continent] ?? 0) + 1;
  }

  List<CountryTravelMetric> _buildCountryMetrics(Map<String, int> counts, int totalUsers) {
    if (counts.isEmpty) return const [];
    final totalCount = counts.values.fold<int>(0, (acc, c) => acc + c);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(15).map((e) {
      final code = e.key;
      final count = e.value;
      final country = _findCountry(code);
      final flag = country?.flag ?? _countryCodeToFlag(code);
      final name = country?.nameTr ?? CountryLocalization.getCountryName(code, 'tr') ?? code;
      final continent = country?.continent ?? 'Global';
      final percentage = totalCount > 0 ? (count / totalCount) : 0.0;

      return CountryTravelMetric(
        countryCode: code,
        countryName: name,
        flag: flag,
        count: count,
        percentage: percentage,
        continent: continent,
      );
    }).toList();
  }

  List<ContinentShareMetric> _buildContinentMetrics(Map<String, int> continentCounts) {
    if (continentCounts.isEmpty) return const [];
    final total = continentCounts.values.fold<int>(0, (acc, c) => acc + c);
    final sorted = continentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) {
      final name = e.key;
      final count = e.value;
      final percentage = total > 0 ? (count / total) : 0.0;
      String icon = '🌍';
      if (name.contains('Europe')) icon = '🇪🇺';
      if (name.contains('Asia')) icon = '⛩️';
      if (name.contains('Americas')) icon = '🗽';
      if (name.contains('Africa')) icon = '🦁';
      if (name.contains('Oceania')) icon = '🦘';

      return ContinentShareMetric(
        continentName: name,
        icon: icon,
        count: count,
        percentage: percentage,
      );
    }).toList();
  }

  List<TransportPreferenceMetric> _buildTransportMetrics(Map<String, int> transportCounts) {
    final Map<String, List<String>> transportMeta = {
      'plane': ['Uçak', '✈️'],
      'flight': ['Uçak', '✈️'],
      'train': ['Tren', '🚆'],
      'car': ['Araba', '🚗'],
      'drive': ['Araba', '🚗'],
      'bus': ['Otobüs', '🚌'],
      'boat': ['Gemi / Vapur', '🚢'],
      'ship': ['Gemi / Vapur', '🚢'],
      'ferry': ['Feribot', '⛴️'],
    };

    final Map<String, int> normalized = {};
    transportCounts.forEach((key, val) {
      final normKey = key.toLowerCase();
      String canonical = normKey;
      if (normKey.contains('plane') || normKey.contains('flight') || normKey.contains('air')) {
        canonical = 'plane';
      } else if (normKey.contains('train') || normKey.contains('rail')) {
        canonical = 'train';
      } else if (normKey.contains('car') || normKey.contains('drive') || normKey.contains('auto')) {
        canonical = 'car';
      } else if (normKey.contains('bus')) {
        canonical = 'bus';
      } else if (normKey.contains('boat') || normKey.contains('ship') || normKey.contains('ferry')) {
        canonical = 'boat';
      }
      normalized[canonical] = (normalized[canonical] ?? 0) + val;
    });

    final total = normalized.values.fold<int>(0, (acc, c) => acc + c);
    final sorted = normalized.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) {
      final mode = e.key;
      final count = e.value;
      final meta = transportMeta[mode] ?? [mode, '🚀'];
      return TransportPreferenceMetric(
        mode: mode,
        label: meta[0],
        icon: meta[1],
        count: count,
        percentage: total > 0 ? (count / total) : 0.0,
      );
    }).toList();
  }

  List<CurrencyShareMetric> _buildCurrencyMetrics(Map<String, int> currencyCounts) {
    if (currencyCounts.isEmpty) return const [];
    final total = currencyCounts.values.fold<int>(0, (acc, c) => acc + c);
    final sorted = currencyCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(6).map((e) {
      return CurrencyShareMetric(
        currencyCode: e.key,
        count: e.value,
        percentage: total > 0 ? (e.value / total) : 0.0,
      );
    }).toList();
  }

  List<VaultCategoryShareMetric> _buildVaultCategoryMetrics(Map<String, int> vaultCategoryCounts) {
    if (vaultCategoryCounts.isEmpty) return const [];
    final total = vaultCategoryCounts.values.fold<int>(0, (acc, c) => acc + c);
    final sorted = vaultCategoryCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final Map<String, String> labels = {
      'passport': 'Pasaport',
      'visa': 'Vize',
      'ticket': 'Bilet & Uçuş',
      'booking': 'Rezervasyon & Otel',
      'insurance': 'Sigorta',
      'identity': 'Kimlik Kartı',
      'health': 'Sağlık & Aşı',
      'vehicle': 'Araç & Ehliyet',
      'privatephotos': 'Özel Kasa / Resimler',
      'private photos': 'Özel Kasa / Resimler',
      'özel resimler': 'Özel Kasa / Resimler',
      'özel kasa': 'Özel Kasa / Resimler',
      'other': 'Diğer Belgeler',
    };

    return sorted.map((e) {
      final cat = e.key;
      final label = labels[cat] ?? cat.toUpperCase();
      return VaultCategoryShareMetric(
        category: cat,
        label: label,
        count: e.value,
        percentage: total > 0 ? (e.value / total) : 0.0,
      );
    }).toList();
  }

  List<PreferenceShareMetric> _buildPreferenceMetrics(
    Map<String, int> counts,
    int totalUsers, {
    required String Function(String) labelResolver,
    required String Function(String) iconResolver,
  }) {
    if (counts.isEmpty) return const [];
    final total = counts.values.fold<int>(0, (acc, c) => acc + c);
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) {
      final key = e.key;
      return PreferenceShareMetric(
        key: key,
        label: labelResolver(key),
        icon: iconResolver(key),
        count: e.value,
        percentage: total > 0 ? (e.value / total) : 0.0,
      );
    }).toList();
  }

  static String _countryCodeToFlag(String code) {
    if (code.length != 2) return '🌐';
    final upper = code.toUpperCase();
    final first = upper.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final second = upper.codeUnitAt(1) - 0x41 + 0x1F1E6;
    if (first < 0x1F1E6 || first > 0x1F1FF || second < 0x1F1E6 || second > 0x1F1FF) {
      return '🌐';
    }
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  @override
  Future<void> toggleUserProStatus(String uid, bool isPremium) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;

    try {
      await firestore.collection('users').doc(uid).set({
        'isPremium': isPremium,
        'is_premium': isPremium,
        'isPro': isPremium,
        'pro': isPremium,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      await PreferencesService.instance.setProUser(isPremium, uid: uid);

      // Audit log recording
      String? targetEmail;
      String? targetName;
      try {
        final uDoc = await firestore.collection('users').doc(uid).get();
        if (uDoc.exists && uDoc.data() != null) {
          targetEmail = uDoc.data()!['email'] as String?;
          targetName = uDoc.data()!['displayName'] as String?;
        }
      } catch (_) {}

      await recordAuditLog(
        action: isPremium ? 'pro_grant' : 'pro_revoke',
        actionTitle: isPremium ? 'Kullanıcıya Pro Lisansı Verildi' : 'Kullanıcının Pro Lisansı Geri Alındı',
        targetUid: uid,
        targetUserEmail: targetEmail,
        targetUserName: targetName,
        details: {'isPremium': isPremium},
      );
    } catch (e) {
      debugPrint('[AdminService] toggleUserProStatus error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  }) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;

    try {
      final updates = <String, dynamic>{
        'isPremium': isPremium,
        'is_premium': isPremium,
        'isPro': isPremium,
        'pro': isPremium,
        'banStatus': banStatus,
        'banExpiresAt': banExpiresAt,
        'banReason': banReason,
        'restrictedFeatures': restrictedFeatures,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await firestore
          .collection('users')
          .doc(uid)
          .set(updates, SetOptions(merge: true));
      await PreferencesService.instance.setProUser(isPremium, uid: uid);

      // Audit log recording
      String? targetEmail;
      String? targetName;
      try {
        final uDoc = await firestore.collection('users').doc(uid).get();
        if (uDoc.exists && uDoc.data() != null) {
          targetEmail = uDoc.data()!['email'] as String?;
          targetName = uDoc.data()!['displayName'] as String?;
        }
      } catch (_) {}

      String action = 'moderate_user';
      String actionTitle = 'Kullanıcı Moderasyon Ayarları Güncellendi';
      if (banStatus == 'banned') {
        action = 'ban_user';
        actionTitle = 'Kullanıcı Kalıcı Olarak Engellendi';
      } else if (banStatus == 'temporary') {
        action = 'ban_user';
        actionTitle = 'Kullanıcı Geçici Olarak Engellendi';
      } else if (banStatus == 'none' && restrictedFeatures.isNotEmpty) {
        action = 'restrict_feature';
        actionTitle = 'Kullanıcı Özellik Kısıtlamaları Güncellendi';
      } else if (banStatus == 'none') {
        action = 'unban_user';
        actionTitle = 'Kullanıcı Engeli Kaldırıldı';
      }

      await recordAuditLog(
        action: action,
        actionTitle: actionTitle,
        targetUid: uid,
        targetUserEmail: targetEmail,
        targetUserName: targetName,
        details: {
          'banStatus': banStatus,
          'banReason': banReason ?? '',
          'banExpiresAt': banExpiresAt ?? '',
          'restrictedFeatures': restrictedFeatures,
          'isPremium': isPremium,
        },
      );
    } catch (e) {
      debugPrint('[AdminService] updateUserModeration error: $e');
      rethrow;
    }
  }

  @override
  Future<List<VaultDocument>> fetchUserDocuments(String uid) async {
    final firestore = _effectiveFirestore;
    final docs = <VaultDocument>[];

    if (firestore != null) {
      try {
        final queryResults = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
        try {
          final s1 = await firestore
              .collection('documents')
              .where('user_id', isEqualTo: uid)
              .get();
          for (final d in s1.docs) {
            queryResults[d.id] = d;
          }
        } catch (_) {}
        try {
          final s2 = await firestore
              .collection('documents')
              .where('userId', isEqualTo: uid)
              .get();
          for (final d in s2.docs) {
            queryResults[d.id] = d;
          }
        } catch (_) {}

        for (final d in queryResults.values) {
          try {
            final data = Map<String, dynamic>.from(d.data());
            data['id'] = (data['id'] != null && data['id'].toString().isNotEmpty) ? data['id'] : d.id;
            data['user_id'] = data['user_id'] ?? data['userId'] ?? uid;
            data['userId'] = data['userId'] ?? data['user_id'] ?? uid;
            final doc = VaultDocument.fromJson(data);
            if (!doc.isDeleted) {
              docs.add(doc);
            }
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserDocuments firestore error: $e');
      }
    }

    // Always merge local documents for this user (if on same device or local testing)
    try {
      final localDocs = await DatabaseHelper.instance.getDocuments(userId: uid);
      final existingIds = docs.map((d) => d.id).toSet();
      for (final d in localDocs) {
        if (!d.isDeleted && !existingIds.contains(d.id)) {
          docs.add(d);
        }
      }
    } catch (e) {
      debugPrint('[AdminService] fetchUserDocuments local merge notice: $e');
    }

    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs;
  }

  @override
  Future<Uint8List?> viewUserDocumentDecrypted({
    required String targetUserId,
    required VaultDocument doc,
  }) async {
    // 1. Immutable Audit log in admin_audit_logs
    await recordAuditLog(
      action: 'view_vault_document',
      actionTitle: 'Kasa Belgesi İnceleme',
      targetUid: targetUserId,
      details: {
        'documentId': doc.id,
        'title': doc.title,
        'category': doc.category,
        'isPrivate': doc.isPrivate,
        'storagePath': doc.storagePath,
        'fileSizeBytes': doc.fileSize,
        'fileType': doc.fileType,
      },
    );

    try {
      TelemetryService.instance.logAdminAction(
        action: 'view_vault_document',
        targetUid: targetUserId,
        details: {
          'documentId': doc.id,
          'title': doc.title,
          'isPrivate': doc.isPrivate,
        },
      );
    } catch (_) {}

    // 2. Owner's escrowed AES key. Firestore rules allow this read only for the owner and a
    //    verified admin; the key is never generated, escrowed or stored on the admin device.
    final userKey = await SecurityService.instance.fetchUserEscrowKeyAsAdmin(targetUserId);

    Uint8List? rawBytes;
    final effectiveDocId = doc.id.isNotEmpty ? doc.id : p.basenameWithoutExtension(doc.localImagePath);

    // 3. Encrypted blob from Firebase Storage (rules: owner or verified admin may read)
    final storagePath = (doc.storagePath != null && doc.storagePath!.isNotEmpty)
        ? doc.storagePath!
        : 'users/$targetUserId/vault/$effectiveDocId.bin';
    if (_isFirebaseReady) {
      try {
        rawBytes = await FirebaseStorage.instance.ref(storagePath).getData(12 * 1024 * 1024);
      } catch (storageErr) {
        debugPrint('[AdminService] Storage download notice for $storagePath: $storageErr');
      }
    }

    // 4. Legacy (pre-v1.0) payloads still present on older documents: inline base64 / chunks
    if ((rawBytes == null || rawBytes.isEmpty) && doc.cloudDataBase64 != null && doc.cloudDataBase64!.isNotEmpty) {
      rawBytes = _decodeBase64Payload(doc.cloudDataBase64!);
    }
    final firestore = _effectiveFirestore;
    if ((rawBytes == null || rawBytes.isEmpty) && effectiveDocId.isNotEmpty && firestore != null) {
      try {
        final chunksSnap = await firestore.collection('documents').doc(effectiveDocId).collection('chunks').get();
        if (chunksSnap.docs.isNotEmpty) {
          final sorted = chunksSnap.docs.toList()
            ..sort((a, b) => ((a.data()['index'] as num?)?.toInt() ?? 0)
                .compareTo((b.data()['index'] as num?)?.toInt() ?? 0));
          final buf = StringBuffer();
          for (final c in sorted) {
            final part = c.data()['chunk'] as String?;
            if (part != null) buf.write(part);
          }
          if (buf.isNotEmpty) rawBytes = _decodeBase64Payload(buf.toString());
        }
      } catch (_) {}
    }

    if (rawBytes == null || rawBytes.isEmpty) {
      return null;
    }

    // 5. Decrypt: AES-GCM (PBENC2) with exactly the owner's key; legacy AES-CBC (PBENC1) also tries
    //    the historical deterministic seeds of the owner. No userId is passed, so the admin device
    //    never resolves or creates a key for the target account.
    return SecurityService.instance.decryptBytes(
      rawBytes,
      candidateKey: userKey,
      extraSeeds: [targetUserId, if (doc.userId.isNotEmpty) doc.userId],
    );
  }

  static Uint8List? _decodeBase64Payload(String payload) {
    try {
      var clean = payload.trim();
      if (clean.contains(',')) clean = clean.split(',').last;
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Trip>> fetchUserTrips(String uid) async {
    final firestore = _effectiveFirestore;
    final trips = <Trip>[];

    if (firestore != null) {
      try {
        var snapshot = await firestore
            .collection('trips')
            .where('user_id', isEqualTo: uid)
            .get();
        if (snapshot.docs.isEmpty) {
          snapshot = await firestore
              .collection('trips')
              .where('userId', isEqualTo: uid)
              .get();
        }
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            final isDel = data['is_deleted'] == 1 || data['is_deleted'] == true || data['isDeleted'] == true;
            if (!isDel) {
              trips.add(Trip.fromMap(data));
            }
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserTrips firestore error: $e');
      }
    }

    if (trips.isEmpty) {
      try {
        final localTrips = await DatabaseHelper.instance.getTrips(userId: uid);
        for (final t in localTrips) {
          if (!t.isDeleted) {
            trips.add(t);
          }
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserTrips local error: $e');
      }
    }

    trips.sort((a, b) => b.startDate.compareTo(a.startDate));
    return trips;
  }

  @override
  Future<List<Expense>> fetchUserExpenses(String uid) async {
    final firestore = _effectiveFirestore;
    final expenses = <Expense>[];

    if (firestore != null) {
      try {
        var snapshot = await firestore
            .collection('expenses')
            .where('user_id', isEqualTo: uid)
            .get();
        if (snapshot.docs.isEmpty) {
          snapshot = await firestore
              .collection('expenses')
              .where('userId', isEqualTo: uid)
              .get();
        }
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            final isDel = data['is_deleted'] == 1 || data['is_deleted'] == true || data['isDeleted'] == true;
            if (!isDel) {
              expenses.add(Expense.fromMap(data));
            }
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserExpenses firestore error: $e');
      }
    }

    if (expenses.isEmpty) {
      try {
        final localExpenses = await DatabaseHelper.instance.getExpenses(userId: uid);
        for (final e in localExpenses) {
          if (!e.isDeleted) {
            expenses.add(e);
          }
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserExpenses local error: $e');
      }
    }

    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<List<AdminUserSessionLog>> fetchUserSessions(String uid) async {
    final firestore = _effectiveFirestore;
    final logs = <AdminUserSessionLog>[];

    if (firestore != null) {
      try {
        final snap = await firestore
            .collection('users')
            .doc(uid)
            .collection('sessions')
            .orderBy('timestamp', descending: true)
            .limit(200)
            .get();
        for (final d in snap.docs) {
          try {
            logs.add(AdminUserSessionLog.fromMap(d.data()));
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserSessions firestore error: $e');
      }
    }

    if (logs.isEmpty) {
      try {
        final localLogs = PreferencesService.instance.getSessionLogs(uid: uid);
        for (final m in localLogs) {
          logs.add(AdminUserSessionLog.fromMap(m));
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserSessions local error: $e');
      }
    }

    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  @override
  Future<List<TravelCountry>> fetchUserTravelCountries(String uid) async {
    final firestore = _effectiveFirestore;
    final Map<String, dynamic> rawCountryMap = {};

    // 1. Fetch from Firestore users/{uid}.travelMapCountries
    if (firestore != null) {
      try {
        final userDoc = await firestore.collection('users').doc(uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          if (data['travelMapCountries'] is Map) {
            final tMap = Map<String, dynamic>.from(data['travelMapCountries'] as Map);
            for (final e in tMap.entries) {
              rawCountryMap[e.key.toUpperCase().trim()] = e.value;
            }
          }
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserTravelCountries user doc error: $e');
      }

      // 2. Fetch from Firestore travel_map collection filtered strictly by user_id
      try {
        var snap = await firestore
            .collection('travel_map')
            .where('user_id', isEqualTo: uid)
            .get();
        if (snap.docs.isEmpty) {
          snap = await firestore
              .collection('travel_map')
              .where('userId', isEqualTo: uid)
              .get();
        }
        for (final doc in snap.docs) {
          final d = doc.data();
          final isDel = d['is_deleted'] == 1 || d['is_deleted'] == true || d['isDeleted'] == true;
          if (isDel) continue;
          final code = (d['code'] ?? d['country_code'] ?? '').toString().toUpperCase().trim();
          if (code.isNotEmpty) {
            rawCountryMap[code] = {
              'status': d['status'] ?? 'visited',
              'visitedDate': d['visited_date'] ?? d['visitedDate'],
              'notes': d['notes'],
            };
          }
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserTravelCountries travel_map collection error: $e');
      }
    }

    // 3. Fallback: local SQLite filtered strictly by this user's UID (no empty/guest rows)
    if (rawCountryMap.isEmpty) {
      try {
        final localRows = await DatabaseHelper.instance.getTravelMapCountries(userId: uid);
        for (final row in localRows) {
          final code = (row['country_code'] ?? '').toString().toUpperCase().trim();
          if (code.isNotEmpty) {
            rawCountryMap[code] = {
              'status': row['status'] ?? 'visited',
              'visitedDate': row['visited_date'],
              'notes': row['notes'],
            };
          }
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserTravelCountries local SQLite error: $e');
      }
    }

    // 4. Fallback: user-scoped SharedPreferences
    if (rawCountryMap.isEmpty) {
      try {
        final rawJson = PreferencesService.instance.getScopedTravelCountriesJson(uid);
        if (rawJson != null && rawJson.isNotEmpty) {
          final decoded = jsonDecode(rawJson);
          if (decoded is Map) {
            for (final e in decoded.entries) {
              rawCountryMap[e.key.toString().toUpperCase().trim()] = e.value;
            }
          }
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserTravelCountries scoped prefs error: $e');
      }
    }

    // 5. Map entries into WorldCountriesData.allCountries strictly for this user
    return WorldCountriesData.allCountries.map((c) {
      final codeUpper = c.code.toUpperCase().trim();
      final userEntry = rawCountryMap[codeUpper];
      if (userEntry == null) return c;

      String statusStr = '';
      DateTime? vDate;
      String? notes;

      if (userEntry is Map) {
        statusStr = (userEntry['status'] ?? '').toString().toLowerCase().trim();
        final rawDate = userEntry['visitedDate'] ?? userEntry['visited_date'];
        if (rawDate is int) {
          vDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
        } else if (rawDate is String) {
          vDate = DateTime.tryParse(rawDate);
        }
        notes = userEntry['notes']?.toString();
      } else if (userEntry is String) {
        statusStr = userEntry.toLowerCase().trim();
      }

      CountryStatus status = CountryStatus.none;
      if (statusStr.contains('visited') || statusStr == 'gezilen' || statusStr == 'gezi') {
        status = CountryStatus.visited;
      } else if (statusStr.contains('wish') || statusStr == 'hedef' || statusStr == 'istek') {
        status = CountryStatus.wishlist;
      } else if (statusStr.contains('lived') || statusStr == 'yasayan') {
        status = CountryStatus.lived;
      }

      if (status == CountryStatus.none) {
        return c;
      }

      return c.copyWith(
        status: status,
        visitedDate: vDate,
        notes: notes,
      );
    }).toList();
  }

  @override
  Future<List<FriendUserSummary>> fetchUserFriends(String uid) async {
    if (uid.isEmpty) return const [];
    final firestore = _effectiveFirestore;
    if (firestore == null) return const [];

    try {
      final query = await firestore
          .collection('friendships')
          .where('users', arrayContains: uid)
          .where('status', isEqualTo: 'accepted')
          .get();

      final List<FriendUserSummary> friends = [];
      for (final doc in query.docs) {
        final data = doc.data();
        final users = (data['users'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final otherUid = users.firstWhere((u) => u != uid, orElse: () => '');
        if (otherUid.isNotEmpty) {
          final userDoc = await firestore.collection('users').doc(otherUid).get();
          if (userDoc.exists && userDoc.data() != null) {
            friends.add(FriendUserSummary.fromMap(userDoc.data()!, fallbackUid: otherUid));
          } else {
            friends.add(FriendUserSummary(uid: otherUid, displayName: 'Traveler ($otherUid)'));
          }
        }
      }
      return friends;
    } catch (e) {
      debugPrint('[AdminService] fetchUserFriends error: $e');
      return const [];
    }
  }

  @override
  Future<({List<FriendRequestItem> incoming, List<FriendRequestItem> outgoing})> fetchUserFriendRequests(String uid) async {
    if (uid.isEmpty) {
      return (incoming: <FriendRequestItem>[], outgoing: <FriendRequestItem>[]);
    }
    final firestore = _effectiveFirestore;
    if (firestore == null) {
      return (incoming: <FriendRequestItem>[], outgoing: <FriendRequestItem>[]);
    }

    try {
      final query = await firestore
          .collection('friendships')
          .where('users', arrayContains: uid)
          .where('status', isEqualTo: 'pending')
          .get();

      final List<FriendRequestItem> incoming = [];
      final List<FriendRequestItem> outgoing = [];

      for (final doc in query.docs) {
        final friendship = Friendship.fromMap(doc.data(), docId: doc.id);
        final isIncoming = friendship.receiverId == uid;
        final otherUid = isIncoming ? friendship.requesterId : friendship.receiverId;

        if (otherUid.isNotEmpty) {
          final userDoc = await firestore.collection('users').doc(otherUid).get();
          final summary = (userDoc.exists && userDoc.data() != null)
              ? FriendUserSummary.fromMap(userDoc.data()!, fallbackUid: otherUid)
              : FriendUserSummary(uid: otherUid, displayName: 'Traveler ($otherUid)');

          final item = FriendRequestItem(
            friendshipId: friendship.id,
            user: summary,
            isIncoming: isIncoming,
            createdAt: friendship.createdAt,
          );
          if (isIncoming) {
            incoming.add(item);
          } else {
            outgoing.add(item);
          }
        }
      }
      return (incoming: incoming, outgoing: outgoing);
    } catch (e) {
      debugPrint('[AdminService] fetchUserFriendRequests error: $e');
      return (incoming: <FriendRequestItem>[], outgoing: <FriendRequestItem>[]);
    }
  }

  @override
  Future<bool> removeUserFriendship(String currentUid, String targetUid) async {
    if (currentUid.isEmpty || targetUid.isEmpty) return false;
    final firestore = _effectiveFirestore;
    if (firestore == null) return true;

    try {
      final docId = Friendship.generateId(currentUid, targetUid);
      await firestore.collection('friendships').doc(docId).delete();
      await recordAuditLog(
        action: 'friendship_deleted',
        actionTitle: 'Arkadaşlık Bağlantısı Silindi',
        targetUid: currentUid,
        details: {'otherUid': targetUid},
      );
      return true;
    } catch (e) {
      debugPrint('[AdminService] removeUserFriendship error: $e');
      return false;
    }
  }

  @override
  Future<void> deleteUserDocumentAsAdmin({
    required String uid,
    required String documentId,
  }) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;
    try {
      await firestore.collection('documents').doc(documentId).set({
        'is_deleted': true,
        'isDeleted': true,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      await recordAuditLog(
        action: 'delete_document',
        actionTitle: 'Kullanıcı Kasa Belgesi Silindi',
        targetUid: uid,
        details: {'documentId': documentId},
      );

      TelemetryService.instance.logAdminAction(
        action: 'delete_user_document',
        targetUid: uid,
        details: {'documentId': documentId},
      );
    } catch (e) {
      debugPrint('[AdminService] deleteUserDocumentAsAdmin error: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;
    try {
      await firestore.collection('users').doc(uid).set({
        'deletionStatus': 'none',
        'deletionRequestedAt': null,
        'scheduledPermanentDeletionAt': null,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      await recordAuditLog(
        action: 'cancel_deletion',
        actionTitle: 'Hesap Silme Talebi İptal Edildi',
        targetUid: uid,
      );

      TelemetryService.instance.logAdminAction(
        action: 'cancel_account_deletion',
        targetUid: uid,
      );
    } catch (e) {
      debugPrint('[AdminService] cancelAccountDeletionAsAdmin error: $e');
      rethrow;
    }
  }

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;
    try {
      // 1. Fetch user snapshot first to preserve details for audit logging
      String targetEmail = '';
      String targetName = '';
      try {
        final uDoc = await firestore.collection('users').doc(uid).get();
        if (uDoc.exists && uDoc.data() != null) {
          final d = uDoc.data()!;
          targetEmail = (d['email'] as String?) ?? '';
          targetName = (d['displayName'] as String?) ?? '';
        }
      } catch (_) {}

      // 2. Delete linked collections
      final collections = ['trips', 'expenses', 'checklist_items', 'documents'];
      for (final coll in collections) {
        try {
          final snap = await firestore.collection(coll).where('user_id', isEqualTo: uid).get();
          for (final doc in snap.docs) {
            if (coll == 'documents') {
              try {
                final chunksSnap = await doc.reference.collection('chunks').get();
                for (final c in chunksSnap.docs) {
                  await c.reference.delete();
                }
              } catch (_) {}
            }
            await doc.reference.delete();
          }
        } catch (_) {}
      }

      // Also clean feedback linked to this user
      try {
        final fbSnap1 = await firestore.collection('feedback').where('user_id', isEqualTo: uid).get();
        for (final doc in fbSnap1.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}
      try {
        final fbSnap2 = await firestore.collection('feedback').where('userId', isEqualTo: uid).get();
        for (final doc in fbSnap2.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      // 3. Delete user subcollections
      final subcollections = ['notifications', 'sessions', 'vault_documents'];
      for (final sub in subcollections) {
        try {
          final subSnap = await firestore.collection('users').doc(uid).collection(sub).get();
          for (final doc in subSnap.docs) {
            await doc.reference.delete();
          }
        } catch (_) {}
      }

      // 4. Delete the root user document completely from Firestore & clean up escrow key!
      await firestore.collection('users').doc(uid).delete();
      try {
        await firestore.collection('vault_keys').doc(uid).delete();
      } catch (_) {}
      try {
        await SecurityService.instance.deleteUserEscrowKey(uid);
      } catch (_) {}

      // 5. Record real persistent audit log
      await recordAuditLog(
        action: 'purge_user',
        actionTitle: 'Kullanıcı ve Tüm Verileri Kalıcı Olarak Silindi',
        targetUid: uid,
        targetUserEmail: targetEmail.isNotEmpty ? targetEmail : null,
        targetUserName: targetName.isNotEmpty ? targetName : null,
        details: {
          'reason': 'Yönetici tarafından kalıcı silindi',
          'deletedCollections': [
            'trips',
            'expenses',
            'checklist_items',
            'documents',
            'feedback',
            'notifications',
            'sessions',
            'vault_documents',
          ],
          'purgedAt': DateTime.now().toIso8601String(),
        },
      );

      TelemetryService.instance.logAdminAction(
        action: 'purge_user_data',
        targetUid: uid,
      );
    } catch (e) {
      debugPrint('[AdminService] purgeUserDataAsAdmin error: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendInactivityWarningEmail(String uid) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;

    final userDoc = await firestore.collection('users').doc(uid).get();
    if (!userDoc.exists || userDoc.data() == null) return;

    final data = userDoc.data()!;
    final email = data['email'] as String? ?? '';
    final displayName = data['displayName'] as String? ?? '';
    final lastActiveRaw = data['lastActiveAt'] ?? data['lastLoginAt'] ?? data['createdAt'];
    DateTime lastActive = DateTime.now();
    if (lastActiveRaw is Timestamp) lastActive = lastActiveRaw.toDate();
    if (lastActiveRaw is String) lastActive = DateTime.tryParse(lastActiveRaw) ?? lastActive;
    if (lastActiveRaw is int) lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveRaw);

    final inactiveDays = DateTime.now().toUtc().difference(lastActive.toUtc()).inDays;
    final remainingDays = (180 - inactiveDays).clamp(1, 30);
    final count = (data['inactivityWarningCount'] as num?)?.toInt() ?? 0;
    final newCount = count + 1;
    final nowUtc = DateTime.now().toUtc();

    if (email.isNotEmpty) {
      final l10n = appL10nFor(_emailLanguageOf(data));
      final name = displayName.isNotEmpty ? displayName : l10n.emailDefaultName;
      final safeName = EmailDispatchService.escapeHtml(name);
      await firestore.collection('mail').add({
        'to': [email],
        'message': {
          'subject': l10n.emailInactivitySubject(remainingDays, newCount),
          'text': '${l10n.emailGreeting(name)}\n\n'
              '${l10n.emailInactivityIntro}\n\n'
              '${l10n.emailInactivityPolicy}\n\n'
              '${l10n.emailInactivityRemaining(remainingDays)}\n\n'
              '${l10n.emailInactivityAction}\n\n'
              '${l10n.emailSignoff}\n${l10n.emailTeamSignature}',
          'html': '''
            <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 16px; background-color: #ffffff;">
              <h2 style="color: #ea580c; margin-top: 0;">${l10n.emailInactivityHeading}</h2>
              <p>${l10n.emailGreeting('<strong>$safeName</strong>')}</p>
              <p>${l10n.emailInactivityIntro}</p>
              <div style="background-color: #fff7ed; border-left: 4px solid #ea580c; padding: 14px; margin: 18px 0; border-radius: 8px;">
                <p style="margin: 0; color: #9a3412; font-weight: bold; font-size: 15px;">
                  ⏳ ${l10n.emailInactivityRemaining(remainingDays)}
                </p>
                <p style="margin: 6px 0 0 0; color: #c2410c; font-size: 13px;">
                  ${l10n.emailInactivityNoticeCount(newCount)}
                </p>
              </div>
              <p style="color: #334155; line-height: 1.5;">
                ${l10n.emailInactivityPolicy}
              </p>
              <p style="color: #0f172a; font-weight: 600;">
                ${l10n.emailInactivityCta}
              </p>
              <p style="color: #64748b; font-size: 13px;">
                ${l10n.emailInactivityAction}
              </p>
              <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 24px 0;" />
              <p style="font-size: 12px; color: #94a3b8; margin-bottom: 0;">${l10n.emailInactivityFooter}</p>
            </div>
          ''',
        },
        'type': 'inactivity_warning_5th_month',
        'targetUid': uid,
        'inactiveDays': inactiveDays,
        'warningNumber': newCount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await firestore.collection('users').doc(uid).set({
      'lastInactivityWarningAt': nowUtc.toIso8601String(),
      'inactivityWarningCount': newCount,
      'updatedAt': nowUtc.toIso8601String(),
    }, SetOptions(merge: true));

    TelemetryService.instance.logAdminAction(
      action: 'send_inactivity_warning_email',
      targetUid: uid,
    );
  }

  @override
  Future<bool> sendUserWarning({
    required String uid,
    required String title,
    required String message,
    required String warningType,
    bool sendInAppNotification = true,
    bool sendEmail = true,
  }) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return false;

    try {
      final userDoc = await firestore.collection('users').doc(uid).get();
      final data = userDoc.exists && userDoc.data() != null ? userDoc.data()! : <String, dynamic>{};
      
      final currentUid = _effectiveAuth?.currentUser?.uid;
      final email = (data['email'] as String?)?.isNotEmpty == true
          ? (data['email'] as String)
          : (currentUid == uid ? _effectiveAuth?.currentUser?.email ?? '' : '');
      final displayName = (data['displayName'] as String?)?.isNotEmpty == true
          ? (data['displayName'] as String)
          : (currentUid == uid ? _effectiveAuth?.currentUser?.displayName ?? '' : '');
      final nowTimestamp = DateTime.now().millisecondsSinceEpoch;
      final nowIso = DateTime.now().toIso8601String();

      // 1. In-App Notification (users/{uid}/notifications subcollection and latestAdminWarning field)
      if (sendInAppNotification) {
        DocumentReference<Map<String, dynamic>>? notifRef;
        try {
          notifRef = await firestore.collection('users').doc(uid).collection('notifications').add({
            'title': title,
            'message': message,
            'type': warningType,
            'timestamp': nowTimestamp,
            'createdAt': FieldValue.serverTimestamp(),
            'read': false,
          });
        } catch (subErr) {
          debugPrint('[AdminService] Error saving to notifications subcollection: $subErr');
        }

        final warningPayload = {
          'id': notifRef?.id ?? '$nowTimestamp',
          'title': title,
          'message': message,
          'type': warningType,
          'timestamp': nowTimestamp,
          'createdAt': nowIso,
        };

        final Map<String, dynamic> userUpdate = {
          'latestAdminWarning': warningPayload,
          'updatedAt': nowIso,
        };

        // If warning is addressed to the active admin user on this device, mark it seen in cloud immediately
        if (currentUid == uid) {
          userUpdate['lastSeenAdminWarningAt'] = nowTimestamp;
        }

        await firestore.collection('users').doc(uid).set(userUpdate, SetOptions(merge: true));

        // If warning is addressed to the active local user on this device, immediately trigger local notification & history!
        if (currentUid == uid) {
          final notifId = notifRef?.id ?? '$nowTimestamp';
          await PreferencesService.instance.markNotificationDelivered(notifId);
          final recordJson = jsonEncode({
            'id': notifId,
            'title': title,
            'body': message,
            'timestamp': nowTimestamp,
            'type': 'admin_warning',
          });
          await PreferencesService.instance.addNotificationHistoryItem(recordJson);
          await PreferencesService.instance.setLastSeenAdminWarningAt(nowTimestamp, uid: uid);
          try {
            await LocalNotificationService().showInstantNotification(
              id: (nowTimestamp % 1000000000).abs(),
              title: title,
              body: message,
              payload: 'admin_warning:$notifId',
            );
          } catch (e) {
            debugPrint('[AdminService] Local notification dispatch error: $e');
          }
        }
      }

      // 2. Email Delivery (mail collection)
      if (sendEmail && email.isNotEmpty) {
        final emailLang = _emailLanguageOf(data);
        final emailSubject = EmailDispatchService.instance.formatWarningEmailSubject(
          title: title,
          languageCode: emailLang,
        );
        final emailText = EmailDispatchService.instance.formatWarningEmailText(
          displayName: displayName,
          title: title,
          message: message,
          languageCode: emailLang,
        );
        final emailHtml = EmailDispatchService.instance.formatWarningEmailHtml(
          displayName: displayName,
          title: title,
          message: message,
          languageCode: emailLang,
        );

        try {
          await firestore.collection('mail').add({
            'to': [email],
            'message': {
              'subject': emailSubject,
              'text': emailText,
              'html': emailHtml,
            },
            'type': 'admin_custom_warning',
            'warningType': warningType,
            'targetUid': uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (mailErr) {
          debugPrint('[AdminService] Error queueing to mail collection: $mailErr');
        }

        try {
          await firestore.collection('users').doc(uid).set({
            'lastWarningEmailQueuedAt': nowIso,
            'lastWarningEmailSubject': emailSubject,
          }, SetOptions(merge: true));
        } catch (_) {}
      }

      // If warningType is inactivity, also update inactivity metrics
      if (warningType == 'inactivity') {
        await firestore.collection('users').doc(uid).set({
          'inactivityWarningCount': FieldValue.increment(1),
          'lastInactivityWarningAt': FieldValue.serverTimestamp(),
          'updatedAt': nowIso,
        }, SetOptions(merge: true));
      }

      await recordAuditLog(
        action: 'send_warning',
        actionTitle: 'Kullanıcıya Yönetici Uyarısı Gönderildi: $title',
        targetUid: uid,
        targetUserEmail: email.isNotEmpty ? email : null,
        targetUserName: displayName.isNotEmpty ? displayName : null,
        details: {
          'warningType': warningType,
          'message': message,
          'sentEmail': sendEmail,
          'sentInApp': sendInAppNotification,
        },
      );

      TelemetryService.instance.logAdminAction(
        action: 'send_user_warning',
        targetUid: uid,
      );

      return true;
    } catch (e) {
      debugPrint('[AdminService] sendUserWarning error: $e');
      return false;
    }
  }

  @override
  Future<bool> sendBroadcastAnnouncement({
    required String title,
    required String message,
    String type = 'discount',
    String targetAction = 'paywall',
    String targetAudience = 'all',
    int? discountPercent,
    String? actionLabel,
  }) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) {
      debugPrint('[AdminService] Firestore not initialized for broadcast.');
      return false;
    }

    try {
      final now = DateTime.now();
      final adminUser = _effectiveAuth?.currentUser;
      final sentBy = adminUser?.email ?? kAdminEmail;

      final docRef = await firestore.collection('broadcast_announcements').add({
        'title': title,
        'message': message,
        'type': type,
        'targetAction': targetAction,
        'targetAudience': targetAudience,
        'discountPercent': discountPercent,
        'actionLabel': actionLabel,
        'active': true,
        'sentBy': sentBy,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': now.millisecondsSinceEpoch,
      });

      // Update doc with its generated ID
      await docRef.set({'id': docRef.id}, SetOptions(merge: true));

      // Also publish a global latest broadcast signal to trigger active client listeners
      await firestore.collection('system_announcements').doc('latest').set({
        'id': docRef.id,
        'title': title,
        'message': message,
        'type': type,
        'targetAction': targetAction,
        'targetAudience': targetAudience,
        'discountPercent': discountPercent,
        'active': true,
        'timestamp': now.millisecondsSinceEpoch,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If active admin user on this device matches audience, mark delivered immediately so no duplicate
      await PreferencesService.instance.markNotificationDelivered(docRef.id);

      await recordAuditLog(
        action: 'broadcast_sent',
        actionTitle: 'Toplu Kampanya / Duyuru Gönderildi: $title',
        targetUid: 'broadcast_all',
        details: {
          'type': type,
          'targetAudience': targetAudience,
          'targetAction': targetAction,
          'discountPercent': discountPercent,
          'actionLabel': actionLabel,
          'broadcastId': docRef.id,
        },
      );

      TelemetryService.instance.logAdminAction(
        action: 'send_broadcast_announcement',
        targetUid: 'ALL_USERS',
      );

      return true;
    } catch (e) {
      debugPrint('[AdminService] sendBroadcastAnnouncement error: $e');
      return false;
    }
  }

  @override
  Future<List<BroadcastAnnouncement>> fetchBroadcastAnnouncements() async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return [];

    try {
      final snap = await firestore
          .collection('broadcast_announcements')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snap.docs
          .map((doc) => BroadcastAnnouncement.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('[AdminService] fetchBroadcastAnnouncements error: $e');
      return [];
    }
  }

  @override
  Future<bool> toggleBroadcastActive(String broadcastId, bool active) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return false;

    try {
      await firestore.collection('broadcast_announcements').doc(broadcastId).set({
        'active': active,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      TelemetryService.instance.logAdminAction(
        action: 'toggle_broadcast_active',
        targetUid: broadcastId,
      );
      return true;
    } catch (e) {
      debugPrint('[AdminService] toggleBroadcastActive error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteBroadcastAnnouncement(String broadcastId) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return false;

    try {
      await firestore.collection('broadcast_announcements').doc(broadcastId).delete();
      TelemetryService.instance.logAdminAction(
        action: 'delete_broadcast_announcement',
        targetUid: broadcastId,
      );
      return true;
    } catch (e) {
      debugPrint('[AdminService] deleteBroadcastAnnouncement error: $e');
      return false;
    }
  }

  @override
  Future<void> recordAuditLog({
    required String action,
    required String actionTitle,
    required String targetUid,
    String? targetUserEmail,
    String? targetUserName,
    Map<String, dynamic> details = const {},
  }) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;

    try {
      final now = DateTime.now();
      final adminEmail = _effectiveAuth?.currentUser?.email ?? kAdminEmail;
      final docRef = firestore.collection('admin_audit_logs').doc();
      final log = AdminAuditLog(
        id: docRef.id,
        action: action,
        actionTitle: actionTitle,
        adminEmail: adminEmail,
        targetUid: targetUid,
        targetUserEmail: targetUserEmail,
        targetUserName: targetUserName,
        details: details,
        timestamp: now,
      );
      await docRef.set(log.toMap());
    } catch (e) {
      debugPrint('[AdminService] recordAuditLog error: $e');
    }
  }

  @override
  Future<List<AdminAuditLog>> fetchAuditLogs({int limit = 100}) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return const [];

    try {
      final snap = await firestore
          .collection('admin_audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snap.docs
          .map((doc) => AdminAuditLog.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // Fallback in case of index creation or mock environment
      try {
        final snap = await firestore
            .collection('admin_audit_logs')
            .limit(limit)
            .get();
        final list = snap.docs
            .map((doc) => AdminAuditLog.fromMap(doc.data(), doc.id))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      } catch (e2) {
        debugPrint('[AdminService] fetchAuditLogs error: $e2');
        return const [];
      }
    }
  }

  @override
  Future<DeletedAccountsSummary> fetchDeletedAccountsArchive() async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return const DeletedAccountsSummary();
    try {
      final snap = await firestore
          .collection('deleted_accounts_archive')
          .orderBy('deletedAt', descending: true)
          .limit(100)
          .get();

      if (snap.docs.isEmpty) return const DeletedAccountsSummary();

      int total = snap.docs.length;
      int totalTrips = 0;
      int totalItems = 0;
      int totalExpenses = 0;
      int proCount = 0;
      final locales = <String, int>{};
      final items = <DeletedAccountArchiveItem>[];

      for (final doc in snap.docs) {
        final item = DeletedAccountArchiveItem.fromMap(doc.id, doc.data());
        items.add(item);
        totalTrips += item.tripCount;
        totalItems += item.itemCount;
        totalExpenses += item.expenseCount;
        if (item.isPro) proCount++;
        locales[item.locale] = (locales[item.locale] ?? 0) + 1;
      }

      return DeletedAccountsSummary(
        totalDeleted: total,
        avgTripsBeforeDeletion: total > 0 ? (totalTrips / total) : 0.0,
        avgItemsBeforeDeletion: total > 0 ? (totalItems / total) : 0.0,
        avgExpensesBeforeDeletion: total > 0 ? (totalExpenses / total) : 0.0,
        proUserPercentage: total > 0 ? (proCount / total) * 100 : 0.0,
        localeDistribution: locales,
        recentItems: items,
      );
    } catch (e) {
      debugPrint('[AdminService] fetchDeletedAccountsArchive notice: $e');
      return const DeletedAccountsSummary();
    }
  }

  @override
  Future<InactivityScanResult> processInactivityPolicies() async {
    final users = await _fetchInactivityCandidates();
    final now = DateTime.now().toUtc();
    int warnings = 0;
    int purged = 0;
    final warningEmails = <String>[];
    final purgedEmails = <String>[];

    for (final user in users) {
      if (user.email.trim().toLowerCase() == kAdminEmail) continue;

      final diffDays = now.difference(user.effectiveLastActiveAt.toUtc()).inDays;

      // 1. Rule: 6 Months (>= 180 days) Inactive -> Permanent Auto-Purge
      if (diffDays >= 180) {
        try {
          await purgeUserDataAsAdmin(user.uid);
          purged++;
          purgedEmails.add(user.email.isNotEmpty ? user.email : user.uid);

          final firestore = _effectiveFirestore;
          if (firestore != null && user.email.isNotEmpty) {
            final l10n = appL10nFor(user.appLanguage.isNotEmpty ? user.appLanguage : 'en');
            final name = user.displayName.isNotEmpty ? user.displayName : l10n.emailDefaultName;
            await firestore.collection('mail').add({
              'to': [user.email],
              'message': {
                'subject': l10n.emailPurgedSubject,
                'text': '${l10n.emailGreeting(name)}\n\n'
                    '${l10n.emailPurgedBody}\n\n'
                    '${l10n.emailTeamSignature}',
              },
              'type': 'inactivity_purged_6_months',
              'targetUid': user.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          debugPrint('[AdminService] Error auto-purging user ${user.uid}: $e');
        }
      }
      // 2. Rule: 5th Month (>= 150 days && < 180 days) Inactive -> Weekly Warning Email
      else if (diffDays >= 150) {
        final lastWarning = user.lastInactivityWarningAt;
        final isDue = lastWarning == null || now.difference(lastWarning.toUtc()).inDays >= 7;

        if (isDue) {
          try {
            await sendInactivityWarningEmail(user.uid);
            warnings++;
            warningEmails.add(user.email.isNotEmpty ? user.email : user.uid);
          } catch (e) {
            debugPrint('[AdminService] Error sending warning email to ${user.uid}: $e');
          }
        }
      }
    }

    if (purged > 0 || warnings > 0) {
      await recordAuditLog(
        action: 'inactivity_scan',
        actionTitle: 'Otomatik İnaktiflik Taraması Tamamlandı',
        targetUid: 'system_scan',
        details: {
          'totalScanned': users.length,
          'warningsSent': warnings,
          'accountsPurged': purged,
          'purgedUserEmails': purgedEmails,
          'warningUserEmails': warningEmails,
        },
      );
    }

    return InactivityScanResult(
      totalScanned: users.length,
      warningsSent: warnings,
      accountsPurged: purged,
      warningUserEmails: warningEmails,
      purgedUserEmails: purgedEmails,
    );
  }
}

/// Global provider for [AdminService]
final adminServiceProvider = Provider<AdminService>((ref) {
  return FirebaseAdminService();
});

/// Reactive guard checking if current logged-in user is the Executive Admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(authUserProvider);
  if (user == null) return false;
  final email = user.email?.trim().toLowerCase();
  return email == kAdminEmail;
});
