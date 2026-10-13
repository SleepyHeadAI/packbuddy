import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/telemetry_service.dart';
import 'admin_service.dart';

/// State representation for the Executive Admin Dashboard
class AdminState {
  final bool isLoading;
  final bool isActionLoading;
  final AdminPlatformMetrics metrics;
  final List<AdminUserModel> allUsers;
  final String searchQuery;
  final String? errorMessage;
  final DateTime? lastRefreshedAt;

  const AdminState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.metrics = const AdminPlatformMetrics(),
    this.allUsers = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.lastRefreshedAt,
  });

  /// Filtered users according to current search query (matches email, displayName, or UID)
  List<AdminUserModel> get filteredUsers {
    if (searchQuery.trim().isEmpty) return allUsers;
    final q = searchQuery.toLowerCase().trim();
    return allUsers.where((u) {
      return u.email.toLowerCase().contains(q) ||
          u.displayName.toLowerCase().contains(q) ||
          u.uid.toLowerCase().contains(q);
    }).toList();
  }

  AdminState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    AdminPlatformMetrics? metrics,
    List<AdminUserModel>? allUsers,
    String? searchQuery,
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

  /// Updates the search query to dynamically filter user cards
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
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
