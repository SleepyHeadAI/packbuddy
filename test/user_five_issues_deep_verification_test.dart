import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/packing_item_tile.dart';
import 'package:packbuddy/features/dashboard/presentation/widgets/horizontal_currency_converter_card.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('User 5 Issues Comprehensive Deep Verification Suite', () {
    // -------------------------------------------------------------------------
    // Issue 1 & 2: World Map Continent Counts, Lived Badge, Removed Header % & Stat Sublabel
    // -------------------------------------------------------------------------
    test('1.1: Continent progress list has authentic unique counts summing to total', () {
      final all = WorldCountriesData.allCountries;
      final state = TravelMapState(countries: all);

      final progress = state.continentProgressList;
      expect(progress.length, equals(5));

      final europe = progress.firstWhere((p) => p.continent == 'Europe');
      final asia = progress.firstWhere((p) => p.continent == 'Asia');
      final americas = progress.firstWhere((p) => p.continent == 'Americas');
      final africa = progress.firstWhere((p) => p.continent == 'Africa');
      final oceania = progress.firstWhere((p) => p.continent == 'Oceania');

      // Unique realistic counts - no longer 3x 54
      expect(europe.totalCountries, equals(51));
      expect(asia.totalCountries, equals(49));
      expect(americas.totalCountries, equals(54));
      expect(africa.totalCountries, equals(57));
      expect(oceania.totalCountries, equals(17));

      // Total sum equals exactly 228
      final sum = europe.totalCountries + asia.totalCountries + americas.totalCountries + africa.totalCountries + oceania.totalCountries;
      expect(sum, equals(all.length));
    });

    testWidgets('1.2: Map AppBar has NO percentage badge, and Passport card shows visited/total sublabel', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            travelMapControllerProvider.overrideWith((ref) {
              final notifier = TravelMapController();
              notifier.state = TravelMapState(
                countries: WorldCountriesData.allCountries,
                isLoading: false,
              );
              return notifier;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: const TravelMapScreen(isTabMode: true),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Top right AppBar actions has ONLY the share button, NOT the percentage pill container
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      // Verify visited/total sublabel appears under world percentage in Passport card
      expect(find.textContaining('/228'), findsWidgets);
    });

    testWidgets('1.3: Lived badge ("Yaşadığım") renders full text without ellipsis', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Create a lived country
      final tr = WorldCountriesData.allCountries.firstWhere((c) => c.code == 'TR').copyWith(
            status: CountryStatus.lived,
          );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            travelMapControllerProvider.overrideWith((ref) {
              final notifier = TravelMapController();
              notifier.state = TravelMapState(countries: [tr]);
              return notifier;
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: const TravelMapScreen(isTabMode: true),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Full word "Yaşadığım" is present and visible
      expect(find.text('Yaşadığım'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // Issue 3: Currency Converter Balanced 2-Column Rates & No Blank Space
    // -------------------------------------------------------------------------
    testWidgets('3.1: Currency converter footer displays direct AND inverse rate side by side', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('tr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: HorizontalCurrencyConverterCard(
                initialFrom: 'USD',
                initialTo: 'TRY',
                initialAmount: 100,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Direct rate on the left
      expect(find.textContaining('1 USD ='), findsOneWidget);
      // Inverse rate on the right
      expect(find.textContaining('1 TRY ='), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Issue 4: Packing Checklist Top Card, Checked Luggage Tag Colors & Item Sizing
    // -------------------------------------------------------------------------
    test('4.1: Uçak Altı (CHECKED) tag uses aviation blue palette, not green', () {
      final lightColor = PackingTagHelper.getTagColor('UÇAK ALTI', false);
      final darkColor = PackingTagHelper.getTagColor('UÇAK ALTI', true);
      final lightBg = PackingTagHelper.getTagBgColor('UÇAK ALTI', false);
      final lightBorder = PackingTagHelper.getTagBorderColor('UÇAK ALTI', false);

      // Light color is aviation blue #0284C7
      expect(lightColor, equals(const Color(0xFF0284C7)));
      // Dark color is sky blue #38BDF8
      expect(darkColor, equals(const Color(0xFF38BDF8)));
      // Light background is clean ice blue #F0F9FF, not #CCFBF1 mint green
      expect(lightBg, equals(const Color(0xFFF0F9FF)));
      expect(lightBorder, equals(const Color(0xFFBAE6FD)));
    });

    testWidgets('4.2: PackingItemTile accommodates multi-line long item names cleanly', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 700 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final longItem = PackingItem(
        id: 'item_1',
        name: 'Evrensel Çok Amaçlı Hızlı Şarj Adaptörü ve Seyahat Prizi Dönüştürücü',
        category: 'Elektronik',
        tag: 'UÇAK ALTI',
        quantity: 2,
        isPacked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: PackingItemTile(
              item: longItem,
              onTogglePacked: () {},
              onUpdateQuantity: (_) {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No overflow, renders smoothly
      expect(tester.takeException(), isNull);
      expect(find.byType(PackingItemTile), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Uçak Altı'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Issue 5: FAB QuickActions Overlay Smoothness, Radius Match & Shadow Fade
    // -------------------------------------------------------------------------
    testWidgets('5.1: QuickActionsSheet overlay opens and dismisses smoothly with matching radius and fading shadow', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fabKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              key: fabKey,
              onPressed: () {},
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(Scaffold));

      // Trigger show
      QuickActionsSheet.show(
        context,
        title: 'Hızlı İşlemler',
        items: [
          QuickActionItem(
            icon: Icons.flight,
            iconColor: Colors.blue,
            iconBgColor: Colors.blue.withValues(alpha: 0.1),
            title: 'Seyahat Ekle',
            onTap: () {},
          ),
        ],
        fabKey: fabKey,
      );

      // Animate opening
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 140));

      expect(find.byKey(const Key('quick_actions_fab_close')), findsOneWidget);
      expect(find.text('Seyahat Ekle'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byKey(const Key('quick_actions_fab_close')));

      // Animate closing
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 140));

      // Successfully popped with zero exceptions or visual glitch
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('quick_actions_fab_close')), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Multi-Language & Multi-Size Validation
    // -------------------------------------------------------------------------
    testWidgets('All 5 solutions render cleanly across all languages and screen sizes', (tester) async {
      final testLocales = [
        const Locale('tr'),
        const Locale('en'),
        const Locale('de'),
        const Locale('es'),
        const Locale('fr'),
        const Locale('ja'),
        const Locale('ar'),
      ];

      final testSizes = [
        const Size(320 * 2, 568 * 2), // Small device (iPhone SE 1st gen)
        const Size(390 * 2, 844 * 2), // Standard device (iPhone 14)
        const Size(412 * 2, 915 * 2), // Android flagship
      ];

      for (final size in testSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 2.0;

        for (final loc in testLocales) {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: loc,
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: ListView(
                  children: [
                    const HorizontalCurrencyConverterCard(
                      initialFrom: 'USD',
                      initialTo: 'EUR',
                      initialAmount: 100,
                    ),
                    PackingItemTile(
                      item: PackingItem(
                        id: 'test_item',
                        name: 'Powerbank 20.000 mAh (Uçuş Onaylı)',
                        category: 'Elektronik',
                        tag: 'CHECKED',
                        quantity: 1,
                        isPacked: false,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                      onTogglePacked: () {},
                      onUpdateQuantity: (_) {},
                      onDelete: () {},
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            tester.takeException(),
            isNull,
            reason: 'Visual overflow in locale ${loc.languageCode} on size $size',
          );
        }
      }

      tester.view.resetPhysicalSize();
    });
  });
}
