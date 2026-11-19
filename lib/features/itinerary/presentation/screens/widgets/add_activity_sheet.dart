import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_item.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_localization.dart';
import 'package:packbuddy/features/itinerary/presentation/controllers/itinerary_controller.dart';

/// Modal bottom sheet for scheduling or editing an activity in the day planner
class AddActivitySheet extends ConsumerStatefulWidget {
  final String tripId;
  final int initialDay;
  final int totalDays;
  final String tripStartDate;
  final String languageCode;
  final ItineraryItem? itemToEdit;

  const AddActivitySheet({
    super.key,
    required this.tripId,
    required this.initialDay,
    required this.totalDays,
    required this.tripStartDate,
    required this.languageCode,
    this.itemToEdit,
  });

  static Future<void> show(
    BuildContext context, {
    required String tripId,
    required int initialDay,
    required int totalDays,
    required String tripStartDate,
    required String languageCode,
    ItineraryItem? itemToEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => AddActivitySheet(
        tripId: tripId,
        initialDay: initialDay,
        totalDays: totalDays,
        tripStartDate: tripStartDate,
        languageCode: languageCode,
        itemToEdit: itemToEdit,
      ),
    );
  }

  @override
  ConsumerState<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends ConsumerState<AddActivitySheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  late final TextEditingController _costController;
  late int _selectedDay;
  String _selectedCategory = 'sightseeing';
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  bool _isSaving = false;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _titleController = TextEditingController(text: item.title);
      _locationController = TextEditingController(text: item.location ?? '');
      _notesController = TextEditingController(text: item.description ?? '');
      _costController = TextEditingController(
        text: item.cost != null && item.cost! > 0
            ? (item.cost! % 1 == 0
                ? item.cost!.toInt().toString()
                : item.cost!.toString())
            : '',
      );
      _selectedDay = item.dayNumber;
      _selectedCategory = item.category;

