import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeTripController extends StateNotifier<TripState> implements TripController {
  FakeTripController(List<Trip> trips)
      : super(TripState(isLoading: false, trips: trips));

  @override
  Future<void> loadTrips() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  FakeVaultController() : super(const VaultState(isLoading: false, documents: []));

  @override
  Future<void> loadDocuments({String? tripId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeExpenseController extends StateNotifier<ExpenseState> implements ExpenseController {
  FakeExpenseController() : super(const ExpenseState(isLoading: false, expenses: [], totalSpent: 0.0));

  @override
  Future<void> loadExpenses() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final sampleTrip = Trip(
    id: 'test-trip-1',
    title: 'Paris Getaway',
    destination: 'Paris, France',
    startDate: DateTime(2026, 7, 1),
    endDate: DateTime(2026, 7, 10),
    defaultCurrency: 'EUR',
    budgetLimit: 1200.0,
    transportMode: 'Flight',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Widget createTestWidget({required Widget child, List<Trip>? trips}) {
    return ProviderScope(
      overrides: [
        tripControllerProvider.overrideWith(
          (ref) => FakeTripController(trips ?? [sampleTrip]),
        ),
        vaultControllerProvider.overrideWith(
          (ref) => FakeVaultController(),
        ),
        expenseControllerProvider(sampleTrip.id).overrideWith(
          (ref) => FakeExpenseController(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: child,
      ),
    );
  }

  group('Navigation & GlobalKey/Hero Safety Tests', () {
    testWidgets('DashboardScreen FAB has heroTag null', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const DashboardScreen()));
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(fab.heroTag, isNull, reason: 'Hero tag must be null to avoid RepaintBoundary GlobalKey conflicts');
    });

    testWidgets('TripsScreen FAB has heroTag null and explicit leading back button pops to previous screen', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const DashboardScreen()));
      await tester.pumpAndSettle();

      // Navigate to TripsScreen via Bento card
      final tripsCard = find.widgetWithText(InkWell, 'Seyahatler');
      expect(tripsCard, findsWidgets);
      await tester.tap(tripsCard.first);
      await tester.pumpAndSettle();

      // Verify TripsScreen is mounted
      expect(find.byType(TripsScreen), findsOneWidget);

      // Verify TripsScreen FAB has heroTag null
      final tripsFab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(tripsFab.heroTag, isNull, reason: 'TripsScreen FAB must have heroTag null');

      // Verify explicit leading IconButton exists
      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(IconButton),
      );
      expect(backButton, findsOneWidget);

      // Tap back button and verify navigation back to Dashboard
      await tester.tap(backButton.first);
      await tester.pumpAndSettle();

      expect(find.byType(TripsScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('VaultScreen FAB has heroTag null and leading back button pops properly', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const DashboardScreen()));
      await tester.pumpAndSettle();

      // Navigate to VaultScreen via Bento card
      final vaultCard = find.widgetWithText(InkWell, 'Belge Kasası');
      expect(vaultCard, findsWidgets);
      await tester.ensureVisible(vaultCard.first);
      await tester.pumpAndSettle();
      await tester.tap(vaultCard.first);
      await tester.pumpAndSettle();

      expect(find.byType(VaultScreen), findsOneWidget);

      // Verify VaultScreen FAB has heroTag null
      final vaultFab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(vaultFab.heroTag, isNull);

      // Tap leading back button
      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(IconButton),
      );
      expect(backButton, findsOneWidget);

      await tester.tap(backButton.first);
      await tester.pumpAndSettle();

      expect(find.byType(VaultScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('TripDetailScreen FAB has heroTag null and leading back button pops properly', (tester) async {
      await tester.pumpWidget(createTestWidget(child: TripDetailScreen(trip: sampleTrip)));
      await tester.pumpAndSettle();

      expect(find.byType(TripDetailScreen), findsOneWidget);

      // Verify FAB has heroTag null
      final detailFab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(detailFab.heroTag, isNull);

      // Verify leading back button exists
      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byWidgetPredicate(
          (w) => w is IconButton && (w.icon as Icon).icon == Icons.arrow_back_rounded,
        ),
      );
      expect(backButton, findsOneWidget);
    });

    testWidgets('SettingsScreen leading back button pops properly', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const DashboardScreen()));
      await tester.pumpAndSettle();

      // Tap Settings button in Dashboard AppBar
      final settingsIcon = find.byIcon(Icons.settings_outlined);
      expect(settingsIcon, findsOneWidget);
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);

      // Tap back button
      final backButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byWidgetPredicate(
          (w) => w is IconButton && (w.icon as Icon).icon == Icons.arrow_back_rounded,
        ),
      );
      expect(backButton, findsOneWidget);

      await tester.tap(backButton.first);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}
