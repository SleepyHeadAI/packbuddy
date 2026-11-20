import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_spacing.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/theme/app_typography.dart';
import 'package:packbuddy/shared/widgets/app_button.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/shared/widgets/app_divider.dart';
import 'package:packbuddy/shared/widgets/status_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 1: Design Tokens Architecture Suite', () {
    test('1. AppSpacing 8-point mathematical scale integrity', () {
      expect(AppSpacing.xxs, 2.0);
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 20.0);
      expect(AppSpacing.xxl, 24.0);
      expect(AppSpacing.xxxl, 32.0);
      expect(AppSpacing.huge, 48.0);

      // Verify pre-composed insets
      expect(AppSpacing.cardPadding, const EdgeInsets.all(16.0));
      expect(AppSpacing.screenPadding.bottom, 110.0);
    });

    test('2. AppRadius concentric geometry scale integrity', () {
      expect(AppRadius.xs, 6.0);
      expect(AppRadius.sm, 10.0);
      expect(AppRadius.md, 14.0);
      expect(AppRadius.lg, 18.0);
      expect(AppRadius.card, 22.0);
      expect(AppRadius.navBar, 26.0);
      expect(AppRadius.sheet, 28.0);
      expect(AppRadius.full, 999.0);

      expect(AppRadius.cardRadius, BorderRadius.circular(22.0));
      expect(AppRadius.sheetRadius, const BorderRadius.vertical(top: Radius.circular(28.0)));
    });

    test('3. AppColors Semantic Layer & Rule 4 WCAG Contrast Verification', () {
      // Light surface tokens
      expect(AppColors.scaffoldLight, const Color(0xFFF7F8FA));
      expect(AppColors.surfaceBaseLight, const Color(0xFFFFFFFF));
      expect(AppColors.surfaceRaisedLight, const Color(0xFFF1F3F6));
      expect(AppColors.surfaceOverlayLight, const Color(0xFFE8EBF0));
      expect(AppColors.borderSubtleLight, const Color(0xFFE5E8EE));

      // Dark surface tokens
      expect(AppColors.scaffoldDark, const Color(0xFF0B0F14));
      expect(AppColors.surfaceBaseDark, const Color(0xFF131920));
      expect(AppColors.surfaceRaisedDark, const Color(0xFF1C2430));
      expect(AppColors.surfaceOverlayDark, const Color(0xFF263242));
      expect(AppColors.borderSubtleDark, const Color(0xFF1E2836));

      // Brand accent tokens
      expect(AppColors.brandAccent, const Color(0xFFD97706));
      expect(AppColors.brandAccentTextLight, const Color(0xFF92400E));

      // Mathematical WCAG 2.1 Contrast Calculation:
      // (L1 + 0.05) / (L2 + 0.05) >= 4.5:1 for normal text
      double relativeLuminance(Color c) {
        double channel(double v) => v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) * ((v + 0.055) / 1.055);
        return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
      }

      final lWhite = relativeLuminance(AppColors.surfaceBaseLight);
      final lAccentText = relativeLuminance(AppColors.brandAccentTextLight);
      final contrastAgainstWhite = (lWhite + 0.05) / (lAccentText + 0.05);

      // Must exceed 4.5:1 contrast threshold
      expect(contrastAgainstWhite, greaterThanOrEqualTo(4.5));
    });

    test('4. AppTypography 3-Font Hierarchy & Fallback Integrity', () {
      final title = AppTypography.title(fontSize: 20, fontWeight: FontWeight.w700);
      final body = AppTypography.body(fontSize: 14, fontWeight: FontWeight.normal);
      final mono = AppTypography.mono(fontSize: 12, fontWeight: FontWeight.w600);

      expect(title.fontFamily, 'Figtree');
      expect(body.fontFamily, 'Noto Sans');
      expect(mono.fontFamily, 'JetBrains Mono');

      // Rule 3: kFontFallbacks contains 20-language system fallback fonts
      expect(AppTypography.kFontFallbacks.contains('Roboto'), isTrue);
      expect(AppTypography.kFontFallbacks.contains('Noto Sans Arabic'), isTrue);
      expect(AppTypography.kFontFallbacks.contains('Noto Sans SC'), isTrue);
      expect(AppTypography.kFontFallbacks.contains('Noto Sans JP'), isTrue);
      expect(AppTypography.kFontFallbacks.contains('Noto Sans KR'), isTrue);
      expect(AppTypography.kFontFallbacks.contains('Noto Sans Thai'), isTrue);
      expect(AppTypography.kFontFallbacks.contains('Noto Sans Devanagari'), isTrue);

      // Verify tabular figures are embedded on mono typography
      expect(mono.fontFeatures?.contains(const FontFeature.tabularFigures()), isTrue);
    });

    test('5. AppMotion & AppIcons Unified Tokens', () {
      expect(AppMotion.fast, const Duration(milliseconds: 160));
      expect(AppMotion.normal, const Duration(milliseconds: 240));
      expect(AppMotion.relaxed, const Duration(milliseconds: 500));

      expect(AppIcons.flight, isNotNull);
      expect(AppIcons.budget, isNotNull);
      expect(AppIcons.checklist, isNotNull);
      expect(AppIcons.vault, isNotNull);
      expect(AppIcons.settings, isNotNull);
    });

    testWidgets('6. AppButton renders all variants with >=44pt touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  AppButton(label: 'Primary', onPressed: () {}, variant: AppButtonVariant.primary),
                  AppButton(label: 'Secondary', onPressed: () {}, variant: AppButtonVariant.secondary),
                  AppButton(label: 'Outline', onPressed: () {}, variant: AppButtonVariant.outline),
                  AppButton(label: 'Ghost', onPressed: () {}, variant: AppButtonVariant.ghost),
                  AppButton(label: 'Destructive', onPressed: () {}, variant: AppButtonVariant.destructive),
                  AppButton(label: 'Loading', onPressed: () {}, isLoading: true),
                ],
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(AppButton);
      expect(buttonFinder, findsNWidgets(6));

      // Test touch target size
      final firstButtonSize = tester.getSize(buttonFinder.first);
      expect(firstButtonSize.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('7. AppDivider & AppCard render seamlessly with new tokens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AppCard(
                borderRadius: AppRadius.card,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Card Content'),
                    AppDivider(),
                    StatusBadge(
                      label: '%100 Hazır',
                      backgroundColor: AppColors.successContainerLight,
                      textColor: AppColors.successPastel,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(AppDivider), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('%100 Hazır'), findsOneWidget);
    });
  });
}
