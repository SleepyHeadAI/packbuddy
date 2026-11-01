import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'country_picker_sheet.dart';

const _customPinColor = Color(0xFFE05A47);

/// Modal bottom sheet to create or edit a trip with country picker, multi-stop itinerary, transport modes, and notes
class AddTripSheet extends ConsumerStatefulWidget {
  final Trip? tripToEdit;

  const AddTripSheet({super.key, this.tripToEdit});

  static Future<void> show(BuildContext context, {Trip? tripToEdit}) {
    if (tripToEdit == null &&
        PreferencesService.instance.getRestrictedFeatures().contains('trip_create')) {
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
  final _stopInputController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 5));
  String _selectedCurrency = 'TRY';
  Country? _selectedCountry;

  // Multi-destination list of stops / cities / countries
  final List<String> _itineraryStops = [];
  List<LocationSearchResult> _locationSuggestions = [];

  @override
  void initState() {
    super.initState();
    _stopInputController.addListener(_onStopInputChanged);
    if (widget.tripToEdit != null) {
      final t = widget.tripToEdit!;
      _titleController.text = t.title;
      _startDate = t.startDate;
      _endDate = t.endDate;
      _selectedCurrency = t.defaultCurrency;
      if (t.budgetLimit != null) {
        _budgetController.text = t.budgetLimit.toString();
      }
      if (t.notes != null) {
        _notesController.text = t.notes!;
      }
      if (t.countryCode != null) {
        _selectedCountry = Country.findByCode(t.countryCode!);
      }
      if (t.destination.isNotEmpty) {
        final parts = t.destination.split(RegExp(r'\s*➔\s*'));
        for (final p in parts) {
          final trimmed = p.trim();
          if (trimmed.isNotEmpty && !_itineraryStops.contains(trimmed)) {
            _itineraryStops.add(trimmed);
          }
        }
      }
    } else {
      _selectedCurrency = PreferencesService.instance.getDefaultCurrency() ??
          CountryDetector.detectNativeCurrency();
    }
  }

  @override
  void dispose() {
    _stopInputController.removeListener(_onStopInputChanged);
    _titleController.dispose();
    _stopInputController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onStopInputChanged() {
    final query = _stopInputController.text.trim();
    if (query.length < 2) {
      if (_locationSuggestions.isNotEmpty) {
        setState(() => _locationSuggestions = []);
      }
      return;
    }

    final langCode = Localizations.localeOf(context).languageCode;
    final results = Country.searchLocations(query, languageCode: langCode, limit: 6);
    setState(() {
      _locationSuggestions = results;
    });
  }

  void _selectLocationSuggestion(LocationSearchResult suggestion) {
    setState(() {
      if (!_itineraryStops.contains(suggestion.formattedStop)) {
        _itineraryStops.add(suggestion.formattedStop);
      }
      _selectedCountry = suggestion.country;
      if (CurrencyFormatter.supportedCurrencies.contains(suggestion.country.defaultCurrency)) {
        _selectedCurrency = suggestion.country.defaultCurrency;
      }
      _stopInputController.clear();
      _locationSuggestions = [];
    });
  }

  void _addCustomLocation(String customName) {
    final clean = customName.trim();
    if (clean.isEmpty) return;
    final formatted = clean.startsWith('📍') ? clean : '📍 $clean';
    setState(() {
      if (!_itineraryStops.contains(formatted)) {
        _itineraryStops.add(formatted);
      }
      _stopInputController.clear();
      _locationSuggestions = [];
    });
  }

  Future<void> _showCustomLocationDialog({String prefill = ''}) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final customController = TextEditingController(text: prefill);
    final formKey = GlobalKey<FormState>();

    final customPlace = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _customPinColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pin_drop_rounded, color: _customPinColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.addCustomLocation,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.customLocationDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: customController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.customLocation,
                  hintText: l10n.customLocationHint,
                  prefixIcon: const Icon(Icons.edit_location_alt_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  isDense: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.customLocation;
                  }
                  return null;
                },
                onFieldSubmitted: (val) {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.of(ctx).pop(val.trim());
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _customPinColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(customController.text.trim());
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );

