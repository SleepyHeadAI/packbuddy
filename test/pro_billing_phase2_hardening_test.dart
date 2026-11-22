import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/pro_entitlement_service.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage whose every call fails, simulating an Android Keystore error.
class _ThrowingStorage implements FlutterSecureStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<dynamic>.error(Exception('keystore unavailable'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = ProEntitlementService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    service.setMockStorage(null);
    await PreferencesService.init();
  });

  group('A2 - no device-global Pro fallback', () {
    test('legacy global secure key never grants Pro to a uid and is purged', () async {
      FlutterSecureStorage.setMockInitialValues({'secure_is_pro_member': 'true'});

      expect(await service.resolveEffectivePro(uid: 'user_b'), isFalse);

      const storage = FlutterSecureStorage();
      expect(await storage.read(key: 'secure_is_pro_member'), isNull);
    });

    test('Pro of account A is not visible to account B', () async {
      await service.setProEntitlement(isPro: true, source: 'google_play_packbuddy_pro_annual', uid: 'user_a');

      expect(await service.resolveEffectivePro(uid: 'user_a'), isTrue);
      expect(await service.resolveEffectivePro(uid: 'user_b'), isFalse);
      expect(PreferencesService.instance.isProUser(uid: 'user_b'), isFalse);
    });

    test('PreferencesService no longer writes a device-global Pro flag', () async {
      await PreferencesService.instance.setProUser(true, uid: 'user_a');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PreferencesService.keyIsPro), isNull);
      expect(PreferencesService.instance.isProUser(uid: 'user_b'), isFalse);
    });
  });

  group('A1 - remote sync must not revoke store purchases', () {
    test('metadata-only user document carries no Pro key', () {
      expect(
        ProEntitlementService.hasRemoteProKey({
          'subscriptionProductId': 'packbuddy_pro_annual',
          'subscriptionUpdatedAt': 'x',
          'lastActiveAt': 'y',
        }),
        isFalse,
      );
      expect(ProEntitlementService.hasRemoteProKey({'adminGrantedPro': true}), isTrue);
    });

    test('remote isPro=false keeps a Google Play entitlement', () async {
      await service.setProEntitlement(
        isPro: true,
        expiresAt: ProEntitlementService.expiryForProduct('packbuddy_pro_monthly'),
        source: 'google_play_packbuddy_pro_monthly',
        uid: 'u1',
      );

      final result = await service.applyRemoteEntitlement(remoteIsPro: false, source: 'firestore_sync', uid: 'u1');

      expect(result, isTrue);
      expect(await service.resolveEffectivePro(uid: 'u1'), isTrue);
    });

    test('remote isPro=false revokes an admin-granted entitlement', () async {
      await service.setProEntitlement(isPro: true, source: 'admin_live_grant', uid: 'u1');

      final result = await service.applyRemoteEntitlement(remoteIsPro: false, source: 'firestore_sync', uid: 'u1');

      expect(result, isFalse);
      expect(await service.resolveEffectivePro(uid: 'u1'), isFalse);
    });

    test('remote isPro=true grants Pro', () async {
      final result = await service.applyRemoteEntitlement(remoteIsPro: true, source: 'admin_live_grant', uid: 'u2');
      expect(result, isTrue);
    });
  });

  group('A3 - expiry & fail-closed', () {
    test('plan-length expiry is computed per product', () {
      final from = DateTime(2026, 1, 1);
      expect(
        ProEntitlementService.expiryForProduct('packbuddy_pro_monthly', from: from),
        from.add(const Duration(days: 30 + 3)),
      );
      expect(
        ProEntitlementService.expiryForProduct('packbuddy_pro_annual', from: from),
        from.add(const Duration(days: 365 + 3)),
      );
    });

    test('expired entitlement resolves to false', () async {
      await service.setProEntitlement(
        isPro: true,
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        source: 'google_play_packbuddy_pro_monthly',
        uid: 'u3',
      );
      expect(await service.resolveEffectivePro(uid: 'u3'), isFalse);
    });

    test('Keystore failure falls back to false, not to SharedPreferences', () async {
      await PreferencesService.instance.setProUser(true, uid: 'u4');
      service.setMockStorage(_ThrowingStorage());

      expect(await service.resolveEffectivePro(uid: 'u4'), isFalse);
    });

    test('store purchase event stores plan-length expiry with store source', () async {
      final notifier = BillingSubscriptionNotifier();
      addTearDown(notifier.dispose);

      await notifier.handlePurchaseUpdates([
        PurchaseDetails(
          productID: BillingSubscriptionNotifier.productMonthly,
          verificationData: PurchaseVerificationData(
            localVerificationData: '',
            serverVerificationData: '',
            source: 'google_play',
          ),
          transactionDate: null,
          status: PurchaseStatus.purchased,
        ),
      ]);

      expect(notifier.state.isPro, isTrue);
      expect(await service.currentSource(), 'google_play_packbuddy_pro_monthly');

      const storage = FlutterSecureStorage();
      final rawExpiry = await storage.read(key: 'guest_secure_pro_expires_at');
      expect(rawExpiry, isNotNull);
      final expiry = DateTime.fromMillisecondsSinceEpoch(int.parse(rawExpiry!));
      final days = expiry.difference(DateTime.now()).inDays;
      expect(days, inInclusiveRange(31, 33));
    });
  });

  group('A4 - store binding', () {
    test('applicationUserName is sha256(uid)', () {
      expect(
        BillingSubscriptionNotifier.obfuscatedAccountIdFor('uid_123'),
        sha256.convert(utf8.encode('uid_123')).toString(),
      );
    });

    test('first purchase uses a plain PurchaseParam (no subscription change)', () {
      final notifier = BillingSubscriptionNotifier();
      addTearDown(notifier.dispose);
      final param = notifier.buildPurchaseParam(ProductDetails(
        id: BillingSubscriptionNotifier.productAnnual,
        title: 'Annual',
        description: '',
        price: '\$4.99',
        rawPrice: 4.99,
        currencyCode: 'USD',
      ));
      expect(param.runtimeType, PurchaseParam);
    });

    test('empty restore answer completes without granting Pro', () async {
      final notifier = BillingSubscriptionNotifier();
      addTearDown(notifier.dispose);
      await notifier.handlePurchaseUpdates(const []);
      expect(notifier.state.isPro, isFalse);
    });
  });

  group('Paket A - online refund/cancel detection', () {
    final defaultIsOnline = BillingSubscriptionNotifier.isOnline;
    setUp(() => BillingSubscriptionNotifier.isOnline = () async => true);
    tearDown(() => BillingSubscriptionNotifier.isOnline = defaultIsOnline);

    Future<void> grantStorePro() => service.setProEntitlement(
          isPro: true,
          expiresAt: ProEntitlementService.expiryForProduct(BillingSubscriptionNotifier.productMonthly),
          source: 'google_play_packbuddy_pro_monthly',
        );

    PurchaseDetails storeError() => PurchaseDetails(
          productID: '',
          verificationData: PurchaseVerificationData(
            localVerificationData: '',
            serverVerificationData: '',
            source: 'google_play',
          ),
          transactionDate: null,
          status: PurchaseStatus.error,
        );

    test('one clean "no subscription" keeps Pro; the 2nd consecutive one revokes it at once', () async {
      await grantStorePro();
      final notifier = BillingSubscriptionNotifier();
      addTearDown(notifier.dispose);

      await notifier.handlePurchaseUpdates(const []);
      expect(await service.resolveEffectivePro(), isTrue);

      await notifier.handlePurchaseUpdates(const []);
      expect(await service.resolveEffectivePro(), isFalse);
      expect(notifier.state.isPro, isFalse);
    });

    test('offline answers and store/network errors never count', () async {
      await grantStorePro();
      final notifier = BillingSubscriptionNotifier();
      addTearDown(notifier.dispose);

      BillingSubscriptionNotifier.isOnline = () async => false;
      await notifier.handlePurchaseUpdates(const []);
      await notifier.handlePurchaseUpdates(const []);
      expect(await service.resolveEffectivePro(), isTrue);

      BillingSubscriptionNotifier.isOnline = () async => true;
      await notifier.handlePurchaseUpdates([storeError()]);
      await notifier.handlePurchaseUpdates([storeError()]);
      expect(await service.resolveEffectivePro(), isTrue);

      // First clean online answer only starts the streak.
      await notifier.handlePurchaseUpdates(const []);
      expect(await service.resolveEffectivePro(), isTrue);
    });

    test('a store re-verification between two "none" answers resets the streak', () async {
      await grantStorePro();
      expect(await service.recordStoreNoActiveSubscription(), isTrue);
      await grantStorePro();
      expect(await service.recordStoreNoActiveSubscription(), isTrue);
    });

    test('admin-granted Pro is never revoked by store answers', () async {
      await service.setProEntitlement(isPro: true, source: 'admin_live_grant');
      for (var i = 0; i < 3; i++) {
        expect(await service.recordStoreNoActiveSubscription(), isTrue);
      }
    });
  });
}
