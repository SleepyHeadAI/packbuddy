import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/features/checklist/domain/canonical_packing_catalog.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  group('Comprehensive Translation & Canonical Catalog Verification', () {
    test('Leather jacket resolves and translates accurately across Korean, Turkish, and English', () {
      // 1. From English 'Leather jacket'
      expect(CanonicalPackingCatalog.getLocalizedItemName('Leather jacket', 'ko'), equals('가죽 재킷'));
      expect(CanonicalPackingCatalog.getLocalizedItemName('Leather jacket', 'tr'), equals('Deri Ceket'));
      expect(CanonicalPackingCatalog.getLocalizedItemName('Leather jacket', 'en'), equals('Leather Jacket'));
      expect(CanonicalPackingCatalog.getLocalizedItemName('Leather jacket', 'de'), equals('Lederjacke'));

      // 2. From Korean '가죽 재킷'
      expect(CanonicalPackingCatalog.getLocalizedItemName('가죽 재킷', 'en'), equals('Leather Jacket'));
      expect(CanonicalPackingCatalog.getLocalizedItemName('가죽 재킷', 'tr'), equals('Deri Ceket'));
      expect(CanonicalPackingCatalog.getLocalizedItemName('가죽 재킷', 'ko'), equals('가죽 재킷'));

      // 3. From Turkish 'Deri Ceket'
      expect(CanonicalPackingCatalog.getLocalizedItemName('Deri Ceket', 'ko'), equals('가죽 재킷'));
      expect(CanonicalPackingCatalog.getLocalizedItemName('Deri Ceket', 'en'), equals('Leather Jacket'));
    });

    test('Unicode characters are preserved during normalization (Korean, Cyrillic, Chinese, etc.)', () {
      expect(CanonicalPackingCatalog.normalize('가죽 재킷'), equals('가죽 재킷'));
      expect(CanonicalPackingCatalog.normalize('여권, 비자'), equals('여권 비자'));
      expect(CanonicalPackingCatalog.normalize('Кожаная куртка!'), equals('кожаная куртка'));
      expect(CanonicalPackingCatalog.normalize('皮夹克 (2x)'), equals('皮夹克 2x'));
    });

    test('Korean travel keywords are resolved to canonical keys', () {
      expect(CanonicalPackingCatalog.resolveCanonicalKey('가죽 재킷'), equals('leather_jacket'));
      expect(CanonicalPackingCatalog.resolveCanonicalKey('여권'), equals('passport'));
      expect(CanonicalPackingCatalog.resolveCanonicalKey('보조배터리'), equals('powerbank'));
      expect(CanonicalPackingCatalog.resolveCanonicalKey('세면도구'), equals('toiletries'));
      expect(CanonicalPackingCatalog.resolveCanonicalKey('칫솔'), equals('toothbrush'));
      expect(CanonicalPackingCatalog.resolveCanonicalKey('청바지'), equals('jeans_joggers'));
      expect(CanonicalPackingCatalog.resolveCanonicalKey('선글라스'), equals('sunglasses'));
      expect(CanonicalPackingCatalog.resolveCanonicalKey('우비'), equals('raincoat'));
    });

    testWidgets('Motivational progress text is translated to Korean without emojis', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ko'),
          home: Scaffold(body: SizedBox.shrink()),
        ),
      );
      await tester.pump();

      final BuildContext context = tester.element(find.byType(Scaffold));
      final l10n = AppLocalizations.of(context)!;

      final text23 = ChecklistScreen.getMotivationalProgressText(0.23, l10n, 'ko');
      expect(text23, equals('짐 싸기를 시작해볼까요! 차근차근 담아보세요.'));

      final text50 = ChecklistScreen.getMotivationalProgressText(0.50, l10n, 'ko');
      expect(text50, equals('아주 잘하고 있어요! 가방이 채워지고 있습니다.'));

      final text80 = ChecklistScreen.getMotivationalProgressText(0.80, l10n, 'ko');
      expect(text80, equals('거의 다 끝났어요! 마지막 몇 가지만 챙기면 돼요.'));

      final text100 = ChecklistScreen.getMotivationalProgressText(1.0, l10n, 'ko');
      expect(text100, equals('짐 싸기 완료! 즐거운 여행 되세요!'));
    });
  });

  group('Iconography & AI Symbol Removal Verification', () {
    test('Toiletries category icon uses bath/hygiene icon, not AI sparkles', () {
      expect(AppIcons.categoryToiletries, equals(LucideIcons.bath));
      expect(AppIcons.categoryToiletries, isNot(equals(LucideIcons.sparkles)));
    });

    test('Essential tag icon uses star, not AI sparkles', () {
      final essentialIcon = PackingTagHelper.getTagIcon('ESSENTIAL');
      expect(essentialIcon, equals(AppIcons.star));
      expect(essentialIcon, isNot(equals(LucideIcons.sparkles)));
    });

    test('Ready templates icon uses layoutTemplate', () {
      expect(AppIcons.template, equals(LucideIcons.layoutTemplate));
    });
  });
}
