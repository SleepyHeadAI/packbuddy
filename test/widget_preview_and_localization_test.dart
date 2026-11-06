import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/services/app_widget_localization.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/home_widget_preview_card.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  group('AppWidgetLocalization Tests', () {
    test('All 20 languages return non-empty headers, subtitles, and labels', () {
      final languages = AppWidgetLocalization.supportedLanguages;
      expect(languages.length, 20);

      for (final lang in languages) {
        expect(AppWidgetLocalization.getHeaderSubtitle(lang).isNotEmpty, isTrue,
            reason: 'Subtitle empty for $lang');
        expect(AppWidgetLocalization.getAutoModeLabel(lang).isNotEmpty, isTrue,
            reason: 'Auto mode label empty for $lang');
        expect(AppWidgetLocalization.getTripModeLabel(lang).isNotEmpty, isTrue,
            reason: 'Trip mode label empty for $lang');
        expect(AppWidgetLocalization.getWorldMapModeLabel(lang).isNotEmpty, isTrue,
            reason: 'World map mode label empty for $lang');
        expect(AppWidgetLocalization.getWorldHeader(lang).isNotEmpty, isTrue,
            reason: 'World header empty for $lang');
        expect(AppWidgetLocalization.getTripHeader(lang).isNotEmpty, isTrue,
            reason: 'Trip header empty for $lang');
        expect(AppWidgetLocalization.getVisitedTitle(lang, 28).isNotEmpty, isTrue,
            reason: 'Visited title empty for $lang');
        expect(AppWidgetLocalization.getContinentsSubtitle(lang, 2).isNotEmpty, isTrue,
            reason: 'Continents subtitle empty for $lang');
        expect(AppWidgetLocalization.getExplorationRateLabel(lang).isNotEmpty, isTrue,
            reason: 'Exploration rate empty for $lang');
        expect(AppWidgetLocalization.getVisitedStatLabel(lang, 28).isNotEmpty, isTrue,
            reason: 'Visited stat empty for $lang');
        expect(AppWidgetLocalization.getWishlistStatLabel(lang, 5).isNotEmpty, isTrue,
            reason: 'Wishlist stat empty for $lang');
        expect(AppWidgetLocalization.getContinentsStatLabel(lang, 2).isNotEmpty, isTrue,
            reason: 'Continents stat empty for $lang');
        expect(AppWidgetLocalization.getLegendLived(lang).isNotEmpty, isTrue,
            reason: 'Legend lived empty for $lang');
        expect(AppWidgetLocalization.getLegendVisited(lang).isNotEmpty, isTrue,
            reason: 'Legend visited empty for $lang');
        expect(AppWidgetLocalization.getLegendWishlist(lang).isNotEmpty, isTrue,
            reason: 'Legend wishlist empty for $lang');
        expect(AppWidgetLocalization.formatDaysUntil(lang, 14).isNotEmpty, isTrue,
            reason: 'Days until empty for $lang');
        expect(AppWidgetLocalization.getDefaultDestination(lang).isNotEmpty, isTrue,
            reason: 'Default destination empty for $lang');
        expect(AppWidgetLocalization.getThemeSectionTitle(lang).isNotEmpty, isTrue,
            reason: 'Theme section title empty for $lang');
        expect(AppWidgetLocalization.getDarkThemesCategory(lang).isNotEmpty, isTrue,
            reason: 'Dark themes category empty for $lang');
        expect(AppWidgetLocalization.getLightThemesCategory(lang).isNotEmpty, isTrue,
            reason: 'Light themes category empty for $lang');
        for (final themeKey in const [
          'midnight',
          'sunset',
          'emerald',
          'cyberpunk',
          'volcano',
          'nordicForest',
          'goldenHour',
          'galaxy',
          'monochromeDark',
          'minimalLight',
          'sandLight',
          'oceanLight',
          'cherryBlossom',
          'vintageSepia',
          'matcha',
          'pastelDream',
          'ocean',
          'light',
        ]) {
          expect(AppWidgetLocalization.getThemeName(lang, themeKey).isNotEmpty, isTrue,
              reason: 'Theme name empty for $lang, theme $themeKey');
        }
      }
    });

    test('English language does not return Turkish strings', () {
      expect(AppWidgetLocalization.getWorldHeader('en'), 'PackBuddy • World');
      expect(AppWidgetLocalization.getVisitedTitle('en', 28), '28 Countries Visited');
      expect(AppWidgetLocalization.getVisitedTitle('en', 1), '1 Country Visited');
      expect(AppWidgetLocalization.getContinentsSubtitle('en', 2), '2 Continents Explored');
      expect(AppWidgetLocalization.getContinentsSubtitle('en', 1), '1 Continent Explored');
      expect(AppWidgetLocalization.getContinentsStatLabel('en', 1), '🌍 1 Continent');
      expect(AppWidgetLocalization.getExplorationRateLabel('en'), 'Exploration Rate');
      expect(AppWidgetLocalization.getVisitedStatLabel('en', 28), '✈️ 28 Visited');
      expect(AppWidgetLocalization.getWishlistStatLabel('en', 0), '🌟 0 Wishlist');
      expect(AppWidgetLocalization.getLegendVisited('en'), 'Visited');
      expect(AppWidgetLocalization.getThemeSectionTitle('en'), 'Widget Theme & Colors');
      expect(AppWidgetLocalization.getDarkThemesCategory('en'), 'Dark');
      expect(AppWidgetLocalization.getLightThemesCategory('en'), 'Light');
      expect(AppWidgetLocalization.getThemeName('en', 'midnight'), 'Midnight Navy');
      expect(AppWidgetLocalization.getThemeName('en', 'sunset'), 'Sunset Amber');
      expect(AppWidgetLocalization.getThemeName('en', 'emerald'), 'Aurora');
      expect(AppWidgetLocalization.getThemeName('en', 'cyberpunk'), 'Cyberpunk');
      expect(AppWidgetLocalization.getThemeName('en', 'minimalLight'), 'Nordic');
      expect(AppWidgetLocalization.getThemeName('en', 'oceanLight'), 'Mediterranean');
      expect(AppWidgetLocalization.getThemeName('en', 'ocean'), 'Deep Ocean');
      expect(AppWidgetLocalization.getThemeName('en', 'light'), 'Clean Light');
    });

    test('Turkish language returns authentic Turkish strings', () {
      expect(AppWidgetLocalization.getWorldHeader('tr'), 'PackBuddy • Dünya');
      expect(AppWidgetLocalization.getVisitedTitle('tr', 28), '28 Ülke Gezildi');
      expect(AppWidgetLocalization.getVisitedTitle('tr', 1), '1 Ülke Gezildi');
      expect(AppWidgetLocalization.getContinentsSubtitle('tr', 2), '2 Kıta Keşfedildi');
      expect(AppWidgetLocalization.getContinentsSubtitle('tr', 1), '1 Kıta Keşfedildi');
      expect(AppWidgetLocalization.getContinentsStatLabel('tr', 1), '🌍 1 Kıta');
      expect(AppWidgetLocalization.getExplorationRateLabel('tr'), 'Keşif Oranı');
      expect(AppWidgetLocalization.getVisitedStatLabel('tr', 28), '✈️ 28 Gezildi');
      expect(AppWidgetLocalization.getWishlistStatLabel('tr', 0), '🌟 0 Hedef');
      expect(AppWidgetLocalization.getLegendVisited('tr'), 'Gezildi');
      expect(AppWidgetLocalization.getThemeSectionTitle('tr'), 'Widget Teması & Renkleri');
      expect(AppWidgetLocalization.getDarkThemesCategory('tr'), 'Karanlık');
      expect(AppWidgetLocalization.getLightThemesCategory('tr'), 'Aydınlık');
      expect(AppWidgetLocalization.getThemeName('tr', 'midnight'), 'Gece Mavisi');
      expect(AppWidgetLocalization.getThemeName('tr', 'sunset'), 'Sıcak Günbatımı');
      expect(AppWidgetLocalization.getThemeName('tr', 'emerald'), 'Aurora');
      expect(AppWidgetLocalization.getThemeName('tr', 'cyberpunk'), 'Siber');
      expect(AppWidgetLocalization.getThemeName('tr', 'minimalLight'), 'İskandinav');
      expect(AppWidgetLocalization.getThemeName('tr', 'oceanLight'), 'Akdeniz');
      expect(AppWidgetLocalization.getThemeName('tr', 'ocean'), 'Derin Okyanus');
      expect(AppWidgetLocalization.getThemeName('tr', 'light'), 'Açık Minimal');
    });

    test('All 20 languages singular and plural values are validated', () {
      for (final lang in AppWidgetLocalization.supportedLanguages) {
        // Singular vs plural check
        final singleCountry = AppWidgetLocalization.getVisitedTitle(lang, 1);
        final multiCountries = AppWidgetLocalization.getVisitedTitle(lang, 10);
        expect(singleCountry.isNotEmpty, isTrue);
        expect(multiCountries.isNotEmpty, isTrue);

        final singleCont = AppWidgetLocalization.getContinentsSubtitle(lang, 1);
        final multiCont = AppWidgetLocalization.getContinentsSubtitle(lang, 3);
        expect(singleCont.isNotEmpty, isTrue);
        expect(multiCont.isNotEmpty, isTrue);

        final singleStat = AppWidgetLocalization.getContinentsStatLabel(lang, 1);
        final multiStat = AppWidgetLocalization.getContinentsStatLabel(lang, 4);
        expect(singleStat.isNotEmpty, isTrue);
        expect(multiStat.isNotEmpty, isTrue);

        // Days until formatting
        expect(AppWidgetLocalization.formatDaysUntil(lang, 5).isNotEmpty, isTrue);
        expect(AppWidgetLocalization.formatDaysUntil(lang, 0).isNotEmpty, isTrue);
        expect(AppWidgetLocalization.formatDaysUntil(lang, -1).isNotEmpty, isTrue);
      }
    });

    testWidgets('HomeWidgetPreviewCard tests all 3 sizes, categories, and themes in English', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: HomeWidgetPreviewCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Check Initial State
      expect(find.byType(HomeWidgetPreviewCard), findsOneWidget);

      // 2. Test Size Switching (Small, Medium, Large)
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();

      // 3. Test Dark / Light Categories
      final darkCategoryText = '🌙 ${AppWidgetLocalization.getDarkThemesCategory('en')} (9)';
      final lightCategoryText = '☀️ ${AppWidgetLocalization.getLightThemesCategory('en')} (7)';

      expect(find.text(darkCategoryText), findsOneWidget);
      expect(find.text(lightCategoryText), findsOneWidget);

      // Switch to Light Category
      await tester.tap(find.text(lightCategoryText));
      await tester.pumpAndSettle();

      // Verify a light theme exists in view (e.g. Nordic / Minimal)
      expect(find.textContaining('Nordic'), findsWidgets);

      // Switch back to Dark Category
      await tester.tap(find.text(darkCategoryText));
      await tester.pumpAndSettle();

      // Verify a dark theme exists in view (e.g. Midnight)
      expect(find.textContaining('Midnight'), findsWidgets);
    });

    testWidgets('HomeWidgetPreviewCard tests Turkish localization and mode switching', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: HomeWidgetPreviewCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeWidgetPreviewCard), findsOneWidget);

      final darkCategoryTr = '🌙 ${AppWidgetLocalization.getDarkThemesCategory('tr')} (9)';
      final lightCategoryTr = '☀️ ${AppWidgetLocalization.getLightThemesCategory('tr')} (7)';

      expect(find.text(darkCategoryTr), findsOneWidget);
      expect(find.text(lightCategoryTr), findsOneWidget);

      // Switch to Light
      await tester.tap(find.text(lightCategoryTr));
      await tester.pumpAndSettle();

      expect(find.textContaining('İskandinav'), findsWidgets);

      // Switch to Small and Large in Turkish via icon finding
      await tester.tap(find.byIcon(Icons.crop_square_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.aspect_ratio_rounded));
      await tester.pumpAndSettle();
    });

    testWidgets('HomeWidgetPreviewCard renders cleanly across all 20 languages without overflow across all 3 sizes', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testLocales = AppWidgetLocalization.supportedLanguages.map((code) => Locale(code)).toList();

      for (final loc in testLocales) {
        SharedPreferences.setMockInitialValues({});
        await PreferencesService.init();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: loc,
              home: const Scaffold(
                body: SingleChildScrollView(
                  child: HomeWidgetPreviewCard(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HomeWidgetPreviewCard), findsOneWidget);

        // Test Medium (default), Small, Large sizes with zero overflow
        await tester.tap(find.byIcon(Icons.crop_square_rounded));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.aspect_ratio_rounded));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.crop_16_9_rounded));
        await tester.pumpAndSettle();
      }
    });

    test('PreferencesService isolates widget themes per mode independently', () async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
      final prefs = PreferencesService.instance;

      // 1. Initial Defaults per mode
      expect(prefs.getWidgetThemeForMode('world_map'), 'midnight');
      expect(prefs.getWidgetThemeForMode('quick_expense'), 'matcha');
      expect(prefs.getWidgetThemeForMode('currency_converter'), 'oceanLight');

      // 2. Change world_map theme to 'volcano'
      await prefs.setWidgetThemeForMode('world_map', 'volcano');
      expect(prefs.getWidgetThemeForMode('world_map'), 'volcano');
      // quick_expense and currency_converter must remain untouched
      expect(prefs.getWidgetThemeForMode('quick_expense'), 'matcha');
      expect(prefs.getWidgetThemeForMode('currency_converter'), 'oceanLight');

      // 3. Change quick_expense theme to 'cyberpunk'
      await prefs.setWidgetThemeForMode('quick_expense', 'cyberpunk');
      expect(prefs.getWidgetThemeForMode('world_map'), 'volcano');
      expect(prefs.getWidgetThemeForMode('quick_expense'), 'cyberpunk');
      expect(prefs.getWidgetThemeForMode('currency_converter'), 'oceanLight');

      // 4. Change currency_converter theme to 'sunset'
      await prefs.setWidgetThemeForMode('currency_converter', 'sunset');
      expect(prefs.getWidgetThemeForMode('world_map'), 'volcano');
      expect(prefs.getWidgetThemeForMode('quick_expense'), 'cyberpunk');
      expect(prefs.getWidgetThemeForMode('currency_converter'), 'sunset');
    });

    test('Widget Layout Sizing Thresholds prevent Small 2x2 from becoming Medium', () {
      // Simulating Android widget sizing logic
      String resolveLayoutSize({
        required String defaultSize, // 'SMALL', 'MEDIUM', 'LARGE'
        required int minWidth,
        required int minHeight,
      }) {
        if (defaultSize == 'SMALL') {
          if (minWidth >= 230 && minHeight >= 210) return 'LARGE';
          if (minWidth >= 230) return 'MEDIUM';
          return 'SMALL';
        } else if (defaultSize == 'MEDIUM') {
          if (minHeight >= 210 && minWidth >= 210) return 'LARGE';
          if (minWidth < 210) return 'SMALL';
          return 'MEDIUM';
        } else {
          if (minWidth < 210 && minHeight < 210) return 'SMALL';
          if (minHeight < 210) return 'MEDIUM';
          return 'LARGE';
        }
      }

      // 1. Small (2x2) widget on standard mobile screens (width 140-195dp, height 140-195dp)
      // MUST ALWAYS resolve to SMALL
      expect(resolveLayoutSize(defaultSize: 'SMALL', minWidth: 140, minHeight: 140), 'SMALL');
      expect(resolveLayoutSize(defaultSize: 'SMALL', minWidth: 170, minHeight: 160), 'SMALL');
      expect(resolveLayoutSize(defaultSize: 'SMALL', minWidth: 180, minHeight: 180), 'SMALL');
      expect(resolveLayoutSize(defaultSize: 'SMALL', minWidth: 200, minHeight: 180), 'SMALL');

      // 2. Medium (4x2) widget on standard mobile screens (width 260-380dp, height 110-180dp)
      // MUST resolve to MEDIUM
      expect(resolveLayoutSize(defaultSize: 'MEDIUM', minWidth: 280, minHeight: 140), 'MEDIUM');
      expect(resolveLayoutSize(defaultSize: 'MEDIUM', minWidth: 340, minHeight: 160), 'MEDIUM');

      // 3. Medium shrunk to 2 columns (width < 210dp) gracefully degrades to SMALL
      expect(resolveLayoutSize(defaultSize: 'MEDIUM', minWidth: 180, minHeight: 150), 'SMALL');

      // 4. Large (4x4) widget on standard screens (width 260-380dp, height 260-380dp)
      expect(resolveLayoutSize(defaultSize: 'LARGE', minWidth: 320, minHeight: 300), 'LARGE');
    });
  });
}

