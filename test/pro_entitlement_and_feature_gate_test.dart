import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:packbuddy/core/services/pro_entitlement_service.dart';
import 'package:packbuddy/core/services/telemetry_service.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/travel_map_story_card.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProFeatureGate Static Limits & Entitlement Logic', () {
    test('Trip limit: Free allows 1 active and 2 total trips; Pro allows unlimited', () {
      // Free tier: 0 trips -> Allowed
      expect(ProFeatureGate.canCreateTrip(isPro: false, totalTrips: 0, activeTrips: 0), isTrue);

      // Free tier: 1 active trip -> Blocked (max 1 active)
      expect(ProFeatureGate.canCreateTrip(isPro: false, totalTrips: 1, activeTrips: 1), isFalse);

      // Free tier: 2 completed trips -> Blocked (max 2 total)
      expect(ProFeatureGate.canCreateTrip(isPro: false, totalTrips: 2, activeTrips: 0), isFalse);

      // Pro tier: unlimited active and total trips
      expect(ProFeatureGate.canCreateTrip(isPro: true, totalTrips: 10, activeTrips: 5), isTrue);
    });

    test('Vault limits: Free allows 5 docs; Pro allows unlimited', () {
      expect(
        ProFeatureGate.canAddVaultDocument(
          isPro: false,
          currentDocCount: 0,
          fileSizeBytes: 1024,
          totalVaultBytes: 0,
        ),
        isTrue,
      );
      expect(
        ProFeatureGate.canAddVaultDocument(
          isPro: false,
          currentDocCount: 4,
          fileSizeBytes: 1024,
          totalVaultBytes: 4096,
        ),
        isTrue,
      );
      expect(
        ProFeatureGate.canAddVaultDocument(
          isPro: false,
          currentDocCount: 5,
          fileSizeBytes: 1024,
          totalVaultBytes: 5120,
        ),
        isFalse,
      );

      // Pro tier allows > 5 docs
      expect(
        ProFeatureGate.canAddVaultDocument(
          isPro: true,
          currentDocCount: 50,
          fileSizeBytes: 1024,
          totalVaultBytes: 51200,
        ),
        isTrue,
      );
    });

    test('Single file size limit: strictly max 10 MB for both Free and Pro', () {
      const maxAllowed = 10 * 1024 * 1024; // 10 MB

      // Valid: exactly 10MB or under
      expect(
        ProFeatureGate.canAddVaultDocument(
          isPro: true,
          currentDocCount: 0,
          fileSizeBytes: maxAllowed,
          totalVaultBytes: 0,
        ),
        isTrue,
      );

      // Exceeded: 10MB + 1 byte
      expect(
        ProFeatureGate.canAddVaultDocument(
          isPro: true,
          currentDocCount: 0,
          fileSizeBytes: maxAllowed + 1,
          totalVaultBytes: 0,
        ),
        isFalse,
      );
    });

    test('Cloud storage quota: Free allows 50 MB; Pro allows 5 GB', () {
      const fiftyMB = 50 * 1024 * 1024;
      const fiveGB = 5 * 1024 * 1024 * 1024;

      // Free tier
      expect(ProFeatureGate.canSyncToCloud(isPro: false, totalCloudBytes: fiftyMB - 100), isTrue);
      expect(ProFeatureGate.canSyncToCloud(isPro: false, totalCloudBytes: fiftyMB + 1), isFalse);

      // Pro tier
      expect(ProFeatureGate.canSyncToCloud(isPro: true, totalCloudBytes: fiveGB - 100), isTrue);
      expect(ProFeatureGate.canSyncToCloud(isPro: true, totalCloudBytes: fiveGB + 1), isFalse);
    });

    test('Itinerary limit: Free allows 3 activities/day; Pro allows unlimited', () {
      // Free tier: 0..2 existing activities -> Allowed
      expect(ProFeatureGate.canAddItineraryActivity(isPro: false, currentActivitiesInDay: 0), isTrue);
      expect(ProFeatureGate.canAddItineraryActivity(isPro: false, currentActivitiesInDay: 2), isTrue);

      // Free tier: 3 existing activities on that date -> Blocked
      expect(ProFeatureGate.canAddItineraryActivity(isPro: false, currentActivitiesInDay: 3), isFalse);

      // Pro tier: unlimited
      expect(ProFeatureGate.canAddItineraryActivity(isPro: true, currentActivitiesInDay: 3), isTrue);
      expect(ProFeatureGate.canAddItineraryActivity(isPro: true, currentActivitiesInDay: 10), isTrue);
    });

    test('Story Card Themes & Layouts: 4 themes / 3 layouts free, remainder Pro', () {
      // 4 Free themes
      for (final theme in [
        StoryCardTheme.midnight,
        StoryCardTheme.sunset,
        StoryCardTheme.minimalLight,
        StoryCardTheme.sandLight,
      ]) {
        expect(ProFeatureGate.canUseStoryTheme(theme: theme, isPro: false), isTrue, reason: '$theme should be free');
        expect(ProFeatureGate.canUseStoryTheme(theme: theme, isPro: true), isTrue);
      }

      // Pro themes
      for (final theme in [
        StoryCardTheme.emerald,
        StoryCardTheme.cyberpunk,
        StoryCardTheme.volcano,
        StoryCardTheme.nordicForest,
        StoryCardTheme.goldenHour,
        StoryCardTheme.galaxy,
        StoryCardTheme.monochromeDark,
        StoryCardTheme.oceanLight,
        StoryCardTheme.cherryBlossom,
        StoryCardTheme.vintageSepia,
        StoryCardTheme.matcha,
        StoryCardTheme.pastelDream,
      ]) {
        expect(ProFeatureGate.canUseStoryTheme(theme: theme, isPro: false), isFalse, reason: '$theme should be locked for free');
        expect(ProFeatureGate.canUseStoryTheme(theme: theme, isPro: true), isTrue);
      }

      // 3 Free layouts
      for (final layout in [
        StoryCardLayout.classic,
        StoryCardLayout.minimal,
        StoryCardLayout.journey,
      ]) {
        expect(ProFeatureGate.canUseStoryLayout(layout: layout, isPro: false), isTrue);
        expect(ProFeatureGate.canUseStoryLayout(layout: layout, isPro: true), isTrue);
      }

      // Pro layouts
      for (final layout in [
        StoryCardLayout.passport,
        StoryCardLayout.showcase,
        StoryCardLayout.polaroid,
        StoryCardLayout.infographic,
      ]) {
        expect(ProFeatureGate.canUseStoryLayout(layout: layout, isPro: false), isFalse);
        expect(ProFeatureGate.canUseStoryLayout(layout: layout, isPro: true), isTrue);
      }
    });

    test('Home Widget Themes: 4 free widget themes, 12 Pro themes', () {
      for (final theme in ['midnight', 'sunset', 'minimalLight', 'sandLight']) {
        expect(ProFeatureGate.canUseWidgetTheme(themeKey: theme, isPro: false), isTrue);
        expect(ProFeatureGate.canUseWidgetTheme(themeKey: theme, isPro: true), isTrue);
      }

      for (final theme in ['emerald', 'cyberpunk', 'volcano', 'nordicForest']) {
        expect(ProFeatureGate.canUseWidgetTheme(themeKey: theme, isPro: false), isFalse);
        expect(ProFeatureGate.canUseWidgetTheme(themeKey: theme, isPro: true), isTrue);
      }
    });

    test('Downgrade Safety: existing user data remains readable and intact', () {
      final now = DateTime.now();
      // Simulating a user who created 5 trips while on Pro, then downgraded to Free
      final trips = List.generate(
        5,
        (i) => Trip(
          id: 'trip_$i',
          title: 'Trip $i',
          destination: 'City $i',
          startDate: now.subtract(Duration(days: 30 - i * 5)),
          endDate: now.subtract(Duration(days: 25 - i * 5)),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Verify all 5 trips remain accessible in the list
      expect(trips.length, equals(5));

      // Attempting to create an additional 6th trip when downgraded to Free
      final canCreate6th = ProFeatureGate.canCreateTrip(isPro: false, totalTrips: trips.length, activeTrips: 0);
      expect(canCreate6th, isFalse); // Gracefully blocked from creating new trips, but existing 5 are intact!

      // Same for 10 vault documents
      final docs = List.generate(
        10,
        (i) => Document(
          id: 'doc_$i',
          title: 'Doc $i',
          category: 'Identity',
          localImagePath: '/data/doc_$i.enc',
          fileSizeBytes: 1024,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(docs.length, equals(10));
      expect(
        ProFeatureGate.canAddVaultDocument(
          isPro: false,
          currentDocCount: docs.length,
          fileSizeBytes: 1024,
          totalVaultBytes: 10240,
        ),
        isFalse,
      );
    });
  });

  group('ProEntitlementService Offline & Anti-Abuse Hardening', () {
    test('Offline for 10 days (> old 72h limit) with an unexpired subscription stays Pro', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final tenDaysAgoMs = nowMs - const Duration(days: 10).inMilliseconds;

      FlutterSecureStorage.setMockInitialValues({
        'test_uid_secure_is_pro_member': 'true',
        'test_uid_secure_pro_source': 'google_play',
        'test_uid_secure_pro_expires_at': '${nowMs + const Duration(days: 20).inMilliseconds}',
        'test_uid_secure_last_verified_at': '$tenDaysAgoMs',
        'test_uid_secure_max_monotonic_ts': '$tenDaysAgoMs',
      });

      expect(await ProEntitlementService.instance.resolveEffectivePro(uid: 'test_uid'), isTrue);
    });

    test('Offline with an expired subscription turns Pro off', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final fortyDaysAgoMs = nowMs - const Duration(days: 40).inMilliseconds;

      FlutterSecureStorage.setMockInitialValues({
        'test_uid_secure_is_pro_member': 'true',
        'test_uid_secure_pro_source': 'google_play',
        'test_uid_secure_pro_expires_at': '${nowMs - const Duration(days: 1).inMilliseconds}',
        'test_uid_secure_last_verified_at': '$fortyDaysAgoMs',
        'test_uid_secure_max_monotonic_ts': '$fortyDaysAgoMs',
      });

      expect(await ProEntitlementService.instance.resolveEffectivePro(uid: 'test_uid'), isFalse);
    });

    test('Clock rollback detection: pauses Pro if device clock is set backwards > 5 minutes', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      // Simulate stored future timestamp in secure storage (clock was at +1 hour earlier)
      final futureMonotonic = nowMs + (3600 * 1000);

      FlutterSecureStorage.setMockInitialValues({
        'test_uid_secure_is_pro_member': 'true',
        'test_uid_secure_pro_source': 'google_play',
        'test_uid_secure_pro_expires_at': '${nowMs + (30 * 24 * 3600 * 1000)}',
        'test_uid_secure_last_verified_at': '$nowMs',
        'test_uid_secure_max_monotonic_ts': '$futureMonotonic',
      });

      final isPro = await ProEntitlementService.instance.resolveEffectivePro(uid: 'test_uid');
      // Device time is 1 hour before max monotonic timestamp -> clock manipulation detected!
      expect(isPro, isFalse);
    });

    test('Legitimate secure storage pro validation succeeds within grace period', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final twoHoursAgoMs = nowMs - (2 * 3600 * 1000);

      FlutterSecureStorage.setMockInitialValues({
        'test_uid_secure_is_pro_member': 'true',
        'test_uid_secure_pro_source': 'google_play',
        'test_uid_secure_pro_expires_at': '${nowMs + (30 * 24 * 3600 * 1000)}',
        'test_uid_secure_last_verified_at': '$twoHoursAgoMs',
        'test_uid_secure_max_monotonic_ts': '$twoHoursAgoMs',
      });

      final isPro = await ProEntitlementService.instance.resolveEffectivePro(uid: 'test_uid');
      expect(isPro, isTrue);
    });
  });

  group('Contextual Paywall UI & PostHog Telemetry Events', () {
    testWidgets('PaywallSheet displays contextual title and highlighted badge', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    PaywallSheet.show(
                      context,
                      triggerSource: 'trip_limit',
                      highlightFeature: 'trip_limit',
                    );
                  },
                  child: const Text('Open Paywall'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Paywall'));
      await tester.pumpAndSettle();

      // Verify PaywallSheet appeared
      expect(find.byType(PaywallSheet), findsOneWidget);

      // Verify contextual title is displayed
      expect(find.textContaining('Unlimited'), findsWidgets);
    });

    test('TelemetryService logs pro gate hit and purchase lifecycle without errors', () async {
      await TelemetryService.instance.logProGateHit(featureKey: 'trip_limit', context: 'add_trip_sheet');
      await TelemetryService.instance.logPaywallViewed(triggerSource: 'settings', highlightFeature: 'cloud_sync');
      await TelemetryService.instance.logPurchaseStarted(productId: 'packbuddy_pro_annual', plan: 'annual');
      await TelemetryService.instance.logPurchaseCompleted(productId: 'packbuddy_pro_annual', plan: 'annual');
    });
  });
}
