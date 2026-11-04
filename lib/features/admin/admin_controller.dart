import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/telemetry_service.dart';
import '../auth/auth_controller.dart';
import '../settings/data/mock_revenuecat_service.dart';
import 'admin_service.dart';

/// Analytics period for geo and user activity calculations
enum AnalyticsPeriod {
  live, // 15 mins
  daily, // 24 hours
  weekly, // 7 days
  monthly, // 30 days
  yearly, // 365 days
}

/// Filter chips for user directory
enum UserFilterChip {
  all,
  pro,
  banned,
  restricted,
  inactive5thMonth,
  inactive6thMonth,
}

/// City aggregated analytics item within a country
class CityAnalyticsItem {
  final String cityName;
  final int activeUserCount;
  final double percentage; // 0.0 to 1.0 (relative to the country's active users)

  const CityAnalyticsItem({
    required this.cityName,
    required this.activeUserCount,
    required this.percentage,
  });
}

/// Country aggregated analytics item
class CountryAnalyticsItem {
  final String countryCode;
  final String countryName;
  final String primaryCurrency;
  final int activeUserCount;
  final double percentage; // 0.0 to 1.0
  final String topCity;
  final List<CityAnalyticsItem> cities;

  const CountryAnalyticsItem({
    required this.countryCode,
    required this.countryName,
    required this.primaryCurrency,
    required this.activeUserCount,
    required this.percentage,
    this.topCity = '',
    this.cities = const [],
  });
}

/// Helper function to convert 2-letter ISO country code to Emoji flag
String countryCodeToFlagEmoji(String countryCode) {
  if (countryCode.length != 2) return '🌐';
  final code = countryCode.toUpperCase();
  final first = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
  final second = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
  if (first < 0x1F1E6 || first > 0x1F1FF || second < 0x1F1E6 || second > 0x1F1FF) {
    return '🌐';
  }
  return String.fromCharCode(first) + String.fromCharCode(second);
}

/// State representation for the Executive Admin Dashboard
class AdminState {
  final bool isLoading;
  final bool isActionLoading;
  final AdminPlatformMetrics metrics;
  final List<AdminUserModel> allUsers;
  final AdminDetailedAnalytics detailedAnalytics;
  final String selectedCountryAnalyticsTab; // 'wishlist', 'visited', 'lived', 'continents'
  final String searchQuery;
  final UserFilterChip userFilter;
  final AnalyticsPeriod analyticsPeriod;
  final String? errorMessage;
  final DateTime? lastRefreshedAt;

