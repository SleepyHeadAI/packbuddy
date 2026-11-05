import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
import 'package:packbuddy/features/checklist/domain/airline_baggage_guide.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';

void main() {
  group('PackingTagHelper Serene Voyage Localization & Styling', () {
    test('localizes standard tags to Turkish correctly', () {
      expect(PackingTagHelper.getLocalizedTag('CARRY-ON', 'tr'), 'Kabin Bagajı');
      expect(PackingTagHelper.getLocalizedTag('CABIN ONLY', 'tr'), 'Kişisel Eşya (Sırt Çantası)');
      expect(PackingTagHelper.getLocalizedTag('CHECK-IN', 'tr'), 'Uçak Altı (Kargo Bagajı)');
      expect(PackingTagHelper.getLocalizedTag('ESSENTIAL', 'tr'), 'Önemli / Yanına Al');
    });

    test('localizes short tags for item tile badges', () {
      expect(PackingTagHelper.getShortTag('CARRY-ON', 'tr'), 'Kabin');
      expect(PackingTagHelper.getShortTag('CHECK-IN', 'tr'), 'Uçak Altı');
      expect(PackingTagHelper.getShortTag('CABIN ONLY', 'tr'), 'Kişisel');
      expect(PackingTagHelper.getShortTag('ESSENTIAL', 'tr'), 'Önemli');
    });

    test('provides distinct, high-contrast Serene Voyage colors for each baggage tag', () {
      for (final tag in ['CARRY-ON', 'CHECK-IN', 'CABIN ONLY', 'ESSENTIAL']) {
        final darkColor = PackingTagHelper.getTagColor(tag, true);
        final lightColor = PackingTagHelper.getTagColor(tag, false);
        final darkBg = PackingTagHelper.getTagBgColor(tag, true);
        final lightBg = PackingTagHelper.getTagBgColor(tag, false);
        final darkBorder = PackingTagHelper.getTagBorderColor(tag, true);
        final lightBorder = PackingTagHelper.getTagBorderColor(tag, false);

        expect(darkColor, isNotNull);
        expect(lightColor, isNotNull);
        expect(darkBg, isNotNull);
        expect(lightBg, isNotNull);
        expect(darkBorder, isNotNull);
        expect(lightBorder, isNotNull);
      }
    });

    test('preserves custom tags gracefully with default styling', () {
      expect(PackingTagHelper.getLocalizedTag('CustomTag', 'tr'), 'CustomTag');
      expect(PackingTagHelper.getShortTag('CustomTag', 'tr'), 'CustomTag');
      final fallbackIcon = PackingTagHelper.getTagIcon('CustomTag');
      expect(fallbackIcon, Icons.sell_outlined);
    });
  });

  group('Checklist Baggage Allowance Modes', () {
    test('ChecklistState initializes with BaggageAllowanceMode.all by default', () {
      const state = ChecklistState();
      expect(state.baggageAllowanceMode, BaggageAllowanceMode.all);
      expect(state.selectedAirline, isNull);
    });

    test('ChecklistState copyWith updates baggageAllowanceMode correctly', () {
      const state = ChecklistState();
      final updated = state.copyWith(baggageAllowanceMode: BaggageAllowanceMode.cabinOnly);
      expect(updated.baggageAllowanceMode, BaggageAllowanceMode.cabinOnly);

      final noneState = updated.copyWith(baggageAllowanceMode: BaggageAllowanceMode.none);
      expect(noneState.baggageAllowanceMode, BaggageAllowanceMode.none);
    });

    test('AirlineBaggageRepository provides standard airline rules', () {
      expect(AirlineBaggageRepository.airlines, isNotEmpty);
      final thy = AirlineBaggageRepository.airlines.firstWhere((a) => a.iataCode == 'TK');
      expect(thy.airlineName, contains('Türk Hava Yolları'));
      expect(thy.cabinLimitKg, 8.0);
      expect(thy.checkedLimitKg, 23.0);
    });
  });
}
