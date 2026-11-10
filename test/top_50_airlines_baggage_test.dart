import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/checklist/domain/airline_baggage_guide.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/airline_guide_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Top 50+ Airlines Baggage Allowances & Directory Tests', () {
    test('AirlineBaggageRepository contains at least 50 major world airlines with valid unique IATA codes', () {
      final list = AirlineBaggageRepository.airlines;
      expect(list.length, greaterThanOrEqualTo(50));

      final iataCodes = <String>{};
      for (final airline in list) {
        expect(airline.airlineName.trim().isNotEmpty, isTrue);
        expect(airline.iataCode.trim().isNotEmpty, isTrue);
        expect(airline.countryFlag.trim().isNotEmpty, isTrue);
        expect(airline.cabinLimitKg, greaterThan(0));
        expect(airline.checkedLimitKg, greaterThan(0));
        expect(airline.cabinDimensions.contains('x'), isTrue);
        expect(airline.notes.trim().isNotEmpty, isTrue);

        expect(iataCodes.contains(airline.iataCode), isFalse,
            reason: 'Duplicate IATA code: ${airline.iataCode}');
        iataCodes.add(airline.iataCode);
      }
    });

    test('Airline search finds airlines by name, flag, or IATA code', () {
      expect(AirlineBaggageRepository.findByQuery('Turkish')?.iataCode, equals('TK'));
      expect(AirlineBaggageRepository.findByQuery('DL')?.airlineName, equals('Delta Air Lines'));
      expect(AirlineBaggageRepository.findByQuery('Emirates')?.iataCode, equals('EK'));
      expect(AirlineBaggageRepository.findByQuery('Southwest')?.iataCode, equals('WN'));
      expect(AirlineBaggageRepository.findByQuery('SQ')?.airlineName, equals('Singapore Airlines'));
      expect(AirlineBaggageRepository.findByQuery('ANA')?.iataCode, equals('NH'));
      expect(AirlineBaggageRepository.findByQuery('JAL')?.iataCode, equals('JL'));
      expect(AirlineBaggageRepository.findByQuery('Qatar')?.iataCode, equals('QR'));
      expect(AirlineBaggageRepository.findByQuery('Lufthansa')?.iataCode, equals('LH'));
      expect(AirlineBaggageRepository.findByQuery('Ryanair')?.iataCode, equals('FR'));
    });

    test('All 50+ airlines provide non-empty localized notes across 20 languages', () {
      const locales = [
        'tr', 'en', 'de', 'fr', 'es', 'it', 'pt', 'nl', 'ru', 'zh',
        'ja', 'ko', 'ar', 'hi', 'id', 'pl', 'el', 'vi', 'th', 'sv'
      ];

      for (final airline in AirlineBaggageRepository.airlines) {
        for (final loc in locales) {
          final note = airline.getLocalizedNotes(loc);
          expect(note.trim().isNotEmpty, isTrue,
              reason: 'Empty localized note for ${airline.iataCode} in locale $loc');
          expect(note.contains('kg') || note.contains('кг') || note.contains('كجم'), isTrue,
              reason: 'Missing weight unit in note for ${airline.iataCode} in locale $loc');
        }
      }
    });

    testWidgets('AirlineGuideSheet renders and searches cleanly on 320x568 compact screen', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(body: AirlineGuideSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AirlineGuideSheet), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Türk Hava Yolları'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Türk Hava Yolları'), findsOneWidget);

      // Search for 'Delta'
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Delta');
      await tester.pumpAndSettle();

      expect(find.text('Delta Air Lines'), findsOneWidget);
      expect(find.text('Türk Hava Yolları'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Türk Hava Yolları'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Türk Hava Yolları'), findsOneWidget);
    });
  });
}

