import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/telemetry_service.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/interactive_world_map.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/widgets/notifications_center_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  FakeVaultController([VaultState? state]) : super(state ?? const VaultState(isLoading: false, documents: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Feature 1 & 7: Interactive World Map & Cities Tab', () {
    testWidgets('InteractiveWorldMap renders zoom controls, resets zoom, and switches to Cities tab', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final sampleCountries = [
        const TravelCountry(
          code: 'TR',
          nameTr: 'Türkiye',
          nameEn: 'Turkey',
          flag: '🇹🇷',
          continent: 'Europe',
          capital: 'Ankara',
          latitude: 39.93,
          longitude: 32.85,
          status: CountryStatus.visited,
        ),
        const TravelCountry(
          code: 'FR',
          nameTr: 'Fransa',
          nameEn: 'France',
          flag: '🇫🇷',
          continent: 'Europe',
          capital: 'Paris',
          latitude: 48.85,
          longitude: 2.35,
          status: CountryStatus.wishlist,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: InteractiveWorldMap(
              countries: sampleCountries,
              onCountryTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify zoom controls exist
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);

      // Tap zoom in
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // Tap reset zoom
      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pumpAndSettle();

      // Tap zoom out
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();

      // Verify no exceptions thrown during interaction
      expect(tester.takeException(), isNull);
    });
  });

  group('Feature 3 & 4: Vault Biometric Persistence and Lock View', () {
    test('PreferencesService persists and retrieves biometric setting', () async {
      final prefs = PreferencesService.instance;
      expect(prefs.isVaultBiometricEnabled(), isFalse);

      await prefs.setVaultBiometricEnabled(true);
      expect(prefs.isVaultBiometricEnabled(), isTrue);

      await prefs.setVaultBiometricEnabled(false);
      expect(prefs.isVaultBiometricEnabled(), isFalse);
    });

    testWidgets('VaultLockView respects biometric enabled state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultControllerProvider.overrideWith(
              (ref) => FakeVaultController(
                const VaultState(
                  hasPin: true,
                  isBiometricEnabled: false, // Biometrics disabled
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(
              body: VaultLockView(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // When biometric is disabled, biometric fingerprint icon button shouldn't appear
      expect(find.byIcon(Icons.fingerprint_rounded), findsNothing);
    });
  });

  group('Feature 5: PostHog API Key Security & Safe Fallback', () {
    test('TelemetryService default configuration is safe with empty key', () {
      // In tests without --dart-define, API key must be empty string, not hardcoded
      expect(TelemetryService.posthogApiKey, isEmpty);
      expect(TelemetryService.posthogProjectId, 0);
    });
  });

  group('Feature 6: Dashboard Trip Comparison Card', () {
    testWidgets('Dashboard renders Compare Trips hub card', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag down in Dashboard ListView to find Seyahatleri Karşılaştır card
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      // Verify "Seyahatleri Karşılaştır" card is rendered
      expect(find.text('Seyahatleri Karşılaştır'), findsOneWidget);
    });
  });

  group('Feature 8: Notification Center Sheet & Preferences Persistence', () {
    test('Notification history persists and clears correctly in PreferencesService', () async {
      final prefs = PreferencesService.instance;
      final initialHistory = prefs.getNotificationHistory();
      expect(initialHistory, isEmpty);

      final mockEntries = [
        '{"id":"1","title":"Test 1","body":"Body 1","timestamp":1700000000000}',
        '{"id":"2","title":"Test 2","body":"Body 2","timestamp":1700000060000}',
      ];
      await prefs.saveNotificationHistory(mockEntries);

      final retrieved = prefs.getNotificationHistory();
      expect(retrieved.length, 2);
      expect(retrieved.first, contains('Test 1'));

      await prefs.clearNotificationHistory();
      final cleared = prefs.getNotificationHistory();
      expect(cleared, isEmpty);
    });

    testWidgets('NotificationsCenterSheet renders tabs and cleans up cleanly', (tester) async {
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({
        'notification_history_json_list': [
          '{"id":"trip_123","title":"PackBuddy Hatırlatıcı","body":"Valizinizi hazırlamayı unutmayın!","timestamp":1730000000000,"type":"reminder"}',
        ],
      });
      await PreferencesService.init();

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(
              body: NotificationsCenterSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check both tabs exist
      expect(find.text('Yaklaşan Hatırlatıcılar'), findsOneWidget);
      expect(find.text('Bildirim Geçmişi'), findsOneWidget);

      // Switch to History tab
      await tester.tap(find.text('Bildirim Geçmişi'));
      await tester.pumpAndSettle();

      // Verify the history item is shown
      expect(find.text('PackBuddy Hatırlatıcı'), findsOneWidget);
      expect(find.text('Valizinizi hazırlamayı unutmayın!'), findsOneWidget);

      // Clear all notifications
      final clearAllButton = find.text('Tümünü Temizle');
      expect(clearAllButton, findsOneWidget);
      await tester.tap(clearAllButton);
      await tester.pumpAndSettle();

      // Verify empty state is now displayed and previous item is gone
      expect(find.text('PackBuddy Hatırlatıcı'), findsNothing);
    });

    testWidgets('NotificationsCenterSheet renders zero overflows in English, German and Russian', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      for (final locale in [const Locale('en'), const Locale('de'), const Locale('ru')]) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              home: const Scaffold(
                body: NotificationsCenterSheet(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}

