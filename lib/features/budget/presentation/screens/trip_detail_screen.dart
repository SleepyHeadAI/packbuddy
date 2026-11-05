import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/shared/widgets/app_animations.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/domain/city_localization.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_progress_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/features/budget/domain/emergency_guide.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/share_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/emergency_guide_sheet.dart';

/// Modern, intuitive Trip Management Hub & Budget Screen
class TripDetailScreen extends ConsumerWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return AppColors.primaryAmber;
      case 'Transport':
        return AppColors.secondaryLight;
      case 'Accommodation':
        return AppColors.tertiaryLight;
      case 'Entertainment':
        return AppColors.actionGold;
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Trip tripToDelete) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTrip),
        content: Text(l10n.deleteTripConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorPastel),
            onPressed: () {
              ref.read(tripControllerProvider.notifier).deleteTrip(tripToDelete.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(l10n.deleteTrip),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final trips = ref.watch(tripControllerProvider).trips;
    final currentTrip = trips.firstWhere((t) => t.id == trip.id, orElse: () => trip);
    final expenseState = ref.watch(expenseControllerProvider(currentTrip.id));
    final country = Country.findByCode(currentTrip.countryCode);
    final transportIcon = TripsScreen.getTransportIcon(currentTrip.transportMode);

    // Watch linked Checklist Items and Vault Documents safely
    int packedCount = 0;
    int checklistTotal = 0;
    double checklistRatio = 0.0;
    try {
      final allChecklistItems = ref.watch(checklistControllerProvider).items;
      final tripChecklistItems = allChecklistItems
          .where((i) => i.tripId == currentTrip.id || i.tripId == null)
          .toList();
      packedCount = tripChecklistItems.where((i) => i.isPacked).length;
      checklistTotal = tripChecklistItems.length;
      checklistRatio = checklistTotal > 0 ? (packedCount / checklistTotal) : 0.0;
    } catch (_) {}

    int vaultDocCount = 0;
    try {
      final allVaultDocs = ref.watch(vaultControllerProvider).documents;
      vaultDocCount = allVaultDocs.where((d) => d.tripId == currentTrip.id).length;
    } catch (_) {}

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
              icon: const Icon(Icons.share_rounded),
              tooltip: l10n.shareTrip,
              onPressed: () => ShareTripSheet.show(context, currentTrip),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editTrip,
              onPressed: () {
                AddTripSheet.show(context, tripToEdit: currentTrip);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: l10n.deleteTrip,
              onPressed: () => _showDeleteDialog(context, ref, currentTrip),
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
            scrollCacheExtent: const ScrollCacheExtent.pixels(600.0),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HERO OVERVIEW CARD
                      _buildTripOverviewHeroCard(
                        currentTrip,
                        country,
                        transportIcon,
                        l10n,
                        theme,
                        context,
                      ),
                      const SizedBox(height: 16),

                      // 2. TRAVEL HUB BENTO: Bavul, Belgeler, Acil Durum
                      _buildTripHubBento(
                        context: context,
                        currentTrip: currentTrip,
                        checklistTotal: checklistTotal,
                        packedCount: packedCount,
                        checklistRatio: checklistRatio,
                        vaultDocCount: vaultDocCount,
                        l10n: l10n,
                        theme: theme,
                      ),
                      const SizedBox(height: 20),

                      // 3. BUDGET & ANALYTICS SECTION
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
                          trip: currentTrip,
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
                      const SizedBox(height: 20),

                      // Section Header: Harcamalar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.budgetDescription,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (expenseState.expenses.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${expenseState.expenses.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // 4. EXPENSES LIST
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
                              Icons.receipt_long_rounded,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noExpensesYet,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
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
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = expenseState.expenses[index];
                        final categoryColor = _getCategoryColor(expense.category);
                        final categoryIcon = _getCategoryIcon(expense.category);
                        final paymentIcon = _getPaymentIcon(expense.paymentMethod);

                        return Dismissible(
                          key: Key(expense.id),
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
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(categoryIcon, color: categoryColor, size: 20),
                              ),
                              title: Text(
                                expense.title,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Row(
                                children: [
                                  if (expense.paymentMethod != null &&
                                      expense.paymentMethod!.isNotEmpty) ...[
                                    Icon(paymentIcon, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _formatPaymentMethod(expense.paymentMethod, l10n),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    AppDateFormatter.formatMMMd(
                                      expense.date,
                                      locale: Localizations.localeOf(context).languageCode,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(
                                      expense.amount,
                                      currency: expense.currency,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (expense.currency.toUpperCase() !=
                                      currentTrip.defaultCurrency.toUpperCase()) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '≈ ${CurrencyFormatter.format(CurrencyService.convert(amount: expense.amount, fromCurrency: expense.currency, toCurrency: currentTrip.defaultCurrency), currency: currentTrip.defaultCurrency)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: theme.colorScheme.onSurfaceVariant,
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

  /// 1. Hero Travel Banner Card
  Widget _buildTripOverviewHeroCard(
    Trip currentTrip,
    Country? country,
    IconData transportIcon,
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Destination + Status Badge
          Row(
            children: [
              if (country != null) ...[
                Text(country.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ] else ...[
                Icon(Icons.place_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  CityLocalization.localizeDestination(
                    currentTrip.destination,
                    Localizations.localeOf(context).languageCode,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildTripStatusBadge(currentTrip, l10n, theme),
            ],
          ),
          const SizedBox(height: 12),

          // Transport Mode & Dates row
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              if (currentTrip.transportMode != null && currentTrip.transportMode!.isNotEmpty) ...[
                Hero(
                  tag: 'trip-transport-icon-${currentTrip.id}',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(transportIcon, size: 12, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            TripsScreen.formatTransportMode(currentTrip.transportMode, l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 64),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: theme.colorScheme.secondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${AppDateFormatter.formatDateRange(currentTrip.startDate, currentTrip.endDate, locale: Localizations.localeOf(context).languageCode)} • ${currentTrip.totalDays} ${l10n.daysUnit}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Waypoints list if multi-stop itinerary exists
          if (currentTrip.waypoints.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: currentTrip.waypoints.map((wp) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFFE05A47)),
                      const SizedBox(width: 3),
                      Text(
                        wp.name,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // Trip Notes Banner if present
          if (currentTrip.notes != null && currentTrip.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      currentTrip.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 2. Travel Hub Bento Grid (Bavul Listesi, Kasa Belgeleri, Acil Durum Rehberi)
  Widget _buildTripHubBento({
    required BuildContext context,
    required Trip currentTrip,
    required int checklistTotal,
    required int packedCount,
    required double checklistRatio,
    required int vaultDocCount,
    required AppLocalizations l10n,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Left Bento Card: BAVUL & KONTROL LİSTESİ
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChecklistScreen(
                        tripId: currentTrip.id,
                        tripTitle: currentTrip.title,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.luggage_rounded, size: 16, color: theme.colorScheme.primary),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 11, color: theme.colorScheme.primary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.baggageAndChecklist,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        checklistTotal > 0
                            ? '$packedCount / $checklistTotal (${(checklistRatio * 100).toInt()}%)'
                            : l10n.addFirstItem,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: checklistRatio,
                          minHeight: 3.5,
                          backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            checklistRatio >= 1.0 ? AppColors.successPastel : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Right Bento Card: KASA & BELGELER
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VaultScreen(initialTripId: currentTrip.id),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_outlined, size: 16, color: Color(0xFFD97706)),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFFD97706)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.travelDocuments,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vaultDocCount > 0
                            ? '$vaultDocCount ${l10n.savedDocument}'
                            : l10n.addDocument,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: vaultDocCount > 0 ? 1.0 : 0.0,
                          minHeight: 3.5,
                          backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD97706)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Full Width Bento Row: ACİL DURUM VE YEREL REHBER (SOS)
        Builder(
          builder: (context) {
            final guides = EmergencyGuide.forTrip(currentTrip);
            final guideSub = guides.map((g) => '${g.countryName}: SOS ${g.generalSos}').join(' • ');

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => EmergencyGuideSheet.show(context, currentTrip),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.errorPastel.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.errorPastel.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.errorPastel.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sos_rounded,
                        color: AppColors.errorPastel,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.emergencyGuideTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            guideSub.isNotEmpty
                                ? guideSub
                                : CityLocalization.localizeDestination(
                                    currentTrip.destination,
                                    Localizations.localeOf(context).languageCode,
                                  ),
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTripStatusBadge(Trip currentTrip, AppLocalizations l10n, ThemeData theme) {
    if (currentTrip.isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.successPastel.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.successPastel.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppPulse(
              minScale: 0.85,
              maxScale: 1.15,
              duration: const Duration(milliseconds: 1400),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.successPastel,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.ongoingTrip.toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColors.successPastel,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    } else if (currentTrip.isUpcoming) {
      final days = currentTrip.daysUntilStart;
      final label = days == 0 ? l10n.today.toUpperCase() : l10n.daysRemaining(days).toUpperCase();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 10, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 10, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              l10n.completed.toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }
  }
}
