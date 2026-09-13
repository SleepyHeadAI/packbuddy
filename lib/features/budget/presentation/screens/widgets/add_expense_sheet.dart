import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';

/// Modal bottom sheet to add an expense to a specific trip
class AddExpenseSheet extends ConsumerStatefulWidget {
  final String tripId;
  final String defaultCurrency;

  const AddExpenseSheet({
    super.key,
    required this.tripId,
    required this.defaultCurrency,
  });

  static Future<void> show(
    BuildContext context, {
    required String tripId,
    required String defaultCurrency,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseSheet(
        tripId: tripId,
        defaultCurrency: defaultCurrency,
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

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food';

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text.trim());

      ref.read(expenseControllerProvider(widget.tripId).notifier).addExpense(
            title: _titleController.text.trim(),
            amount: amount,
            currency: widget.defaultCurrency,
            category: _selectedCategory,
            date: _selectedDate,
          );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

    final categories = [
      {'key': 'Food', 'label': l10n.food, 'icon': Icons.restaurant_rounded, 'color': AppColors.tertiaryLight},
      {'key': 'Transport', 'label': l10n.transport, 'icon': Icons.directions_subway_rounded, 'color': AppColors.secondaryLight},
      {'key': 'Accommodation', 'label': l10n.accommodation, 'icon': Icons.hotel_rounded, 'color': AppColors.primaryLight},
      {'key': 'Entertainment', 'label': l10n.entertainment, 'icon': Icons.attractions_rounded, 'color': AppColors.warningPastel},
      {'key': 'Other', 'label': l10n.other, 'icon': Icons.more_horiz_rounded, 'color': AppColors.outlineDark},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                l10n.addExpense,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  prefixText: '${widget.defaultCurrency} ',
                  prefixStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return l10n.amount;
                  if (double.tryParse(value.trim()) == null) return l10n.amount;
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Title
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.tripName,
                  prefixIcon: const Icon(Icons.receipt_long_outlined, size: 20),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.tripName : null,
              ),
              const SizedBox(height: 18),

              // Category Selector
              Text(
                l10n.category,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
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
                          '${l10n.date}: ${dateFormat.format(_selectedDate)}',
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
    );
  }
}
