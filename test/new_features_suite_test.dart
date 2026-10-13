import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/features/checklist/domain/packing_templates.dart';
import 'package:packbuddy/features/checklist/domain/airline_baggage_guide.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. PreferencesService Unit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
    });

    test('ThemeMode persistence works correctly', () async {
      final prefs = PreferencesService.instance;
      expect(prefs.getThemeMode(), ThemeMode.system);

      await prefs.setThemeMode(ThemeMode.dark);
      expect(prefs.getThemeMode(), ThemeMode.dark);

      await prefs.setThemeMode(ThemeMode.light);
      expect(prefs.getThemeMode(), ThemeMode.light);
    });

    test('Locale persistence works correctly', () async {
      final prefs = PreferencesService.instance;
      expect(prefs.getLocale(), isNull); // Defaults to null (system/fallback)

      await prefs.setLocale(const Locale('tr'));
      expect(prefs.getLocale()?.languageCode, 'tr');

      await prefs.setLocale(const Locale('en'));
      expect(prefs.getLocale()?.languageCode, 'en');
    });

    test('Pro Entitlement persistence works correctly', () async {
      final prefs = PreferencesService.instance;
      expect(prefs.isProUser(), false);

      await prefs.setProUser(true);
      expect(prefs.isProUser(), true);
    });

    test('Vault PIN & Biometrics persistence works correctly', () async {
      final prefs = PreferencesService.instance;
      expect(prefs.getVaultPin(), isNull);

      await prefs.setVaultPin('1234');
      expect(prefs.getVaultPin(), '1234');

      await prefs.setVaultBiometricEnabled(true);
      expect(prefs.isVaultBiometricEnabled(), true);

      await prefs.setVaultPin(null);
      expect(prefs.getVaultPin(), isNull);
    });
  });

  group('2. Offline CurrencyService Unit Tests', () {
    test('Currency conversion calculates proportional amounts', () {
      // 100 USD to TRY
      final tryAmount = CurrencyService.convert(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'TRY',
      );
      expect(tryAmount, greaterThan(3000));

      // Same currency conversion returns exact amount
      final identity = CurrencyService.convert(
        amount: 50,
        fromCurrency: 'EUR',
        toCurrency: 'EUR',
      );
      expect(identity, 50.0);

      // Symbol mapping
      expect(CurrencyService.getCurrencySymbol('USD'), '\$');
      expect(CurrencyService.getCurrencySymbol('EUR'), '€');
      expect(CurrencyService.getCurrencySymbol('TRY'), '₺');
      expect(CurrencyService.getCurrencySymbol('GBP'), '£');
    });

    test('Supported currencies list contains major global travel currencies', () {
      expect(CurrencyService.supportedCurrencies, containsAll(['USD', 'EUR', 'TRY', 'GBP', 'JPY']));
      expect(CurrencyService.supportedCurrencies.length, greaterThanOrEqualTo(20));
    });
  });

  group('3. Smart Packing Templates Domain Tests', () {
    test('Contains 5 curated travel templates with items', () {
      expect(PackingTemplatesRepository.all.length, 5);

      for (final t in PackingTemplatesRepository.all) {
        expect(t.title, isNotEmpty);
        expect(t.emoji, isNotEmpty);
        expect(t.items, isNotEmpty);

        final packingItem = t.items.first.toPackingItem(tripId: 'test_trip');
        expect(packingItem.name, t.items.first.name);
        expect(packingItem.tripId, 'test_trip');
        expect(packingItem.isPacked, false);
      }
    });
  });

  group('4. Airline Baggage Guide Domain Tests', () {
    test('Contains major airlines with valid cabin and checked allowances', () {
      expect(AirlineBaggageRepository.airlines.length, greaterThanOrEqualTo(8));

      final thy = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'TK');
      expect(thy.airlineName, contains('Türk Hava Yolları'));
      expect(thy.cabinLimitKg, 8.0);
      expect(thy.checkedLimitKg, 23.0);

      final ba = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'BA');
      expect(ba.cabinLimitKg, 23.0);
    });
  });

  group('5. Budget Analytics Card Widget Tests', () {
    testWidgets('Renders category breakdown and percentages correctly', (tester) async {
      final dummyExpenses = [
        Expense(
          id: '1',
          tripId: 'trip_1',
          title: 'Akşam Yemeği',
          amount: 50.0,
          currency: 'EUR',
          category: 'Food',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Expense(
          id: '2',
          tripId: 'trip_1',
          title: 'Metro Bileti',
          amount: 20.0,
          currency: 'EUR',
          category: 'Transport',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Expense(
          id: '3',
          tripId: 'trip_1',
          title: 'Müze Girişi',
          amount: 30.0,
          currency: 'EUR',
          category: 'Entertainment',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: BudgetAnalyticsCard(
                expenses: dummyExpenses,
                tripCurrency: 'EUR',
                totalSpent: 100.0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kategori Harcama Analizi'), findsOneWidget);
      expect(find.text('3 Harcama'), findsOneWidget);
      expect(find.text('Yemek'), findsOneWidget);
      expect(find.text('Ulaşım'), findsOneWidget);
      expect(find.text('Eğlence'), findsOneWidget);
      expect(find.text('%50'), findsOneWidget); // 50 / 100 EUR
    });
  });

  group('5. Bottom Navigation & Airline Selection Tests', () {
    test('ChecklistController updates selectedAirline properly', () {
      final notifier = ChecklistNotifier();
      expect(notifier.state.selectedAirline, isNull);

      const testAirline = AirlineBaggageRule(
        airlineName: 'Türk Hava Yolları',
        iataCode: 'TK',
        countryFlag: '🇹🇷',
        cabinLimitKg: 8.0,
        cabinDimensions: '55 x 40 x 23 cm',
        checkedLimitKg: 23.0,
        notes: '1 adet 8 kg kabin bagajı',
      );

      notifier.selectAirline(testAirline);
      expect(notifier.state.selectedAirline, equals(testAirline));
      expect(notifier.state.selectedAirline?.cabinLimitKg, equals(8.0));
      expect(notifier.state.selectedAirline?.airlineName, 'Türk Hava Yolları');
      expect(notifier.state.selectedAirline?.checkedLimitKg, 23.0);

      notifier.selectAirline(null);
      expect(notifier.state.selectedAirline, isNull);
    });
  });
}