      if (item.time != null && item.time!.isNotEmpty) {
        if (item.time!.contains(' - ')) {
          final parts = item.time!.split(' - ');
          _selectedStartTime = _parseTimeOfDay(parts[0]);
          _selectedEndTime = _parseTimeOfDay(parts[1]);
        } else {
          _selectedStartTime = _parseTimeOfDay(item.time!);
        }
      }
      if (item.endTime != null && item.endTime!.isNotEmpty) {
        _selectedEndTime = _parseTimeOfDay(item.endTime!);
      }
    } else {
      _titleController = TextEditingController();
      _locationController = TextEditingController();
      _notesController = TextEditingController();
      _costController = TextEditingController();
      _selectedDay = widget.initialDay;
      _selectedCategory = 'sightseeing';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final clean = timeStr.trim();
      final parts = clean.split(':');
      if (parts.length >= 2) {
        final h = int.parse(parts[0].trim());
        final m = int.parse(parts[1].trim());
        return TimeOfDay(hour: h, minute: m);
      }
    } catch (_) {}
    return null;
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final h = tod.hour.toString().padLeft(2, '0');
    final m = tod.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final initial = _selectedEndTime ??
        (_selectedStartTime != null
            ? TimeOfDay(
                hour: (_selectedStartTime!.hour + 1) % 24,
                minute: _selectedStartTime!.minute,
              )
            : const TimeOfDay(hour: 10, minute: 30));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  String _calculateDateForDay(int dayNumber) {
    if (widget.tripStartDate.isEmpty) {
      return DateTime.now().toIso8601String().split('T').first;
    }
    try {
      final start = DateTime.parse(widget.tripStartDate);
      final target = start.add(Duration(days: dayNumber - 1));
      return target.toIso8601String().split('T').first;
    } catch (_) {
      return DateTime.now().toIso8601String().split('T').first;
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = ItineraryLocalization.getTitleRequired(widget.languageCode);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ItineraryLocalization.getTitleRequired(widget.languageCode)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _titleError = null;
      _isSaving = true;
    });

    final formattedStartTime = _selectedStartTime != null
        ? _formatTimeOfDay(_selectedStartTime!)
        : null;
    final formattedEndTime = _selectedEndTime != null
        ? _formatTimeOfDay(_selectedEndTime!)
        : null;

    final cost = double.tryParse(_costController.text.trim().replaceAll(',', '.'));
    final date = _calculateDateForDay(_selectedDay);

    final bool success;
    if (widget.itemToEdit != null) {
      success = await ref
          .read(itineraryControllerFamily(widget.tripId).notifier)
          .updateActivity(
            id: widget.itemToEdit!.id,
            title: title,
            dayNumber: _selectedDay,
            date: date,
            time: formattedStartTime,
            endTime: formattedEndTime,
            location: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
            description: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
            category: _selectedCategory,
            cost: cost,
          );
    } else {
      success = await ref
          .read(itineraryControllerFamily(widget.tripId).notifier)
          .addActivity(
            title: title,
            dayNumber: _selectedDay,
            date: date,
            time: formattedStartTime,
            endTime: formattedEndTime,
            location: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
            description: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
            category: _selectedCategory,
            cost: cost,
          );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      if (success) {
        Navigator.of(context).pop();
      } else {
        final errorMsg = ref.read(itineraryControllerFamily(widget.tripId)).errorMessage ??
            (widget.languageCode == 'tr' ? 'Aktivite kaydedilemedi' : 'Could not save activity');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = widget.languageCode;
    final isEditing = widget.itemToEdit != null;
    final mediaQuery = MediaQuery.of(context);

    final categories = ['sightseeing', 'food', 'transit', 'activity', 'lodging', 'shopping'];

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: mediaQuery.viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle Indicator
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Bar (Pinned at top)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing
                        ? ItineraryLocalization.getEditActivity(lang)
                        : ItineraryLocalization.getAddActivity(lang),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Scrollable Form Body
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day Selector Chips
                      Text(
                        ItineraryLocalization.getDay(lang, _selectedDay),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.totalDays,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final dayNum = index + 1;
                            final isSelected = dayNum == _selectedDay;
                            return ChoiceChip(
                              label: Text(ItineraryLocalization.getDay(lang, dayNum)),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedDay = dayNum;
                                });
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              selectedColor: theme.colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Activity Title Field (REQUIRED *)
                      Row(
                        children: [
                          Text(
                            ItineraryLocalization.getActivityTitle(lang),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${ItineraryLocalization.getRequired(lang)})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titleController,
                        autofocus: false,
                        onChanged: (val) {
                          if (_titleError != null && val.trim().isNotEmpty) {
                            setState(() => _titleError = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: ItineraryLocalization.getActivityTitleHint(lang),
                          prefixIcon: const Icon(Icons.event_note_rounded, size: 20),
                          errorText: _titleError,
                          filled: true,
                          fillColor: isDark
                              ? theme.colorScheme.surfaceContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Category Chips (REQUIRED *)
                      Row(
                        children: [
                          Text(
                            ItineraryLocalization.getCategory(lang),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${ItineraryLocalization.getRequired(lang)})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: categories.map((cat) {
                          final isSelected = cat == _selectedCategory;
                          return ChoiceChip(
                            label: Text(ItineraryLocalization.getCategoryLabel(cat, lang)),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            selectedColor: theme.colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Dual Time (Start Time & Optional End Time) Row (OPTIONAL)
                      Row(
                        children: [
                          Text(
                            ItineraryLocalization.getTime(lang),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${ItineraryLocalization.getOptional(lang)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Start Time Card (Gidiş / Başlangıç)
                          Expanded(
                            child: InkWell(
                              onTap: _pickStartTime,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? theme.colorScheme.surfaceContainer
                                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _selectedStartTime != null
                                        ? theme.colorScheme.primary.withValues(alpha: 0.45)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 17,
                                      color: _selectedStartTime != null
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            ItineraryLocalization.getStartTime(lang),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            _selectedStartTime != null
                                                ? _formatTimeOfDay(_selectedStartTime!)
                                                : '--:--',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: _selectedStartTime != null
                                                  ? FontWeight.w800
                                                  : FontWeight.w400,
                                              color: _selectedStartTime != null
                                                  ? theme.colorScheme.onSurface
                                                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_selectedStartTime != null)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedStartTime = null;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(
                                            Icons.cancel_rounded,
                                            size: 16,
                                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // End Time Card (Dönüş / Bitiş - Optional / Flexible)
                          Expanded(
                            child: InkWell(
                              onTap: _pickEndTime,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? theme.colorScheme.surfaceContainer
                                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _selectedEndTime != null
                                        ? theme.colorScheme.primary.withValues(alpha: 0.45)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.update_rounded,
                                      size: 17,
                                      color: _selectedEndTime != null
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            ItineraryLocalization.getEndTime(lang),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            _selectedEndTime != null
                                                ? _formatTimeOfDay(_selectedEndTime!)
                                                : ItineraryLocalization.getFlexible(lang),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: _selectedEndTime != null
                                                  ? FontWeight.w800
                                                  : FontWeight.w500,
                                              color: _selectedEndTime != null
                                                  ? theme.colorScheme.onSurface
                                                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_selectedEndTime != null)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedEndTime = null;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(
                                            Icons.cancel_rounded,
                                            size: 16,
                                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Location Field (OPTIONAL)
                      Row(
                        children: [
                          Text(
                            ItineraryLocalization.getLocation(lang),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${ItineraryLocalization.getOptional(lang)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: ItineraryLocalization.getLocationHint(lang),
                          prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                          filled: true,
                          fillColor: isDark
                              ? theme.colorScheme.surfaceContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Cost Field (OPTIONAL)
                      Row(
                        children: [
                          Text(
                            ItineraryLocalization.getCost(lang),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${ItineraryLocalization.getOptional(lang)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _costController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: ItineraryLocalization.getCostHint(lang),
                          prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                          filled: true,
                          fillColor: isDark
                              ? theme.colorScheme.surfaceContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Notes Field (OPTIONAL)
                      Row(
                        children: [
                          Text(
                            ItineraryLocalization.getNotes(lang),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${ItineraryLocalization.getOptional(lang)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: ItineraryLocalization.getNotesHint(lang),
                          filled: true,
                          fillColor: isDark
                              ? theme.colorScheme.surfaceContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Save Button (Always visible at bottom)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          ItineraryLocalization.getSave(lang),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
