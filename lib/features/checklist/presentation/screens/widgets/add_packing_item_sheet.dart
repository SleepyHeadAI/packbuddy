import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/features/profile/presentation/controllers/friends_controller.dart';

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
  String? _assignedTo;

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
      _assignedTo = item.assignedTo;
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
        assignedTo: _assignedTo,
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
      assignedTo: _assignedTo,
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
              const SizedBox(height: 14),

              // Collaborative Assignment Selector ("Kim Getirecek?")
              Consumer(
                builder: (context, ref, _) {
                  final langCode = Localizations.localeOf(context).languageCode;
                  final friends = ref.watch(friendsControllerProvider).friends;
                  final trips = ref.watch(tripControllerProvider).trips;

                  // Gather candidate assignees
                  final candidates = <String>{};
                  if (widget.tripId != null) {
                    final currentTrip = trips.where((t) => t.id == widget.tripId).firstOrNull;
                    if (currentTrip != null) {
                      for (final c in currentTrip.collaborators) {
                        candidates.add(c.startsWith('@') ? c : '@$c');
                      }
                    }
                  }
                  for (final f in friends) {
                    if (f.username != null && f.username!.isNotEmpty) {
                      candidates.add('@${f.username}');
                    } else if (f.displayName != null && f.displayName!.isNotEmpty) {
                      candidates.add(f.displayName!);
                    }
                  }
                  if (_assignedTo != null && _assignedTo!.isNotEmpty) {
                    final normalized = _assignedTo!.startsWith('@') ? _assignedTo! : '@$_assignedTo';
                    candidates.add(normalized);
                  }

                  if (candidates.isEmpty) return const SizedBox.shrink();

                  final effectiveValue = _assignedTo != null && _assignedTo!.isNotEmpty
                      ? (_assignedTo!.startsWith('@') ? _assignedTo! : '@$_assignedTo')
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: DropdownButtonFormField<String?>(
                      isExpanded: true,
                      initialValue: candidates.contains(effectiveValue) ? effectiveValue : null,
                      menuMaxHeight: 280,
                      borderRadius: BorderRadius.circular(16),
                      decoration: InputDecoration(
                        labelText: FriendLocalization.getAssignedTo(langCode),
                        prefixIcon: Icon(Icons.person_pin_rounded, size: 20, color: theme.colorScheme.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            FriendLocalization.getUnassigned(langCode),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        ...candidates.map((handle) {
                          return DropdownMenuItem<String?>(
                            value: handle,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_circle_rounded, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    handle,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() => _assignedTo = val);
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

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
    final lang = langCode.toLowerCase().split('_').first.split('-').first;
    switch (lang) {
      case 'tr': return 'Bavul / Bagaj Türü';
      case 'de': return 'Gepäckart';
      case 'fr': return 'Type de bagage';
      case 'es': return 'Tipo de equipaje';
      case 'it': return 'Tipo di bagaglio';
      case 'ru': return 'Тип багажа';
      case 'ar': return 'نوع الأمتعة';
      case 'pt': return 'Tipo de bagagem';
      case 'nl': return 'Type bagage';
      case 'zh': return '行李类别';
      case 'ja': return '荷物タイプ';
      case 'ko': return '수하물 유형';
      case 'hi': return 'सामान का प्रकार';
      case 'el': return 'Τύπος αποσκευής';
      case 'sv': return 'Bagagetyp';
      case 'pl': return 'Typ bagażu';
      case 'id': return 'Tipe Bagasi';
      case 'th': return 'ประเภทสัมภาระ';
      case 'vi': return 'Loại hành lý';
      case 'en':
      default: return 'Luggage Type';
    }
  }

  static String _getLocalizedCompartment(String comp, String langCode) {
    final lang = langCode.toLowerCase().split('_').first.split('-').first;
    switch (comp) {
      case 'Ana Bölme':
        switch (lang) {
          case 'tr': return 'Ana Bölme';
          case 'de': return 'Hauptfach';
          case 'fr': return 'Compartiment principal';
          case 'es': return 'Compartimento principal';
          case 'it': return 'Scomparto principale';
          case 'ru': return 'Основное отделение';
          case 'ar': return 'المقصورة الرئيسية';
          case 'pt': return 'Compartimento principal';
          case 'nl': return 'Hoofdvak';
          case 'zh': return '主隔层';
          case 'ja': return 'メイン収納';
          case 'ko': return '메인 수납공간';
          case 'hi': return 'मुख्य डिब्बा';
          case 'el': return 'Κύριος χώρος';
          case 'sv': return 'Huvudfack';
          case 'pl': return 'Główna komora';
          case 'id': return 'Kompartemen Utama';
          case 'th': return 'ช่องหลัก';
          case 'vi': return 'Ngăn chính';
          case 'en':
          default: return 'Main Compartment';
        }
      case 'Ön Cep':
        switch (lang) {
          case 'tr': return 'Ön Cep';
          case 'de': return 'Vordertasche';
          case 'fr': return 'Poche avant';
          case 'es': return 'Bolsillo delantero';
          case 'it': return 'Tasca frontale';
          case 'ru': return 'Передний карман';
          case 'ar': return 'الجيب الأمامي';
          case 'pt': return 'Bolso frontal';
          case 'nl': return 'Voorvak';
          case 'zh': return '前袋';
          case 'ja': return 'フロントポケット';
          case 'ko': return '앞주머니';
          case 'hi': return 'सामने की जेब';
          case 'el': return 'Μπροστινή τσέπη';
          case 'sv': return 'Framficka';
          case 'pl': return 'Przednia kieszeń';
          case 'id': return 'Saku Depan';
          case 'th': return 'กระเป๋าหน้า';
          case 'vi': return 'Túi trước';
          case 'en':
          default: return 'Front Pocket';
        }
      case 'Sırt Çantası':
        switch (lang) {
          case 'tr': return 'Sırt Çantası';
          case 'de': return 'Rucksack';
          case 'fr': return 'Sac à dos';
          case 'es': return 'Mochila';
          case 'it': return 'Zaino';
          case 'ru': return 'Рюкзак';
          case 'ar': return 'حقيبة الظهر';
          case 'pt': return 'Mochila';
          case 'nl': return 'Rugzak';
          case 'zh': return '背包';
          case 'ja': return 'バックパック';
          case 'ko': return '백팩';
          case 'hi': return 'बैकपैक';
          case 'el': return 'Σακίδιο πλάτης';
          case 'sv': return 'Ryggsäck';
          case 'pl': return 'Plecak';
          case 'id': return 'Ransel';
          case 'th': return 'กระเป๋าเป้';
          case 'vi': return 'Ba lô';
          case 'en':
          default: return 'Backpack';
        }
      case 'Kozmetik Bölmesi':
        switch (lang) {
          case 'tr': return 'Kozmetik Bölmesi';
          case 'de': return 'Kulturbeutel';
          case 'fr': return 'Trousse de toilette';
          case 'es': return 'Neceser';
          case 'it': return 'Bustina cosmetici';
          case 'ru': return 'Косметичка';
          case 'ar': return 'حقيبة مستحضرات التجميل';
          case 'pt': return 'Necessaire';
          case 'nl': return 'Toilettas';
          case 'zh': return '洗漱包/化妆隔层';
          case 'ja': return '洗面ポーチ';
          case 'ko': return '세면용품 파우치';
          case 'hi': return 'प्रसाधन पाउच';
          case 'el': return 'Νεσεσέρ καλλυντικών';
          case 'sv': return 'Necessär';
          case 'pl': return 'Kosmetyczka';
          case 'id': return 'Pouch Kosmetik';
          case 'th': return 'กระเป๋าเครื่องแป้ง';
          case 'vi': return 'Túi mỹ phẩm';
          case 'en':
          default: return 'Toiletry Pouch';
        }
      case 'Yan Göz':
        switch (lang) {
          case 'tr': return 'Yan Göz';
          case 'de': return 'Seitentasche';
          case 'fr': return 'Poche latérale';
          case 'es': return 'Bolsillo lateral';
          case 'it': return 'Tasca laterale';
          case 'ru': return 'Боковой карман';
          case 'ar': return 'الجيب الجانبي';
          case 'pt': return 'Bolso lateral';
          case 'nl': return 'Zijvak';
          case 'zh': return '侧袋';
          case 'ja': return 'サイドポケット';
          case 'ko': return '측면 포켓';
          case 'hi': return 'साइड पॉकेट';
          case 'el': return 'Πλαϊνή τσέπη';
          case 'sv': return 'Sidofack';
          case 'pl': return 'Kieszeń boczna';
          case 'id': return 'Saku Samping';
          case 'th': return 'ช่องด้านข้าง';
          case 'vi': return 'Túi bên';
          case 'en':
          default: return 'Side Pocket';
        }
      default:
        return comp;
    }
  }
}
