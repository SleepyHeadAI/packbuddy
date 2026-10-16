import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/security_service.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/document_viewer_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1 Verification: Gradle, SDK & Android Manifest Configuration', () {
    test('build.gradle.kts has compileSdk 37, minSdk 24, targetSdk 36, multiDex, minify, and proguard', () {
      final buildGradle = File('android/app/build.gradle.kts').readAsStringSync();
      expect(buildGradle, contains('compileSdk = 37'));
      expect(buildGradle, contains('minSdk = 24'));
      expect(buildGradle, contains('targetSdk = 36'));
      expect(buildGradle, contains('multiDexEnabled = true'));
      expect(buildGradle, contains('isMinifyEnabled = true'));
      expect(buildGradle, contains('isShrinkResources = true'));
      expect(buildGradle, contains('proguard-rules.pro'));
    });

    test('gradle.properties contains required SDK 37, AndroidX, and Jetifier flags', () {
      final properties = File('android/gradle.properties').readAsStringSync();
      expect(properties, contains('android.suppressUnsupportedCompileSdk=37'));
      expect(properties, contains('android.useAndroidX=true'));
      expect(properties, contains('android.enableJetifier=true'));
    });

    test('AndroidManifest.xml contains BILLING permission and allowBackup="false"', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest, contains('com.android.vending.BILLING'));
      expect(manifest, contains('android:allowBackup="false"'));
    });
  });

  group('Phase 2 Verification: Official In-App Purchase Service Integration', () {
    test('MockRevenueCatNotifier supports monthly & annual plans with test purchases enabled', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(proSubscriptionProvider.notifier);
      expect(container.read(proSubscriptionProvider).isPro, isFalse);

      notifier.selectPlan(SubscriptionPlan.monthly);
      expect(container.read(proSubscriptionProvider).activePlan, SubscriptionPlan.monthly);

      final purchasedMonthly = await notifier.purchaseActivePlan();
      expect(purchasedMonthly, isTrue);
      expect(container.read(proSubscriptionProvider).isPro, isTrue);

      await notifier.resetProStatus();
      expect(container.read(proSubscriptionProvider).isPro, isFalse);

      notifier.selectPlan(SubscriptionPlan.annual);
      expect(container.read(proSubscriptionProvider).activePlan, SubscriptionPlan.annual);

      final purchasedAnnual = await notifier.purchaseActivePlan();
      expect(purchasedAnnual, isTrue);
      expect(container.read(proSubscriptionProvider).isPro, isTrue);
    });

    test('MockRevenueCatNotifier restorePurchases restores entitlement cleanly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(proSubscriptionProvider.notifier);
      await notifier.resetProStatus();
      expect(container.read(proSubscriptionProvider).isPro, isFalse);

      final restored = await notifier.restorePurchases();
      expect(restored, isTrue);
      expect(container.read(proSubscriptionProvider).isPro, isTrue);
    });

    test('MockRevenueCatNotifier enforces store billing readiness when test mode is disabled', () async {
      final prevFlag = MockRevenueCatNotifier.enableTestPurchasesForUnitTests;
      final prevConfig = MockRevenueCatNotifier.isStoreBillingConfigured;
      try {
        MockRevenueCatNotifier.enableTestPurchasesForUnitTests = false;
        MockRevenueCatNotifier.isStoreBillingConfigured = false;

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(proSubscriptionProvider.notifier);
        final success = await notifier.purchaseActivePlan(isTestOrAdminConfirmation: false);

        expect(success, isFalse);
        expect(container.read(proSubscriptionProvider).errorMessage, contains('Store billing products'));
      } finally {
        MockRevenueCatNotifier.enableTestPurchasesForUnitTests = prevFlag;
        MockRevenueCatNotifier.isStoreBillingConfigured = prevConfig;
      }
    });
  });

  group('Phase 3 Verification: Anti-Tamper, Security & FLAG_SECURE', () {
    test('SecurityService toggles secure screen active state', () async {
      final security = SecurityService.instance;
      expect(security.isSecureScreenActive, isFalse);

      await security.enableSecureScreen();
      expect(security.isSecureScreenActive, isTrue);

      await security.disableSecureScreen();
      expect(security.isSecureScreenActive, isFalse);
    });

    testWidgets('VaultScreen enables FLAG_SECURE on mount and disables on dispose', (tester) async {
      final security = SecurityService.instance;
      await security.disableSecureScreen();
      expect(security.isSecureScreenActive, isFalse);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: VaultScreen(),
          ),
        ),
      );
      await tester.pump();

      // Screen is mounted: secure screen must be active
      expect(security.isSecureScreenActive, isTrue);

      // Unmount screen
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // Screen is disposed: secure screen must be deactivated
      expect(security.isSecureScreenActive, isFalse);
    });

    testWidgets('DocumentViewerScreen enables FLAG_SECURE on mount and disables on dispose', (tester) async {
      final security = SecurityService.instance;
      await security.disableSecureScreen();
      expect(security.isSecureScreenActive, isFalse);

      final dummyDoc = Document(
        id: 'doc_sec_1',
        title: 'Sensitive Passport',
        category: 'Passport',
        localImagePath: 'test/non_existent.jpg',
        createdAt: DateTime(2026, 10, 16),
        updatedAt: DateTime(2026, 10, 16),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: DocumentViewerScreen(document: dummyDoc),
          ),
        ),
      );
      await tester.pump();

      expect(security.isSecureScreenActive, isTrue);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      expect(security.isSecureScreenActive, isFalse);
    });

    test('proguard-rules.pro exists and protects Firebase, PostHog, SQLite, Billing, and Flutter', () {
      final file = File('android/app/proguard-rules.pro');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('com.google.firebase'));
      expect(content, contains('com.posthog'));
      expect(content, contains('com.dooboolab.flutterinapppurchase'));
      expect(content, contains('io.flutter.plugins'));
      expect(content, contains('com.tekartik.sqflite'));
    });

    test('firestore.rules protects totalVaultStorageBytes, isPremium, and ban attributes', () {
      final rules = File('firestore.rules').readAsStringSync();
      expect(rules, contains('totalVaultStorageBytes'));
      expect(rules, contains('isPremium'));
      expect(rules, contains('banStatus'));
      expect(rules, contains('banExpiresAt'));
      expect(rules, contains('restrictedFeatures'));
    });
  });
}
