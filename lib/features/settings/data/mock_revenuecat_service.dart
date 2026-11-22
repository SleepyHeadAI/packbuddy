import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/telemetry_service.dart';
import '../../../../core/services/pro_entitlement_service.dart';

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
class BillingSubscriptionNotifier extends StateNotifier<ProSubscriptionState>
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

  /// How long [restorePurchases] waits for the store to answer on the purchase stream.
  static Duration restoreTimeout = const Duration(seconds: 7);

  /// Online check before trusting a store "no subscription" answer: Play answers from its
  /// local cache when offline, so only an answer given while online may revoke Pro.
  @visibleForTesting
  static Future<bool> Function() isOnline = () async {
    try {
      final result = await InternetAddress.lookup('play.googleapis.com').timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  };

  /// Whether store billing backend is currently active on this build.
  static bool isStoreBillingConfigured = true;

  /// Test-mode flag to allow automated unit and widget tests to simulate purchases without real store interaction.
  /// Only honoured outside release builds, so it can never grant Pro in production.
  static bool enableTestPurchasesForUnitTests = () {
    if (kReleaseMode) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }();

  /// Debug-only escape hatch for sandbox/admin test purchases. Always false in release (A4).
  static bool _allowDebugSandbox(bool isTestOrAdminConfirmation) =>
      kDebugMode && isTestOrAdminConfirmation;

  /// Obfuscated account id sent to Google Play (`applicationUserName`): sha256(uid).
  /// Play uses it for fraud detection and we use it to bind a purchase to the account.
  @visibleForTesting
  static String obfuscatedAccountIdFor(String uid) =>
      sha256.convert(utf8.encode(uid)).toString();

  /// Backward compatibility hook
  static Future<void> initStoreSdk() async {
    // InAppPurchase does not require explicit static configuration
  }

  /// Latest known store purchase per product (needed for subscription plan changes).
  final Map<String, PurchaseDetails> _ownedPurchases = {};

  /// Pending restore request waiting for the purchase stream.
  Completer<bool>? _restoreCompleter;

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

  BillingSubscriptionNotifier([PreferencesService? prefs, InAppPurchase? iap])
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
    _initSecureEntitlement();
    _checkRemoteEntitlementOnStartup();
    _startLiveListener();
  }

  Future<void> _initSecureEntitlement() async {
    final uid = _auth?.currentUser?.uid;
    final isSecurePro = await ProEntitlementService.instance.resolveEffectivePro(uid: uid);
    if (!mounted) return;
    if (isSecurePro != state.isPro) {
      state = state.copyWith(isPro: isSecurePro);
    }
  }

  void _startLiveListener() {
    final uid = _auth?.currentUser?.uid;
    if (uid == null) return;
    ProEntitlementService.instance.startLiveUserEntitlementListener(
      uid,
      onStatusUpdated: (isLivePro) {
        if (!mounted) return;
        if (state.isPro != isLivePro) {
          state = state.copyWith(isPro: isLivePro);
          TelemetryService.instance.logProStatusChanged(
            isPro: isLivePro,
            source: 'firestore_live_admin_sync',
          );
        }
      },
    );
  }

  void _checkRemoteEntitlementOnStartup() {
    final uid = _auth?.currentUser?.uid;
    if (uid == null) return;
    final firestore = _firestore;
    if (firestore == null) return;

    firestore.collection('users').doc(uid).get().then((doc) async {
      if (!mounted) return;
      final data = doc.data();
      if (!doc.exists || data == null || !ProEntitlementService.hasRemoteProKey(data)) return;
      final isPro = await ProEntitlementService.instance.applyRemoteEntitlement(
        remoteIsPro: ProEntitlementService.remoteProValue(data),
        expiresAt: ProEntitlementService.remoteExpiresAt(data),
        source: 'firestore_startup',
        uid: uid,
      );
      setResolvedProStatus(isPro);
    }).catchError((_) {});
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
          state = state.copyWith(isLoading: false, errorMessage: 'billing_error');
          _completeRestore(false);
        },
      );

      await queryProductDetails();

      // Silent store re-verification on startup: active subscriptions arrive as `restored`
      // events and refresh `expiresAt` / `lastVerifiedAt` from the store itself.
      try {
        await _iap.restorePurchases(applicationUserName: _currentObfuscatedAccountId());
      } catch (e) {
        debugPrint('[SubscriptionService] Silent store refresh notice: $e');
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Billing initialization error: $e');
    }
  }

  String? _currentObfuscatedAccountId() {
    final uid = _auth?.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    return obfuscatedAccountIdFor(uid);
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

  void _completeRestore(bool result) {
    final completer = _restoreCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  /// True when the purchase was made for a different PackBuddy account on this Play account.
  bool _belongsToAnotherAccount(PurchaseDetails details) {
    if (details is! GooglePlayPurchaseDetails) return false;
    final purchaseAccountId = details.billingClientPurchase.obfuscatedAccountId;
    if (purchaseAccountId == null || purchaseAccountId.isEmpty) return false; // legacy purchase
    final current = _currentObfuscatedAccountId();
    return current != null && purchaseAccountId != current;
  }

  @visibleForTesting
  Future<void> handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) =>
      _onPurchaseStreamUpdated(purchaseDetailsList);

  Future<void> _onPurchaseStreamUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    // Android emits an empty list when a restore finds no purchases.
    if (purchaseDetailsList.isEmpty) {
      _completeRestore(false);
      await _onStoreReportedNoSubscription();
      return;
    }

    var grantedInBatch = false;
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(isLoading: true, errorMessage: null);
          break;
        case PurchaseStatus.error:
          debugPrint('[SubscriptionService] purchase error: ${purchaseDetails.error?.message}');
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'purchase_failed',
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

          if (!productIds.contains(purchaseDetails.productID)) break;

          // A purchase bound to a different app account must not unlock Pro here.
          if (_belongsToAnotherAccount(purchaseDetails)) {
            debugPrint('[SubscriptionService] Ignoring purchase bound to another account.');
            break;
          }

          _ownedPurchases[purchaseDetails.productID] = purchaseDetails;
          grantedInBatch = true;

          // 2. Persist securely with a plan-length expiry (A3). Restored events on Android
          // only include active subscriptions, so the period is counted from now.
          final currentUid = _auth?.currentUser?.uid;
          final source = 'google_play_${purchaseDetails.productID}';
          await ProEntitlementService.instance.setProEntitlement(
            isPro: true,
            expiresAt: ProEntitlementService.expiryForProduct(purchaseDetails.productID),
            source: source,
            uid: currentUid,
          );
          final wasPro = state.isPro;
          state = state.copyWith(
            isPro: true,
            isLoading: false,
            errorMessage: null,
            activePlan: purchaseDetails.productID == productMonthly
                ? SubscriptionPlan.monthly
                : SubscriptionPlan.annual,
          );

          if (purchaseDetails.status != PurchaseStatus.purchased) {
            if (!wasPro) {
              TelemetryService.instance.logProStatusChanged(isPro: true, source: source);
            }
            break;
          }

          // 3. Update Firestore users/{uid} with subscription metadata (no Pro fields: rules block self-elevation)
          final firestore = _firestore ?? (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);
          if (currentUid != null && firestore != null) {
            try {
              await firestore.collection('users').doc(currentUid).set({
                'subscriptionProductId': purchaseDetails.productID,
                'subscriptionPurchaseId': purchaseDetails.purchaseID ?? '',
                'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            } catch (e) {
              debugPrint('[SubscriptionService] Firestore subscription update notice: $e');
            }
          }

          // 4. Telemetry & conversion funnel
          TelemetryService.instance.logPurchaseCompleted(
            productId: purchaseDetails.productID,
            plan: purchaseDetails.productID == productMonthly ? 'monthly' : 'annual',
            purchaseId: purchaseDetails.purchaseID,
          );
          TelemetryService.instance.logProStatusChanged(isPro: true, source: source);
          break;
      }
    }

    if (grantedInBatch) {
      _completeRestore(true);
    } else if (purchaseDetailsList.every((p) =>
        p.status == PurchaseStatus.restored || p.status == PurchaseStatus.error)) {
      // A restore answered, but nothing usable for this account was found.
      _completeRestore(false);
      if (purchaseDetailsList.every((p) => p.status == PurchaseStatus.restored)) {
        await _onStoreReportedNoSubscription();
      }
    }
  }

  /// A store query finished without error and found no active subscription for this account.
  /// Restore failures (network / billing service) throw instead and never reach here.
  Future<void> _onStoreReportedNoSubscription() async {
    final uid = _auth?.currentUser?.uid;
    final service = ProEntitlementService.instance;
    // Only store-sourced Pro is revocable here; skip the network probe for everyone else.
    if (!ProEntitlementService.isStoreSource(await service.currentSource(uid: uid))) return;
    if (!await isOnline()) return;
    final isPro = await service.recordStoreNoActiveSubscription(uid: uid);
    if (isPro || !mounted) return;
    setResolvedProStatus(false);
    // A server-side grant (adminGrantedPro) still applies after the store entitlement is gone.
    _checkRemoteEntitlementOnStartup();
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

  /// Builds the store purchase param: binds the purchase to sha256(uid) and, when the user
  /// already owns the other plan, performs a Google Play subscription change (monthly↔annual).
  @visibleForTesting
  PurchaseParam buildPurchaseParam(ProductDetails details) {
    final accountId = _currentObfuscatedAccountId();

    PurchaseDetails? oldPurchase;
    for (final entry in _ownedPurchases.entries) {
      if (entry.key != details.id) {
        oldPurchase = entry.value;
        break;
      }
    }

    if (oldPurchase is GooglePlayPurchaseDetails) {
      final isUpgrade = details.id == productAnnual;
      return GooglePlayPurchaseParam(
        productDetails: details,
        applicationUserName: accountId,
        changeSubscriptionParam: ChangeSubscriptionParam(
          oldPurchaseDetails: oldPurchase,
          // Upgrade takes effect now with credit; downgrade waits for the current period to end.
          replacementMode: isUpgrade ? ReplacementMode.withTimeProration : ReplacementMode.deferred,
        ),
      );
    }

    return PurchaseParam(productDetails: details, applicationUserName: accountId);
  }

  /// Purchase subscription with strict store billing readiness and admin confirmation protection.
  @override
  Future<bool> purchasePlan(String productId, {bool isTestOrAdminConfirmation = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    TelemetryService.instance.logPurchaseStarted(
      productId: productId,
      plan: productId == productMonthly ? 'monthly' : 'annual',
    );

    if (enableTestPurchasesForUnitTests) {
      if (!isTestOrAdminConfirmation && !isStoreBillingConfigured) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'products_not_configured',
        );
        return false;
      }
      final currentUid = _auth?.currentUser?.uid;
      await ProEntitlementService.instance.setProEntitlement(
        isPro: true,
        expiresAt: ProEntitlementService.expiryForProduct(productId),
        source: 'unit_test_purchase',
        uid: currentUid,
      );
      state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
      TelemetryService.instance.logPurchaseCompleted(
        productId: productId,
        plan: productId == productMonthly ? 'monthly' : 'annual',
      );
      TelemetryService.instance.logProStatusChanged(isPro: true, source: 'purchase');
      return true;
    }

    if (!isStoreBillingConfigured && !_allowDebugSandbox(isTestOrAdminConfirmation)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'store_unavailable',
      );
      return false;
    }

    // Automatically trigger fresh queryProductDetails if not yet cached in state
    if (state.products[productId] == null && isStoreBillingConfigured && !enableTestPurchasesForUnitTests) {
      await queryProductDetails();
    }

    // Check if store product is loaded and available
    final details = state.products[productId];
    if (details != null) {
      try {
        final initiated = await _iap.buyNonConsumable(purchaseParam: buildPurchaseParam(details));
        return initiated;
      } catch (e) {
        debugPrint('[SubscriptionService] InAppPurchase buy error: $e');
        state = state.copyWith(isLoading: false, errorMessage: 'billing_error');
        return false;
      }
    }

    // Debug-only sandbox purchase fallback (never available in release builds)
    if (!_allowDebugSandbox(isTestOrAdminConfirmation)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'store_unavailable',
      );
      return false;
    }

    final currentUid = _auth?.currentUser?.uid;
    await ProEntitlementService.instance.setProEntitlement(
      isPro: true,
      expiresAt: ProEntitlementService.expiryForProduct(productId),
      source: 'debug_sandbox_purchase',
      uid: currentUid,
    );
    state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
    TelemetryService.instance.logProStatusChanged(isPro: true, source: 'debug_sandbox_purchase');
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
          errorMessage: 'products_not_configured',
        );
        return false;
      }
      final currentUid = _auth?.currentUser?.uid;
      await ProEntitlementService.instance.setProEntitlement(
        isPro: true,
        expiresAt: ProEntitlementService.expiryForProduct(
          state.activePlan == SubscriptionPlan.monthly ? productMonthly : productAnnual,
        ),
        source: 'unit_test_purchase',
        uid: currentUid,
      );
      state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
      TelemetryService.instance.logProStatusChanged(isPro: true, source: 'restore');
      return true;
    }

    if (!isStoreBillingConfigured && !_allowDebugSandbox(isTestOrAdminConfirmation)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'products_not_configured',
      );
      return false;
    }

    // 1. Server-granted Pro (admin) on users/{uid}: clients cannot self-write these fields.
    final currentUid = _auth?.currentUser?.uid;
    if (currentUid != null && _firestore != null) {
      try {
        final userDoc = await _firestore!.collection('users').doc(currentUid).get();
        final data = userDoc.data();
        if (userDoc.exists && data != null && ProEntitlementService.remoteProValue(data)) {
          await ProEntitlementService.instance.setProEntitlement(
            isPro: true,
            expiresAt: ProEntitlementService.remoteExpiresAt(data),
            source: 'firestore_restore',
            uid: currentUid,
          );
          state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
          TelemetryService.instance.logPurchaseRestored(source: 'firestore_restore');
          TelemetryService.instance.logProStatusChanged(isPro: true, source: 'firestore_restore');
          return true;
        }
      } catch (e) {
        debugPrint('[SubscriptionService] Firestore restore check error: $e');
      }
    }

    // 2. Ask the store and wait for its answer on the purchase stream (A4).
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final isAvailable = await _iap.isAvailable();
        if (isAvailable) {
          final restored = await _awaitStoreRestore();
          if (restored) {
            state = state.copyWith(isLoading: false);
            TelemetryService.instance.logPurchaseRestored(source: 'google_play_restore');
            return true;
          }
        }
      } catch (e) {
        debugPrint('[SubscriptionService] InAppPurchase restore error: $e');
      }
    }

    if (_allowDebugSandbox(isTestOrAdminConfirmation)) {
      await ProEntitlementService.instance.setProEntitlement(
        isPro: true,
        expiresAt: ProEntitlementService.expiryForProduct(productMonthly),
        source: 'debug_sandbox_purchase',
        uid: currentUid,
      );
      state = state.copyWith(isPro: true, isLoading: false, errorMessage: null);
      TelemetryService.instance.logPurchaseRestored(source: 'debug_sandbox_restore');
      TelemetryService.instance.logProStatusChanged(isPro: true, source: 'debug_sandbox_purchase');
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: 'no_active_subscription',
    );
    return false;
  }

  /// Triggers a store restore and completes when the purchase stream reports a result
  /// or after [restoreTimeout].
  Future<bool> _awaitStoreRestore() async {
    // Reuse an in-flight restore instead of racing two completers.
    final existing = _restoreCompleter;
    if (existing != null && !existing.isCompleted) {
      return existing.future;
    }
    final completer = Completer<bool>();
    _restoreCompleter = completer;
    try {
      await _iap.restorePurchases(applicationUserName: _currentObfuscatedAccountId());
      return await completer.future.timeout(restoreTimeout, onTimeout: () => false);
    } finally {
      if (identical(_restoreCompleter, completer)) {
        _restoreCompleter = null;
      }
    }
  }

  /// Reset Pro status (useful for QA testing and debug developer settings)
  @override
  Future<void> resetProStatus({String? uid}) async {
    await ProEntitlementService.instance.clearProEntitlement(uid: uid);
    state = state.copyWith(isPro: false);
    TelemetryService.instance.logProStatusChanged(isPro: false, source: 'reset');
  }

  /// Sets Pro status directly. Used by admin tooling; callers must have a verified source.
  @override
  Future<void> updateProStatus(bool isPro, {String? uid}) async {
    await ProEntitlementService.instance.setProEntitlement(
      isPro: isPro,
      source: 'update_pro_status',
      uid: uid,
    );
    setResolvedProStatus(isPro);
  }

  /// Reflects an already-resolved entitlement (from [ProEntitlementService]) in UI state
  /// without writing storage or refreshing verification timestamps.
  void setResolvedProStatus(bool isPro) {
    if (!mounted) return;
    if (state.isPro != isPro) {
      state = state.copyWith(isPro: isPro);
      TelemetryService.instance.logProStatusChanged(isPro: isPro, source: 'sync');
    }
  }

  /// Reloads Pro status for a specific or current user from user-scoped storage
  void reloadForUser({String? uid}) {
    final effectiveUid = uid ?? _auth?.currentUser?.uid;
    ProEntitlementService.instance.resolveEffectivePro(uid: effectiveUid).then((isPro) {
      setResolvedProStatus(isPro);
    });
  }

  @override
  void dispose() {
    _completeRestore(false);
    ProEntitlementService.instance.cancelLiveListener();
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    super.dispose();
  }
}

/// Backward compatibility alias for legacy tests and references
typedef MockRevenueCatNotifier = BillingSubscriptionNotifier;

/// Global Riverpod Provider exposing the decoupled subscription service
final proSubscriptionProvider =
    StateNotifierProvider<BillingSubscriptionNotifier, ProSubscriptionState>((ref) {
  return BillingSubscriptionNotifier();
});
