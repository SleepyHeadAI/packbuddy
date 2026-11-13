import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/connectivity/domain/connectivity_localization.dart';
import 'package:packbuddy/features/connectivity/domain/sync_log_entry.dart';
import 'package:packbuddy/features/connectivity/presentation/controllers/connectivity_controller.dart';
import 'package:packbuddy/features/connectivity/presentation/screens/sync_status_screen.dart';
import 'package:packbuddy/features/help/domain/help_localization.dart';
import 'package:packbuddy/features/help/presentation/screens/help_screen.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_item.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_localization.dart';
import 'package:packbuddy/features/itinerary/presentation/controllers/itinerary_controller.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/itinerary_screen.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/widgets/day_timeline_card.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/profile_header_card.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/travel_stats_card.dart';
import 'package:packbuddy/features/search/domain/search_localization.dart';
import 'package:packbuddy/features/search/domain/search_result.dart';
import 'package:packbuddy/features/search/presentation/controllers/search_controller.dart';
import 'package:packbuddy/features/search/presentation/screens/global_search_screen.dart';
import 'package:packbuddy/features/search/presentation/screens/widgets/search_result_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test matrix
  final screenSizes = <String, Size>{
    'Compact (320x568)': const Size(320, 568),
    'Standard (390x844)': const Size(390, 844),
    'Tablet (768x1024)': const Size(768, 1024),
  };

  final themes = <String, ThemeData>{
    'Light': ThemeData(brightness: Brightness.light, useMaterial3: true),
    'Dark': ThemeData(brightness: Brightness.dark, useMaterial3: true),
  };

  final sampleTrip = Trip(
    id: 'trip_matrix_test',
    title: 'European Grand Tour Across Multiple Cities and Countries',
    destination: 'Berlin, Paris, Rome, Istanbul',
    startDate: DateTime(2026, 6, 1),
    endDate: DateTime(2026, 6, 10),
    countryCode: 'DE',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final sampleProfile = UserProfile(
    uid: 'user_matrix',
    displayName: 'Alexander von Humboldt & Wolfgang Amadeus',
    email: 'alexander.humboldt@packbuddy.travel',
    homeCountryCode: 'DE',
    homeCity: 'Frankfurt am Main',
    bio: 'Traveling across continents to discover cultural heritages and geography.',
    createdAt: DateTime(2025, 1, 1),
    isPro: true,
  );

  final sampleItineraryItem = ItineraryItem(
    id: 'itin_matrix_1',
    userId: 'user_matrix',
    tripId: 'trip_matrix_test',
    dayNumber: 1,
    date: '2026-06-01',
    time: '14:30',
    title: 'Brandenburger Tor and Museum Island Detailed Walking Tour',
    location: 'Pariser Platz, 10117 Berlin, Deutschland',
    description: 'Meeting point at northern gate next to the tourist information center.',
    category: 'sightseeing',
    cost: 25.50,
    currency: 'EUR',
    isCompleted: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final sampleSearchResult = SearchResult(
    id: 'search_matrix_1',
    title: 'International Flights & Train Booking Reservations',
    subtitle: 'Transit • 2 items ready • 2026-06-01',
    type: SearchResultType.packingItem,
    isPacked: true,
  );

  group('Multi-Screen, Multi-Theme, Multi-Locale Comprehensive Audit', () {
    for (final sizeEntry in screenSizes.entries) {
      final sizeName = sizeEntry.key;
      final size = sizeEntry.value;

      for (final themeEntry in themes.entries) {
        final themeName = themeEntry.key;
        final theme = themeEntry.value;

        testWidgets('1. HelpScreen renders cleanly on $sizeName with $themeName theme', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          for (final locale in [const Locale('en'), const Locale('tr'), const Locale('ar')]) {
            await tester.pumpWidget(
              MaterialApp(
                locale: locale,
                theme: theme,
                home: const HelpScreen(),
              ),
            );
            await tester.pumpAndSettle();
            expect(find.byType(HelpScreen), findsOneWidget);
            expect(find.byType(TextField), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
        });

        testWidgets('2. SyncStatusScreen and ConnectivityBanner render on $sizeName ($themeName)', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                connectivityControllerProvider.overrideWith((ref) {
                  final controller = ConnectivityController(ref);
                  controller.state = ConnectivityControllerState(
                    syncStatus: SyncStatus.noInternet,
                    pendingChangesCount: 14,
                    pendingBreakdown: const {
                      'trips': 2,
                      'checklist': 8,
                      'expenses': 3,
                      'documents': 1,
                    },
                    syncHistory: [
                      SyncLogEntry(
                        id: 'log_1',
                        timestamp: DateTime.now(),
                        status: 'noInternet',
                        errorMessage: 'Network timeout',
                      ),
                    ],
                  );
                  return controller;
                }),
                syncEngineProvider.overrideWith((ref) => SyncEngineMock(const SyncState(status: SyncStatus.noInternet))),
              ],
              child: MaterialApp(
                theme: theme,
                home: const SyncStatusScreen(),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.byType(SyncStatusScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('3. ProfileScreen renders without overflow on $sizeName ($themeName)', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authUserProvider.overrideWith((ref) => null),
                profileControllerProvider.overrideWith((ref) {
                  final controller = ProfileController(ref);
                  controller.state = ProfileState(
                    profile: sampleProfile,
                    totalTrips: 18,
                    totalCountriesVisited: 32,
                    totalPackingItems: 142,
                    totalDocuments: 15,
                  );
                  return controller;
                }),
              ],
              child: MaterialApp(
                theme: theme,
                home: const ProfileScreen(),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.byType(ProfileScreen), findsOneWidget);
          expect(find.byType(ProfileHeaderCard), findsOneWidget);
          expect(find.byType(TravelStatsCard, skipOffstage: false), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('4. GlobalSearchScreen renders without overflow on $sizeName ($themeName)', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                globalSearchControllerProvider.overrideWith((ref) {
                  final controller = GlobalSearchController(ref);
                  controller.state = SearchState(
                    query: 'Tour',
                    allResults: [sampleSearchResult],
                    filteredResults: [sampleSearchResult],
                    recentSearches: const ['Berlin', 'Museum Ticket', 'Luggage Check'],
                  );
                  return controller;
                }),
              ],
              child: MaterialApp(
                theme: theme,
                home: const GlobalSearchScreen(),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.byType(GlobalSearchScreen), findsOneWidget);
          expect(find.byType(SearchResultTile), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('5. ItineraryScreen renders without overflow on $sizeName ($themeName)', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                tripControllerProvider.overrideWith((ref) {
                  final c = TripController(ref);
                  c.state = TripState(trips: [sampleTrip]);
                  return c;
                }),
                itineraryControllerFamily(sampleTrip.id).overrideWith((ref) {
                  final c = ItineraryController(ref, sampleTrip.id);
                  c.state = ItineraryState(
                    tripId: sampleTrip.id,
                    selectedDay: 1,
                    totalDays: 10,
                    items: [sampleItineraryItem],
                  );
                  return c;
                }),
              ],
              child: MaterialApp(
                theme: theme,
                home: ItineraryScreen(trip: sampleTrip),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.byType(ItineraryScreen), findsOneWidget);
          expect(find.byType(DayTimelineCard), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }

    test('6. All 20 Locales provide non-empty localized strings across all 5 features', () {
      final allLocales = [
        'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja',
        'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
      ];

      for (final l in allLocales) {
        // Feature 1: Help & FAQ
        expect(HelpLocalization.getTitle(l), isNotEmpty);
        expect(HelpLocalization.getSubtitle(l), isNotEmpty);
        expect(HelpLocalization.getSearchHint(l), isNotEmpty);
        expect(HelpLocalization.getContactUs(l), isNotEmpty);
        expect(HelpLocalization.getContactUsSubtitle(l), isNotEmpty);
        expect(HelpLocalization.getReplayWalkthrough(l), isNotEmpty);
        expect(HelpLocalization.getNoResultsFound(l), isNotEmpty);
        expect(HelpLocalization.getCategoryName('packing', l), isNotEmpty);

        // Feature 2: Connectivity & Sync Status
        expect(ConnectivityLocalization.getOfflineBanner(l), isNotEmpty);
        expect(ConnectivityLocalization.getSyncingBanner(l), isNotEmpty);
        expect(ConnectivityLocalization.getSyncFailedBanner(l), isNotEmpty);
        expect(ConnectivityLocalization.getSyncStatusTitle(l), isNotEmpty);
        expect(ConnectivityLocalization.getSyncNow(l), isNotEmpty);
        expect(ConnectivityLocalization.getRetry(l), isNotEmpty);
        expect(ConnectivityLocalization.getPendingChanges(l), isNotEmpty);
        expect(ConnectivityLocalization.getSyncHistory(l), isNotEmpty);

        // Feature 3: Profile
        expect(ProfileLocalization.getTitle(l), isNotEmpty);
        expect(ProfileLocalization.getEditProfile(l), isNotEmpty);
        expect(ProfileLocalization.getDisplayName(l), isNotEmpty);
        expect(ProfileLocalization.getHomeCountry(l), isNotEmpty);
        expect(ProfileLocalization.getBio(l), isNotEmpty);
        expect(ProfileLocalization.getTravelStats(l), isNotEmpty);
        expect(ProfileLocalization.getTotalTrips(l), isNotEmpty);
        expect(ProfileLocalization.getCountriesVisited(l), isNotEmpty);
        expect(ProfileLocalization.getPackingItems(l), isNotEmpty);
        expect(ProfileLocalization.getVaultDocuments(l), isNotEmpty);
        expect(ProfileLocalization.getMemberSince(l), isNotEmpty);
        expect(ProfileLocalization.getAccountSecurity(l), isNotEmpty);
        expect(ProfileLocalization.getSave(l), isNotEmpty);
        expect(ProfileLocalization.getProfileUpdated(l), isNotEmpty);

        // Feature 4: Global Search
        expect(SearchLocalization.getSearch(l), isNotEmpty);
        expect(SearchLocalization.getSearchHint(l), isNotEmpty);
        expect(SearchLocalization.getFilterAll(l), isNotEmpty);
        expect(SearchLocalization.getFilterTrips(l), isNotEmpty);
        expect(SearchLocalization.getFilterPacking(l), isNotEmpty);
        expect(SearchLocalization.getFilterDocuments(l), isNotEmpty);
        expect(SearchLocalization.getFilterExpenses(l), isNotEmpty);
        expect(SearchLocalization.getRecentSearches(l), isNotEmpty);
        expect(SearchLocalization.getClear(l), isNotEmpty);
        expect(SearchLocalization.getNoResults(l), isNotEmpty);
        expect(SearchLocalization.getNoResultsHint(l), isNotEmpty);
        expect(SearchLocalization.getStartTyping(l), isNotEmpty);

        // Feature 5: Itinerary
        expect(ItineraryLocalization.getItineraryTitle(l), isNotEmpty);
        expect(ItineraryLocalization.getDay(l, 1), isNotEmpty);
        expect(ItineraryLocalization.getAddActivity(l), isNotEmpty);
        expect(ItineraryLocalization.getEditActivity(l), isNotEmpty);
        expect(ItineraryLocalization.getActivityTitle(l), isNotEmpty);
        expect(ItineraryLocalization.getTime(l), isNotEmpty);
        expect(ItineraryLocalization.getLocation(l), isNotEmpty);
        expect(ItineraryLocalization.getCategory(l), isNotEmpty);
        expect(ItineraryLocalization.getNotes(l), isNotEmpty);
        expect(ItineraryLocalization.getSave(l), isNotEmpty);
        expect(ItineraryLocalization.getDelete(l), isNotEmpty);
        expect(ItineraryLocalization.getNoActivities(l), isNotEmpty);
        expect(ItineraryLocalization.getNoActivitiesHint(l), isNotEmpty);
        expect(ItineraryLocalization.getCategoryLabel('food', l), isNotEmpty);
        expect(ItineraryLocalization.getCategoryLabel('sightseeing', l), isNotEmpty);
      }
    });

    testWidgets('7. HelpScreen RTL renders cleanly in Arabic', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: HelpScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HelpScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('8. SyncStatusScreen RTL renders cleanly in Arabic', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityControllerProvider.overrideWith((ref) {
              final controller = ConnectivityController(ref);
              controller.state = ConnectivityControllerState(
                syncStatus: SyncStatus.noInternet,
                pendingChangesCount: 5,
                pendingBreakdown: const {'trips': 2, 'expenses': 3},
                syncHistory: [
                  SyncLogEntry(
                    id: 'rtl_log',
                    timestamp: DateTime.now(),
                    status: 'success',
                    itemsSynced: 5,
                  ),
                ],
              );
              return controller;
            }),
            syncEngineProvider.overrideWith((ref) => SyncEngineMock(const SyncState(status: SyncStatus.noInternet))),
          ],
          child: const MaterialApp(
            locale: Locale('ar'),
            home: SyncStatusScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SyncStatusScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('9. ProfileScreen RTL renders cleanly in Arabic', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWith((ref) => null),
            profileControllerProvider.overrideWith((ref) {
              final controller = ProfileController(ref);
              controller.state = ProfileState(
                profile: sampleProfile,
                totalTrips: 10,
                totalCountriesVisited: 5,
                totalPackingItems: 25,
                totalDocuments: 3,
              );
              return controller;
            }),
          ],
          child: const MaterialApp(
            locale: Locale('ar'),
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('10. GlobalSearchScreen RTL renders cleanly in Arabic', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalSearchControllerProvider.overrideWith((ref) {
              final controller = GlobalSearchController(ref);
              controller.state = SearchState(
                query: 'Tour',
                allResults: [sampleSearchResult],
                filteredResults: [sampleSearchResult],
                recentSearches: const ['Berlin', 'Museum Ticket'],
              );
              return controller;
            }),
          ],
          child: const MaterialApp(
            locale: Locale('ar'),
            home: GlobalSearchScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GlobalSearchScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('11. ItineraryScreen RTL renders cleanly in Arabic', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripControllerProvider.overrideWith((ref) {
              final c = TripController(ref);
              c.state = TripState(trips: [sampleTrip]);
              return c;
            }),
            itineraryControllerFamily(sampleTrip.id).overrideWith((ref) {
              final c = ItineraryController(ref, sampleTrip.id);
              c.state = ItineraryState(
                tripId: sampleTrip.id,
                selectedDay: 1,
                totalDays: 10,
                items: [sampleItineraryItem],
              );
              return c;
            }),
          ],
          child: MaterialApp(
            locale: const Locale('ar'),
            home: ItineraryScreen(trip: sampleTrip),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ItineraryScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

class SyncEngineMock extends StateNotifier<SyncState> implements SyncEngine {
  SyncEngineMock(super.state);

  @override
  bool get isSyncing => state.status == SyncStatus.syncing;

  @override
  Future<void> performSync() async {}

  @override
  Future<bool> hasInternetConnection() async => true;

  @override
  void listenToUserDoc(String uid) {}

  @override
  void cancelUserDocSubscription() {}

  @override
  void listenToSharedTrip(String tripId) {}

  @override
  void cancelSharedTripListener(String tripId) {}

  @override
  void cancelAllSharedTripListeners() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
