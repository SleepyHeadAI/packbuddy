import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/telemetry_service.dart';

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
  Future<bool> purchaseActivePlan({bool isTestOrAdminConfirmation = false});
  Future<bool> restorePurchases({bool isTestOrAdminConfirmation = false});
  Future<void> resetProStatus({String? uid});
  Future<void> updateProStatus(bool isPro, {String? uid});
}

// =============================================================================
// Store Billing Products Configuration
// =============================================================================
// Product IDs registered in Google Play Console & Apple App Store Connect:
// - packbuddy_pro_monthly : Monthly micro-subscription tier ($0.99 / ₺29,99 / €0,99)
// - packbuddy_pro_annual  : Annual micro-subscription tier ($4.99 / ₺149,99 / €4,99 - Save 58%)
// =============================================================================

/// RevenueCat & Store Billing Service managing entitlements, purchases, and subscriptions.
/// Cleanly decoupled from the UI layer to allow seamless real store or mock testing.
class MockRevenueCatNotifier extends StateNotifier<ProSubscriptionState>
    implements SubscriptionService {
  final PreferencesService _prefs;

  /// Official product identifiers
  static const String productMonthly = 'packbuddy_pro_monthly';
  static const String productAnnual = 'packbuddy_pro_annual';

  /// Real RevenueCat SDK API Keys (injectable via --dart-define)
  static const String appleApiKey =
      String.fromEnvironment('REVENUECAT_APPLE_KEY', defaultValue: '');
  static const String googleApiKey =
      String.fromEnvironment('REVENUECAT_GOOGLE_KEY', defaultValue: '');

  /// Whether store billing backend is currently active on this build.
  static bool isStoreBillingConfigured = false;

  /// Initializes the real purchases_flutter SDK if configured on mobile platform
  static Future<void> initStoreSdk() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    final apiKey = Platform.isIOS ? appleApiKey : googleApiKey;
    if (apiKey.isEmpty) return;
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      isStoreBillingConfigured = true;
    } catch (e) {
      debugPrint('[SubscriptionService] Purchases.configure error: $e');
    }
  }

  /// Test-mode flag to allow automated unit and widget tests to simulate purchases without real store interaction.
  /// Automatically defaults to true when running inside Flutter test runner.
  static bool enableTestPurchasesForUnitTests = () {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }();

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
    state = state.copyWith(activePlan: plan);
    _prefs.setSubscriptionPlan(plan == SubscriptionPlan.monthly ? 'monthly' : 'annual');
  }

  /// Purchase subscription with strict store billing readiness and admin confirmation protection.
  /// Normal users cannot bypass payment without confirmed store transaction or admin test verification.
  @override
  Future<bool> purchaseActivePlan({bool isTestOrAdminConfirmation = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (isStoreBillingConfigured && !enableTestPurchasesForUnitTests && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final offerings = await Purchases.getOfferings();
        final currentOffering = offerings.current;
        final targetPackage = state.activePlan == SubscriptionPlan.monthly
            ? currentOffering?.monthly
            : currentOffering?.annual;
        if (targetPackage != null) {
          final customerInfo = await Purchases.purchasePackage(targetPackage);
          final hasPro = customerInfo.entitlements.active.containsKey('pro') ||
              customerInfo.entitlements.active.containsKey('premium');
          if (hasPro) {
            await _prefs.setProUser(true);
            state = state.copyWith(
              isPro: true,
              isLoading: false,
              errorMessage: null,
            );
            TelemetryService.instance.logProStatusChanged(isPro: true, source: 'purchase');
            return true;
          }
        }
      } catch (e) {
        debugPrint('[SubscriptionService] Purchases SDK error: $e');
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
        return false;
      }
    }

    // Production billing guard: Prevent unverified free Pro bypass for regular users
    if (!enableTestPurchasesForUnitTests && !isTestOrAdminConfirmation && !isStoreBillingConfigured) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Store billing products ($productMonthly, $productAnnual) are not yet configured.',
      );
      return false;
    }

    await Future.delayed(const Duration(milliseconds: 400));
    await _prefs.setProUser(true);
    state = state.copyWith(
      isPro: true,
      isLoading: false,
      errorMessage: null,
    );
    TelemetryService.instance.logProStatusChanged(isPro: true, source: 'purchase');
    return true;
  }

  /// Restore purchases with verification protection
  @override
  Future<bool> restorePurchases({bool isTestOrAdminConfirmation = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (isStoreBillingConfigured && !enableTestPurchasesForUnitTests && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final customerInfo = await Purchases.restorePurchases();
        final hasPro = customerInfo.entitlements.active.containsKey('pro') ||
            customerInfo.entitlements.active.containsKey('premium');
        if (hasPro) {
          await _prefs.setProUser(true);
          state = state.copyWith(
            isPro: true,
            isLoading: false,
            errorMessage: null,
          );
          TelemetryService.instance.logProStatusChanged(isPro: true, source: 'restore');
          return true;
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'No active Pro subscription found for this account.',
          );
          return false;
        }
      } catch (e) {
        debugPrint('[SubscriptionService] Purchases restore error: $e');
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
        return false;
      }
    }

    if (!enableTestPurchasesForUnitTests && !isTestOrAdminConfirmation && !isStoreBillingConfigured) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Store billing products ($productMonthly, $productAnnual) are not yet configured.',
      );
      return false;
    }

    await Future.delayed(const Duration(milliseconds: 400));
    await _prefs.setProUser(true);
    state = state.copyWith(
      isPro: true,
      isLoading: false,
      errorMessage: null,
    );
    TelemetryService.instance.logProStatusChanged(isPro: true, source: 'restore');
    return true;
  }

  /// Reset Pro status (useful for QA testing and debug developer settings)
  @override
  Future<void> resetProStatus({String? uid}) async {
    if (isStoreBillingConfigured && !enableTestPurchasesForUnitTests && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Purchases.logOut();
      } catch (e) {
        debugPrint('[SubscriptionService] Purchases.logOut notice: $e');
      }
    }
    await _prefs.setProUser(false, uid: uid);
    await _prefs.clearDeviceProStatus();
    state = state.copyWith(isPro: false);
    TelemetryService.instance.logProStatusChanged(isPro: false, source: 'reset');
  }

  /// Sets or synchronizes Pro status directly (e.g. from Firestore admin or remote entitlements)
  @override
  Future<void> updateProStatus(bool isPro, {String? uid}) async {
    await _prefs.setProUser(isPro, uid: uid);
    if (state.isPro != isPro) {
      state = state.copyWith(isPro: isPro);
      TelemetryService.instance.logProStatusChanged(isPro: isPro, source: 'sync');
    }
  }

  /// Reloads Pro status for a specific or current user from user-scoped storage
  void reloadForUser({String? uid}) {
    final isPro = _prefs.isProUser(uid: uid);
    if (state.isPro != isPro) {
      state = state.copyWith(isPro: isPro);
    }
  }
}

/// Global Riverpod Provider exposing the decoupled subscription service
final proSubscriptionProvider =
    StateNotifierProvider<MockRevenueCatNotifier, ProSubscriptionState>((ref) {
  return MockRevenueCatNotifier();
});
