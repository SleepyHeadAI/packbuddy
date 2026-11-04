import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:packbuddy/core/services/widget_map_renderer.dart';

void main() {
  testWidgets('Simulate HomeWidget.renderFlutterWidget for Large and Medium sizes', (tester) async {
    Widget buildCanvas({required double width, required double height, required bool showLegend}) {
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1329),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 2000 / 857,
                  child: SimpleMap(
                    instructions: SMapWorld.instructions,
                    defaultColor: const Color(0xFF2D3B55),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (showLegend)
                Positioned(
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Colors.black54,
                    child: const Text('Legend', style: TextStyle(fontSize: 8, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Large test in Column
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 360,
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCanvas(width: 360, height: 180, showLegend: true),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(SimpleMap), findsOneWidget);

    // Medium test in Column
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 200,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildCanvas(width: 200, height: 120, showLegend: false),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(SimpleMap), findsOneWidget);
  });

  test('WidgetThemeConfig supports all 16 themes with accurate light/dark classification', () {
    const darkThemes = [
      'midnight',
      'sunset',
      'emerald',
      'cyberpunk',
      'volcano',
      'nordicForest',
      'goldenHour',
      'galaxy',
      'monochromeDark',
    ];

    const lightThemes = [
      'minimalLight',
      'sandLight',
      'oceanLight',
      'cherryBlossom',
      'vintageSepia',
      'matcha',
      'pastelDream',
    ];

    expect(darkThemes.length, 9);
    expect(lightThemes.length, 7);

    for (final key in darkThemes) {
      final config = WidgetThemeConfig.fromKey(key);
      expect(config.key, key);
      expect(config.isLight, isFalse, reason: 'Expected $key to be a dark theme');
      expect(config.emoji.isNotEmpty, isTrue);
      expect(config.cardBgColor, isNotNull);
      expect(config.accentColor, isNotNull);
      expect(config.livedColor, isNotNull);
      expect(config.visitedColor, isNotNull);
      expect(config.wishlistColor, isNotNull);
    }

    for (final key in lightThemes) {
      final config = WidgetThemeConfig.fromKey(key);
      expect(config.key, key);
      expect(config.isLight, isTrue, reason: 'Expected $key to be a light theme');
      expect(config.emoji.isNotEmpty, isTrue);
      expect(config.cardBgColor, isNotNull);
      expect(config.accentColor, isNotNull);
      expect(config.livedColor, isNotNull);
      expect(config.visitedColor, isNotNull);
      expect(config.wishlistColor, isNotNull);
    }

    // Aliases
    expect(WidgetThemeConfig.fromKey('ocean').key, 'oceanLight');
    expect(WidgetThemeConfig.fromKey('light').key, 'minimalLight');
  });
}
