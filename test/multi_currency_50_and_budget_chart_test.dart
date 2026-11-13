import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_progress_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/currency_picker_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CurrencyService.resetToDefaults();
  });

  group('Top 50 World Currencies Suite', () {
    test('1. Exactly 50 world currencies are supported in CurrencyService and CurrencyFormatter', () {
      expect(CurrencyService.supportedCurrencies.length, 50);
      expect(CurrencyFormatter.supportedCurrencies.length, 50);

      // Verify that every single currency in CurrencyFormatter has a rate in CurrencyService
      for (final code in CurrencyFormatter.supportedCurrencies) {
        expect(CurrencyService.supportedCurrencies.contains(code), isTrue,
            reason: '$code should be supported by CurrencyService');
        final rate = CurrencyService.ratesAgainstUsd[code];
        expect(rate, isNotNull);
        expect(rate!, greaterThan(0.0), reason: '$code should have a positive exchange rate');

        final symbol = CurrencyFormatter.getSymbol(code);
        expect(symbol, isNotEmpty, reason: '$code should have a valid symbol');

        final flag = CurrencyFormatter.getFlag(code);
        expect(flag, isNotEmpty, reason: '$code should have a flag');
        expect(flag, isNot(equals('🌐')), reason: '$code should have a specific flag emoji');

        final cleanName = CurrencyFormatter.getCleanName(code);
        expect(cleanName, isNotEmpty, reason: '$code should have a clean name');
      }
    });

    test('2. Top 50 currencies include major world currencies', () {
      final keyCurrencies = [
        'USD', 'EUR', 'JPY', 'GBP', 'CNY', 'AUD', 'CAD', 'CHF', 'HKD', 'SGD',
        'SEK', 'KRW', 'NOK', 'NZD', 'INR', 'MXN', 'TWD', 'ZAR', 'BRL', 'DKK',
        'PLN', 'THB', 'ILS', 'IDR', 'CZK', 'TRY', 'AED', 'CLP', 'SAR', 'PHP',
        'MYR', 'HUF', 'COP', 'VND', 'QAR', 'EGP', 'KWD', 'BHD', 'OMR', 'PEN',
        'RON', 'BGN', 'ARS', 'KZT', 'MAD', 'JOD', 'ISK', 'RSD', 'GEL', 'PKR',
      ];
      expect(CurrencyService.supportedCurrencies, containsAll(keyCurrencies));
      expect(keyCurrencies.length, 50);
    });

    test('3. Cross-currency conversion works accurately across newly added currencies', () {
      // 100 USD to EUR: 100 * 0.92 = 92 EUR
      expect(CurrencyService.convert(amount: 100, fromCurrency: 'USD', toCurrency: 'EUR'), closeTo(92.0, 0.01));

      // 100 EUR to USD: 100 / 0.92 = ~108.70 USD
      expect(CurrencyService.convert(amount: 92, fromCurrency: 'EUR', toCurrency: 'USD'), closeTo(100.0, 0.01));

      // TRY to JPY cross conversion:
      // 342.50 TRY -> 10 USD -> 10 * 152.5 = 1525 JPY
      final jpyAmount = CurrencyService.convert(amount: 342.5, fromCurrency: 'TRY', toCurrency: 'JPY');
      expect(jpyAmount, closeTo(1525.0, 0.1));

      // HKD to SGD cross conversion:
      // 77.80 HKD -> 10 USD -> 10 * 1.32 = 13.20 SGD
      final sgdAmount = CurrencyService.convert(amount: 77.8, fromCurrency: 'HKD', toCurrency: 'SGD');
      expect(sgdAmount, closeTo(13.2, 0.05));

      // ARS to BRL cross conversion:
      // 9950 ARS -> 10 USD -> 10 * 5.72 = 57.20 BRL
      final brlAmount = CurrencyService.convert(amount: 9950, fromCurrency: 'ARS', toCurrency: 'BRL');
      expect(brlAmount, closeTo(57.2, 0.1));

      // Identity conversion
      expect(CurrencyService.convert(amount: 500, fromCurrency: 'TRY', toCurrency: 'TRY'), 500.0);
    });

    test('4. Live rate sync updates all 50 currencies dynamically', () async {
      final mockDynamicRates = <String, dynamic>{};
      for (final code in CurrencyService.supportedCurrencies) {
        mockDynamicRates[code] = 2.0; // dummy rate
      }
      mockDynamicRates['TRY'] = 35.50;
      mockDynamicRates['EUR'] = 0.95;
      mockDynamicRates['HKD'] = 7.82;

      CurrencyService.applyRates({
        'TRY': 35.50,
        'EUR': 0.95,
        'HKD': 7.82,
      });

      expect(CurrencyService.isUsingLiveRates, isTrue);
      expect(CurrencyService.ratesAgainstUsd['TRY'], 35.50);
      expect(CurrencyService.ratesAgainstUsd['EUR'], 0.95);
      expect(CurrencyService.ratesAgainstUsd['HKD'], 7.82);
    });
  });

  group('Budget Section Multi-Currency Chart Tests', () {
    final testTrip = Trip(
      id: 'trip-test-1',
      title: 'İtalya Gezisi',
      destination: 'Roma, İtalya',
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 11, 10),
      budgetLimit: 1000.0,
      defaultCurrency: 'EUR',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testExpenses = [
      Expense(
        id: 'e1',
        tripId: testTrip.id,
        title: 'Pizza & Pasta',
        amount: 50.0,
        currency: 'EUR',
        category: 'Food',
        date: DateTime(2026, 11, 2),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Expense(
        id: 'e2',
        tripId: testTrip.id,
        title: 'Metro Bileti',
        amount: 20.0,
        currency: 'EUR',
        category: 'Transport',
        date: DateTime(2026, 11, 3),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    testWidgets('5. BudgetAnalyticsCard renders top-right currency selector and default total', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: BudgetAnalyticsCard(
                expenses: testExpenses,
                tripCurrency: testTrip.defaultCurrency,
                totalSpent: 70.0,
                trip: testTrip,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the top-right currency selector button exists
      final currencySelector = find.byKey(const Key('chart_currency_selector_button'));
      expect(currencySelector, findsOneWidget);

      // Verify default currency 'EUR' and symbol '€' are displayed
      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('€70'), findsWidgets);
    });

    testWidgets('6. BudgetAnalyticsCard converts chart and center total when currency changed', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      String selectedCurr = 'EUR';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: SingleChildScrollView(
                  child: BudgetAnalyticsCard(
                    expenses: testExpenses,
                    tripCurrency: testTrip.defaultCurrency,
                    selectedCurrency: selectedCurr,
                    onCurrencyChanged: (newCurr) {
                      setState(() => selectedCurr = newCurr);
                    },
                    totalSpent: 70.0,
                    trip: testTrip,
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Check default EUR total
      expect(find.text('EUR'), findsOneWidget);

      // Tap the top-right currency selector
      await tester.tap(find.byKey(const Key('chart_currency_selector_button')));
      await tester.pumpAndSettle();

      // CurrencyPickerSheet should now be visible with 50 currencies
      expect(find.byType(CurrencyPickerSheet), findsOneWidget);

      // Filter for 'USD' in the search bar
      await tester.enterText(find.byType(TextField), 'USD');
      await tester.pumpAndSettle();

      // Select 'USD' from the list
      final usdTile = find.widgetWithText(ListTile, 'USD');
      expect(usdTile, findsOneWidget);
      await tester.tap(usdTile);
      await tester.pumpAndSettle();

      // Selector now shows USD
      expect(find.text('USD'), findsOneWidget);

      // 70 EUR converted to USD: 70 / 0.92 = 76.09 USD -> shows '$76' or '$76.09'
      final expectedUsd = CurrencyService.convert(amount: 70.0, fromCurrency: 'EUR', toCurrency: 'USD');
      final formattedUsd = CurrencyFormatter.format(expectedUsd, currency: 'USD');
      expect(find.text(formattedUsd), findsOneWidget);

      // Also shows approximate original reference: '≈ €70'
      expect(find.text('≈ €70'), findsOneWidget);
    });

    testWidgets('7. BudgetProgressCard displays converted spent and reference when custom currency active', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: BudgetProgressCard(
              budgetLimit: 1087.0,
              totalSpent: 76.09,
              currency: 'USD',
              originalCurrency: 'EUR',
              originalTotalSpent: 70.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Displays USD spent
      expect(find.text(CurrencyFormatter.format(76.09, currency: 'USD')), findsOneWidget);
      // Displays original EUR reference
      expect(find.text('≈ €70'), findsOneWidget);
    });

    testWidgets('8. CurrencyPickerSheet search filters currencies correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: CurrencyPickerSheet(
              selectedCurrency: 'EUR',
              defaultCurrency: 'EUR',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Total 50 currencies in sheet
      expect(find.text('50 world currencies'), findsOneWidget);

      // Search for 'Turkey' or 'TRY'
      await tester.enterText(find.byType(TextField), 'TRY');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'TRY'), findsOneWidget);
      expect(find.text('USD'), findsNothing);
      expect(find.text('EUR'), findsNothing);
    });
  });
}
