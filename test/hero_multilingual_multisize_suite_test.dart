import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/profile_screen.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/document_viewer_screen.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/main_shell_scaffold.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class MockTripController extends StateNotifier<TripState> implements TripController {
  MockTripController(List<Trip> trips) : super(TripState(isLoading: false, trips: trips));
  @override
  Future<void> loadTrips({String? userId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockVaultController extends StateNotifier<VaultState> implements VaultController {
  MockVaultController(List<Document> docs)
      : super(VaultState(isLoading: false, isLocked: false, hasPin: true, documents: docs));
  @override
  void lockVault() {}
  @override
  bool unlockVault(String pin) => true;
  @override
  bool isPinLockedOut() => false;
  @override
  int getPinLockoutRemainingSeconds() => 0;
  @override
  int getRemainingPinAttempts() => 5;
  @override
  Future<void> loadDocuments({String? tripId, String? userId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockExpenseController extends StateNotifier<ExpenseState> implements ExpenseController {
  MockExpenseController() : super(const ExpenseState(isLoading: false, expenses: [], totalSpent: 0.0));
  @override
  Future<void> loadExpenses() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockProfileController extends StateNotifier<ProfileState> implements ProfileController {
  MockProfileController(UserProfile profile)
      : super(ProfileState(isLoading: false, profile: profile, totalTrips: 3, totalCountriesVisited: 5, totalDocuments: 4));
  @override
  Future<void> loadProfile(String uid) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockChecklistController extends StateNotifier<ChecklistState> implements ChecklistNotifier {
  MockChecklistController([List<PackingItem>? items])
      : super(
          ChecklistState(
            isLoading: false,
            items: items ?? [
              PackingItem(
                id: 'hero-item-1',
                name: 'Passport & Documents',
                category: 'Belgeler',
                isPacked: true,
                createdAt: DateTime(2026, 1, 1),
                updatedAt: DateTime(2026, 1, 1),
              ),
              PackingItem(
                id: 'hero-item-2',
                name: 'Universal Power Adapter',
                category: 'Elektronik',
                isPacked: false,
                createdAt: DateTime(2026, 1, 1),
                updatedAt: DateTime(2026, 1, 1),
              ),
            ],
          ),
        );

  @override
  Future<void> loadItems({String? tripId, String? userId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTravelMapController extends StateNotifier<TravelMapState> implements TravelMapController {
  MockTravelMapController()
      : super(
          TravelMapState(
            isLoading: false,
            countries: [
              TravelCountry(
                code: 'TR',
                nameTr: 'Türkiye',
                nameEn: 'Turkey',
                flag: '🇹🇷',
                continent: 'Europe',
                capital: 'Ankara',
                latitude: 39.9334,
                longitude: 32.8597,
                status: CountryStatus.visited,
                visitedDate: DateTime(2026, 1, 1),
              ),
              TravelCountry(
                code: 'JP',
                nameTr: 'Japonya',
                nameEn: 'Japan',
                flag: '🇯🇵',
                continent: 'Asia',
                capital: 'Tokyo',
                latitude: 35.6762,
                longitude: 139.6503,
                status: CountryStatus.visited,
                visitedDate: DateTime(2026, 2, 1),
              ),
            ],
          ),
        );

  @override
  Future<void> loadCountries({String? userId, bool showLoading = false}) async {}
  @override
  void setFilter(String filter) {}
  @override
  void setSearchQuery(String query) {}
  @override
  Future<void> refreshFromCloud({String? userId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  const allSupportedLocales = [
    'ar', 'de', 'el', 'en', 'es', 'fr', 'hi', 'id', 'it', 'ja',
    'ko', 'nl', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'vi', 'zh',
  ];

  const testDimensions = <String, Size>{
    'Small (320x568)': Size(320, 568),
    'Standard (390x844)': Size(390, 844),
    'Large Phone (428x926)': Size(428, 926),
    'Tablet (800x1280)': Size(800, 1280),
  };

  final sampleTrip = Trip(
    id: 'hero-test-trip-1',
    title: 'Tokyo & Kyoto Cultural Odyssey',
    destination: 'Tokyo, Japan',
    startDate: DateTime(2026, 9, 1),
    endDate: DateTime(2026, 9, 14),
    defaultCurrency: 'JPY',
    budgetLimit: 350000.0,
    transportMode: 'Flight',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final sampleDoc = Document(
    id: 'hero-test-doc-1',
    userId: 'user-123',
    title: 'International Flight E-Ticket & Boarding Pass',
    category: 'Ticket',
    localImagePath: '/tmp/test_ticket.pdf',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final sampleProfile = UserProfile(
    uid: 'user-123',
    displayName: 'Aura Traveler',
    email: 'traveler@packbuddy.app',
    homeCountryCode: 'TR',
    homeCity: 'Istanbul',
    createdAt: DateTime(2026, 1, 1),
  );

  Widget createTestApp({
    required Widget child,
    required Locale locale,
    ThemeData? theme,
  }) {
    return ProviderScope(
      overrides: [
        tripControllerProvider.overrideWith((ref) => MockTripController([sampleTrip])),
        vaultControllerProvider.overrideWith((ref) => MockVaultController([sampleDoc])),
        expenseControllerProvider(sampleTrip.id).overrideWith((ref) => MockExpenseController()),
        profileControllerProvider.overrideWith((ref) => MockProfileController(sampleProfile)),
        checklistControllerProvider.overrideWith((ref) => MockChecklistController()),
        travelMapControllerProvider.overrideWith((ref) => MockTravelMapController()),
      ],
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: child,
      ),
    );
  }

  group('Hero Animations Multi-Language & Multi-Size Validation Suite', () {
    testWidgets('1. Dashboard renders all Hero tags with ZERO duplicates across all 20 languages', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in allSupportedLocales) {
        await tester.pumpWidget(createTestApp(
          child: const DashboardScreen(),
          locale: Locale(lang),
        ));
        await tester.pumpAndSettle();

        final heroes = tester.widgetList<Hero>(find.byType(Hero)).toList();
        final tags = heroes.map((h) => h.tag.toString()).toList();

        // Key shared element badges and titles must be present
        expect(tags, contains('vault-hero-badge'), reason: 'Missing vault-hero-badge in $lang');
        expect(tags, contains('vault-hero-title'), reason: 'Missing vault-hero-title in $lang');
        expect(tags, contains('travel-map-hero-badge'), reason: 'Missing travel-map-hero-badge in $lang');
        expect(tags, contains('travel-map-hero-title'), reason: 'Missing travel-map-hero-title in $lang');
        expect(tags, contains('checklist-hero-badge'), reason: 'Missing checklist-hero-badge in $lang');
        expect(tags, contains('checklist-hero-title'), reason: 'Missing checklist-hero-title in $lang');
        expect(tags, contains('compare-trips-hero-badge'), reason: 'Missing compare-trips-hero-badge in $lang');
        expect(tags, contains('compare-trips-hero-title'), reason: 'Missing compare-trips-hero-title in $lang');
        expect(tags, contains('trips-hero-badge'), reason: 'Missing trips-hero-badge in $lang');
        expect(tags, contains('trips-hero-title'), reason: 'Missing trips-hero-title in $lang');
        expect(tags, contains('dashboard-profile-avatar'), reason: 'Missing dashboard-profile-avatar in $lang');
        expect(tags, contains('trip-title-${sampleTrip.id}'), reason: 'Missing trip-title in $lang');
        expect(tags, contains('trip-transport-icon-${sampleTrip.id}'), reason: 'Missing transport icon in $lang');
        expect(tags, contains('trip-destination-${sampleTrip.id}'), reason: 'Missing destination in $lang');

        // Verify 100% uniqueness (no Hero tag collisions anywhere in widget tree)
        final uniqueTags = tags.toSet();
        expect(tags.length, uniqueTags.length, reason: 'Duplicate Hero tags detected in locale $lang: $tags');
        expect(tester.takeException(), isNull, reason: 'Layout exception in locale $lang');
      }
    });

    testWidgets('2. Dashboard renders cleanly across all 4 form factors without overflow', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final entry in testDimensions.entries) {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestApp(
          child: const DashboardScreen(),
          locale: const Locale('tr'),
        ));
        await tester.pumpAndSettle();

        // Expect no render exceptions
        expect(tester.takeException(), isNull, reason: 'Render exception at ${entry.key}');
      }
    });

    testWidgets('3. TripsScreen & TripDetailScreen match Hero tags across sizes and languages', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final entry in testDimensions.entries) {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        for (final lang in ['tr', 'en', 'ar', 'de', 'zh']) {
          // Verify TripsScreen
          await tester.pumpWidget(createTestApp(
            child: const TripsScreen(),
            locale: Locale(lang),
          ));
          await tester.pumpAndSettle();

          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trips-hero-badge'), findsOneWidget);
          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trips-hero-title'), findsOneWidget);
          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trip-title-${sampleTrip.id}'), findsOneWidget);
          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trip-transport-icon-${sampleTrip.id}'), findsOneWidget);
          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trip-destination-${sampleTrip.id}'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Verify TripDetailScreen
          await tester.pumpWidget(createTestApp(
            child: TripDetailScreen(trip: sampleTrip),
            locale: Locale(lang),
          ));
          await tester.pumpAndSettle();

          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trip-title-${sampleTrip.id}'), findsOneWidget);
          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trip-transport-icon-${sampleTrip.id}'), findsOneWidget);
          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trip-destination-${sampleTrip.id}'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('4. VaultScreen & DocumentViewerScreen match Hero tags across sizes and languages', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final entry in testDimensions.entries) {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        for (final lang in ['tr', 'en', 'es', 'ja', 'ru']) {
          // VaultScreen
          await tester.pumpWidget(createTestApp(
            child: const VaultScreen(),
            locale: Locale(lang),
          ));
          await tester.pumpAndSettle();

          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'vault-hero-badge'), findsOneWidget);
          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'vault-hero-title'), findsOneWidget);
          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'doc-title-${sampleDoc.id}'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // DocumentViewerScreen (pump without infinite wait due to CircularProgressIndicator)
          await tester.pumpWidget(createTestApp(
            child: DocumentViewerScreen(document: sampleDoc),
            locale: Locale(lang),
          ));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'doc-title-${sampleDoc.id}'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('5. ProfileScreen avatar Hero tag works across sizes and RTL/LTR without overflow', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final entry in testDimensions.entries) {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        for (final lang in ['ar', 'tr', 'en', 'zh', 'el']) {
          await tester.pumpWidget(createTestApp(
            child: const ProfileScreen(avatarHeroTag: 'dashboard-profile-avatar'),
            locale: Locale(lang),
          ));
          await tester.pumpAndSettle();

          expect(
            find.byWidgetPredicate((w) => w is Hero && w.tag == 'dashboard-profile-avatar'),
            findsOneWidget,
            reason: 'ProfileScreen must mount dashboard-profile-avatar Hero in $lang at ${entry.key}',
          );
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('6. Hero flight transitions execute smoothly between Dashboard and TripsScreen', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp(
        child: const DashboardScreen(),
        locale: const Locale('tr'),
      ));
      await tester.pumpAndSettle();

      // Scroll down to reveal All Trips companion tile
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();

      final tripsFinder = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'trips-hero-title',
      );
      expect(tripsFinder, findsOneWidget);
      await tester.tap(tripsFinder);

      // Pump mid-flight to exercise Hero flight
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.byType(TripsScreen), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'trips-hero-title'), findsOneWidget);
    });

    testWidgets('7. MainShellScaffold mounts all 5 tabs simultaneously with ZERO duplicate Hero tags across all 20 languages', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in allSupportedLocales) {
        await tester.pumpWidget(createTestApp(
          child: const MainShellScaffold(),
          locale: Locale(lang),
        ));
        await tester.pumpAndSettle();

        final heroes = tester.widgetList<Hero>(find.byType(Hero)).toList();
        final tags = heroes.map((h) => h.tag.toString()).toList();
        final uniqueTags = tags.toSet();

        expect(
          tags.length,
          uniqueTags.length,
          reason: 'Duplicate Hero tags found in MainShellScaffold for locale $lang: $tags',
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('8. TravelMapScreen Hero flight from Dashboard executes smoothly without duplicate tag collision across languages and sizes', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final entry in testDimensions.entries) {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        for (final lang in ['tr', 'en', 'de', 'ar', 'zh']) {
          await tester.pumpWidget(createTestApp(
            child: const DashboardScreen(),
            locale: Locale(lang),
          ));
          await tester.pumpAndSettle();

          // Scroll to make sure travel map card is visible
          final listViewFinder = find.byType(ListView);
          if (listViewFinder.evaluate().isNotEmpty) {
            await tester.drag(listViewFinder.first, const Offset(0, -300));
            await tester.pumpAndSettle();
          }

          final mapHeroFinder = find.byWidgetPredicate(
            (w) => w is Hero && w.tag == 'travel-map-hero-title',
          );
          expect(mapHeroFinder, findsOneWidget, reason: 'Travel map hero title not found on dashboard in $lang at ${entry.key}');
          await tester.tap(mapHeroFinder);

          // Pump mid-flight to exercise Hero flight animation
          await tester.pump(const Duration(milliseconds: 130));
          expect(tester.takeException(), isNull, reason: 'Hero flight exception in $lang at ${entry.key}');

          await tester.pumpAndSettle();
          expect(find.byType(TravelMapScreen), findsOneWidget);
          expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'travel-map-hero-title'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Pop back to Dashboard
          final backIconFinder = find.byIcon(AppIcons.chevronLeft);
          if (backIconFinder.evaluate().isNotEmpty) {
            await tester.tap(backIconFinder.first);
          } else {
            await tester.pageBack();
          }
          await tester.pumpAndSettle();
          expect(find.byType(DashboardScreen), findsOneWidget);
        }
      }
    });

    testWidgets('9. ChecklistScreen Hero flight and Overview Card displays packingReadiness without duplication or truncation across 20 languages and 4 sizes', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Part A: Flight test from Dashboard
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestApp(
        child: const DashboardScreen(),
        locale: const Locale('tr'),
      ));
      await tester.pumpAndSettle();

      final checklistHeroFinder = find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'checklist-hero-title',
      );
      expect(checklistHeroFinder, findsOneWidget);
      await tester.tap(checklistHeroFinder);

      // Mid-flight check
      await tester.pump(const Duration(milliseconds: 130));
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      expect(find.byType(ChecklistScreen), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'checklist-hero-title'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Part B: Multi-language & multi-size validation of ChecklistScreen overview card
      for (final entry in testDimensions.entries) {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;

        for (final lang in allSupportedLocales) {
          await tester.pumpWidget(createTestApp(
            child: const ChecklistScreen(isTabMode: false),
            locale: Locale(lang),
          ));
          await tester.pumpAndSettle();

          final l10n = AppLocalizations.of(tester.element(find.byType(ChecklistScreen)))!;
          // Overview card must show packingReadiness, NOT repeat baggageAndChecklist
          expect(find.text(l10n.packingReadiness), findsOneWidget,
              reason: 'Overview card should display packingReadiness (${l10n.packingReadiness}) in $lang at ${entry.key}');

          // Verify no RenderFlex overflow
          expect(tester.takeException(), isNull, reason: 'RenderFlex overflow in $lang at ${entry.key}');
        }
      }
    });
  });
}
