import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/checklist/domain/canonical_packing_catalog.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_thumbnail_widget.dart';
import 'package:packbuddy/features/budget/domain/emergency_guide.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/travel_map_story_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/emergency_guide_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.now();

  group('1. Acil Durum & Yerel Rehber (SOS) Çoklu Ülke ve Doğruluk Testleri', () {
    test('EmergencyGuide.forTrip correctly resolves single and multiple countries', () {
      final multiCountryTrip = Trip(
        id: 'trip_multi_1',
        title: 'Balkan & Avrupa Turu',
        destination: 'Kosova ➔ Almanya',
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        budgetLimit: 1500.0,
        createdAt: now,
        updatedAt: now,
      );

      final guides = EmergencyGuide.forTrip(multiCountryTrip);
      expect(guides.length, 2);
      expect(guides[0].countryCode, 'XK');
      expect(guides[0].countryName, 'Kosovo');
      expect(guides[0].police, '192');
      expect(guides[0].ambulance, '194');
      expect(guides[0].fire, '193');
      expect(guides[0].generalSos, '112');
      expect(guides[0].powerPlugs, 'Type C / F (230V, 50Hz)');

      expect(guides[1].countryCode, 'DE');
      expect(guides[1].countryName, 'Germany');
      expect(guides[1].police, '110');
      expect(guides[1].ambulance, '112');
      expect(guides[1].fire, '112');
      expect(guides[1].generalSos, '112');
      expect(guides[1].powerPlugs, 'Type C / F (230V, 50Hz)');
    });

    test('EmergencyGuide.forTrip resolves specific countries like Austria and Switzerland', () {
      final trip = Trip(
        id: 'trip_at_ch',
        title: 'Alp Macerası',
        destination: 'Avusturya - İsviçre',
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
        budgetLimit: 2000.0,
        createdAt: now,
        updatedAt: now,
      );

      final guides = EmergencyGuide.forTrip(trip);
      expect(guides.length, 2);
      expect(guides[0].countryCode, 'AT');
      expect(guides[0].police, '133');
      expect(guides[0].ambulance, '144');
      expect(guides[0].fire, '122');

      expect(guides[1].countryCode, 'CH');
      expect(guides[1].police, '117');
      expect(guides[1].ambulance, '144');
      expect(guides[1].fire, '118');
    });

    testWidgets('EmergencyGuideSheet renders tabs when multiple countries exist', (tester) async {
      final trip = Trip(
        id: 'trip_multi_sheet',
        title: 'Balkan Turu',
        destination: 'Kosova ➔ Almanya',
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
        budgetLimit: 1200.0,
        createdAt: now,
        updatedAt: now,
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

      // Check if both country choice chips are visible
      expect(find.textContaining('Kosova'), findsWidgets);
      expect(find.textContaining('Almanya'), findsWidgets);

      // Verify emergency numbers for Kosovo
      expect(find.text('192'), findsOneWidget); // Police in Kosovo

      // Tap on Almanya chip
      await tester.tap(find.textContaining('Almanya').first);
      await tester.pumpAndSettle();

      // Verify emergency numbers for Germany
      expect(find.text('110'), findsOneWidget); // Police in Germany
    });
  });

  group('2. Ülke Arama ve Öneri Sıralaması (Prefix-First Autocomplete) Testleri', () {
    test('Prefix matches come before infix matches', () {
      final q = 'ame';
      final results = WorldCountriesData.allCountries.where((c) {
        final tr = c.nameTr.toLowerCase();
        final en = c.nameEn.toLowerCase();
        return tr.contains(q) || en.contains(q);
      }).toList();

      results.sort((a, b) {
        final aStartsTr = a.nameTr.toLowerCase().startsWith(q);
        final aStartsEn = a.nameEn.toLowerCase().startsWith(q);
        final bStartsTr = b.nameTr.toLowerCase().startsWith(q);
        final bStartsEn = b.nameEn.toLowerCase().startsWith(q);

        final aStarts = aStartsTr || aStartsEn;
        final bStarts = bStartsTr || bStartsEn;

        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;
        return a.nameTr.compareTo(b.nameTr);
      });

      expect(results.isNotEmpty, true);
      // The first result MUST start with 'ame' (e.g. Amerika Birleşik Devletleri or Amerikan Samoası)
      final first = results.first;
      final startsWithAme = first.nameTr.toLowerCase().startsWith('ame') || first.nameEn.toLowerCase().startsWith('ame');
      expect(startsWithAme, true);
    });
  });

  group('3. Harita Ülke Durumunu Kaldırma Testi', () {
    test('CountryStatus.none clears lived, visited and wishlist states', () {
      final country = TravelCountry(
        code: 'FR',
        nameEn: 'France',
        nameTr: 'Fransa',
        flag: '🇫🇷',
        continent: 'Europe',
        capital: 'Paris',
        latitude: 48.8566,
        longitude: 2.3522,
        status: CountryStatus.visited,
      );

      expect(country.isVisited, true);

      final clearedCountry = country.copyWith(status: CountryStatus.none);
      expect(clearedCountry.isVisited, false);
      expect(clearedCountry.isLived, false);
      expect(clearedCountry.isWishlist, false);
      expect(clearedCountry.status, CountryStatus.none);
    });
  });

  group('4. Güvenli Model Ayrıştırma ve Çift Alan (user_id / userId) Testleri', () {
    test('Trip.fromJson safely parses payload with missing or null id and snake_case user_id', () {
      final json = <String, dynamic>{
        // id is omitted (will fallback to empty string safely without throwing TypeError)
        'user_id': 'user_123',
        'title': 'İtalya Gezisi',
        'destination': 'Roma',
        'startDate': '2026-11-01T10:00:00Z',
        'endDate': '2026-11-05T18:00:00Z',
      };

      final trip = Trip.fromJson(json);
      expect(trip.id, '');
      expect(trip.userId, 'user_123');
      expect(trip.title, 'İtalya Gezisi');
    });

    test('Trip.fromJson safely parses payload with camelCase userId', () {
      final json = <String, dynamic>{
        'id': 'trip_abc',
        'userId': 'user_456',
        'title': 'Paris Seyahati',
        'destination': 'Paris',
        'startDate': '2026-12-01T10:00:00Z',
        'endDate': '2026-12-05T18:00:00Z',
      };

      final trip = Trip.fromJson(json);
      expect(trip.id, 'trip_abc');
      expect(trip.userId, 'user_456');
    });

    test('Expense.fromJson safely parses payload with missing id and resolves userId/user_id', () {
      final json = <String, dynamic>{
        'user_id': 'user_exp_1',
        'trip_id': 'trip_100',
        'title': 'Müze Bileti',
        'amount': 25.5,
        'date': '2026-11-02T14:00:00Z',
      };

      final expense = Expense.fromJson(json);
      expect(expense.id, '');
      expect(expense.userId, 'user_exp_1');
      expect(expense.tripId, 'trip_100');
      expect(expense.amount, 25.5);
    });

    test('Document.fromJson safely parses payload with missing id and resolves userId/user_id', () {
      final json = <String, dynamic>{
        'userId': 'user_doc_1',
        'title': 'Pasaport Fotokopisi',
        'category': 'Identity',
      };

      final doc = Document.fromJson(json);
      expect(doc.id, '');
      expect(doc.userId, 'user_doc_1');
      expect(doc.title, 'Pasaport Fotokopisi');
    });

    test('PackingItem.fromJson safely parses payload with both userId formats', () {
      final item1 = PackingItem.fromJson({
        'id': 'item_1',
        'user_id': 'user_item_1',
        'name': 'Pasaport',
      });
      expect(item1.userId, 'user_item_1');

      final item2 = PackingItem.fromJson({
        'id': 'item_2',
        'userId': 'user_item_2',
        'name': 'Güneş Gözlüğü',
      });
      expect(item2.userId, 'user_item_2');
    });
  });

  group('5. Kasa Küçük Resim (VaultThumbnailWidget) Şifre Çözme ve PDF Önizleme Testleri', () {
    testWidgets('VaultThumbnailWidget renders fallback gracefully when file does not exist', (tester) async {
      final doc = Document(
        id: 'missing_doc',
        userId: 'u1',
        title: 'Kayıp Belge',
        category: 'General',
        localImagePath: '/tmp/non_existent_file_9999.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultThumbnailWidget(
              document: doc,
              categoryColor: Colors.blue,
              categoryIcon: Icons.description,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.description), findsOneWidget);
    });

    testWidgets('VaultThumbnailWidget renders PDF cover layout gracefully', (tester) async {
      final pdfDoc = Document(
        id: 'pdf_sample_doc',
        userId: 'u1',
        title: 'Bilet.pdf',
        category: 'Ticket',
        fileType: 'pdf',
        localImagePath: '/tmp/sample_ticket.pdf',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VaultThumbnailWidget(
              document: pdfDoc,
              categoryColor: Colors.red,
              categoryIcon: Icons.picture_as_pdf_rounded,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('PDF BELGESİ'), findsOneWidget);
    });
  });

  group('6. Bavul Eşya Silme ve Geri Gelmeme (Resurrection Prevention) Testleri', () {
    test('PreferencesService tracks hasSeededChecklist per user', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesService.init();

      await prefs.setSeededChecklist(false, uid: 'test_user_seed');
      expect(prefs.hasSeededChecklist(uid: 'test_user_seed'), false);

      await prefs.setSeededChecklist(true, uid: 'test_user_seed');
      expect(prefs.hasSeededChecklist(uid: 'test_user_seed'), true);

      // Separate user is not affected
      expect(prefs.hasSeededChecklist(uid: 'different_user'), false);
    });

    test('Deleted items canonical key resolution correctly matches English and Turkish seeds', () {
      final itemTr = PackingItem(
        id: 'item_tr_1',
        name: 'Pasaport, Vize & Uçuş Biletleri',
        category: 'Belgeler',
        quantity: 1,
        isPacked: false,
        createdAt: now,
        updatedAt: now,
      );

      final itemEn = PackingItem(
        id: 'item_en_1',
        name: 'Passport, Visa & Flight Tickets',
        category: 'Documents',
        quantity: 1,
        isPacked: false,
        createdAt: now,
        updatedAt: now,
      );

      final keyTr = CanonicalPackingCatalog.resolveCanonicalKey(itemTr.name) ?? CanonicalPackingCatalog.normalize(itemTr.name);
      final keyEn = CanonicalPackingCatalog.resolveCanonicalKey(itemEn.name) ?? CanonicalPackingCatalog.normalize(itemEn.name);

      expect(keyTr, 'passport');
      expect(keyEn, 'passport');
      expect(keyTr, keyEn);
    });

    test('Deleted items are filtered out from remote upserts', () {
      final deletedIds = {'item_del_1', 'item_del_2'};
      final remoteItems = [
        PackingItem(
          id: 'item_del_1',
          name: 'Pasaport',
          category: 'Belgeler',
          quantity: 1,
          isPacked: false,
          createdAt: now,
          updatedAt: now,
        ),
        PackingItem(
          id: 'item_keep_3',
          name: 'Güneş Kremi',
          category: 'Bakım',
          quantity: 1,
          isPacked: false,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final filteredRemote = remoteItems.where((i) => !deletedIds.contains(i.id)).toList();
      expect(filteredRemote.length, 1);
      expect(filteredRemote.first.id, 'item_keep_3');
    });
  });

  group('7. Hikaye Kartı 10 Yeni Tema, 3 Yeni Şablon ve Sıfır Boşluk Tasarımı Testleri', () {
    test('StoryCardTheme has 16 palettes and StoryCardLayout has 7 distinct layouts', () {
      expect(StoryCardTheme.values.length, 16);
      expect(StoryCardLayout.values.length, 7);

      // Verify 3 new layouts
      expect(StoryCardLayout.values.contains(StoryCardLayout.journey), isTrue);
      expect(StoryCardLayout.values.contains(StoryCardLayout.polaroid), isTrue);
      expect(StoryCardLayout.values.contains(StoryCardLayout.infographic), isTrue);

      // Verify 10 new themes
      expect(StoryCardTheme.values.contains(StoryCardTheme.cyberpunk), isTrue);
      expect(StoryCardTheme.values.contains(StoryCardTheme.volcano), isTrue);
      expect(StoryCardTheme.values.contains(StoryCardTheme.nordicForest), isTrue);
      expect(StoryCardTheme.values.contains(StoryCardTheme.goldenHour), isTrue);
      expect(StoryCardTheme.values.contains(StoryCardTheme.galaxy), isTrue);
      expect(StoryCardTheme.values.contains(StoryCardTheme.monochromeDark), isTrue);
      expect(StoryCardTheme.values.contains(StoryCardTheme.cherryBlossom), isTrue);
      expect(StoryCardTheme.values.contains(StoryCardTheme.vintageSepia), isTrue);
      expect(StoryCardTheme.values.contains(StoryCardTheme.matcha), isTrue);
      expect(StoryCardTheme.values.contains(StoryCardTheme.pastelDream), isTrue);
    });

    test('StoryCardLayout localized names work across tr, en, de', () {
      expect(StoryCardLayout.journey.getLocalizedName(null, locale: 'tr'), 'Yolculuk');
      expect(StoryCardLayout.journey.getLocalizedName(null, locale: 'en'), 'Journey');
      expect(StoryCardLayout.journey.getLocalizedName(null, locale: 'de'), 'Reise');

      expect(StoryCardLayout.polaroid.getLocalizedName(null, locale: 'tr'), 'Kartpostal');
      expect(StoryCardLayout.polaroid.getLocalizedName(null, locale: 'en'), 'Postcard');
      expect(StoryCardLayout.polaroid.getLocalizedName(null, locale: 'de'), 'Postkarte');

      expect(StoryCardLayout.infographic.getLocalizedName(null, locale: 'tr'), 'İnfografik');
      expect(StoryCardLayout.infographic.getLocalizedName(null, locale: 'en'), 'Infographic');
      expect(StoryCardLayout.infographic.getLocalizedName(null, locale: 'de'), 'Infografik');
    });

    testWidgets('TravelMapStoryCard renders all 7 layouts with 0 countries gracefully without void or overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      for (final layout in StoryCardLayout.values) {
        debugPrint('Testing layout: $layout');
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: Scaffold(
              body: Center(
                child: TravelMapStoryCard(
                  countries: const [],
                  totalVisited: 0,
                  totalLived: 0,
                  totalWishlist: 0,
                  worldPercentage: 0.0,
                  continentsCount: 0,
                  theme: StoryCardTheme.cyberpunk,
                  layout: layout,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('TravelMapStoryCard renders with low country count (1-3 countries) and wishlist targets', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final sampleCountries = [
        WorldCountriesData.allCountries.firstWhere((c) => c.code == 'TR').copyWith(status: CountryStatus.lived),
        WorldCountriesData.allCountries.firstWhere((c) => c.code == 'FR').copyWith(status: CountryStatus.visited),
        WorldCountriesData.allCountries.firstWhere((c) => c.code == 'JP').copyWith(status: CountryStatus.wishlist),
      ];

      for (final layout in [StoryCardLayout.journey, StoryCardLayout.polaroid, StoryCardLayout.infographic]) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: Scaffold(
              body: Center(
                child: TravelMapStoryCard(
                  countries: sampleCountries,
                  totalVisited: 1,
                  totalLived: 1,
                  totalWishlist: 1,
                  worldPercentage: 1.0,
                  continentsCount: 2,
                  theme: StoryCardTheme.goldenHour,
                  layout: layout,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
