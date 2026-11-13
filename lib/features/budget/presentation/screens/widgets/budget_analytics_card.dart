import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'currency_picker_sheet.dart';

/// Donut Chart Painter for category spending distribution
class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final double progress;

  DonutChartPainter({
    required this.values,
    required this.colors,
    this.strokeWidth = 14.0,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || progress <= 0) return;

    final total = values.fold<double>(0.0, (sum, v) => sum + v);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    double startAngle = -math.pi / 2;
    final totalArc = 2 * math.pi * progress;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * totalArc;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Slight gap between segments
      final gap = values.length > 1 ? 0.04 * progress : 0.0;
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
    return oldDelegate.values != values ||
        oldDelegate.colors != colors ||
        oldDelegate.progress != progress;
  }
}

/// Interactive Category Breakdown, Donut Chart & Budget Trend Analytics Card (Feature F-4)
/// Supports real-time multi-currency viewing with top-right currency selector.
class BudgetAnalyticsCard extends StatefulWidget {
  final List<Expense> expenses;
  final String tripCurrency;
  final double totalSpent;
  final Trip? trip;
  final String? selectedCurrency;
  final ValueChanged<String>? onCurrencyChanged;

  const BudgetAnalyticsCard({
    super.key,
    required this.expenses,
    required this.tripCurrency,
    required this.totalSpent,
    this.trip,
    this.selectedCurrency,
    this.onCurrencyChanged,
  });

  static Color getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('yemek')) {
      return AppColors.primaryAmber; // Serene Sun Gold
    } else if (cat.contains('transport') || cat.contains('ulaşım')) {
      return AppColors.secondaryLight; // Serene Pine Teal
    } else if (cat.contains('accommodation') || cat.contains('konaklama') || cat.contains('otel')) {
      return AppColors.tertiaryLight; // Serene Slate Blue
    } else if (cat.contains('entertainment') || cat.contains('eğlence') || cat.contains('aktivite')) {
      return AppColors.actionGold; // Serene Deep Ochre
    } else if (cat.contains('shopping') || cat.contains('alışveriş')) {
      return const Color(0xFF14B8A6); // Serene Radiant Teal
    } else {
      return const Color(0xFF94A3B8); // Serene Soft Slate
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
  State<BudgetAnalyticsCard> createState() => _BudgetAnalyticsCardState();
}

class _BudgetAnalyticsCardState extends State<BudgetAnalyticsCard> {
  late String _currentCurrency;

  @override
  void initState() {
    super.initState();
    _currentCurrency = widget.selectedCurrency ?? widget.tripCurrency;
  }

