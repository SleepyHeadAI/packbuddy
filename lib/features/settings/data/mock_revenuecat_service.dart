import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Mock RevenueCat Service simulating purchases, entitlement validation and subscriptions
class MockRevenueCatNotifier extends StateNotifier<ProSubscriptionState> {
  MockRevenueCatNotifier() : super(const ProSubscriptionState());

  /// Select a plan before purchasing
  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(activePlan: plan);
  }

  /// Simulate purchasing a subscription via RevenueCat
  Future<bool> purchaseActivePlan() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
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
    state = state.copyWith(
      isPro: true,
      isLoading: false,
    );
    return true;
  }
}

/// Provider exposing Mock RevenueCat service
final proSubscriptionProvider =
    StateNotifierProvider<MockRevenueCatNotifier, ProSubscriptionState>((ref) {
  return MockRevenueCatNotifier();
});
