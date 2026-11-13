import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/help/data/faq_data.dart';
import 'package:packbuddy/features/help/domain/help_localization.dart';
import 'package:packbuddy/features/help/presentation/screens/help_screen.dart';
import 'package:packbuddy/features/help/presentation/screens/widgets/faq_expansion_tile.dart';

void main() {
  group('Help & FAQ Domain & Data Tests', () {
    test('FaqData returns all curated items and valid categories', () {
      expect(FaqData.allItems.isNotEmpty, isTrue);
      expect(FaqData.categories.length, equals(7));

      for (final cat in FaqData.categories) {
        final items = FaqData.getByCategory(cat);
        expect(items.isNotEmpty, isTrue, reason: 'Category $cat should have at least one item');
      }
    });

    test('HelpLocalization returns localized questions and answers for multiple languages', () {
      final sampleIds = ['whatIsPackBuddy', 'offlineOperation', 'vaultPinForgot'];
      final sampleLangs = ['en', 'tr', 'de', 'es', 'fr', 'ja'];

      for (final id in sampleIds) {
        for (final lang in sampleLangs) {
          final q = HelpLocalization.getQuestion(id, lang);
          final a = HelpLocalization.getAnswer(id, lang);
          expect(q.isNotEmpty, isTrue);
          expect(a.isNotEmpty, isTrue);
        }
      }
    });
  });

  group('HelpScreen Widget Tests', () {
    testWidgets('renders HelpScreen, search bar, topic pills, and expands a question', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & search
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(FaqExpansionTile), findsWidgets);

      // Tap on first FAQ expansion tile to expand
      final firstTile = find.byType(FaqExpansionTile).first;
      await tester.tap(firstTile);
      await tester.pumpAndSettle();

      // Test search filter
      await tester.enterText(find.byType(TextField), 'offline');
      await tester.pumpAndSettle();

      // Should find at least offlineOperation
      expect(find.byType(FaqExpansionTile), findsWidgets);

      // Test searching non-existent string
      await tester.enterText(find.byType(TextField), 'xyz123randomstring');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });
  });
}

