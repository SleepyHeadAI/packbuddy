import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';

/// Modal bottom sheet to add or edit an expense with multi-currency, payment method, dynamic category, and notes
class AddExpenseSheet extends ConsumerStatefulWidget {
  final String tripId;
  final String defaultCurrency;
  final Expense? expenseToEdit;

  const AddExpenseSheet({
    super.key,
    required this.tripId,
    required this.defaultCurrency,
    this.expenseToEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required String tripId,
    required String defaultCurrency,
    Expense? expenseToEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => RepaintBoundary(
        child: AddExpenseSheet(
          tripId: tripId,
          defaultCurrency: defaultCurrency,
          expenseToEdit: expenseToEdit,
        ),
      ),
    );
  }

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food';
  String _selectedPaymentMethod = 'CreditCard';
  late String _selectedCurrency;

  static const List<Map<String, dynamic>> _paymentMethods = [
    {'key': 'CreditCard', 'icon': Icons.credit_card_rounded},
    {'key': 'Online', 'icon': Icons.language_rounded},
    {'key': 'Cash', 'icon': Icons.payments_outlined},
    {'key': 'DebitCard', 'icon': Icons.account_balance_wallet_outlined},
    {'key': 'DigitalWallet', 'icon': Icons.contactless_outlined},
  ];

  String _getPaymentLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'CreditCard':
        return l10n.creditCard;
      case 'Online':
        return l10n.onlinePayment;
      case 'Cash':
        return l10n.cash;
      case 'DebitCard':
        return l10n.debitCard;
      case 'DigitalWallet':
        return l10n.digitalWallet;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final exp = widget.expenseToEdit!;
      _selectedCurrency = exp.currency;
      _amountController.text = exp.amount.toString();
      _titleController.text = exp.title;
      _selectedDate = exp.date;
      if (exp.notes != null) {
        _notesController.text = exp.notes!;
      }
      if (exp.paymentMethod != null && _paymentMethods.any((m) => m['key'] == exp.paymentMethod)) {
        _selectedPaymentMethod = exp.paymentMethod!;
      }
      const standardCategories = ['Food', 'Transport', 'Accommodation', 'Entertainment', 'Other'];
      if (standardCategories.contains(exp.category)) {
        _selectedCategory = exp.category;
      } else {
        _selectedCategory = 'Other';
        _customCategoryController.text = exp.category;
      }
    } else {
      _selectedCurrency = widget.defaultCurrency;
    }
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _titleController.dispose();
    _customCategoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showCurrencyPicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return RepaintBoundary(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Text(
                    l10n.changeCurrency,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: CurrencyFormatter.supportedCurrencies.length,
                  itemBuilder: (context, index) {
                    final curr = CurrencyFormatter.supportedCurrencies[index];
                    final isSelected = curr == _selectedCurrency;
                    return ListTile(
                      leading: Text(
                        CurrencyFormatter.getSymbol(curr),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      title: Text(CurrencyFormatter.getCurrencyName(curr)),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                      onTap: () {
                        setState(() => _selectedCurrency = curr);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(colorScheme: theme.colorScheme),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text.trim());
      final notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      final categoryToSave = (_selectedCategory == 'Other' && _customCategoryController.text.trim().isNotEmpty)
          ? _customCategoryController.text.trim()
          : _selectedCategory;

      if (widget.expenseToEdit != null) {
        final updated = widget.expenseToEdit!.copyWith(
          title: _titleController.text.trim(),
          amount: amount,
          currency: _selectedCurrency,
          category: categoryToSave,
          date: _selectedDate,
          paymentMethod: _selectedPaymentMethod,
          notes: notes,
          updatedAt: DateTime.now(),
        );
        await ref.read(expenseControllerProvider(widget.tripId).notifier).updateExpense(updated);
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      await ref.read(expenseControllerProvider(widget.tripId).notifier).addExpense(
            title: _titleController.text.trim(),
            amount: amount,
            currency: _selectedCurrency,
            category: categoryToSave,
            date: _selectedDate,
            paymentMethod: _selectedPaymentMethod,
            notes: notes,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final categories = [
      {'key': 'Food', 'label': l10n.food, 'icon': Icons.restaurant_rounded, 'color': AppColors.tertiaryLight},
      {'key': 'Transport', 'label': l10n.transport, 'icon': Icons.directions_subway_rounded, 'color': AppColors.secondaryLight},
      {'key': 'Accommodation', 'label': l10n.accommodation, 'icon': Icons.hotel_rounded, 'color': AppColors.primaryLight},
      {'key': 'Entertainment', 'label': l10n.entertainment, 'icon': Icons.attractions_rounded, 'color': AppColors.warningPastel},
      {'key': 'Other', 'label': l10n.other, 'icon': Icons.more_horiz_rounded, 'color': theme.colorScheme.outline},
    ];

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                widget.expenseToEdit != null ? l10n.editExpense : l10n.addExpense,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),

              // Unified Trip Currency Amount Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        prefixText: '${CurrencyFormatter.getSymbol(_selectedCurrency)} ',
                        prefixStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return l10n.amount;
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) return l10n.amount;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: '${l10n.changeCurrency} ($_selectedCurrency)',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _showCurrencyPicker,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CurrencyFormatter.getSymbol(_selectedCurrency),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedCurrency,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedCurrency.toUpperCase() != widget.defaultCurrency.toUpperCase()) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.currency_exchange_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '≈ ${CurrencyFormatter.format(CurrencyService.convert(amount: double.tryParse(_amountController.text.trim()) ?? 0.0, fromCurrency: _selectedCurrency, toCurrency: widget.defaultCurrency), currency: widget.defaultCurrency)} (${widget.defaultCurrency})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
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

              // Title
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.expenseTitle,
                  hintText: l10n.expenseTitleHint,
                  prefixIcon: const Icon(Icons.receipt_long_outlined, size: 20),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.pleaseEnterExpenseTitle : null,
              ),
              const SizedBox(height: 14),

              // Category Selector
              Text(
                l10n.category,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat['key'];
                    final color = cat['color'] as Color;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        avatar: Icon(
                          cat['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : color,
                        ),
                        label: Text(cat['label'] as String),
                        selectedColor: color,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat['key'] as String);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Custom Category Input Field (when "Diğer" is selected)
              if (_selectedCategory == 'Other') ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customCategoryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.customCategoryName,
                    hintText: l10n.customCategoryHint,
                    prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                  ),
                  validator: (value) {
                    if (_selectedCategory == 'Other' && (value == null || value.trim().isEmpty)) {
                      return l10n.pleaseEnterCustomCategory;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 14),

              // Payment Method Chips (including Online Ödeme)
              Text(
                l10n.paymentMethod,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _paymentMethods.map((pm) {
                    final isSelected = _selectedPaymentMethod == pm['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(
                          pm['icon'] as IconData,
                          size: 16,
                          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                        ),
                        label: Text(_getPaymentLabel(pm['key'] as String, l10n)),
                        selected: isSelected,
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedPaymentMethod = pm['key'] as String);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Date Picker Button
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${l10n.date}: ${AppDateFormatter.formatYMMMd(_selectedDate, locale: Localizations.localeOf(context).languageCode)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.edit_calendar_outlined,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Notes Input Field
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.expenseNotesLabel,
                  hintText: l10n.expenseNotesHint,
                  prefixIcon: const Icon(Icons.description_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              FilledButton(
                onPressed: _submit,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
