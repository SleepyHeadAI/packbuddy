import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/domain/animal_avatar.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/edit_profile_sheet.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/profile_header_card.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/travel_stats_card.dart';
import 'package:packbuddy/features/profile/presentation/widgets/avatar_picker_sheet.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('UserProfile serializes and deserializes correctly', () {
      final now = DateTime(2026, 1, 15, 10, 30);
      final profile = UserProfile(
        uid: 'user_test_123',
        displayName: 'Ayla Yılmaz',
        email: 'ayla@example.com',
        photoUrl: 'avatar:animal_cat',
        homeCountryCode: 'TR',
        homeCity: 'Istanbul',
        bio: 'Avid traveler & digital nomad',
        createdAt: now,
        lastActiveAt: now,
        isPro: true,
      );

      final map = profile.toMap();
      final fromMap = UserProfile.fromMap(map);

      expect(fromMap.uid, equals('user_test_123'));
      expect(fromMap.displayName, equals('Ayla Yılmaz'));
      expect(fromMap.email, equals('ayla@example.com'));
      expect(fromMap.photoUrl, equals('avatar:animal_cat'));
      expect(fromMap.homeCountryCode, equals('TR'));
      expect(fromMap.homeCity, equals('Istanbul'));
      expect(fromMap.bio, equals('Avid traveler & digital nomad'));
      expect(fromMap.isPro, isTrue);

      final jsonStr = profile.toJson();
      final fromJson = UserProfile.fromJson(jsonStr);
      expect(fromJson.uid, equals(profile.uid));
      expect(fromJson.displayName, equals(profile.displayName));
      expect(fromJson.email, equals(profile.email));
      expect(fromJson.photoUrl, equals(profile.photoUrl));
    });

    test('UserProfile copyWith works as expected', () {
      final profile = UserProfile(
        uid: 'user_1',
        displayName: 'Original Name',
        createdAt: DateTime(2025, 1, 1),
        isPro: false,
      );

      final updated = profile.copyWith(
        displayName: 'Updated Name',
        bio: 'New bio',
        photoUrl: 'avatar:animal_panda',
        isPro: true,
      );

      expect(updated.uid, equals('user_1'));
      expect(updated.displayName, equals('Updated Name'));
      expect(updated.bio, equals('New bio'));
      expect(updated.photoUrl, equals('avatar:animal_panda'));
      expect(updated.isPro, isTrue);
    });
  });

  group('20 Animated Animal Avatars Tests', () {
    test('Catalog contains exactly 20 distinct cute animals with complete 20-language support', () {
      expect(AnimalAvatar.all.length, equals(20));

      final langs = [
        'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja',
        'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
      ];

      final ids = <String>{};
      for (final animal in AnimalAvatar.all) {
        expect(ids.add(animal.id), isTrue, reason: 'Duplicate animal id: ${animal.id}');
        expect(animal.emoji.isNotEmpty, isTrue);
        expect(animal.trName.isNotEmpty, isTrue);
        expect(animal.enName.isNotEmpty, isTrue);
        expect(animal.bgGradient.length, greaterThanOrEqualTo(2));

        for (final lang in langs) {
          final localizedName = animal.getName(lang);
          expect(localizedName.isNotEmpty, isTrue,
              reason: 'Missing localization for ${animal.id} in $lang');
        }
      }

      // Verify category distribution
      expect(AnimalAvatar.getByCategory(AnimalCategory.all).length, equals(20));
      expect(AnimalAvatar.getByCategory(AnimalCategory.pets).length, equals(4));
      expect(AnimalAvatar.getByCategory(AnimalCategory.forest).length, equals(7));
      expect(AnimalAvatar.getByCategory(AnimalCategory.wild).length, equals(4));
      expect(AnimalAvatar.getByCategory(AnimalCategory.special).length, equals(5));
    });

    test('AnimalAvatar helper methods work correctly', () {
      final cat = AnimalAvatar.findById('animal_cat');
      expect(cat, isNotNull);
      expect(cat?.trName, equals('Pamuk Kedi'));

      final pandaByUri = AnimalAvatar.findById('avatar:animal_panda');
      expect(pandaByUri, isNotNull);
      expect(pandaByUri?.id, equals('animal_panda'));

      expect(AnimalAvatar.isAnimalAvatar('avatar:animal_fox'), isTrue);
      expect(AnimalAvatar.isAnimalAvatar('animal_dog'), isTrue);
      expect(AnimalAvatar.isAnimalAvatar('https://google.com/avatar.jpg'), isFalse);
      expect(AnimalAvatar.isAnimalAvatar(null), isFalse);

      expect(AnimalAvatar.toUri('animal_koala'), equals('avatar:animal_koala'));
      expect(AnimalAvatar.toUri('avatar:animal_koala'), equals('avatar:animal_koala'));
    });
  });

  group('ProfileLocalization Tests', () {
    test('Returns non-empty strings across all 20 supported languages', () {
      final langs = [
        'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja',
        'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
      ];

      for (final lang in langs) {
        expect(ProfileLocalization.getTitle(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getEditProfile(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getDisplayName(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getHomeCountry(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getBio(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getBioHint(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getTravelStats(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getTotalTrips(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getCountriesVisited(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getPackingItems(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getVaultDocuments(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getMemberSince(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getAccountSecurity(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getSave(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getProfileUpdated(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getChangePhoto(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getChooseFromGallery(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getRemovePhoto(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getCuteAnimalAvatars(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getSelectAvatar(lang).isNotEmpty, isTrue);
        expect(ProfileLocalization.getPhotoUpdated(lang).isNotEmpty, isTrue);
      }
    });
  });

  group('Profile UI Widget Tests', () {
    testWidgets('UserAvatar renders correctly with fallback initial and animal avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                UserAvatar(
                  displayName: 'Kemal Sunal',
                  size: 64,
                  showEditBadge: true,
                ),
                UserAvatar(
                  photoUrl: 'avatar:animal_cat',
                  size: 64,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('K'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
      expect(find.byType(UserAvatar), findsNWidgets(2));
    });

    testWidgets('ProfileHeaderCard displays traveler info, avatar and triggers onEditTap', (tester) async {
      bool editTapped = false;
      bool avatarTapped = false;

      final profile = UserProfile(
        uid: 'uid_test',
        displayName: 'Batu Gezgin',
        email: 'batu@packbuddy.com',
        photoUrl: 'avatar:animal_panda',
        homeCountryCode: 'DE',
        homeCity: 'Berlin',
        bio: 'Exploring every corner of the world 🌍',
        createdAt: DateTime(2025, 3, 10),
        isPro: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeaderCard(
              profile: profile,
              languageCode: 'en',
              onEditTap: () {
                editTapped = true;
              },
              onAvatarTap: () {
                avatarTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Batu Gezgin'), findsOneWidget);
      expect(find.text('batu@packbuddy.com'), findsOneWidget);
      expect(find.textContaining('Exploring every corner of the world 🌍'), findsOneWidget);
      expect(find.textContaining('Berlin'), findsOneWidget);

      final editBtn = find.byIcon(Icons.edit_rounded);
      expect(editBtn, findsOneWidget);
      await tester.tap(editBtn);
      await tester.pump();
      expect(editTapped, isTrue);

      final avatarFinder = find.byType(UserAvatar);
      expect(avatarFinder, findsOneWidget);
      await tester.tap(avatarFinder);
      await tester.pump();
      expect(avatarTapped, isTrue);
    });

    testWidgets('TravelStatsCard displays all 4 traveler statistics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TravelStatsCard(
              totalTrips: 7,
              totalCountries: 14,
              totalItems: 85,
              totalDocuments: 6,
              languageCode: 'en',
            ),
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('Travel Statistics'), findsOneWidget);
      expect(find.text('Trips'), findsOneWidget);
      expect(find.text('Countries Visited'), findsOneWidget);
    });

    testWidgets('AvatarPickerSheet renders gallery action and 20 animal avatars', (tester) async {
      final profile = UserProfile(
        uid: 'user_sheet_test',
        displayName: 'Ezgi Doğa',
        email: 'ezgi@packbuddy.com',
        photoUrl: 'avatar:animal_cat',
        createdAt: DateTime(2025, 4, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AvatarPickerSheet(
                profile: profile,
                languageCode: 'tr',
              ),
            ),
          ),
        ),
      );

      // Gallery button
      expect(find.text('Galeriden Fotoğraf Seç'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);

      // Remove photo button is present because photoUrl is set
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // Title & 20 animals count badge
      expect(find.text('20 ✨'), findsOneWidget);
      expect(find.text('Tatlı Hayvan Avatarları (20 Karakter)'), findsOneWidget);

      // Check some animal names
      expect(find.text('Pamuk Kedi'), findsOneWidget);
      expect(find.text('Neşeli Köpek'), findsOneWidget);
      expect(find.text('Bambu Panda'), findsOneWidget);
    });

    testWidgets('EditProfileSheet renders UserAvatar and change photo button', (tester) async {
      final profile = UserProfile(
        uid: 'user_edit_test',
        displayName: 'Caner Kurt',
        email: 'caner@packbuddy.com',
        createdAt: DateTime(2025, 5, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EditProfileSheet(
                profile: profile,
                languageCode: 'tr',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Profili Düzenle'), findsOneWidget);
      expect(find.text('Fotoğrafı Değiştir'), findsOneWidget);
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('ProfileScreen renders profile state with Pro badge and stats', (tester) async {
      final testProfile = UserProfile(
        uid: 'uid_user_pro',
        displayName: 'Selin Yıldız',
        email: 'selin@travel.io',
        photoUrl: 'avatar:animal_bunny',
        bio: 'Solo backpacker',
        isPro: true,
        createdAt: DateTime(2025, 6, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWith((ref) => null),
            profileControllerProvider.overrideWith((ref) {
              final controller = ProfileController(ref);
              controller.state = ProfileState(
                profile: testProfile,
                totalTrips: 12,
                totalCountriesVisited: 5,
                totalPackingItems: 120,
                totalDocuments: 8,
              );
              return controller;
            }),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Selin Yıldız'), findsOneWidget);
      expect(find.textContaining('Solo backpacker'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.byType(UserAvatar), findsOneWidget);
    });
  });

  group('Multi-Screen Size, RTL & Localization Layout Tests', () {
    const testSizes = [
      Size(320, 568), // Compact phone (iPhone SE 1st gen)
      Size(390, 844), // Standard phone (iPhone 14)
      Size(412, 915), // Large Android (Pixel 7)
      Size(800, 1280), // Tablet (10-inch)
    ];

    final complexProfile = UserProfile(
      uid: 'user_multi_test',
      displayName: 'Maximilian Constantin von Hohenberg',
      email: 'maximilian.constantin@packbuddy.enterprise.org',
      photoUrl: 'avatar:animal_fox',
      homeCountryCode: 'DE',
      homeCity: 'Garmisch-Partenkirchen',
      bio: 'Reisen ist Leben, Leben ist Reisen. Erkundung aller Kontinente mit Rucksack!',
      createdAt: DateTime(2024, 2, 29),
      isPro: true,
    );

    for (final size in testSizes) {
      testWidgets('ProfileHeaderCard renders at ${size.width}x${size.height} in DE and AR without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final lang in ['de', 'ar']) {
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: ProfileHeaderCard(
                  profile: complexProfile,
                  languageCode: lang,
                  onEditTap: () {},
                ),
              ),
            ),
          );

          expect(tester.takeException(), isNull);
          expect(find.byType(ProfileHeaderCard), findsOneWidget);
          expect(find.byType(UserAvatar), findsOneWidget);
        }
      });
    }

    testWidgets('TravelStatsCard renders with 1.5x font scale without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.5),
            ),
            child: const Scaffold(
              body: SingleChildScrollView(
                child: TravelStatsCard(
                  totalTrips: 15,
                  totalCountries: 28,
                  totalItems: 340,
                  totalDocuments: 12,
                  languageCode: 'de',
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);
    });

    testWidgets('AvatarPickerSheet adapts layout for compact screen (320px) and tablet (800px)', (tester) async {
      for (final width in [320.0, 800.0]) {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: const Locale('ar'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: AvatarPickerSheet(
                  profile: complexProfile,
                  languageCode: 'ar',
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(AvatarPickerSheet), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('ProfileScreen renders across sizes and locales without RenderFlex errors', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final lang in ['tr', 'en', 'ar', 'ru']) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authUserProvider.overrideWith((ref) => null),
              profileControllerProvider.overrideWith((ref) {
                final controller = ProfileController(ref);
                controller.state = ProfileState(
                  profile: complexProfile,
                  totalTrips: 9,
                  totalCountriesVisited: 11,
                  totalPackingItems: 145,
                  totalDocuments: 4,
                );
                return controller;
              }),
            ],
            child: MaterialApp(
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ProfileScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(ProfileScreen), findsOneWidget);
      }
    });
  });
}