  const AdminState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.metrics = const AdminPlatformMetrics(),
    this.allUsers = const [],
    this.detailedAnalytics = const AdminDetailedAnalytics(),
    this.selectedCountryAnalyticsTab = 'wishlist',
    this.searchQuery = '',
    this.userFilter = UserFilterChip.all,
    this.analyticsPeriod = AnalyticsPeriod.daily,
    this.errorMessage,
    this.lastRefreshedAt,
  });

  /// Cutoff DateTime for active users in the selected analytics period
  DateTime get periodCutoff {
    final now = DateTime.now();
    switch (analyticsPeriod) {
      case AnalyticsPeriod.live:
        return now.subtract(const Duration(minutes: 15));
      case AnalyticsPeriod.daily:
        return now.subtract(const Duration(hours: 24));
      case AnalyticsPeriod.weekly:
        return now.subtract(const Duration(days: 7));
      case AnalyticsPeriod.monthly:
        return now.subtract(const Duration(days: 30));
      case AnalyticsPeriod.yearly:
        return now.subtract(const Duration(days: 365));
    }
  }

  /// Users active in the current period
  List<AdminUserModel> get activeUsersInPeriod {
    final cutoff = periodCutoff;
    return allUsers.where((u) {
      return u.effectiveLastActiveAt.isAfter(cutoff);
    }).toList();
  }

  /// Country breakdown list for active users in the current period, sorted descending by active count
  List<CountryAnalyticsItem> get countryBreakdown {
    final active = activeUsersInPeriod;
    if (active.isEmpty) return const [];

    final totalActive = active.length;
    final Map<String, List<AdminUserModel>> grouped = {};

    for (final user in active) {
      final code = user.effectiveLiveCountryCode.toUpperCase().trim();
      grouped.putIfAbsent(code, () => []).add(user);
    }

    final items = grouped.entries.map((entry) {
      final code = entry.key;
      final usersInCountry = entry.value;
      final count = usersInCountry.length;
      final countryName = usersInCountry
          .firstWhere(
            (u) => u.effectiveLiveCountryName.isNotEmpty,
            orElse: () => usersInCountry.first,
          )
          .effectiveLiveCountryName;
      final primaryCurrency = usersInCountry
          .firstWhere((u) => u.currencyCode.isNotEmpty,
              orElse: () => usersInCountry.first)
          .currencyCode;
      final topCity = usersInCountry
          .map((u) => u.liveCity.trim())
          .firstWhere((c) => c.isNotEmpty, orElse: () => '');

      // Group cities within this country
      final Map<String, int> cityCounts = {};
      final Map<String, String> cityDisplayNames = {};

      for (final u in usersInCountry) {
        final rawCity = u.liveCity.trim();
        if (rawCity.isEmpty) {
          cityCounts[''] = (cityCounts[''] ?? 0) + 1;
        } else {
          final normalizedKey = rawCity.toLowerCase();
          cityCounts[normalizedKey] = (cityCounts[normalizedKey] ?? 0) + 1;
          if (!cityDisplayNames.containsKey(normalizedKey)) {
            final formatted = rawCity[0].toUpperCase() + (rawCity.length > 1 ? rawCity.substring(1) : '');
            cityDisplayNames[normalizedKey] = formatted;
          }
        }
      }

      final cityItems = cityCounts.entries.map((cEntry) {
        final key = cEntry.key;
        final cCount = cEntry.value;
        final displayName = key.isEmpty ? '' : (cityDisplayNames[key] ?? key);
        final cPct = count > 0 ? (cCount / count) : 0.0;
        return CityAnalyticsItem(
          cityName: displayName,
          activeUserCount: cCount,
          percentage: cPct,
        );
      }).toList();

      cityItems.sort((a, b) {
        if (a.cityName.isEmpty && b.cityName.isNotEmpty) return 1;
        if (a.cityName.isNotEmpty && b.cityName.isEmpty) return -1;
        final cmp = b.activeUserCount.compareTo(a.activeUserCount);
        if (cmp != 0) return cmp;
        return a.cityName.compareTo(b.cityName);
      });

      return CountryAnalyticsItem(
        countryCode: code,
        countryName: countryName.isEmpty ? code : countryName,
        primaryCurrency: primaryCurrency.isEmpty ? 'USD' : primaryCurrency,
        activeUserCount: count,
        percentage: totalActive > 0 ? (count / totalActive) : 0.0,
        topCity: topCity,
        cities: cityItems,
      );
    }).toList();

    items.sort((a, b) => b.activeUserCount.compareTo(a.activeUserCount));
    return items;
  }

  /// Filtered users according to current search query and active filter chip
  List<AdminUserModel> get filteredUsers {
    var users = allUsers;

    // Apply Filter Chip
    switch (userFilter) {
      case UserFilterChip.all:
        break;
      case UserFilterChip.pro:
        users = users.where((u) => u.isPremium).toList();
        break;
      case UserFilterChip.banned:
        users = users.where((u) => u.isCurrentlyBanned).toList();
        break;
      case UserFilterChip.restricted:
        users = users.where((u) => u.restrictedFeatures.isNotEmpty).toList();
        break;
      case UserFilterChip.inactive5thMonth:
        users = users.where((u) => u.is5thMonthWarningPeriod).toList();
        break;
      case UserFilterChip.inactive6thMonth:
        users = users.where((u) => u.is6thMonthPurgeReady).toList();
        break;
    }

    if (searchQuery.trim().isEmpty) return users;
    final q = searchQuery.toLowerCase().trim();
    return users.where((u) {
      return u.email.toLowerCase().contains(q) ||
          u.displayName.toLowerCase().contains(q) ||
          u.uid.toLowerCase().contains(q) ||
          u.countryCode.toLowerCase().contains(q) ||
          u.countryName.toLowerCase().contains(q);
    }).toList();
  }

  AdminState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    AdminPlatformMetrics? metrics,
    List<AdminUserModel>? allUsers,
    AdminDetailedAnalytics? detailedAnalytics,
    String? selectedCountryAnalyticsTab,
    String? searchQuery,
    UserFilterChip? userFilter,
    AnalyticsPeriod? analyticsPeriod,
    String? errorMessage,
    DateTime? lastRefreshedAt,
    bool clearError = false,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      metrics: metrics ?? this.metrics,
      allUsers: allUsers ?? this.allUsers,
      detailedAnalytics: detailedAnalytics ?? this.detailedAnalytics,
      selectedCountryAnalyticsTab: selectedCountryAnalyticsTab ?? this.selectedCountryAnalyticsTab,
      searchQuery: searchQuery ?? this.searchQuery,
      userFilter: userFilter ?? this.userFilter,
      analyticsPeriod: analyticsPeriod ?? this.analyticsPeriod,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
    );
  }
}

