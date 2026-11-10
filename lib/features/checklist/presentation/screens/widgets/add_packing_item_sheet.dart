import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
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

  final List<String> _tags = List.from(PackingTagHelper.standardTags);

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
      case 'diğer':
      case 'other':
      case 'others':
        return l10n.other == 'Other' ? 'Others' : l10n.other;
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: bottomInset + 24,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
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
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
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
                      isExpanded: true,
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
                          child: Text(
                            _getCategoryLabel(c, l10n),
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
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
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '$_quantity ${l10n.pieces}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Tag & Compartment Selectors
              Builder(
                builder: (context) {
                  final langCode = Localizations.localeOf(context).languageCode;
                  final tagLabel = _getLuggageTypeLabel(langCode);

                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _tags.contains(_tag) ? _tag : _tags.first,
                          menuMaxHeight: 280,
                          borderRadius: BorderRadius.circular(16),
                          decoration: InputDecoration(
                            labelText: tagLabel,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: _tags.map((t) {
                            final localized = PackingTagHelper.getLocalizedTag(t, langCode);
                            final icon = PackingTagHelper.getTagIcon(t);
                            final tagColor = PackingTagHelper.getTagColor(t, isDark);

                            return DropdownMenuItem(
                              value: t,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon, size: 14, color: tagColor),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      localized,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _tag = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _compartment,
                          menuMaxHeight: 280,
                          borderRadius: BorderRadius.circular(16),
                          decoration: InputDecoration(
                            labelText: l10n.compartment,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: _compartments.map((comp) {
                            final localizedComp = _getLocalizedCompartment(comp, langCode);
                            return DropdownMenuItem(
                              value: comp,
                              child: Text(
                                localizedComp,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _compartment = val);
                          },
                        ),
                      ),
                    ],
                  );
                },
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.cancel),
                          ),
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.itemToEdit != null ? l10n.save : l10n.addToBaggage,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
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
    ),
  );
}

  static String _getLuggageTypeLabel(String langCode) {
    final lang = langCode.toLowerCase();
    if (lang == 'tr') return 'Bavul / Bagaj Türü';
    if (lang == 'de') return 'Gepäckart';
    if (lang == 'fr') return 'Type de bagage';
    if (lang == 'es') return 'Tipo de equipaje';
    if (lang == 'it') return 'Tipo di bagaglio';
    if (lang == 'ru') return 'Тип багажа';
    if (lang == 'ar') return 'نوع الأمتعة';
    if (lang == 'pt') return 'Tipo de bagagem';
    if (lang == 'nl') return 'Type bagage';
    return 'Luggage Type';
  }

  static String _getLocalizedCompartment(String comp, String langCode) {
    final lang = langCode.toLowerCase();
    switch (comp) {
      case 'Ana Bölme':
        if (lang == 'tr') return 'Ana Bölme';
        if (lang == 'de') return 'Hauptfach';
        if (lang == 'fr') return 'Compartiment principal';
        if (lang == 'es') return 'Compartimento principal';
        if (lang == 'it') return 'Scomparto principale';
        if (lang == 'ru') return 'Основное отделение';
        if (lang == 'ar') return 'المقصورة الرئيسية';
        if (lang == 'pt') return 'Compartimento principal';
        if (lang == 'nl') return 'Hoofdvak';
        return 'Main Compartment';
      case 'Ön Cep':
        if (lang == 'tr') return 'Ön Cep';
        if (lang == 'de') return 'Vordertasche';
        if (lang == 'fr') return 'Poche avant';
        if (lang == 'es') return 'Bolsillo delantero';
        if (lang == 'it') return 'Tasca frontale';
        if (lang == 'ru') return 'Передний карман';
        if (lang == 'ar') return 'الجيب الأمامي';
        if (lang == 'pt') return 'Bolso frontal';
        if (lang == 'nl') return 'Voorvak';
        return 'Front Pocket';
      case 'Sırt Çantası':
        if (lang == 'tr') return 'Sırt Çantası';
        if (lang == 'de') return 'Rucksack';
        if (lang == 'fr') return 'Sac à dos';
        if (lang == 'es') return 'Mochila';
        if (lang == 'it') return 'Zaino';
        if (lang == 'ru') return 'Рюкзак';
        if (lang == 'ar') return 'حقيبة الظهر';
        if (lang == 'pt') return 'Mochila';
        if (lang == 'nl') return 'Rugzak';
        return 'Backpack';
      case 'Kozmetik Bölmesi':
        if (lang == 'tr') return 'Kozmetik Bölmesi';
        if (lang == 'de') return 'Kulturbeutel';
        if (lang == 'fr') return 'Trousse de toilette';
        if (lang == 'es') return 'Neceser';
        if (lang == 'it') return 'Bustina cosmetici';
        if (lang == 'ru') return 'Косметичка';
        if (lang == 'ar') return 'حقيبة مستحضرات التجميل';
        if (lang == 'pt') return 'Necessaire';
        if (lang == 'nl') return 'Toilettas';
        return 'Toiletry Pouch';
      case 'Yan Göz':
        if (lang == 'tr') return 'Yan Göz';
        if (lang == 'de') return 'Seitentasche';
        if (lang == 'fr') return 'Poche latérale';
        if (lang == 'es') return 'Bolsillo lateral';
        if (lang == 'it') return 'Tasca laterale';
        if (lang == 'ru') return 'Боковой карман';
        if (lang == 'ar') return 'الجيب الجانبي';
        if (lang == 'pt') return 'Bolso lateral';
        if (lang == 'nl') return 'Zijvak';
        return 'Side Pocket';
      default:
        return comp;
    }
  }
}
