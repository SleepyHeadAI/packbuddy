import 'package:countries_world_map/countries_world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/friend_profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/edit_profile_sheet.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/profile_header_card.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/world_map_profile_card.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const all20Languages = [
    'ar', 'de', 'el', 'en', 'es', 'fr', 'hi', 'id', 'it', 'ja',
    'ko', 'nl', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'vi', 'zh',
  ];

  const screenSizes = [
    Size(320, 568),   // iPhone SE (1st gen) - Compact
    Size(390, 844),   // iPhone 14 - Standard
    Size(412, 915),   // Pixel 7 - Large Android
    Size(800, 1280),  // 10-inch Tablet
  ];

  Widget buildLocalizedApp({
    required Widget home,
    Locale locale = const Locale('tr'),
    ThemeData? theme,
    List<dynamic> overrides = const [],
  }) {
    final app = MaterialApp(
      locale: locale,
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

    if (overrides.isNotEmpty) {
      return ProviderScope(
        overrides: overrides.cast(),
        child: app,
      );
    }
    return app;
  }

  group('WorldMapProfileCard Metric Calculation & Parsing Tests', () {
    test('parseCountriesFromRaw accurately handles Map and List input formats', () {
      final rawMap = {
        'TR': {'code': 'TR', 'status': 'lived'},
        'DE': {'status': 'visited'},
        'JP': {'status': 'wishlist'},
      };
      final parsedFromMap = WorldMapProfileCard.parseCountriesFromRaw(rawMap);
      expect(parsedFromMap.length, equals(WorldCountriesData.allCountries.length));

      final tr = parsedFromMap.firstWhere((c) => c.code == 'TR');
      final de = parsedFromMap.firstWhere((c) => c.code == 'DE');
      final jp = parsedFromMap.firstWhere((c) => c.code == 'JP');
      final it = parsedFromMap.firstWhere((c) => c.code == 'IT');

      expect(tr.status, equals(CountryStatus.lived));
      expect(de.status, equals(CountryStatus.visited));
      expect(jp.status, equals(CountryStatus.wishlist));
      expect(it.status, equals(CountryStatus.none));

      // List format with strings
      final rawList = ['FR', 'IT', 'ES'];
      final parsedFromList = WorldMapProfileCard.parseCountriesFromRaw(rawList);
      expect(parsedFromList.firstWhere((c) => c.code == 'FR').status, equals(CountryStatus.visited));
      expect(parsedFromList.firstWhere((c) => c.code == 'IT').status, equals(CountryStatus.visited));
      expect(parsedFromList.firstWhere((c) => c.code == 'ES').status, equals(CountryStatus.visited));
      expect(parsedFromList.firstWhere((c) => c.code == 'TR').status, equals(CountryStatus.none));
    });

    test('FriendUserSummary serializes and deserializes travelMapCountries and bio correctly', () {
      final summary = FriendUserSummary(
        uid: 'user_123',
        displayName: 'Caner Gezgin',
        bio: '300 karakterlik seyahat tutkunu biyografisi burada yer alır!',
        travelMapCountries: {
          'TR': {'status': 'lived'},
          'IT': {'status': 'visited'},
          'IS': {'status': 'wishlist'},
        },
      );

      final map = summary.toMap();
      expect(map['travelMapCountries'], isNotNull);
      expect(map['travelMapCountries']['TR']['status'], equals('lived'));
      expect(map['bio'], equals('300 karakterlik seyahat tutkunu biyografisi burada yer alır!'));

      final restored = FriendUserSummary.fromMap(map);
      expect(restored.travelMapCountries, isNotNull);
      expect(restored.travelMapCountries!['TR']['status'], equals('lived'));
      expect(restored.travelMapCountries!['IT']['status'], equals('visited'));
      expect(restored.travelMapCountries!['IS']['status'], equals('wishlist'));
      expect(restored.bio, equals('300 karakterlik seyahat tutkunu biyografisi burada yer alır!'));
    });
  });

  group('WorldMapProfileCard UI Widget Tests', () {
    testWidgets('Renders own profile map card in Turkish with correct coverage and exploration metrics', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final countries = WorldCountriesData.allCountries.map((c) {
        if (c.code == 'TR' || c.code == 'DE') {
          return c.copyWith(status: CountryStatus.lived);
        } else if (c.code == 'FR' || c.code == 'IT' || c.code == 'ES' || c.code == 'GB') {
          return c.copyWith(status: CountryStatus.visited);
        } else if (['US', 'CA', 'JP', 'AU', 'BR', 'EG'].contains(c.code)) {
          return c.copyWith(status: CountryStatus.wishlist);
        }
        return c;
      }).toList();

      final totalCount = countries.length;
      final exploredPctStr = '%${((6 / totalCount) * 100).toStringAsFixed(1)}';

      bool didTapOpen = false;

      await tester.pumpWidget(
        buildLocalizedApp(
          locale: const Locale('tr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: WorldMapProfileCard(
                countries: countries,
                isOwnProfile: true,
                onOpenMap: () => didTapOpen = true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dünya Seyahat Haritası'), findsOneWidget);
      expect(find.text('Güncel Keşif & Boyama Durumu'), findsOneWidget);
      expect(find.text(exploredPctStr), findsOneWidget);
      expect(find.text('6 / $totalCount Ülke Gezildi'), findsOneWidget);

      // Breakdown chips
      expect(find.text('Yaşanan'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Gezilen'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Hedef'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);

      // SimpleMap vector map widget exists
      expect(find.byType(SimpleMap), findsOneWidget);

      // Tap action button opens map
      await tester.tap(find.text('Haritayı Aç ↗'));
      expect(didTapOpen, isTrue);
    });

    testWidgets('Renders own profile map card in English with correct localization', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final countries = WorldCountriesData.allCountries.map((c) {
        if (c.code == 'TR') return c.copyWith(status: CountryStatus.lived);
        if (c.code == 'FR') return c.copyWith(status: CountryStatus.visited);
        return c;
      }).toList();

      final totalCount = countries.length;

      await tester.pumpWidget(
        buildLocalizedApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: WorldMapProfileCard(
                countries: countries,
                isOwnProfile: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('World Travel Map'), findsOneWidget);
      expect(find.text('Live Exploration & Coverage'), findsOneWidget);
      expect(find.text('Open Map ↗'), findsOneWidget);
      expect(find.text('2 / $totalCount Visited'), findsOneWidget);
      expect(find.text('Lived'), findsOneWidget);
      expect(find.text('Visited'), findsOneWidget);
      expect(find.text('Wishlist'), findsOneWidget);
    });

    testWidgets('Renders friend profile map card with inspect dialog and mutual countries', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final friendCountries = WorldCountriesData.allCountries.map((c) {
        if (c.code == 'TR') return c.copyWith(status: CountryStatus.lived);
        if (['FR', 'IT', 'GR'].contains(c.code)) return c.copyWith(status: CountryStatus.visited);
        if (['NO', 'SE'].contains(c.code)) return c.copyWith(status: CountryStatus.wishlist);
        return c;
      }).toList();

      final totalCount = friendCountries.length;
      final exploredPctStr = '%${((4 / totalCount) * 100).toStringAsFixed(1)}';

      await tester.pumpWidget(
        buildLocalizedApp(
          locale: const Locale('tr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: WorldMapProfileCard(
                countries: friendCountries,
                isOwnProfile: false,
                friendName: 'Deniz',
                mutualVisitedCodes: const ['TR', 'FR'],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dünya Seyahat Haritası'), findsOneWidget);
      expect(find.text("Deniz'in Haritası"), findsOneWidget);
      expect(find.text('İncele 🔍'), findsOneWidget);

      expect(find.text(exploredPctStr), findsOneWidget);

      // Mutual visited countries banner
      expect(find.textContaining('2 Ortak Gezilen Ülke'), findsOneWidget);
      expect(find.textContaining('TR'), findsOneWidget);

      // Tapping inspect opens zoomable map dialog
      await tester.tap(find.text('İncele 🔍'));
      await tester.pumpAndSettle();

      expect(find.text("Deniz'in Dünya Haritası"), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(SimpleMap), findsWidgets);

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text("Deniz'in Dünya Haritası"), findsNothing);
    });
  });

  group('ProfileScreen & FriendProfileScreen Integration Tests', () {
    testWidgets('ProfileScreen embeds live WorldMapProfileCard with up-to-date stats', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final testCountries = WorldCountriesData.allCountries.map((c) {
        if (c.code == 'TR') return c.copyWith(status: CountryStatus.lived);
        if (c.code == 'NL') return c.copyWith(status: CountryStatus.visited);
        return c;
      }).toList();

      final totalCount = testCountries.length;

      await tester.pumpWidget(
        buildLocalizedApp(
          locale: const Locale('tr'),
          overrides: [
            authUserProvider.overrideWith((ref) => null),
            profileControllerProvider.overrideWith((ref) {
              final c = ProfileController(ref);
              c.state = ProfileState(
                profile: UserProfile(
                  uid: 'test_uid',
                  displayName: 'Enes',
                  createdAt: DateTime.now(),
                ),
                totalTrips: 5,
                totalCountriesVisited: 2,
              );
              return c;
            }),
            travelMapControllerProvider.overrideWith((ref) {
              final c = TravelMapController(null, ref);
              c.state = TravelMapState(countries: testCountries);
              return c;
            }),
          ],
          home: const ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WorldMapProfileCard), findsOneWidget);
      expect(find.text('Dünya Seyahat Haritası'), findsOneWidget);
      expect(find.text('Güncel Keşif & Boyama Durumu'), findsOneWidget);
      expect(find.text('Haritayı Aç ↗'), findsOneWidget);
      expect(find.text('2 / $totalCount Ülke Gezildi'), findsOneWidget);
    });

    testWidgets('FriendProfileScreen embeds WorldMapProfileCard displaying friend map and stats', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final friendSummary = FriendUserSummary(
        uid: 'friend_456',
        displayName: 'Melis',
        username: 'melistravels',
        travelMapCountries: {
          'TR': {'status': 'lived'},
          'FR': {'status': 'visited'},
          'IT': {'status': 'visited'},
          'ES': {'status': 'wishlist'},
        },
      );

      final userCountries = WorldCountriesData.allCountries.map((c) {
        if (c.code == 'TR' || c.code == 'FR') return c.copyWith(status: CountryStatus.visited);
        return c;
      }).toList();

      final totalCount = WorldCountriesData.allCountries.length;

      await tester.pumpWidget(
        buildLocalizedApp(
          locale: const Locale('tr'),
          overrides: [
            travelMapControllerProvider.overrideWith((ref) {
              final c = TravelMapController(null, ref);
              c.state = TravelMapState(countries: userCountries);
              return c;
            }),
          ],
          home: FriendProfileScreen(
            friendUid: 'friend_456',
            fallbackSummary: friendSummary,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Melis'), findsWidgets);
      expect(find.byType(WorldMapProfileCard), findsOneWidget);
      expect(find.text("Melis'in Haritası"), findsOneWidget);
      expect(find.text('İncele 🔍'), findsOneWidget);

      // Friend visited: TR (lived), FR (visited), IT (visited) = 3 countries
      expect(find.text('3 / $totalCount Ülke Gezildi'), findsOneWidget);

      // Mutual visited: TR and FR
      expect(find.textContaining('2 Ortak Gezilen Ülke'), findsOneWidget);
    });
  });

  group('All 20 Languages Exhaustive Localization & Rendering Tests', () {
    test('ProfileLocalization getBio and getBioHint return non-empty strings across all 20 languages', () {
      for (final lang in all20Languages) {
        final bio = ProfileLocalization.getBio(lang);
        final hint = ProfileLocalization.getBioHint(lang);
        expect(bio.isNotEmpty, isTrue, reason: 'getBio failed for $lang');
        expect(hint.isNotEmpty, isTrue, reason: 'getBioHint failed for $lang');
      }
    });

    for (final lang in all20Languages) {
      testWidgets('WorldMapProfileCard renders without errors in language: $lang', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final sampleCountries = [
          const TravelCountry(
            code: 'TR',
            nameTr: 'Türkiye',
            nameEn: 'Turkey',
            flag: '🇹🇷',
            continent: 'Europe',
            capital: 'Ankara',
            latitude: 39.9,
            longitude: 32.8,
            status: CountryStatus.lived,
          ),
          const TravelCountry(
            code: 'FR',
            nameTr: 'Fransa',
            nameEn: 'France',
            flag: '🇫🇷',
            continent: 'Europe',
            capital: 'Paris',
            latitude: 48.8,
            longitude: 2.3,
            status: CountryStatus.visited,
          ),
        ];

        await tester.pumpWidget(
          buildLocalizedApp(
            locale: Locale(lang),
            home: Scaffold(
              body: SingleChildScrollView(
                child: WorldMapProfileCard(
                  countries: sampleCountries,
                  isOwnProfile: true,
                  friendName: 'Test Traveler',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(WorldMapProfileCard), findsOneWidget);
      });
    }
  });

  group('Multi-Screen Size Dimension & 300-Char Bio Stress Tests', () {
    // Exact 300-character realistic traveler bio
    final bio300Chars = 'Gezgin ruhumla dünyayı adım adım keşfediyorum! Sırt çantamı alıp yeni kültürleri, lezzetleri ve insanları tanımak için yola çıkıyorum. Bugüne kadar harika anılar biriktirdim ve sırada keşfedilecek onlarca yeni rota var. Hayat bir yolculuk ve ben bu seyahatin tadını sonuna kadar çıkarıyorum!'.padRight(300, '.');
    assert(bio300Chars.length == 300);

    for (final size in screenSizes) {
      testWidgets('WorldMapProfileCard renders cleanly on ${size.width}x${size.height} without any RenderFlex overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final countries = WorldCountriesData.allCountries.map((c) {
          if (c.code == 'TR') return c.copyWith(status: CountryStatus.lived);
          if (c.code == 'IT') return c.copyWith(status: CountryStatus.visited);
          return c;
        }).toList();

        await tester.pumpWidget(
          buildLocalizedApp(
            locale: const Locale('tr'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: WorldMapProfileCard(
                  countries: countries,
                  isOwnProfile: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(WorldMapProfileCard), findsOneWidget);
      });

      testWidgets('ProfileHeaderCard renders 300-character bio on ${size.width}x${size.height} without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final testProfile = UserProfile(
          uid: 'stress_bio_user',
          displayName: 'Ahmet Yılmaz',
          username: 'ahmet_travels',
          bio: bio300Chars,
          travelStatus: '🏖️ Tatil modunda',
          homeCountryCode: 'TR',
          homeCity: 'Antalya',
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          buildLocalizedApp(
            locale: const Locale('tr'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProfileHeaderCard(
                  profile: testProfile,
                  languageCode: 'tr',
                  onEditTap: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('Gezgin ruhumla dünyayı'), findsOneWidget);
      });

      testWidgets('FriendProfileScreen renders 300-character bio and map card on ${size.width}x${size.height} without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final friendSummary = FriendUserSummary(
          uid: 'friend_bio_test',
          displayName: 'Zeynep Kaya',
          username: 'zeynep_explorer',
          bio: bio300Chars,
          homeCountryCode: 'TR',
          homeCity: 'İzmir',
          travelMapCountries: {
            'TR': {'status': 'lived'},
            'GR': {'status': 'visited'},
          },
        );

        await tester.pumpWidget(
          buildLocalizedApp(
            locale: const Locale('tr'),
            overrides: [
              travelMapControllerProvider.overrideWith((ref) {
                final c = TravelMapController(null, ref);
                c.state = const TravelMapState();
                return c;
              }),
            ],
            home: FriendProfileScreen(
              friendUid: 'friend_bio_test',
              fallbackSummary: friendSummary,
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.textContaining('Gezgin ruhumla dünyayı'), findsOneWidget);
        expect(find.byType(WorldMapProfileCard), findsOneWidget);
      });
    }

    testWidgets('EditProfileSheet renders bio field with 300 characters maxLength and counter', (tester) async {
      final testProfile = UserProfile(
        uid: 'test_edit_uid',
        displayName: 'Selin',
        bio: bio300Chars,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildLocalizedApp(
          locale: const Locale('tr'),
          overrides: [
            profileControllerProvider.overrideWith((ref) => ProfileController(ref)),
          ],
          home: Scaffold(
            body: EditProfileSheet(
              profile: testProfile,
              languageCode: 'tr',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Verify bio field rendered
      expect(find.text('Hakkımda / Biyografi'), findsOneWidget);
      expect(find.text(bio300Chars), findsOneWidget);
    });
  });

  group('RTL (Arabic) Internationalization & Dark/Light Mode Tests', () {
    testWidgets('WorldMapProfileCard and FriendProfileScreen render in RTL Arabic without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final arabicFriend = FriendUserSummary(
        uid: 'ar_friend',
        displayName: 'طارق المسافر',
        username: 'tariq_traveler',
        bio: 'مغامر يستكشف العالم ويزور أماكن جديدة دائماً',
        homeCountryCode: 'EG',
        travelMapCountries: {'EG': 'lived', 'SA': 'visited'},
      );

      await tester.pumpWidget(
        buildLocalizedApp(
          locale: const Locale('ar'),
          overrides: [
            travelMapControllerProvider.overrideWith((ref) {
              final c = TravelMapController(null, ref);
              c.state = const TravelMapState();
              return c;
            }),
          ],
          home: FriendProfileScreen(
            friendUid: 'ar_friend',
            fallbackSummary: arabicFriend,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(WorldMapProfileCard), findsOneWidget);
      expect(find.text('طارق المسافر'), findsWidgets);
    });

    testWidgets('WorldMapProfileCard renders in Dark Mode with dark theme ocean and borders', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildLocalizedApp(
          locale: const Locale('en'),
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: WorldMapProfileCard(
                countries: [],
                isOwnProfile: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(WorldMapProfileCard), findsOneWidget);
    });
  });
}
