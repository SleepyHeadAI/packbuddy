import '../../core/services/telemetry_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/live_location_service.dart';
import '../../core/services/email_dispatch_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/local_db/database_helper.dart';
import '../budget/domain/country.dart';
import '../budget/domain/trip.dart';
import '../budget/domain/expense.dart';
import '../vault/domain/document.dart';
import '../travel_map/data/world_countries_data.dart';
import '../travel_map/domain/travel_country.dart';
import '../budget/domain/country_localization.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import 'domain/broadcast_announcement.dart';
import 'domain/admin_audit_log.dart';

/// Designated Executive Super Admin Email
const String kAdminEmail = 'sleepyheadaitr@gmail.com';

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

  const AdminPlatformMetrics({
    this.totalUsers = 0,
    this.verifiedUsers = 0,
    this.proUsers = 0,
    this.totalTrips = 0,
    this.totalExpenses = 0,
    this.totalDocuments = 0,
    this.totalChecklistItems = 0,
    this.totalStorageBytes = 0,
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
    );
  }
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
      countryCode: (data['countryCode'] ?? data['country_code']) as String? ?? 'US',
      countryName: (data['countryName'] ?? data['country_name']) as String? ?? 'United States',
      currencyCode: (data['currencyCode'] ?? data['currency_code']) as String? ?? 'USD',
      liveCountryCode: ((data['liveCountryCode'] ?? data['live_country_code'] ?? data['countryCode'] ?? data['country_code']) as String? ?? 'US').toUpperCase().trim(),
      liveCountryName: ((data['liveCountryName'] ?? data['live_country_name'] ?? data['countryName'] ?? data['country_name']) as String? ?? 'United States').trim(),
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
    );
  }

  double get averageSessionMinutes =>
      sessionCount > 0 ? (totalSessionSeconds / sessionCount / 60) : 0.0;

  String get effectiveLiveCountryCode =>
      liveCountryCode.isNotEmpty ? liveCountryCode : (countryCode.isNotEmpty ? countryCode : 'US');

  String get effectiveLiveCountryName =>
      liveCountryName.isNotEmpty ? liveCountryName : (countryName.isNotEmpty ? countryName : 'United States');

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
  Future<List<Trip>> fetchUserTrips(String uid);
  Future<List<Expense>> fetchUserExpenses(String uid);
  Future<List<AdminUserSessionLog>> fetchUserSessions(String uid);
  Future<List<TravelCountry>> fetchUserTravelCountries(String uid);
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

  Future<int> _getCollectionCount(String collectionName) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return 0;
    try {
      final aggregate = await firestore.collection(collectionName).count().get();
      return aggregate.count ?? 0;
    } catch (_) {
      try {
        final snapshot = await firestore.collection(collectionName).get();
        return snapshot.size;
      } catch (_) {
        return 0;
      }
    }
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
      final usersSnapshot = await firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      int verifiedUsers = 0;
      int proUsers = 0;
      int totalStorageBytes = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        if (data['emailVerified'] == true || data['email_verified'] == true) {
          verifiedUsers++;
        }
        final isPro = (data['isPremium'] == true) ||
            (data['is_premium'] == true) ||
            (data['isPro'] == true) ||
            (data['pro'] == true) ||
            PreferencesService.instance.isProUser(uid: doc.id);
        if (isPro) {
          proUsers++;
        }
        final storage = ((data['totalVaultStorageBytes'] ?? data['total_vault_storage_bytes']) as num?)?.toInt() ?? 0;
        totalStorageBytes += storage;
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

      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await firestore
            .collection('users')
            .orderBy('lastLoginAt', descending: true)
            .get();
      } catch (_) {
        // Fallback without server-side ordering if composite index is pending
        snapshot = await firestore.collection('users').get();
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

      int totalPlatformSessionSeconds = 0;
      int totalPlatformSessions = 0;
      int verifiedUsers = 0;
      int proUsers = 0;
      int totalWorldMapMarks = 0;

      List<Map<String, dynamic>> userMaps = [];
      if (firestore != null) {
        try {
          final usersSnap = await firestore.collection('users').get();
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
      }

      // 5. Query Trips (Strictly Trip Data Analytics: Destinations, Dates, Transport, Currencies)
      double totalTripDays = 0;
      int tripCountWithDates = 0;
      int upcomingTripsCount = 0;
      int completedTripsCount = 0;
      int totalTripsSnapCount = 0;

      if (firestore != null) {
        try {
          final tripsSnap = await firestore.collection('trips').get();
          totalTripsSnapCount = tripsSnap.docs.length;
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
          final expSnap = await firestore.collection('expenses').get();
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
          final docsSnap = await firestore.collection('documents').get();
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
        var snapshot = await firestore
            .collection('documents')
            .where('user_id', isEqualTo: uid)
            .get();
        if (snapshot.docs.isEmpty) {
          snapshot = await firestore
              .collection('documents')
              .where('userId', isEqualTo: uid)
              .get();
        }
        for (final d in snapshot.docs) {
          try {
            final doc = VaultDocument.fromJson(d.data());
            if (!doc.isDeleted) {
              docs.add(doc);
            }
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserDocuments firestore error: $e');
      }
    }

    if (docs.isEmpty) {
      try {
        final localDocs = await DatabaseHelper.instance.getDocuments(userId: uid);
        for (final d in localDocs) {
          if (!d.isDeleted) {
            docs.add(d);
          }
        }
      } catch (e) {
        debugPrint('[AdminService] fetchUserDocuments local error: $e');
      }
    }

    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs;
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

      // 4. Delete the root user document completely from Firestore!
      await firestore.collection('users').doc(uid).delete();

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
      await firestore.collection('mail').add({
        'to': [email],
        'message': {
          'subject': '⚠️ PackBuddy Hesabınız $remainingDays Gün İçinde Silinecek (Uyarı #$newCount)',
          'text': 'Merhaba ${displayName.isNotEmpty ? displayName : "Gezgin"},\n\n'
              'PackBuddy hesabınıza yaklaşık 5 aydır giriş yapmadığınızı fark ettik.\n\n'
              'Veri saklama ve gizlilik politikamız gereğince 6 ay (180 gün) boyunca giriş yapılmayan hesaplar ve bu hesaplara ait seyahatler, harcamalar, bavul kontrol listeleri ve kasa belgeleri kalıcı olarak silinmektedir.\n\n'
              'Hesabınızın kalıcı olarak silinmesine yaklaşık $remainingDays gün kaldı.\n\n'
              'Hesabınızı ve tüm seyahat verilerinizi korumak için lütfen PackBuddy mobil uygulamasına giriş yapınız. Giriş yaptığınız anda hesabınız otomatik olarak aktif kalmaya devam edecektir.\n\n'
              'İyi yolculuklar,\nPackBuddy Ekibi',
          'html': '''
            <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 16px; background-color: #ffffff;">
              <h2 style="color: #ea580c; margin-top: 0;">PackBuddy Hesap İnaktiflik Uyarısı</h2>
              <p>Merhaba <strong>${displayName.isNotEmpty ? displayName : "Gezgin"}</strong>,</p>
              <p>PackBuddy hesabınıza yaklaşık <strong>5 aydır</strong> giriş yapmadığınızı fark ettik.</p>
              <div style="background-color: #fff7ed; border-left: 4px solid #ea580c; padding: 14px; margin: 18px 0; border-radius: 8px;">
                <p style="margin: 0; color: #9a3412; font-weight: bold; font-size: 15px;">
                  ⏳ Hesabınızın ve tüm verilerinizin kalıcı olarak silinmesine yaklaşık $remainingDays gün kaldı.
                </p>
                <p style="margin: 6px 0 0 0; color: #c2410c; font-size: 13px;">
                  (5. ay boyunca her hafta gönderilen otomatik uyarı e-postası: #$newCount)
                </p>
              </div>
              <p style="color: #334155; line-height: 1.5;">
                Sistemlerimizde 6 ay (180 gün) boyunca giriş yapılmayan hesaplar ve bu hesaplara ait seyahat kayıtları, harcamalar, bavul kontrol listeleri ve kasa belgeleri güvenlik ve veri koruma ilkelerimiz uyarınca kalıcı olarak silinmektedir.
              </p>
              <p style="color: #0f172a; font-weight: 600;">
                Hesabınızı korumak için tek yapmanız gereken: Uygulamaya giriş yapmak!
              </p>
              <p style="color: #64748b; font-size: 13px;">
                Uygulamayı açıp giriş yaptığınız anda hesabınız otomatik olarak sıfırlanacak ve aktif olarak korunmaya devam edecektir.
              </p>
              <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 24px 0;" />
              <p style="font-size: 12px; color: #94a3b8; margin-bottom: 0;">Bu e-posta PackBuddy otomatik hesap koruma servisi tarafından gönderilmiştir.</p>
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
        final emailSubject = '⚠️ PackBuddy Bildirimi: $title';
        final emailText = EmailDispatchService.instance.formatWarningEmailText(
          displayName: displayName,
          title: title,
          message: message,
        );
        final emailHtml = EmailDispatchService.instance.formatWarningEmailHtml(
          displayName: displayName,
          title: title,
          message: message,
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
  Future<InactivityScanResult> processInactivityPolicies() async {
    final users = await fetchUsers();
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
            await firestore.collection('mail').add({
              'to': [user.email],
              'message': {
                'subject': 'PackBuddy Hesabınız 6 Aylık İnaktiflik Nedeniyle Silindi / Account Deleted',
                'text': 'Merhaba ${user.displayName.isNotEmpty ? user.displayName : "Gezgin"},\n\n'
                    'PackBuddy hesabınıza 6 ay (180 gün) boyunca giriş yapılmadığı için güvenlik ve veri koruma ilkelerimiz uyarınca hesabınız ve tüm verileriniz kalıcı olarak silinmiştir.\n\n'
                    'PackBuddy Ekibi',
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
