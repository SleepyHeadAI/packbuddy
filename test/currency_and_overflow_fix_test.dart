import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/shared/widgets/status_badge.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_progress_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  group('Startup Date Formatting & Locale Safety Tests', () {
    test('AppDateFormatter formats safely in tr locale without throwing', () {
      final date = DateTime(2026, 9, 14, 15, 30);
      
      final mmmd = AppDateFormatter.formatMMMd(date, locale: 'tr');
      expect(mmmd, isNotEmpty);
      expect(mmmd.toLowerCase(), contains('eyl'));

      final ymmmd = AppDateFormatter.formatYMMMd(date, locale: 'tr');
      expect(ymmmd, isNotEmpty);
      expect(ymmmd, contains('2026'));

      final dateTimeStr = AppDateFormatter.formatDateTime(date);
      expect(dateTimeStr, isNotEmpty);
      expect(dateTimeStr, contains(':'));
    });

    test('AppDateFormatter falls back safely when locale is invalid or uninitialized', () {
      final date = DateTime(2026, 5, 20);
      final formatted = AppDateFormatter.formatMMMd(date, locale: 'invalid_locale_xyz');
      expect(formatted, isNotEmpty);

      final dateRange = AppDateFormatter.formatDateRange(
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 10),
        locale: 'invalid_locale_xyz',
      );
      expect(dateRange, isNotEmpty);
      expect(dateRange, contains('-'));
    });

    test('AppDateFormatter formatDateRange handles same-day and multi-day ranges properly', () {
      final start = DateTime(2026, 7, 10);
      final end = DateTime(2026, 7, 10);
      final singleDay = AppDateFormatter.formatDateRange(start, end, locale: 'tr');
      expect(singleDay, isNotEmpty);

      final multiDay = AppDateFormatter.formatDateRange(start, DateTime(2026, 7, 15), locale: 'tr');
      expect(multiDay, isNotEmpty);
      expect(multiDay, contains('-'));
    });
  });

  group('Currency Consistency Tests', () {
    test('CurrencyFormatter correctly formats TRY, USD, EUR, and GBP', () {
      expect(CurrencyFormatter.format(1500.0, currency: 'TRY'), contains('₺'));
      expect(CurrencyFormatter.format(250.0, currency: 'USD'), contains('\$'));
      expect(CurrencyFormatter.format(99.0, currency: 'EUR'), contains('€'));
      expect(CurrencyFormatter.format(50.0, currency: 'GBP'), contains('£'));
      expect(CurrencyFormatter.getSymbol('TRY'), equals('₺'));
      expect(CurrencyFormatter.getSymbol('USD'), equals('\$'));
    });

    test('Expenses under a TRY trip preserve TRY currency symbol and amount', () {
      final trip = Trip(
        id: 'trip-try',
        title: 'Antalya Tatili',
        destination: 'Antalya, TR',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 7),
        budgetLimit: 25000.0,
        defaultCurrency: 'TRY',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final expense = Expense(
        id: 'exp-1',
        tripId: trip.id,
        title: 'Otel Konaklama',
        amount: 12500.0,
        currency: trip.defaultCurrency,
        category: 'Accommodation',
        date: DateTime(2026, 8, 2),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final formatted = CurrencyFormatter.format(expense.amount, currency: trip.defaultCurrency);
      expect(formatted, contains('₺'));
      expect(formatted, contains('12,500'));
      expect(formatted, isNot(contains('\$')));
      expect(formatted, isNot(contains('€')));
    });

    test('Expenses under a USD trip preserve USD currency symbol and amount', () {
      final trip = Trip(
        id: 'trip-usd',
        title: 'New York Trip',
        destination: 'New York, USA',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 7),
        budgetLimit: 3000.0,
        defaultCurrency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final expense = Expense(
        id: 'exp-2',
        tripId: trip.id,
        title: 'Flight Ticket',
        amount: 850.0,
        currency: trip.defaultCurrency,
        category: 'Transport',
        date: DateTime(2026, 10, 1),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final formatted = CurrencyFormatter.format(expense.amount, currency: trip.defaultCurrency);
      expect(formatted, contains('\$'));
      expect(formatted, isNot(contains('₺')));
      expect(formatted, isNot(contains('€')));
    });
  });

  group('UI Overflow & RenderFlex Safety Tests', () {
    testWidgets('StatusBadge handles long labels within narrow row without overflow stripes',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Very long greeting text that takes almost all space in greeting card',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  StatusBadge(
                    label: 'Very Long Status Text Label Here',
                    icon: Icons.sync_rounded,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('BudgetProgressCard renders cleanly on 320px width without overflow',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 600));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(8.0),
              child: BudgetProgressCard(
                budgetLimit: 150000.0,
                totalSpent: 98750.50,
                currency: 'TRY',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Bütçe'), findsOneWidget);
    });

    testWidgets('AddExpenseSheet renders locked currency badge and inputs without overflow',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      AddExpenseSheet.show(
                        context,
                        tripId: 'test-trip-1',
                        defaultCurrency: 'TRY',
                      );
                    },
                    child: const Text('Harcama Ekle'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Tap button to open bottom sheet
      await tester.tap(find.text('Harcama Ekle'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Verify locked currency badge is displayed showing TRY symbol
      expect(find.text('₺'), findsWidgets);
      expect(find.text('TRY'), findsWidgets);
    });

    testWidgets('DashboardScreen renders cleanly with PRO badge and all actions on 320px width without overflow',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 600));
      SharedPreferences.setMockInitialValues({'packbuddy_is_pro_member': true});
      await PreferencesService.init();

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
      expect(tester.takeException(), isNull);
      expect(find.text('PRO'), findsOneWidget);
    });
  });
}
