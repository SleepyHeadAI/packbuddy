import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/search/domain/search_localization.dart';
import 'package:packbuddy/features/search/domain/search_result.dart';
import 'package:packbuddy/features/search/presentation/controllers/search_controller.dart';
import 'package:packbuddy/features/search/presentation/screens/global_search_screen.dart';
import 'package:packbuddy/features/search/presentation/screens/widgets/search_filter_bar.dart';
import 'package:packbuddy/features/search/presentation/screens/widgets/search_result_tile.dart';

void main() {
  group('SearchResult Model Tests', () {
    test('SearchResult.fromMap correctly maps a trip', () {
      final map = {
        'id': 'trip_101',
        'title': 'Paris Getaway',
        'destination': 'Paris, France',
        'start_date': '2026-06-01',
        'end_date': '2026-06-10',
        'search_type': 'trip',
        'updated_at': 1718000000000,
      };

      final result = SearchResult.fromMap(map);
      expect(result.id, equals('trip_101'));
      expect(result.title, equals('Paris Getaway'));
      expect(result.type, equals(SearchResultType.trip));
      expect(result.subtitle, contains('Paris, France'));
      expect(result.icon, equals(Icons.flight_takeoff_rounded));
    });

    test('SearchResult.fromMap correctly maps a packing item', () {
      final map = {
        'id': 'item_201',
        'trip_id': 'trip_101',
        'name': 'Passport & Visa',
        'category': 'Documents',
        'quantity': 2,
        'is_packed': 1,
        'search_type': 'packingItem',
      };

      final result = SearchResult.fromMap(map);
      expect(result.id, equals('item_201'));
      expect(result.title, equals('Passport & Visa'));
      expect(result.type, equals(SearchResultType.packingItem));
      expect(result.isPacked, isTrue);
      expect(result.quantity, equals(2));
      expect(result.icon, equals(Icons.check_circle_rounded));
    });

    test('SearchResult.fromMap correctly maps a vault document', () {
      final map = {
        'id': 'doc_301',
        'trip_id': 'trip_101',
        'title': 'Health Insurance Certificate',
        'category': 'Insurance',
        'file_type': 'PDF',
        'search_type': 'document',
      };

      final result = SearchResult.fromMap(map);
      expect(result.id, equals('doc_301'));
      expect(result.title, equals('Health Insurance Certificate'));
      expect(result.type, equals(SearchResultType.document));
      expect(result.subtitle, contains('Insurance'));
      expect(result.subtitle, contains('PDF'));
      expect(result.icon, equals(Icons.description_rounded));
    });

    test('SearchResult.fromMap correctly maps an expense', () {
      final map = {
        'id': 'exp_401',
        'trip_id': 'trip_101',
        'title': 'Train tickets to Lyon',
        'amount': 84.50,
        'currency': 'EUR',
        'category': 'Transportation',
        'date': '2026-06-03',
        'search_type': 'expense',
      };

      final result = SearchResult.fromMap(map);
      expect(result.id, equals('exp_401'));
      expect(result.title, equals('Train tickets to Lyon'));
      expect(result.type, equals(SearchResultType.expense));
      expect(result.amount, equals(84.50));
      expect(result.currency, equals('EUR'));
      expect(result.subtitle, contains('84.50 EUR'));
      expect(result.icon, equals(Icons.receipt_long_rounded));
    });
  });

  group('SearchLocalization Tests', () {
    test('Returns non-empty strings across all 20 supported languages', () {
      final langs = [
        'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja',
        'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi',
      ];

      for (final lang in langs) {
        expect(SearchLocalization.getSearch(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getSearchHint(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getFilterAll(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getFilterTrips(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getFilterPacking(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getFilterDocuments(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getFilterExpenses(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getRecentSearches(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getClear(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getNoResults(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getNoResultsHint(lang).isNotEmpty, isTrue);
        expect(SearchLocalization.getStartTyping(lang).isNotEmpty, isTrue);
      }
    });
  });

  group('Search UI Widget Tests', () {
    testWidgets('SearchFilterBar renders filters and triggers selection', (tester) async {
      SearchFilter selected = SearchFilter.all;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchFilterBar(
              selectedFilter: selected,
              onFilterSelected: (f) {
                selected = f;
              },
              languageCode: 'en',
              counts: const {
                SearchFilter.all: 10,
                SearchFilter.trips: 3,
                SearchFilter.packing: 5,
                SearchFilter.documents: 1,
                SearchFilter.expenses: 1,
              },
            ),
          ),
        ),
      );

      expect(find.text('All (10)'), findsOneWidget);
      expect(find.text('Trips (3)'), findsOneWidget);
      expect(find.text('Packing Items (5)'), findsOneWidget);

      await tester.tap(find.text('Trips (3)'));
      await tester.pump();
      expect(selected, equals(SearchFilter.trips));
    });

    testWidgets('SearchResultTile renders title, subtitle, and triggers tap', (tester) async {
      bool tapped = false;
      const result = SearchResult(
        id: 'r_1',
        title: 'Swiss Alps Hiking',
        subtitle: 'Interlaken • 2026-07-10',
        type: SearchResultType.trip,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultTile(
              result: result,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Swiss Alps Hiking'), findsOneWidget);
      expect(find.text('Interlaken • 2026-07-10'), findsOneWidget);
      expect(find.text('Trip'), findsOneWidget);

      await tester.tap(find.text('Swiss Alps Hiking'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('GlobalSearchScreen renders recent searches and search input', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalSearchControllerProvider.overrideWith((ref) {
              final controller = GlobalSearchController(ref);
              controller.state = const SearchState(
                query: '',
                recentSearches: ['Rome', 'Camera Charger', 'Passport'],
              );
              return controller;
            }),
          ],
          child: const MaterialApp(
            home: GlobalSearchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Recent Searches'), findsOneWidget);
      expect(find.text('Rome'), findsOneWidget);
      expect(find.text('Camera Charger'), findsOneWidget);
      expect(find.text('Passport'), findsOneWidget);
    });

    testWidgets('GlobalSearchScreen renders search results when query matches', (tester) async {
      const results = [
        SearchResult(
          id: 't_1',
          title: 'Tokyo Food Tour',
          subtitle: 'Tokyo, Japan • 2026-10-01',
          type: SearchResultType.trip,
        ),
        SearchResult(
          id: 'i_1',
          title: 'Japan Rail Pass',
          subtitle: 'Transit • 1 adet ✓ Hazır',
          type: SearchResultType.packingItem,
          isPacked: true,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalSearchControllerProvider.overrideWith((ref) {
              final controller = GlobalSearchController(ref);
              controller.state = const SearchState(
                query: 'Japan',
                allResults: results,
                filteredResults: results,
              );
              return controller;
            }),
          ],
          child: const MaterialApp(
            home: GlobalSearchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tokyo Food Tour'), findsOneWidget);
      expect(find.text('Japan Rail Pass'), findsOneWidget);
    });
  });
}

