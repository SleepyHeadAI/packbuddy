import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/country_picker_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  group('1. Country & City Search & Exact Matching Engine Testleri', () {
    test('Country.searchLocations finds real cities with prefix and country information', () {
      final resultsTr = Country.searchLocations('İst', languageCode: 'tr');
      expect(resultsTr.isNotEmpty, isTrue);
      final istanbul = resultsTr.firstWhere((r) => r.cityName == 'İstanbul');
      expect(istanbul.isCity, isTrue);
      expect(istanbul.country.code, 'TR');
      expect(istanbul.formattedStop, contains('İstanbul'));
      expect(istanbul.formattedStop, contains('Türkiye'));

      final resultsFr = Country.searchLocations('Par', languageCode: 'tr');
      expect(resultsFr.isNotEmpty, isTrue);
      final paris = resultsFr.firstWhere((r) => r.cityName == 'Paris');
      expect(paris.isCity, isTrue);
      expect(paris.country.code, 'FR');
    });

    test('Country.searchLocations finds real countries with prefix priority', () {
      final resultsAme = Country.searchLocations('Ame', languageCode: 'tr');
      expect(resultsAme.isNotEmpty, isTrue);
      expect(resultsAme.first.country.code, 'US');
      expect(resultsAme.first.isCity, isFalse);

      final resultsTur = Country.searchLocations('Tür', languageCode: 'tr');
      expect(resultsTur.isNotEmpty, isTrue);
      expect(resultsTur.any((r) => r.country.code == 'TR' && !r.isCity), isTrue);
    });

    test('Country.searchLocations returns empty for fake or custom locations like "Bizim Köy" or "Kedi"', () {
      final resultsKedi = Country.searchLocations('Kedi', languageCode: 'tr');
      expect(resultsKedi.isEmpty, isTrue);

      final resultsKoy = Country.searchLocations('Bizim Köy', languageCode: 'tr');
      expect(resultsKoy.isEmpty, isTrue);
    });

    test('Country.findLocationExact verifies genuine countries/cities and rejects fake inputs', () {
      final exactParis = Country.findLocationExact('Paris', languageCode: 'en');
      expect(exactParis, isNotNull);
      expect(exactParis!.isCity, isTrue);
      expect(exactParis.country.code, 'FR');

      final exactTurkey = Country.findLocationExact('Türkiye', languageCode: 'tr');
      expect(exactTurkey, isNotNull);
      expect(exactTurkey!.isCity, isFalse);
      expect(exactTurkey.country.code, 'TR');

      final exactFake = Country.findLocationExact('Bizim Köy', languageCode: 'tr');
      expect(exactFake, isNull);

      final exactKedi = Country.findLocationExact('Kedi', languageCode: 'tr');
      expect(exactKedi, isNull);
    });
  });

  group('2. CountryPickerResult Format Testleri', () {
    test('CountryPickerResult formats country-only and city-specific stops cleanly', () {
      final tr = Country.findByCode('TR')!;
      final resultCountryOnly = CountryPickerResult(country: tr);
      expect(resultCountryOnly.getLocalizedLabel('tr'), '🇹🇷 Türkiye');

      final resultWithCity = CountryPickerResult(country: tr, selectedCity: 'Antalya');
      expect(resultWithCity.getLocalizedLabel('tr'), '🇹🇷 Antalya, Türkiye');
      expect(resultWithCity.selectedCity, 'Antalya');
    });
  });

  group('3. AddTripSheet Opsiyonel Özel Konum ve Gerçek Şehir/Ülke Arama UI Testleri', () {
    testWidgets('AddTripSheet renders custom location pin icon and suggests verified countries/cities', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(
              body: AddTripSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify custom location icon is rendered
      expect(find.byIcon(Icons.pin_drop_rounded), findsWidgets);

      // Enter "Paris" in location input field
      final inputFinder = find.byType(TextFormField).at(1);
      await tester.enterText(inputFinder, 'Paris');
      await tester.pumpAndSettle();

      // Verified city should appear in suggestion list
      expect(find.textContaining('Paris'), findsWidgets);
      expect(find.text('Şehir'), findsWidgets);

      // Custom location option should also appear at bottom
      expect(find.textContaining('Özel konum olarak ekle'), findsOneWidget);

      // Tap on Paris suggestion item
      await tester.tap(find.text('Fransa (FR)'));
      await tester.pumpAndSettle();

      // Chip with "🇫🇷 Paris, Fransa" should now be present in itinerary stops
      expect(find.textContaining('Paris, Fransa'), findsOneWidget);
    });

    testWidgets('AddTripSheet custom location dialog adds "📍 Bizim Köy" stop properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(
              body: AddTripSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the custom pin icon
      final pinButtonFinder = find.byIcon(Icons.pin_drop_rounded).first;
      await tester.tap(pinButtonFinder);
      await tester.pumpAndSettle();

      // Dialog should open
      expect(find.text('Özel Konum Ekle'), findsOneWidget);
      expect(find.textContaining('haritada yer almayan'), findsOneWidget);

      // Type "Bizim Köy" in dialog
      final dialogInput = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(dialogInput, 'Bizim Köy');
      await tester.pumpAndSettle();

      // Tap "Ekle"
      final addBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      );
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // "📍 Bizim Köy" should now be added to itinerary stops with custom pin avatar
      expect(find.text('📍 Bizim Köy'), findsOneWidget);
    });

    testWidgets('AddTripSheet rejects unrecognized string "Kedi" from direct adding and prompts custom confirmation', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(
              body: AddTripSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter unrecognized location "Kedi"
      final inputFinder = find.byType(TextFormField).at(1);
      await tester.enterText(inputFinder, 'Kedi');
      await tester.pumpAndSettle();

      // Tap "Ekle" button next to input
      final addBtnFinder = find.widgetWithText(FilledButton, 'Ekle');
      await tester.tap(addBtnFinder);
      await tester.pumpAndSettle();

      // Confirmation dialog should pop up because "Kedi" is not a country or city
      expect(find.textContaining('ülke veya şehir listesinde bulunamadı'), findsOneWidget);
      expect(find.text('Özel konum olarak ekle'), findsOneWidget);

      // Tap "Özel konum olarak ekle"
      await tester.tap(find.text('Özel konum olarak ekle'));
      await tester.pumpAndSettle();

      // Now "📍 Kedi" is explicitly marked as custom location
      expect(find.text('📍 Kedi'), findsOneWidget);
    });
  });
}
