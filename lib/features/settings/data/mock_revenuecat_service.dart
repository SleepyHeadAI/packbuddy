import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
  final Map<String, ProductDetails> products;
  final bool isAvailable;

  const ProSubscriptionState({
    this.isPro = false,
    this.isLoading = false,
    this.activePlan = SubscriptionPlan.annual,
    this.errorMessage,
    this.products = const {},
    this.isAvailable = false,
  });

  ProductDetails? get monthlyProduct => products[MockRevenueCatNotifier.productMonthly];
  ProductDetails? get annualProduct => products[MockRevenueCatNotifier.productAnnual];

  ProSubscriptionState copyWith({
    bool? isPro,
    bool? isLoading,
    SubscriptionPlan? activePlan,
    String? errorMessage,
    Map<String, ProductDetails>? products,
    bool? isAvailable,
  }) {
    return ProSubscriptionState(
      isPro: isPro ?? this.isPro,
      isLoading: isLoading ?? this.isLoading,
      activePlan: activePlan ?? this.activePlan,
      errorMessage: errorMessage,
      products: products ?? this.products,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

/// Abstract contract for In-App Purchases & Subscriptions.
/// Decouples the UI layer (PaywallSheet, Settings, Dashboard) from the billing SDK.
abstract class SubscriptionService {
  void selectPlan(SubscriptionPlan plan);
  Future<bool> purchasePlan(String productId, {bool isTestOrAdminConfirmation = false});
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

/// Official Google Play & App Store Billing Service managing entitlements, purchases, and subscriptions.
/// Cleanly decoupled from the UI layer to allow seamless real store or mock testing.
class MockRevenueCatNotifier extends StateNotifier<ProSubscriptionState>
    implements SubscriptionService {
  final PreferencesService _prefs;
  final InAppPurchase? _customIap;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Lazily resolves InAppPurchase.instance only when not running in headless unit tests
  InAppPurchase get _iap => _customIap ?? InAppPurchase.instance;

  /// Official product identifiers
  static const String productMonthly = 'packbuddy_pro_monthly';
  static const String productAnnual = 'packbuddy_pro_annual';
  static const Set<String> productIds = {productMonthly, productAnnual};

  /// Whether store billing backend is currently active on this build.
  static bool isStoreBillingConfigured = true;

  /// Test-mode flag to allow automated unit and widget tests to simulate purchases without real store interaction.
  /// Automatically defaults to true when running inside Flutter test runner.
  static bool enableTestPurchasesForUnitTests = () {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }();

  /// Backward compatibility hook
  static Future<void> initStoreSdk() async {
    // InAppPurchase does not require explicit static configuration
  }

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  MockRevenueCatNotifier([PreferencesService? prefs, InAppPurchase? iap])
      : _prefs = prefs ?? PreferencesService.instance,
        _customIap = iap,
        super(ProSubscriptionState(
          isPro: (prefs ?? PreferencesService.instance).isProUser(),
          activePlan: (prefs ?? PreferencesService.instance).getSubscriptionPlan() == 'monthly'
              ? SubscriptionPlan.monthly
              : SubscriptionPlan.annual,
        )) {
    if (!enableTestPurchasesForUnitTests && isStoreBillingConfigured) {
      _initBilling();
    }
  }

  Future<void> _initBilling() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    try {
      final available = await _iap.isAvailable();
      if (!available) {
        state = state.copyWith(isAvailable: false);
        return;
      }

      state = state.copyWith(isAvailable: true);

      _purchaseSubscription = _iap.purchaseStream.listen(
        _onPurchaseStreamUpdated,
        onDone: () => _purchaseSubscription?.cancel(),
        onError: (error) {
          debugPrint('[SubscriptionService] purchaseStream error: $error');
          state = state.copyWith(isLoading: false, errorMessage: error.toString());
        },
      );

      await queryProductDetails();
    } catch (e) {
      debugPrint('[SubscriptionService] Billing initialization error: $e');
    }
  }

  /// Queries live store product details
  Future<void> queryProductDetails() async {
    if (enableTestPurchasesForUnitTests || !isStoreBillingConfigured) return;
    try {
      final response = await _iap.queryProductDetails(productIds);
      if (response.error != null) {
        debugPrint('[SubscriptionService] queryProductDetails error: ${response.error}');
      }
      final map = <String, ProductDetails>{};
      for (final p in response.productDetails) {
        map[p.id] = p;
      }
      state = state.copyWith(products: map);
    } catch (e) {
      debugPrint('[SubscriptionService] queryProductDetails error: $e');
    }
  }

  Future<void> _onPurchaseStreamUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(isLoading: true, errorMessage: null);
          break;
        case PurchaseStatus.error:
          state = state.copyWith(
            isLoading: false,
            errorMessage: purchaseDetails.error?.message ?? 'Purchase failed',
          );
          TelemetryService.instance.logProStatusChanged(isPro: false, source: 'google_play_error');
          break;
        case PurchaseStatus.canceled:
          state = state.copyWith(isLoading: false, errorMessage: null);
          TelemetryService.instance.logProStatusChanged(isPro: false, source: 'google_play_canceled');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // 1. Mandatory: Complete purchase to prevent Google from auto-refunding after 3 days!
          if (purchaseDetails.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(purchaseDetails);
            } catch (e) {
              debugPrint('[SubscriptionService] completePurchase error: $e');
            }
          }

          // 2. Update local state and persist
          final currentUid = _auth?.currentUser?.uid;
          await _prefs.setProUser(true, uid: currentUid);
          state = state.copyWith(
            isPro: true,
            isLoading: false,
            errorMessage: null,
          );

          // 3. Update Firestore users/{uid} with isPremium: true, subscriptionProductId, subscriptionPurchaseId, subscriptionUpdatedAt
          if (currentUid != null && _firestore != null) {
            try {
              await _firestore!.collection('users').doc(currentUid).set({
                'isPremium': true,
                'subscriptionProductId': purchaseDetails.productID,
                'subscriptionPurchaseId': purchaseDetails.purchaseID ?? '',
                'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            } catch (e) {
              debugPrint('[SubscriptionService] Firestore subscription update notice: $e');
            }
          }

          // 4. Telemetry
          TelemetryService.instance.logProStatusChanged(
            isPro: true,
            source: 'google_play_${purchaseDetails.productID}',
          );
          break;
      }
    }
  }

  /// Select a plan before purchasing
  @override
  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(activePlan: plan);
    _prefs.setSubscriptionPlan(plan == SubscriptionPlan.monthly ? 'monthly' : 'annual');
  }

  /// Purchase subscription via active plan
  @override
  Future<bool> purchaseActivePlan({bool isTestOrAdminConfirmation = false}) {
    final productId = state.activePlan == SubscriptionPlan.monthly ? productMonthly : productAnnual;
    return purchasePlan(productId, isTestOrAdminConfirmation: isTestOrAdminConfirmation);
  }

  /// Purchase subscription with strict store billing readiness and admin confirmation protection.
  @override
  Future<bool> purchasePlan(String productId, {bool isTestOrAdminConfirmation = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (enableTestPurchasesForUnitTests) {
      if (!isTestOrAdminConfirmation && !isStoreBillingConfigured) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Store billing products ($productMonthly, $productAnnual) are not yet configured.',
        );
        return false;
      }
      final currentUid = _auth?.currentUser?.uid;
      await _prefs.setProUser(true, uid: currentUid);
      state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
      TelemetryService.instance.logProStatusChanged(isPro: true, source: 'purchase');
      return true;
    }

    if (!isStoreBillingConfigured) {
      final currentUserEmail = _auth?.currentUser?.email?.trim().toLowerCase();
      final isSuperAdmin = currentUserEmail == 'sleepyheadaitr@gmail.com';
      final allowSandbox = isTestOrAdminConfirmation && (isSuperAdmin || kDebugMode);

      if (!allowSandbox) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Store billing products ($productMonthly, $productAnnual) are not yet configured.',
        );
        return false;
      }
    }

    // Check if store product is loaded and available
    final details = state.products[productId];
    if (details != null) {
      try {
        final purchaseParam = PurchaseParam(productDetails: details);
        final initiated = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
        return initiated;
      } catch (e) {
        debugPrint('[SubscriptionService] InAppPurchase buy error: $e');
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
        return false;
      }
    }

    // Super Admin or kDebugMode test purchase fallback
    final currentUserEmail = _auth?.currentUser?.email?.trim().toLowerCase();
    final isSuperAdmin = currentUserEmail == 'sleepyheadaitr@gmail.com';
    final allowSandbox = isTestOrAdminConfirmation && (isSuperAdmin || kDebugMode);

    if (!allowSandbox) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Store billing products ($productMonthly, $productAnnual) are not yet configured.',
      );
      return false;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final currentUid = _auth?.currentUser?.uid;
    await _prefs.setProUser(true, uid: currentUid);
    state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
    TelemetryService.instance.logProStatusChanged(isPro: true, source: 'admin_test_purchase');
    return true;
  }

  /// Restore purchases with verification protection and cross-device Firestore sync
  @override
  Future<bool> restorePurchases({bool isTestOrAdminConfirmation = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (enableTestPurchasesForUnitTests) {
      if (!isTestOrAdminConfirmation && !isStoreBillingConfigured) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Store billing products ($productMonthly, $productAnnual) are not yet configured.',
        );
        return false;
      }
      final currentUid = _auth?.currentUser?.uid;
      await _prefs.setProUser(true, uid: currentUid);
      state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
      TelemetryService.instance.logProStatusChanged(isPro: true, source: 'restore');
      return true;
    }

    if (!isStoreBillingConfigured && !isTestOrAdminConfirmation) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Store billing products ($productMonthly, $productAnnual) are not yet configured.',
      );
      return false;
    }

    // 1. Cross-check Firestore users/{uid}.isPremium so switching devices restores entitlement immediately
    final currentUid = _auth?.currentUser?.uid;
    if (currentUid != null && _firestore != null) {
      try {
        final userDoc = await _firestore!.collection('users').doc(currentUid).get();
        if (userDoc.exists && (userDoc.data()?['isPremium'] == true)) {
          await _prefs.setProUser(true, uid: currentUid);
          state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
          TelemetryService.instance.logProStatusChanged(isPro: true, source: 'firestore_restore');
          return true;
        }
      } catch (e) {
        debugPrint('[SubscriptionService] Firestore restore check error: $e');
      }
    }

    // 2. Query InAppPurchase.instance.restorePurchases()
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final isAvailable = await _iap.isAvailable();
        if (isAvailable) {
          await _iap.restorePurchases();
          await Future.delayed(const Duration(milliseconds: 500));
          if (state.isPro) {
            state = state.copyWith(isLoading: false);
            return true;
          }
        }
      } catch (e) {
        debugPrint('[SubscriptionService] InAppPurchase restore error: $e');
      }
    }

    if (isTestOrAdminConfirmation) {
      await _prefs.setProUser(true, uid: currentUid);
      state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
      TelemetryService.instance.logProStatusChanged(isPro: true, source: 'restore_admin');
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: 'No active Pro subscription found for this account.',
    );
    return false;
  }

  /// Reset Pro status (useful for QA testing and debug developer settings)
  @override
  Future<void> resetProStatus({String? uid}) async {
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

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    super.dispose();
  }
}

/// Global Riverpod Provider exposing the decoupled subscription service
final proSubscriptionProvider =
    StateNotifierProvider<MockRevenueCatNotifier, ProSubscriptionState>((ref) {
  return MockRevenueCatNotifier();
});
