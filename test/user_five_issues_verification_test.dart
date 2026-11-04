import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/travel_map/data/travel_map_service.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Issue 1: Country Sorting by Current Language', () {
    late TravelMapService mapService;
    late TravelMapController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
      mapService = TravelMapService.instance;
      controller = TravelMapController(mapService);
      await controller.loadCountries();
    });

    test('getFilteredCountries sorts by Turkish names when lang is tr', () {
      final listTr = controller.state.getFilteredCountries('tr');
      expect(listTr.isNotEmpty, isTrue);

      // Verify that list is sorted alphabetically by Turkish name
      for (int i = 0; i < listTr.length - 1; i++) {
        final current = listTr[i].getLocalizedName('tr').toLowerCase();
        final next = listTr[i + 1].getLocalizedName('tr').toLowerCase();
        expect(current.compareTo(next) <= 0, isTrue,
            reason: '${listTr[i].getLocalizedName('tr')} should precede or equal ${listTr[i + 1].getLocalizedName('tr')}');
      }

      // In Turkish, Germany is 'Almanya' (starts with A) and comes before Turkey 'Türkiye' (starts with T)
      final deIndex = listTr.indexWhere((c) => c.code == 'DE');
      final trIndex = listTr.indexWhere((c) => c.code == 'TR');
      expect(deIndex < trIndex, isTrue);
    });

    test('getFilteredCountries sorts by English names when lang is en', () {
      final listEn = controller.state.getFilteredCountries('en');
      expect(listEn.isNotEmpty, isTrue);

      // Verify sorted alphabetically by English name
      for (int i = 0; i < listEn.length - 1; i++) {
        final current = listEn[i].getLocalizedName('en').toLowerCase();
        final next = listEn[i + 1].getLocalizedName('en').toLowerCase();
        expect(current.compareTo(next) <= 0, isTrue,
            reason: '${listEn[i].getLocalizedName('en')} should precede or equal ${listEn[i + 1].getLocalizedName('en')}');
      }

      // In English, 'Germany' starts with G, while 'Austria' starts with A. Austria precedes Germany.
      final atIndex = listEn.indexWhere((c) => c.code == 'AT');
      final deIndex = listEn.indexWhere((c) => c.code == 'DE');
      expect(atIndex < deIndex, isTrue);
    });

    test('Searching with getFilteredCountries matches localized names', () {
      controller.setSearchQuery('Almanya');
      final searchResultTr = controller.state.getFilteredCountries('tr');
      expect(searchResultTr.any((c) => c.code == 'DE'), isTrue);

      controller.setSearchQuery('Germany');
      final searchResultEn = controller.state.getFilteredCountries('en');
      expect(searchResultEn.any((c) => c.code == 'DE'), isTrue);
    });
  });

  group('Issue 2: Wishlist Countries in Story Export', () {
    test('Wishlist items list formatting preserves multiple wishlist countries', () {
      final countries = [
        const TravelCountry(code: 'TR', nameEn: 'Turkey', nameTr: 'Türkiye', flag: '🇹🇷', continent: 'Europe', capital: 'Ankara', latitude: 39, longitude: 35, status: CountryStatus.wishlist),
        const TravelCountry(code: 'GB', nameEn: 'United Kingdom', nameTr: 'Birleşik Krallık', flag: '🇬🇧', continent: 'Europe', capital: 'London', latitude: 51, longitude: 0, status: CountryStatus.wishlist),
        const TravelCountry(code: 'JP', nameEn: 'Japan', nameTr: 'Japonya', flag: '🇯🇵', continent: 'Asia', capital: 'Tokyo', latitude: 35, longitude: 139, status: CountryStatus.wishlist),
        const TravelCountry(code: 'PE', nameEn: 'Peru', nameTr: 'Peru', flag: '🇵🇪', continent: 'Americas', capital: 'Lima', latitude: -12, longitude: -77, status: CountryStatus.wishlist),
      ];

      final wishlistCountries = countries.where((c) => c.isWishlist).toList();
      expect(wishlistCountries.length, 4);

      // All 4 countries are present and localized
      final ptNames = wishlistCountries.map((c) => c.getLocalizedName('pt')).join(', ');
      expect(ptNames.contains('Turquia'), isTrue);
      expect(ptNames.contains('Reino Unido'), isTrue);
      expect(ptNames.contains('Japão'), isTrue);
      expect(ptNames.contains('Peru'), isTrue);
    });
  });

  group('Issue 5: Widget Localization & Modes', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
    });

    test('PreferencesService handles world_map, trip and auto widget modes', () async {
      await PreferencesService.instance.setWidgetMode('world_map');
      expect(PreferencesService.instance.getWidgetMode(), 'world_map');

      await PreferencesService.instance.setWidgetMode('trip');
      expect(PreferencesService.instance.getWidgetMode(), 'trip');

      await PreferencesService.instance.setWidgetMode('auto');
      expect(PreferencesService.instance.getWidgetMode(), 'auto');
    });
  });
}
