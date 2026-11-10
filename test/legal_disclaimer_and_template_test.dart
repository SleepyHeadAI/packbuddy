import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/widgets/legal_disclaimer_card.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/emergency_guide_sheet.dart';
import 'package:packbuddy/features/checklist/domain/canonical_packing_catalog.dart';
import 'package:packbuddy/features/checklist/domain/packing_templates.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/airline_guide_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  const all20Languages = [
    'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja',
    'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi'
  ];

  group('Template Localization Suite', () {
    test('Every template item maps to a canonical key and has valid translations', () {
      for (final template in PackingTemplatesRepository.all) {
        for (final item in template.items) {
          final key = CanonicalPackingCatalog.resolveCanonicalKey(item.name);
          expect(key, isNotNull, reason: 'Failed to resolve canonical key for ${item.name}');

          for (final lang in all20Languages) {
            final localized = CanonicalPackingCatalog.getLocalizedItemName(item.name, lang);
            expect(localized, isNotEmpty, reason: '${item.name} is empty in $lang');
            if (lang != 'tr') {
              expect(
                localized,
                isNot(equals(item.name)),
                reason: '${item.name} fell back to Turkish for language $lang',
              );
            }
          }
        }
      }
    });
  });

  group('Legal Disclaimer Banner Tests', () {
    test('Every language has non-empty title and message for both types', () {
      for (final lang in all20Languages) {
        final title = LegalDisclaimerBanner.getTitle(lang);
        expect(title, isNotEmpty);

        final airlineMsg = LegalDisclaimerBanner.getMessage(LegalDisclaimerType.airlineBaggage, lang);
        expect(airlineMsg, isNotEmpty);
        expect(airlineMsg.length, greaterThan(30));

        final sosMsg = LegalDisclaimerBanner.getMessage(LegalDisclaimerType.emergencySos, lang);
        expect(sosMsg, isNotEmpty);
        expect(sosMsg.length, greaterThan(30));
      }
    });

    testWidgets('Legal disclaimer renders cleanly on narrow 320dp screen in multiple languages without overflow', (tester) async {
      tester.view.physicalSize = const Size(320 * 2, 700 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      for (final lang in ['tr', 'en', 'de', 'ru', 'zh', 'ar']) {
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(lang),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ListView(
                children: const [
                  LegalDisclaimerBanner.airline(),
                  SizedBox(height: 12),
                  LegalDisclaimerBanner.emergency(),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LegalDisclaimerBanner), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('AirlineGuideSheet displays legal disclaimer at top', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AirlineGuideSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LegalDisclaimerBanner), findsOneWidget);
      expect(find.text('Yasal Bilgilendirme'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('EmergencyGuideSheet displays legal disclaimer in scrollable view', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testTrip = Trip(
        id: 'trip_1',
        title: 'Europe Tour',
        destination: 'Germany',
        countryCode: 'DE',
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        budgetLimit: 1500,
        defaultCurrency: 'EUR',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: EmergencyGuideSheet(trip: testTrip),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LegalDisclaimerBanner), findsOneWidget);
      expect(find.text('Yasal Bilgilendirme'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
