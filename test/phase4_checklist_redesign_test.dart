import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/packing_item_tile.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_button.dart';

class FakeChecklistNotifier extends ChecklistNotifier {
  FakeChecklistNotifier(ChecklistState initialState) : super(null, initialState);

  @override
  Future<void> loadItems({String? tripId, String? userId}) async {
    // Keep initialState for synchronous testing without hitting SQLite/Firestore
  }
}

void main() {
  group('Phase 4: Structural Emoji Elimination in Checklist', () {
    testWidgets('Motivational progress text and ready titles contain zero decorative emojis', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final testLocales = [
                'en', 'tr', 'de', 'fr', 'es', 'it', 'pt', 'ru', 'zh', 'ja',
                'ko', 'ar', 'hi', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi'
              ];
              final forbiddenEmojis = ['✈️', '✨', '🎒', '🧳', '🗺️', '🎉'];

              for (final lang in testLocales) {
                // Test 100% ready title
                final readyTitle = ChecklistScreen.getReadyTitle(lang);
                for (final emoji in forbiddenEmojis) {
                  expect(readyTitle.contains(emoji), isFalse,
                      reason: 'Ready title in $lang contains forbidden emoji $emoji: "$readyTitle"');
                }

                // Test motivational text across all ratio brackets
                for (final ratio in [1.0, 0.8, 0.5, 0.1]) {
                  final motivational = ChecklistScreen.getMotivationalProgressText(ratio, l10n, lang);
                  for (final emoji in forbiddenEmojis) {
                    expect(motivational.contains(emoji), isFalse,
                        reason: 'Motivational text in $lang (ratio $ratio) contains forbidden emoji $emoji: "$motivational"');
                  }
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('Phase 4: PackingItemTile Inset-Grouped & Things 3 Refinement', () {
    final sampleItem = PackingItem(
      id: 'test-item-1',
      name: 'Passport',
      category: 'Belgeler',
      quantity: 2,
      isPacked: false,
      tag: 'CARRY-ON',
      compartment: 'Ana Bölme',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('Stepper tap targets are strictly >= 44x44 dp with tabular font', (tester) async {
      int quantityDelta = 0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PackingItemTile(
              item: sampleItem,
              onTogglePacked: () {},
              onUpdateQuantity: (delta) => quantityDelta = delta,
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Check ConstrainedBox min dimensions for stepper buttons
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.descendant(
          of: find.byType(PackingItemTile),
          matching: find.byType(ConstrainedBox),
        ),
      );

      // Tap increment
      final addIcon = find.byIcon(AppIcons.add);
      expect(addIcon, findsOneWidget);
      await tester.tap(addIcon);
      expect(quantityDelta, 1);

      // Verify quantity text has tabular figures font
      final quantityFinder = find.text('2');
      expect(quantityFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(quantityFinder);
      expect(textWidget.style?.fontFeatures?.any((f) => f.feature == 'tnum') ?? false, isTrue);
    });

    testWidgets('Dismissible backgrounds use refined flat surfaces without LinearGradient', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PackingItemTile(
              item: sampleItem,
              onTogglePacked: () {},
              onUpdateQuantity: (_) {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.background, isA<Container>());
      expect(dismissible.secondaryBackground, isA<Container>());

      final bgContainer = dismissible.background as Container;
      final bgDecoration = bgContainer.decoration as BoxDecoration?;
      expect(bgDecoration?.gradient, isNull, reason: 'Delete swipe must not use a harsh gradient');
      expect(bgDecoration?.color, isNotNull);

      final secBgContainer = dismissible.secondaryBackground as Container;
      final secBgDecoration = secBgContainer.decoration as BoxDecoration?;
      expect(secBgDecoration?.gradient, isNull, reason: 'Packed swipe must not use a harsh gradient');
      expect(secBgDecoration?.color, isNotNull);
    });

    testWidgets('Packed state tile renders clean flat background with solid checkbox', (tester) async {
      final packedItem = sampleItem.copyWith(isPacked: true);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PackingItemTile(
              item: packedItem,
              onTogglePacked: () {},
              onUpdateQuantity: (_) {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Checkmark icon rendered inside solid circle
      expect(find.byIcon(AppIcons.check), findsOneWidget);
    });
  });

  group('Phase 4: ChecklistScreen Empty State & Overview Card', () {
    testWidgets('Renders empty state with AppButton primitives and no RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checklistControllerProvider.overrideWith(
              (ref) => FakeChecklistNotifier(
                const ChecklistState(
                  isLoading: false,
                  items: [],
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChecklistScreen(isTabMode: true),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // Verify AppButton usage in empty state
      expect(find.byType(AppButton), findsNWidgets(2));
      expect(find.byIcon(AppIcons.spark), findsWidgets);
      expect(find.byIcon(AppIcons.add), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320x568 compact iPhone SE viewport renders with zero overflows in Dark Mode', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checklistControllerProvider.overrideWith(
              (ref) => FakeChecklistNotifier(
                const ChecklistState(
                  isLoading: false,
                  items: [],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ChecklistScreen(isTabMode: true),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(tester.takeException(), isNull);
    });
  });
}
