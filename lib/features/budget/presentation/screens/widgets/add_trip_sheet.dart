import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'country_picker_sheet.dart';

/// Modal bottom sheet to create or edit a trip with country picker, multi-stop itinerary, transport modes, and notes
class AddTripSheet extends ConsumerStatefulWidget {
  final Trip? tripToEdit;

  const AddTripSheet({super.key, this.tripToEdit});

  static Future<void> show(BuildContext context, {Trip? tripToEdit}) {
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
      builder: (_) => RepaintBoundary(child: AddTripSheet(tripToEdit: tripToEdit)),
    );
  }

  @override
  ConsumerState<AddTripSheet> createState() => _AddTripSheetState();
}

class _AddTripSheetState extends ConsumerState<AddTripSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _stopInputController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 5));
  String _selectedCurrency = 'TRY';
  Country? _selectedCountry;
  String _selectedTransport = 'Flight';
  String? _customTransport;

  // Multi-destination list of stops / cities / countries
  final List<String> _itineraryStops = [];

  static const List<Map<String, dynamic>> _presetTransportModes = [
    {'key': 'Flight', 'icon': Icons.flight_rounded},
    {'key': 'BulletTrain', 'icon': Icons.directions_railway_rounded},
    {'key': 'Train', 'icon': Icons.train_rounded},
    {'key': 'Car', 'icon': Icons.directions_car_rounded},
    {'key': 'Bus', 'icon': Icons.directions_bus_rounded},
    {'key': 'Ship', 'icon': Icons.directions_boat_rounded},
    {'key': 'Motorcycle', 'icon': Icons.two_wheeler_rounded},
    {'key': 'Camper', 'icon': Icons.airport_shuttle_rounded},
    {'key': 'Bicycle', 'icon': Icons.pedal_bike_rounded},
    {'key': 'Subway', 'icon': Icons.tram_rounded},
    {'key': 'Hiking', 'icon': Icons.hiking_rounded},
  ];

  String _getTransportLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Flight':
        return l10n.flight;
      case 'BulletTrain':
        return l10n.bulletTrain;
      case 'Train':
        return l10n.train;
      case 'Car':
        return l10n.car;
      case 'Bus':
        return l10n.bus;
      case 'Ship':
        return l10n.ferry;
      case 'Motorcycle':
        return l10n.motorcycle;
      case 'Camper':
        return l10n.camper;
      case 'Bicycle':
        return l10n.bicycle;
      case 'Subway':
        return l10n.subway;
      case 'Hiking':
        return l10n.hiking;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.tripToEdit != null) {
      final t = widget.tripToEdit!;
      _titleController.text = t.title;
      _destinationController.text = t.destination;
      _startDate = t.startDate;
      _endDate = t.endDate;
      _selectedCurrency = t.defaultCurrency;
      if (t.budgetLimit != null) {
        _budgetController.text = t.budgetLimit.toString();
      }
      if (t.notes != null) {
        _notesController.text = t.notes!;
      }
      if (t.transportMode != null) {
        _selectedTransport = t.transportMode!;
      }
      if (t.countryCode != null) {
        _selectedCountry = Country.findByCode(t.countryCode!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _stopInputController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final theme = Theme.of(context);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme,
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

  Future<void> _openCountryPicker() async {
    final country = await CountryPickerSheet.show(context);
    if (country != null) {
      setState(() {
        _selectedCountry = country;
        final countryLabel = '${country.flag} ${country.localName}';
        if (!_itineraryStops.contains(countryLabel)) {
          _itineraryStops.add(countryLabel);
        }
        _destinationController.text = _itineraryStops.join(' ➔ ');
        if (CurrencyFormatter.supportedCurrencies.contains(country.defaultCurrency)) {
          _selectedCurrency = country.defaultCurrency;
        }
      });
    }
  }

  void _addStopFromInput() {
    final text = _stopInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        if (!_itineraryStops.contains(text)) {
          _itineraryStops.add(text);
        }
        _destinationController.text = _itineraryStops.join(' ➔ ');
        _stopInputController.clear();
      });
    }
  }

  void _removeStop(int index) {
    setState(() {
      _itineraryStops.removeAt(index);
      _destinationController.text = _itineraryStops.join(' ➔ ');
    });
  }

  Future<void> _showCustomTransportDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _customTransport ?? '');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit_road_rounded),
            const SizedBox(width: 10),
            Text(l10n.customTransportType, style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.customTransportVehicle,
            hintText: l10n.customTransportHint,
            prefixIcon: const Icon(Icons.commute_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                setState(() {
                  _customTransport = val;
                  _selectedTransport = val;
                });
              }
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_destinationController.text.trim().isEmpty && _itineraryStops.isNotEmpty) {
      _destinationController.text = _itineraryStops.join(' ➔ ');
    }

    if (_formKey.currentState?.validate() ?? false) {
      final double? budget = _budgetController.text.trim().isNotEmpty
          ? double.tryParse(_budgetController.text.trim())
          : null;

      final notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      final finalDestination = _destinationController.text.trim().isNotEmpty
          ? _destinationController.text.trim()
          : (_itineraryStops.isNotEmpty ? _itineraryStops.join(' ➔ ') : 'Seyahat Rotası');

      if (widget.tripToEdit != null) {
        final updated = widget.tripToEdit!.copyWith(
          title: _titleController.text.trim(),
          destination: finalDestination,
          startDate: _startDate,
          endDate: _endDate,
          defaultCurrency: _selectedCurrency,
          budgetLimit: budget,
          countryCode: _selectedCountry?.code,
          transportMode: _selectedTransport,
          notes: notes,
          updatedAt: DateTime.now(),
        );

        ref.read(tripControllerProvider.notifier).updateTrip(updated);
        Navigator.of(context).pop();
        return;
      }

      ref.read(tripControllerProvider.notifier).addTrip(
            title: _titleController.text.trim(),
            destination: finalDestination,
            startDate: _startDate,
            endDate: _endDate,
            defaultCurrency: _selectedCurrency,
            budgetLimit: budget,
            countryCode: _selectedCountry?.code,
            transportMode: _selectedTransport,
            notes: notes,
          );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
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
              // Drag handle
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

              // Title
              Text(
                widget.tripToEdit != null ? l10n.editTrip : l10n.addTrip,
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
                  hintText: l10n.tripNameHint,
                  prefixIcon: const Icon(Icons.luggage_rounded, size: 20),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? l10n.tripName : null,
              ),
              const SizedBox(height: 16),

              // Destination & Multi-city / country Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.travelRouteOrStops,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _openCountryPicker,
                    icon: const Icon(Icons.travel_explore_rounded, size: 16),
                    label: Text(l10n.addCountry, style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Destination Quick Stop Input Field
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stopInputController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: l10n.cityOrStopHint,
                        prefixIcon: const Icon(Icons.add_location_alt_outlined, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onFieldSubmitted: (_) => _addStopFromInput(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: _addStopFromInput,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, size: 18),
                        const SizedBox(width: 4),
                        Text(l10n.add),
                      ],
                    ),
                  ),
                ],
              ),

              // Itinerary stops chips
              if (_itineraryStops.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.alt_route_rounded, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${l10n.itineraryStops} (${_itineraryStops.length})',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _itineraryStops.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final stop = entry.value;
                          return Chip(
                            avatar: CircleAvatar(
                              radius: 10,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                '${idx + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            label: Text(
                              stop,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: theme.colorScheme.surface,
                            deleteIcon: const Icon(Icons.close_rounded, size: 14),
                            onDeleted: () => _removeStop(idx),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),

              // Destination Summary / Manual Text
              TextFormField(
                controller: _destinationController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.destination,
                  hintText: l10n.destinationHint,
                  prefixIcon: const Icon(Icons.place_outlined, size: 20),
                ),
                validator: (value) {
                  if (_itineraryStops.isEmpty && (value == null || value.trim().isEmpty)) {
                    return l10n.destination;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Transport Mode Chips with Preset + Custom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      l10n.transportMode,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_customTransport != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${l10n.custom}: $_customTransport',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._presetTransportModes.map((m) {
                      final isSelected = _selectedTransport == m['key'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(
                            m['icon'] as IconData,
                            size: 16,
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                          ),
                          label: Text(_getTransportLabel(m['key'] as String, l10n)),
                          selected: isSelected,
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedTransport = m['key'] as String;
                              });
                            }
                          },
                        ),
                      );
                    }),
                    // Custom Transport Chip
                    if (_customTransport != null) ...[
                      () {
                        final isCustomSelected = _selectedTransport == _customTransport;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(
                              Icons.commute_rounded,
                              size: 16,
                              color: isCustomSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                            ),
                            label: Text(_customTransport!),
                            selected: isCustomSelected,
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isCustomSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() => _selectedTransport = _customTransport!);
                              }
                            },
                          ),
                        );
                      }(),
                    ],
                    // Add Custom Action Chip
                    ActionChip(
                      avatar: const Icon(Icons.add_rounded, size: 16),
                      label: Text(l10n.addCustomTransport),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      onPressed: _showCustomTransportDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Budget Limit & 28+ Currency Selector
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
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return l10n.budget;
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCurrency,
                      isExpanded: true,
                      menuMaxHeight: 280,
                      borderRadius: BorderRadius.circular(16),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      items: CurrencyFormatter.supportedCurrencies.map((curr) {
                        return DropdownMenuItem(
                          value: curr,
                          child: Text(
                            '$curr (${CurrencyFormatter.getSymbol(curr)})',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppDateFormatter.formatDateRange(
                            _startDate,
                            _endDate,
                            locale: Localizations.localeOf(context).languageCode,
                            includeYear: true,
                          ),
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
              const SizedBox(height: 12),

              // Travel Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.tripNotesLabel,
                  hintText: l10n.tripNotesHint,
                  prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.save,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
