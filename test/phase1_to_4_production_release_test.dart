import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/theme/theme_provider.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/checklist/domain/canonical_packing_catalog.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/domain/airline_baggage_guide.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

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
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = true,
    this.providerData = const [],
  });
}

class FakeCurrencyNotifier extends StateNotifier<String> implements CurrencyNotifier {
  FakeCurrencyNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthController extends StateNotifier<AuthState> implements AuthController {
  FakeAuthController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PHASE 1: Subscriptions Pricing, Store Billing Protection & Admin Sandbox', () {
    testWidgets('PaywallSheet displays affordable localized pricing across currencies (USD, TRY, EUR, GBP, JPY)', (tester) async {
      // 1. USD Currency
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            currencyProvider.overrideWith((ref) => FakeCurrencyNotifier('USD')),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(body: PaywallSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('\$0.99 / mo'), findsOneWidget);
      expect(find.text('\$4.99 / yr'), findsOneWidget);
      expect(find.text('Save 58%'), findsOneWidget);

      // 2. TRY Currency
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            currencyProvider.overrideWith((ref) => FakeCurrencyNotifier('TRY')),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(body: PaywallSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₺29,99 / ay'), findsOneWidget);
      expect(find.text('₺149,99 / yıl'), findsOneWidget);
      expect(find.text('%58 Tasarruf'), findsOneWidget);

      // 3. EUR Currency
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            currencyProvider.overrideWith((ref) => FakeCurrencyNotifier('EUR')),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('de'),
            home: Scaffold(body: PaywallSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('€0,99 / Monat'), findsOneWidget);
      expect(find.text('€4,99 / Jahr'), findsOneWidget);
      expect(find.text('58% Sparen'), findsOneWidget);

      // 4. GBP Currency
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            currencyProvider.overrideWith((ref) => FakeCurrencyNotifier('GBP')),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(body: PaywallSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('£0.89 / mo'), findsOneWidget);
      expect(find.text('£4.49 / yr'), findsOneWidget);

      // 5. JPY Currency
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            currencyProvider.overrideWith((ref) => FakeCurrencyNotifier('JPY')),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('ja'),
            home: Scaffold(body: PaywallSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('¥150 /月'), findsOneWidget);
      expect(find.text('¥750 /年'), findsOneWidget);
    });

    testWidgets('Normal regular user cannot bypass billing; shows store billing required dialog and isPro remains false', (tester) async {
      final regularUser = FakeUser(uid: 'regular_user_1', email: 'regular@example.com');
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(
            (ref) => FakeAuthController(
              AuthState(
                user: regularUser,
                isInitialized: true,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(body: PaywallSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure user is not Pro initially
      expect(container.read(proSubscriptionProvider).isPro, isFalse);

      // Tap Subscribe Now
      final subscribeBtn = find.text('Continue with Pro');
      expect(subscribeBtn, findsOneWidget);
      await tester.tap(subscribeBtn);
      await tester.pumpAndSettle();

      // Store billing required dialog is displayed
      expect(find.text('Store Billing Required'), findsOneWidget);
      expect(find.textContaining('Official Google Play & App Store billing'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Crucial: isPro MUST remain false!
      expect(container.read(proSubscriptionProvider).isPro, isFalse);
    });

    testWidgets('Super Admin shows Admin / Sandbox Test Purchase Confirmation dialog and activates Pro on confirmation', (tester) async {
      final adminUser = FakeUser(uid: 'admin_123', email: kAdminEmail);
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(
            (ref) => FakeAuthController(
              AuthState(
                user: adminUser,
                isInitialized: true,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Ensure Pro is reset first
      await container.read(proSubscriptionProvider.notifier).resetProStatus();
      expect(container.read(proSubscriptionProvider).isPro, isFalse);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(body: PaywallSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Subscribe
      final subscribeBtn = find.text('Continue with Pro');
      await tester.tap(subscribeBtn);
      await tester.pumpAndSettle();

      // Dedicated Admin Confirmation dialog appears
      expect(find.text('Admin / Sandbox Test Purchase'), findsOneWidget);
      expect(find.textContaining('You are signed in as Super Admin'), findsOneWidget);

      // Confirm purchase
      await tester.tap(find.text('Activate Pro (Test)'));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Pro is successfully activated for Super Admin!
      expect(container.read(proSubscriptionProvider).isPro, isTrue);
    });

    test('MockRevenueCatNotifier rejects unauthenticated purchases when testPurchases flag is false', () async {
      final prevFlag = MockRevenueCatNotifier.enableTestPurchasesForUnitTests;
      try {
        MockRevenueCatNotifier.enableTestPurchasesForUnitTests = false;
        MockRevenueCatNotifier.isStoreBillingConfigured = false;

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(proSubscriptionProvider.notifier);
        final success = await notifier.purchaseActivePlan(isTestOrAdminConfirmation: false);

        expect(success, isFalse);
        expect(container.read(proSubscriptionProvider).errorMessage, contains('Store billing products'));
      } finally {
        MockRevenueCatNotifier.enableTestPurchasesForUnitTests = prevFlag;
      }
    });
  });

  group('PHASE 2: Canonical Catalog, Deterministic IDs & Dynamic Item Localization', () {
    test('CanonicalPackingCatalog normalizes strings and resolves canonical keys across languages', () {
      // English & Turkish variations
      expect(CanonicalPackingCatalog.resolveCanonicalKey('Passport, Visa & Flight Tickets'), 'passport');
      expect(CanonicalPackingCatalog.resolveCanonicalKey('Pasaport, Vize & Uçuş Biletleri'), 'passport');
      expect(CanonicalPackingCatalog.resolveCanonicalKey('Reisepass, Visum & Flugtickets'), 'passport');

      expect(CanonicalPackingCatalog.resolveCanonicalKey('Noise-Cancelling Headphones & Case'), 'headphones');
      expect(CanonicalPackingCatalog.resolveCanonicalKey('Gürültü Engelleyici Kulaklık & Kılıfı'), 'headphones');

      expect(CanonicalPackingCatalog.resolveCanonicalKey('Universal Travel Adapter & Fast Charger'), 'charger');
      expect(CanonicalPackingCatalog.resolveCanonicalKey('Evrensel Seyahat Prizi & Hızlı Şarj Cihazı'), 'charger');

      expect(CanonicalPackingCatalog.resolveCanonicalKey('Seyahat Boy Diş Fırçası & Macunu'), 'toothbrush');
      expect(CanonicalPackingCatalog.resolveCanonicalKey('Travel Toothbrush & Toothpaste'), 'toothbrush');

      // Unrecognized custom items return null
      expect(CanonicalPackingCatalog.resolveCanonicalKey('My Custom Fender Guitar 1968'), isNull);
    });

    test('Deterministic ID generation produces consistent IDs preventing duplicates', () {
      final id1 = CanonicalPackingCatalog.generateDeterministicId(
        prefix: 'default',
        userId: 'user_456',
        canonicalKey: 'passport',
      );
      final id2 = CanonicalPackingCatalog.generateDeterministicId(
        prefix: 'default',
        userId: 'user_456',
        canonicalKey: 'passport',
      );
      expect(id1, equals(id2));
      expect(id1, equals('default_user_456_passport'));

      final tplId = CanonicalPackingCatalog.generateDeterministicId(
        prefix: 'tpl_summer',
        userId: 'user_789',
        canonicalKey: 'swimwear',
        tripId: 'trip_1',
      );
      expect(tplId, equals('tpl_summer_user_789_trip_1_swimwear'));
    });

    testWidgets('Switching locale from tr to en and de dynamically translates seeded checklist items in ChecklistScreen', (tester) async {
      final seededPassport = PackingItem(
        id: 'default_u1_passport',
        name: 'Pasaport, Vize & Uçuş Biletleri', // Stored in DB originally in Turkish
        category: 'Belgeler',
        quantity: 1,
        isPacked: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final seededHeadphones = PackingItem(
        id: 'default_u1_headphones',
        name: 'Noise-Cancelling Headphones & Case', // Stored in DB originally in English
        category: 'Elektronik',
        quantity: 1,
        isPacked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final customUserItem = PackingItem(
        id: 'custom_guitar',
        name: 'Custom Acoustic Guitar', // Custom item
        category: 'Aksesuar',
        quantity: 1,
        isPacked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Widget createWidget(Locale locale) {
        return ProviderScope(
          key: UniqueKey(),
          overrides: [
            checklistControllerProvider.overrideWith(
              (ref) => ChecklistNotifier(
                null,
                ChecklistState(
                  isLoading: false,
                  items: [seededPassport, seededHeadphones, customUserItem],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: const ChecklistScreen(),
          ),
        );
      }

      // 1. In Turkish (tr)
      await tester.pumpWidget(createWidget(const Locale('tr')));
      await tester.pumpAndSettle();

      expect(find.text('Pasaport, Vize & Uçuş Biletleri'), findsOneWidget);
      expect(find.text('Gürültü Engelleyici Kulaklık & Kılıfı'), findsOneWidget);
      expect(find.text('Custom Acoustic Guitar'), findsOneWidget);

      // 2. Switch to English (en)
      await tester.pumpWidget(createWidget(const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Passport, Visa & Flight Tickets'), findsOneWidget);
      expect(find.text('Noise-Cancelling Headphones & Case'), findsOneWidget);
      expect(find.text('Custom Acoustic Guitar'), findsOneWidget);

      // 3. Switch to German (de)
      await tester.pumpWidget(createWidget(const Locale('de')));
      await tester.pumpAndSettle();

      expect(find.text('Reisepass, Visum & Flugtickets'), findsOneWidget);
      expect(find.text('Noise-Cancelling-Kopfhörer & Etui'), findsOneWidget);
      expect(find.text('Custom Acoustic Guitar'), findsOneWidget);
    });

    test('AirlineBaggageRule notes dynamically localize based on language code', () {
      final tk = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'TK');
      expect(tk.getLocalizedNotes('tr'), contains('1 adet 8 kg kabin bagajı'));
      expect(tk.getLocalizedNotes('en'), contains('1 cabin bag (8 kg)'));
      expect(tk.getLocalizedNotes('de'), contains('1 Handgepäck (8 kg)'));
      expect(tk.getLocalizedNotes('zh'), contains('1 cabin bag (8 kg)'));

      final fr = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'FR');
      expect(fr.getLocalizedNotes('tr'), contains('Standart bilette'));
      expect(fr.getLocalizedNotes('en'), contains('Standard ticket'));
    });
  });

  group('PHASE 3: Settings Theme Selector UI Polish & Compact Viewport Testing', () {
    testWidgets('SettingsScreen Theme Selector renders System Default cleanly on 320x568 screen with 1.15x text scale with 0 overflows', (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Render in Russian (long words) with 1.15x text scaling
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(1.15),
            ),
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('ru'),
              home: SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No RenderFlex overflow
      expect(tester.takeException(), isNull);

      // All 3 theme mode buttons are present
      expect(find.byIcon(Icons.brightness_auto_rounded), findsOneWidget);
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

      // Verify tapping Dark mode updates themeModeProvider
      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      // Verify tapping Light mode updates themeModeProvider
      await tester.tap(find.byIcon(Icons.light_mode_rounded));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.light);

      // Verify tapping System mode updates themeModeProvider
      await tester.tap(find.byIcon(Icons.brightness_auto_rounded));
      await tester.pumpAndSettle();
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    testWidgets('SettingsScreen Theme Selector renders cleanly in Turkish and German with 1.15x text scale', (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(1.15),
            ),
            child: const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('tr'),
              home: SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Sistem Varsayılanı'), findsOneWidget);
    });
  });
}
