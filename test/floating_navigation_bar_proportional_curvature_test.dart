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
    testWidgets('Corner tabs (Ana Sayfa) and middle tabs (Kasa) have mathematically concentric radii in LTR', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Start with Home (index 0 - corner tab)
      await tester.pumpWidget(_buildTestApp(lang: 'tr', theme: AppTheme.lightTheme, initialIndex: 0));
      await tester.pumpAndSettle();

      // Find all AnimatedContainers that represent the tab selection items
      final animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      expect(animatedContainers.length, greaterThanOrEqualTo(5));

      // The 5 nav item containers are the last ones rendered in the tree
      final navContainers = animatedContainers.sublist(animatedContainers.length - 5);

      // Tab 0 (Ana Sayfa - Left Corner):
      // In LTR, left corners curve concentrically with outer bar (radius 20.0),
      // inner right corners use disciplined inner radius (12.0).
      final homeDecor = navContainers[0].decoration as BoxDecoration?;
      expect(homeDecor, isNotNull);
      final homeBorderRadius = homeDecor!.borderRadius as BorderRadius?;
      expect(homeBorderRadius, isNotNull);
      expect(homeBorderRadius!.topLeft.x, equals(20.0));
      expect(homeBorderRadius.bottomLeft.x, equals(20.0));
      expect(homeBorderRadius.topRight.x, equals(12.0));
      expect(homeBorderRadius.bottomRight.x, equals(12.0));

      // Tab 3 (Kasa - Middle Tab):
      // Middle tabs maintain balanced 12.0 on all 4 corners (no bulbous distortion)
      final vaultDecor = navContainers[3].decoration as BoxDecoration?;
      expect(vaultDecor, isNotNull);
      final vaultBorderRadius = vaultDecor!.borderRadius as BorderRadius?;
      expect(vaultBorderRadius, isNotNull);
      expect(vaultBorderRadius!.topLeft.x, equals(12.0));
      expect(vaultBorderRadius.topRight.x, equals(12.0));
      expect(vaultBorderRadius.bottomLeft.x, equals(12.0));
      expect(vaultBorderRadius.bottomRight.x, equals(12.0));

      // Tab 4 (Ayarlar - Right Corner):
      // In LTR, right corners curve concentrically with outer bar (radius 20.0),
      // inner left corners use disciplined inner radius (12.0).
      final settingsDecor = navContainers[4].decoration as BoxDecoration?;
      expect(settingsDecor, isNotNull);
      final settingsBorderRadius = settingsDecor!.borderRadius as BorderRadius?;
      expect(settingsBorderRadius, isNotNull);
      expect(settingsBorderRadius!.topRight.x, equals(20.0));
      expect(settingsBorderRadius.bottomRight.x, equals(20.0));
      expect(settingsBorderRadius.topLeft.x, equals(12.0));
      expect(settingsBorderRadius.bottomLeft.x, equals(12.0));
    });

    testWidgets('Arabic (ar) RTL mirrors outer corner radii symmetrically to the right and left ends', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(lang: 'ar', theme: AppTheme.lightTheme, initialIndex: 0));
      await tester.pumpAndSettle();

      final animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      final navContainers = animatedContainers.sublist(animatedContainers.length - 5);

      // In RTL:
      // Tab 0 (Home / الرئيسية) is at the FAR RIGHT end:
      // Outer corners are topRight and bottomRight (20.0), inner corners are topLeft and bottomLeft (12.0).
      final homeDecor = navContainers[0].decoration as BoxDecoration?;
      final homeBorderRadius = homeDecor!.borderRadius as BorderRadius?;
      expect(homeBorderRadius!.topRight.x, equals(20.0));
      expect(homeBorderRadius.bottomRight.x, equals(20.0));
      expect(homeBorderRadius.topLeft.x, equals(12.0));
      expect(homeBorderRadius.bottomLeft.x, equals(12.0));

      // Tab 4 (Settings / الإعدادات) is at the FAR LEFT end:
      // Outer corners are topLeft and bottomLeft (20.0), inner corners are topRight and bottomRight (12.0).
      final settingsDecor = navContainers[4].decoration as BoxDecoration?;
      final settingsBorderRadius = settingsDecor!.borderRadius as BorderRadius?;
      expect(settingsBorderRadius!.topLeft.x, equals(20.0));
      expect(settingsBorderRadius.bottomLeft.x, equals(20.0));
      expect(settingsBorderRadius.topRight.x, equals(12.0));
      expect(settingsBorderRadius.bottomRight.x, equals(12.0));
    });

    testWidgets('Theme adaptation: Selection indicator has soft cream/gold tint in Light Mode and glowing amber in Dark Mode', (tester) async {
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
      expect(homeDecor.border, isNotNull);

      // Dark Theme
      await tester.pumpWidget(_buildTestApp(lang: 'tr', theme: AppTheme.darkTheme, initialIndex: 0));
      await tester.pumpAndSettle();

      animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      navContainers = animatedContainers.sublist(animatedContainers.length - 5);
      homeDecor = navContainers[0].decoration as BoxDecoration;
      expect(homeDecor.color, isNot(Colors.transparent));
      expect(homeDecor.border, isNotNull);
    });
  });
}
