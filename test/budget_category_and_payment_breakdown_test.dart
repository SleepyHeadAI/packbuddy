import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeTripController extends StateNotifier<TripState> implements TripController {
  FakeTripController(List<Trip> trips) : super(TripState(isLoading: false, trips: trips));

  @override
  Future<void> loadTrips({String? userId}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeExpenseController extends StateNotifier<ExpenseState> implements ExpenseController {
  FakeExpenseController({required List<Expense> expenses})
      : super(
          ExpenseState(
            isLoading: false,
            expenses: expenses,
            totalSpent: expenses.fold<double>(0.0, (sum, e) => sum + e.amount),
          ),
        );

  @override
  Future<void> loadExpenses() async {}

  @override
  Future<bool> deleteExpense(String expenseId) async {
    final updated = state.expenses.where((e) => e.id != expenseId).toList();
    state = state.copyWith(
      expenses: updated,
      totalSpent: updated.fold<double>(0.0, (sum, e) => sum + e.amount),
    );
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime(2026, 6, 15);
  final testTrip = Trip(
    id: 'trip-paris-1',
    title: 'Paris Summer Vacation',
    destination: 'Paris, France',
    countryCode: 'FR',
    startDate: now,
    endDate: now.add(const Duration(days: 7)),
    budgetLimit: 2000.0,
    defaultCurrency: 'EUR',
    createdAt: now,
    updatedAt: now,
  );

  final sampleExpenses = [
    Expense(
      id: 'exp-1',
      tripId: 'trip-paris-1',
      title: 'Croissant & Coffee',
      amount: 15.0,
      currency: 'EUR',
      category: 'Food',
      paymentMethod: 'Cash',
      date: now,
      createdAt: now,
      updatedAt: now,
    ),
    Expense(
      id: 'exp-2',
      tripId: 'trip-paris-1',
      title: 'Metro Weekly Pass',
      amount: 35.0,
      currency: 'EUR',
      category: 'Transport',
      paymentMethod: 'CreditCard',
      date: now,
      createdAt: now,
      updatedAt: now,
    ),
    Expense(
      id: 'exp-3',
      tripId: 'trip-paris-1',
      title: 'Dinner at Le Bistro',
      amount: 85.0,
      currency: 'EUR',
      category: 'Food',
      paymentMethod: 'CreditCard',
      date: now,
      createdAt: now,
      updatedAt: now,
    ),
    Expense(
      id: 'exp-4',
      tripId: 'trip-paris-1',
      title: 'Souvenir Eiffel Tower Model',
      amount: 40.0,
      currency: 'EUR',
      category: 'Shopping',
      paymentMethod: 'DigitalWallet',
      date: now,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  Widget createWidget({
    required Trip trip,
    required List<Expense> expenses,
    String locale = 'tr',
  }) {
    return ProviderScope(
      overrides: [
        tripControllerProvider.overrideWith((ref) => FakeTripController([trip])),
        expenseControllerProvider(trip.id).overrideWith(
          (ref) => FakeExpenseController(expenses: expenses),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(locale),
        home: TripDetailScreen(trip: trip),
      ),
    );
  }

  group('Budget Category and Payment Method Breakdown Tests', () {
    testWidgets('Renders view mode selector with All, Category, and Payment tabs', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1600 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget(trip: testTrip, expenses: sampleExpenses));
      await tester.pumpAndSettle();

      // Check all 3 mode selector buttons exist
      expect(find.byKey(const Key('expense_view_mode_0')), findsOneWidget); // All
      expect(find.byKey(const Key('expense_view_mode_1')), findsOneWidget); // Category
      expect(find.byKey(const Key('expense_view_mode_2')), findsOneWidget); // Payment Method
    });

    testWidgets('Category Mode displays Category Summaries, counts, totals, and expense lists', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1600 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget(trip: testTrip, expenses: sampleExpenses));
      await tester.pumpAndSettle();

      // Switch to Category View Mode
      await tester.tap(find.byKey(const Key('expense_view_mode_1')));
      await tester.pumpAndSettle();

      // Verify category groups exist
      expect(find.byKey(const Key('category_group_Food')), findsOneWidget);
      expect(find.byKey(const Key('category_group_Transport')), findsOneWidget);
      expect(find.byKey(const Key('category_group_Shopping')), findsOneWidget);

      // Verify expenses are listed under their categories
      expect(find.text('Croissant & Coffee'), findsOneWidget);
      expect(find.text('Dinner at Le Bistro'), findsOneWidget);
      expect(find.text('Metro Weekly Pass'), findsOneWidget);
      expect(find.text('Souvenir Eiffel Tower Model'), findsOneWidget);

      // Verify category totals are displayed in the headers
      // Food total: 15 + 85 = 100 EUR
      expect(find.textContaining('100'), findsWidgets);
      // Transport total: 35 EUR
      expect(find.textContaining('35'), findsWidgets);

      // Test collapsing a category group
      await tester.tap(find.byKey(const Key('category_header_Food')));
      await tester.pumpAndSettle();

      // After collapsing Food, Food expenses should be hidden while Transport remains visible
      expect(find.text('Croissant & Coffee'), findsNothing);
      expect(find.text('Dinner at Le Bistro'), findsNothing);
      expect(find.text('Metro Weekly Pass'), findsOneWidget);

      // Re-expand Food
      await tester.tap(find.byKey(const Key('category_header_Food')));
      await tester.pumpAndSettle();
      expect(find.text('Croissant & Coffee'), findsOneWidget);
    });

    testWidgets('Category Filter Chips filter down to a single category', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1600 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget(trip: testTrip, expenses: sampleExpenses));
      await tester.pumpAndSettle();

      // Switch to Category View Mode
      await tester.tap(find.byKey(const Key('expense_view_mode_1')));
      await tester.pumpAndSettle();

      // Filter by Food only
      final foodChip = find.byKey(const Key('category_filter_Food'));
      expect(foodChip, findsOneWidget);
      await tester.tap(foodChip);
      await tester.pumpAndSettle();

      // Only Food group should be shown
      expect(find.byKey(const Key('category_group_Food')), findsOneWidget);
      expect(find.byKey(const Key('category_group_Transport')), findsNothing);
      expect(find.byKey(const Key('category_group_Shopping')), findsNothing);

      // Food items visible
      expect(find.text('Croissant & Coffee'), findsOneWidget);
      expect(find.text('Dinner at Le Bistro'), findsOneWidget);
      expect(find.text('Metro Weekly Pass'), findsNothing);
    });

    testWidgets('Payment Method Mode displays Payment Summaries, totals, and expense breakdowns', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1600 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget(trip: testTrip, expenses: sampleExpenses));
      await tester.pumpAndSettle();

      // Switch to Payment Method View Mode
      await tester.tap(find.byKey(const Key('expense_view_mode_2')));
      await tester.pumpAndSettle();

      // Verify payment groups exist
      expect(find.byKey(const Key('payment_group_CreditCard')), findsOneWidget);
      expect(find.byKey(const Key('payment_group_Cash')), findsOneWidget);
      expect(find.byKey(const Key('payment_group_DigitalWallet')), findsOneWidget);

      // CreditCard total: 35 + 85 = 120 EUR
      expect(find.textContaining('120'), findsWidgets);
      // Cash total: 15 EUR
      expect(find.textContaining('15'), findsWidgets);
      // DigitalWallet total: 40 EUR
      expect(find.textContaining('40'), findsWidgets);

      // Verify expenses appear in payment method breakdown
      expect(find.text('Metro Weekly Pass'), findsOneWidget);
      expect(find.text('Dinner at Le Bistro'), findsOneWidget);
      expect(find.text('Croissant & Coffee'), findsOneWidget);
      expect(find.text('Souvenir Eiffel Tower Model'), findsOneWidget);

      // Collapse CreditCard
      await tester.tap(find.byKey(const Key('payment_header_CreditCard')));
      await tester.pumpAndSettle();

      // CreditCard items hidden, Cash and DigitalWallet remain visible
      expect(find.text('Dinner at Le Bistro'), findsNothing);
      expect(find.text('Croissant & Coffee'), findsOneWidget);

      // Re-expand CreditCard
      await tester.tap(find.byKey(const Key('payment_header_CreditCard')));
      await tester.pumpAndSettle();
      expect(find.text('Dinner at Le Bistro'), findsOneWidget);
    });

    testWidgets('Payment Method Filter Chips filter down to a single payment method', (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1600 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget(trip: testTrip, expenses: sampleExpenses));
      await tester.pumpAndSettle();

      // Switch to Payment Method View Mode
      await tester.tap(find.byKey(const Key('expense_view_mode_2')));
      await tester.pumpAndSettle();

      // Filter by Cash only
      final cashChip = find.byKey(const Key('payment_filter_Cash'));
      expect(cashChip, findsOneWidget);
      await tester.tap(cashChip);
      await tester.pumpAndSettle();

      // Only Cash group should be visible
      expect(find.byKey(const Key('payment_group_Cash')), findsOneWidget);
      expect(find.byKey(const Key('payment_group_CreditCard')), findsNothing);
      expect(find.byKey(const Key('payment_group_DigitalWallet')), findsNothing);

      expect(find.text('Croissant & Coffee'), findsOneWidget);
      expect(find.text('Dinner at Le Bistro'), findsNothing);
    });

    testWidgets('Compact Screen (320px width) renders zero overflow across all modes and languages', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 1200 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      for (final locale in ['tr', 'en', 'de', 'ru', 'fr']) {
        await tester.pumpWidget(createWidget(trip: testTrip, expenses: sampleExpenses, locale: locale));
        await tester.pumpAndSettle();

        // Check Mode 0 (All)
        expect(tester.takeException(), isNull, reason: 'Overflow in All mode for $locale');

        // Switch to Category
        final mode1Finder = find.byKey(const Key('expense_view_mode_1'));
        await tester.tap(mode1Finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Overflow in Category mode for $locale');

        // Switch to Payment
        final mode2Finder = find.byKey(const Key('expense_view_mode_2'));
        await tester.tap(mode2Finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Overflow in Payment mode for $locale');
      }
    });
  });
}
