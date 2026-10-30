import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/security_service.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/auth/auth_screen.dart';
import 'package:packbuddy/features/budget/domain/emergency_guide.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_progress_card.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('PHASE 1: Paywall Production Purchase Flow & Apple Sign-In Removal', () {
    test('MockRevenueCatNotifier handles store unavailable error gracefully for regular users', () async {
      final notifier = MockRevenueCatNotifier();
      // Ensure unit test bypass is disabled to test production-like behavior
      MockRevenueCatNotifier.enableTestPurchasesForUnitTests = false;

      // When store is unreachable / SKU not active
      final success = await notifier.purchaseActivePlan();
      // Regular user without store connection gets error message 'store_unavailable'
      expect(success, isFalse);
      expect(notifier.state.errorMessage, 'store_unavailable');

      // Reset test mode for other unit tests
      MockRevenueCatNotifier.enableTestPurchasesForUnitTests = true;
    });

    test('MockRevenueCatNotifier sandbox mode succeeds for Super Admin or Unit Test mode', () async {
      final notifier = MockRevenueCatNotifier();
      MockRevenueCatNotifier.enableTestPurchasesForUnitTests = true;

      final success = await notifier.purchaseActivePlan();
      expect(success, isTrue);
      expect(notifier.state.isPro, isTrue);
      expect(notifier.state.errorMessage, isNull);
    });

    testWidgets('AuthScreen does NOT render Apple Sign-In button on Android', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: AuthScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('Continue with Apple'), findsNothing);
      expect(find.byIcon(Icons.apple), findsNothing);
    });
  });

  group('PHASE 2: Real-Time Shared Trip Synchronization', () {
    test('SyncEngine manages shared trip listeners lifecycle without error', () {
      final engine = SyncEngine();

      expect(() => engine.listenToSharedTrip('trip-test-123'), returnsNormally);
      expect(() => engine.cancelSharedTripListener('trip-test-123'), returnsNormally);
      expect(() => engine.cancelAllSharedTripListeners(), returnsNormally);

      engine.dispose();
    });
  });

  group('PHASE 3: Vault AES-256 At-Rest Local File Encryption', () {
    test('Encrypts and decrypts byte stream with PBENC1 header roundtrip', () async {
      final originalData = Uint8List.fromList(utf8.encode('Top Secret Passport Document Data 12345!'));

      expect(SecurityService.instance.isEncrypted(originalData), isFalse);

      final encryptedData = await SecurityService.instance.encryptBytes(originalData);

      // Verify encrypted output has PBENC1 header
      expect(SecurityService.instance.isEncrypted(encryptedData), isTrue);
      expect(encryptedData.length, greaterThan(originalData.length + 6 + 16));
      expect(encryptedData.sublist(0, 6), equals([80, 66, 69, 78, 67, 49]));

      // Verify decrypted data matches original exactly
      final decryptedData = await SecurityService.instance.decryptBytes(encryptedData);
      expect(decryptedData, equals(originalData));
      expect(utf8.decode(decryptedData), 'Top Secret Passport Document Data 12345!');
    });

    test('Backward compatibility: unencrypted legacy files pass through untouched', () async {
      final legacyData = Uint8List.fromList(utf8.encode('Legacy unencrypted file contents'));

      expect(SecurityService.instance.isEncrypted(legacyData), isFalse);

      final result = await SecurityService.instance.decryptBytes(legacyData);
      expect(result, equals(legacyData));
      expect(utf8.decode(result), 'Legacy unencrypted file contents');
    });
  });

  group('PHASE 4: Offline Emergency & Essential Local Phrases Guide', () {
    test('Resolves Turkey (TR) emergency numbers and Turkish phrases', () {
      final guide = EmergencyGuide.forCountry('TR');
      expect(guide.countryCode, 'TR');
      expect(guide.police, '112');
      expect(guide.ambulance, '112');
      expect(guide.fire, '112');
      expect(guide.generalSos, '112');
      expect(guide.powerPlugs, contains('Type C'));
      expect(guide.phrases.length, 6);
      expect(guide.phrases.any((p) => p.phrase.contains('Merhaba')), isTrue);
    });

    test('Resolves United States (US) emergency numbers and English phrases', () {
      final guide = EmergencyGuide.forCountry('US');
      expect(guide.countryCode, 'US');
      expect(guide.police, '911');
      expect(guide.generalSos, '911');
      expect(guide.powerPlugs, contains('Type A'));
      expect(guide.phrases.any((p) => p.phrase == 'Hello'), isTrue);
    });

    test('Resolves United Kingdom (GB / UK) emergency numbers', () {
      final guide = EmergencyGuide.forCountry('GB');
      expect(guide.countryCode, 'GB');
      expect(guide.police, '999');
      expect(guide.powerPlugs, contains('Type G'));
    });

    test('Resolves Japan (JP) emergency numbers and Japanese phrases', () {
      final guide = EmergencyGuide.forCountry('JP');
      expect(guide.countryCode, 'JP');
      expect(guide.police, '110');
      expect(guide.ambulance, '119');
      expect(guide.phrases.any((p) => p.phrase.contains('こんにちは')), isTrue);
    });

    test('Smart regional fallback handles unmapped or unknown countries smoothly', () {
      final guide = EmergencyGuide.forCountry('XYZ_UNKNOWN');
      expect(guide.generalSos, isNotEmpty);
      expect(guide.police, isNotEmpty);
      expect(guide.phrases.length, 6);

      final nullGuide = EmergencyGuide.forCountry(null, 'Unknown Desert Camp');
      expect(nullGuide.generalSos, isNotEmpty);
      expect(nullGuide.phrases.length, 6);
    });
  });

  group('PHASE 5: 120 FPS Scroll Optimization & Budget Threshold Alerts', () {
    testWidgets('BudgetProgressCard renders no alert below 85% limit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: BudgetProgressCard(
              budgetLimit: 1000,
              totalSpent: 500, // 50%
              currency: 'USD',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BudgetProgressCard), findsOneWidget);
      expect(find.text('Approaching limit (85%)'), findsNothing);
      expect(find.text('Budget limit exceeded!'), findsNothing);
    });

    testWidgets('BudgetProgressCard displays 85% warning alert when spending reaches 85%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: BudgetProgressCard(
              budgetLimit: 1000,
              totalSpent: 870, // 87%
              currency: 'USD',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Approaching limit (85%)'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('BudgetProgressCard displays 100% danger alert when spending exceeds limit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(
            body: BudgetProgressCard(
              budgetLimit: 1000,
              totalSpent: 1050, // 105%
              currency: 'USD',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Budget limit exceeded!'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('BudgetAnalyticsCard displays alert banner when budget reaches threshold', (tester) async {
      final trip = Trip(
        id: 'trip-test',
        title: 'Trip to Tokyo',
        destination: 'Tokyo',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        budgetLimit: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final expenses = [
        Expense(
          id: 'exp-1',
          tripId: 'trip-test',
          title: 'Hotel',
          amount: 900.0,
          currency: 'USD',
          category: 'accommodation',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: BudgetAnalyticsCard(
                expenses: expenses,
                tripCurrency: 'USD',
                totalSpent: 900.0,
                trip: trip,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BudgetAnalyticsCard), findsOneWidget);
      expect(find.text('Approaching limit (85%)'), findsOneWidget);
    });
  });

  group('PHASE 6: 20-Language Parity Tests for All 18 Injected Keys', () {
    const supportedLocales = [
      Locale('en'), Locale('tr'), Locale('de'), Locale('fr'), Locale('es'),
      Locale('it'), Locale('pt'), Locale('nl'), Locale('ru'), Locale('zh'),
      Locale('ja'), Locale('ko'), Locale('ar'), Locale('hi'), Locale('id'),
      Locale('pl'), Locale('el'), Locale('vi'), Locale('th'), Locale('sv'),
    ];

    for (final loc in supportedLocales) {
      test('Language ${loc.languageCode} resolves all newly injected Phase 1-5 keys', () async {
        final l10n = await AppLocalizations.delegate.load(loc);

        // Phase 1
        expect(l10n.storeUnavailableMessage, isNotEmpty, reason: 'storeUnavailableMessage missing in ${loc.languageCode}');

        // Phase 4
        expect(l10n.emergencyGuideTitle, isNotEmpty, reason: 'emergencyGuideTitle missing in ${loc.languageCode}');
        expect(l10n.emergencyPolice, isNotEmpty, reason: 'emergencyPolice missing in ${loc.languageCode}');
        expect(l10n.emergencyAmbulance, isNotEmpty, reason: 'emergencyAmbulance missing in ${loc.languageCode}');
        expect(l10n.emergencyFire, isNotEmpty, reason: 'emergencyFire missing in ${loc.languageCode}');
        expect(l10n.emergencyGeneralSos, isNotEmpty, reason: 'emergencyGeneralSos missing in ${loc.languageCode}');
        expect(l10n.emergencyPowerPlugs, isNotEmpty, reason: 'emergencyPowerPlugs missing in ${loc.languageCode}');
        expect(l10n.emergencyPhrases, isNotEmpty, reason: 'emergencyPhrases missing in ${loc.languageCode}');
        expect(l10n.emergencyCopyTooltip, isNotEmpty, reason: 'emergencyCopyTooltip missing in ${loc.languageCode}');
        expect(l10n.emergencyCopied, isNotEmpty, reason: 'emergencyCopied missing in ${loc.languageCode}');
        expect(l10n.phraseHello, isNotEmpty, reason: 'phraseHello missing in ${loc.languageCode}');
        expect(l10n.phraseThankYou, isNotEmpty, reason: 'phraseThankYou missing in ${loc.languageCode}');
        expect(l10n.phraseHowMuch, isNotEmpty, reason: 'phraseHowMuch missing in ${loc.languageCode}');
        expect(l10n.phraseHelp, isNotEmpty, reason: 'phraseHelp missing in ${loc.languageCode}');
        expect(l10n.phraseHospital, isNotEmpty, reason: 'phraseHospital missing in ${loc.languageCode}');
        expect(l10n.phraseEnglish, isNotEmpty, reason: 'phraseEnglish missing in ${loc.languageCode}');

        // Phase 5
        expect(l10n.budgetAlert85, isNotEmpty, reason: 'budgetAlert85 missing in ${loc.languageCode}');
        expect(l10n.budgetAlert100, isNotEmpty, reason: 'budgetAlert100 missing in ${loc.languageCode}');
      });
    }
  });
}
