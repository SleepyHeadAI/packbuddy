import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget({
    required Trip trip,
    required List<Expense> expenses,
    required double totalSpent,
    String locale = 'tr',
  }) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale(locale),
        home: Scaffold(
          body: SingleChildScrollView(
            child: BudgetAnalyticsCard(
              trip: trip,
              expenses: expenses,
              tripCurrency: trip.defaultCurrency,
              totalSpent: totalSpent,
            ),
          ),
        ),
      ),
    );
  }

  group('BudgetAnalyticsCard Pacing & Burn Rate Logic Tests', () {
    testWidgets('Upcoming Trip with 1 flight expense (\$350 out of \$3000) shows Yolunda (On Track), NOT warning', (tester) async {
      final now = DateTime.now();
      final upcomingTrip = Trip(
        id: 'trip-us-1',
        title: 'US Trip',
        destination: 'United States',
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 20)),
        budgetLimit: 3000,
        defaultCurrency: 'USD',
        createdAt: now,
        updatedAt: now,
      );

      final expenses = [
        Expense(
          id: 'exp-1',
          tripId: 'trip-us-1',
          title: 'Flight Ticket',
          amount: 350.0,
          currency: 'USD',
          category: 'transportation',
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          trip: upcomingTrip,
          expenses: expenses,
          totalSpent: 350.0,
          locale: 'tr',
        ),
      );
      await tester.pumpAndSettle();

      // In Turkish, should show 'Yolunda'
      expect(find.text('Bütçe Dahilinde'), findsOneWidget);
      // Must NOT show 'Yüksek Harcama Hızı'
      expect(find.text('Yüksek Harcama Hızı'), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('User screenshot case: 3 expenses (\$415 out of \$3000, 13.8% budget) shows Yolunda', (tester) async {
      final now = DateTime.now();
      final upcomingTrip = Trip(
        id: 'trip-us-2',
        title: 'US Trip',
        destination: 'United States',
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 15)),
        budgetLimit: 3000,
        defaultCurrency: 'USD',
        createdAt: now,
        updatedAt: now,
      );

      final expenses = [
        Expense(
          id: 'exp-1',
          tripId: 'trip-us-2',
          title: 'Flight Ticket',
          amount: 350.0,
          currency: 'USD',
          category: 'transportation',
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
        Expense(
          id: 'exp-2',
          tripId: 'trip-us-2',
          title: 'Hotel Deposit',
          amount: 50.0,
          currency: 'USD',
          category: 'accommodation',
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
        Expense(
          id: 'exp-3',
          tripId: 'trip-us-2',
          title: 'Snack',
          amount: 15.0,
          currency: 'USD',
          category: 'food',
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          trip: upcomingTrip,
          expenses: expenses,
          totalSpent: 415.0,
          locale: 'tr',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bütçe Dahilinde'), findsOneWidget);
      expect(find.text('Yüksek Harcama Hızı'), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('Ongoing Trip Day 1 with 1 hotel expense (\$120 out of \$600) shows Yolunda (early stage protection)', (tester) async {
      final now = DateTime.now();
      final ongoingTrip = Trip(
        id: 'trip-paris-1',
        title: 'Paris Trip',
        destination: 'Paris',
        startDate: now, // Day 1
        endDate: now.add(const Duration(days: 5)),
        budgetLimit: 600,
        defaultCurrency: 'EUR',
        createdAt: now,
        updatedAt: now,
      );

      final expenses = [
        Expense(
          id: 'exp-1',
          tripId: 'trip-paris-1',
          title: 'Hotel Night 1',
          amount: 120.0,
          currency: 'EUR',
          category: 'accommodation',
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          trip: ongoingTrip,
          expenses: expenses,
          totalSpent: 120.0,
          locale: 'tr',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bütçe Dahilinde'), findsOneWidget);
      expect(find.text('Yüksek Harcama Hızı'), findsNothing);
    });

    testWidgets('Ongoing Trip Day 3 of 10 with 75% budget burned triggers Yüksek Harcama Hızı legitimately', (tester) async {
      final now = DateTime.now();
      final ongoingTrip = Trip(
        id: 'trip-tokyo-1',
        title: 'Tokyo Trip',
        destination: 'Tokyo',
        startDate: now.subtract(const Duration(days: 2)), // Day 3
        endDate: now.add(const Duration(days: 7)), // Total 10 days
        budgetLimit: 1000,
        defaultCurrency: 'USD',
        createdAt: now,
        updatedAt: now,
      );

      final expenses = [
        Expense(
          id: 'exp-1',
          tripId: 'trip-tokyo-1',
          title: 'Expensive Shopping',
          amount: 750.0,
          currency: 'USD',
          category: 'shopping',
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
        Expense(
          id: 'exp-2',
          tripId: 'trip-tokyo-1',
          title: 'Sushi dinner',
          amount: 50.0,
          currency: 'USD',
          category: 'food',
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
        Expense(
          id: 'exp-3',
          tripId: 'trip-tokyo-1',
          title: 'Taxi',
          amount: 40.0,
          currency: 'USD',
          category: 'transportation',
          date: now,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          trip: ongoingTrip,
          expenses: expenses,
          totalSpent: 840.0,
          locale: 'tr',
        ),
      );
      await tester.pumpAndSettle();

      // Here 84% is spent by day 3 -> legitimately Yüksek Harcama Hızı
      expect(find.text('Yüksek Harcama Hızı'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });
  });
}
