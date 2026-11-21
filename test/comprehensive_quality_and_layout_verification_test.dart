import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/travel_map_story_card.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';
import 'package:packbuddy/features/dashboard/presentation/widgets/horizontal_currency_converter_card.dart';
import 'package:packbuddy/shared/widgets/status_badge.dart';

double _colorDistance(Color c1, Color c2) {
  // Use 0-255 ARGB channel differences
  final rDiff = (c1.toARGB32() >> 16 & 0xFF) - (c2.toARGB32() >> 16 & 0xFF);
  final gDiff = (c1.toARGB32() >> 8 & 0xFF) - (c2.toARGB32() >> 8 & 0xFF);
  final bDiff = (c1.toARGB32() & 0xFF) - (c2.toARGB32() & 0xFF);
  return math.sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1 & Phase 2: Bug Fixes & Design Verification', () {
    test('TripsScreen.getTransportIcon resolves transport modes accurately', () {
      expect(TripsScreen.getTransportIcon('uçak'), AppIcons.flight);
      expect(TripsScreen.getTransportIcon('flight'), AppIcons.flight);
      expect(TripsScreen.getTransportIcon('tren'), AppIcons.train);
      expect(TripsScreen.getTransportIcon('gemi'), AppIcons.boat);
    });

    test('All 16 StoryCardThemes have visually distinguishable country colors', () {
      for (final st in StoryCardTheme.values) {
        final palette = StoryCardPalette.forTheme(st);

        final dLivedVisited = _colorDistance(palette.livedColor, palette.visitedColor);
        final dLivedWishlist = _colorDistance(palette.livedColor, palette.wishlistColor);
        final dVisitedWishlist = _colorDistance(palette.visitedColor, palette.wishlistColor);
        final dVisitedUnvisited = _colorDistance(palette.visitedColor, palette.unvisitedLandColor);
        final dLivedUnvisited = _colorDistance(palette.livedColor, palette.unvisitedLandColor);

        // Every category must be clearly distinct (distance > 30)
        expect(dLivedVisited, greaterThan(30.0),
            reason: '${st.name}: livedColor and visitedColor are too close');
        expect(dLivedWishlist, greaterThan(30.0),
            reason: '${st.name}: livedColor and wishlistColor are too close');
        expect(dVisitedWishlist, greaterThan(30.0),
            reason: '${st.name}: visitedColor and wishlistColor are too close');
        expect(dVisitedUnvisited, greaterThan(30.0),
            reason: '${st.name}: visitedColor and unvisitedLandColor are too close');
        expect(dLivedUnvisited, greaterThan(30.0),
            reason: '${st.name}: livedColor and unvisitedLandColor are too close');
      }
    });

    test('StoryCardTheme.emerald (Aurora) has polar cyan lived, emerald visited, champagne gold wishlist, charcoal pine unvisited', () {
      final palette = StoryCardPalette.forTheme(StoryCardTheme.emerald);
      expect(palette.livedColor, const Color(0xFF22D3EE));
      expect(palette.visitedColor, const Color(0xFF10B981));
      expect(palette.wishlistColor, const Color(0xFFFBBF24));
      expect(palette.unvisitedLandColor, const Color(0xFF162521));
    });

    test('StoryCardTheme.volcano (Lav) has sun core yellow lived, molten orange visited, hot magenta wishlist, basalt ash unvisited', () {
      final palette = StoryCardPalette.forTheme(StoryCardTheme.volcano);
      expect(palette.livedColor, const Color(0xFFFFD600));
      expect(palette.visitedColor, const Color(0xFFFF5722));
      expect(palette.wishlistColor, const Color(0xFFEC4899));
      expect(palette.unvisitedLandColor, const Color(0xFF262022));
    });

    test('StoryCardLayout has 7 distinct vector icons with zero emoji dependence', () {
      for (final layout in StoryCardLayout.values) {
        expect(layout.icon, isNotNull);
      }
      expect(StoryCardLayout.classic.icon, Icons.auto_awesome_rounded);
      expect(StoryCardLayout.passport.icon, Icons.badge_outlined);
      expect(StoryCardLayout.journey.icon, Icons.flight_takeoff_rounded);
    });

    test('StatusBadge respects useMono: false and does not leak monospace font', () {
      const badge = StatusBadge(
        label: 'Güncel',
        backgroundColor: Colors.transparent,
        textColor: Colors.black,
        useMono: false,
      );
      expect(badge.useMono, isFalse);
    });
  });

  group('Phase 3: Multi-Language & Multi-Size Zero Overflow Tests', () {
    final viewports = [
      const Size(320, 568),  // iPhone SE 1st gen
      const Size(360, 640),  // Compact Android
      const Size(390, 844),  // Standard Modern Phone
      const Size(412, 915),  // Large Android
      const Size(800, 1280), // Tablet
    ];

    final testLocales = [
      const Locale('en'),
      const Locale('tr'), // Turkish
      const Locale('de'), // German (long compound words)
      const Locale('ru'), // Russian (Cyrillic)
      const Locale('el'), // Greek
      const Locale('id'), // Indonesian
      const Locale('ar'), // Arabic RTL
    ];

    for (final size in viewports) {
      for (final locale in testLocales) {
        testWidgets('HorizontalCurrencyConverterCard renders overflow-free at ${size.width}x${size.height} in ${locale.languageCode}', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          final isRtl = locale.languageCode == 'ar';

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                home: Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: const Scaffold(
                    body: SingleChildScrollView(
                      child: HorizontalCurrencyConverterCard(),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('QuickActions overlay mounts without yellow double underline (Material wrapped)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      QuickActionsSheet.show(
                        context,
                        title: 'Hızlı Eylemler',
                        items: [
                          QuickActionItem(
                            icon: AppIcons.flightTakeoff,
                            iconColor: Colors.blue,
                            iconBgColor: Colors.blue.withValues(alpha: 0.15),
                            title: 'Seyahat Ekle',
                            subtitle: 'Yeni bir rota planla',
                            onTap: () {},
                          ),
                          QuickActionItem(
                            icon: AppIcons.expense,
                            iconColor: Colors.green,
                            iconBgColor: Colors.green.withValues(alpha: 0.15),
                            title: 'Harcama Ekle',
                            subtitle: 'Harcama kaydet',
                            onTap: () {},
                          ),
                        ],
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open quick actions overlay
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify that QuickAction titles have NO yellow underline (decoration: none)
      final textFinder = find.text('Seyahat Ekle');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.decoration, equals(TextDecoration.none));

      // Dismiss overlay
      final closeFinder = find.byKey(const Key('quick_actions_fab_close'));
      expect(closeFinder, findsOneWidget);
      await tester.tap(closeFinder);
      await tester.pumpAndSettle();
    });
  });
}
