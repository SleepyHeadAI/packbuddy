import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:packbuddy/features/travel_map/data/globe_world_data.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/data/world_map_instructions.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/interactive_world_map.dart';

void main() {
  group('Travel Map Microstates and Zoom Range Tests', () {
    test('WorldMapInstructions contains all 9 microstates and valid root JSON', () {
      final String raw = WorldMapInstructions.instructions;
      expect(raw, isNotEmpty);

      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      expect(data['w'], equals(2000));
      expect(data['h'], equals(857));
      expect(data['g'], isNotNull);
      expect(data['g']['a'], isNotNull);

      final List items = data['i'] as List;
      final existingCodes = items.map((it) => (it as Map)['u']?.toString().toLowerCase()).toSet();

      final expectedMicrostates = ['hk', 'sg', 'mo', 'va', 'mc', 'sm', 'ad', 'li', 'gi'];
      for (final code in expectedMicrostates) {
        expect(existingCodes.contains(code), isTrue, reason: 'Expected microstate $code in map instructions');
      }
    });

    testWidgets('SimpleMap renders with WorldMapInstructions and color mapping for HK and SG', (tester) async {
      String? tappedCode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 400,
              child: SimpleMap(
                instructions: WorldMapInstructions.instructions,
                defaultColor: Colors.white,
                colors: const {
                  'hk': Color(0xFFE7B623), // Visited amber
                  'sg': Color(0xFF10B981), // Lived green
                },
                callback: (id, name, details) {
                  tappedCode = id;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SimpleMap), findsOneWidget);

      // Tap Hong Kong (approx x=0.8182, y=0.4128 on 800x400 map with BoxFit.contain)
      final centerHK = const Offset(800 * 0.8182, 28.6 + 342.8 * 0.4128);
      await tester.tapAt(centerHK);
      await tester.pumpAndSettle();
      expect(tappedCode, equals('hk'));

      // Tap Singapore (approx x=0.7882, y=0.5786)
      final centerSG = const Offset(800 * 0.7882, 28.6 + 342.8 * 0.5786);
      await tester.tapAt(centerSG);
      await tester.pumpAndSettle();
      expect(tappedCode, equals('sg'));
    });

    testWidgets('InteractiveWorldMap renders and configures maxScale up to 30.0', (tester) async {
      final List<TravelCountry> countries = [
        WorldCountriesData.allCountries.firstWhere((c) => c.code == 'HK').copyWith(status: CountryStatus.visited),
        WorldCountriesData.allCountries.firstWhere((c) => c.code == 'SG').copyWith(status: CountryStatus.lived),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveWorldMap(
              countries: countries,
              is3DMode: false,
              onCountryTap: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(InteractiveWorldMap), findsOneWidget);

      final interactiveViewerFinder = find.byType(InteractiveViewer);
      expect(interactiveViewerFinder, findsOneWidget);

      final InteractiveViewer iv = tester.widget(interactiveViewerFinder);
      expect(iv.maxScale, equals(30.0));
      expect(iv.minScale, equals(1.0));
    });

    test('GlobeWorldData includes polygons for microstates', () {
      final polygons = GlobeWorldData.getPolygons();
      expect(polygons, isNotEmpty);

      final codes = polygons.map((p) => p.code.toLowerCase()).toSet();
      expect(codes.contains('hk'), isTrue);
      expect(codes.contains('sg'), isTrue);
    });
  });
}
