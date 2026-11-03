import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/constants/app_constants.dart';
import 'package:packbuddy/core/services/live_location_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/travel_map/data/travel_map_service.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('World Travel Map Reinstall & UI Tests', () {
    test('AppConstants includes tableTravelMap and version 11', () {
      expect(AppConstants.tableTravelMap, equals('travel_map'));
      expect(AppConstants.databaseVersion, equals(11));
    });

    test('TravelMapService correctly stores and retrieves countries in local storage', () async {
      final service = TravelMapService.instance;
      const testUid = 'user_persistence_test_123';

      await service.setStatus(
        code: 'TR',
        status: CountryStatus.visited,
        uid: testUid,
        notes: 'Istanbul trip',
      );
      await service.setStatus(
        code: 'JP',
        status: CountryStatus.wishlist,
        uid: testUid,
        notes: 'Tokyo exploration',
      );

      final countries = await service.getCountries(uid: testUid);
      final tr = countries.firstWhere((c) => c.code == 'TR');
      final jp = countries.firstWhere((c) => c.code == 'JP');

      expect(tr.isVisited, isTrue);
      expect(jp.isWishlist, isTrue);
    });

    testWidgets('TravelMapScreen does NOT contain the redundant sync_rounded icon button in AppBar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('tr')],
            home: TravelMapScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Ensure sync_rounded icon is removed from AppBar
      expect(find.byIcon(Icons.sync_rounded), findsNothing);
      // Ensure share button is present
      expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);
    });
  });

  group('Live Location & Admin Analytics Tests', () {
    test('LiveLocationService resolves location in test environment gracefully', () async {
      final location = await LiveLocationService.instance.detectLiveLocation();
      expect(location.countryCode.isNotEmpty, isTrue);
      expect(location.countryName.isNotEmpty, isTrue);
    });

    test('AdminUserModel correctly parses live location, app preferences, and computes travel map stats', () {
      final data = {
        'email': 'traveler@packbuddy.com',
        'displayName': 'Traveler Jane',
        'countryCode': 'US',
        'countryName': 'United States',
        'liveCountryCode': 'TR',
        'liveCountryName': 'Turkey',
        'liveCity': 'Istanbul',
        'appThemeMode': 'dark',
        'appLanguage': 'tr',
        'currencyCode': 'TRY',
        'totalSessionSeconds': 1800,
        'sessionCount': 6,
        'lastSessionSeconds': 300,
        'travelMapCountries': {
          'TR': {'status': 'lived', 'visitedDate': 1600000000000},
          'FR': {'status': 'visited', 'visitedDate': 1610000000000},
          'IT': {'status': 'visited', 'visitedDate': 1620000000000},
          'JP': {'status': 'wishlist', 'visitedDate': 1630000000000},
        },
      };

      final user = AdminUserModel.fromMap('user_test_999', data);

      expect(user.liveCountryCode, equals('TR'));
      expect(user.liveCountryName, equals('Turkey'));
      expect(user.liveCity, equals('Istanbul'));
      expect(user.appThemeMode, equals('dark'));
      expect(user.appLanguage, equals('tr'));
      expect(user.visitedWorldMapCount, equals(3)); // TR (lived) + FR (visited) + IT (visited)
      expect(user.wishlistWorldMapCount, equals(1)); // JP (wishlist)
      expect(user.livedWorldMapCount, equals(1)); // TR (lived)
      expect(user.worldExploredPercentage, greaterThan(0.0));
      expect(user.averageSessionMinutes, equals(5.0)); // 1800 / 6 / 60
    });

    test('AdminDetailedAnalytics holds themeShares and languageShares distributions', () {
      const analytics = AdminDetailedAnalytics(
        themeShares: [
          PreferenceShareMetric(
            key: 'dark',
            label: 'Koyu Tema (Dark)',
            icon: '🌙',
            count: 20,
            percentage: 0.625,
          ),
          PreferenceShareMetric(
            key: 'light',
            label: 'Açık Tema (Light)',
            icon: '☀️',
            count: 12,
            percentage: 0.375,
          ),
        ],
        languageShares: [
          PreferenceShareMetric(
            key: 'tr',
            label: 'Türkçe (TR)',
            icon: '🇹🇷',
            count: 24,
            percentage: 0.75,
          ),
          PreferenceShareMetric(
            key: 'en',
            label: 'English (EN)',
            icon: '🇬🇧',
            count: 8,
            percentage: 0.25,
          ),
        ],
      );

      expect(analytics.themeShares.length, equals(2));
      expect(analytics.themeShares.first.key, equals('dark'));
      expect(analytics.themeShares.first.count, equals(20));
      expect(analytics.languageShares.first.key, equals('tr'));
      expect(analytics.languageShares.first.count, equals(24));
    });

    test('AdminState countryBreakdown groups by liveCountryCode when available', () {
      final now = DateTime.now();
      final users = [
        AdminUserModel(
          uid: 'u1',
          email: 'u1@test.com',
          countryCode: 'US',
          countryName: 'United States',
          liveCountryCode: 'TR',
          liveCountryName: 'Turkey',
          lastActiveAt: now.subtract(const Duration(minutes: 5)),
        ),
        AdminUserModel(
          uid: 'u2',
          email: 'u2@test.com',
          countryCode: 'US',
          countryName: 'United States',
          liveCountryCode: 'TR',
          liveCountryName: 'Turkey',
          lastActiveAt: now.subtract(const Duration(minutes: 8)),
        ),
        AdminUserModel(
          uid: 'u3',
          email: 'u3@test.com',
          countryCode: 'DE',
          countryName: 'Germany',
          liveCountryCode: 'DE',
          liveCountryName: 'Germany',
          lastActiveAt: now.subtract(const Duration(minutes: 2)),
        ),
      ];

      final state = AdminState(
        allUsers: users,
        analyticsPeriod: AnalyticsPeriod.live,
      );

      final breakdown = state.countryBreakdown;
      expect(breakdown.isNotEmpty, isTrue);

      final trItem = breakdown.firstWhere((b) => b.countryCode == 'TR');
      expect(trItem.activeUserCount, equals(2));
      expect(trItem.countryName, equals('Turkey'));

      final deItem = breakdown.firstWhere((b) => b.countryCode == 'DE');
      expect(deItem.activeUserCount, equals(1));
    });
  });
}
