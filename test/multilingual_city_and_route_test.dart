import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/budget/domain/city_localization.dart';
import 'package:packbuddy/features/budget/domain/country.dart';

void main() {
  group('Multilingual City & Global Destinations Engine', () {
    test('Contains over 200 globally recognized travel destinations', () {
      expect(CityLocalization.popularCities.length, greaterThanOrEqualTo(200));
    });

    test('Search for cities works seamlessly across English, Turkish, German, and native forms', () {
      // Munich search
      final enMunich = Country.searchLocations('Munich', languageCode: 'en');
      expect(enMunich.any((r) => r.cityName == 'Munich' && r.country.code == 'DE'), isTrue);

      final deMunich = Country.searchLocations('München', languageCode: 'de');
      expect(deMunich.any((r) => r.cityName == 'München' && r.country.code == 'DE'), isTrue);

      final trMunich = Country.searchLocations('Münih', languageCode: 'tr');
      expect(trMunich.any((r) => r.cityName == 'Münih' && r.country.code == 'DE'), isTrue);

      // Vienna search
      final enVienna = Country.searchLocations('Vienna', languageCode: 'en');
      expect(enVienna.any((r) => r.cityName == 'Vienna' && r.country.code == 'AT'), isTrue);

      final deVienna = Country.searchLocations('Wien', languageCode: 'de');
      expect(deVienna.any((r) => r.cityName == 'Wien' && r.country.code == 'AT'), isTrue);

      final trVienna = Country.searchLocations('Viyana', languageCode: 'tr');
      expect(trVienna.any((r) => r.cityName == 'Viyana' && r.country.code == 'AT'), isTrue);

      // Rome search
      final enRome = Country.searchLocations('Rome', languageCode: 'en');
      expect(enRome.any((r) => r.cityName == 'Rome' && r.country.code == 'IT'), isTrue);

      final itRome = Country.searchLocations('Roma', languageCode: 'it');
      expect(itRome.any((r) => r.cityName == 'Roma' && r.country.code == 'IT'), isTrue);
    });

    test('Country.findLocationExact resolves multilingual city names to active language', () {
      final resEn = Country.findLocationExact('Münih', languageCode: 'en');
      expect(resEn, isNotNull);
      expect(resEn!.cityName, 'Munich');
      expect(resEn.country.code, 'DE');
      expect(resEn.formattedStop, contains('Munich'));

      final resDe = Country.findLocationExact('Munich', languageCode: 'de');
      expect(resDe, isNotNull);
      expect(resDe!.cityName, 'München');
      expect(resDe.country.code, 'DE');

      final resTr = Country.findLocationExact('Munich', languageCode: 'tr');
      expect(resTr, isNotNull);
      expect(resTr!.cityName, 'Münih');
    });

    test('CityLocalization.localizeStop translates single stop properly', () {
      const stop = '🇩🇪 Münih, Almanya';
      final enStop = CityLocalization.localizeStop(stop, 'en');
      expect(enStop, '🇩🇪 Munich, Germany');

      final deStop = CityLocalization.localizeStop(stop, 'de');
      expect(deStop, '🇩🇪 München, Deutschland');

      final trStop = CityLocalization.localizeStop(enStop, 'tr');
      expect(trStop, '🇩🇪 Münih, Almanya');
    });

    test('CityLocalization.localizeDestination translates full multi-stop routes and preserves custom pins', () {
      const route = '🇹🇷 İstanbul, Türkiye ➔ 🇩🇪 Münih, Almanya ➔ 📍 Yayla Evi';
      
      final enRoute = CityLocalization.localizeDestination(route, 'en');
      expect(enRoute, contains('Istanbul, Turkey'));
      expect(enRoute, contains('Munich, Germany'));
      expect(enRoute, contains('📍 Yayla Evi'));

      final deRoute = CityLocalization.localizeDestination(route, 'de');
      expect(deRoute, contains('Istanbul, Türkei'));
      expect(deRoute, contains('München, Deutschland'));
      expect(deRoute, contains('📍 Yayla Evi'));
    });
  });
}
