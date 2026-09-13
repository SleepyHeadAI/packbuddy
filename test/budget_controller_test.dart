import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_progress_card.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  group('Budget Models and State Logic Tests', () {
    test('Trip copyWith works as expected', () {
      final trip = Trip(
        id: 'trip-1',
        title: 'Rome Holiday',
        destination: 'Rome, Italy',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 10),
        defaultCurrency: 'EUR',
        budgetLimit: 1500.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedTrip = trip.copyWith(budgetLimit: 2000.0);
      expect(updatedTrip.budgetLimit, 2000.0);
      expect(updatedTrip.title, 'Rome Holiday');
    });

    test('Expense sum calculation works correctly', () {
      final expenses = [
        Expense(
          id: '1',
          tripId: 'trip-1',
          title: 'Lunch',
          amount: 25.50,
          currency: 'EUR',
          category: 'Food',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Expense(
          id: '2',
          tripId: 'trip-1',
          title: 'Train',
          amount: 74.50,
          currency: 'EUR',
          category: 'Transport',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final total = expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
      expect(total, 100.0);

      const budgetLimit = 1500.0;
      final remaining = budgetLimit - total;
      expect(remaining, 1400.0);
    });
  });

  group('BudgetProgressCard Widget Tests', () {
    testWidgets('Renders budget, spent and remaining correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('tr'),
          home: Scaffold(
            body: BudgetProgressCard(
              budgetLimit: 1000.0,
              totalSpent: 400.0,
              currency: 'EUR',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify progress percentage is 40%
      expect(find.text('%40'), findsOneWidget);
      expect(find.text('Bütçe'), findsOneWidget);
      expect(find.text('Harcanan'), findsOneWidget);
      expect(find.text('Kalan'), findsOneWidget);
    });
  });
}