  @override
  void didUpdateWidget(BudgetAnalyticsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCurrency != null && widget.selectedCurrency != _currentCurrency) {
      _currentCurrency = widget.selectedCurrency!;
    }
  }

  Future<void> _pickCurrency(BuildContext context) async {
    final picked = await CurrencyPickerSheet.show(
      context,
      selectedCurrency: _currentCurrency,
      defaultCurrency: widget.tripCurrency,
    );
    if (picked != null && picked != _currentCurrency) {
      setState(() {
        _currentCurrency = picked;
      });
      widget.onCurrencyChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (widget.expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeCurrency = _currentCurrency;
    final isCustomCurrency = activeCurrency.toUpperCase() != widget.tripCurrency.toUpperCase();

    // Group expenses by standard category and convert amount to activeCurrency
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};
    double convertedTotalSpent = 0.0;

    for (final exp in widget.expenses) {
      final key = BudgetAnalyticsCard.getCategoryDisplayName(exp.category, l10n);
      final converted = CurrencyService.convert(
        amount: exp.amount,
        fromCurrency: exp.currency,
        toCurrency: activeCurrency,
      );
      convertedTotalSpent += converted;
      categoryTotals[key] = (categoryTotals[key] ?? 0.0) + converted;
      categoryCounts[key] = (categoryCounts[key] ?? 0) + 1;
    }

    // Sort categories descending by amount
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedEntries.isNotEmpty ? sortedEntries.first : null;
    final topPercentage = (topCategory != null && convertedTotalSpent > 0)
        ? ((topCategory.value / convertedTotalSpent) * 100).toStringAsFixed(0)
        : '0';

    // Donut chart lists
    final chartValues = sortedEntries.map((e) => e.value).toList();
    final chartColors = sortedEntries.map((e) => BudgetAnalyticsCard.getCategoryColor(e.key)).toList();

    // Trend analysis & burn rate in activeCurrency
    double? dailyBurnRate;
    double? plannedDailyBudget;
    double? projectedTotal;
    int tripDays = 1;
    String pacingStatus = 'onTrack';

    if (widget.trip != null) {
      final trip = widget.trip!;
      final duration = trip.endDate.difference(trip.startDate).inDays + 1;
      tripDays = duration > 0 ? duration : 1;

      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final tripStart = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
      final tripEnd = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day);

      final bool isUpcoming = todayDate.isBefore(tripStart);
      final bool isPast = todayDate.isAfter(tripEnd);

      int elapsedDays;
      if (isUpcoming) {
        elapsedDays = 0;
        dailyBurnRate = convertedTotalSpent / tripDays;
      } else if (isPast) {
        elapsedDays = tripDays;
        dailyBurnRate = convertedTotalSpent / tripDays;
      } else {
        elapsedDays = (todayDate.difference(tripStart).inDays + 1).clamp(1, tripDays);
        dailyBurnRate = convertedTotalSpent / elapsedDays;
      }

      if (trip.budgetLimit != null && trip.budgetLimit! > 0) {
        final originalLimit = trip.budgetLimit!;
        final limit = CurrencyService.convert(
          amount: originalLimit,
          fromCurrency: widget.tripCurrency,
          toCurrency: activeCurrency,
        );
        plannedDailyBudget = limit / tripDays;
        final budgetRatio = limit > 0 ? (convertedTotalSpent / limit) : 0.0;

        if (convertedTotalSpent > limit) {
          pacingStatus = 'over';
        } else if (isUpcoming) {
          pacingStatus = budgetRatio >= 0.90 ? 'warning' : 'onTrack';
        } else if (isPast) {
          pacingStatus = 'onTrack';
        } else {
          final double timeRatio = elapsedDays / tripDays;

          if (elapsedDays <= 1 || widget.expenses.length <= 2) {
            if (budgetRatio <= 0.45) {
              pacingStatus = 'onTrack';
            } else if (budgetRatio > 0.85) {
              pacingStatus = 'warning';
            } else {
              pacingStatus = 'onTrack';
            }
          } else {
            projectedTotal = dailyBurnRate * tripDays;
            if (budgetRatio >= 0.35 &&
                budgetRatio > (timeRatio + 0.20) &&
                projectedTotal > (limit * 1.10)) {
              pacingStatus = 'warning';
            } else {
              pacingStatus = 'onTrack';
            }
          }
        }
      }
    }

    final hasBudget = widget.trip?.budgetLimit != null && widget.trip!.budgetLimit! > 0;
    final convertedLimit = hasBudget
        ? CurrencyService.convert(
            amount: widget.trip!.budgetLimit!,
            fromCurrency: widget.tripCurrency,
            toCurrency: activeCurrency,
          )
        : 0.0;
    final budgetRatio = hasBudget && convertedLimit > 0 ? (convertedTotalSpent / convertedLimit) : 0.0;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
            // Header Row with Title and Top-Right Currency Selector
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
                      if (topCategory != null && convertedTotalSpent > 0) ...[
                        Text(
                          '${l10n?.topSpendingCategory(topCategory.key, topPercentage) ?? 'Top: ${topCategory.key} (%$topPercentage)'} · ${widget.expenses.length}',
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

                // Top-Right Currency Selector on the Chart Card
                Tooltip(
                  message: l10n?.changeCurrency ?? 'Change currency',
                  child: InkWell(
                    key: const Key('chart_currency_selector_button'),
                    onTap: () => _pickCurrency(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCustomCurrency
                            ? theme.colorScheme.primary.withValues(alpha: 0.16)
                            : (isDark
                                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                                : theme.colorScheme.primary.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCustomCurrency
                              ? theme.colorScheme.primary.withValues(alpha: 0.6)
                              : theme.colorScheme.primary.withValues(alpha: 0.2),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CurrencyFormatter.getFlag(activeCurrency),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            activeCurrency,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isCustomCurrency
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (hasBudget && budgetRatio >= 0.85) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (budgetRatio >= 1.0 ? AppColors.errorPastel : AppColors.warningPastel)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (budgetRatio >= 1.0 ? AppColors.errorPastel : AppColors.warningPastel)
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      budgetRatio >= 1.0 ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                      size: 16,
                      color: budgetRatio >= 1.0 ? AppColors.errorPastel : AppColors.warningPastel,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        budgetRatio >= 1.0
                            ? (l10n?.budgetAlert100 ?? 'Budget limit exceeded!')
                            : (l10n?.budgetAlert85 ?? 'Approaching limit (85%)'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: budgetRatio >= 1.0 ? AppColors.errorPastel : AppColors.warningPastel,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),

            // Donut Chart & Center Summary
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      builder: (context, progress, child) {
                        return CustomPaint(
                          size: const Size(140, 140),
                          painter: DonutChartPainter(
                            values: chartValues,
                            colors: chartColors,
                            strokeWidth: 14,
                            progress: progress,
                          ),
                        );
                      },
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
                            CurrencyFormatter.format(convertedTotalSpent, currency: activeCurrency),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (isCustomCurrency) ...[
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '≈ ${CurrencyFormatter.format(widget.totalSpent, currency: widget.tripCurrency)}',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (isCustomCurrency) ...[
              const SizedBox(height: 10),
              Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentCurrency = widget.tripCurrency;
                    });
                    widget.onCurrencyChanged?.call(widget.tripCurrency);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 12, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.tripCurrency} (${CurrencyFormatter.getSymbol(widget.tripCurrency)}) para birimine dön',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

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
                              CurrencyFormatter.format(dailyBurnRate, currency: activeCurrency),
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

            // Multi-segmented colored distribution bar with smooth opening animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, factor, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: sortedEntries.map((entry) {
                        final ratio = convertedTotalSpent > 0 ? (entry.value / convertedTotalSpent).clamp(0.01, 1.0) : 0.0;
                        final color = BudgetAnalyticsCard.getCategoryColor(entry.key);
                        final flexVal = ((ratio * 1000) * factor).toInt();
                        return Flexible(
                          flex: flexVal > 0 ? flexVal : 1,
                          child: Container(
                            color: color,
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Breakdown List by Category
            ...sortedEntries.map((entry) {
              final catName = entry.key;
              final catAmount = entry.value;
              final catCount = categoryCounts[catName] ?? 0;
              final color = BudgetAnalyticsCard.getCategoryColor(catName);
              final icon = BudgetAnalyticsCard.getCategoryIcon(catName);
              final percentage = convertedTotalSpent > 0 ? (catAmount / convertedTotalSpent) * 100 : 0.0;

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
                              CurrencyFormatter.format(catAmount, currency: activeCurrency),
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
                        value: convertedTotalSpent > 0 ? (catAmount / convertedTotalSpent).clamp(0.0, 1.0) : 0.0,
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
      ),
    );
  }
}
