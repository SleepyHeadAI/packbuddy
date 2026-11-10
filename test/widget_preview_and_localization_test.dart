import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/l10n/l10n.dart';
import 'package:packbuddy/core/l10n/language_selector_sheet.dart';
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

    test('Widget Layout Sizing Thresholds prevent Small 2x2 from becoming Medium and Medium 4x2 from becoming Large', () {
      // Simulating Android widget sizing logic
      String resolveLayoutSize({
        required String defaultSize, // 'SMALL', 'MEDIUM', 'LARGE'
        required int minWidth,
        required int minHeight,
      }) {
        if (defaultSize == 'SMALL') {
          if (minWidth >= 240 && minHeight >= 265) return 'LARGE';
          if (minWidth >= 240) return 'MEDIUM';
          return 'SMALL';
        } else if (defaultSize == 'MEDIUM') {
          if (minHeight >= 265 && minWidth >= 200) return 'LARGE';
          if (minWidth < 200) return 'SMALL';
          return 'MEDIUM';
        } else {
          if (minWidth < 200 && minHeight < 200) return 'SMALL';
          if (minHeight < 250) return 'MEDIUM';
          return 'LARGE';
        }
      }

      // 1. Small (2x2) widget on standard mobile screens (width 140-195dp, height 140-195dp)
      // MUST ALWAYS resolve to SMALL
      expect(resolveLayoutSize(defaultSize: 'SMALL', minWidth: 140, minHeight: 140), 'SMALL');
      expect(resolveLayoutSize(defaultSize: 'SMALL', minWidth: 170, minHeight: 160), 'SMALL');
      expect(resolveLayoutSize(defaultSize: 'SMALL', minWidth: 180, minHeight: 180), 'SMALL');
      expect(resolveLayoutSize(defaultSize: 'SMALL', minWidth: 200, minHeight: 180), 'SMALL');

      // 2. Medium (4x2) widget on standard mobile and tall launcher screens (width 260-380dp, height 110-230dp)
      // MUST resolve to MEDIUM (never jump to Large on Samsung 215dp height!)
      expect(resolveLayoutSize(defaultSize: 'MEDIUM', minWidth: 280, minHeight: 140), 'MEDIUM');
      expect(resolveLayoutSize(defaultSize: 'MEDIUM', minWidth: 340, minHeight: 160), 'MEDIUM');
      expect(resolveLayoutSize(defaultSize: 'MEDIUM', minWidth: 340, minHeight: 215), 'MEDIUM');
      expect(resolveLayoutSize(defaultSize: 'MEDIUM', minWidth: 360, minHeight: 225), 'MEDIUM');

      // 3. Medium shrunk to 2 columns (width < 200dp) gracefully degrades to SMALL
      expect(resolveLayoutSize(defaultSize: 'MEDIUM', minWidth: 180, minHeight: 150), 'SMALL');

      // 4. Large (4x4 / 4x3) widget on standard screens (width 260-380dp, height 265-380dp)
      expect(resolveLayoutSize(defaultSize: 'LARGE', minWidth: 320, minHeight: 300), 'LARGE');
      expect(resolveLayoutSize(defaultSize: 'MEDIUM', minWidth: 320, minHeight: 300), 'LARGE');
    });

    test('L10n: Language alphabetical order in every language verification', () {
      const allCodes = [
        'tr', 'en', 'es', 'fr', 'de', 'it', 'pt', 'ru',
        'zh', 'ja', 'ko', 'hi', 'ar', 'nl', 'el', 'sv',
        'pl', 'id', 'th', 'vi',
      ];

      // 1. Verify every language has exactly 20 unique locales sorted
      for (final lang in allCodes) {
        final sorted = L10n.getSortedLocales(lang);
        expect(sorted.length, 20, reason: 'Language $lang must have 20 locales');
        final uniqueCodes = sorted.map((l) => l.languageCode).toSet();
        expect(uniqueCodes.length, 20, reason: 'Language $lang must have 20 unique codes');
        for (final code in allCodes) {
          expect(uniqueCodes.contains(code), isTrue, reason: 'Missing code $code in $lang');
        }
      }

      // 2. English alphabetical order check
      final enSorted = L10n.getSortedLocales('en').map((l) => l.languageCode).toList();
      expect(enSorted, [
        'ar', 'zh', 'nl', 'en', 'fr', 'de', 'el', 'hi', 'id', 'it',
        'ja', 'ko', 'pl', 'pt', 'ru', 'es', 'sv', 'th', 'tr', 'vi',
      ]);
      final enDisplayNames = enSorted.map((c) => L10n.getLanguageDisplayName(c, 'en')).toList();
      expect(enDisplayNames.first, 'Arabic (العربية)');
      expect(enDisplayNames[3], 'English'); // Same native/localized = clean without duplicate
      expect(enDisplayNames.last, 'Vietnamese (Tiếng Việt)');

      // 3. Turkish alphabetical order check
      final trSorted = L10n.getSortedLocales('tr').map((l) => l.languageCode).toList();
      expect(trSorted, [
        'de', 'ar', 'zh', 'id', 'nl', 'fr', 'hi', 'en', 'es', 'sv',
        'it', 'ja', 'ko', 'pl', 'pt', 'ru', 'th', 'tr', 'vi', 'el',
      ]);
      final trDisplayNames = trSorted.map((c) => L10n.getLanguageDisplayName(c, 'tr')).toList();
      expect(trDisplayNames.first, 'Almanca (Deutsch)');
      expect(trDisplayNames[17], 'Türkçe'); // Turkish clean without duplicate
      expect(trDisplayNames.last, 'Yunanca (Ελληνικά)');

      // 4. German alphabetical order check
      final deSorted = L10n.getSortedLocales('de').map((l) => l.languageCode).toList();
      expect(deSorted.first, 'ar'); // Arabisch
      expect(deSorted[2], 'de'); // Deutsch
      expect(deSorted.last, 'vi'); // Vietnamesisch

      // 5. French alphabetical order check
      final frSorted = L10n.getSortedLocales('fr').map((l) => l.languageCode).toList();
      expect(frSorted.first, 'de'); // Allemand
      expect(frSorted[1], 'en'); // Anglais
      expect(frSorted[6], 'fr'); // Français
      expect(frSorted.last, 'vi'); // Vietnamien
    });

    testWidgets('showLanguageSelectorSheet displays alphabetical order dynamically', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) => ElevatedButton(
                  onPressed: () => showLanguageSelectorSheet(context, ref, const Locale('en')),
                  child: const Text('Open Picker'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Top of list should be Arabic (العربية), then Chinese (中文) in English!
      expect(find.text('Arabic (العربية)'), findsOneWidget);
      expect(find.text('Chinese (中文)'), findsWidgets);
    });
  });
}

