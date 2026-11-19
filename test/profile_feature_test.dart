import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/domain/animal_avatar.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/travel_badge.dart';
import 'package:packbuddy/features/profile/domain/travel_style.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/friends_controller.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/friend_profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/friends_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/add_friend_sheet.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/edit_profile_sheet.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/friend_tile.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/my_buddy_qr_sheet.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/profile_header_card.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/travel_badges_card.dart';
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
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
      // Both AppBar title and ProfileHeaderCard display the user's chosen avatar
      expect(find.byType(UserAvatar), findsNWidgets(2));
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

  group('Phase 1: Travel Badges, Styles & Handles Tests', () {
    test('UserProfile handles username, travelStatus and travelStyles correctly', () {
      final profile = UserProfile(
        uid: 'user_ph1',
        displayName: 'Caner Gezgin',
        username: 'caner_traveler',
        travelStatus: '🧳 Roma için bavul topluyor',
        travelStyles: const ['backpacker', 'photographer'],
        createdAt: DateTime(2026, 1, 1),
      );

      final map = profile.toMap();
      expect(map['username'], equals('caner_traveler'));
      expect(map['travelStatus'], equals('🧳 Roma için bavul topluyor'));
      expect(map['travelStyles'], equals(['backpacker', 'photographer']));

      final fromMap = UserProfile.fromMap(map);
      expect(fromMap.username, equals('caner_traveler'));
      expect(fromMap.travelStatus, equals('🧳 Roma için bavul topluyor'));
      expect(fromMap.travelStyles, equals(['backpacker', 'photographer']));

      final updated = profile.copyWith(
        username: 'caner_nomad',
        travelStyles: ['nature', 'foodie'],
      );
      expect(updated.username, equals('caner_nomad'));
      expect(updated.travelStyles, equals(['nature', 'foodie']));
    });

    test('TravelStyle catalog contains 10 distinct styles with valid localizations', () {
      expect(TravelStyle.catalog.length, equals(10));
      for (final style in TravelStyle.catalog) {
        expect(style.id.isNotEmpty, isTrue);
        expect(style.emoji.isNotEmpty, isTrue);
        expect(style.getLocalizedName('tr').isNotEmpty, isTrue);
        expect(style.getLocalizedName('en').isNotEmpty, isTrue);
        expect(style.getLocalizedName('de').isNotEmpty, isTrue);
      }
      expect(TravelStyle.findById('backpacker')?.emoji, equals('🎒'));
      expect(TravelStyle.findById('unknown_id'), isNull);
    });

    test('TravelBadge calculator computes unlock status and ratios accurately', () {
      final badges = TravelBadge.calculateBadges(
        totalTrips: 6,
        totalCountries: 10,
        totalItems: 120,
        totalDocuments: 2,
      );

      expect(badges.isNotEmpty, isTrue);

      // Countries
      final explorerBronze = badges.firstWhere((b) => b.id == 'explorer_bronze');
      expect(explorerBronze.isUnlocked, isTrue);
      final explorerGold = badges.firstWhere((b) => b.id == 'explorer_gold');
      expect(explorerGold.isUnlocked, isTrue);
      final explorerDiamond = badges.firstWhere((b) => b.id == 'explorer_diamond');
      expect(explorerDiamond.isUnlocked, isFalse);
      expect(explorerDiamond.progressRatio, equals(10 / 25));

      // Trips
      final tripsBronze = badges.firstWhere((b) => b.id == 'trips_bronze');
      expect(tripsBronze.isUnlocked, isTrue);
      final tripsSilver = badges.firstWhere((b) => b.id == 'trips_silver');
      expect(tripsSilver.isUnlocked, isTrue);
      final tripsGold = badges.firstWhere((b) => b.id == 'trips_gold');
      expect(tripsGold.isUnlocked, isFalse);

      // Packing
      final packingSilver = badges.firstWhere((b) => b.id == 'packing_silver');
      expect(packingSilver.isUnlocked, isTrue);

      // Vault
      final vaultBronze = badges.firstWhere((b) => b.id == 'vault_bronze');
      expect(vaultBronze.isUnlocked, isTrue);
      final vaultSilver = badges.firstWhere((b) => b.id == 'vault_silver');
      expect(vaultSilver.isUnlocked, isFalse);
    });

    testWidgets('ProfileHeaderCard displays @username and travel status chips', (tester) async {
      final profile = UserProfile(
        uid: 'user_display_test',
        displayName: 'Merve Bulut',
        username: 'merve_b',
        travelStatus: '✈️ Yolda / Havada',
        createdAt: DateTime(2026, 2, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeaderCard(
              profile: profile,
              languageCode: 'tr',
              onEditTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('@merve_b'), findsOneWidget);
      expect(find.text('✈️ Yolda / Havada'), findsOneWidget);
    });

    testWidgets('TravelBadgesCard renders travel styles and badges seamlessly', (tester) async {
      final profile = UserProfile(
        uid: 'user_badges_test',
        displayName: 'Selin Kaya',
        travelStyles: const ['backpacker', 'beach'],
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TravelBadgesCard(
                profile: profile,
                totalTrips: 5,
                totalCountries: 3,
                totalItems: 80,
                totalDocuments: 1,
                languageCode: 'tr',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TravelBadgesCard), findsOneWidget);
      expect(find.text('Sırt Çantalı'), findsOneWidget);
      expect(find.text('Deniz & Plaj'), findsOneWidget);
    });
  });

  group('Phase 2: Travel Buddies, Requests & QR Tests', () {
    test('Friendship canonical ID and status serialization works accurately', () {
      final id1 = Friendship.generateId('user_alpha', 'user_beta');
      final id2 = Friendship.generateId('user_beta', 'user_alpha');
      expect(id1, equals('user_alpha_user_beta'));
      expect(id2, equals('user_alpha_user_beta'));

      final friendship = Friendship(
        id: id1,
        users: const ['user_alpha', 'user_beta'],
        requesterId: 'user_alpha',
        receiverId: 'user_beta',
        status: FriendshipStatus.pending,
        createdAt: DateTime(2026, 2, 10),
        updatedAt: DateTime(2026, 2, 10),
      );

      final map = friendship.toMap();
      expect(map['status'], equals('pending'));
      expect(map['users'], equals(['user_alpha', 'user_beta']));

      final fromMap = Friendship.fromMap(map);
      expect(fromMap.status, equals(FriendshipStatus.pending));
      expect(fromMap.id, equals(id1));
    });

    test('FriendUserSummary serializes and parses json cleanly', () {
      final summary = FriendUserSummary(
        uid: 'buddy_42',
        displayName: 'Kerem Kaya',
        username: 'kerem_k',
        photoUrl: 'avatar:animal_fox',
        travelStatus: '🏖️ Tatil modunda',
        homeCountryCode: 'TR',
        homeCity: 'Antalya',
        isPro: true,
        travelStyles: const ['beach', 'foodie'],
      );

      final jsonStr = summary.toJson();
      final fromJson = FriendUserSummary.fromJson(jsonStr);

      expect(fromJson.uid, equals('buddy_42'));
      expect(fromJson.displayName, equals('Kerem Kaya'));
      expect(fromJson.username, equals('kerem_k'));
      expect(fromJson.travelStatus, equals('🏖️ Tatil modunda'));
      expect(fromJson.homeCountryCode, equals('TR'));
      expect(fromJson.homeCity, equals('Antalya'));
      expect(fromJson.isPro, isTrue);
      expect(fromJson.travelStyles, equals(['beach', 'foodie']));
    });

    test('FriendLocalization returns non-empty strings across all supported languages', () {
      const langs = ['tr', 'en', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja', 'ko', 'ar'];
      for (final l in langs) {
        expect(FriendLocalization.getFriends(l).isNotEmpty, isTrue);
        expect(FriendLocalization.getFriendRequests(l).isNotEmpty, isTrue);
        expect(FriendLocalization.getAddFriend(l).isNotEmpty, isTrue);
        expect(FriendLocalization.getSearchHint(l).isNotEmpty, isTrue);
        expect(FriendLocalization.getNoFriendsTitle(l).isNotEmpty, isTrue);
        expect(FriendLocalization.getMyQrCode(l).isNotEmpty, isTrue);
      }
    });

    testWidgets('FriendTile renders friend details and status chip properly', (tester) async {
      final friend = FriendUserSummary(
        uid: 'friend_1',
        displayName: 'Deniz Demir',
        username: 'deniz_d',
        travelStatus: '🧳 Bavul topluyor',
        homeCountryCode: 'TR',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendTile(
              friend: friend,
              languageCode: 'tr',
            ),
          ),
        ),
      );

      expect(find.text('Deniz Demir'), findsOneWidget);
      expect(find.text('@deniz_d'), findsOneWidget);
      expect(find.text('🧳 Bavul topluyor'), findsOneWidget);
    });

    testWidgets('MyBuddyQrSheet renders QR visual, handle and action buttons', (tester) async {
      final profile = UserProfile(
        uid: 'user_qr_test',
        displayName: 'Barış Yıldız',
        username: 'baris_y',
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyBuddyQrSheet(
              profile: profile,
              languageCode: 'tr',
            ),
          ),
        ),
      );

      expect(find.text('Barış Yıldız'), findsOneWidget);
      expect(find.text('@baris_y'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Kopyala'), findsOneWidget);
    });

    testWidgets('FriendsScreen renders tabs, empty state and switches tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWith((ref) => null),
            friendsControllerProvider.overrideWith((ref) {
              return FriendsController(ref);
            }),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            home: FriendsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(FriendsScreen), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);

      // Switch to Requests tab
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Phase 3: Friend Profile & Presence Tests', () {
    test('PresenceFormatter formats smart activity timestamps accurately', () {
      final now = DateTime.now();

      // Null -> Offline
      expect(PresenceFormatter.format(null, 'tr'), contains('Çevrimdışı'));
      expect(PresenceFormatter.format(null, 'en'), contains('Offline'));

      // < 5 min -> Currently active
      final justNow = now.subtract(const Duration(minutes: 2));
      expect(PresenceFormatter.format(justNow, 'tr'), equals('🟢 Şu an aktif'));
      expect(PresenceFormatter.format(justNow, 'en'), equals('🟢 Active now'));

      // 30 min -> 30m ago
      final thirtyMin = now.subtract(const Duration(minutes: 30));
      expect(PresenceFormatter.format(thirtyMin, 'tr'), equals('🟡 30 dk önce aktifti'));
      expect(PresenceFormatter.format(thirtyMin, 'en'), equals('🟡 Active 30m ago'));

      // 4 hours -> 4h ago
      final fourHours = now.subtract(const Duration(hours: 4));
      expect(PresenceFormatter.format(fourHours, 'tr'), equals('🟡 4 saat önce aktifti'));
      expect(PresenceFormatter.format(fourHours, 'en'), equals('🟡 Active 4h ago'));

      // 1 day -> yesterday
      final oneDay = now.subtract(const Duration(days: 1, hours: 2));
      expect(PresenceFormatter.format(oneDay, 'tr'), equals('⚪ Dün aktifti'));
      expect(PresenceFormatter.format(oneDay, 'en'), equals('⚪ Active yesterday'));

      // 3 days -> 3d ago
      final threeDays = now.subtract(const Duration(days: 3));
      expect(PresenceFormatter.format(threeDays, 'tr'), equals('⚪ 3 gün önce aktifti'));
      expect(PresenceFormatter.format(threeDays, 'en'), equals('⚪ Active 3d ago'));
    });

    testWidgets('FriendProfileScreen renders friend info, presence, badges and invite button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final summary = FriendUserSummary(
        uid: 'friend_view_test',
        displayName: 'Okan Yurt',
        username: 'okan_y',
        photoUrl: 'avatar:animal_owl',
        travelStatus: '🗺️ Yeni rota planlıyor',
        homeCountryCode: 'TR',
        homeCity: 'Izmir',
        lastActiveAt: DateTime.now().subtract(const Duration(minutes: 1)),
        isPro: true,
        travelStyles: const ['backpacker', 'nature'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FriendProfileScreen(
              friendUid: 'friend_view_test',
              fallbackSummary: summary,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Okan Yurt'), findsWidgets);
      expect(find.text('@okan_y'), findsOneWidget);
      expect(find.text('🟢 Şu an aktif'), findsOneWidget);
      expect(find.text('🗺️ Yeni rota planlıyor'), findsOneWidget);
      expect(find.text('Sırt Çantalı'), findsOneWidget);
      expect(find.text('Doğa & Kamp'), findsOneWidget);
      expect(find.byType(FilledButton), findsWidgets);
    });
  });
}
