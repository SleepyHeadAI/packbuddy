import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/budget/domain/emergency_guide.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/emergency_guide_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Travel Plan Country Flags & Removal Synchronization Tests', () {
    test('Resolves multiple country flags and drops removed country flags accurately', () {
      // Create a 3-country trip: Turkey, Germany, France
      final tripWith3 = Trip(
        id: 'trip-1',
        title: 'Avrupa Turu',
        destination: '🇹🇷 Türkiye ➔ 🇩🇪 Almanya ➔ 🇫🇷 Fransa',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(tripWith3.countries.length, 3);
      expect(tripWith3.countryFlags, ['🇹🇷', '🇩🇪', '🇫🇷']);
      expect(tripWith3.primaryCountry?.code, 'TR');

      // Now user removes France from the travel plan
      final tripAfterRemovingFrance = tripWith3.copyWith(
        destination: '🇹🇷 Türkiye ➔ 🇩🇪 Almanya',
        countryCode: 'TR',
      );

      expect(tripAfterRemovingFrance.countries.length, 2);
      expect(tripAfterRemovingFrance.countryFlags, ['🇹🇷', '🇩🇪']);
      expect(tripAfterRemovingFrance.countryFlags.contains('🇫🇷'), isFalse);

      // User removes Turkey as well (only Germany remains)
      final tripOnlyGermany = tripAfterRemovingFrance.copyWith(
        destination: '🇩🇪 Almanya',
        countryCode: 'DE',
      );

      expect(tripOnlyGermany.countries.length, 1);
      expect(tripOnlyGermany.countryFlags, ['🇩🇪']);
      expect(tripOnlyGermany.countryFlags.contains('🇹🇷'), isFalse);

      // User removes all countries and adds custom local place
      final tripCustomOnly = tripOnlyGermany.copyWith(
        destination: '📍 Dedemin Evi',
        countryCode: null,
      );

      expect(tripCustomOnly.countries, isEmpty);
      expect(tripCustomOnly.countryFlags, isEmpty);
    });

    test('Resolves stops in non-Latin and international languages (e.g. Arabic, Russian, Japanese, English)', () {
      // English
      final tripEn = Trip(
        id: 'trip-en',
        title: 'Euro Trip',
        destination: 'Italy ➔ Spain ➔ Japan',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(tripEn.countryFlags, ['🇮🇹', '🇪🇸', '🇯🇵']);

      // Russian
      final tripRu = Trip(
        id: 'trip-ru',
        title: 'Поездка',
        destination: 'Италия ➔ Испания',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(tripRu.countryFlags, ['🇮🇹', '🇪🇸']);

      // Arabic
      final tripAr = Trip(
        id: 'trip-ar',
        title: 'رحلة',
        destination: 'ألمانيا ➔ فرنسا',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(tripAr.countryFlags, ['🇩🇪', '🇫🇷']);
    });
  });

  group('2. SOS Multi-Country Guide Resolution & Display Tests', () {
    test('5 Countries in a trip each get distinct, dedicated SOS guides', () {
      final trip5 = Trip(
        id: 'trip-5',
        title: '5 Ülke Seyahati',
        destination: '🇹🇷 Türkiye ➔ 🇩🇪 Almanya ➔ 🇫🇷 Fransa ➔ 🇮🇹 İtalya ➔ 🇯🇵 Japonya',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 20)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final guides = EmergencyGuide.forTrip(trip5);
      expect(guides.length, 5);
      expect(guides.map((g) => g.countryCode).toList(), ['TR', 'DE', 'FR', 'IT', 'JP']);

      // Turkey numbers
      final trGuide = guides.firstWhere((g) => g.countryCode == 'TR');
      expect(trGuide.generalSos, '112');
      expect(trGuide.police, '112');

      // Japan numbers
      final jpGuide = guides.firstWhere((g) => g.countryCode == 'JP');
      expect(jpGuide.police, '110');
      expect(jpGuide.ambulance, '119');

      // If user removes France from the trip, EmergencyGuide.forTrip only yields 4 countries
      final trip4 = trip5.copyWith(
        destination: '🇹🇷 Türkiye ➔ 🇩🇪 Almanya ➔ 🇮🇹 İtalya ➔ 🇯🇵 Japonya',
      );
      final guides4 = EmergencyGuide.forTrip(trip4);
      expect(guides4.length, 4);
      expect(guides4.any((g) => g.countryCode == 'FR'), isFalse);
    });

    testWidgets('EmergencyGuideSheet renders tabs for each country and switches active info', (tester) async {
      final trip = Trip(
        id: 'trip-sos-ui',
        title: 'Çoklu Ülke Seyahati',
        destination: '🇹🇷 Türkiye ➔ 🇩🇪 Almanya ➔ 🇯🇵 Japonya',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 14)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: EmergencyGuideSheet(trip: trip),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 3 countries have their tabs rendered
      expect(find.textContaining('Türkiye (TR)'), findsWidgets);
      expect(find.textContaining('Almanya (DE)'), findsWidgets);
      expect(find.textContaining('Japonya (JP)'), findsWidgets);

      // Initially Turkey is selected (unified emergency 112)
      expect(find.text('112'), findsWidgets);

      // Tap on Japan tab
      await tester.tap(find.textContaining('Japonya (JP)').first);
      await tester.pumpAndSettle();

      // Now Japan emergency numbers (110 for police, 119 for ambulance) must be displayed
      expect(find.text('110'), findsWidgets);
      expect(find.text('119'), findsWidgets);
    });
  });

  group('3. Budget Analytics: Multi-Chart Types & Deep Insights Tests', () {
    final testExpenses = [
      Expense(
        id: 'e1',
        tripId: 't1',
        title: 'Restoran Yemeği',
        amount: 80.0,
        currency: 'EUR',
        category: 'Food',
        paymentMethod: 'CreditCard',
        date: DateTime(2026, 9, 10),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Expense(
        id: 'e2',
        tripId: 't1',
        title: 'Metro Kartı Dolumu',
        amount: 20.0,
        currency: 'EUR',
        category: 'Transport',
        paymentMethod: 'Cash',
        date: DateTime(2026, 9, 11),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Expense(
        id: 'e3',
        tripId: 't1',
        title: 'Müze Giriş Bileti',
        amount: 50.0,
        currency: 'EUR',
        category: 'Entertainment',
        paymentMethod: 'Online',
        date: DateTime(2026, 9, 11),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final sampleTrip = Trip(
      id: 't1',
      title: 'Paris Seyahati',
      destination: '🇫🇷 Paris, Fransa',
      startDate: DateTime(2026, 9, 10),
      endDate: DateTime(2026, 9, 15),
      defaultCurrency: 'EUR',
      budgetLimit: 300.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('Renders Category chart by default, toggles to Payment Method and Daily Trend', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: BudgetAnalyticsCard(
                expenses: testExpenses,
                tripCurrency: 'EUR',
                totalSpent: 150.0,
                trip: sampleTrip,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Default View: Category
      expect(find.text('Harcama Türü'), findsOneWidget);
      expect(find.text('Ödeme Yöntemi'), findsOneWidget);
      expect(find.text('Günlük Dağılım'), findsOneWidget);
      expect(find.text('Yemek'), findsOneWidget);
      expect(find.text('Ulaşım'), findsOneWidget);
      expect(find.text('Eğlence'), findsOneWidget);

      // 2. Switch to Payment Method
      await tester.tap(find.text('Ödeme Yöntemi'));
      await tester.pumpAndSettle();

      expect(find.text('Kredi Kartı'), findsOneWidget);
      expect(find.text('Nakit'), findsOneWidget);
      expect(find.text('Online Ödeme'), findsOneWidget);

      // 3. Switch to Daily Trend
      await tester.tap(find.text('Günlük Dağılım'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Günlük Dağılım (2 gün)'), findsOneWidget);
      expect(find.textContaining('Zirve:'), findsOneWidget);
      expect(find.textContaining('€80'), findsWidgets);
    });

    testWidgets('Expands Detaylı İstatistikler & Analiz section and displays micro-metrics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: BudgetAnalyticsCard(
                expenses: testExpenses,
                tripCurrency: 'EUR',
                totalSpent: 150.0,
                trip: sampleTrip,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Deep Analytics accordion is collapsed by default (minimalist look)
      expect(find.text('Detaylı İstatistikler & Analiz'), findsOneWidget);
      expect(find.text('Ortalama İşlem'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('Detaylı İstatistikler & Analiz'));
      await tester.pumpAndSettle();

      // Deep metrics are now visible
      expect(find.text('Ortalama İşlem'), findsOneWidget);
      expect(find.text('En Yüksek Harcama'), findsOneWidget);
      expect(find.text('En Yoğun Harcama Günü'), findsOneWidget);
      expect(find.text('Nakit / Kart Dengesi'), findsOneWidget);
      expect(find.text('Kategori Çeşitliliği'), findsOneWidget);
    });

    testWidgets('BudgetAnalyticsCard renders on small 320x568 screen across languages with zero overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      for (final localeCode in ['tr', 'en', 'de', 'ru', 'ar', 'ja']) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(localeCode),
            home: Scaffold(
              body: SingleChildScrollView(
                child: BudgetAnalyticsCard(
                  expenses: testExpenses,
                  tripCurrency: 'EUR',
                  totalSpent: 150.0,
                  trip: sampleTrip,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Zero overflow on 320x568 for $localeCode');
      }
    });
  });
}
