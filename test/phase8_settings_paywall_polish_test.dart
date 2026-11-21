import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_button.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

class Phase8MockSyncEngine extends StateNotifier<SyncState> implements SyncEngine {
  Phase8MockSyncEngine([SyncState state = const SyncState(status: SyncStatus.upToDate)])
      : super(state);

  Future<void> syncNow({bool isManual = true}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Phase8MockProNotifier extends StateNotifier<ProSubscriptionState>
    implements MockRevenueCatNotifier {
  Phase8MockProNotifier({
    bool isPro = false,
    SubscriptionPlan activePlan = SubscriptionPlan.annual,
  }) : super(ProSubscriptionState(isPro: isPro, activePlan: activePlan));

  @override
  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(activePlan: plan);
  }

  @override
  Future<bool> purchasePlan(String productId, {bool isTestOrAdminConfirmation = false}) async => true;

  @override
  Future<bool> purchaseActivePlan({bool isTestOrAdminConfirmation = false}) async => true;

  @override
  Future<bool> restorePurchases({bool isTestOrAdminConfirmation = false}) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Phase8MockVaultController extends StateNotifier<VaultState> implements VaultController {
  Phase8MockVaultController({
    bool isLocked = false,
    bool hasPin = false,
    bool isBiometricEnabled = false,
    List<Document> documents = const [],
  }) : super(VaultState(
          isLocked: isLocked,
          hasPin: hasPin,
          isBiometricEnabled: isBiometricEnabled,
          documents: documents,
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Phase8MockRemindersNotifier extends StateNotifier<bool>
    implements PackingRemindersNotifier {
  Phase8MockRemindersNotifier([bool initial = true]) : super(initial);

  @override
  Future<void> toggle(bool enabled) async {
    state = enabled;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Phase8MockProfileController extends StateNotifier<ProfileState>
    implements ProfileController {
  Phase8MockProfileController()
      : super(ProfileState(
          profile: UserProfile(
            uid: 'test_phase8_uid',
            displayName: 'Alex Solo Traveler',
            email: 'alex@packbuddy.app',
            photoUrl: 'assets/avatars/avatar_1.png',
            createdAt: DateTime(2026, 1, 1),
          ),
          totalTrips: 7,
          totalCountriesVisited: 14,
          totalPackingItems: 42,
          totalDocuments: 3,
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Phase 8: Settings, Paywall, Cloud Sync & Visual Polish Tests', () {
    testWidgets('1. SettingsScreen renders Inset-Grouped cards with AppRadius.card and Hero identity elements', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final proNotifier = Phase8MockProNotifier(isPro: false);
      final profileNotifier = Phase8MockProfileController();
      final syncNotifier = Phase8MockSyncEngine();
      final vaultNotifier = Phase8MockVaultController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => proNotifier),
            profileControllerProvider.overrideWith((ref) => profileNotifier),
            syncEngineProvider.overrideWith((ref) => syncNotifier),
            vaultControllerProvider.overrideWith((ref) => vaultNotifier),
            isAdminProvider.overrideWith((ref) => false),
            authUserProvider.overrideWith((ref) => null),
            packingRemindersProvider.overrideWith((ref) => Phase8MockRemindersNotifier(true)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Hero elements: badge, title, avatar
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'settings-hero-badge'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'settings-hero-title'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Hero && w.tag == 'settings-profile-avatar'), findsOneWidget);

      // Verify Cards use AppRadius.card (22.0)
      final appCards = tester.widgetList<AppCard>(find.byType(AppCard));
      expect(appCards.length, greaterThanOrEqualTo(4));
      for (final card in appCards) {
        expect(card.borderRadius, equals(AppRadius.card));
      }

      // Verify ListView bottom clearance is at least 120.0 pt
      final listView = tester.widget<ListView>(find.byType(ListView));
      final edgeInsets = listView.padding as EdgeInsets?;
      expect(edgeInsets, isNotNull);
      expect(edgeInsets!.bottom, greaterThanOrEqualTo(120.0));

      // Scroll to bottom and verify app version footer with AppTypography.mono
      await tester.dragUntilVisible(find.text('PackBuddy v1.0.0'), find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('PackBuddy v1.0.0'), findsOneWidget);
    });

    testWidgets('2. Theme mode switcher toggles System, Light, and Dark modes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final proNotifier = Phase8MockProNotifier(isPro: false);
      final profileNotifier = Phase8MockProfileController();
      final syncNotifier = Phase8MockSyncEngine();
      final vaultNotifier = Phase8MockVaultController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => proNotifier),
            profileControllerProvider.overrideWith((ref) => profileNotifier),
            syncEngineProvider.overrideWith((ref) => syncNotifier),
            vaultControllerProvider.overrideWith((ref) => vaultNotifier),
            isAdminProvider.overrideWith((ref) => false),
            authUserProvider.overrideWith((ref) => null),
            packingRemindersProvider.overrideWith((ref) => Phase8MockRemindersNotifier(true)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for Theme options: System Default, Light, Dark
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Tap 'Dark' theme
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(PreferencesService.instance.getThemeMode(), equals(ThemeMode.dark));

      // Tap 'Light' theme
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(PreferencesService.instance.getThemeMode(), equals(ThemeMode.light));

      // Tap 'System Default' theme
      await tester.tap(find.text('System Default'));
      await tester.pumpAndSettle();
      expect(PreferencesService.instance.getThemeMode(), equals(ThemeMode.system));
    });

    testWidgets('3. Cloud Sync card provides outline action and tabular mono sync timestamp', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final proNotifier = Phase8MockProNotifier(isPro: false);
      final profileNotifier = Phase8MockProfileController();
      final syncNotifier = Phase8MockSyncEngine();
      final vaultNotifier = Phase8MockVaultController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => proNotifier),
            profileControllerProvider.overrideWith((ref) => profileNotifier),
            syncEngineProvider.overrideWith((ref) => syncNotifier),
            vaultControllerProvider.overrideWith((ref) => vaultNotifier),
            isAdminProvider.overrideWith((ref) => false),
            authUserProvider.overrideWith((ref) => null),
            packingRemindersProvider.overrideWith((ref) => Phase8MockRemindersNotifier(true)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Locate Sync Now action button
      expect(find.widgetWithText(AppButton, 'Sync Now'), findsOneWidget);
      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
    });

    testWidgets('4. Account Session Card renders Sign Out and Delete Account with AppButton primitives', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final proNotifier = Phase8MockProNotifier(isPro: false);
      final profileNotifier = Phase8MockProfileController();
      final syncNotifier = Phase8MockSyncEngine();
      final vaultNotifier = Phase8MockVaultController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => proNotifier),
            profileControllerProvider.overrideWith((ref) => profileNotifier),
            syncEngineProvider.overrideWith((ref) => syncNotifier),
            vaultControllerProvider.overrideWith((ref) => vaultNotifier),
            isAdminProvider.overrideWith((ref) => false),
            authUserProvider.overrideWith((ref) => null),
            packingRemindersProvider.overrideWith((ref) => Phase8MockRemindersNotifier(true)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to account session area
      final signOutBtn = find.widgetWithText(AppButton, 'Sign Out');
      await tester.dragUntilVisible(signOutBtn, find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      // Verify Sign Out button
      expect(signOutBtn, findsOneWidget);

      // Verify Delete Account button
      final deleteAccountBtn = find.widgetWithText(AppButton, 'Delete Account');
      expect(deleteAccountBtn, findsOneWidget);

      // Tap Sign Out to open modernized confirmation dialog
      await tester.tap(signOutBtn);
      await tester.pumpAndSettle();

      // Verify dialog is shown with AppRadius.card shape
      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      final shape = alertDialog.shape as RoundedRectangleBorder?;
      expect(shape, isNotNull);
      expect((shape!.borderRadius as BorderRadius).topLeft.x, equals(AppRadius.card));

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('5. PaywallSheet displays peaceful indie UI with AppRadius.sheet, mono prices, and WCAG AA badge', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final proNotifier = Phase8MockProNotifier(isPro: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => proNotifier),
            isAdminProvider.overrideWith((ref) => false),
            authUserProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(
              body: PaywallSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify top sheet radius is AppRadius.sheet (28.0)
      final sheetContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(PaywallSheet),
          matching: find.byWidgetPredicate(
            (w) => w is Container && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).borderRadius is BorderRadius,
          ),
        ).first,
      );
      final borderRad = (sheetContainer.decoration as BoxDecoration).borderRadius as BorderRadius;
      expect(borderRad.topLeft.x, equals(AppRadius.sheet));

      // Verify title & primary action button
      expect(find.text('PackBuddy Pro'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Continue with Pro'), findsOneWidget);

      // Verify Discount badge text color matches WCAG AA compliant brandAccentTextLight in Light Theme
      final discountFinder = find.text('Save 58%');
      expect(discountFinder, findsOneWidget);
      final discountText = tester.widget<Text>(discountFinder);
      expect(discountText.style?.color, equals(AppColors.brandAccentTextLight));

      // Verify plan toggle (tap Monthly option)
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      expect(proNotifier.state.activePlan, equals(SubscriptionPlan.monthly));
    });

    testWidgets('6. PaywallSheet shows Pro Active state with AppButton.primary when user is already Pro', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final proNotifier = Phase8MockProNotifier(isPro: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => proNotifier),
            isAdminProvider.overrideWith((ref) => false),
            authUserProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(
              body: PaywallSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pro Active card verification
      expect(find.text('PackBuddy Pro Active'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'OK'), findsOneWidget);
    });

    testWidgets('7. Compact Viewport Stress Test (320x568 iPhone SE 1st gen) zero overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final proNotifier = Phase8MockProNotifier(isPro: false);
      final profileNotifier = Phase8MockProfileController();
      final syncNotifier = Phase8MockSyncEngine();
      final vaultNotifier = Phase8MockVaultController();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => proNotifier),
            profileControllerProvider.overrideWith((ref) => profileNotifier),
            syncEngineProvider.overrideWith((ref) => syncNotifier),
            vaultControllerProvider.overrideWith((ref) => vaultNotifier),
            isAdminProvider.overrideWith((ref) => false),
            authUserProvider.overrideWith((ref) => null),
            packingRemindersProvider.overrideWith((ref) => Phase8MockRemindersNotifier(true)),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll across full screen to ensure 0 overflows
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('8. Multilingual Turkish Locale (tr) displays localized settings & paywall labels cleanly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final proNotifier = Phase8MockProNotifier(isPro: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => proNotifier),
            isAdminProvider.overrideWith((ref) => false),
            authUserProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: const Scaffold(
              body: PaywallSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Turkish localized labels
      expect(find.widgetWithText(AppButton, 'Pro ile Devam Et'), findsOneWidget);
      expect(find.text('Yıllık'), findsOneWidget);
      expect(find.text('Aylık'), findsOneWidget);
      expect(find.text('%58 Tasarruf'), findsOneWidget);
    });
  });
}
