import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/features/budget/domain/country_localization.dart';
import 'package:packbuddy/features/travel_map/data/globe_world_data.dart';
import 'package:packbuddy/features/travel_map/data/travel_map_service.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/country_flag.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/globe_3d_viewer.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/travel_map_story_card.dart';

void main() {
  group('Travel Map Upgrades & Features Test Suite', () {
    test('Kosovo (XK) is properly registered in WorldCountriesData', () {
      final kosovo = WorldCountriesData.allCountries.where((c) => c.code == 'XK').firstOrNull;
      expect(kosovo, isNotNull);
      expect(kosovo!.nameTr, 'Kosova');
      expect(kosovo.nameEn, 'Kosovo');
      expect(kosovo.capital, 'Priştine');
      expect(kosovo.flag, '🇽🇰');
      expect(kosovo.continent, 'Europe');
      expect(kosovo.latitude, greaterThan(40.0));
    });

    test('Northern Cyprus (NC) and South Cyprus (CY) are both present as distinct entities', () {
      final nc = WorldCountriesData.allCountries.where((c) => c.code == 'NC').firstOrNull;
      expect(nc, isNotNull);
      expect(nc!.nameTr, 'Kuzey Kıbrıs');
      expect(nc.capital, 'Lefkoşa');
      expect(nc.flag, '🇹🇷');

      final cy = WorldCountriesData.allCountries.where((c) => c.code == 'CY').firstOrNull;
      expect(cy, isNotNull);
      expect(cy!.nameTr, 'Güney Kıbrıs');
      expect(cy.capital, 'Lefkoşa');
      expect(cy.flag, '🇨🇾');
    });

    test('Prominent territories & microstates are available', () {
      final codes = WorldCountriesData.allCountries.map((c) => c.code).toSet();
      expect(codes.contains('VA'), isTrue); // Vatican
      expect(codes.contains('MC'), isTrue); // Monaco
      expect(codes.contains('SM'), isTrue); // San Marino
      expect(codes.contains('LI'), isTrue); // Liechtenstein
      expect(codes.contains('AD'), isTrue); // Andorra
      expect(codes.contains('LU'), isTrue); // Luxembourg
      expect(codes.contains('PS'), isTrue); // Palestine
      expect(codes.contains('GL'), isTrue); // Greenland
      expect(codes.contains('PR'), isTrue); // Puerto Rico
      expect(codes.contains('HK'), isTrue); // Hong Kong
    });

    test('CountryStatus.lived is included in totalVisited without decreasing visited count', () {
      final tr = WorldCountriesData.allCountries.firstWhere((c) => c.code == 'TR').copyWith(
            status: CountryStatus.lived,
          );
      final fr = WorldCountriesData.allCountries.firstWhere((c) => c.code == 'FR').copyWith(
            status: CountryStatus.visited,
          );
      final de = WorldCountriesData.allCountries.firstWhere((c) => c.code == 'DE').copyWith(
            status: CountryStatus.visited,
          );
      final jp = WorldCountriesData.allCountries.firstWhere((c) => c.code == 'JP').copyWith(
            status: CountryStatus.wishlist,
          );
      final it = WorldCountriesData.allCountries.firstWhere((c) => c.code == 'IT');

      final state = TravelMapState(countries: [tr, fr, de, jp, it]);

      // Lived country (TR) must be included in totalVisited!
      expect(state.totalLived, 1);
      expect(state.totalWishlist, 1);
      expect(state.totalVisited, 3); // 2 visited + 1 lived = 3 countries traveled!
      expect(state.visitedCount, 3);

      // Percentage calculation
      expect(state.worldPercentage, closeTo((3 / 5) * 100, 0.01));

      // Filter: 'visited' must return visited + lived countries
      final filteredVisited = TravelMapState(countries: [tr, fr, de, jp, it], filter: 'visited').filteredCountries;
      expect(filteredVisited.map((c) => c.code).toSet(), containsAll(['TR', 'FR', 'DE']));
    });

    test('CountryLocalization handles XK, NC and CY in Turkish and English', () {
      expect(CountryLocalization.getCountryName('XK', 'tr'), 'Kosova');
      expect(CountryLocalization.getCountryName('XK', 'en'), 'Kosovo');
      expect(CountryLocalization.getCountryName('NC', 'tr'), 'Kuzey Kıbrıs Türk Cumhuriyeti');
      expect(CountryLocalization.getCountryName('NC', 'en'), 'Northern Cyprus');
      expect(CountryLocalization.getCountryName('CY', 'tr'), 'Güney Kıbrıs');
      expect(CountryLocalization.getCountryName('CY', 'en'), 'Cyprus');
    });

    test('TravelCountry.parseStatus handles legacy string formats, case-insensitivity and Turkish terms', () {
      expect(TravelCountry.parseStatus('CountryStatus.visited'), CountryStatus.visited);
      expect(TravelCountry.parseStatus('visited'), CountryStatus.visited);
      expect(TravelCountry.parseStatus('VISITED'), CountryStatus.visited);
      expect(TravelCountry.parseStatus('gezilen'), CountryStatus.visited);

      expect(TravelCountry.parseStatus('CountryStatus.lived'), CountryStatus.lived);
      expect(TravelCountry.parseStatus('lived'), CountryStatus.lived);
      expect(TravelCountry.parseStatus('LIVED'), CountryStatus.lived);
      expect(TravelCountry.parseStatus('yasadigim'), CountryStatus.lived);

      expect(TravelCountry.parseStatus('CountryStatus.wishlist'), CountryStatus.wishlist);
      expect(TravelCountry.parseStatus('wishlist'), CountryStatus.wishlist);
      expect(TravelCountry.parseStatus('hedef'), CountryStatus.wishlist);

      expect(TravelCountry.parseStatus('none'), CountryStatus.none);
      expect(TravelCountry.parseStatus(null), CountryStatus.none);
    });

    test('GlobeWorldData loads world polygons with valid coordinates and key countries', () {
      final polygons = GlobeWorldData.getPolygons();
      expect(polygons.isNotEmpty, isTrue);
      expect(polygons.length, greaterThan(400));

      final codes = polygons.map((p) => p.code).toSet();
      expect(codes.contains('TR'), isTrue);
      expect(codes.contains('XK'), isTrue);
      expect(codes.contains('ME'), isTrue);
      expect(codes.contains('CY'), isTrue);
      expect(codes.contains('US'), isTrue);
      expect(codes.contains('FR'), isTrue);
      expect(codes.contains('DE'), isTrue);
      expect(codes.contains('JP'), isTrue);
      expect(codes.contains('BR'), isTrue);
    });

    testWidgets('Globe3DViewer renders clean static globe and reset button operates smoothly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Globe3DViewer(
              countries: WorldCountriesData.allCountries,
              onCountryTap: (_) {},
              isDark: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // CustomPaint renders the 3D globe with no auto-spin ticker
      expect(find.byType(CustomPaint), findsWidgets);
      // Reset button exists
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);
      // Tap reset button
      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pump();
    });

    test('StoryCardTheme includes exactly 6 themes: 3 Dark and 3 Light', () {
      expect(StoryCardTheme.values.length, 6);

      final darkThemes = StoryCardTheme.values.where((t) {
        final palette = StoryCardPalette.forTheme(t);
        return !palette.isLight;
      }).toList();

      final lightThemes = StoryCardTheme.values.where((t) {
        final palette = StoryCardPalette.forTheme(t);
        return palette.isLight;
      }).toList();

      expect(darkThemes.length, 3);
      expect(lightThemes.length, 3);

      expect(darkThemes, containsAll([StoryCardTheme.midnight, StoryCardTheme.sunset, StoryCardTheme.emerald]));
      expect(lightThemes, containsAll([StoryCardTheme.minimalLight, StoryCardTheme.sandLight, StoryCardTheme.oceanLight]));
    });

    testWidgets('CountryFlag widget renders authentic NorthernCyprusFlag for NC code and emoji text for others', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CountryFlag(code: 'NC', fallbackEmoji: '🇹🇷', size: 24),
                CountryFlag(code: 'TR', fallbackEmoji: '🇹🇷', size: 24),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Northern Cyprus flag is rendered using NorthernCyprusFlag (CustomPaint)
      expect(find.byType(NorthernCyprusFlag), findsOneWidget);
      // Turkey is rendered with native Text
      expect(find.text('🇹🇷'), findsOneWidget);
    });

    test('TravelMapService restores marked countries after app reinstall simulation', () async {
      SharedPreferences.setMockInitialValues({});

      final service = TravelMapService.instance;

      // 1. User sets countries before reinstall
      await service.setStatus(
        code: 'TR',
        status: CountryStatus.lived,
        notes: 'Memleket',
        uid: 'user_reinstall_123',
      );
      await service.setStatus(
        code: 'ME',
        status: CountryStatus.visited,
        uid: 'user_reinstall_123',
      );
      await service.setStatus(
        code: 'JP',
        status: CountryStatus.wishlist,
        uid: 'user_reinstall_123',
      );

      final countriesBefore = await service.getCountries(uid: 'user_reinstall_123');
      expect(countriesBefore.firstWhere((c) => c.code == 'TR').isLived, isTrue);
      expect(countriesBefore.firstWhere((c) => c.code == 'ME').isVisited, isTrue);
      expect(countriesBefore.firstWhere((c) => c.code == 'JP').isWishlist, isTrue);

      final cloudPayload = await service.getRawSavedMap(uid: 'user_reinstall_123');
      expect(cloudPayload.containsKey('TR'), isTrue);
      expect(cloudPayload.containsKey('ME'), isTrue);
      expect(cloudPayload.containsKey('JP'), isTrue);

      // 2. SIMULATE UNINSTALL & REINSTALL: All local SharedPreferences wiped!
      SharedPreferences.setMockInitialValues({});

      // Freshly installed app has empty local cache
      final freshInstalledCountries = await service.getCountries();
      expect(freshInstalledCountries.firstWhere((c) => c.code == 'TR').isLived, isFalse);

      // 3. User logs in with their account -> restoreFromCloud is triggered
      await service.restoreFromCloud(cloudPayload, uid: 'user_reinstall_123');

      // 4. Verify all countries are 100% restored
      final restoredCountries = await service.getCountries(uid: 'user_reinstall_123');
      final trRestored = restoredCountries.firstWhere((c) => c.code == 'TR');
      final meRestored = restoredCountries.firstWhere((c) => c.code == 'ME');
      final jpRestored = restoredCountries.firstWhere((c) => c.code == 'JP');

      expect(trRestored.isLived, isTrue);
      expect(trRestored.notes, 'Memleket');
      expect(meRestored.isVisited, isTrue);
      expect(jpRestored.isWishlist, isTrue);
    });
  });
}

