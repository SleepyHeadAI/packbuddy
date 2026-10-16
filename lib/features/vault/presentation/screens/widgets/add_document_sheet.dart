import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';

/// Modal bottom sheet to choose source (camera/gallery/PDF file) and add a document with category hierarchy
class AddDocumentSheet extends ConsumerStatefulWidget {
  final String? initialTripId;
  final String? initialCategory;
  final String? initialSubCategory;

  const AddDocumentSheet({
    super.key,
    this.initialTripId,
    this.initialCategory,
    this.initialSubCategory,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialTripId,
    String? initialCategory,
    String? initialSubCategory,
  }) {
    if (PreferencesService.instance.getRestrictedFeatures().contains('vault_upload')) {
      final l10n = AppLocalizations.of(context);
      final msg = l10n != null ? l10n.adminFeatureRestrictedNotice : 'This feature has been restricted by an administrator.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.errorPastel,
          content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      );
      return Future.value();
    }
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
      builder: (context) => RepaintBoundary(
        child: AddDocumentSheet(
          initialTripId: initialTripId,
          initialCategory: initialCategory,
          initialSubCategory: initialSubCategory,
        ),
      ),
    );
  }

  @override
  ConsumerState<AddDocumentSheet> createState() => _AddDocumentSheetState();
}

class _AddDocumentSheetState extends ConsumerState<AddDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late String _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedTripId;
  bool _initializedTitles = false;

  final List<String> _ticketSubCategories = [
    'flightTicket',
    'busTicket',
    'ferryTicket',
    'trainTicket',
    'otherTransport',
  ];

  String _getSubCategoryLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'flightTicket':
      case 'Uçak Bileti':
        return l10n.flightTicket;
      case 'busTicket':
      case 'Otobüs Bileti':
        return l10n.busTicket;
      case 'ferryTicket':
      case 'Gemi / Feribot Bileti':
        return l10n.ferryTicket;
      case 'trainTicket':
      case 'Tren Bileti':
        return l10n.trainTicket;
      case 'otherTransport':
      case 'Diğer Ulaşım':
      default:
        return l10n.otherTransport;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Ticket';
    _selectedSubCategory = widget.initialSubCategory ?? (_selectedCategory == 'Ticket' ? 'flightTicket' : null);
    _selectedTripId = widget.initialTripId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTitles) {
      _initializedTitles = true;
      final l10n = AppLocalizations.of(context)!;
      if (_titleController.text.isEmpty) {
        if (_selectedCategory == 'Passport') {
          _titleController.text = l10n.myPassport;
        } else if (_selectedCategory == 'Ticket') {
          _titleController.text = _getSubCategoryLabel(_selectedSubCategory ?? 'flightTicket', l10n);
        } else if (_selectedCategory == 'Booking') {
          _titleController.text = l10n.hotelBooking;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickAndSaveImage(ImageSource source) {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final category = _selectedCategory;
      final subCategory = _selectedCategory == 'Ticket' ? _selectedSubCategory : null;
      final notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      Navigator.of(context).pop();

      ref.read(vaultControllerProvider.notifier).pickAndAddDocument(
            source: source,
            title: title,
            category: category,
            subCategory: subCategory,
            tripId: _selectedTripId,
            notes: notes,
          );
    }
  }

  void _pickAndSaveFile() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final category = _selectedCategory;
      final subCategory = _selectedCategory == 'Ticket' ? _selectedSubCategory : null;
      final notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      Navigator.of(context).pop();

      ref.read(vaultControllerProvider.notifier).pickAndAddFileDocument(
            title: title,
            category: category,
            subCategory: subCategory,
            tripId: _selectedTripId,
            notes: notes,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tripState = ref.watch(tripControllerProvider);

    final categories = [
      {'key': 'Ticket', 'label': l10n.tickets, 'icon': Icons.confirmation_number_outlined, 'color': AppColors.secondaryLight},
      {'key': 'Booking', 'label': l10n.accommodation, 'icon': Icons.hotel_outlined, 'color': AppColors.warningPastel},
      {'key': 'Passport', 'label': l10n.idAndPassport, 'icon': Icons.badge_outlined, 'color': AppColors.primaryLight},
      {'key': 'Insurance', 'label': l10n.healthAndInsurance, 'icon': Icons.health_and_safety_outlined, 'color': AppColors.errorPastel},
      {'key': 'Other', 'label': l10n.otherDocuments, 'icon': Icons.folder_open_rounded, 'color': theme.colorScheme.outline},
    ];

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
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
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
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
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.shield_outlined, color: theme.colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.addDocument,
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

              // Document Name (No autofocus to avoid animation lag)
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: l10n.documentName,
                  hintText: l10n.documentNameHint,
                  prefixIcon: const Icon(Icons.description_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.documentName : null,
              ),
              const SizedBox(height: 14),

              // Main Category Selector
              Text(
                l10n.mainCategory,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
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
                          fontWeight: FontWeight.w700,
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
                            setState(() {
                              _selectedCategory = cat['key'] as String;
                              if (_selectedCategory == 'Ticket' && _selectedSubCategory == null) {
                                _selectedSubCategory = 'flightTicket';
                              }
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Sub-category selector (Only shown for Biletler / Ticket category)
              if (_selectedCategory == 'Ticket') ...[
                Container(
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
                        children: [
                          Icon(Icons.subtitles_rounded, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            l10n.ticketTypeSubCategory,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _ticketSubCategories.map((sub) {
                          final isSubSelected = _selectedSubCategory == sub;
                          return ChoiceChip(
                            label: Text(_getSubCategoryLabel(sub, l10n)),
                            selected: isSubSelected,
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSubSelected ? Colors.white : theme.colorScheme.onSurface,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedSubCategory = sub;
                                  if (_titleController.text.isEmpty ||
                                      _ticketSubCategories.any((k) => _titleController.text == _getSubCategoryLabel(k, l10n))) {
                                    _titleController.text = _getSubCategoryLabel(sub, l10n);
                                  }
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Trip Association Dropdown
              if (tripState.trips.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  initialValue: _selectedTripId,
                  menuMaxHeight: 280,
                  borderRadius: BorderRadius.circular(16),
                  decoration: InputDecoration(
                    labelText: l10n.documentScope,
                    prefixIcon: const Icon(Icons.luggage_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.generalDocumentAllTrips),
                    ),
                    ...tripState.trips.map((trip) {
                      return DropdownMenuItem<String?>(
                        value: trip.id,
                        child: Text(
                          '✈️ ${trip.title} (${trip.destination})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedTripId = val);
                  },
                ),
                const SizedBox(height: 14),
              ],

              // Notes Input Field
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.documentNotesLabel,
                  hintText: l10n.documentNotesHint,
                  prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              // Legal Compliance & Cloud Backup Notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cloud_done_outlined, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.vaultCloudBackupNotice,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Source Options: Camera, Gallery, PDF/File
              Text(
                l10n.uploadDocumentPrompt,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Camera
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickAndSaveImage(ImageSource.camera),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 20, color: theme.colorScheme.primary),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  l10n.camera,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Gallery
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickAndSaveImage(ImageSource.gallery),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library_outlined, size: 20, color: theme.colorScheme.secondary),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  l10n.gallery,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // PDF / Document File
                    Expanded(
                      child: InkWell(
                        onTap: _pickAndSaveFile,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.picture_as_pdf_rounded, size: 20, color: Colors.white),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  l10n.pdfOrFile,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
