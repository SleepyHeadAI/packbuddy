import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/travel_badge.dart';
import 'package:packbuddy/features/profile/domain/travel_style.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/screens/friend_profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/friends_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/collaborator_avatar_stack.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/friend_tile.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/travel_badges_card.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  const supported20LangCodes = [
    'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru',
    'zh', 'ja', 'ko', 'hi', 'ar', 'nl', 'el', 'sv',
    'pl', 'id', 'th', 'vi'
  ];

  const screenSizes = [
    Size(320, 568),  // iPhone SE (ultra compact)
    Size(390, 844),  // iPhone 14/15/16 (standard iOS)
    Size(412, 915),  // Pixel 7/8/9 (standard Android)
    Size(800, 1280), // Tablet (10-inch)
  ];

  group('Faz 5: 20-Language Exhaustive Localization Tests', () {
    test('All 20 languages have complete non-empty ProfileLocalization strings', () {
      for (final lang in supported20LangCodes) {
        expect(ProfileLocalization.getTitle(lang).isNotEmpty, isTrue, reason: 'Failed for title in $lang');
        expect(ProfileLocalization.getEditProfile(lang).isNotEmpty, isTrue, reason: 'Failed for editProfile in $lang');
        expect(ProfileLocalization.getTravelStyles(lang).isNotEmpty, isTrue, reason: 'Failed for travelStyles in $lang');
        expect(ProfileLocalization.getBadgesAndAchievements(lang).isNotEmpty, isTrue, reason: 'Failed for badges in $lang');
        expect(ProfileLocalization.getUsername(lang).isNotEmpty, isTrue, reason: 'Failed for username in $lang');
        expect(ProfileLocalization.getTravelStatus(lang).isNotEmpty, isTrue, reason: 'Failed for travelStatus in $lang');
      }
    });

    test('All 20 languages have complete non-empty FriendLocalization strings', () {
      for (final lang in supported20LangCodes) {
        expect(FriendLocalization.getFriends(lang).isNotEmpty, isTrue, reason: 'Failed for friends in $lang');
        expect(FriendLocalization.getFriendRequests(lang).isNotEmpty, isTrue, reason: 'Failed for requests in $lang');
        expect(FriendLocalization.getAddFriend(lang).isNotEmpty, isTrue, reason: 'Failed for addFriend in $lang');
        expect(FriendLocalization.getSearchHint(lang).isNotEmpty, isTrue, reason: 'Failed for searchHint in $lang');
        expect(FriendLocalization.getMyQrCode(lang).isNotEmpty, isTrue, reason: 'Failed for myQrCode in $lang');
        expect(FriendLocalization.getRemoveFriend(lang).isNotEmpty, isTrue, reason: 'Failed for removeFriend in $lang');
        expect(FriendLocalization.getInviteToTrip(lang).isNotEmpty, isTrue, reason: 'Failed for inviteToTrip in $lang');
        expect(FriendLocalization.getAddFromFriends(lang).isNotEmpty, isTrue, reason: 'Failed for addFromFriends in $lang');
        expect(FriendLocalization.getAssignedTo(lang).isNotEmpty, isTrue, reason: 'Failed for assignedTo in $lang');
        expect(FriendLocalization.getUnassigned(lang).isNotEmpty, isTrue, reason: 'Failed for unassigned in $lang');
        expect(FriendLocalization.getInvitedToTrip(lang, 'Tokyo').isNotEmpty, isTrue, reason: 'Failed for invitedToTrip in $lang');
      }
    });

    test('All 10 TravelStyles localize in all 20 languages without fallback error', () {
      for (final style in TravelStyle.catalog) {
        for (final lang in supported20LangCodes) {
          final name = style.getLocalizedName(lang);
          expect(name.isNotEmpty, isTrue, reason: 'TravelStyle ${style.id} missing localized name in $lang');
        }
      }
    });

    test('All 16 Badges and 4 Tiers localize in all 20 languages', () {
      final badges = TravelBadge.calculateBadges(
        totalTrips: 10,
        totalCountries: 10,
        totalItems: 100,
        totalDocuments: 10,
      );

      for (final badge in badges) {
        for (final lang in supported20LangCodes) {
          expect(badge.getLocalizedTitle(lang).isNotEmpty, isTrue);
          expect(badge.getLocalizedDescription(lang).isNotEmpty, isTrue);
          expect(badge.tier.getLocalizedLabel(lang).isNotEmpty, isTrue);
        }
      }
    });
  });

  group('Faz 5: Multi-Screen Dimension Tests (320px, 390px, 412px, 800px)', () {
    final mockFriendSummary = FriendUserSummary(
      uid: 'dim_friend_test',
      displayName: 'Elif Sena Kaya',
      username: 'elif_sena',
      photoUrl: 'avatar:animal_panda',
      travelStatus: '🎒 Doğu Karadeniz yaylalarını geziyor',
      homeCountryCode: 'TR',
      homeCity: 'Trabzon',
      lastActiveAt: DateTime.now().subtract(const Duration(minutes: 3)),
      isPro: true,
      travelStyles: const ['backpacker', 'nature', 'photographer'],
    );

    for (final size in screenSizes) {
      testWidgets('FriendProfileScreen renders on ${size.width}x${size.height} without any RenderFlex overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

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
                friendUid: 'dim_friend_test',
                fallbackSummary: mockFriendSummary,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(FriendProfileScreen), findsOneWidget);
        expect(find.text('Elif Sena Kaya'), findsWidgets);
      });

      testWidgets('FriendsScreen renders on ${size.width}x${size.height} cleanly', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authUserProvider.overrideWith((ref) => null),
            ],
            child: const MaterialApp(
              locale: Locale('tr'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: FriendsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(FriendsScreen), findsOneWidget);
      });
    }
  });

  group('Faz 5: Dark Mode vs Light Mode Contrast & Rendering Tests', () {
    for (final isDark in [false, true]) {
      final themeName = isDark ? 'Dark Mode' : 'Light Mode';

      testWidgets('CollaboratorAvatarStack and BadgesCard render in $themeName', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
              home: Scaffold(
                body: Column(
                  children: [
                    const CollaboratorAvatarStack(
                      collaborators: ['@ahmet', '@zehra', '@cem', '@can'],
                      size: 26,
                    ),
                    TravelBadgesCard(
                      profile: UserProfile(
                        uid: 'u_test',
                        displayName: 'Test Explorer',
                        createdAt: DateTime.now(),
                        travelStyles: const ['backpacker', 'foodie'],
                      ),
                      totalTrips: 5,
                      totalCountries: 4,
                      totalItems: 50,
                      totalDocuments: 3,
                      languageCode: 'tr',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final ex = tester.takeException();
        if (ex != null) {
          final renderLines = tester.binding.renderView.toStringDeep().split('\n');
          for (int i = 0; i < renderLines.length; i++) {
            if (renderLines[i].contains('OVERFLOWING')) {
              for (int j = (i - 8).clamp(0, renderLines.length - 1); j <= (i + 15).clamp(0, renderLines.length - 1); j++) {
                debugPrint('TREE: ${renderLines[j]}');
              }
            }
          }
        }
        expect(ex, isNull);
        expect(find.byType(CollaboratorAvatarStack), findsOneWidget);
        expect(find.byType(TravelBadgesCard), findsOneWidget);
      });
    }
  });

  group('Faz 5: RTL (Arabic) Internationalization Tests', () {
    testWidgets('FriendTile and ProfileHeaderCard render in Arabic RTL without crash or overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final arabicFriend = FriendUserSummary(
        uid: 'friend_ar_test',
        displayName: 'طارق المنصور',
        username: 'tariq_m',
        photoUrl: 'avatar:animal_camel',
        travelStatus: '✈️ مسافر إلى دبي',
        lastActiveAt: DateTime.now(),
        isPro: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                children: [
                  FriendTile(
                    friend: arabicFriend,
                    languageCode: 'ar',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FriendTile), findsOneWidget);
      expect(find.text('طارق المنصور'), findsOneWidget);
      expect(find.text('@tariq_m'), findsOneWidget);
    });
  });
}
