import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_comparison_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: child,
      ),
    );
  }

  group('Dashboard Hero Animations & Tag Uniqueness Suite', () {
    testWidgets('Dashboard renders all 5 new Hero badges and titles without collisions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const DashboardScreen()));
      await tester.pumpAndSettle();

      // Find all Hero widgets on the Dashboard subtree
      final heroWidgets = tester.widgetList<Hero>(find.byType(Hero)).toList();
      final tags = heroWidgets.map((h) => h.tag).toList();

      // Check for expected tags
      expect(tags, contains('trips-hero-badge'));
      expect(tags, contains('trips-hero-title'));
      expect(tags, contains('vault-hero-badge'));
      expect(tags, contains('vault-hero-title'));
      expect(tags, contains('travel-map-hero-badge'));
      expect(tags, contains('travel-map-hero-title'));
      expect(tags, contains('checklist-hero-badge'));
      expect(tags, contains('checklist-hero-title'));

      // Scroll to reveal the bottom Hub feature cards
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      final updatedHeroWidgets = tester.widgetList<Hero>(find.byType(Hero)).toList();
      final updatedTags = updatedHeroWidgets.map((h) => h.tag).toList();

      expect(updatedTags, contains('compare-trips-hero-badge'));
      expect(updatedTags, contains('compare-trips-hero-title'));
      expect(updatedTags, contains('settings-hero-badge'));
      expect(updatedTags, contains('settings-hero-title'));

      // Verify tag uniqueness (no duplicates in the active widget tree)
      final uniqueTags = updatedTags.toSet();
      expect(updatedTags.length, uniqueTags.length, reason: 'Duplicate Hero tags found in subtree: $updatedTags');
    });

    testWidgets('TripsScreen renders matching trips-hero-badge and trips-hero-title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const TripsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trips-hero-badge'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trips-hero-title'), findsOneWidget);
    });

    testWidgets('VaultScreen renders matching vault-hero-badge and vault-hero-title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const VaultScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'vault-hero-badge'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'vault-hero-title'), findsOneWidget);
    });

    testWidgets('TravelMapScreen renders matching travel-map-hero-badge and travel-map-hero-title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const TravelMapScreen()));
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'travel-map-hero-badge'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'travel-map-hero-title'), findsOneWidget);
    });

    testWidgets('TripComparisonScreen renders matching compare-trips-hero-badge and compare-trips-hero-title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const TripComparisonScreen()));
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'compare-trips-hero-badge'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'compare-trips-hero-title'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders matching settings-hero-badge and settings-hero-title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'settings-hero-badge'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'settings-hero-title'), findsOneWidget);
    });

    testWidgets('Tapping Travel Map card on Dashboard executes Hero flight without errors', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const DashboardScreen()));
      await tester.pumpAndSettle();

      // Tap on the Travel Map showcase banner
      await tester.tap(find.text('Dünya Seyahat Haritam').first);
      // Pump middle of transition to exercise Hero flight
      await tester.pump(const Duration(milliseconds: 130));
      await tester.pumpAndSettle();

      // We should now be on TravelMapScreen
      expect(find.byType(TravelMapScreen), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'travel-map-hero-title'), findsOneWidget);
    });

    testWidgets('Tapping Settings card on Dashboard executes Hero flight without errors', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const DashboardScreen()));
      await tester.pumpAndSettle();

      // Scroll down to settings card
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      // Tap on Settings feature card
      await tester.tap(find.text('Ayarlar').first);
      // Pump transition
      await tester.pump(const Duration(milliseconds: 130));
      await tester.pumpAndSettle();

      // We should now be on SettingsScreen
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'settings-hero-title'), findsOneWidget);
    });
  });
}
