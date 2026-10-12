import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/preferences_service.dart';

/// Package subscription types for PackBuddy Pro
enum SubscriptionPlan {
  monthly,
  annual,
}

/// State representation for PackBuddy Pro membership
class ProSubscriptionState {
  final bool isPro;
  final bool isLoading;
  final SubscriptionPlan activePlan;

  const ProSubscriptionState({
    this.isPro = false,
    this.isLoading = false,
    this.activePlan = SubscriptionPlan.annual,
  });

  ProSubscriptionState copyWith({
    bool? isPro,
    bool? isLoading,
    SubscriptionPlan? activePlan,
  }) {
    return ProSubscriptionState(
      isPro: isPro ?? this.isPro,
      isLoading: isLoading ?? this.isLoading,
      activePlan: activePlan ?? this.activePlan,
    );
  }
}

/// Mock RevenueCat Service simulating purchases, entitlement validation and subscriptions with SharedPreferences
class MockRevenueCatNotifier extends StateNotifier<ProSubscriptionState> {
  final PreferencesService _prefs;

  MockRevenueCatNotifier([PreferencesService? prefs])
      : _prefs = prefs ?? PreferencesService.instance,
        super(ProSubscriptionState(
          isPro: (prefs ?? PreferencesService.instance).isProUser(),
          activePlan: (prefs ?? PreferencesService.instance).getSubscriptionPlan() == 'monthly'
              ? SubscriptionPlan.monthly
              : SubscriptionPlan.annual,
        ));

  /// Select a plan before purchasing
  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(activePlan: plan);
    _prefs.setSubscriptionPlan(plan == SubscriptionPlan.monthly ? 'monthly' : 'annual');
  }

  /// Simulate purchasing a subscription via RevenueCat
  Future<bool> purchaseActivePlan() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    await _prefs.setProUser(true);
    state = state.copyWith(
      isPro: true,
      isLoading: false,
    );
    return true;
  }

  /// Simulate restoring previous purchases
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    await _prefs.setProUser(true);
    state = state.copyWith(
      isPro: true,
      isLoading: false,
    );
    return true;
  }

  /// Reset Pro status (useful for testing and debug settings)
  Future<void> resetProStatus() async {
    await _prefs.setProUser(false);
    state = state.copyWith(isPro: false);
  }
}

/// Provider exposing Mock RevenueCat service
final proSubscriptionProvider =
    StateNotifierProvider<MockRevenueCatNotifier, ProSubscriptionState>((ref) {
  return MockRevenueCatNotifier();
});
