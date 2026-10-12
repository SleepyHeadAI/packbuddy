import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/l10n/l10n.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/core/theme/theme_provider.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeProNotifier extends StateNotifier<ProSubscriptionState> implements MockRevenueCatNotifier {
  FakeProNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Phase 5 - 20 Languages & Localization Verification', () {
    test('L10n supports all 20 languages', () {
      expect(L10n.all.length, 20);

      const expectedCodes = [
        'tr', 'en', 'es', 'fr', 'de', 'it', 'pt', 'ru',
        'zh', 'ja', 'ko', 'hi', 'ar', 'nl', 'el', 'sv',
        'pl', 'id', 'th', 'vi',
      ];

      for (final code in expectedCodes) {
        final hasCode = L10n.all.any((locale) => locale.languageCode == code);
        expect(hasCode, isTrue, reason: 'Missing code: $code');
        expect(L10n.getLanguageName(code), isNotEmpty);
        expect(L10n.getLanguageFlag(code), isNotEmpty);
      }
    });

    test('LocaleNotifier switches to any of the 20 locales', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(localeProvider.notifier);
      expect(container.read(localeProvider), const Locale('tr'));

      // Switch to Arabic (RTL)
      notifier.setLocale(const Locale('ar'));
      expect(container.read(localeProvider), const Locale('ar'));

      // Switch to Japanese
      notifier.setLocale(const Locale('ja'));
      expect(container.read(localeProvider), const Locale('ja'));

      // Switch to Spanish
      notifier.setLocale(const Locale('es'));
      expect(container.read(localeProvider), const Locale('es'));
    });
  });

  group('Phase 5 - Theme Management', () {
    test('ThemeModeNotifier switches between system, light, and dark modes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      expect(container.read(themeModeProvider), ThemeMode.system);

      notifier.setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);

      notifier.setThemeMode(ThemeMode.light);
      expect(container.read(themeModeProvider), ThemeMode.light);
    });
  });

  group('Phase 5 - Mock RevenueCat Service & Entitlements', () {
    test('MockRevenueCatNotifier purchases and activates PackBuddy Pro', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(proSubscriptionProvider.notifier);
      expect(container.read(proSubscriptionProvider).isPro, isFalse);

      notifier.selectPlan(SubscriptionPlan.monthly);
      expect(container.read(proSubscriptionProvider).activePlan, SubscriptionPlan.monthly);

      final success = await notifier.purchaseActivePlan();
      expect(success, isTrue);
      expect(container.read(proSubscriptionProvider).isPro, isTrue);
      expect(container.read(proSubscriptionProvider).isLoading, isFalse);
    });

    test('MockRevenueCatNotifier restores previous purchases', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(proSubscriptionProvider.notifier);
      expect(container.read(proSubscriptionProvider).isPro, isFalse);

      final restored = await notifier.restorePurchases();
      expect(restored, isTrue);
      expect(container.read(proSubscriptionProvider).isPro, isTrue);
    });
  });

  group('Phase 5 - Settings & Paywall UI Widget Tests', () {
    testWidgets('SettingsScreen renders language, theme, sync, and Pro banner', (tester) async {
      final localeNotifier = LocaleNotifier()..setLocale(const Locale('en'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith((ref) => localeNotifier),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('PackBuddy Pro'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays localized active status badge when Pro is active', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith(
              (ref) => FakeProNotifier(
                const ProSubscriptionState(
                  isPro: true,
                  activePlan: SubscriptionPlan.annual,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('PackBuddy Pro'), findsOneWidget);
      expect(find.text('AKTİF'), findsOneWidget);
      expect(find.text('ACTIVE'), findsNothing);
    });

    testWidgets('PaywallSheet displays Pro features and plan options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(body: PaywallSheet()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('PackBuddy Pro'), findsOneWidget);
      expect(find.text('Annual'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Continue with Pro'), findsOneWidget);
    });
  });
}
