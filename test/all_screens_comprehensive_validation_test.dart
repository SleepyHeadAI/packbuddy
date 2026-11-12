import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

// Screens & Controllers
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/auth_screen.dart';
import 'package:packbuddy/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:packbuddy/features/auth/presentation/screens/banned_screen.dart';
import 'package:packbuddy/features/auth/presentation/screens/legal_consent_screen.dart';
import 'package:packbuddy/features/admin/user_moderation_provider.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_comparison_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/emergency_guide_sheet.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/add_packing_item_sheet.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/airline_guide_sheet.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/add_document_sheet.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/feedback/presentation/widgets/feedback_sheet.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/onboarding/presentation/screens/onboarding_screen.dart';

// =============================================================================
// FAKES & TEST FIXTURES
// =============================================================================

class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool emailVerified;
  @override
  final List<UserInfo> providerData;

  FakeUser({
    this.uid = 'test-user-id',
    this.email = 'tester@packbuddy.app',
    this.displayName = 'Master Traveler',
    this.emailVerified = true,
    this.providerData = const [],
  });
}

class FakeLocaleNotifier extends LocaleNotifier {
  FakeLocaleNotifier(Locale initial) : super() {
    state = initial;
  }
}

class FakeTripController extends StateNotifier<TripState> implements TripController {
  FakeTripController([TripState? state])
      : super(state ?? const TripState(isLoading: false, trips: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeChecklistNotifier extends StateNotifier<ChecklistState> implements ChecklistNotifier {
  FakeChecklistNotifier([ChecklistState? state])
      : super(state ?? const ChecklistState(isLoading: false, items: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  FakeVaultController([VaultState? state])
      : super(state ?? const VaultState(isLoading: false, documents: []));

  int _failedAttempts = 0;

  @override
  int getRemainingPinAttempts() => (5 - _failedAttempts).clamp(0, 5);

  @override
  bool isPinLockedOut() => false;

  @override
  int getPinLockoutRemainingSeconds() => 0;

  @override
  Future<void> resetFailedPinAttempts() async {
    _failedAttempts = 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeSyncEngine extends StateNotifier<SyncState> implements SyncEngine {
  FakeSyncEngine([SyncState? state]) : super(state ?? const SyncState());

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeRevenueCatNotifier extends StateNotifier<ProSubscriptionState> implements MockRevenueCatNotifier {
  FakeRevenueCatNotifier([ProSubscriptionState? state])
      : super(state ?? const ProSubscriptionState(isPro: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakePackingRemindersNotifier extends StateNotifier<bool> implements PackingRemindersNotifier {
  FakePackingRemindersNotifier([super.state = true]);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'packbuddy_is_pro_member': true,
      'theme_mode': 'light',
    });
    await PreferencesService.init();
    await PreferencesService.instance.setOnboardingCompleted(true);
    await PreferencesService.instance.setLegalConsentAccepted(true, uid: 'test-user-id');
  });

  const testViewports = [
    Size(320, 568), // Ultra-compact iPhone SE 1st gen
    Size(390, 844), // Standard Phone iPhone 14
    Size(412, 915), // Large Android Phone Pixel 7/8
    Size(768, 1024), // Tablet iPad
  ];

  const primaryTestLangs = ['tr', 'en', 'de', 'ru', 'ar', 'ja'];

  const all20Languages = [
    'ar', 'de', 'el', 'en', 'es', 'fr', 'hi', 'id', 'it', 'ja',
    'ko', 'nl', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'vi', 'zh',
  ];

  final now = DateTime(2026, 6, 1);
  final testTrip = Trip(
    id: 'test-trip-1',
    userId: 'test-user-id',
    title: 'European Grand Tour & Cultural Expedition',
    destination: 'Berlin, Deutschland & Wien, Österreich',
    countryCode: 'DE',
    startDate: now.add(const Duration(days: 3)),
    endDate: now.add(const Duration(days: 10)),
    budgetLimit: 2500,
    transportMode: 'uçak',
    notes: 'Packing passport and warm jackets',
    createdAt: now,
    updatedAt: now,
  );

  final testItem = PackingItem(
    id: 'item-1',
    tripId: 'test-trip-1',
    name: 'Noise Cancelling Headphones',
    category: 'Electronics',
    quantity: 1,
    isPacked: false,
    createdAt: now,
    updatedAt: now,
  );

  final testDoc = Document(
    id: 'doc-1',
    tripId: 'test-trip-1',
    title: 'Biometric Passport & International Travel Insurance',
    category: 'Passport',
    subCategory: 'Primary',
    localImagePath: 'test/path/passport.pdf',
    fileType: 'pdf',
    fileSizeBytes: 1024 * 500,
    createdAt: now,
    updatedAt: now,
  );

  Widget buildTestScope({
    required Widget screen,
    required String langCode,
    double textScale = 1.0,
    List<Override> extraOverrides = const [],
  }) {
    final locale = Locale(langCode);
    return ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) => FakeLocaleNotifier(locale)),
        authUserProvider.overrideWithValue(FakeUser()),
        tripControllerProvider.overrideWith(
          (ref) => FakeTripController(TripState(isLoading: false, trips: [testTrip])),
        ),
        checklistControllerProvider.overrideWith(
          (ref) => FakeChecklistNotifier(ChecklistState(isLoading: false, items: [testItem])),
        ),
        vaultControllerProvider.overrideWith(
          (ref) => FakeVaultController(VaultState(isLoading: false, documents: [testDoc])),
        ),
        syncEngineProvider.overrideWith(
          (ref) => FakeSyncEngine(const SyncState(status: SyncStatus.upToDate)),
        ),
        proSubscriptionProvider.overrideWith(
          (ref) => FakeRevenueCatNotifier(const ProSubscriptionState(isPro: true)),
        ),
        packingRemindersProvider.overrideWith(
          (ref) => FakePackingRemindersNotifier(true),
        ),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
      ),
    );
  }

  group('Comprehensive Screen & Window Quality Audit', () {
    // 1. OnboardingScreen across Viewports & Languages
    for (final size in testViewports) {
      testWidgets('1. OnboardingScreen renders at ${size.width}x${size.height} across languages without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        for (final lang in primaryTestLangs) {
          await tester.pumpWidget(
            buildTestScope(
              screen: const OnboardingScreen(isReplay: true),
              langCode: lang,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull, reason: 'OnboardingScreen overflow in $lang at ${size.width}x${size.height}');
          expect(find.byType(OnboardingScreen), findsOneWidget);
        }
      });
    }

    // 2. AuthScreen (Sign-In and Sign-Up) on 320x568
    testWidgets('2. AuthScreen (Sign In & Sign Up) renders cleanly on 320x568 across languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const AuthScreen(),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'AuthScreen SignIn overflow in $lang on 320x568');

        final signUpButton = find.text(AppLocalizations.of(tester.element(find.byType(AuthScreen)))!.authSignUp);
        if (signUpButton.evaluate().isNotEmpty) {
          await tester.tap(signUpButton.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          final err = tester.takeException();
          if (err != null) {
            for (final ro in tester.allRenderObjects) {
              if (ro.toString().contains('OVERFLOWING')) {
                debugPrint('FOUND OVERFLOWING IN AuthScreen SignUp:\n${ro.toStringDeep()}');
              }
            }
          }
          expect(err, isNull, reason: 'AuthScreen SignUp overflow in $lang on 320x568');
        }
      }
    });

    // 3. EmailVerificationScreen
    testWidgets('3. EmailVerificationScreen renders cleanly on 320x568 across languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const EmailVerificationScreen(),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'EmailVerificationScreen overflow in $lang on 320x568');
      }
    });

    // 4. BannedScreen (Temporary and Permanent Ban)
    testWidgets('4. BannedScreen renders cleanly on 320x568 across languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final moderation = UserModerationState(
        banStatus: 'temporary',
        banReason: 'Security audit violation detected by admin',
        banExpiresAt: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      );

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: BannedScreen(moderation: moderation),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'BannedScreen overflow in $lang on 320x568');
      }
    });

    // 5. LegalConsentScreen across all 20 languages on 320x568
    testWidgets('5. LegalConsentScreen renders across all 20 languages on 320x568 without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in all20Languages) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const LegalConsentScreen(isMandatoryGate: true),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'LegalConsentScreen mandatory overflow in $lang on 320x568');
      }
    });

    // 6. DashboardScreen on 320x568
    testWidgets('6. DashboardScreen renders cleanly on 320x568 across languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const DashboardScreen(),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'DashboardScreen overflow in $lang on 320x568');
      }
    });

    // 7. TripsScreen & TripDetailScreen
    testWidgets('7. TripsScreen & TripDetailScreen render cleanly on 320x568 across languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const TripsScreen(),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'TripsScreen overflow in $lang on 320x568');

        // TripDetailScreen
        await tester.pumpWidget(
          buildTestScope(
            screen: TripDetailScreen(trip: testTrip),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'TripDetailScreen overflow in $lang on 320x568');
      }
    });

    // 8. TripComparisonScreen
    testWidgets('8. TripComparisonScreen renders cleanly on 320x568 across languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const TripComparisonScreen(),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'TripComparisonScreen overflow in $lang on 320x568');
      }
    });

    // 9. ChecklistScreen
    testWidgets('9. ChecklistScreen renders cleanly on 320x568 across languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const ChecklistScreen(),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'ChecklistScreen overflow in $lang on 320x568');
      }
    });

    // 10. TravelMapScreen
    testWidgets('10. TravelMapScreen renders cleanly on 320x568 across languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const TravelMapScreen(),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        final err = tester.takeException();
        if (err != null) {
          for (final ro in tester.allRenderObjects) {
            if (ro.toString().contains('OVERFLOWING')) {
              debugPrint('FOUND OVERFLOWING IN TravelMapScreen:\n${ro.toStringDeep()}');
            }
          }
        }
        expect(err, isNull, reason: 'TravelMapScreen overflow in $lang on 320x568');
      }
    });

    // 11. VaultScreen
    testWidgets('11. VaultScreen renders cleanly on 320x568 across languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const VaultScreen(),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'VaultScreen overflow in $lang on 320x568');
      }
    });

    // 12. SettingsScreen with 1.25x Text Scaling
    testWidgets('12. SettingsScreen renders cleanly on 320x568 with textScaleFactor 1.25 across languages', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const SettingsScreen(),
            langCode: lang,
            textScale: 1.25,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'SettingsScreen text scale overflow in $lang on 320x568');
      }
    });

    // 13. FeedbackSheet
    testWidgets('13. FeedbackSheet renders on 320x568 without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        await tester.pumpWidget(
          buildTestScope(
            screen: const Scaffold(body: FeedbackSheet()),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'FeedbackSheet overflow in $lang on 320x568');
      }
    });

    // 14. EmergencyGuideSheet & AirlineGuideSheet
    testWidgets('14. EmergencyGuideSheet & AirlineGuideSheet render on 320x568 without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        // EmergencyGuideSheet
        await tester.pumpWidget(
          buildTestScope(
            screen: Scaffold(body: EmergencyGuideSheet(trip: testTrip)),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'EmergencyGuideSheet overflow in $lang on 320x568');

        // AirlineGuideSheet
        await tester.pumpWidget(
          buildTestScope(
            screen: const Scaffold(body: AirlineGuideSheet()),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'AirlineGuideSheet overflow in $lang on 320x568');
      }
    });

    // 15. AddTripSheet, AddExpenseSheet, AddPackingItemSheet, AddDocumentSheet & QuickActionsSheet
    testWidgets('15. Modal sheets render on 320x568 without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final lang in primaryTestLangs) {
        // AddTripSheet
        await tester.pumpWidget(
          buildTestScope(
            screen: const Scaffold(body: AddTripSheet()),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'AddTripSheet overflow in $lang on 320x568');

        // AddExpenseSheet
        await tester.pumpWidget(
          buildTestScope(
            screen: const Scaffold(
              body: AddExpenseSheet(
                tripId: 'test-trip-1',
                defaultCurrency: 'EUR',
              ),
            ),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'AddExpenseSheet overflow in $lang on 320x568');

        // AddPackingItemSheet
        await tester.pumpWidget(
          buildTestScope(
            screen: const Scaffold(
              body: AddPackingItemSheet(tripId: 'test-trip-1'),
            ),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'AddPackingItemSheet overflow in $lang on 320x568');

        // AddDocumentSheet
        await tester.pumpWidget(
          buildTestScope(
            screen: const Scaffold(
              body: AddDocumentSheet(initialTripId: 'test-trip-1'),
            ),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        final err = tester.takeException();
        if (err != null) {
          for (final ro in tester.allRenderObjects) {
            if (ro.toString().contains('OVERFLOWING')) {
              debugPrint('FOUND OVERFLOWING IN AddDocumentSheet:\n${ro.toStringDeep()}');
            }
          }
        }
        expect(err, isNull, reason: 'AddDocumentSheet overflow in $lang on 320x568');

        // QuickActionsSheet
        await tester.pumpWidget(
          buildTestScope(
            screen: Scaffold(
              body: QuickActionsSheet(
                title: 'Quick Actions',
                items: [
                  QuickActionItem(
                    icon: Icons.flight_takeoff_rounded,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue.withValues(alpha: 0.1),
                    title: 'New Trip',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            langCode: lang,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'QuickActionsSheet overflow in $lang on 320x568');
      }
    });
  });
}
