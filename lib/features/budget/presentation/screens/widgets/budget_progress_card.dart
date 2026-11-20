import 'package:flutter/material.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_typography.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/shared/widgets/app_animations.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Minimalist pastel card displaying budget progress, spent, and remaining amounts
class BudgetProgressCard extends StatelessWidget {
  final double? budgetLimit;
  final double totalSpent;
  final String currency;
  final String? originalCurrency;
  final double? originalTotalSpent;
  final VoidCallback? onCurrencyTap;

  const BudgetProgressCard({
    super.key,
    required this.budgetLimit,
    required this.totalSpent,
    required this.currency,
    this.originalCurrency,
    this.originalTotalSpent,
    this.onCurrencyTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasBudget = budgetLimit != null && budgetLimit! > 0;
    final remaining = hasBudget ? (budgetLimit! - totalSpent) : 0.0;
    final progress = hasBudget ? (totalSpent / budgetLimit!).clamp(0.0, 1.0) : 0.0;
    final ratio = hasBudget ? (totalSpent / budgetLimit!) : 0.0;

    // Serene semantic colors based on budget health
    Color progressColor;
    if (ratio > 1.0 || progress > 0.95) {
      progressColor = isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
    } else if (ratio >= 0.8) {
      progressColor = const Color(0xFFD97706);
    } else {
      progressColor = isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
    }

    return RepaintBoundary(
      child: AppCard(
        borderRadius: AppRadius.card,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.budget,
                          style: AppTypography.title(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onCurrencyTap != null) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          key: const Key('budget_card_currency_chip'),
                          onTap: onCurrencyTap,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  CurrencyFormatter.getFlag(currency),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  currency,
                                  style: AppTypography.mono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                    tabularFigures: true,
                                  ),
                                ),
                                const SizedBox(width: 1),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasBudget) ...[
                  const SizedBox(width: 8),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: progressColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '%${(val * 100).toInt()}',
                          style: AppTypography.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: progressColor,
                            tabularFigures: true,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            if (hasBudget && ratio >= 0.85) ...[
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final isCrit = ratio >= 1.0;
                  final alertColor = isCrit
                      ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C))
                      : (isDark ? const Color(0xFFFDE68A) : AppColors.brandAccentTextLight);
                  final alertBg = isCrit
                      ? (isDark ? const Color(0xFF450A0A).withValues(alpha: 0.35) : const Color(0xFFFEE2E2))
                      : (isDark ? const Color(0xFF422E00).withValues(alpha: 0.35) : const Color(0xFFFEF3C7));
                  final alertBorder = isCrit
                      ? (isDark ? const Color(0xFFDC2626).withValues(alpha: 0.45) : const Color(0xFFFECACA))
                      : (isDark ? const Color(0xFFD97706).withValues(alpha: 0.45) : const Color(0xFFFDE68A));

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: alertBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: alertBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCrit ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                          size: 16,
                          color: alertColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isCrit ? l10n.budgetAlert100 : l10n.budgetAlert85,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: alertColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 16),

          // Smooth Animated Progress Bar (Linear)
          if (hasBudget) ...[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 750),
              curve: Curves.easeOutCubic,
              builder: (context, val, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: val,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
          ],

          // Numbers Row (Total, Spent, Remaining)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Total Spent
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.spent,
                        style: AppTypography.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: AnimatedCurrencyCounter(
                          value: totalSpent,
                          currency: currency,
                          style: AppTypography.mono(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            tabularFigures: true,
                          ),
                        ),
                      ),
                      if (originalCurrency != null &&
                          originalTotalSpent != null &&
                          originalCurrency != currency) ...[
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '≈ ${CurrencyFormatter.format(originalTotalSpent!, currency: originalCurrency!)}',
                            style: AppTypography.mono(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                              tabularFigures: true,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Remaining Budget (if set)
                if (hasBudget) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.remaining,
                          style: AppTypography.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: AnimatedCurrencyCounter(
                            value: remaining,
                            currency: currency,
                            style: AppTypography.mono(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: remaining < 0
                                  ? (isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626))
                                  : (isDark ? const Color(0xFF10B981) : const Color(0xFF059669)),
                              tabularFigures: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
