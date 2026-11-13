import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_localization.dart';
import 'package:packbuddy/features/itinerary/presentation/controllers/itinerary_controller.dart';

/// Modal bottom sheet for scheduling a new activity in the day planner
class AddActivitySheet extends ConsumerStatefulWidget {
  final String tripId;
  final int initialDay;
  final int totalDays;
  final String tripStartDate;
  final String languageCode;

  const AddActivitySheet({
    super.key,
    required this.tripId,
    required this.initialDay,
    required this.totalDays,
    required this.tripStartDate,
    required this.languageCode,
  });

  static Future<void> show(
    BuildContext context, {
    required String tripId,
    required int initialDay,
    required int totalDays,
    required String tripStartDate,
    required String languageCode,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddActivitySheet(
        tripId: tripId,
        initialDay: initialDay,
        totalDays: totalDays,
        tripStartDate: tripStartDate,
        languageCode: languageCode,
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
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _locationController = TextEditingController();
    _notesController = TextEditingController();
    _costController = TextEditingController();
    _selectedDay = widget.initialDay;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
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
    if (title.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    String? formattedTime;
    if (_selectedTime != null) {
      final h = _selectedTime!.hour.toString().padLeft(2, '0');
      final m = _selectedTime!.minute.toString().padLeft(2, '0');
      formattedTime = '$h:$m';
    }

    final cost = double.tryParse(_costController.text.trim());
    final date = _calculateDateForDay(_selectedDay);

    final success = await ref
        .read(itineraryControllerFamily(widget.tripId).notifier)
        .addActivity(
          title: title,
          dayNumber: _selectedDay,
          date: date,
          time: formattedTime,
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          description: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          category: _selectedCategory,
          cost: cost,
        );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = widget.languageCode;

    final categories = ['sightseeing', 'food', 'transit', 'activity', 'lodging', 'shopping'];

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ItineraryLocalization.getAddActivity(lang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

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

            // Activity Title Field
            Text(
              ItineraryLocalization.getActivityTitle(lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: lang == 'tr' ? 'örn. Eyfel Kulesi Ziyareti' : 'e.g. Visit Eiffel Tower',
                prefixIcon: const Icon(Icons.event_note_rounded, size: 20),
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

            // Time & Location Row
            Row(
              children: [
                // Time Picker Trigger
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainer
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime != null
                                ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                : ItineraryLocalization.getTime(lang),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedTime != null ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Cost Field
                Expanded(
                  child: TextField(
                    controller: _costController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: lang == 'tr' ? 'Masraf' : 'Cost',
                      prefixIcon: const Icon(Icons.attach_money_rounded, size: 18),
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
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Location Field
            Text(
              ItineraryLocalization.getLocation(lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: lang == 'tr' ? 'Mekan / Adres' : 'Venue / Address',
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

            // Category Chips
            Text(
              ItineraryLocalization.getCategory(lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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

            // Notes Field
            Text(
              ItineraryLocalization.getNotes(lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: lang == 'tr' ? 'Rezervasyon no, hatırlatma...' : 'Booking ID, reminder...',
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
            const SizedBox(height: 20),

            // Save Button
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
    );
  }
}

