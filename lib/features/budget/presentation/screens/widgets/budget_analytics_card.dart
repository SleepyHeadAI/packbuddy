import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Donut Chart Painter for category spending distribution
class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;

  DonutChartPainter({
    required this.values,
    required this.colors,
    this.strokeWidth = 14.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final total = values.fold<double>(0.0, (sum, v) => sum + v);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    double startAngle = -math.pi / 2;
    final totalArc = 2 * math.pi;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * totalArc;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Slight gap between segments
      final gap = values.length > 1 ? 0.04 : 0.0;
      if (sweepAngle > gap) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + (gap / 2),
          sweepAngle - gap,
          false,
          paint,
        );
      }
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}

/// Interactive Category Breakdown, Donut Chart & Budget Trend Analytics Card (Feature F-4)
class BudgetAnalyticsCard extends StatelessWidget {
  final List<Expense> expenses;
  final String tripCurrency;
  final double totalSpent;
  final Trip? trip;

  const BudgetAnalyticsCard({
    super.key,
    required this.expenses,
    required this.tripCurrency,
    required this.totalSpent,
    this.trip,
  });

  static Color getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('yemek')) {
      return const Color(0xFFF97316); // Amber Orange
    } else if (cat.contains('transport') || cat.contains('ulaşım')) {
      return const Color(0xFF06B6D4); // Cyan
    } else if (cat.contains('accommodation') || cat.contains('konaklama') || cat.contains('otel')) {
      return const Color(0xFF6366F1); // Indigo
    } else if (cat.contains('entertainment') || cat.contains('eğlence') || cat.contains('aktivite')) {
      return const Color(0xFFA855F7); // Purple
    } else if (cat.contains('shopping') || cat.contains('alışveriş')) {
      return const Color(0xFFEC4899); // Pink
    } else {
      return const Color(0xFF64748B); // Slate
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

  static String getCategoryDisplayName(String category, [AppLocalizations? l10n]) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('yemek')) {
      return l10n?.food ?? 'Food & Dining';
    } else if (cat.contains('transport') || cat.contains('ulaşım')) {
      return l10n?.transport ?? 'Transportation';
    } else if (cat.contains('accommodation') || cat.contains('konaklama') || cat.contains('otel')) {
      return l10n?.accommodation ?? 'Accommodation';
    } else if (cat.contains('entertainment') || cat.contains('eğlence') || cat.contains('aktivite')) {
      return l10n?.entertainment ?? 'Entertainment';
    } else if (cat.contains('shopping') || cat.contains('alışveriş')) {
      return l10n?.shopping ?? 'Shopping';
    } else {
      return l10n?.other ?? 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group expenses by standard category and convert amount to trip currency
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};

    for (final exp in expenses) {
      final key = getCategoryDisplayName(exp.category, l10n);
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

    // Donut chart lists
    final chartValues = sortedEntries.map((e) => e.value).toList();
    final chartColors = sortedEntries.map((e) => getCategoryColor(e.key)).toList();

    // Trend analysis & burn rate
    double? dailyBurnRate;
    double? plannedDailyBudget;
    double? projectedTotal;
    int tripDays = 1;
    int remainingDays = 0;
    String pacingStatus = 'onTrack';

    if (trip != null) {
      final duration = trip!.endDate.difference(trip!.startDate).inDays + 1;
      tripDays = duration > 0 ? duration : 1;

      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final tripStart = DateTime(trip!.startDate.year, trip!.startDate.month, trip!.startDate.day);
      final tripEnd = DateTime(trip!.endDate.year, trip!.endDate.month, trip!.endDate.day);

      int elapsedDays = todayDate.difference(tripStart).inDays + 1;
      if (elapsedDays < 1) elapsedDays = 1;
      if (elapsedDays > tripDays) elapsedDays = tripDays;

      remainingDays = tripEnd.difference(todayDate).inDays;
      if (remainingDays < 0) remainingDays = 0;

      dailyBurnRate = totalSpent / elapsedDays;
      if (trip!.budgetLimit != null && trip!.budgetLimit! > 0) {
        plannedDailyBudget = trip!.budgetLimit! / tripDays;
        projectedTotal = dailyBurnRate * tripDays;

        if (totalSpent > trip!.budgetLimit!) {
          pacingStatus = 'over';
        } else if (projectedTotal > trip!.budgetLimit!) {
          pacingStatus = 'warning';
        } else {
          pacingStatus = 'onTrack';
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.30)
                : const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.pie_chart_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.budgetAnalytics ?? 'Budget Analytics',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (topCategory != null && totalSpent > 0) ...[
                      Text(
                        l10n?.topSpendingCategory(topCategory.key, topPercentage) ??
                            'Top: ${topCategory.key} (%$topPercentage)',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n?.expenseCount(expenses.length) ?? '${expenses.length} expenses',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Donut Chart & Center Summary
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: DonutChartPainter(
                      values: chartValues,
                      colors: chartColors,
                      strokeWidth: 14,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n?.total ?? 'Total',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          CurrencyFormatter.format(totalSpent, currency: tripCurrency),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Trend & Burn Rate Statistics (if trip available)
          if (dailyBurnRate != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.dailyBurnRate ?? 'Daily Spend Rate',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyFormatter.format(dailyBurnRate, currency: tripCurrency),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (plannedDailyBudget != null) ...[
                    Container(
                      width: 1,
                      height: 28,
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.budgetEfficiency ?? 'Pacing Status',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                pacingStatus == 'onTrack'
                                    ? Icons.check_circle_rounded
                                    : (pacingStatus == 'warning'
                                        ? Icons.warning_amber_rounded
                                        : Icons.error_rounded),
                                size: 14,
                                color: pacingStatus == 'onTrack'
                                    ? AppColors.successPastel
                                    : (pacingStatus == 'warning'
                                        ? AppColors.warningPastel
                                        : AppColors.errorPastel),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pacingStatus == 'onTrack'
                                      ? (l10n?.budgetStatusOnTrack ?? 'On Track')
                                      : (pacingStatus == 'warning'
                                          ? (l10n?.budgetStatusWarning ?? 'Pacing High')
                                          : (l10n?.budgetStatusOver ?? 'Over Budget')),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: pacingStatus == 'onTrack'
                                        ? AppColors.successPastel
                                        : (pacingStatus == 'warning'
                                            ? AppColors.warningPastel
                                            : AppColors.errorPastel),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Multi-segmented colored distribution bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
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
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Icon(icon, size: 15, color: color)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                catName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            CurrencyFormatter.format(catAmount, currency: tripCurrency),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
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
