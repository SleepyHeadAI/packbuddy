import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';

/// Modal bottom sheet to create a new trip with budget limit
class AddTripSheet extends ConsumerStatefulWidget {
  const AddTripSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTripSheet(),
    );
  }

  @override
  ConsumerState<AddTripSheet> createState() => _AddTripSheetState();
}

class _AddTripSheetState extends ConsumerState<AddTripSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 5));
  String _selectedCurrency = 'USD';

  final List<String> _currencies = ['USD', 'EUR', 'TRY', 'GBP', 'JPY'];

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryLight,
              onPrimary: AppColors.onPrimaryLight,
              surface: AppColors.surfaceLight,
              onSurface: AppColors.onSurfaceLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final double? budget = _budgetController.text.trim().isNotEmpty
          ? double.tryParse(_budgetController.text.trim())
          : null;

      ref.read(tripControllerProvider.notifier).addTrip(
            title: _titleController.text.trim(),
            destination: _destinationController.text.trim(),
            startDate: _startDate,
            endDate: _endDate,
            defaultCurrency: _selectedCurrency,
            budgetLimit: budget,
          );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

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
              // Drag handle
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

              // Title
              Text(
                l10n.addTrip,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),

              // Trip Name
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.tripName,
                  prefixIcon: const Icon(Icons.flight_takeoff_rounded, size: 20),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.tripName : null,
              ),
              const SizedBox(height: 12),

              // Destination
              TextFormField(
                controller: _destinationController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.destination,
                  prefixIcon: const Icon(Icons.place_outlined, size: 20),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.destination : null,
              ),
              const SizedBox(height: 12),

              // Budget Limit & Currency Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.budget,
                        prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCurrency,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      items: _currencies.map((curr) {
                        return DropdownMenuItem(
                          value: curr,
                          child: Text(curr, style: const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCurrency = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date Range Picker Row
              InkWell(
                onTap: _pickDateRange,
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
                      const Icon(Icons.calendar_today_rounded, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
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
