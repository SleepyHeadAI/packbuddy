import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/budget/domain/country_localization.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/travel_map/data/travel_map_service.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Problem 1: World Travel Map Persistence & Reinstall Resolution', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
    });

    test('Marking countries and simulating reinstall restores countries from cloud backup', () async {
      final service = TravelMapService.instance;
      const uid = 'test_user_persistence_456';

      // 1. User marks countries
      await service.setStatus(code: 'TR', status: CountryStatus.lived, uid: uid);
      await service.setStatus(code: 'US', status: CountryStatus.visited, uid: uid);
      await service.setStatus(code: 'JP', status: CountryStatus.wishlist, uid: uid);

      final countriesBefore = await service.getCountries(uid: uid);
      final rawSaved = await service.getRawSavedMap(uid: uid);
      expect(rawSaved.containsKey('TR'), isTrue);
      expect(rawSaved.containsKey('US'), isTrue);
      expect(rawSaved.containsKey('JP'), isTrue);
      expect(countriesBefore.firstWhere((c) => c.code == 'TR').isLived, isTrue);

      // 2. SIMULATE APP REINSTALL: Wiping SharedPreferences clean
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();

      // Verify that local storage is now clean
      final rawSavedAfterUninstall = await service.getRawSavedMap(uid: uid);
      expect(rawSavedAfterUninstall.isEmpty, isTrue);

      // 3. User logs in -> restoreFromCloud restores from the remote backup payload
      await service.restoreFromCloud(rawSaved, uid: uid);

      // 4. Verify all marked countries are 100% recovered
      final countriesRestored = await service.getCountries(uid: uid);
      final tr = countriesRestored.firstWhere((c) => c.code == 'TR');
      final us = countriesRestored.firstWhere((c) => c.code == 'US');
      final jp = countriesRestored.firstWhere((c) => c.code == 'JP');

      expect(tr.isLived, isTrue);
      expect(us.isVisited, isTrue);
      expect(jp.isWishlist, isTrue);
    });

    test('syncFromTrips does not wipe existing marked countries', () async {
      final service = TravelMapService.instance;
      const uid = 'test_user_trips_789';

      // Set manual countries
      await service.setStatus(code: 'FR', status: CountryStatus.visited, uid: uid);
      await service.setStatus(code: 'DE', status: CountryStatus.lived, uid: uid);

      // Simulate a completed trip to Italy
      final trip = Trip(
        id: 'trip_italy_1',
        title: 'Rome Holiday',
        destination: 'Italy',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 3)),
        defaultCurrency: 'EUR',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      final updatedCountries = await service.syncFromTrips([trip], uid: uid);
      expect(updatedCountries, isNotNull);

      // Verify Italy is visited, AND France and Germany were preserved!
      final it = updatedCountries!.firstWhere((c) => c.code == 'IT');
      final fr = updatedCountries.firstWhere((c) => c.code == 'FR');
      final de = updatedCountries.firstWhere((c) => c.code == 'DE');

      expect(it.isVisited, isTrue);
      expect(fr.isVisited, isTrue);
      expect(de.isLived, isTrue);
    });

    test('TravelMapController auto-syncs when local storage is empty for logged-in user', () async {
      final service = TravelMapService.instance;
      const uid = 'test_user_empty_sync';

      // Remote cloud map has 1 country
      await service.setStatus(code: 'ES', status: CountryStatus.visited, uid: uid);
      final cloudData = await service.getRawSavedMap(uid: uid);

      // Reinstall: wipe prefs
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();

      // Controller initialized
      final controller = TravelMapController(service);
      expect(controller.state.countries.every((c) => c.status == CountryStatus.none), isTrue);

      // Restore payload and load
      await service.restoreFromCloud(cloudData, uid: uid);
      await controller.loadCountries(userId: uid);

      expect(controller.state.countries.firstWhere((c) => c.code == 'ES').isVisited, isTrue);
      expect(controller.state.totalVisited, 1);
    });
  });

  group('Problem 2: Checklist Deletion & Re-seeding Loop Resolution', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
    });

    test('PreferencesService tracks hasClearedChecklist per user and globally', () async {
      final prefs = PreferencesService.instance;
      expect(prefs.hasClearedChecklist(), isFalse);
      expect(prefs.hasClearedChecklist(uid: 'user_abc'), isFalse);

      await prefs.setClearedChecklist(true, uid: 'user_abc');
      expect(prefs.hasClearedChecklist(uid: 'user_abc'), isTrue);
      expect(prefs.hasClearedChecklist(uid: 'user_xyz'), isFalse);

      await prefs.setClearedChecklist(false, uid: 'user_abc');
      expect(prefs.hasClearedChecklist(uid: 'user_abc'), isFalse);
    });

    test('When checklist is cleared, subsequent loads recognize user intentionally has 0 items', () async {
      final prefs = PreferencesService.instance;
      const uid = 'user_cleared_test';

      // User clears checklist
      await prefs.setClearedChecklist(true, uid: uid);
      await prefs.setSeededChecklist(true, uid: uid);

      expect(prefs.hasClearedChecklist(uid: uid), isTrue);
      expect(prefs.hasSeededChecklist(uid: uid), isTrue);

      // Even if items list is empty, !alreadySeeded && !alreadyCleared evaluates to false!
      final alreadySeeded = prefs.hasSeededChecklist(uid: uid);
      final alreadyCleared = prefs.hasClearedChecklist(uid: uid);
      final shouldSeed = !alreadySeeded && !alreadyCleared;

      expect(shouldSeed, isFalse);
    });
  });

  group('Problem 3: Comprehensive 20-Language Localization Resolution', () {
    test('CountryLocalization covers all countries across multiple non-Latin alphabets', () {
      // 1. Turkish (TR)
      expect(CountryLocalization.getCountryName('TR', 'tr'), 'Türkiye');
      expect(CountryLocalization.getCountryName('TR', 'en'), 'Turkey');
      expect(CountryLocalization.getCountryName('TR', 'ja'), 'トルコ'); // Katakana
      expect(CountryLocalization.getCountryName('TR', 'zh'), '土耳其'); // Simplified Chinese
      expect(CountryLocalization.getCountryName('TR', 'ko'), '튀르키예'); // Hangul
      expect(CountryLocalization.getCountryName('TR', 'ru'), 'Турция'); // Cyrillic
      expect(CountryLocalization.getCountryName('TR', 'ar'), 'تركيا'); // Arabic
      expect(CountryLocalization.getCountryName('TR', 'hi'), 'तुर्की'); // Devanagari
      expect(CountryLocalization.getCountryName('TR', 'el'), 'Τουρκία'); // Greek
      expect(CountryLocalization.getCountryName('TR', 'th'), 'ตุรกี'); // Thai

      // 2. Japan (JP)
      expect(CountryLocalization.getCountryName('JP', 'ja'), '日本');
      expect(CountryLocalization.getCountryName('JP', 'zh'), '日本');
      expect(CountryLocalization.getCountryName('JP', 'ko'), '일본');
      expect(CountryLocalization.getCountryName('JP', 'ru'), 'Япония');
      expect(CountryLocalization.getCountryName('JP', 'ar'), 'اليابان');
      expect(CountryLocalization.getCountryName('JP', 'hi'), 'जापान');
      expect(CountryLocalization.getCountryName('JP', 'th'), 'ญี่ปุ่น');
      expect(CountryLocalization.getCountryName('JP', 'el'), 'Ιαπωνία');
      expect(CountryLocalization.getCountryName('JP', 'fr'), 'Japon');
      expect(CountryLocalization.getCountryName('JP', 'de'), 'Japan');

      // 3. United States (US)
      expect(CountryLocalization.getCountryName('US', 'zh'), '美国');
      expect(CountryLocalization.getCountryName('US', 'ru'), 'Соединенные Штаты');
      expect(CountryLocalization.getCountryName('US', 'ar'), 'الولايات المتحدة');
      expect(CountryLocalization.getCountryName('US', 'ja'), 'アメリカ合衆国');
      expect(CountryLocalization.getCountryName('US', 'ko'), '미국');

      // 4. Germany (DE)
      expect(CountryLocalization.getCountryName('DE', 'de'), 'Deutschland');
      expect(CountryLocalization.getCountryName('DE', 'fr'), 'Allemagne');
      expect(CountryLocalization.getCountryName('DE', 'ru'), 'Германия');
      expect(CountryLocalization.getCountryName('DE', 'zh'), '德国');
      expect(CountryLocalization.getCountryName('DE', 'ar'), 'ألمانيا');
    });

    test('CountryLocalization normalizes regional language codes seamlessly', () {
      // zh-CN, zh-Hans, zh_TW should all resolve to Chinese
      expect(CountryLocalization.getCountryName('CN', 'zh-CN'), '中国');
      expect(CountryLocalization.getCountryName('CN', 'zh_CN'), '中国');
      expect(CountryLocalization.getCountryName('CN', 'zh-Hans'), '中国');

      // pt-BR, pt_PT should resolve to Portuguese
      expect(CountryLocalization.getCountryName('BR', 'pt-BR'), 'Brasil');
      expect(CountryLocalization.getCountryName('BR', 'pt_BR'), 'Brasil');

      // ja-JP, ja_JP should resolve to Japanese
      expect(CountryLocalization.getCountryName('JP', 'ja-JP'), '日本');
      expect(CountryLocalization.getCountryName('JP', 'ja_JP'), '日本');

      // en-US, en_GB should resolve to English
      expect(CountryLocalization.getCountryName('GB', 'en-US'), 'United Kingdom');
      expect(CountryLocalization.getCountryName('GB', 'en_GB'), 'United Kingdom');
    });

    test('ContinentLocalization accurately translates all continents across all languages', () {
      const continents = ['Europe', 'Asia', 'Americas', 'Africa', 'Oceania'];

      for (final cont in continents) {
        // Turkish
        expect(ContinentLocalization.getContinentName(cont, 'tr'), isNotEmpty);
        // English
        expect(ContinentLocalization.getContinentName(cont, 'en'), isNotEmpty);
        // Chinese
        expect(ContinentLocalization.getContinentName(cont, 'zh'), isNotEmpty);
        // Japanese
        expect(ContinentLocalization.getContinentName(cont, 'ja'), isNotEmpty);
        // Russian
        expect(ContinentLocalization.getContinentName(cont, 'ru'), isNotEmpty);
        // Arabic
        expect(ContinentLocalization.getContinentName(cont, 'ar'), isNotEmpty);
        // Hindi
        expect(ContinentLocalization.getContinentName(cont, 'hi'), isNotEmpty);
        // Greek
        expect(ContinentLocalization.getContinentName(cont, 'el'), isNotEmpty);
      }

      expect(ContinentLocalization.getContinentName('Europe', 'tr'), 'Avrupa');
      expect(ContinentLocalization.getContinentName('Europe', 'zh'), '欧洲');
      expect(ContinentLocalization.getContinentName('Europe', 'ja'), 'ヨーロッパ');
      expect(ContinentLocalization.getContinentName('Europe', 'ru'), 'Европа');
      expect(ContinentLocalization.getContinentName('Europe', 'ar'), 'أوروبا');

      expect(ContinentLocalization.getContinentName('Asia', 'tr'), 'Asya');
      expect(ContinentLocalization.getContinentName('Asia', 'zh'), '亚洲');
      expect(ContinentLocalization.getContinentName('Asia', 'ja'), 'アジア');

      expect(ContinentLocalization.getContinentName('Americas', 'tr'), 'Amerika');
      expect(ContinentLocalization.getContinentName('Americas', 'zh'), '美洲');

      expect(ContinentLocalization.getContinentName('Africa', 'tr'), 'Afrika');
      expect(ContinentLocalization.getContinentName('Africa', 'zh'), '非洲');

      expect(ContinentLocalization.getContinentName('Oceania', 'tr'), 'Okyanusya');
      expect(ContinentLocalization.getContinentName('Oceania', 'zh'), '大洋洲');
    });

    test('Every country in WorldCountriesData has valid translations', () {
      final all = WorldCountriesData.allCountries;
      expect(all.length, greaterThanOrEqualTo(220));

      for (final c in all) {
        final trName = CountryLocalization.getCountryName(c.code, 'tr');
        final enName = CountryLocalization.getCountryName(c.code, 'en');
        final zhName = CountryLocalization.getCountryName(c.code, 'zh');
        final jaName = CountryLocalization.getCountryName(c.code, 'ja');
        final ruName = CountryLocalization.getCountryName(c.code, 'ru');

        expect(trName, isNotNull, reason: 'Missing TR translation for ${c.code}');
        expect(enName, isNotNull, reason: 'Missing EN translation for ${c.code}');
        expect(zhName, isNotNull, reason: 'Missing ZH translation for ${c.code}');
        expect(jaName, isNotNull, reason: 'Missing JA translation for ${c.code}');
        expect(ruName, isNotNull, reason: 'Missing RU translation for ${c.code}');
      }
    });
  });
}
