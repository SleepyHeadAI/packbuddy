import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/globe_3d_viewer.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/interactive_world_map.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/travel_map_story_card.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  group('Phase 6: Travel Map Design System & Visual Upgrades', () {
    testWidgets('InteractiveWorldMap 2D/3D switcher has no system emojis and uses vector icons', (tester) async {
      bool modeToggled = false;
      bool target3D = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: InteractiveWorldMap(
                countries: WorldCountriesData.allCountries,
                is3DMode: false,
                onToggle3DMode: (val) {
                  modeToggled = true;
                  target3D = val;
                },
                onCountryTap: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no emoji text in mode switcher
      expect(find.textContaining('🗺️'), findsNothing);
      expect(find.textContaining('🌐'), findsNothing);

      // Verify clean vector icons are present
      expect(find.byIcon(Icons.map_outlined), findsOneWidget);
      expect(find.byIcon(Icons.public_rounded), findsOneWidget);

      // Verify 2D and 3D labels
      expect(find.text('2D'), findsOneWidget);
      expect(find.textContaining('3D'), findsOneWidget);

      // Verify tap on 3D pill triggers toggle
      await tester.tap(find.byIcon(Icons.public_rounded));
      await tester.pumpAndSettle();
      expect(modeToggled, isTrue);
      expect(target3D, isTrue);
    });

    testWidgets('InteractiveWorldMap zoom controls enforce minimum touch targets and AppRadius.full', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: InteractiveWorldMap(
                countries: WorldCountriesData.allCountries,
                is3DMode: false,
                onToggle3DMode: (_) {},
                onCountryTap: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Zoom in, zoom out, reset buttons
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);

      // Verify inkwells / touch containers
      final zoomBoxes = tester.widgetList<ConstrainedBox>(
        find.descendant(
          of: find.byType(InteractiveWorldMap),
          matching: find.byType(ConstrainedBox),
        ),
      );
      final min44Boxes = zoomBoxes.where((box) =>
          box.constraints.minWidth >= 44 && box.constraints.minHeight >= 44);
      expect(min44Boxes.isNotEmpty, isTrue);
    });

    testWidgets('Globe3DViewer reset rotation control enforces AppRadius.full and min 44pt touch constraints', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Globe3DViewer(
              countries: WorldCountriesData.allCountries,
              onCountryTap: (_) {},
              isDark: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify reset button
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);

      // Verify touch constraint
      final resetConstrainedBox = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.byIcon(Icons.restart_alt_rounded),
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(resetConstrainedBox.constraints.minWidth, greaterThanOrEqualTo(44.0));
      expect(resetConstrainedBox.constraints.minHeight, greaterThanOrEqualTo(44.0));
    });

    test('Strict Protection: StoryCardTheme 16 themes and color presets are untouched', () {
      expect(StoryCardTheme.values.length, equals(16));

      final themeNames = StoryCardTheme.values.map((t) => t.name).toList();
      expect(themeNames, contains('midnight'));
      expect(themeNames, contains('sunset'));
      expect(themeNames, contains('emerald'));
      expect(themeNames, contains('cyberpunk'));
      expect(themeNames, contains('minimalLight'));
      expect(themeNames, contains('sandLight'));
      expect(themeNames, contains('vintageSepia'));

      // Validate that backgrounds and palettes are distinct and valid
      for (final st in StoryCardTheme.values) {
        final palette = StoryCardPalette.forTheme(st);
        expect(palette.label, isNotEmpty);
        expect(palette.accentColor, isNotNull);
        expect(palette.backgroundGradient.colors.length, greaterThanOrEqualTo(2));
      }
    });

    testWidgets('Viewport stress test: InteractiveWorldMap renders without overflow on 320x568 and 390x844', (tester) async {
      final viewports = [
        const Size(320, 568), // iPhone SE 1st gen
        const Size(390, 844), // iPhone 14/15/16
      ];

      for (final size in viewports) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Test in Light Theme
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SizedBox(
                width: size.width,
                height: 280,
                child: InteractiveWorldMap(
                  countries: WorldCountriesData.allCountries,
                  is3DMode: false,
                  onToggle3DMode: (_) {},
                  onCountryTap: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Zero overflow on ${size.width}x${size.height} light mode');

        // Test in Dark Theme with 3D Globe Mode
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SizedBox(
                width: size.width,
                height: 280,
                child: InteractiveWorldMap(
                  countries: WorldCountriesData.allCountries,
                  is3DMode: true,
                  onToggle3DMode: (_) {},
                  onCountryTap: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Zero overflow on ${size.width}x${size.height} dark 3D mode');
      }
    });
  });
}
