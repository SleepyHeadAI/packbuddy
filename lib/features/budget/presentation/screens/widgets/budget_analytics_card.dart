import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';

/// Interactive Category Breakdown & Budget Analytics Card
class BudgetAnalyticsCard extends StatelessWidget {
  final List<Expense> expenses;
  final String tripCurrency;
  final double totalSpent;

  const BudgetAnalyticsCard({
    super.key,
    required this.expenses,
    required this.tripCurrency,
    required this.totalSpent,
  });

  static Color getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('yemek')) {
      return AppColors.tertiaryLight;
    } else if (cat.contains('transport') || cat.contains('ulaşım')) {
      return AppColors.secondaryLight;
    } else if (cat.contains('accommodation') || cat.contains('konaklama') || cat.contains('otel')) {
      return AppColors.primaryLight;
    } else if (cat.contains('entertainment') || cat.contains('eğlence') || cat.contains('aktivite')) {
      return AppColors.warningPastel;
    } else if (cat.contains('shopping') || cat.contains('alışveriş')) {
      return const Color(0xFFEC4899);
    } else {
      return const Color(0xFF8B5CF6);
    }
  }

  static IconData getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('yemek')) {
      return Icons.restaurant_rounded;
    } else if (cat.contains('transport') || cat.contains('ulaşım')) {
      return Icons.directions_subway_rounded;
    } else if (cat.contains('accommodation') || cat.contains('konaklama') || cat.contains('otel')) {
      return Icons.hotel_rounded;
    } else if (cat.contains('entertainment') || cat.contains('eğlence') || cat.contains('aktivite')) {
      return Icons.attractions_rounded;
    } else if (cat.contains('shopping') || cat.contains('alışveriş')) {
      return Icons.shopping_bag_rounded;
    } else {
      return Icons.receipt_long_rounded;
    }
  }

  static String getCategoryDisplayName(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('yemek')) {
      return 'Yeme & İçme';
    } else if (cat.contains('transport') || cat.contains('ulaşım')) {
      return 'Ulaşım';
    } else if (cat.contains('accommodation') || cat.contains('konaklama') || cat.contains('otel')) {
      return 'Konaklama';
    } else if (cat.contains('entertainment') || cat.contains('eğlence') || cat.contains('aktivite')) {
      return 'Aktivite & Eğlence';
    } else if (cat.contains('shopping') || cat.contains('alışveriş')) {
      return 'Alışveriş';
    } else {
      return 'Diğer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group expenses by standard category and convert amount to trip currency
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};

    for (final exp in expenses) {
      final key = getCategoryDisplayName(exp.category);
      final converted = CurrencyService.convert(
        amount: exp.amount,
        fromCurrency: exp.currency,
        toCurrency: tripCurrency,
      );
      categoryTotals[key] = (categoryTotals[key] ?? 0.0) + converted;
      categoryCounts[key] = (categoryCounts[key] ?? 0) + 1;
    }

    // Sort categories descending by amount
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedEntries.isNotEmpty ? sortedEntries.first : null;
    final topPercentage = (topCategory != null && totalSpent > 0)
        ? ((topCategory.value / totalSpent) * 100).toStringAsFixed(0)
        : '0';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : theme.colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori Harcama Analizi',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (topCategory != null && totalSpent > 0) ...[
                      Text(
                        'En çok: ${topCategory.key} (%$topPercentage)',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${expenses.length} Harcama',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Multi-segmented colored distribution bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: sortedEntries.map((entry) {
                  final ratio = totalSpent > 0 ? (entry.value / totalSpent).clamp(0.01, 1.0) : 0.0;
                  final color = getCategoryColor(entry.key);
                  return Flexible(
                    flex: (ratio * 1000).toInt(),
                    child: Container(
                      color: color,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Breakdown List by Category
          ...sortedEntries.map((entry) {
            final catName = entry.key;
            final catAmount = entry.value;
            final catCount = categoryCounts[catName] ?? 0;
            final color = getCategoryColor(catName);
            final icon = getCategoryIcon(catName);
            final percentage = totalSpent > 0 ? (catAmount / totalSpent) * 100 : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 14, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              catName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($catCount)',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(catAmount, currency: tripCurrency),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        child: Text(
                          '%${percentage.toStringAsFixed(0)}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Category percentage mini bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: totalSpent > 0 ? (catAmount / totalSpent).clamp(0.0, 1.0) : 0.0,
                      backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
