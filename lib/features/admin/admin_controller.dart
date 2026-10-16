import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/telemetry_service.dart';
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
}

/// Country aggregated analytics item
class CountryAnalyticsItem {
  final String countryCode;
  final String countryName;
  final String primaryCurrency;
  final int activeUserCount;
  final double percentage; // 0.0 to 1.0

  const CountryAnalyticsItem({
    required this.countryCode,
    required this.countryName,
    required this.primaryCurrency,
    required this.activeUserCount,
    required this.percentage,
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
      final code = user.countryCode.toUpperCase().trim().isEmpty
          ? 'US'
          : user.countryCode.toUpperCase().trim();
      grouped.putIfAbsent(code, () => []).add(user);
    }

    final items = grouped.entries.map((entry) {
      final code = entry.key;
      final usersInCountry = entry.value;
      final count = usersInCountry.length;
      final countryName = usersInCountry
          .firstWhere((u) => u.countryName.isNotEmpty,
              orElse: () => usersInCountry.first)
          .countryName;
      final primaryCurrency = usersInCountry
          .firstWhere((u) => u.currencyCode.isNotEmpty,
              orElse: () => usersInCountry.first)
          .currencyCode;

      return CountryAnalyticsItem(
        countryCode: code,
        countryName: countryName.isEmpty ? code : countryName,
        primaryCurrency: primaryCurrency.isEmpty ? 'USD' : primaryCurrency,
        activeUserCount: count,
        percentage: totalActive > 0 ? (count / totalActive) : 0.0,
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

  AdminController(this._adminService) : super(const AdminState()) {
    refreshData();
  }

  /// Reloads both platform metrics and user profiles from Cloud Firestore
  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _adminService.fetchMetrics(),
        _adminService.fetchUsers(),
      ]);

      final metrics = results[0] as AdminPlatformMetrics;
      final users = results[1] as List<AdminUserModel>;

      state = state.copyWith(
        isLoading: false,
        metrics: metrics,
        allUsers: users,
        lastRefreshedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
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
  return AdminController(service);
});
