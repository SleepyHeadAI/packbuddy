import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_progress_card.dart';
import 'package:packbuddy/features/budget/presentation/widgets/currency_converter_card.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

void main() {
  group('Phase 5: BudgetProgressCard Design System & Semantic Color Progression', () {
    testWidgets('Budget under 80% uses calm emerald progress color and AppRadius.card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: BudgetProgressCard(
              budgetLimit: 1000.0,
              totalSpent: 400.0,
              currency: 'EUR',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify AppCard with AppRadius.card (22.0)
      final appCard = tester.widget<AppCard>(find.byType(AppCard));
      expect(appCard.borderRadius, equals(AppRadius.card));
      expect(appCard.borderRadius, equals(22.0));

      // Verify LinearProgressIndicator color is calm emerald
      final indicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      final colorAnim = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(colorAnim.value, equals(const Color(0xFF059669))); // light emerald
    });

    testWidgets('Budget between 80% and 100% uses warm amber and accessible contrast alert on light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: BudgetProgressCard(
              budgetLimit: 1000.0,
              totalSpent: 900.0,
              currency: 'USD',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Progress bar color should be warm amber
      final indicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      final colorAnim = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(colorAnim.value, equals(const Color(0xFFD97706)));

      // Warning text should be rendered with AppColors.brandAccentTextLight (#92400E) for WCAG AA 4.5:1 contrast
      final alertIcon = tester.widget<Icon>(find.byIcon(Icons.warning_amber_rounded));
      expect(alertIcon.color, equals(AppColors.brandAccentTextLight));
      expect(alertIcon.color, equals(const Color(0xFF92400E)));
    });

    testWidgets('Budget over 100% uses serene red progress color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: BudgetProgressCard(
              budgetLimit: 1000.0,
              totalSpent: 1250.0,
              currency: 'USD',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final indicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      final colorAnim = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(colorAnim.value, equals(const Color(0xFFDC2626))); // light serene red
    });

    testWidgets('Percentage badge and currency counters use AppTypography.mono with tabular figures', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: BudgetProgressCard(
              budgetLimit: 1000.0,
              totalSpent: 500.0,
              currency: 'EUR',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Percentage badge text
      final percentFinder = find.text('%50');
      expect(percentFinder, findsOneWidget);
      final percentWidget = tester.widget<Text>(percentFinder);
      expect(percentWidget.style?.fontFeatures?.any((f) => f.feature == 'tnum'), isTrue);

      // Remaining counter
      final remainingFinder = find.textContaining('500');
      expect(remainingFinder, findsWidgets);
    });
  });

  group('Phase 5: CurrencyConverterCard Refinement', () {
    testWidgets('CurrencyConverterCard renders with AppRadius.card and mono typography for conversion result', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: CurrencyConverterCard(
                initialAmount: 100,
                initialFromCurrency: 'USD',
                initialToCurrency: 'EUR',
                isModal: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check AppCard has AppRadius.card
      final appCard = tester.widget<AppCard>(find.byType(AppCard));
      expect(appCard.borderRadius, equals(AppRadius.card));
    });
  });

  group('Phase 5: Viewport Responsiveness & Zero Overflows', () {
    for (final isDark in [false, true]) {
      final modeName = isDark ? 'Dark' : 'Light';

      testWidgets('BudgetProgressCard renders cleanly on compact 320x568 ($modeName)', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: BudgetProgressCard(
                budgetLimit: 5000000.0,
                totalSpent: 4250000.0,
                currency: 'JPY',
                originalCurrency: 'USD',
                originalTotalSpent: 28500.0,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(BudgetProgressCard), findsOneWidget);
      });

      testWidgets('CurrencyConverterCard renders cleanly on compact 320x568 ($modeName)', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: CurrencyConverterCard(
                  initialAmount: 250,
                  initialFromCurrency: 'EUR',
                  initialToCurrency: 'TRY',
                  isModal: false,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CurrencyConverterCard), findsOneWidget);
      });
    }
  });
}
