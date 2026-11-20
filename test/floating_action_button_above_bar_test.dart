import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/main_shell_scaffold.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class _FakeTripController extends StateNotifier<TripState> implements TripController {
  _FakeTripController(List<Trip> trips)
      : super(TripState(isLoading: false, trips: trips));

  @override
  Future<void> loadTrips({String? userId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  _FakeVaultController()
      : super(
          VaultState(
            isLoading: false,
            isLocked: false,
            hasPin: false,
            documents: [
              Document(
                id: 'doc-1',
                title: 'Flight Ticket',
                category: 'Ticket',
                localImagePath: '/tmp/doc.pdf',
                createdAt: DateTime(2026, 1, 1),
                updatedAt: DateTime(2026, 1, 1),
              ),
            ],
          ),
        );

  @override
  void lockVault() {}
  @override
  Future<void> loadDocuments({String? tripId, String? userId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeExpenseController extends StateNotifier<ExpenseState> implements ExpenseController {
  _FakeExpenseController()
      : super(const ExpenseState(isLoading: false, expenses: [], totalSpent: 0.0));

  @override
  Future<void> loadExpenses() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChecklistController extends StateNotifier<ChecklistState> implements ChecklistNotifier {
  _FakeChecklistController()
      : super(
          ChecklistState(
            isLoading: false,
            items: [
              PackingItem(
                id: 'item-1',
                name: 'T-Shirt',
                category: 'Kıyafet',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ],
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _sampleTrip = Trip(
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

Widget _buildMainApp({
  required String lang,
  List<Trip>? trips,
}) {
  final tripList = trips ?? [_sampleTrip];
  return ProviderScope(
    overrides: [
      tripControllerProvider.overrideWith((ref) => _FakeTripController(tripList)),
      vaultControllerProvider.overrideWith((ref) => _FakeVaultController()),
      expenseControllerProvider(_sampleTrip.id).overrideWith((ref) => _FakeExpenseController()),
      checklistControllerProvider.overrideWith((ref) => _FakeChecklistController()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainShellScaffold(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  const testScreenSizes = [
    Size(320, 568),  // iPhone SE 1st gen
    Size(390, 844),  // iPhone 14
    Size(412, 915),  // Pixel 7
    Size(800, 1280), // Tablet
  ];

  group('Floating Action Button Position Tests Above Floating Navigation Bar', () {
    for (final size in testScreenSizes) {
      testWidgets('FAB is positioned strictly ABOVE the floating bottom bar at ${size.width}x${size.height} across tabs', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildMainApp(lang: 'tr'));
        await tester.pumpAndSettle();

        // 1. Switch to Baggage / Checklist Tab (index 2)
        await tester.tap(find.byIcon(AppIcons.checklistOutlined));
        await tester.pumpAndSettle();

        final fabFinderChecklist = find.byType(FloatingActionButton);
        expect(fabFinderChecklist, findsOneWidget);

        final fabRectChecklist = tester.getRect(fabFinderChecklist);
        final navBarFinder = find.byType(ClipRRect);
        final navBarRect = tester.getRect(navBarFinder.last);
        expect(
          fabRectChecklist.bottom,
          lessThanOrEqualTo(navBarRect.top),
          reason: 'Checklist FAB bottom (${fabRectChecklist.bottom}) must be <= Nav bar top (${navBarRect.top}) at ${size.width}x${size.height}',
        );

        // 2. Switch to Vault Tab (index 3)
        await tester.tap(find.byIcon(AppIcons.vaultOutlined));
        await tester.pumpAndSettle();

        final fabFinderVault = find.byType(FloatingActionButton);
        if (fabFinderVault.evaluate().isNotEmpty) {
          final fabRectVault = tester.getRect(fabFinderVault);
          expect(
            fabRectVault.bottom,
            lessThanOrEqualTo(navBarRect.top),
            reason: 'Vault FAB bottom (${fabRectVault.bottom}) must be <= Nav bar top (${navBarRect.top}) at ${size.width}x${size.height}',
          );
        }
      });
    }

    testWidgets('FAB RTL mirroring: on Arabic (ar) locale, FAB is positioned cleanly without clipping', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildMainApp(lang: 'ar'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(AppIcons.checklistOutlined));
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      final fabRect = tester.getRect(fabFinder);
      final navBarFinder = find.byType(ClipRRect);
      final navBarRect = tester.getRect(navBarFinder.last);

      // In Arabic (RTL), FAB is mirrored to the left edge of the screen!
      expect(fabRect.left, lessThan(100.0), reason: 'In RTL locale, FAB should align to the start edge (left)');
      // And still strictly above the bottom bar!
      expect(fabRect.bottom, lessThanOrEqualTo(navBarRect.top));
    });
  });
}
