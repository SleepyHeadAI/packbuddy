import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Screen allowing users to select and compare 2 or more trips side-by-side (Feature F-10)
class TripComparisonScreen extends ConsumerStatefulWidget {
  final List<String>? initialSelectedTripIds;

  const TripComparisonScreen({super.key, this.initialSelectedTripIds});

  @override
  ConsumerState<TripComparisonScreen> createState() => _TripComparisonScreenState();
}

class _TripComparisonScreenState extends ConsumerState<TripComparisonScreen> {
  final Set<String> _selectedTripIds = {};
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedTripIds != null) {
      _selectedTripIds.addAll(widget.initialSelectedTripIds!);
    }
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final items = await DatabaseHelper.instance.getExpenses(includeDeleted: false);
      if (mounted) {
        setState(() {
          _expenses = items;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final tripState = ref.watch(tripControllerProvider);
    final checklistState = ref.watch(checklistControllerProvider);
    final activeCurrency = ref.watch(currencyProvider);

    final allTrips = tripState.trips.where((t) => !t.isDeleted).toList();

    // Live sync expense controllers for compared trips
    for (final tripId in _selectedTripIds) {
      ref.listen(expenseControllerProvider(tripId), (_, next) => _loadExpenses());
    }

    // Auto-select first two trips if none selected
    if (_selectedTripIds.isEmpty && allTrips.length >= 2) {
      _selectedTripIds.add(allTrips[0].id);
      _selectedTripIds.add(allTrips[1].id);
    } else if (_selectedTripIds.isEmpty && allTrips.isNotEmpty) {
      _selectedTripIds.add(allTrips[0].id);
    }

    final selectedTrips = allTrips.where((t) => _selectedTripIds.contains(t.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.compareTrips ?? 'Compare Trips',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: allTrips.length < 2
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.compare_arrows_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n?.selectAtLeastTwoTrips ?? 'Create at least 2 trips to compare',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip Selection Chips
                    Text(
                      l10n?.selectTripsToCompare ?? 'Select Trips to Compare',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allTrips.map((trip) {
                        final isSelected = _selectedTripIds.contains(trip.id);
                        return FilterChip(
                          label: Text(
                            trip.title.isNotEmpty ? trip.title : trip.destination,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTripIds.add(trip.id);
                              } else {
                                if (_selectedTripIds.length > 2) {
                                  _selectedTripIds.remove(trip.id);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n?.selectAtLeastTwoTrips ??
                                            'Select at least 2 trips to compare',
                                      ),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Comparison Cards Grid / Side-by-Side
                    if (selectedTrips.length >= 2) ...[
                      _buildSummaryHighlights(
                        selectedTrips: selectedTrips,
                        expenses: _expenses,
                        items: checklistState.items,
                        activeCurrency: activeCurrency,
                        theme: theme,
                        l10n: l10n,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n?.comparisonSummary ?? 'Side-by-Side Breakdown',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...selectedTrips.map((trip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildTripComparisonCard(
                            trip: trip,
                            expenses: _expenses.where((e) => e.tripId == trip.id).toList(),
                            items: checklistState.items.where((i) => i.tripId == trip.id).toList(),
                            activeCurrency: activeCurrency,
                            theme: theme,
                            l10n: l10n,
                            isDark: isDark,
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryHighlights({
    required List<Trip> selectedTrips,
    required List<Expense> expenses,
    required List<PackingItem> items,
    required String activeCurrency,
    required ThemeData theme,
    required AppLocalizations? l10n,
    required bool isDark,
  }) {
    // Calculate metrics for each trip
    Trip? mostEconomicalTrip;
    double lowestDailyCost = double.infinity;

    Trip? mostPreparedTrip;
    double highestPackingRate = -1;

    for (final trip in selectedTrips) {
      final tripExpenses = expenses.where((e) => e.tripId == trip.id && !e.isDeleted);
      double totalSpentInActive = 0.0;
      for (final exp in tripExpenses) {
        totalSpentInActive += CurrencyService.convert(
          amount: exp.amount,
          fromCurrency: exp.currency,
          toCurrency: activeCurrency,
        );
      }

      final duration = math.max(1, trip.endDate.difference(trip.startDate).inDays + 1);
      final dailyCost = totalSpentInActive / duration;

      if (dailyCost < lowestDailyCost) {
        lowestDailyCost = dailyCost;
        mostEconomicalTrip = trip;
      }

      final tripItems = items.where((i) => i.tripId == trip.id && !i.isDeleted).toList();
      final packedCount = tripItems.where((i) => i.isPacked).length;
      final packingRate = tripItems.isNotEmpty ? (packedCount / tripItems.length) * 100 : 0.0;

      if (packingRate > highestPackingRate) {
        highestPackingRate = packingRate;
        mostPreparedTrip = trip;
      }
    }

    return Row(
      children: [
        if (mostEconomicalTrip != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : const Color(0xFFBBF7D0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.savings_rounded, size: 16, color: AppColors.successPastel),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n?.lowestDailyCost ?? 'Most Economical',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successPastel,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mostEconomicalTrip.title.isNotEmpty
                        ? mostEconomicalTrip.title
                        : mostEconomicalTrip.destination,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${CurrencyFormatter.format(lowestDailyCost, currency: activeCurrency)}/day',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 10),
        if (mostPreparedTrip != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark : const Color(0xFFBFDBFE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.backpack_rounded, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n?.packingReadiness ?? 'Most Prepared',
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
                  const SizedBox(height: 6),
                  Text(
                    mostPreparedTrip.title.isNotEmpty
                        ? mostPreparedTrip.title
                        : mostPreparedTrip.destination,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '%${highestPackingRate.toStringAsFixed(0)} packed',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTripComparisonCard({
    required Trip trip,
    required List<Expense> expenses,
    required List<PackingItem> items,
    required String activeCurrency,
    required ThemeData theme,
    required AppLocalizations? l10n,
    required bool isDark,
  }) {
    double totalSpent = 0.0;
    for (final exp in expenses.where((e) => !e.isDeleted)) {
      totalSpent += CurrencyService.convert(
        amount: exp.amount,
        fromCurrency: exp.currency,
        toCurrency: trip.defaultCurrency,
      );
    }

    final duration = math.max(1, trip.endDate.difference(trip.startDate).inDays + 1);
    final dailyCost = totalSpent / duration;

    final packedCount = items.where((i) => i.isPacked && !i.isDeleted).length;
    final totalItems = items.where((i) => !i.isDeleted).length;
    final packingRate = totalItems > 0 ? (packedCount / totalItems) * 100 : 0.0;

    final budgetLimit = trip.budgetLimit;
    final budgetPercent = (budgetLimit != null && budgetLimit > 0)
        ? (totalSpent / budgetLimit).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Title & Destination
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title.isNotEmpty ? trip.title : trip.destination,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${trip.destination} • $duration days',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trip.isShared) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_alt_rounded, size: 12, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        l10n?.sharedTrip ?? 'Shared',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Budget & Spending Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.totalSpent ?? 'Total Spent',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyFormatter.format(totalSpent, currency: trip.defaultCurrency),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.budget ?? 'Budget Limit',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        budgetLimit != null
                            ? CurrencyFormatter.format(budgetLimit, currency: trip.defaultCurrency)
                            : '-',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.dailyBurnRate ?? 'Daily Cost',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${CurrencyFormatter.format(dailyCost, currency: trip.defaultCurrency)}/d',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Budget Progress Bar
          if (budgetLimit != null && budgetLimit > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budgetPercent,
                minHeight: 5,
                backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                valueColor: AlwaysStoppedAnimation<Color>(
                  totalSpent > budgetLimit ? AppColors.errorPastel : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Packing Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n?.packingReadiness ?? 'Packing'}: $packedCount / $totalItems',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '%${packingRate.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: totalItems > 0 ? (packedCount / totalItems).clamp(0.0, 1.0) : 0.0,
              minHeight: 4,
              backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.successPastel),
            ),
          ),
        ],
      ),
    );
  }
}
