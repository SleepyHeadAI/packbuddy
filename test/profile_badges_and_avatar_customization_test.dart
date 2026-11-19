import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/travel_badge.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/travel_badges_card.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  const supportedLanguages = [
    'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja',
    'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
  ];

  group('User Avatar in ProfileScreen AppBar Tests', () {
    testWidgets('ProfileScreen AppBar displays UserAvatar with user selected profile photo', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final userProfile = UserProfile(
        uid: 'user_avatar_test',
        displayName: 'Enes Seyahat',
        email: 'enes@packbuddy.app',
        photoUrl: 'avatar:animal_cat',
        bio: 'Dünya Gezgini',
        createdAt: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWith((ref) => null),
            profileControllerProvider.overrideWith((ref) {
              final controller = ProfileController(ref);
              controller.state = ProfileState(
                profile: userProfile,
                totalTrips: 8,
                totalCountriesVisited: 12,
                totalPackingItems: 150,
                totalDocuments: 6,
              );
              return controller;
            }),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all UserAvatar widgets (one in the AppBar and one in the ProfileHeaderCard)
      final avatarFinders = find.byType(UserAvatar);
      expect(avatarFinders, findsNWidgets(2));

      // Verify the AppBar contains a UserAvatar with the selected photoUrl
      final appBarAvatarFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(UserAvatar),
      );
      expect(appBarAvatarFinder, findsOneWidget);
      final appBarAvatar = tester.widget<UserAvatar>(appBarAvatarFinder);
      expect(appBarAvatar.photoUrl, equals('avatar:animal_cat'));
      expect(appBarAvatar.size, equals(32));

      // Verify the title "Profilim" is next to the avatar
      expect(find.text('Profilim'), findsOneWidget);
    });
  });

  group('TravelBadgesCard and "Tümünü Göster" Modal Tests', () {
    testWidgets('TravelBadgesCard renders "Tümünü Göster" button and opens All Badges modal', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final profile = UserProfile(
        uid: 'user_badges_modal_test',
        displayName: 'Caner Öz',
        travelStyles: ['backpacking', 'beach'],
        createdAt: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: TravelBadgesCard(
                profile: profile,
                totalTrips: 6,
                totalCountries: 10,
                totalItems: 120,
                totalDocuments: 7,
                languageCode: 'tr',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // "Tümünü Göster" button is rendered
      final viewAllBtn = find.text('Tümünü Göster');
      expect(viewAllBtn, findsOneWidget);

      // Verify the badges card header shows achievement count (unlocked / total)
      final badges = TravelBadge.calculateBadges(
        totalTrips: 6,
        totalCountries: 10,
        totalItems: 120,
        totalDocuments: 7,
      );
      final unlockedCount = badges.where((b) => b.isUnlocked).length;
      expect(find.text('$unlockedCount/${badges.length}'), findsOneWidget);

      // Tap "Tümünü Göster" to open the bottom sheet modal
      await tester.tap(viewAllBtn);
      await tester.pumpAndSettle();

      // Verify the modal sheet is open with title "Tüm Rozetler & Başarılar"
      expect(find.text('Tüm Rozetler & Başarılar'), findsOneWidget);
      expect(find.textContaining('Rozet Açıldı'), findsOneWidget);

      // Verify filter tabs are rendered: "Tümü (15)", "Kazanılanlar", "Kilitli"
      expect(find.textContaining('Tümü (${badges.length})'), findsOneWidget);
      expect(find.textContaining('Kazanılanlar ($unlockedCount)'), findsOneWidget);
      expect(find.textContaining('Kilitli (${badges.length - unlockedCount})'), findsOneWidget);

      // In the modal, both unlocked and locked badges are shown
      expect(find.text('İlk Sınır Ötesi'), findsWidgets);
      expect(find.text('Evrensel Kaşif'), findsWidgets);

      // Tap on a badge in the modal to view its detailed bottom sheet
      await tester.tap(find.text('İlk Sınır Ötesi').last);
      await tester.pumpAndSettle();

      // Detail sheet shows requirement and progress
      expect(find.text('Gereksinim'), findsOneWidget);
      expect(find.text('1 ülke ziyaret edildi'), findsOneWidget);
      expect(find.text('Kazanıldı ✨'), findsOneWidget);
    });

    testWidgets('Filter tabs in All Badges modal switch between All, Unlocked, and Locked', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final profile = UserProfile(
        uid: 'user_badges_filter_test',
        displayName: 'Test User',
        createdAt: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: TravelBadgesCard(
                profile: profile,
                totalTrips: 2,
                totalCountries: 1,
                totalItems: 30,
                totalDocuments: 1,
                languageCode: 'tr',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Tümünü Göster'));
      await tester.pumpAndSettle();

      // Tap "Kazanılanlar" tab
      final earnedTab = find.textContaining('Kazanılanlar');
      await tester.tap(earnedTab);
      await tester.pumpAndSettle();

      // Tap "Kilitli" tab
      final lockedTab = find.textContaining('Kilitli');
      await tester.tap(lockedTab);
      await tester.pumpAndSettle();

      // Locked badge is shown
      expect(find.text('Evrensel Kaşif'), findsWidgets);

      // Tap locked badge to see locked details
      await tester.tap(find.text('Evrensel Kaşif').last);
      await tester.pumpAndSettle();

      expect(find.text('Kilitli'), findsOneWidget);
      expect(find.text('25 ülke ziyaret edildi'), findsOneWidget);
    });
  });

  group('Multi-Screen Size & Localization Robustness Tests', () {
    const screenSizes = [
      Size(320, 568), // Compact iPhone SE
      Size(360, 640), // Standard Android compact
      Size(390, 844), // iPhone 14
      Size(412, 915), // Pixel 7
      Size(800, 1280), // Tablet
    ];

    for (final size in screenSizes) {
      testWidgets('TravelBadgesCard renders on size ${size.width}x${size.height} without RenderFlex overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final profile = UserProfile(
          uid: 'user_size_test',
          displayName: 'Test Multi Size',
          travelStyles: ['backpacking', 'cultural', 'luxury', 'nature'],
          createdAt: DateTime(2025, 1, 1),
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('tr'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: TravelBadgesCard(
                  profile: profile,
                  totalTrips: 15,
                  totalCountries: 25,
                  totalItems: 300,
                  totalDocuments: 10,
                  languageCode: 'tr',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final exception = tester.takeException();
        expect(exception, isNull);
        expect(find.text('Tümünü Göster'), findsOneWidget);
      });
    }

    test('All 20 languages have non-empty strings for all new badge methods and tiers', () {
      for (final lang in supportedLanguages) {
        expect(ProfileLocalization.getViewAll(lang).isNotEmpty, isTrue, reason: 'getViewAll empty for $lang');
        expect(ProfileLocalization.getAllBadges(lang).isNotEmpty, isTrue, reason: 'getAllBadges empty for $lang');
        expect(ProfileLocalization.getAllTab(lang).isNotEmpty, isTrue, reason: 'getAllTab empty for $lang');
        expect(ProfileLocalization.getEarnedTab(lang).isNotEmpty, isTrue, reason: 'getEarnedTab empty for $lang');
        expect(ProfileLocalization.getLockedTab(lang).isNotEmpty, isTrue, reason: 'getLockedTab empty for $lang');
        expect(ProfileLocalization.getTapBadgeHint(lang).isNotEmpty, isTrue, reason: 'getTapBadgeHint empty for $lang');
        expect(ProfileLocalization.getProgress(lang).isNotEmpty, isTrue, reason: 'getProgress empty for $lang');
        expect(ProfileLocalization.getRequirement(lang).isNotEmpty, isTrue, reason: 'getRequirement empty for $lang');
        expect(ProfileLocalization.getBadgesUnlockedSummary(lang, 5, 15).isNotEmpty, isTrue, reason: 'getBadgesUnlockedSummary empty for $lang');

        // Check tier labels in this language
        for (final tier in BadgeTier.values) {
          expect(tier.getLocalizedLabel(lang).isNotEmpty, isTrue, reason: '${tier.name} tier empty for $lang');
        }

        // Check all 15 badges titles and descriptions in this language
        final sampleBadges = TravelBadge.calculateBadges(
          totalTrips: 10,
          totalCountries: 5,
          totalItems: 100,
          totalDocuments: 5,
        );
        for (final badge in sampleBadges) {
          expect(badge.getLocalizedTitle(lang).isNotEmpty, isTrue, reason: '${badge.id} title empty for $lang');
          expect(badge.getLocalizedDescription(lang).isNotEmpty, isTrue, reason: '${badge.id} desc empty for $lang');
        }
      }
    });
  });
}
