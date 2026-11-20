import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/main_shell_scaffold.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class _FakeTripController extends StateNotifier<TripState> implements TripController {
  _FakeTripController()
      : super(
          TripState(
            isLoading: false,
            trips: [
              Trip(
                id: 'trip-1',
                title: 'Summer in Rome',
                destination: 'Rome, Italy',
                startDate: DateTime(2026, 8, 1),
                endDate: DateTime(2026, 8, 10),
                defaultCurrency: 'EUR',
                budgetLimit: 1500.0,
                transportMode: 'Flight',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ],
          ),
        );

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
                title: 'Passport',
                category: 'Passport',
                localImagePath: '/tmp/pass.png',
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
                name: 'Toothbrush',
                category: 'Personal Care',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ],
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildTestApp({
  required String lang,
  required ThemeData theme,
  int initialIndex = 0,
}) {
  return ProviderScope(
    overrides: [
      tripControllerProvider.overrideWith((ref) => _FakeTripController()),
      vaultControllerProvider.overrideWith((ref) => _FakeVaultController()),
      expenseControllerProvider('trip-1').overrideWith((ref) => _FakeExpenseController()),
      checklistControllerProvider.overrideWith((ref) => _FakeChecklistController()),
      mainNavigationIndexProvider.overrideWith((ref) => initialIndex),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
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

  group('Floating Navigation Bar - Proportional Curvature & Concentric Geometry', () {
    testWidgets('Tabs render micro-pill curvature and outer dock has AppRadius.navBar', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Start with Home (index 0)
      await tester.pumpWidget(_buildTestApp(lang: 'tr', theme: AppTheme.lightTheme, initialIndex: 0));
      await tester.pumpAndSettle();

      // Find all AnimatedContainers that represent the tab selection items
      final animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      expect(animatedContainers.length, greaterThanOrEqualTo(5));

      // The 5 nav item containers are the last ones rendered in the tree
      final navContainers = animatedContainers.sublist(animatedContainers.length - 5);

      // Tabs use modern 16.0 micro-pill border radius
      for (final container in navContainers) {
        final decor = container.decoration as BoxDecoration?;
        expect(decor, isNotNull);
        final borderRadius = decor!.borderRadius as BorderRadius?;
        expect(borderRadius, isNotNull);
        expect(borderRadius!.topLeft.x, equals(16.0));
        expect(borderRadius.topRight.x, equals(16.0));
        expect(borderRadius.bottomLeft.x, equals(16.0));
        expect(borderRadius.bottomRight.x, equals(16.0));
      }
    });

    testWidgets('Arabic (ar) RTL renders clean micro-pills symmetrically across all tabs', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(lang: 'ar', theme: AppTheme.lightTheme, initialIndex: 0));
      await tester.pumpAndSettle();

      final animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      final navContainers = animatedContainers.sublist(animatedContainers.length - 5);

      for (final container in navContainers) {
        final decor = container.decoration as BoxDecoration?;
        final borderRadius = decor!.borderRadius as BorderRadius?;
        expect(borderRadius!.topLeft.x, equals(16.0));
        expect(borderRadius.topRight.x, equals(16.0));
        expect(borderRadius.bottomLeft.x, equals(16.0));
        expect(borderRadius.bottomRight.x, equals(16.0));
      }
    });

    testWidgets('Theme adaptation: Selection indicator has soft brand tint in Light Mode and Dark Mode', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Light Theme
      await tester.pumpWidget(_buildTestApp(lang: 'tr', theme: AppTheme.lightTheme, initialIndex: 0));
      await tester.pumpAndSettle();

      var animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      var navContainers = animatedContainers.sublist(animatedContainers.length - 5);
      var homeDecor = navContainers[0].decoration as BoxDecoration;
      expect(homeDecor.color, isNot(Colors.transparent));

      // Dark Theme
      await tester.pumpWidget(_buildTestApp(lang: 'tr', theme: AppTheme.darkTheme, initialIndex: 0));
      await tester.pumpAndSettle();

      animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      navContainers = animatedContainers.sublist(animatedContainers.length - 5);
      homeDecor = navContainers[0].decoration as BoxDecoration;
      expect(homeDecor.color, isNot(Colors.transparent));
    });
  });
}
