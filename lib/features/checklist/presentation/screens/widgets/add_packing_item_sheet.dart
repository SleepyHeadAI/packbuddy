import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';

/// Fast, snappy modal bottom sheet to add or edit a packing item in the checklist
class AddPackingItemSheet extends StatefulWidget {
  final String? tripId;
  final PackingItem? itemToEdit;

  const AddPackingItemSheet({super.key, this.tripId, this.itemToEdit});

  static Future<void> show(BuildContext context, {String? tripId, PackingItem? itemToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (ctx) => RepaintBoundary(
        child: AddPackingItemSheet(tripId: tripId, itemToEdit: itemToEdit),
      ),
    );
  }

  @override
  State<AddPackingItemSheet> createState() => _AddPackingItemSheetState();
}

class _AddPackingItemSheetState extends State<AddPackingItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _category = 'Kıyafet';
  String _tag = 'CARRY-ON';
  String _compartment = 'Ana Bölme';
  int _quantity = 1;

  final List<String> _categories = [
    'Kıyafet',
    'Elektronik',
    'Kişisel Bakım',
    'Belgeler',
    'Aksesuar',
    'Diğer',
  ];

  final List<String> _tags = [
    'CARRY-ON',
    'CABIN ONLY',
    'CHECK-IN',
    'ESSENTIAL',
  ];

  final List<String> _compartments = [
    'Ana Bölme',
    'Ön Cep',
    'Sırt Çantası',
    'Kozmetik Bölmesi',
    'Yan Göz',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _nameController.text = item.name;
      if (!_categories.contains(item.category)) {
        _categories.add(item.category);
      }
      _category = item.category;
      if (!_tags.contains(item.tag)) {
        _tags.add(item.tag);
      }
      _tag = item.tag;
      if (!_compartments.contains(item.compartment)) {
        _compartments.add(item.compartment);
      }
      _compartment = item.compartment;
      _quantity = item.quantity;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getCategoryLabel(String cat, AppLocalizations l10n) {
    switch (cat.toLowerCase()) {
      case 'kıyafet':
      case 'clothing':
        return l10n.categoryClothing;
      case 'elektronik':
      case 'electronics':
        return l10n.categoryElectronics;
      case 'kişisel bakım':
      case 'toiletries':
        return l10n.categoryToiletries;
      case 'belgeler':
      case 'documents':
        return l10n.categoryDocuments;
      case 'aksesuar':
      case 'accessories':
        return l10n.categoryAccessories;
      default:
        return cat;
    }
  }

  void _submit(WidgetRef ref) {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    if (widget.itemToEdit != null) {
      final updatedItem = widget.itemToEdit!.copyWith(
        name: _nameController.text.trim(),
        category: _category,
        quantity: _quantity,
        tag: _tag,
        compartment: _compartment,
      );

      ref.read(checklistControllerProvider.notifier).updateItem(updatedItem);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('"${updatedItem.name}" ${l10n.itemUpdated}')),
            ],
          ),
          backgroundColor: AppColors.successPastel,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final newItem = PackingItem(
      id: const Uuid().v4(),
      tripId: widget.tripId,
      name: _nameController.text.trim(),
      category: _category,
      quantity: _quantity,
      isPacked: false,
      tag: _tag,
      compartment: _compartment,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(checklistControllerProvider.notifier).addItem(newItem);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('"${newItem.name}" ${l10n.itemAddedToBaggage}')),
          ],
        ),
        backgroundColor: AppColors.successPastel,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(22, 12, 22, 20 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle pill
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Sheet Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.luggage_rounded, color: theme.colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.itemToEdit != null ? l10n.editItem : l10n.addNewItem,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Item Name Field (autofocus disabled to eliminate animation stutter)
              TextFormField(
                controller: _nameController,
                autofocus: false,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.itemName,
                  hintText: l10n.itemNameHint,
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.pleaseEnterItemName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category Selector & Quantity Stepper
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      menuMaxHeight: 280,
                      borderRadius: BorderRadius.circular(16),
                      decoration: InputDecoration(
                        labelText: l10n.category,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _categories.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(_getCategoryLabel(c, l10n), style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Quantity
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          visualDensity: VisualDensity.compact,
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Text(
                          '$_quantity ${l10n.pieces}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Consumer(
                builder: (context, ref, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _submit(ref),
                          child: Text(
                            widget.itemToEdit != null ? l10n.save : l10n.addToBaggage,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
