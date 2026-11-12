import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
import 'package:packbuddy/features/checklist/domain/airline_baggage_guide.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';

void main() {
  group('Personal Item (Kişisel Eşya) Tag Verification', () {
    test('strictly says Kişisel Eşya without backpack across 20 languages', () {
      final langs = [
        'tr', 'en', 'de', 'fr', 'es', 'it', 'ru', 'pt', 'nl', 'pl',
        'sv', 'ar', 'ja', 'ko', 'zh', 'hi', 'id', 'th', 'vi', 'el'
      ];

      for (final lang in langs) {
        final localized = PackingTagHelper.getLocalizedTag('CABIN ONLY', lang);
        expect(localized, isNotEmpty);
        expect(localized.toLowerCase(), isNot(contains('sırt')));
        expect(localized.toLowerCase(), isNot(contains('sirt')));
        expect(localized.toLowerCase(), isNot(contains('backpack')));
        expect(localized.toLowerCase(), isNot(contains('рюкзак')));
      }

      expect(PackingTagHelper.getLocalizedTag('CABIN ONLY', 'tr'), 'Kişisel Eşya');
      expect(PackingTagHelper.getLocalizedTag('PERSONAL', 'tr'), 'Kişisel Eşya');
      expect(PackingTagHelper.getLocalizedTag('CABIN ONLY', 'en'), 'Personal Item');
      expect(PackingTagHelper.getLocalizedTag('CABIN ONLY', 'de'), 'Persönlicher Gegenstand');
      expect(PackingTagHelper.getLocalizedTag('CABIN ONLY', 'ru'), 'Личная вещь');
      expect(PackingTagHelper.getLocalizedTag('CABIN ONLY', 'th'), 'ของใช้ส่วนตัว');
    });

    test('tag icon is shopping_bag rather than backpack', () {
      final icon = PackingTagHelper.getTagIcon('CABIN ONLY');
      expect(icon, Icons.shopping_bag_outlined);
    });
  });

  group('Major Airlines Inclusion Verification', () {
    test('contains Thai Airways, Malaysia, AirAsia, flydubai, Air India, NZ, RJ, EgyptAir', () {
      final thai = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'TG');
      expect(thai.airlineName, contains('Thai Airways'));
      expect(thai.countryFlag, '🇹🇭');
      expect(thai.cabinLimitKg, 7.0);
      expect(thai.personalItemLimitKg, 3.0);
      expect(thai.packages, isNotEmpty);
      expect(thai.packages.any((p) => p.name == 'Saver'), isTrue);
      expect(thai.packages.any((p) => p.name == 'Standard'), isTrue);
      expect(thai.packages.any((p) => p.name == 'Flexi'), isTrue);

      final malaysia = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'MH');
      expect(malaysia.airlineName, contains('Malaysia Airlines'));
      expect(malaysia.countryFlag, '🇲🇾');
      expect(malaysia.packages, isNotEmpty);

      final airAsia = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'AK');
      expect(airAsia.airlineName, contains('AirAsia'));
      expect(airAsia.countryFlag, '🇲🇾');

      final flydubai = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'FZ');
      expect(flydubai.airlineName, contains('flydubai'));
      expect(flydubai.countryFlag, '🇦🇪');

      final airIndia = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'AI');
      expect(airIndia.airlineName, contains('Air India'));
      expect(airIndia.countryFlag, '🇮🇳');

      final airNZ = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'NZ');
      expect(airNZ.airlineName, contains('Air New Zealand'));
      expect(airNZ.countryFlag, '🇳🇿');

      final rj = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'RJ');
      expect(rj.airlineName, contains('Royal Jordanian'));
      expect(rj.countryFlag, '🇯🇴');

      final egyptAir = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'MS');
      expect(egyptAir.airlineName, contains('EgyptAir'));
      expect(egyptAir.countryFlag, '🇪🇬');
    });

    test('findByQuery resolves aliases for newly added airlines', () {
      expect(AirlineBaggageRepository.findByQuery('thai')?.iataCode, 'TG');
      expect(AirlineBaggageRepository.findByQuery('thai airways')?.iataCode, 'TG');
      expect(AirlineBaggageRepository.findByQuery('tg')?.iataCode, 'TG');

      expect(AirlineBaggageRepository.findByQuery('malaysia')?.iataCode, 'MH');
      expect(AirlineBaggageRepository.findByQuery('airasia')?.iataCode, 'AK');
      expect(AirlineBaggageRepository.findByQuery('flydubai')?.iataCode, 'FZ');
      expect(AirlineBaggageRepository.findByQuery('air india')?.iataCode, 'AI');
      expect(AirlineBaggageRepository.findByQuery('air new zealand')?.iataCode, 'NZ');
      expect(AirlineBaggageRepository.findByQuery('royal jordanian')?.iataCode, 'RJ');
      expect(AirlineBaggageRepository.findByQuery('egyptair')?.iataCode, 'MS');
    });
  });

  group('Airline Fare Package Selection & Effective Limits', () {
    test('Pegasus Airlines Süper Eko has 0 kg cabin and 3 kg personal bag', () {
      final pegasus = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'PC');
      expect(pegasus.packages, isNotEmpty);

      final superEko = pegasus.copyWith(selectedPackageId: 'PC_SUPER_EKO');
      expect(superEko.effectiveCabinLimitKg, 0.0);
      expect(superEko.effectivePersonalItemLimitKg, 3.0);
      expect(superEko.effectiveCheckedLimitKg, 0.0);

      final avantaj = pegasus.copyWith(selectedPackageId: 'PC_AVANTAJ');
      expect(avantaj.effectiveCabinLimitKg, 8.0);
      expect(avantaj.effectivePersonalItemLimitKg, 3.0);
      expect(avantaj.effectiveCheckedLimitKg, 20.0);
    });

    test('Turkish Airlines package limits apply dynamically', () {
      final thy = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'TK');
      expect(thy.packages, isNotEmpty);

      final ecoFly = thy.copyWith(selectedPackageId: 'TK_ECOFLY');
      expect(ecoFly.effectiveCabinLimitKg, 8.0);
      expect(ecoFly.effectiveCheckedLimitKg, 15.0);

      final extraFly = thy.copyWith(selectedPackageId: 'TK_EXTRAFLY');
      expect(extraFly.effectiveCabinLimitKg, 8.0);
      expect(extraFly.effectiveCheckedLimitKg, 20.0);

      final primeFly = thy.copyWith(selectedPackageId: 'TK_PRIMEFLY');
      expect(primeFly.effectiveCabinLimitKg, 8.0);
      expect(primeFly.effectiveCheckedLimitKg, 25.0);
    });

    test('Thai Airways package limits apply dynamically', () {
      final thai = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'TG');

      final saver = thai.copyWith(selectedPackageId: 'TG_SAVER');
      expect(saver.effectiveCabinLimitKg, 7.0);
      expect(saver.effectiveCheckedLimitKg, 20.0);
      expect(saver.effectivePersonalItemLimitKg, 3.0);

      final flexi = thai.copyWith(selectedPackageId: 'TG_FLEXI');
      expect(flexi.effectiveCabinLimitKg, 7.0);
      expect(flexi.effectiveCheckedLimitKg, 35.0);
    });

    test('ChecklistController updates selected package seamlessly', () {
      final pegasus = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'PC');
      final state = ChecklistState(selectedAirline: pegasus);
      expect(state.selectedAirline?.effectiveCabinLimitKg, 0.0); // default to first package (Süper Eko)

      final updatedState = state.copyWith(
        selectedAirline: pegasus.copyWith(selectedPackageId: 'PC_AVANTAJ'),
      );
      expect(updatedState.selectedAirline?.activePackage.name, 'Avantaj');
      expect(updatedState.selectedAirline?.effectiveCabinLimitKg, 8.0);
      expect(updatedState.selectedAirline?.effectiveCheckedLimitKg, 20.0);
    });
  });
}