/// StateNotifier controlling platform metric aggregation and user status mutations
class AdminController extends StateNotifier<AdminState> {
  final AdminService _adminService;
  final Ref? _ref;

  AdminController(this._adminService, [this._ref]) : super(const AdminState()) {
    refreshData();
  }

  /// Reloads platform metrics, user profiles, and detailed travel analytics from Cloud Firestore
  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _adminService.fetchMetrics(),
        _adminService.fetchUsers(),
        _adminService.fetchDetailedAnalytics(),
      ]);

      final metrics = results[0] as AdminPlatformMetrics;
      final users = results[1] as List<AdminUserModel>;
      final analytics = results[2] as AdminDetailedAnalytics;

      state = state.copyWith(
        isLoading: false,
        metrics: metrics,
        allUsers: users,
        detailedAnalytics: analytics,
        lastRefreshedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Changes the active tab in the Country Travel Demand Hub ('wishlist', 'visited', 'lived', 'continents')
  void setCountryAnalyticsTab(String tab) {
    state = state.copyWith(selectedCountryAnalyticsTab: tab);
  }

  /// Alias for refreshData
  Future<void> loadUsers() => refreshData();

  /// Updates the search query to dynamically filter user cards
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Updates the user filter chip
  void setUserFilter(UserFilterChip filter) {
    state = state.copyWith(userFilter: filter);
  }

  /// Updates the analytics period
  void setAnalyticsPeriod(AnalyticsPeriod period) {
    state = state.copyWith(analyticsPeriod: period);
  }

  /// Toggles Pro membership status for a specific user
  Future<bool> toggleUserProStatus(String uid, bool isPremium) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _adminService.toggleUserProStatus(uid, isPremium);

      TelemetryService.instance.logAdminAction(
        action: isPremium ? 'grant_pro' : 'revoke_pro',
        targetUid: uid,
      );

      // Optimistic update of local user model and metric count
      final updatedUsers = state.allUsers.map((u) {
        if (u.uid == uid) {
          return u.copyWith(isPremium: isPremium);
        }
        return u;
      }).toList();

      final proCount = updatedUsers.where((u) => u.isPremium).length;
      final updatedMetrics = state.metrics.copyWith(proUsers: proCount);

      // Synchronize active session if current logged-in user's pro was modified
      final currentUid = _ref?.read(authUserProvider)?.uid;
      if (currentUid == uid && _ref != null) {
        _ref.read(proSubscriptionProvider.notifier).updateProStatus(isPremium, uid: uid);
      }

      state = state.copyWith(
        isActionLoading: false,
        allUsers: updatedUsers,
        metrics: updatedMetrics,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Updates full moderation settings (Pro, ban, and granular restrictions)
  Future<bool> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _adminService.updateUserModeration(
        uid: uid,
        isPremium: isPremium,
        banStatus: banStatus,
        banExpiresAt: banExpiresAt,
        banReason: banReason,
        restrictedFeatures: restrictedFeatures,
      );

      TelemetryService.instance.logAdminAction(
        action: 'moderate_user',
        targetUid: uid,
      );

      // Optimistic update
      final updatedUsers = state.allUsers.map((u) {
        if (u.uid == uid) {
          return u.copyWith(
            isPremium: isPremium,
            banStatus: banStatus,
            banExpiresAt: banExpiresAt,
            clearBanExpiresAt: banExpiresAt == null,
            banReason: banReason,
            clearBanReason: banReason == null,
            restrictedFeatures: restrictedFeatures,
          );
        }
        return u;
      }).toList();

      final proCount = updatedUsers.where((u) => u.isPremium).length;
      final updatedMetrics = state.metrics.copyWith(proUsers: proCount);

      // Synchronize active session if current logged-in user's pro was modified
      final currentUid = _ref?.read(authUserProvider)?.uid;
      if (currentUid == uid && _ref != null) {
        _ref.read(proSubscriptionProvider.notifier).updateProStatus(isPremium, uid: uid);
      }

      state = state.copyWith(
        isActionLoading: false,
        allUsers: updatedUsers,
        metrics: updatedMetrics,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Sends a manual or scheduled inactivity warning email to a user in their 5th inactive month
  Future<bool> sendInactivityWarning(String uid) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _adminService.sendInactivityWarningEmail(uid);
      final updatedUsers = state.allUsers.map((u) {
        if (u.uid == uid) {
          return u.copyWith(
            lastInactivityWarningAt: DateTime.now(),
            inactivityWarningCount: u.inactivityWarningCount + 1,
          );
        }
        return u;
      }).toList();

      state = state.copyWith(
        isActionLoading: false,
        allUsers: updatedUsers,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Cancels pending account deletion requested by user
  Future<bool> cancelAccountDeletion(String uid) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _adminService.cancelAccountDeletionAsAdmin(uid);
      final updatedUsers = state.allUsers.map((u) {
        if (u.uid == uid) {
          return u.copyWith(
            deletionStatus: 'none',
            scheduledPermanentDeletionAt: null,
            deletionRequestedAt: null,
          );
        }
        return u;
      }).toList();

      state = state.copyWith(
        isActionLoading: false,
        allUsers: updatedUsers,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Completely purges a user's account and all linked cloud data
  Future<bool> purgeUser(String uid) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      await _adminService.purgeUserDataAsAdmin(uid);
      final updatedUsers = state.allUsers.where((u) => u.uid != uid).toList();
      state = state.copyWith(
        isActionLoading: false,
        allUsers: updatedUsers,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Executes global 6-month inactivity auto-purge & 5th-month weekly email scan
  Future<InactivityScanResult?> runInactivityScan() async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      final result = await _adminService.processInactivityPolicies();
      await refreshData();
      state = state.copyWith(isActionLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Sends an interactive admin warning to a user (in-app notification + email)
  Future<bool> sendUserWarning({
    required String uid,
    required String title,
    required String message,
    required String warningType,
    bool sendInAppNotification = true,
    bool sendEmail = true,
  }) async {
    state = state.copyWith(isActionLoading: true, clearError: true);
    try {
      final success = await _adminService.sendUserWarning(
        uid: uid,
        title: title,
        message: message,
        warningType: warningType,
        sendInAppNotification: sendInAppNotification,
        sendEmail: sendEmail,
      );
      if (success) {
        await loadUsers();
      }
      state = state.copyWith(isActionLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Clears active error notification
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

/// Global Riverpod Provider for [AdminController]
final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  final service = ref.watch(adminServiceProvider);
  return AdminController(service, ref);
});
