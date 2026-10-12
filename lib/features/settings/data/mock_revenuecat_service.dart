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
  final String? errorMessage;

  const ProSubscriptionState({
    this.isPro = false,
    this.isLoading = false,
    this.activePlan = SubscriptionPlan.annual,
    this.errorMessage,
  });

  ProSubscriptionState copyWith({
    bool? isPro,
    bool? isLoading,
    SubscriptionPlan? activePlan,
    String? errorMessage,
  }) {
    return ProSubscriptionState(
      isPro: isPro ?? this.isPro,
      isLoading: isLoading ?? this.isLoading,
      activePlan: activePlan ?? this.activePlan,
      errorMessage: errorMessage,
    );
  }
}

/// Abstract contract for In-App Purchases & Subscriptions.
/// Decouples the UI layer (PaywallSheet, Settings, Dashboard) from the billing SDK.
abstract class SubscriptionService {
  void selectPlan(SubscriptionPlan plan);
  Future<bool> purchaseActivePlan();
  Future<bool> restorePurchases();
  Future<void> resetProStatus();
}

// =============================================================================
// TODO: Replace with official purchases_flutter SDK
// =============================================================================
// MIGRATION BLUEPRINT TO OFFICIAL purchases_flutter SDK:
// 1. Add `purchases_flutter: ^8.x.x` to pubspec.yaml dependencies.
// 2. Initialize RevenueCat in main.dart:
//      await Purchases.setLogLevel(LogLevel.debug);
//      PurchasesConfiguration configuration = PurchasesConfiguration(<public_api_key>);
//      await Purchases.configure(configuration);
// 3. This StateNotifier adheres to the SubscriptionService contract. When ready,
//    swap internal calls with `Purchases.purchasePackage()` & `Purchases.restorePurchases()`.
// 4. Zero UI changes required: UI layers consume ONLY `proSubscriptionProvider`.
// =============================================================================

/// Mock RevenueCat Service simulating purchases, entitlement validation, and subscriptions.
/// Cleanly decoupled from the UI layer to allow drop-in replacement with `purchases_flutter`.
class MockRevenueCatNotifier extends StateNotifier<ProSubscriptionState>
    implements SubscriptionService {
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
  @override
  void selectPlan(SubscriptionPlan plan) {
    // TODO: Replace with official purchases_flutter SDK package selection:
    // e.g. ref.read(currentOfferingProvider).availablePackages.firstWhere(...)
    state = state.copyWith(activePlan: plan);
    _prefs.setSubscriptionPlan(plan == SubscriptionPlan.monthly ? 'monthly' : 'annual');
  }

  /// Simulate purchasing a subscription via RevenueCat
  @override
  Future<bool> purchaseActivePlan() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // =========================================================================
    // TODO: Replace with official purchases_flutter SDK
    // Production replacement:
    // try {
    //   final customerInfo = await Purchases.purchasePackage(selectedPackage);
    //   final isProActive = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
    //   await _prefs.setProUser(isProActive);
    //   state = state.copyWith(isPro: isProActive, isLoading: false);
    //   return isProActive;
    // } on PlatformException catch (e) {
    //   final errorCode = PurchasesErrorHelper.getErrorCode(e);
    //   if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
    //     state = state.copyWith(isLoading: false, errorMessage: e.message);
    //   }
    //   return false;
    // }
    // =========================================================================

    await Future.delayed(const Duration(milliseconds: 600));
    await _prefs.setProUser(true);
    state = state.copyWith(
      isPro: true,
      isLoading: false,
    );
    return true;
  }

  /// Simulate restoring previous purchases
  @override
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // =========================================================================
    // TODO: Replace with official purchases_flutter SDK
    // Production replacement:
    // try {
    //   final customerInfo = await Purchases.restorePurchases();
    //   final isProActive = customerInfo.entitlements.all['pro_access']?.isActive ?? false;
    //   await _prefs.setProUser(isProActive);
    //   state = state.copyWith(isPro: isProActive, isLoading: false);
    //   return isProActive;
    // } catch (e) {
    //   state = state.copyWith(isLoading: false, errorMessage: e.toString());
    //   return false;
    // }
    // =========================================================================

    await Future.delayed(const Duration(milliseconds: 500));
    await _prefs.setProUser(true);
    state = state.copyWith(
      isPro: true,
      isLoading: false,
    );
    return true;
  }

  /// Reset Pro status (useful for QA testing and debug developer settings)
  @override
  Future<void> resetProStatus() async {
    // TODO: Replace with official purchases_flutter SDK (Purchases.logOut())
    await _prefs.setProUser(false);
    state = state.copyWith(isPro: false);
  }
}

/// Global Riverpod Provider exposing the decoupled subscription service
final proSubscriptionProvider =
    StateNotifierProvider<MockRevenueCatNotifier, ProSubscriptionState>((ref) {
  return MockRevenueCatNotifier();
});
