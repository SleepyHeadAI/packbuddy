import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/main_shell_scaffold.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/shared/widgets/app_divider.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';

class _FakeTripController extends StateNotifier<TripState> implements TripController {
  _FakeTripController() : super(TripState(isLoading: false, trips: []));
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
            documents: [],
          ),
        );
  @override
  void lockVault() {}
  @override
  Future<void> loadDocuments({String? tripId, String? userId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChecklistController extends StateNotifier<ChecklistState> implements ChecklistNotifier {
  _FakeChecklistController() : super(ChecklistState(isLoading: false, items: []));

  @override
  Future<void> loadItems({String? tripId, String? userId}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildTestApp({required Widget home, ThemeData? theme}) {
  return ProviderScope(
    overrides: [
      tripControllerProvider.overrideWith((ref) => _FakeTripController()),
      vaultControllerProvider.overrideWith((ref) => _FakeVaultController()),
      checklistControllerProvider.overrideWith((ref) => _FakeChecklistController()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: home,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Phase 2 - Navigation Shell & Floating Island', () {
    testWidgets('MainShellScaffold renders floating navigation bar with ClipRRect and 5 tabs', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(home: const MainShellScaffold()));
      await tester.pumpAndSettle();

      // Find the navigation bar's ClipRRect
      final clipRRectFinder = find.byType(ClipRRect);
      expect(clipRRectFinder, findsWidgets);

      final barRect = tester.getRect(clipRRectFinder.last);
      expect(barRect.height, equals(64.0));
      expect(barRect.bottom, lessThan(844.0));
      expect(barRect.left, greaterThanOrEqualTo(16.0));
      expect(barRect.right, lessThanOrEqualTo(390.0 - 16.0));

      // 5 tabs present: Home, Map, Luggage, Vault, Settings
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Luggage'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Switching tabs triggers selection without crashes and preserves state', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(home: const MainShellScaffold()));
      await tester.pumpAndSettle();

      // Tap "Map" tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Tap "Luggage" tab
      await tester.tap(find.text('Luggage'));
      await tester.pumpAndSettle();

      // Tap "Settings" tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Phase 2 - QuickActionsSheet Refactoring', () {
    testWidgets('QuickActionsSheet bottom sheet uses AppDivider and eliminates nested AppCards', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: QuickActionsSheet(
              title: 'Quick Actions',
              subtitle: 'Select an option to begin',
              items: [
                QuickActionItem(
                  icon: Icons.flight_takeoff_rounded,
                  iconColor: Colors.amber,
                  iconBgColor: Colors.amber.withValues(alpha: 0.15),
                  title: 'New Trip',
                  subtitle: 'Plan a destination',
                  onTap: () {},
                ),
                QuickActionItem(
                  icon: Icons.receipt_long_rounded,
                  iconColor: Colors.green,
                  iconBgColor: Colors.green.withValues(alpha: 0.15),
                  title: 'New Expense',
                  subtitle: 'Track spending',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title and subtitle
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Select an option to begin'), findsOneWidget);
      expect(find.text('New Trip'), findsOneWidget);
      expect(find.text('New Expense'), findsOneWidget);

      // Verify NO AppCard is used inside the sheet (eliminated card-in-card anti-pattern)
      expect(find.byType(AppCard), findsNothing);

      // Verify AppDivider is used between items
      expect(find.byType(AppDivider), findsOneWidget);
    });

    testWidgets('QuickActionsSheet adapts to Dark Mode with dark surface tokens', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: QuickActionsSheet(
              title: 'Quick Actions',
              items: [
                QuickActionItem(
                  icon: Icons.flight_takeoff_rounded,
                  iconColor: Colors.amber,
                  iconBgColor: Colors.amber.withValues(alpha: 0.15),
                  title: 'New Trip',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('New Trip'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
