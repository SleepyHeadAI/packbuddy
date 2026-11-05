import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/shared/widgets/status_badge.dart';
import 'package:packbuddy/shared/widgets/serene_action_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Serene Voyage Design System Suite', () {
    test('1. Exact Palette Hex Verification', () {
      // Primary: #E7B623 and #856404 (warm golden ochre)
      expect(AppColors.primaryAmber, const Color(0xFFE7B623));
      expect(AppColors.primaryLight, const Color(0xFF856404));

      // Secondary: #0F766E
      expect(AppColors.secondaryLight, const Color(0xFF0F766E));

      // Tertiary: #64748B
      expect(AppColors.tertiaryLight, const Color(0xFF64748B));

      // Neutral: #F3F5F7
      expect(AppColors.backgroundLight, const Color(0xFFF3F5F7));

      // Action circles
      expect(AppColors.actionGold, const Color(0xFF856404));
      expect(AppColors.actionTeal, const Color(0xFF0F766E));
      expect(AppColors.actionSlate, const Color(0xFF50607A));
      expect(AppColors.actionRed, const Color(0xFFB91C1C));
      expect(AppColors.actionPeriwinkle, const Color(0xFFA4B8D1));
    });

    test('2. Typographic Hierarchy Font Families', () {
      final headline = AppTheme.headlineFont(fontSize: 24, fontWeight: FontWeight.bold);
      final body = AppTheme.bodyFont(fontSize: 14, fontWeight: FontWeight.normal);
      final label = AppTheme.labelFont(fontSize: 12, fontWeight: FontWeight.w600);
      final mono = AppTheme.monoFont(fontSize: 12, fontWeight: FontWeight.w600);

      expect(headline.fontFamily, 'Outfit');
      expect(body.fontFamily, 'Plus Jakarta Sans');
      expect(label.fontFamily, 'JetBrains Mono');
      expect(mono.fontFamily, 'JetBrains Mono');

      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.textTheme.headlineLarge?.fontFamily, 'Outfit');
      expect(lightTheme.textTheme.bodyMedium?.fontFamily, 'Plus Jakarta Sans');
      expect(lightTheme.textTheme.labelMedium?.fontFamily, 'JetBrains Mono');
    });

    test('3. Theme Component Shape & Border Tokens', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.scaffoldBackgroundColor, AppColors.backgroundLight);
      expect(dark.scaffoldBackgroundColor, AppColors.backgroundDark);

      // Card radius 22
      final cardShape = light.cardTheme.shape as RoundedRectangleBorder?;
      expect(cardShape?.borderRadius, BorderRadius.circular(22));

      // Filled button radius 22
      final btnShape = light.filledButtonTheme.style?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(btnShape?.borderRadius, BorderRadius.circular(22));

      // Navigation bar indicator circular
      expect(light.navigationBarTheme.indicatorShape, const CircleBorder());
      expect(dark.navigationBarTheme.indicatorShape, const CircleBorder());
    });

    testWidgets('4. Serene Voyage Custom Action Buttons Render Smoothly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: Row(
                children: const [
                  SereneCircleButton(icon: Icons.auto_awesome_rounded, variant: SereneActionVariant.gold),
                  SereneCircleButton(icon: Icons.category_rounded, variant: SereneActionVariant.teal),
                  SereneCircleButton(icon: Icons.label_rounded, variant: SereneActionVariant.slate),
                  SereneCircleButton(icon: Icons.delete_outline_rounded, variant: SereneActionVariant.destructive),
                  SereneCircleButton(icon: Icons.edit_rounded, variant: SereneActionVariant.periwinkle),
                  SerenePillButton(label: 'Label', icon: Icons.edit_rounded),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SereneCircleButton), findsNWidgets(5));
      expect(find.byType(SerenePillButton), findsOneWidget);
      expect(find.text('Label'), findsOneWidget);
    });

    testWidgets('5. AppCard & StatusBadge Monospace Hierarchy', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AppCard(
                child: StatusBadge(
                  label: 'CONFIRMED',
                  backgroundColor: AppColors.successContainerLight,
                  textColor: AppColors.successPastel,
                ),
              ),
            ),
          ),
        ),
      );

      final badgeText = tester.widget<Text>(find.text('CONFIRMED'));
      expect(badgeText.style?.fontFamily, 'JetBrains Mono');
    });

    testWidgets('6. Search Bar & Input Decoration Pill Styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search destinations...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search destinations...'), findsOneWidget);
    });
  });
}

