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
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_progress_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/share_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/emergency_guide_sheet.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/itinerary_screen.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_localization.dart';
import 'package:packbuddy/features/itinerary/presentation/controllers/itinerary_controller.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Modern, intuitive Trip Management Hub & Budget Screen
class TripDetailScreen extends ConsumerStatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  final GlobalKey _fabKey = GlobalKey();
  int _viewMode = 0; // 0: All, 1: Category, 2: Payment Method
  String? _selectedCategoryFilter;
  String? _selectedPaymentMethodFilter;
  String? _selectedBudgetCurrency;
  final Set<String> _collapsedCategories = <String>{};
  final Set<String> _collapsedPaymentMethods = <String>{};

  Color _getCategoryColor(String category) {
    return BudgetAnalyticsCard.getCategoryColor(category);
  }

  IconData _getCategoryIcon(String category) {
    return BudgetAnalyticsCard.getCategoryIcon(category);
  }

  String _canonicalCategoryKey(String category) {
    final cat = category.toLowerCase().trim();
    if (cat.contains('food') || cat.contains('yemek')) return 'Food';
    if (cat.contains('transport') || cat.contains('ulaşım')) return 'Transport';
    if (cat.contains('accommodation') || cat.contains('konaklama') || cat.contains('otel')) {
      return 'Accommodation';
    }
    if (cat.contains('entertainment') || cat.contains('eğlence') || cat.contains('aktivite')) {
      return 'Entertainment';
    }
    if (cat.contains('shopping') || cat.contains('alışveriş')) return 'Shopping';
    if (cat == 'other' || cat == 'diğer') return 'Other';
    return category.isNotEmpty ? category : 'Other';
  }

  String _canonicalPaymentMethodKey(String? method) {
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

  Color _getPaymentColor(String? method) {
    final m = method?.toLowerCase().replaceAll(' ', '') ?? '';
    if (m.contains('credit') || m.contains('kredi')) {
      return const Color(0xFF0EA5E9); // Sky blue
    } else if (m.contains('cash') || m.contains('nakit')) {
      return AppColors.primaryAmber; // Amber
    } else if (m.contains('debit') || m.contains('banka')) {
      return const Color(0xFF10B981); // Emerald
    } else if (m.contains('wallet') || m.contains('cüzdan')) {
      return const Color(0xFF8B5CF6); // Purple
    } else if (m.contains('online')) {
      return const Color(0xFF06B6D4); // Cyan
    } else {
      return const Color(0xFF64748B); // Slate
    }
  }

  IconData _getPaymentIcon(String? method) {
    final m = method?.toLowerCase().replaceAll(' ', '') ?? '';
    if (m.contains('credit') || m.contains('kredi')) {
      return Icons.credit_card_rounded;
    } else if (m.contains('cash') || m.contains('nakit')) {
      return Icons.payments_outlined;
    } else if (m.contains('debit') || m.contains('banka')) {
      return Icons.account_balance_wallet_outlined;
    } else if (m.contains('wallet') || m.contains('cüzdan')) {
      return Icons.contactless_outlined;
    } else if (m.contains('online')) {
      return Icons.language_rounded;
    } else {
      return Icons.payment_rounded;
    }
  }

  String _formatPaymentMethod(String? method, AppLocalizations l10n) {
    if (method == null || method.trim().isEmpty) return l10n.other;
    final m = method.toLowerCase().replaceAll(' ', '');
    if (m.contains('credit') || m.contains('kredi')) {
      return l10n.creditCard;
    } else if (m.contains('cash') || m.contains('nakit')) {
      return l10n.cash;
    } else if (m.contains('debit') || m.contains('banka')) {
      return l10n.debitCard;
    } else if (m.contains('wallet') || m.contains('cüzdan')) {
      return l10n.digitalWallet;
    } else if (m.contains('online')) {
      return l10n.onlinePayment;
    } else if (m == 'other' || m == 'diğer') {
      return l10n.other;
    } else {
      return method;
    }
  }

  String _formatExpenseCountLabel(int count, BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'tr':
        return '$count harcama';
      case 'de':
        return '$count ${count == 1 ? 'Ausgabe' : 'Ausgaben'}';
      case 'fr':
        return '$count ${count == 1 ? 'dépense' : 'dépenses'}';
      case 'es':
        return '$count ${count == 1 ? 'gasto' : 'gastos'}';
      case 'it':
        return '$count ${count == 1 ? 'spesa' : 'spese'}';
      case 'pt':
        return '$count ${count == 1 ? 'despesa' : 'despesas'}';
      case 'ru':
        return '$count ${count == 1 ? 'расход' : 'расходов'}';
      case 'nl':
        return '$count ${count == 1 ? 'uitgave' : 'uitgaven'}';
      case 'sv':
        return '$count ${count == 1 ? 'utgift' : 'utgifter'}';
      case 'pl':
        return '$count ${count == 1 ? 'wydatek' : 'wydatków'}';
      case 'id':
        return '$count pengeluaran';
      case 'vi':
        return '$count khoản chi';
      case 'el':
        return '$count έξοδα';
      case 'ar':
        return '$count مصاريف';
      case 'zh':
        return '$count 笔支出';
      case 'ja':
        return '$count 件の支出';
      case 'ko':
        return '$count건 지출';
      case 'hi':
        return '$count खर्च';
      case 'th':
        return '$count รายการ';
      case 'en':
      default:
        return '$count ${count == 1 ? 'expense' : 'expenses'}';
    }
  }

  void _showDeleteDialog(BuildContext context, Trip tripToDelete) {
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

  Widget _buildItineraryCard(Trip currentTrip, ThemeData theme, String lang) {
    final itineraryState = ref.watch(itineraryControllerFamily(currentTrip.id));
    final count = itineraryState.totalCount;
    final completed = itineraryState.completedCount;
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItineraryScreen(trip: currentTrip),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.event_note_rounded,
                size: 22,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ItineraryLocalization.getItineraryTitle(lang),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? (lang == 'tr' ? 'Gün gün aktiviteleri planlayın' : 'Plan activities day by day')
                      : '$count ${lang == "tr" ? "aktivite planlandı" : "activities planned"} ($completed ${lang == "tr" ? "tamamlandı" : "done"})',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector(ThemeData theme, AppLocalizations l10n) {
    final isDark = theme.brightness == Brightness.dark;
    final modes = [
      {'mode': 0, 'label': l10n.allFilter, 'icon': Icons.format_list_bulleted_rounded},
      {'mode': 1, 'label': l10n.category, 'icon': Icons.category_outlined},
      {'mode': 2, 'label': l10n.paymentMethod, 'icon': Icons.account_balance_wallet_outlined},
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.6 : 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
      ),
      child: Row(
        children: modes.map((m) {
          final modeIndex = m['mode'] as int;
          final isSelected = _viewMode == modeIndex;

          return Expanded(
            child: InkWell(
              key: Key('expense_view_mode_$modeIndex'),
              onTap: () {
                setState(() {
                  _viewMode = modeIndex;
                });
              },
              borderRadius: BorderRadius.circular(11),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.surfaceDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      m['icon'] as IconData,
                      size: 14,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        m['label'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
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
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilterChips(
    List<MapEntry<String, List<Expense>>> entries,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final totalCount = entries.fold<int>(0, (sum, e) => sum + e.value.length);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              key: const Key('category_filter_all'),
              selected: _selectedCategoryFilter == null,
              showCheckmark: false,
              label: Text('${l10n.allFilter} ($totalCount)'),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: _selectedCategoryFilter == null ? FontWeight.w700 : FontWeight.w500,
                color: _selectedCategoryFilter == null ? Colors.white : theme.colorScheme.onSurface,
              ),
              selectedColor: theme.colorScheme.primary,
              onSelected: (_) {
                setState(() {
                  _selectedCategoryFilter = null;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _selectedCategoryFilter == null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
          ...entries.map((entry) {
            final isSelected = _selectedCategoryFilter == entry.key;
            final catName = BudgetAnalyticsCard.getCategoryDisplayName(entry.key, l10n);
            final color = _getCategoryColor(entry.key);
            final icon = _getCategoryIcon(entry.key);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                key: Key('category_filter_${entry.key}'),
                selected: isSelected,
                showCheckmark: false,
                avatar: Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : color,
                ),
                label: Text('$catName (${entry.value.length})'),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                ),
                selectedColor: color,
                onSelected: (_) {
                  setState(() {
                    _selectedCategoryFilter = isSelected ? null : entry.key;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? color
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodFilterChips(
    List<MapEntry<String, List<Expense>>> entries,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final totalCount = entries.fold<int>(0, (sum, e) => sum + e.value.length);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              key: const Key('payment_filter_all'),
              selected: _selectedPaymentMethodFilter == null,
              showCheckmark: false,
              label: Text('${l10n.allFilter} ($totalCount)'),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: _selectedPaymentMethodFilter == null ? FontWeight.w700 : FontWeight.w500,
                color: _selectedPaymentMethodFilter == null ? Colors.white : theme.colorScheme.onSurface,
              ),
              selectedColor: theme.colorScheme.primary,
              onSelected: (_) {
                setState(() {
                  _selectedPaymentMethodFilter = null;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _selectedPaymentMethodFilter == null
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
          ...entries.map((entry) {
            final isSelected = _selectedPaymentMethodFilter == entry.key;
            final methodName = _formatPaymentMethod(entry.key, l10n);
            final color = _getPaymentColor(entry.key);
            final icon = _getPaymentIcon(entry.key);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                key: Key('payment_filter_${entry.key}'),
                selected: isSelected,
                showCheckmark: false,
                avatar: Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : color,
                ),
                label: Text('$methodName (${entry.value.length})'),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                ),
                selectedColor: color,
                onSelected: (_) {
                  setState(() {
                    _selectedPaymentMethodFilter = isSelected ? null : entry.key;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? color
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryGroupCard({
    required String categoryKey,
    required List<Expense> expenses,
    required double totalSpent,
    required Trip currentTrip,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(categoryKey);
    final categoryIcon = _getCategoryIcon(categoryKey);
    final categoryName = BudgetAnalyticsCard.getCategoryDisplayName(categoryKey, l10n);

    final categoryTotal = expenses.fold<double>(
      0.0,
      (sum, e) => sum + CurrencyService.convert(
        amount: e.amount,
        fromCurrency: e.currency,
        toCurrency: currentTrip.defaultCurrency,
      ),
    );

    final percentage = totalSpent > 0
        ? ((categoryTotal / totalSpent) * 100).toStringAsFixed(0)
        : '0';

    final isExpanded = !_collapsedCategories.contains(categoryKey);

    return Container(
      key: Key('category_group_$categoryKey'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Summary Header
          InkWell(
            key: Key('category_header_$categoryKey'),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _collapsedCategories.add(categoryKey);
                } else {
                  _collapsedCategories.remove(categoryKey);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatExpenseCountLabel(expenses.length, context),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '%$percentage',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(
                          categoryTotal,
                          currency: currentTrip.defaultCurrency,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expenses List for this Category
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            ...expenses.map((expense) => _buildExpenseTileItem(
                  expense: expense,
                  currentTrip: currentTrip,
                  theme: theme,
                  l10n: l10n,
                  secondaryBadge: _formatPaymentMethod(expense.paymentMethod, l10n),
                  secondaryIcon: _getPaymentIcon(expense.paymentMethod),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodGroupCard({
    required String methodKey,
    required List<Expense> expenses,
    required double totalSpent,
    required Trip currentTrip,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final methodColor = _getPaymentColor(methodKey);
    final methodIcon = _getPaymentIcon(methodKey);
    final methodName = _formatPaymentMethod(methodKey, l10n);

    final methodTotal = expenses.fold<double>(
      0.0,
      (sum, e) => sum + CurrencyService.convert(
        amount: e.amount,
        fromCurrency: e.currency,
        toCurrency: currentTrip.defaultCurrency,
      ),
    );

    final percentage = totalSpent > 0
        ? ((methodTotal / totalSpent) * 100).toStringAsFixed(0)
        : '0';

    final isExpanded = !_collapsedPaymentMethods.contains(methodKey);

    return Container(
      key: Key('payment_group_$methodKey'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Method Summary Header
          InkWell(
            key: Key('payment_header_$methodKey'),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _collapsedPaymentMethods.add(methodKey);
                } else {
                  _collapsedPaymentMethods.remove(methodKey);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: methodColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(methodIcon, color: methodColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          methodName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatExpenseCountLabel(expenses.length, context),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: methodColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '%$percentage',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: methodColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(
                          methodTotal,
                          currency: currentTrip.defaultCurrency,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expenses Breakdown List for this Payment Method
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            ...expenses.map((expense) => _buildExpenseTileItem(
                  expense: expense,
                  currentTrip: currentTrip,
                  theme: theme,
                  l10n: l10n,
                  secondaryBadge: BudgetAnalyticsCard.getCategoryDisplayName(expense.category, l10n),
                  secondaryIcon: _getCategoryIcon(expense.category),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildExpenseTileItem({
    required Expense expense,
    required Trip currentTrip,
    required ThemeData theme,
    required AppLocalizations l10n,
    String? secondaryBadge,
    IconData? secondaryIcon,
  }) {
    final categoryColor = _getCategoryColor(expense.category);
    final categoryIcon = _getCategoryIcon(expense.category);

    return Dismissible(
      key: Key('exp-tile-${expense.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.errorPastel,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref
            .read(expenseControllerProvider(currentTrip.id).notifier)
            .deleteExpense(expense.id);
      },
      child: InkWell(
        onTap: () {
          AddExpenseSheet.show(
            context,
            tripId: currentTrip.id,
            defaultCurrency: currentTrip.defaultCurrency,
            expenseToEdit: expense,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (secondaryBadge != null && secondaryBadge.isNotEmpty) ...[
                          if (secondaryIcon != null) ...[
                            Icon(secondaryIcon, size: 11, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 3),
                          ],
                          Flexible(
                            child: Text(
                              secondaryBadge,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•',
                            style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(width: 6),
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
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
                      fontSize: 13.5,
                    ),
                  ),
                  if (expense.currency.toUpperCase() != currentTrip.defaultCurrency.toUpperCase()) ...[
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseListItem({
    required Expense expense,
    required Trip currentTrip,
    required ThemeData theme,
    required AppLocalizations l10n,
  }) {
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: ListTile(
          onTap: () {
            AddExpenseSheet.show(
              context,
              tripId: currentTrip.id,
              defaultCurrency: currentTrip.defaultCurrency,
              expenseToEdit: expense,
            );
          },
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
              if (expense.paymentMethod != null && expense.paymentMethod!.isNotEmpty) ...[
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
              if (expense.currency.toUpperCase() != currentTrip.defaultCurrency.toUpperCase()) ...[
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
    ),
  ),
);
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final trips = ref.watch(tripControllerProvider).trips;
    final currentTrip = trips.firstWhere((t) => t.id == widget.trip.id, orElse: () => widget.trip);
    final expenseState = ref.watch(expenseControllerProvider(currentTrip.id));
    final country = Country.findByCode(currentTrip.countryCode);
    final transportIcon = TripsScreen.getTransportIcon(currentTrip.transportMode);

    final activeBudgetCurrency = _selectedBudgetCurrency ?? currentTrip.defaultCurrency;
    final isCustomBudgetCurrency = activeBudgetCurrency.toUpperCase() != currentTrip.defaultCurrency.toUpperCase();
    final displayTotalSpent = isCustomBudgetCurrency
        ? CurrencyService.convert(
            amount: expenseState.totalSpent,
            fromCurrency: currentTrip.defaultCurrency,
            toCurrency: activeBudgetCurrency,
          )
        : expenseState.totalSpent;
    final displayBudgetLimit = (isCustomBudgetCurrency && currentTrip.budgetLimit != null)
        ? CurrencyService.convert(
            amount: currentTrip.budgetLimit!,
            fromCurrency: currentTrip.defaultCurrency,
            toCurrency: activeBudgetCurrency,
          )
        : currentTrip.budgetLimit;

    // Grouping by Category
    final Map<String, List<Expense>> categoryGroups = {};
    for (final exp in expenseState.expenses) {
      final key = _canonicalCategoryKey(exp.category);
      categoryGroups.putIfAbsent(key, () => []).add(exp);
    }
    final sortedCategoryEntries = categoryGroups.entries.toList()
      ..sort((a, b) {
        final totalA = a.value.fold<double>(
          0.0,
          (sum, e) => sum + CurrencyService.convert(
            amount: e.amount,
            fromCurrency: e.currency,
            toCurrency: currentTrip.defaultCurrency,
          ),
        );
        final totalB = b.value.fold<double>(
          0.0,
          (sum, e) => sum + CurrencyService.convert(
            amount: e.amount,
            fromCurrency: e.currency,
            toCurrency: currentTrip.defaultCurrency,
          ),
        );
        return totalB.compareTo(totalA);
      });

    // Grouping by Payment Method
    final Map<String, List<Expense>> paymentGroups = {};
    for (final exp in expenseState.expenses) {
      final key = _canonicalPaymentMethodKey(exp.paymentMethod);
      paymentGroups.putIfAbsent(key, () => []).add(exp);
    }
    final sortedPaymentEntries = paymentGroups.entries.toList()
      ..sort((a, b) {
        final totalA = a.value.fold<double>(
          0.0,
          (sum, e) => sum + CurrencyService.convert(
            amount: e.amount,
            fromCurrency: e.currency,
            toCurrency: currentTrip.defaultCurrency,
          ),
        );
        final totalB = b.value.fold<double>(
          0.0,
          (sum, e) => sum + CurrencyService.convert(
            amount: e.amount,
            fromCurrency: e.currency,
            toCurrency: currentTrip.defaultCurrency,
          ),
        );
        return totalB.compareTo(totalA);
      });

    final filteredCategoryEntries = _selectedCategoryFilter == null
        ? sortedCategoryEntries
        : sortedCategoryEntries.where((e) => e.key == _selectedCategoryFilter).toList();

    final filteredPaymentEntries = _selectedPaymentMethodFilter == null
        ? sortedPaymentEntries
        : sortedPaymentEntries.where((e) => e.key == _selectedPaymentMethodFilter).toList();

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
              icon: const Icon(Icons.event_note_rounded),
              tooltip: ItineraryLocalization.getItineraryTitle(lang),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ItineraryScreen(trip: currentTrip),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.sos_rounded, color: AppColors.errorPastel),
              tooltip: l10n.emergencyGuideTitle,
              onPressed: () => EmergencyGuideSheet.show(context, currentTrip),
            ),
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
              onPressed: () => _showDeleteDialog(context, currentTrip),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          key: _fabKey,
          heroTag: null,
          onPressed: () => QuickActionsSheet.showForTripDetail(
            context,
            trip: currentTrip,
            fabKey: _fabKey,
          ),
          elevation: 3,
          child: const Icon(Icons.add_rounded, size: 26),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await CurrencyService.syncRates(force: true);
            await ref.read(expenseControllerProvider(widget.trip.id).notifier).loadExpenses();
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

                      // 1.5. ITINERARY / DAY-BY-DAY PLANNER CARD
                      _buildItineraryCard(currentTrip, theme, lang),
                      const SizedBox(height: 16),

                      // 2. BUDGET & ANALYTICS SECTION
                      BudgetProgressCard(
                        budgetLimit: displayBudgetLimit,
                        totalSpent: displayTotalSpent,
                        currency: activeBudgetCurrency,
                        originalCurrency: isCustomBudgetCurrency ? currentTrip.defaultCurrency : null,
                        originalTotalSpent: isCustomBudgetCurrency ? expenseState.totalSpent : null,
                      ),
                      if (expenseState.expenses.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        BudgetAnalyticsCard(
                          expenses: expenseState.expenses,
                          tripCurrency: currentTrip.defaultCurrency,
                          selectedCurrency: activeBudgetCurrency,
                          onCurrencyChanged: (newCurrency) {
                            setState(() {
                              _selectedBudgetCurrency = newCurrency;
                            });
                          },
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

                      // Section Header: Harcamalar & Total Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _getExpensesSectionTitle(context),
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
                      if (expenseState.expenses.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildViewModeSelector(theme, l10n),
                        if (_viewMode == 1 && sortedCategoryEntries.length > 1) ...[
                          const SizedBox(height: 10),
                          _buildCategoryFilterChips(sortedCategoryEntries, theme, l10n),
                        ],
                        if (_viewMode == 2 && sortedPaymentEntries.length > 1) ...[
                          const SizedBox(height: 10),
                          _buildPaymentMethodFilterChips(sortedPaymentEntries, theme, l10n),
                        ],
                      ],
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // 4. EXPENSES LIST & CATEGORY / PAYMENT BREAKDOWNS
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
              else if (_viewMode == 0)
                // Mode 0: All Expenses (Flat chronological list)
                SliverPadding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = expenseState.expenses[index];
                        return _buildExpenseListItem(
                          expense: expense,
                          currentTrip: currentTrip,
                          theme: theme,
                          l10n: l10n,
                        );
                      },
                      childCount: expenseState.expenses.length,
                    ),
                  ),
                )
              else if (_viewMode == 1)
                // Mode 1: By Category (Grouped with summary cards & expense lists)
                if (filteredCategoryEntries.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          l10n.noExpensesYet,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
                          final entry = filteredCategoryEntries[index];
                          return _buildCategoryGroupCard(
                            categoryKey: entry.key,
                            expenses: entry.value,
                            totalSpent: expenseState.totalSpent,
                            currentTrip: currentTrip,
                            theme: theme,
                            l10n: l10n,
                          );
                        },
                        childCount: filteredCategoryEntries.length,
                      ),
                    ),
                  )
              else
                // Mode 2: By Payment Method (Grouped with summary cards & breakdown lists)
                if (filteredPaymentEntries.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          l10n.noExpensesYet,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
                          final entry = filteredPaymentEntries[index];
                          return _buildPaymentMethodGroupCard(
                            methodKey: entry.key,
                            expenses: entry.value,
                            totalSpent: expenseState.totalSpent,
                            currentTrip: currentTrip,
                            theme: theme,
                            l10n: l10n,
                          );
                        },
                        childCount: filteredPaymentEntries.length,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  String _getExpensesSectionTitle(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'tr':
        return 'Harcamalar';
      case 'de':
        return 'Ausgaben';
      case 'fr':
        return 'Dépenses';
      case 'es':
        return 'Gastos';
      case 'it':
        return 'Spese';
      case 'pt':
        return 'Despesas';
      case 'ru':
        return 'Расходы';
      case 'nl':
        return 'Uitgaven';
      case 'sv':
        return 'Utgifter';
      case 'pl':
        return 'Wydatki';
      case 'id':
        return 'Pengeluaran';
      case 'vi':
        return 'Chi tiêu';
      case 'el':
        return 'Έξοδα';
      case 'ar':
        return 'المصروفات';
      case 'zh':
        return '支出明细';
      case 'ja':
        return '支出履歴';
      case 'ko':
        return '지출 내역';
      case 'hi':
        return 'खर्च';
      case 'th':
        return 'รายการค่าใช้จ่าย';
      case 'en':
      default:
        return 'Expenses';
    }
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
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 76),
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
            Flexible(
              child: Text(
                l10n.ongoingTrip.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.successPastel,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            Flexible(
              child: Text(
                l10n.completed.toUpperCase(),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }
}
