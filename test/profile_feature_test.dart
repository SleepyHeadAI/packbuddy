import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/profile_header_card.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/travel_stats_card.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('UserProfile serializes and deserializes correctly', () {
      final now = DateTime(2026, 1, 15, 10, 30);
      final profile = UserProfile(
        uid: 'user_test_123',
        displayName: 'Ayla Yılmaz',
        email: 'ayla@example.com',
        photoUrl: 'https://example.com/avatar.png',
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
      expect(fromMap.homeCountryCode, equals('TR'));
      expect(fromMap.homeCity, equals('Istanbul'));
      expect(fromMap.bio, equals('Avid traveler & digital nomad'));
      expect(fromMap.isPro, isTrue);

      final jsonStr = profile.toJson();
      final fromJson = UserProfile.fromJson(jsonStr);
      expect(fromJson.uid, equals(profile.uid));
      expect(fromJson.displayName, equals(profile.displayName));
      expect(fromJson.email, equals(profile.email));
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
        isPro: true,
      );

      expect(updated.uid, equals('user_1'));
      expect(updated.displayName, equals('Updated Name'));
      expect(updated.bio, equals('New bio'));
      expect(updated.isPro, isTrue);
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
      }
    });
  });

  group('Profile UI Widget Tests', () {
    testWidgets('ProfileHeaderCard displays traveler info and triggers onEditTap', (tester) async {
      bool editTapped = false;
      final profile = UserProfile(
        uid: 'uid_test',
        displayName: 'Batu Gezgin',
        email: 'batu@packbuddy.com',
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

    testWidgets('ProfileScreen renders profile state with Pro badge and stats', (tester) async {
      final testProfile = UserProfile(
        uid: 'uid_user_pro',
        displayName: 'Selin Yıldız',
        email: 'selin@travel.io',
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
    });
  });
}
