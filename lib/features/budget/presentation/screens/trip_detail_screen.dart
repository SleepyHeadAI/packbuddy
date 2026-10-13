import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_progress_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';

/// Trip Detail and Budget Dashboard Screen
class TripDetailScreen extends ConsumerWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return AppColors.tertiaryLight;
      case 'Transport':
        return AppColors.secondaryLight;
      case 'Accommodation':
        return AppColors.primaryLight;
      case 'Entertainment':
        return AppColors.warningPastel;
      default:
        return AppColors.secondaryDark;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_subway_rounded;
      case 'Accommodation':
        return Icons.hotel_rounded;
      case 'Entertainment':
        return Icons.attractions_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  IconData _getPaymentIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'cash':
      case 'nakit':
        return Icons.payments_outlined;
      case 'credit card':
      case 'kredi kartı':
      case 'creditcard':
        return Icons.credit_card_rounded;
      case 'debit card':
      case 'banka kartı':
      case 'debitcard':
        return Icons.credit_score_rounded;
      case 'digital wallet':
      case 'dijital cüzdan':
      case 'digitalwallet':
        return Icons.account_balance_wallet_outlined;
      case 'online':
      case 'online ödeme':
        return Icons.language_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String _formatPaymentMethod(String? method, AppLocalizations l10n) {
    if (method == null) return '';
    switch (method.toLowerCase()) {
      case 'creditcard':
      case 'credit card':
      case 'kredi kartı':
        return l10n.creditCard;
      case 'cash':
      case 'nakit':
        return l10n.cash;
      case 'debitcard':
      case 'debit card':
      case 'banka kartı':
        return l10n.debitCard;
      case 'digitalwallet':
      case 'digital wallet':
      case 'dijital cüzdan':
        return l10n.digitalWallet;
      case 'online':
      case 'online ödeme':
        return l10n.onlinePayment;
      default:
        return method;
    }
  }

  String _formatTransportMode(String? mode, AppLocalizations l10n) {
    if (mode == null) return '';
    switch (mode.toLowerCase()) {
      case 'flight':
      case 'plane':
      case 'uçak':
        return l10n.flight;
      case 'bullettrain':
        return l10n.bulletTrain;
      case 'train':
      case 'tren':
        return l10n.train;
      case 'car':
      case 'araba':
        return l10n.car;
      case 'bus':
      case 'otobüs':
        return l10n.bus;
      case 'ship':
      case 'ferry':
      case 'gemi':
        return l10n.ferry;
      case 'motorcycle':
        return l10n.motorcycle;
      case 'camper':
        return l10n.camper;
      case 'bicycle':
        return l10n.bicycle;
      case 'subway':
        return l10n.subway;
      case 'hiking':
        return l10n.hiking;
      default:
        return mode;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final trips = ref.watch(tripControllerProvider).trips;
    final currentTrip = trips.firstWhere((t) => t.id == trip.id, orElse: () => trip);
    final expenseState = ref.watch(expenseControllerProvider(currentTrip.id));
    final transportIcon = TripsScreen.getTransportIcon(currentTrip.transportMode);

    // Listen for database errors and notify user cleanly
    ref.listen<ExpenseState>(expenseControllerProvider(currentTrip.id), (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: AppColors.errorPastel,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: 'trip-title-${currentTrip.id}',
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                currentTrip.title,
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editTrip,
              onPressed: () {
                AddTripSheet.show(context, tripToEdit: currentTrip);
              },
            ),
            IconButton(
              icon: const Icon(Icons.checklist_rtl_rounded),
              tooltip: l10n.baggageAndChecklist,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChecklistScreen(tripId: currentTrip.id, tripTitle: currentTrip.title),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shield_outlined),
              tooltip: l10n.travelDocuments,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VaultScreen(initialTripId: currentTrip.id),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            AddExpenseSheet.show(
              context,
              tripId: currentTrip.id,
              defaultCurrency: currentTrip.defaultCurrency,
            );
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 3,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.addExpense, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await CurrencyService.syncRates(force: true);
            await ref.read(expenseControllerProvider(trip.id).notifier).loadExpenses();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            // Trip Info & Budget Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destination / Route
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.place_outlined, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            currentTrip.destination,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Transport Mode & Date row
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        if (currentTrip.transportMode != null && currentTrip.transportMode!.isNotEmpty) ...[
                          Hero(
                            tag: 'trip-transport-icon-${currentTrip.id}',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(transportIcon, size: 13, color: theme.colorScheme.primary),
                                  const SizedBox(width: 5),
                                  Text(
                                    _formatTransportMode(currentTrip.transportMode, l10n),
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
                        ],
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 13, color: theme.colorScheme.secondary),
                            const SizedBox(width: 5),
                            Text(
                              AppDateFormatter.formatDateRange(
                                currentTrip.startDate,
                                currentTrip.endDate,
                                locale: Localizations.localeOf(context).languageCode,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Trip Notes Banner if present
                    if (currentTrip.notes != null && currentTrip.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentTrip.notes!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Pastel Budget Progress Card (Animated)
                    BudgetProgressCard(
                      budgetLimit: currentTrip.budgetLimit,
                      totalSpent: expenseState.totalSpent,
                      currency: currentTrip.defaultCurrency,
                    ),
                    if (expenseState.expenses.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      BudgetAnalyticsCard(
                        expenses: expenseState.expenses,
                        tripCurrency: currentTrip.defaultCurrency,
                        totalSpent: expenseState.totalSpent,
                      ),
                    ],
                    if (expenseState.expenses.any((e) =>
                        e.currency.toUpperCase() != currentTrip.defaultCurrency.toUpperCase())) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.currency_exchange_rounded,
                                size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                CurrencyService.isUsingLiveRates
                                    ? '${l10n.currencySynced} (${CurrencyService.lastUpdatedAt!.day}.${CurrencyService.lastUpdatedAt!.month})'
                                    : l10n.offlineRatesActive,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Section Header
                    Text(
                      l10n.budgetDescription,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expenses List
            if (expenseState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (expenseState.expenses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noExpensesYet,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.noExpensesSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = expenseState.expenses[index];
                      final color = _getCategoryColor(expense.category);
                      final icon = _getCategoryIcon(expense.category);
                      final paymentIcon = _getPaymentIcon(expense.paymentMethod);

                      return Dismissible(
                        key: ValueKey(expense.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.errorPastel,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(expenseControllerProvider(currentTrip.id).notifier)
                              .deleteExpense(expense.id);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"${expense.title}" ${l10n.deleted}'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              action: SnackBarAction(
                                label: l10n.undo.toUpperCase(),
                                textColor: Colors.white,
                                onPressed: () {
                                  ref
                                      .read(expenseControllerProvider(currentTrip.id).notifier)
                                      .restoreExpense(expense);
                                },
                              ),
                            ),
                          );
                        },
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            AddExpenseSheet.show(
                              context,
                              tripId: currentTrip.id,
                              defaultCurrency: currentTrip.defaultCurrency,
                              expenseToEdit: expense,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(child: Icon(icon, color: color, size: 20)),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expense.title,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 2,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                AppDateFormatter.formatYMMMd(
                                                  expense.date,
                                                  locale: Localizations.localeOf(context).languageCode,
                                                ),
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              if (expense.paymentMethod != null &&
                                                  expense.paymentMethod!.isNotEmpty) ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: theme.colorScheme.surfaceContainerHighest
                                                        .withValues(alpha: 0.5),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        paymentIcon,
                                                        size: 10,
                                                        color: theme.colorScheme.onSurfaceVariant,
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        _formatPaymentMethod(expense.paymentMethod, l10n),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w500,
                                                          color: theme.colorScheme.onSurfaceVariant,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              CurrencyFormatter.format(
                                                expense.amount,
                                                currency: expense.currency,
                                              ),
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          if (expense.currency.toUpperCase() != currentTrip.defaultCurrency.toUpperCase()) ...[
                                            const SizedBox(height: 1),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                '≈ ${CurrencyFormatter.format(CurrencyService.convert(amount: expense.amount, fromCurrency: expense.currency, toCurrency: currentTrip.defaultCurrency), currency: currentTrip.defaultCurrency)}',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Expense Notes if present
                                if (expense.notes != null && expense.notes!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      expense.notes!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: expenseState.expenses.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
}
