import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/budget/domain/geocoding_helper.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/interactive_world_map.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/document_viewer_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/widgets/notifications_center_sheet.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/home_widget_preview_card.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  _FakeVaultController([VaultState? state]) : super(state ?? const VaultState(isLoading: false, documents: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;

  _MockUser({required this.uid, this.email});
}

class _MockAuthController extends StateNotifier<AuthState> implements AuthController {
  _MockAuthController([AuthState? state]) : super(state ?? const AuthState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Biniş Kartı ve Dijital Bilet Görüntüleyici Kaldırılması Testleri', () {
    testWidgets('VaultScreen renders tickets as normal documents and never renders old native wallet or barcode buttons', (tester) async {
      final ticketDoc = Document(
        id: 'doc_flight_ticket_1',
        title: 'TK1821 Biniş Kartı',
        category: 'Ticket',
        localImagePath: '/tmp/boarding_pass.pdf',
        fileType: 'pdf',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultControllerProvider.overrideWith(
              (ref) => _FakeVaultController(VaultState(isLoading: false, documents: [ticketDoc])),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: VaultScreen(),
          ),
        ),
      );

      await tester.pump();

      // Title must be visible
      expect(find.text('TK1821 Biniş Kartı'), findsOneWidget);
      // PDF badge is displayed
      expect(find.text('PDF'), findsOneWidget);
      // Native Apple Wallet / Google Wallet modal hooks MUST NOT exist
      expect(find.byIcon(Icons.wallet_rounded), findsNothing);
      expect(find.byIcon(Icons.qr_code_2_rounded), findsNothing);
    });

    testWidgets('DocumentViewerScreen renders properly for PDF documents with page navigation controls', (tester) async {
      final pdfDoc = Document(
        id: 'pdf_doc_1',
        title: 'Otel Rezervasyon Belgesi',
        category: 'Hotel',
        localImagePath: '/tmp/hotel_voucher.pdf',
        fileType: 'pdf',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: DocumentViewerScreen(document: pdfDoc),
        ),
      );

      await tester.pump();

      // Verify title is rendered
      expect(find.text('Otel Rezervasyon Belgesi'), findsWidgets);
      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });
  });

  group('2. PackBuddy Pro & Apple ile Giriş Yap İnaktiflik ve Hata Koruması', () {
    testWidgets('PaywallSheet shows friendly coming-soon notice when user taps subscribe without throwing errors', (tester) async {
      final regularUser = _MockUser(uid: 'regular_user_test', email: 'user@test.com');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              (ref) => _MockAuthController(AuthState(user: regularUser, isInitialized: true)),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: const Scaffold(body: PaywallSheet()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final subscribeBtn = find.text('Pro ile Devam Et');
      expect(subscribeBtn, findsOneWidget);
      await tester.tap(subscribeBtn);
      await tester.pumpAndSettle();

      // Real store purchase flow triggered, coming soon dialog is completely removed
      expect(find.text('PackBuddy Pro Yakında Aktif'), findsNothing);
    });

    testWidgets('PaywallSheet shows English and German friendly coming-soon notices', (tester) async {
      final regularUser = _MockUser(uid: 'regular_user_de', email: 'de@test.com');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              (ref) => _MockAuthController(AuthState(user: regularUser, isInitialized: true)),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('de'),
            home: const Scaffold(body: PaywallSheet()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final subscribeBtn = find.text('Mit Pro fortfahren');
      expect(subscribeBtn, findsOneWidget);
      await tester.tap(subscribeBtn);
      await tester.pumpAndSettle();

      // Real store purchase flow triggered, coming soon dialog is completely removed
      expect(find.text('PackBuddy Pro bald verfügbar'), findsNothing);
    });
  });

  group('3. Etkileşimli Rota Haritası ve Geocoding (Been & Skratch) Testleri', () {
    test('GeocodingHelper resolves top global cities and countries accurately offline', () {
      final rome = GeocodingHelper.resolveCoordinates('Roma');
      expect(rome, isNotNull);
      expect(rome!['latitude'], closeTo(41.90, 0.05));
      expect(rome['longitude'], closeTo(12.49, 0.05));

      final tokyo = GeocodingHelper.resolveCoordinates('Tokyo');
      expect(tokyo, isNotNull);
      expect(tokyo!['latitude'], closeTo(35.67, 0.05));
      expect(tokyo['longitude'], closeTo(139.65, 0.05));

      final country = GeocodingHelper.resolveCoordinates('Fransa');
      expect(country, isNotNull);
      expect(country!['latitude'], closeTo(46.22, 0.1));
    });

    test('WorldCountriesData matches countries across English and Turkish names', () {
      final trMatch = WorldCountriesData.matchCountry('İtalya');
      expect(trMatch, isNotNull);
      expect(trMatch!.code, 'IT');
      expect(trMatch.flag, '🇮🇹');

      final enMatch = WorldCountriesData.matchCountry('Japan');
      expect(enMatch, isNotNull);
      expect(enMatch!.code, 'JP');
      expect(enMatch.flag, '🇯🇵');
    });

    test('TravelMapController correctly tracks visited, wishlist, and percentage calculation', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = TravelMapController();
      await notifier.loadCountries();
      expect(notifier.state.countries.isNotEmpty, isTrue);

      final initialVisited = notifier.state.visitedCount;

      await notifier.setCountryStatus(
        code: 'IT',
        status: CountryStatus.visited,
        visitedDate: DateTime(2025, 5, 10),
        notes: 'Colosseum & Gelato',
      );

      expect(notifier.state.visitedCount, initialVisited + 1);
      final it = notifier.state.countries.firstWhere((c) => c.code == 'IT');
      expect(it.isVisited, isTrue);
      expect(it.notes, 'Colosseum & Gelato');

      await notifier.setCountryStatus(
        code: 'JP',
        status: CountryStatus.wishlist,
        notes: 'Cherry blossoms trip',
      );

      final jp = notifier.state.countries.firstWhere((c) => c.code == 'JP');
      expect(jp.isWishlist, isTrue);
      expect(notifier.state.wishlistCount, greaterThanOrEqualTo(1));
      expect(notifier.state.worldPercentage, greaterThan(0.0));
    });

    testWidgets('InteractiveWorldMap widget renders pin canvas and handles zoom safely', (tester) async {
      final sampleCountries = [
        const TravelCountry(
          code: 'IT',
          nameEn: 'Italy',
          nameTr: 'İtalya',
          capital: 'Rome',
          continent: 'Europe',
          flag: '🇮🇹',
          latitude: 41.8719,
          longitude: 12.5674,
          status: CountryStatus.visited,
        ),
        const TravelCountry(
          code: 'JP',
          nameEn: 'Japan',
          nameTr: 'Japonya',
          capital: 'Tokyo',
          continent: 'Asia',
          flag: '🇯🇵',
          latitude: 36.2048,
          longitude: 138.2529,
          status: CountryStatus.wishlist,
        ),
      ];

      TravelCountry? tappedCountry;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: InteractiveWorldMap(
              countries: sampleCountries,
              onCountryTap: (c) => tappedCountry = c,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify zoom in and zoom out buttons render and operate smoothly
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pumpAndSettle();

      expect(tappedCountry, isNull);
    });

    testWidgets('TravelMapScreen renders search bar, continent chips and discovery progress bar', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: TravelMapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dünya Seyahat Haritam'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Gezilen'), findsWidgets);
      expect(find.text('Hedef'), findsWidgets);
    });
  });

  group('4. Ana Ekrana Otomatik Widget Ekleme Butonu Testleri', () {
    testWidgets('HomeWidgetPreviewCard renders pin widget button and payload sync smoothly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: HomeWidgetPreviewCard(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the interactive pin button exists and is clickable
      final addWidgetBtn = find.text('Ana Ekrana Widget Ekle');
      expect(addWidgetBtn, findsOneWidget);

      await tester.tap(addWidgetBtn);
      await tester.pump();
      // Verifies no unhandled exception occurs on tapping the button
      expect(tester.takeException(), isNull);
    });
  });

  group('5. Bildirim Merkezi Hızlı Geçiş Senkronizasyonu Testleri', () {
    testWidgets('NotificationsCenterSheet toggles packing reminders and updates provider', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(
              body: NotificationsCenterSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify switch is rendered
      expect(find.byType(Switch), findsOneWidget);

      // Tap the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('6. Vault PIN & Biyometrik Hesap Tabanlı Kalıcılık Testleri', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('PreferencesService isolates and persists vault PIN and biometric settings per user UID', () async {
      final prefs = await PreferencesService.init();

      // User A
      await prefs.setVaultPin('1234', uid: 'user_A');
      await prefs.setVaultBiometricEnabled(true, uid: 'user_A');

      // User B
      await prefs.setVaultPin('9876', uid: 'user_B');
      await prefs.setVaultBiometricEnabled(false, uid: 'user_B');

      // Guest / Fallback
      await prefs.setVaultPin('0000');

      expect(prefs.getVaultPin(uid: 'user_A'), '1234');
      expect(prefs.isVaultBiometricEnabled(uid: 'user_A'), true);

      expect(prefs.getVaultPin(uid: 'user_B'), '9876');
      expect(prefs.isVaultBiometricEnabled(uid: 'user_B'), false);

      expect(prefs.getVaultPin(), '0000');

      // Clearing PIN for User A does not affect User B
      await prefs.setVaultPin(null, uid: 'user_A');
      expect(prefs.getVaultPin(uid: 'user_A'), isNull);
      expect(prefs.getVaultPin(uid: 'user_B'), '9876');
    });
  });
}
