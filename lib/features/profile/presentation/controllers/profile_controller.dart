import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/profile/data/profile_service.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';

/// State representation of the user profile and aggregated travel metrics
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? errorMessage;
  final int totalTrips;
  final int totalCountriesVisited;
  final int totalPackingItems;
  final int totalDocuments;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.totalTrips = 0,
    this.totalCountriesVisited = 0,
    this.totalPackingItems = 0,
    this.totalDocuments = 0,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? errorMessage,
    int? totalTrips,
    int? totalCountriesVisited,
    int? totalPackingItems,
    int? totalDocuments,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      totalTrips: totalTrips ?? this.totalTrips,
      totalCountriesVisited: totalCountriesVisited ?? this.totalCountriesVisited,
      totalPackingItems: totalPackingItems ?? this.totalPackingItems,
      totalDocuments: totalDocuments ?? this.totalDocuments,
    );
  }
}

/// Controller managing profile loading, profile updates, and travel statistics computation
class ProfileController extends StateNotifier<ProfileState> {
  final Ref _ref;
  final ProfileService _profileService;

  ProfileController(this._ref, {ProfileService? service})
      : _profileService = service ?? ProfileService(),
        super(const ProfileState()) {
    _init();
  }

  void _init() {
    final user = _ref.read(authUserProvider);
    if (user != null) {
      loadProfile(user.uid);
    }
  }

  /// Calculates real-time travel metrics from existing Riverpod controllers
  void refreshStats() {
    try {
      final trips = _ref.read(tripControllerProvider).trips.where((t) => !t.isDeleted).length;
      final countries = _ref.read(travelMapControllerProvider).visitedCount;
      final items = _ref.read(checklistControllerProvider).items.where((i) => !i.isDeleted).length;
      final docs = _ref.read(vaultControllerProvider).documents.where((d) => !d.isDeleted).length;

      state = state.copyWith(
        totalTrips: trips,
        totalCountriesVisited: countries,
        totalPackingItems: items,
        totalDocuments: docs,
      );
    } catch (_) {}
  }

  /// Loads profile from cache or Firestore and calculates stats
  Future<void> loadProfile(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _profileService.fetchProfile(uid);
      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );
      refreshStats();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Updates profile metadata and syncs with cloud
  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? homeCountryCode,
    String? homeCity,
  }) async {
    final uid = state.profile?.uid ?? _ref.read(authUserProvider)?.uid;
    if (uid == null || uid.isEmpty) return false;

    state = state.copyWith(isLoading: true);
    try {
      final updated = await _profileService.updateProfile(
        uid,
        displayName: displayName,
        bio: bio,
        homeCountryCode: homeCountryCode,
        homeCity: homeCity,
      );
      state = state.copyWith(
        profile: updated,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Resets state on sign out
  void resetState() {
    state = const ProfileState();
  }
}

/// Global Riverpod provider for User Profile
final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController(ref);
});
