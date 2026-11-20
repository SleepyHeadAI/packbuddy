import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/app_widget_localization.dart';
import 'package:packbuddy/core/services/app_widget_service.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/widget_card_renderer.dart';
import 'package:packbuddy/core/services/widget_map_renderer.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/dashboard/presentation/widgets/horizontal_currency_converter_card.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
    await CurrencyService.init();
  });

  group('User Request 1: Budget Analytics Revert Button Localization', () {
    testWidgets('revertToCurrency provides authentic translation across all 20 languages', (tester) async {
      final supportedLocales = AppLocalizations.supportedLocales;
      expect(supportedLocales.length, 20);

      const testCurrency = 'AUD (A\$)';

      for (final locale in supportedLocales) {
        late AppLocalizations l10n;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                l10n = AppLocalizations.of(context)!;
                return const Scaffold();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        final translated = l10n.revertToCurrency(testCurrency);
        expect(translated.isNotEmpty, isTrue, reason: 'Empty string for ${locale.languageCode}');
        expect(translated.contains(testCurrency), isTrue,
            reason: '$translated does not include placeholder for ${locale.languageCode}');

        if (locale.languageCode == 'tr') {
          expect(translated, 'AUD (A\$) para birimine dön');
        } else if (locale.languageCode == 'en') {
          expect(translated, 'Switch back to AUD (A\$)');
        } else if (locale.languageCode == 'de') {
          expect(translated, 'Zurück zu AUD (A\$)');
        } else if (locale.languageCode == 'fr') {
          expect(translated, 'Revenir à AUD (A\$)');
        } else if (locale.languageCode == 'es') {
          expect(translated, 'Volver a AUD (A\$)');
        }
      }
    });

    testWidgets('BudgetAnalyticsCard displays localized revert button when custom currency selected', (tester) async {
      final trip = Trip(
        id: 'trip-1',
        title: 'Sydney Trip',
        destination: 'Sydney',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        defaultCurrency: 'AUD',
        budgetLimit: 5000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final expense = Expense(
        id: 'exp-1',
        tripId: 'trip-1',
        title: 'Lunch',
        amount: 62.47,
        currency: 'AUD',
        category: 'Food & Dining',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Render in English with BRL selected (different from AUD)
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: BudgetAnalyticsCard(
                trip: trip,
                expenses: [expense],
                tripCurrency: 'AUD',
                selectedCurrency: 'BRL',
                totalSpent: 62.47,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In English, it must say "Switch back to AUD (A$)" instead of hardcoded Turkish
      expect(find.text('Switch back to AUD (A\$)'), findsOneWidget);
      expect(find.text('AUD (A\$) para birimine dön'), findsNothing);
    });
  });

  group('User Request 2: Exactly One Green Dot in Live Rates Status', () {
    test('getLiveRatesLabel across all 20 languages does not contain leading bullet characters', () {
      final languages = AppWidgetLocalization.supportedLanguages;
      expect(languages.length, 20);

      for (final lang in languages) {
        final label = AppWidgetLocalization.getLiveRatesLabel(lang);
        expect(label.contains('●'), isFalse, reason: '$lang label contains duplicate bullet: $label');
        expect(label.isNotEmpty, isTrue);
      }

      expect(AppWidgetLocalization.getLiveRatesLabel('en'), 'Live Rates');
      expect(AppWidgetLocalization.getLiveRatesLabel('tr'), 'Canlı Kurlar');
      expect(AppWidgetLocalization.getLiveRatesLabel('es'), 'Tasas en vivo');
    });

    testWidgets('WidgetCardRenderer Medium Currency renders clean single green dot', (tester) async {
      final widgetData = AppWidgetData(
        widgetMode: 'currency_converter',
        userCurrency: 'AUD',
        currencyRateUSD: 'A\$1.48',
        currencyRateEUR: 'A\$1.63',
        converterFromCurrency: 'USD',
        converterToCurrency: 'AUD',
        converterAmount: 100,
        converterResult: 'A\$148.00',
        converterRate: 'A\$1.48',
        converterReverseRate: '\$0.68',
        updatedAt: DateTime.now(),
      );

      final themeConfig = WidgetThemeConfig.fromKey('midnight');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WidgetCardRenderer.buildWidgetCard(
                mode: 'currency_converter',
                sizeIndex: 1, // Medium
                themeConfig: themeConfig,
                widgetData: widgetData,
                countries: const [],
                lang: 'en',
                showLiveRate: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure "Live Rates" text is displayed
      expect(find.text('Live Rates'), findsOneWidget);
      // Ensure text itself does NOT start with a bullet character
      expect(find.text('● Live Rates'), findsNothing);

      // Verify the single green circle indicator container exists
      final greenContainers = tester.widgetList<Container>(find.byType(Container)).where((c) {
        final dec = c.decoration;
        if (dec is BoxDecoration) {
          return dec.shape == BoxShape.circle && dec.color == const Color(0xFF10B981);
        }
        return false;
      }).toList();

      expect(greenContainers.length, 1, reason: 'Must have exactly one green indicator dot');
    });
  });

  group('User Request 3: Previous Currency Search & 1:1 In-App Parity', () {
    testWidgets('HorizontalCurrencyConverterCard saves conversion search and syncs with widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HorizontalCurrencyConverterCard(
                initialFrom: 'USD',
                initialTo: 'AUD',
                initialAmount: 250,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial conversion render
      expect(find.text('USD'), findsWidgets);
      expect(find.text('AUD'), findsWidgets);

      // Verify swap button triggers state update & persistence
      final swapBtn = find.descendant(
        of: find.byType(IconButton),
        matching: find.byIcon(AppIcons.currency),
      );
      expect(swapBtn, findsOneWidget);
      await tester.tap(swapBtn);
      await tester.pumpAndSettle();

      // Check persisted state in PreferencesService
      expect(PreferencesService.instance.getLastConverterFromCurrency(), 'AUD');
      expect(PreferencesService.instance.getLastConverterToCurrency(), 'USD');
    });

    testWidgets('WidgetCardRenderer across Small, Medium, Large reflects user previous search', (tester) async {
      final widgetData = AppWidgetData(
        widgetMode: 'currency_converter',
        userCurrency: 'AUD',
        converterFromCurrency: 'USD',
        converterToCurrency: 'AUD',
        converterAmount: 100,
        converterResult: 'A\$148.00',
        converterRate: 'A\$1.48',
        converterReverseRate: '\$0.68',
        updatedAt: DateTime.now(),
      );

      final themeConfig = WidgetThemeConfig.fromKey('midnight');

      for (int size = 0; size < 3; size++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WidgetCardRenderer.buildWidgetCard(
                  mode: 'currency_converter',
                  sizeIndex: size,
                  themeConfig: themeConfig,
                  widgetData: widgetData,
                  countries: const [],
                  lang: 'en',
                  showLiveRate: true,
                  showReverseRate: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // All sizes must display the user's previous conversion search
        expect(find.textContaining('148'), findsWidgets,
            reason: 'Size $size did not display converted result');
      }
    });

    testWidgets('WidgetCardRenderer renders without overflow across all 20 languages and all 16 themes', (tester) async {
      final widgetData = AppWidgetData(
        widgetMode: 'currency_converter',
        userCurrency: 'AUD',
        converterFromCurrency: 'USD',
        converterToCurrency: 'AUD',
        converterAmount: 100,
        converterResult: 'A\$148.00',
        converterRate: 'A\$1.48',
        converterReverseRate: '\$0.68',
        updatedAt: DateTime.now(),
      );

      const allThemes = [
        'midnight',
        'sunset',
        'emerald',
        'cyberpunk',
        'volcano',
        'nordicForest',
        'goldenHour',
        'galaxy',
        'monochromeDark',
        'minimalLight',
        'sandLight',
        'oceanLight',
        'cherryBlossom',
        'vintageSepia',
        'matcha',
        'pastelDream',
      ];

      for (final themeKey in allThemes) {
        final themeConfig = WidgetThemeConfig.fromKey(themeKey);
        for (final lang in AppWidgetLocalization.supportedLanguages) {
          for (int size = 0; size < 3; size++) {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: WidgetCardRenderer.buildWidgetCard(
                      mode: 'currency_converter',
                      sizeIndex: size,
                      themeConfig: themeConfig,
                      widgetData: widgetData,
                      countries: const [],
                      lang: lang,
                      showLiveRate: true,
                      showReverseRate: true,
                    ),
                  ),
                ),
              ),
            );

            expect(tester.takeException(), isNull,
                reason: 'Overflow on size $size, theme $themeKey, lang $lang');
          }
        }
      }
    });
  });
}