    if (customPlace != null && customPlace.isNotEmpty) {
      _addCustomLocation(customPlace);
    }
  }

  Future<void> _showUnrecognizedLocationDialog(String text) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final shouldAddAsCustom = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _customPinColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.help_outline_rounded, color: _customPinColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.addCustomLocation,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.notACountryOrCityPrompt(text),
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _customPinColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.pin_drop_rounded, size: 16),
            label: Text(l10n.addAsCustomLocation),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldAddAsCustom == true) {
      _addCustomLocation(text);
    }
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
    final result = await CountryPickerSheet.show(context);
    if (result != null) {
      setState(() {
        _selectedCountry = result.country;
        final langCode = Localizations.localeOf(context).languageCode;
        final label = result.getLocalizedLabel(langCode);
        if (!_itineraryStops.contains(label)) {
          _itineraryStops.add(label);
        }
        if (CurrencyFormatter.supportedCurrencies.contains(result.country.defaultCurrency)) {
          _selectedCurrency = result.country.defaultCurrency;
        }
      });
    }
  }

  void _addStopFromInput() {
    final text = _stopInputController.text.trim();
    if (text.isEmpty) return;

    final langCode = Localizations.localeOf(context).languageCode;
    // 1. Check if user typed an exact real country or city
    final exact = Country.findLocationExact(text, languageCode: langCode);
    if (exact != null) {
      _selectLocationSuggestion(exact);
      return;
    }

    // 2. If suggestions are open and first item is a matching city or country
    if (_locationSuggestions.isNotEmpty &&
        _locationSuggestions.first.title.toLowerCase() == text.toLowerCase()) {
      _selectLocationSuggestion(_locationSuggestions.first);
      return;
    }

    // 3. User entered an unrecognized location (e.g. "Bizim Köy", "Dedemin Evi")
    // Prompt whether to add as custom location
    _showUnrecognizedLocationDialog(text);
  }

  void _removeStop(int index) {
    setState(() {
      _itineraryStops.removeAt(index);
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final textStop = _stopInputController.text.trim();
    if (textStop.isNotEmpty) {
      final langCode = Localizations.localeOf(context).languageCode;
      final exact = Country.findLocationExact(textStop, languageCode: langCode);
      if (exact != null && !_itineraryStops.contains(exact.formattedStop)) {
        _itineraryStops.add(exact.formattedStop);
        _selectedCountry = exact.country;
      }
      _stopInputController.clear();
      _locationSuggestions = [];
    }

    if (_itineraryStops.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.errorPastel,
          content: Text(
            l10n.travelRouteOrStops,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final double? budget = _budgetController.text.trim().isNotEmpty
          ? double.tryParse(_budgetController.text.trim())
          : null;

      if (budget == null || budget <= 0) {
        return;
      }

      final notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;

      final finalDestination = _itineraryStops.join(' ➔ ');

      if (widget.tripToEdit != null) {
        final updated = widget.tripToEdit!.copyWith(
          title: _titleController.text.trim(),
          destination: finalDestination,
          startDate: _startDate,
          endDate: _endDate,
          defaultCurrency: _selectedCurrency,
          budgetLimit: budget,
          countryCode: _selectedCountry?.code,
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
                  // Optional Custom Location Quick Button
                  IconButton(
                    icon: const Icon(Icons.pin_drop_outlined, size: 18),
                    tooltip: l10n.customLocationTooltip,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(6),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ),
                    onPressed: () => _showCustomLocationDialog(prefill: _stopInputController.text.trim()),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: TextButton.icon(
                      onPressed: _openCountryPicker,
                      icon: const Icon(Icons.travel_explore_rounded, size: 16),
                      label: Text(
                        l10n.addCountry,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Destination Quick Stop Input Field (with Optional Custom Pin Action)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stopInputController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: l10n.cityOrStopHint,
                        prefixIcon: const Icon(Icons.travel_explore_rounded, size: 20),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_stopInputController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _stopInputController.clear();
                                  setState(() => _locationSuggestions = []);
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.pin_drop_rounded, size: 20),
                              tooltip: l10n.customLocationTooltip,
                              color: _customPinColor,
                              onPressed: () => _showCustomLocationDialog(prefill: _stopInputController.text.trim()),
                            ),
                          ],
                        ),
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

              // Dynamic Real Country & City Suggestions (Plus Custom Location Pin Action)
              if (_stopInputController.text.trim().length >= 2) ...[
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._locationSuggestions.map((item) {
                          return InkWell(
                            onTap: () => _selectLocationSuggestion(item),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  Text(item.country.flag, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          item.subtitle,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (item.isCity ? theme.colorScheme.tertiaryContainer : theme.colorScheme.primaryContainer)
                                          .withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.isCity ? l10n.cityLabel : l10n.countryLabel,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: item.isCity ? theme.colorScheme.onTertiaryContainer : theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.north_west_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        // Option to add the entered text as a custom location directly
                        InkWell(
                          onTap: () => _addCustomLocation(_stopInputController.text.trim()),
                          child: Container(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _customPinColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.pin_drop_rounded, size: 16, color: _customPinColor),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${l10n.addAsCustomLocation}: "${_stopInputController.text.trim()}"',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          color: _customPinColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        l10n.customLocationDescription,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 10.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.add_rounded, size: 18, color: _customPinColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

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
                          final isCustom = stop.startsWith('📍');
                          return Chip(
                            avatar: CircleAvatar(
                              radius: 10,
                              backgroundColor: isCustom ? _customPinColor : theme.colorScheme.primary,
                              child: isCustom
                                  ? const Icon(Icons.pin_drop_rounded, size: 10, color: Colors.white)
                                  : Text(
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
              const SizedBox(height: 12),

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
                        if (value == null || value.trim().isEmpty) {
                          return l10n.budget;
                        }
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return l10n.budget;
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
                    const Icon(Icons.check_rounded, size: 20),
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
