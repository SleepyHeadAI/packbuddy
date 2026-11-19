import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/budget_localization.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'currency_picker_sheet.dart';

/// Available chart views in the Budget Analytics Card
enum AnalyticsChartType {
  category,
  paymentMethod,
  dailyTrend,
}

/// Donut Chart Painter for category & payment spending distribution
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

/// Interactive Category Breakdown, Payment Method Analytics, Daily Spend Timeline
/// & Deep Insights Card (Feature F-4 & Advanced Analytics Suite).
/// Default view is minimalist and focused; detail-oriented users can toggle optional
/// payment method donut, daily timeline bars, and deep statistical cards.
class BudgetAnalyticsCard extends StatefulWidget {
  final List<Expense> expenses;
  final String tripCurrency;
  final double totalSpent;
  final Trip? trip;
  final String? selectedCurrency;
  final ValueChanged<String>? onCurrencyChanged;
  final VoidCallback? onSetAsBaseCurrency;

  const BudgetAnalyticsCard({
    super.key,
    required this.expenses,
    required this.tripCurrency,
    required this.totalSpent,
    this.trip,
    this.selectedCurrency,
    this.onCurrencyChanged,
    this.onSetAsBaseCurrency,
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

  static String canonicalPaymentMethodKey(String? method) {
    if (method == null || method.trim().isEmpty) return 'Other';
    final m = method.toLowerCase().replaceAll(' ', '');
    if (m.contains('credit') || m.contains('kredi')) return 'CreditCard';
    if (m.contains('cash') || m.contains('nakit')) return 'Cash';
    if (m.contains('debit') || m.contains('banka')) return 'DebitCard';
    if (m.contains('wallet') || m.contains('cüzdan')) return 'DigitalWallet';
    if (m.contains('online')) return 'Online';
    if (m == 'other' || m == 'diğer') return 'Other';
    return method;
  }

  static Color getPaymentMethodColor(String? method) {
    final key = canonicalPaymentMethodKey(method);
    switch (key) {
      case 'CreditCard':
        return const Color(0xFF0EA5E9); // Sky blue
      case 'Cash':
        return AppColors.primaryAmber; // Amber
      case 'DebitCard':
        return const Color(0xFF10B981); // Emerald
      case 'DigitalWallet':
        return const Color(0xFF8B5CF6); // Purple
      case 'Online':
        return const Color(0xFF06B6D4); // Cyan
      case 'Other':
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  static IconData getPaymentMethodIcon(String? method) {
    final key = canonicalPaymentMethodKey(method);
    switch (key) {
      case 'CreditCard':
        return Icons.credit_card_rounded;
      case 'Cash':
        return Icons.payments_outlined;
      case 'DebitCard':
        return Icons.account_balance_wallet_outlined;
      case 'DigitalWallet':
        return Icons.contactless_outlined;
      case 'Online':
        return Icons.language_rounded;
      case 'Other':
      default:
        return Icons.payment_rounded;
    }
  }

  static String getPaymentMethodDisplayName(String? method, [AppLocalizations? l10n]) {
    final key = canonicalPaymentMethodKey(method);
    switch (key) {
      case 'CreditCard':
        return l10n?.creditCard ?? 'Credit Card';
      case 'Cash':
        return l10n?.cash ?? 'Cash';
      case 'DebitCard':
        return l10n?.debitCard ?? 'Debit Card';
      case 'DigitalWallet':
        return l10n?.digitalWallet ?? 'Digital Wallet';
      case 'Online':
        return l10n?.onlinePayment ?? 'Online';
      case 'Other':
      default:
        return l10n?.other ?? 'Other';
    }
  }

  @override
  State<BudgetAnalyticsCard> createState() => _BudgetAnalyticsCardState();
}

class _BudgetAnalyticsCardState extends State<BudgetAnalyticsCard> {
  late String _currentCurrency;
  AnalyticsChartType _chartType = AnalyticsChartType.category;
  bool _isDeepStatsExpanded = false;

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
    final lang = Localizations.localeOf(context).languageCode;

    if (widget.expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeCurrency = _currentCurrency;
    final isCustomCurrency = activeCurrency.toUpperCase() != widget.tripCurrency.toUpperCase();

    // 1. Group expenses by standard category and convert amount to activeCurrency
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

    final sortedCategoryEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategory = sortedCategoryEntries.isNotEmpty ? sortedCategoryEntries.first : null;
    final topCategoryPercentage = (topCategory != null && convertedTotalSpent > 0)
        ? ((topCategory.value / convertedTotalSpent) * 100).toStringAsFixed(0)
        : '0';

    final categoryChartValues = sortedCategoryEntries.map((e) => e.value).toList();
    final categoryChartColors = sortedCategoryEntries.map((e) => BudgetAnalyticsCard.getCategoryColor(e.key)).toList();

    // 2. Group expenses by payment method
    final paymentTotals = <String, double>{};
    final paymentCounts = <String, int>{};
    double cashTotal = 0.0;

    for (final exp in widget.expenses) {
      final key = BudgetAnalyticsCard.canonicalPaymentMethodKey(exp.paymentMethod);
      final converted = CurrencyService.convert(
        amount: exp.amount,
        fromCurrency: exp.currency,
        toCurrency: activeCurrency,
      );
      paymentTotals[key] = (paymentTotals[key] ?? 0.0) + converted;
      paymentCounts[key] = (paymentCounts[key] ?? 0) + 1;
      if (key == 'Cash') {
        cashTotal += converted;
      }
    }

    final sortedPaymentEntries = paymentTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topPayment = sortedPaymentEntries.isNotEmpty ? sortedPaymentEntries.first : null;
    final topPaymentName = topPayment != null
        ? BudgetAnalyticsCard.getPaymentMethodDisplayName(topPayment.key, l10n)
        : '';
    final topPaymentPercentage = (topPayment != null && convertedTotalSpent > 0)
        ? ((topPayment.value / convertedTotalSpent) * 100).toStringAsFixed(0)
        : '0';

    final paymentChartValues = sortedPaymentEntries.map((e) => e.value).toList();
    final paymentChartColors = sortedPaymentEntries.map((e) => BudgetAnalyticsCard.getPaymentMethodColor(e.key)).toList();

    final cardAndDigitalTotal = convertedTotalSpent - cashTotal;
    final cashPct = convertedTotalSpent > 0 ? ((cashTotal / convertedTotalSpent) * 100).round() : 0;
    final cardPct = 100 - cashPct;

    // 3. Group expenses by date for Daily Timeline Trend
    final dailySpends = <DateTime, double>{};
    for (final exp in widget.expenses) {
      final dateKey = DateTime(exp.date.year, exp.date.month, exp.date.day);
      final converted = CurrencyService.convert(
        amount: exp.amount,
        fromCurrency: exp.currency,
        toCurrency: activeCurrency,
      );
      dailySpends[dateKey] = (dailySpends[dateKey] ?? 0.0) + converted;
    }

    final sortedDailyEntries = dailySpends.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    DateTime? peakDay;
    double peakDayAmount = 0.0;
    for (final entry in sortedDailyEntries) {
      if (entry.value > peakDayAmount) {
        peakDayAmount = entry.value;
        peakDay = entry.key;
      }
    }

    // 4. Trend analysis & burn rate in activeCurrency
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

    // Deep Analytics Metrics
    final avgTransaction = widget.expenses.isNotEmpty
        ? convertedTotalSpent / widget.expenses.length
        : 0.0;

    Expense? highestExp;
    Expense? lowestExp;
    for (final exp in widget.expenses) {
      if (highestExp == null || exp.amount > highestExp.amount) {
        highestExp = exp;
      }
      if (lowestExp == null || exp.amount < lowestExp.amount) {
        lowestExp = exp;
      }
    }

    final highestExpConverted = highestExp != null
        ? CurrencyService.convert(
            amount: highestExp.amount,
            fromCurrency: highestExp.currency,
            toCurrency: activeCurrency,
          )
        : 0.0;

    final lowestExpConverted = lowestExp != null
        ? CurrencyService.convert(
            amount: lowestExp.amount,
            fromCurrency: lowestExp.currency,
            toCurrency: activeCurrency,
          )
        : 0.0;

    // Safe remaining daily budget calculation
    double? safeDailySpendAmount;
    if (hasBudget && convertedLimit > convertedTotalSpent) {
      final remainingBudget = convertedLimit - convertedTotalSpent;
      final remainingDays = widget.trip != null
          ? math.max(1, widget.trip!.endDate.difference(DateTime.now()).inDays + 1)
          : tripDays;
      safeDailySpendAmount = remainingBudget / remainingDays;
    }

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
                      _chartType == AnalyticsChartType.category
                          ? Icons.pie_chart_rounded
                          : (_chartType == AnalyticsChartType.paymentMethod
                              ? Icons.credit_card_rounded
                              : Icons.bar_chart_rounded),
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
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              l10n?.expenseCount(widget.expenses.length) ?? '${widget.expenses.length} Harcama',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (topCategory != null && convertedTotalSpent > 0) ...[
                        Text(
                          _chartType == AnalyticsChartType.category
                              ? (l10n?.topSpendingCategory(topCategory.key, topCategoryPercentage) ?? 'Top: ${topCategory.key} (%$topCategoryPercentage)')
                              : (_chartType == AnalyticsChartType.paymentMethod
                                  ? '$topPaymentName (%$topPaymentPercentage)'
                                  : '${BudgetLocalization.peakSpendDay(lang)}: ${peakDay != null ? AppDateFormatter.formatMMMd(peakDay, locale: lang) : ''}'),
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

            const SizedBox(height: 14),

            // Minimalist Chart Type Switcher Pills
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                ),
              ),
              child: Row(
                children: [
                  _buildChartTabItem(
                    type: AnalyticsChartType.category,
                    icon: Icons.pie_chart_outline_rounded,
                    label: BudgetLocalization.chartTypeCategory(lang),
                    theme: theme,
                    isDark: isDark,
                  ),
                  _buildChartTabItem(
                    type: AnalyticsChartType.paymentMethod,
                    icon: Icons.payment_rounded,
                    label: BudgetLocalization.chartTypePayment(lang),
                    theme: theme,
                    isDark: isDark,
                  ),
                  _buildChartTabItem(
                    type: AnalyticsChartType.dailyTrend,
                    icon: Icons.bar_chart_rounded,
                    label: BudgetLocalization.chartTypeTimeline(lang),
                    theme: theme,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main Visual View according to selected _chartType
            if (_chartType == AnalyticsChartType.category) ...[
              _buildCategoryChartView(
                context,
                theme,
                isDark,
                l10n,
                lang,
                activeCurrency,
                isCustomCurrency,
                convertedTotalSpent,
                sortedCategoryEntries,
                categoryCounts,
                categoryChartValues,
                categoryChartColors,
                dailyBurnRate,
                plannedDailyBudget,
                pacingStatus,
              ),
            ] else if (_chartType == AnalyticsChartType.paymentMethod) ...[
              _buildPaymentMethodChartView(
                context,
                theme,
                isDark,
                l10n,
                lang,
                activeCurrency,
                isCustomCurrency,
                convertedTotalSpent,
                sortedPaymentEntries,
                paymentCounts,
                paymentChartValues,
                paymentChartColors,
                topPaymentName,
                topPaymentPercentage,
                cashPct,
                cardPct,
                cashTotal,
                cardAndDigitalTotal,
              ),
            ] else ...[
              _buildDailyTimelineChartView(
                context,
                theme,
                isDark,
                l10n,
                lang,
                activeCurrency,
                convertedTotalSpent,
                sortedDailyEntries,
                peakDay,
                peakDayAmount,
                tripDays,
              ),
            ],

            const SizedBox(height: 18),

            // Collapsible "Detaylı İstatistikler & Analiz" Accordion for Power Users
            _buildDeepAnalyticsAccordion(
              context,
              theme,
              isDark,
              l10n,
              lang,
              activeCurrency,
              convertedTotalSpent,
              avgTransaction,
              highestExp,
              highestExpConverted,
              lowestExp,
              lowestExpConverted,
              peakDay,
              peakDayAmount,
              cashPct,
              cardPct,
              categoryTotals.length,
              topCategory?.key,
              dailyBurnRate,
              tripDays,
              safeDailySpendAmount,
              pacingStatus,
            ),
          ],
        ),
      ),
    );
  }

  /// Minimalist Segment Tab Pill
  Widget _buildChartTabItem({
    required AnalyticsChartType type,
    required IconData icon,
    required String label,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _chartType == type;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            setState(() {
              _chartType = type;
            });
          }
        },
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? theme.colorScheme.primaryContainer : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Category Chart View (Default)
  Widget _buildCategoryChartView(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    String lang,
    String activeCurrency,
    bool isCustomCurrency,
    double convertedTotalSpent,
    List<MapEntry<String, double>> sortedEntries,
    Map<String, int> categoryCounts,
    List<double> chartValues,
    List<Color> chartColors,
    double? dailyBurnRate,
    double? plannedDailyBudget,
    String pacingStatus,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          const SizedBox(height: 12),
          _buildCurrencyActionChips(context, theme, isDark, lang, activeCurrency, l10n),
        ],

        const SizedBox(height: 16),

        // Trend & Burn Rate Statistics (if trip available)
        if (dailyBurnRate != null) ...[
          _buildBurnRateBar(theme, isDark, l10n, activeCurrency, dailyBurnRate, plannedDailyBudget, pacingStatus),
          const SizedBox(height: 16),
        ],

        // Multi-segmented colored distribution bar
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
    );
  }

  /// 2. Payment Method Chart View (Optional / Extra)
  Widget _buildPaymentMethodChartView(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    String lang,
    String activeCurrency,
    bool isCustomCurrency,
    double convertedTotalSpent,
    List<MapEntry<String, double>> sortedEntries,
    Map<String, int> paymentCounts,
    List<double> chartValues,
    List<Color> chartColors,
    String topPaymentName,
    String topPaymentPercentage,
    int cashPct,
    int cardPct,
    double cashTotal,
    double cardAndDigitalTotal,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Donut Chart & Center Payment Highlight
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
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
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
                    if (topPaymentName.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        '%$topPaymentPercentage $topPaymentName',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Cash vs Card Balance Summary Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.credit_card_rounded, size: 15, color: Color(0xFF0EA5E9)),
                  const SizedBox(width: 6),
                  Text(
                    '${BudgetLocalization.cashVsCard(lang).split('/').last.trim()}: %$cardPct',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(width: 1, height: 16, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payments_outlined, size: 15, color: AppColors.primaryAmber),
                  const SizedBox(width: 6),
                  Text(
                    '${BudgetLocalization.cashVsCard(lang).split('/').first.trim()}: %$cashPct',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Multi-segmented colored distribution bar for payment methods
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
                    final color = BudgetAnalyticsCard.getPaymentMethodColor(entry.key);
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

        // Payment Methods Breakdown List
        ...sortedEntries.map((entry) {
          final methodKey = entry.key;
          final methodAmount = entry.value;
          final methodCount = paymentCounts[methodKey] ?? 0;
          final methodName = BudgetAnalyticsCard.getPaymentMethodDisplayName(methodKey, l10n);
          final color = BudgetAnalyticsCard.getPaymentMethodColor(methodKey);
          final icon = BudgetAnalyticsCard.getPaymentMethodIcon(methodKey);
          final percentage = convertedTotalSpent > 0 ? (methodAmount / convertedTotalSpent) * 100 : 0.0;

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
                              methodName,
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
                            '($methodCount)',
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
                          CurrencyFormatter.format(methodAmount, currency: activeCurrency),
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
                    value: convertedTotalSpent > 0 ? (methodAmount / convertedTotalSpent).clamp(0.0, 1.0) : 0.0,
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
    );
  }

  /// 3. Daily Timeline Trend Bar Chart View
  Widget _buildDailyTimelineChartView(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    String lang,
    String activeCurrency,
    double convertedTotalSpent,
    List<MapEntry<DateTime, double>> sortedDailyEntries,
    DateTime? peakDay,
    double peakDayAmount,
    int tripDays,
  ) {
    if (sortedDailyEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(l10n?.noExpensesYet ?? 'No expenses yet'),
        ),
      );
    }

    final maxVal = peakDayAmount > 0 ? peakDayAmount : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily Spend Bar Visualizer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.outlineDark : AppColors.outlineLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${BudgetLocalization.chartTypeTimeline(lang)} ${BudgetLocalization.timelineDays(lang, sortedDailyEntries.length)}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (peakDay != null)
                    Text(
                      BudgetLocalization.peakLabel(lang, CurrencyFormatter.format(peakDayAmount, currency: activeCurrency)),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryAmber,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Interactive Bar Chart
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: sortedDailyEntries.map((entry) {
                    final dayDate = entry.key;
                    final amount = entry.value;
                    final heightFactor = (amount / maxVal).clamp(0.08, 1.0);
                    final isPeak = dayDate == peakDay;
                    final dateLabel = AppDateFormatter.formatMMMd(dayDate, locale: lang);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                CurrencyFormatter.format(amount, currency: activeCurrency).split(' ').first,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: isPeak ? AppColors.primaryAmber : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  height: 65 * heightFactor,
                                  decoration: BoxDecoration(
                                    color: isPeak
                                        ? AppColors.primaryAmber
                                        : theme.colorScheme.primary.withValues(alpha: 0.7),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                dateLabel,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isPeak ? FontWeight.w800 : FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // List of days
        ...sortedDailyEntries.reversed.map((entry) {
          final isPeak = entry.key == peakDay;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  isPeak ? Icons.star_rounded : Icons.calendar_today_rounded,
                  size: 14,
                  color: isPeak ? AppColors.primaryAmber : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppDateFormatter.formatMMMd(entry.key, locale: lang),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isPeak ? FontWeight.w800 : FontWeight.w600,
                      color: isPeak ? AppColors.primaryAmber : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(entry.value, currency: activeCurrency),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isPeak ? AppColors.primaryAmber : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 4. Collapsible Deep Statistics & Insights Accordion
  Widget _buildDeepAnalyticsAccordion(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    String lang,
    String activeCurrency,
    double convertedTotalSpent,
    double avgTransaction,
    Expense? highestExp,
    double highestExpConverted,
    Expense? lowestExp,
    double lowestExpConverted,
    DateTime? peakDay,
    double peakDayAmount,
    int cashPct,
    int cardPct,
    int categoryDiversityCount,
    String? topCategoryName,
    double? dailyBurnRate,
    int tripDays,
    double? safeDailySpendAmount,
    String pacingStatus,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accordion Header Bar
          InkWell(
            onTap: () {
              setState(() {
                _isDeepStatsExpanded = !_isDeepStatsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.insights_rounded, size: 16, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          BudgetLocalization.deepStatsTitle(lang),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _isDeepStatsExpanded
                              ? BudgetLocalization.deepStatsCollapse(lang)
                              : BudgetLocalization.deepStatsExplore(lang),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isDeepStatsExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          if (_isDeepStatsExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.receipt_long_rounded,
                          color: const Color(0xFF0EA5E9),
                          title: BudgetLocalization.averageTransaction(lang),
                          value: CurrencyFormatter.format(avgTransaction, currency: activeCurrency),
                          subtitle: '${widget.expenses.length} ${l10n?.expenseCount(widget.expenses.length) ?? 'harcama'}',
                          theme: theme,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.trending_up_rounded,
                          color: AppColors.errorPastel,
                          title: BudgetLocalization.highestExpense(lang),
                          value: CurrencyFormatter.format(highestExpConverted, currency: activeCurrency),
                          subtitle: highestExp?.title ?? '',
                          theme: theme,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.star_rounded,
                          color: AppColors.primaryAmber,
                          title: BudgetLocalization.peakSpendDay(lang),
                          value: CurrencyFormatter.format(peakDayAmount, currency: activeCurrency),
                          subtitle: peakDay != null ? AppDateFormatter.formatMMMd(peakDay, locale: lang) : '',
                          theme: theme,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.balance_rounded,
                          color: const Color(0xFF10B981),
                          title: BudgetLocalization.cashVsCard(lang),
                          value: BudgetLocalization.formatRatioPercent(lang, cardPct, cashPct),
                          subtitle: BudgetLocalization.cardVsCashSubtitle(lang),
                          theme: theme,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.category_rounded,
                          color: const Color(0xFF8B5CF6),
                          title: BudgetLocalization.categoryDiversity(lang),
                          value: BudgetLocalization.formatCategoryCount(lang, categoryDiversityCount),
                          subtitle: topCategoryName != null && topCategoryName.isNotEmpty
                              ? BudgetLocalization.formatTopCategory(lang, BudgetAnalyticsCard.getCategoryDisplayName(topCategoryName, l10n))
                              : '',
                          theme: theme,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.speed_rounded,
                          color: pacingStatus == 'onTrack'
                              ? AppColors.successPastel
                              : (pacingStatus == 'warning' ? AppColors.warningPastel : AppColors.errorPastel),
                          title: safeDailySpendAmount != null
                              ? BudgetLocalization.safeDailySpend(lang)
                              : (l10n?.dailyBurnRate ?? 'Daily Spend'),
                          value: CurrencyFormatter.format(
                            safeDailySpendAmount ?? (dailyBurnRate ?? (convertedTotalSpent / tripDays)),
                            currency: activeCurrency,
                          ),
                          subtitle: safeDailySpendAmount != null
                              ? BudgetLocalization.perRemainingDay(lang)
                              : BudgetLocalization.dailyAverage(lang),
                          theme: theme,
                          isDark: isDark,
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
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Currency switch actions
  Widget _buildCurrencyActionChips(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String lang,
    String activeCurrency,
    AppLocalizations? l10n,
  ) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          if (widget.onSetAsBaseCurrency != null)
            InkWell(
              key: const Key('set_as_base_currency_button'),
              onTap: widget.onSetAsBaseCurrency,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                constraints: BoxConstraints(maxWidth: math.max(120, MediaQuery.of(context).size.width - 64)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 13, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        BudgetLocalization.makeTripCurrency(lang, activeCurrency),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            key: const Key('revert_to_trip_currency_button'),
            onTap: () {
              setState(() {
                _currentCurrency = widget.tripCurrency;
              });
              widget.onCurrencyChanged?.call(widget.tripCurrency);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              constraints: BoxConstraints(maxWidth: math.max(120, MediaQuery.of(context).size.width - 64)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 12, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      l10n?.revertToCurrency('${widget.tripCurrency} (${CurrencyFormatter.getSymbol(widget.tripCurrency)})') ??
                          'Switch back to ${widget.tripCurrency} (${CurrencyFormatter.getSymbol(widget.tripCurrency)})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Burn Rate and Pacing Bar
  Widget _buildBurnRateBar(
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    String activeCurrency,
    double dailyBurnRate,
    double? plannedDailyBudget,
    String pacingStatus,
  ) {
    return Container(
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
    );
  }
}
