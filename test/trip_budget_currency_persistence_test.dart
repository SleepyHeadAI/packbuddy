import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/features/budget/domain/budget_localization.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_progress_card.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeTripNotifier extends StateNotifier<TripState> implements TripController {
  FakeTripNotifier(List<Trip> initialTrips)
      : super(TripState(trips: initialTrips, isLoading: false));

  Trip? lastUpdatedTrip;

  @override
  Future<Trip?> updateTrip(Trip trip) async {
    lastUpdatedTrip = trip;
    final updated = state.trips.map((t) => t.id == trip.id ? trip : t).toList();
    state = state.copyWith(trips: updated);
    return trip;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeExpenseNotifier extends StateNotifier<ExpenseState> implements ExpenseController {
  FakeExpenseNotifier(List<Expense> initialExpenses)
      : super(ExpenseState(expenses: initialExpenses, isLoading: false));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences mockPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
    PreferencesService.setInstance(PreferencesService.instance);
    await PreferencesService.init();
    CurrencyService.resetToDefaults();
  });

  group('Trip Budget Currency Persistence & PreferencesService Tests', () {
    test('1. getTripBudgetCurrency and setTripBudgetCurrency persist and clear correctly', () async {
      expect(PreferencesService.instance.getTripBudgetCurrency('trip-aud-1'), isNull);

      // Persist USD for trip-aud-1
      await PreferencesService.instance.setTripBudgetCurrency('trip-aud-1', 'USD');
      expect(PreferencesService.instance.getTripBudgetCurrency('trip-aud-1'), 'USD');

      // Another trip has independent preference
      expect(PreferencesService.instance.getTripBudgetCurrency('trip-other-2'), isNull);

      // Clearing preference reverts to null
      await PreferencesService.instance.setTripBudgetCurrency('trip-aud-1', null);
      expect(PreferencesService.instance.getTripBudgetCurrency('trip-aud-1'), isNull);
    });

    test('2. getDefaultCurrency falls back to lastConverterFromCurrency if user used converter', () async {
      expect(PreferencesService.instance.getDefaultCurrency(), isNull);

      // User used currency converter with USD
      await mockPrefs.setString('packbuddy_last_converter_from_currency', 'USD');
      expect(PreferencesService.instance.getDefaultCurrency(), 'USD');

      // Explicit default currency takes highest precedence
      await PreferencesService.instance.setDefaultCurrency('EUR');
      expect(PreferencesService.instance.getDefaultCurrency(), 'EUR');
    });
  });

  group('TripDetailScreen AUD Sticky Issue & Multi-Currency Flow Tests', () {
    final audTrip = Trip(
      id: 'trip-aud-sydney',
      title: 'Sydney Holiday',
      destination: 'Sydney, Australia',
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 11, 10),
      defaultCurrency: 'AUD',
      budgetLimit: 10000.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final audExpense = Expense(
      id: 'exp-1',
      tripId: audTrip.id,
      title: 'Food & Dining',
      amount: 16.32,
      currency: 'AUD',
      category: 'Food',
      date: DateTime(2026, 11, 2),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Widget buildTestApp({
      required Trip trip,
      required List<Expense> expenses,
      required FakeTripNotifier tripNotifier,
      Locale locale = const Locale('en'),
    }) {
      return ProviderScope(
        overrides: [
          tripControllerProvider.overrideWith((ref) => tripNotifier),
          expenseControllerProvider(trip.id).overrideWith(
            (ref) => FakeExpenseNotifier(expenses),
          ),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TripDetailScreen(trip: trip),
        ),
      );
    }

    testWidgets('3. TripDetailScreen starts in AUD initially, and switches currency without reverting on re-entry', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final tripNotifier = FakeTripNotifier([audTrip]);

      // Phase A: First entry - starts in AUD
      await tester.pumpWidget(buildTestApp(
        trip: audTrip,
        expenses: [audExpense],
        tripNotifier: tripNotifier,
      ));
      await tester.pumpAndSettle();

      // Top budget progress card shows AUD symbol
      expect(find.text('A\$16.32'), findsWidgets);
      // Analytics card shows AUD
      expect(find.text('AUD'), findsWidgets);

      // Phase B: User clicks the currency selector button on BudgetAnalyticsCard and changes to USD
      await tester.tap(find.byKey(const Key('chart_currency_selector_button')));
      await tester.pumpAndSettle();

      // Filter and tap USD
      await tester.enterText(find.byType(TextField), 'USD');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'USD'));
      await tester.pumpAndSettle();

      // Verify that USD is active
      expect(find.text('USD'), findsWidgets);
      expect(PreferencesService.instance.getTripBudgetCurrency(audTrip.id), 'USD');

      // Phase C: Simulate exiting the screen and re-entering the trip!
      // In the old broken code, re-entering created a new State and reverted to AUD.
      // Now, with persistence, it must start directly in USD!
      await tester.pumpWidget(buildTestApp(
        trip: audTrip,
        expenses: [audExpense],
        tripNotifier: tripNotifier,
      ));
      await tester.pumpAndSettle();

      // It must NOT start over in AUD! It must remain in USD!
      expect(find.text('USD'), findsWidgets);
      expect(PreferencesService.instance.getTripBudgetCurrency(audTrip.id), 'USD');
    });

    testWidgets('4. "Make USD Trip Currency" permanently updates trip base currency', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final tripNotifier = FakeTripNotifier([audTrip]);

      // Pre-set persisted preference as USD
      await PreferencesService.instance.setTripBudgetCurrency(audTrip.id, 'USD');

      await tester.pumpWidget(buildTestApp(
        trip: audTrip,
        expenses: [audExpense],
        tripNotifier: tripNotifier,
      ));
      await tester.pumpAndSettle();

      // Custom currency is active, so "Make USD Trip Currency" button is visible
      final makeBaseBtn = find.byKey(const Key('set_as_base_currency_button'));
      expect(makeBaseBtn, findsOneWidget);
      expect(find.text('Make USD Trip Currency'), findsOneWidget);

      // Tap make base currency
      await tester.tap(makeBaseBtn);
      await tester.pumpAndSettle();

      // Trip controller must have received updated trip with defaultCurrency == 'USD'
      expect(tripNotifier.lastUpdatedTrip, isNotNull);
      expect(tripNotifier.lastUpdatedTrip?.defaultCurrency, 'USD');
      // Per-trip view override is cleared because trip is now natively USD
      expect(PreferencesService.instance.getTripBudgetCurrency(audTrip.id), isNull);
      // Success snackbar is displayed
      expect(find.textContaining('USD'), findsWidgets);
    });

    testWidgets('5. "Switch back to AUD" reverts to original base currency', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final tripNotifier = FakeTripNotifier([audTrip]);

      // Pre-set persisted preference as USD
      await PreferencesService.instance.setTripBudgetCurrency(audTrip.id, 'USD');

      await tester.pumpWidget(buildTestApp(
        trip: audTrip,
        expenses: [audExpense],
        tripNotifier: tripNotifier,
      ));
      await tester.pumpAndSettle();

      final revertBtn = find.byKey(const Key('revert_to_trip_currency_button'));
      expect(revertBtn, findsOneWidget);

      // Tap revert button
      await tester.tap(revertBtn);
      await tester.pumpAndSettle();

      // Persisted override is removed
      expect(PreferencesService.instance.getTripBudgetCurrency(audTrip.id), isNull);
      // Active display is back in AUD
      expect(find.text('A\$16.32'), findsWidgets);
    });

    testWidgets('6. BudgetProgressCard currency chip is clickable and allows picking currency', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      final tripNotifier = FakeTripNotifier([audTrip]);

      await tester.pumpWidget(buildTestApp(
        trip: audTrip,
        expenses: [audExpense],
        tripNotifier: tripNotifier,
      ));
      await tester.pumpAndSettle();

      final chip = find.byKey(const Key('budget_card_currency_chip'));
      expect(chip, findsOneWidget);

      // Tap budget card chip opens CurrencyPickerSheet
      await tester.tap(chip);
      await tester.pumpAndSettle();

      expect(find.text('50 world currencies'), findsOneWidget);
    });
  });

  group('Multi-Language (All 20 Languages) & Multi-Size Stress Tests', () {
    final testTrip = Trip(
      id: 'trip-stress',
      title: 'Global Tour',
      destination: 'Tokyo, Japan',
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 11, 10),
      defaultCurrency: 'AUD',
      budgetLimit: 8000.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testExpenses = [
      Expense(
        id: 'e-1',
        tripId: testTrip.id,
        title: 'Dinner',
        amount: 85.50,
        currency: 'AUD',
        category: 'Food',
        date: DateTime(2026, 11, 2),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('7. BudgetLocalization provides non-empty translations for all 20 supported languages', () {
      final supportedLocales = AppLocalizations.supportedLocales;
      expect(supportedLocales.length, 20);

      for (final locale in supportedLocales) {
        final lang = locale.languageCode;
        final makeTrip = BudgetLocalization.makeTripCurrency(lang, 'USD');
        final setBase = BudgetLocalization.setAsBaseCurrency(lang, 'USD');
        final updated = BudgetLocalization.tripCurrencyUpdated(lang, 'USD');
        final viewing = BudgetLocalization.viewingIn(lang, 'USD');

        expect(makeTrip.isNotEmpty, isTrue, reason: '$lang makeTrip is empty');
        expect(makeTrip.contains('USD'), isTrue, reason: '$lang makeTrip missing currency');
        expect(setBase.isNotEmpty, isTrue, reason: '$lang setBase is empty');
        expect(updated.isNotEmpty, isTrue, reason: '$lang updated is empty');
        expect(viewing.isNotEmpty, isTrue, reason: '$lang viewing is empty');
      }
    });

    testWidgets('8. BudgetAnalyticsCard renders without overflow across all 20 languages with custom currency active', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));

      for (final locale in AppLocalizations.supportedLocales) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: BudgetAnalyticsCard(
                  expenses: testExpenses,
                  tripCurrency: 'AUD',
                  selectedCurrency: 'EUR',
                  totalSpent: 85.50,
                  trip: testTrip,
                  onSetAsBaseCurrency: () {},
                  onCurrencyChanged: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull,
            reason: 'RenderFlex overflow occurred in language ${locale.languageCode}');
      }
    });

    testWidgets('9. BudgetAnalyticsCard and BudgetProgressCard render cleanly across multiple screen dimensions', (tester) async {
      const screenSizes = [
        Size(320, 568),  // Ultra compact (iPhone SE 1st gen)
        Size(360, 640),  // Standard compact Android
        Size(390, 844),  // Modern iPhone (12/13/14)
        Size(412, 915),  // Modern Pixel / Android flagship
        Size(768, 1024), // Tablet / iPad portrait
      ];

      for (final size in screenSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    BudgetProgressCard(
                      budgetLimit: 8000,
                      totalSpent: 85.50,
                      currency: 'EUR',
                      originalCurrency: 'AUD',
                      originalTotalSpent: 85.50,
                      onCurrencyTap: () {},
                    ),
                    const SizedBox(height: 16),
                    BudgetAnalyticsCard(
                      expenses: testExpenses,
                      tripCurrency: 'AUD',
                      selectedCurrency: 'EUR',
                      totalSpent: 85.50,
                      trip: testTrip,
                      onSetAsBaseCurrency: () {},
                      onCurrencyChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull,
            reason: 'RenderFlex overflow occurred on screen size $size');
      }
    });
  });
}
