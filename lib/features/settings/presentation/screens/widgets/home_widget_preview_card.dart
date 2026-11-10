import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/core/services/app_widget_localization.dart';
import 'package:packbuddy/core/services/app_widget_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/travel_map/data/travel_map_service.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/core/services/widget_card_renderer.dart';
import 'package:packbuddy/core/services/widget_map_renderer.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// In-App Home Screen Widget Preview & Customization Card (Feature F-9)
/// Provides complete 20-language localization and differentiated Small / Medium / Large widgets,
/// featuring a miniature painted vector World Map in Medium and Large sizes.
class HomeWidgetPreviewCard extends ConsumerStatefulWidget {
  const HomeWidgetPreviewCard({super.key});

  @override
  ConsumerState<HomeWidgetPreviewCard> createState() => _HomeWidgetPreviewCardState();
}

class _HomeWidgetPreviewCardState extends ConsumerState<HomeWidgetPreviewCard> {
  static const List<String> darkWidgetThemes = [
    'midnight',
    'sunset',
    'emerald',
    'cyberpunk',
    'volcano',
    'nordicForest',
    'goldenHour',
    'galaxy',
    'monochromeDark',
  ];

  static const List<String> lightWidgetThemes = [
    'minimalLight',
    'sandLight',
    'oceanLight',
    'cherryBlossom',
    'vintageSepia',
    'matcha',
    'pastelDream',
  ];

  int _selectedSize = 1; // 0: Small, 1: Medium, 2: Large
  late String _widgetMode; // 'trip', 'world_map', 'currency_converter', 'quick_expense'
  late String _widgetTheme;
  int _selectedThemeCategory = 0; // 0: Dark (9), 1: Light (7)
  late bool _showCountdown;
  late bool _showPacking;
  late bool _showBudget;
  late bool _showContinents;
  late bool _showWishlist;
  late bool _showLiveRate;
  late bool _showReverseRate;
  late bool _showRemainingBudget;
  late bool _showLastExpense;
  AppWidgetData? _widgetData;
  List<TravelCountry> _countries = const [];

  @override
  void initState() {
    super.initState();
    final prefs = PreferencesService.instance;
    _widgetMode = prefs.getWidgetMode();
    _widgetTheme = prefs.getWidgetThemeForMode(_widgetMode);
    if (_widgetTheme == 'light') _widgetTheme = 'minimalLight';
    if (_widgetTheme == 'ocean') _widgetTheme = 'oceanLight';
    _selectedThemeCategory = lightWidgetThemes.contains(_widgetTheme) ? 1 : 0;
    _showCountdown = prefs.isWidgetShowCountdown();
    _showPacking = prefs.isWidgetShowPacking();
    _showBudget = prefs.isWidgetShowBudget();
    _showContinents = prefs.isWidgetShowContinents();
    _showWishlist = prefs.isWidgetShowWishlist();
    _showLiveRate = prefs.isWidgetShowLiveRate();
    _showReverseRate = prefs.isWidgetShowReverseRate();
    _showRemainingBudget = prefs.isWidgetShowRemainingBudget();
    _showLastExpense = prefs.isWidgetShowLastExpense();
    _loadPayload();
  }

  Future<void> _loadPayload() async {
    final data = await AppWidgetService.getWidgetPayload();
    List<TravelCountry> countries = const [];
    try {
      countries = await TravelMapService.instance.getCountries();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _widgetData = data;
        _countries = countries;
      });
    }
  }

  Future<void> _updateWidgetMode(String mode) async {
    final prefs = PreferencesService.instance;
    final themeForMode = prefs.getWidgetThemeForMode(mode);
    setState(() {
      _widgetMode = mode;
      _widgetTheme = themeForMode;
      _selectedThemeCategory = lightWidgetThemes.contains(themeForMode) ? 1 : 0;
    });
    await prefs.setWidgetMode(mode);
    await AppWidgetService.syncCurrentState(widgetMode: mode, widgetTheme: themeForMode);
    await _loadPayload();
  }

  Future<void> _updateWidgetTheme(String themeKey) async {
    setState(() => _widgetTheme = themeKey);
    await HomeWidget.saveWidgetData<String>('pending_pin_theme', themeKey);
    await HomeWidget.saveWidgetData<String>('${_widgetMode}_theme', themeKey);
    await HomeWidget.saveWidgetData<String>('widget_theme', themeKey);
    await PreferencesService.instance.setWidgetThemeForMode(_widgetMode, themeKey);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: themeKey);
    await _loadPayload();
  }

  Future<void> _pinWidgetToHomeScreen() async {
    try {
      final tripState = ref.read(tripControllerProvider);
      final checklistState = ref.read(checklistControllerProvider);
      final now = DateTime.now();
      final upcoming = tripState.trips
          .where((t) => !t.isDeleted && t.startDate.isAfter(now.subtract(const Duration(days: 1))))
          .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

      final nextTrip = upcoming.isNotEmpty ? upcoming.first : null;
      final List<Expense> expenses = nextTrip != null
          ? await DatabaseHelper.instance.getExpenses(tripId: nextTrip.id, includeDeleted: false)
          : const <Expense>[];

      await AppWidgetService.updateWidgetPayload(
        upcomingTrip: nextTrip,
        items: checklistState.items,
        expenses: expenses,
        countries: _countries,
        widgetMode: _widgetMode,
        widgetTheme: _widgetTheme,
      );

      await HomeWidget.saveWidgetData<String>('pending_pin_mode', _widgetMode);
      await HomeWidget.saveWidgetData<String>('pending_pin_theme', _widgetTheme);
      await HomeWidget.saveWidgetData<String>('${_widgetMode}_theme', _widgetTheme);
      await HomeWidget.saveWidgetData<String>('widget_theme', _widgetTheme);
      await HomeWidget.saveWidgetData<int>('user_selected_size', _selectedSize);
      await HomeWidget.saveWidgetData<bool>('pending_pin_map_show_continents', _showContinents);
      await HomeWidget.saveWidgetData<bool>('pending_pin_map_show_wishlist', _showWishlist);
      await HomeWidget.saveWidgetData<bool>('pending_pin_trip_show_countdown', _showCountdown);
      await HomeWidget.saveWidgetData<bool>('pending_pin_trip_show_packing', _showPacking);
      await HomeWidget.saveWidgetData<bool>('pending_pin_trip_show_budget', _showBudget);
      await HomeWidget.saveWidgetData<bool>('pending_pin_currency_show_live_rate', _showLiveRate);
      await HomeWidget.saveWidgetData<bool>('pending_pin_currency_show_reverse_rate', _showReverseRate);
      await HomeWidget.saveWidgetData<bool>('pending_pin_quick_expense_show_remaining', _showRemainingBudget);
      await HomeWidget.saveWidgetData<bool>('pending_pin_quick_expense_show_last', _showLastExpense);

      final isSupported = await HomeWidget.isRequestPinWidgetSupported() ?? false;
      if (isSupported) {
        String providerName;
        switch (_widgetMode) {
          case 'world_map':
            providerName = _selectedSize == 2
                ? 'PackBuddyMapLargeWidgetProvider'
                : (_selectedSize == 1 ? 'PackBuddyMapMediumWidgetProvider' : 'PackBuddyMapWidgetProvider');
            break;
          case 'quick_expense':
            providerName = _selectedSize == 2
                ? 'PackBuddyExpenseLargeWidgetProvider'
                : (_selectedSize == 1 ? 'PackBuddyExpenseMediumWidgetProvider' : 'PackBuddyExpenseWidgetProvider');
            break;
          case 'currency_converter':
            providerName = _selectedSize == 2
                ? 'PackBuddyCurrencyLargeWidgetProvider'
                : (_selectedSize == 1 ? 'PackBuddyCurrencyMediumWidgetProvider' : 'PackBuddyCurrencyWidgetProvider');
            break;
          case 'trip':
          default:
            providerName = _selectedSize == 2
                ? 'PackBuddyLargeWidgetProvider'
                : (_selectedSize == 1 ? 'PackBuddyMediumWidgetProvider' : 'PackBuddyWidgetProvider');
            break;
        }

        bool pinnedViaNative = false;
        try {
          final res = await const MethodChannel('com.sleepyhead.packbuddy/widget_pin').invokeMethod<bool>('pinWidget', {
            'mode': _widgetMode,
            'theme': _widgetTheme,
            'size': _selectedSize,
            'provider': providerName,
            'showContinents': _showContinents,
            'showWishlist': _showWishlist,
            'showCountdown': _showCountdown,
            'showPacking': _showPacking,
            'showBudget': _showBudget,
            'showLiveRate': _showLiveRate,
            'showReverseRate': _showReverseRate,
            'showRemainingBudget': _showRemainingBudget,
            'showLastExpense': _showLastExpense,
          });
          pinnedViaNative = res == true;
        } catch (_) {}

        if (!pinnedViaNative) {
          await HomeWidget.requestPinWidget(
            name: providerName,
            androidName: providerName,
            qualifiedAndroidName: 'com.sleepyhead.packbuddy.$providerName',
          );
        }
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n?.pinWidgetSuccess ?? 'Widget added to home screen.',
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF059669),
            ),
          );
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n?.pinWidgetGuide ??
                          'Long-press your home screen and choose Widgets > PackBuddy to add.',
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.pinWidgetGuide ??
                  'Long-press your home screen and choose Widgets > PackBuddy to add.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _updateCountdown(bool val) async {
    setState(() => _showCountdown = val);
    await PreferencesService.instance.setWidgetShowCountdown(val);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: _widgetTheme);
  }

  Future<void> _updatePacking(bool val) async {
    setState(() => _showPacking = val);
    await PreferencesService.instance.setWidgetShowPacking(val);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: _widgetTheme);
  }

  Future<void> _updateBudget(bool val) async {
    setState(() => _showBudget = val);
    await PreferencesService.instance.setWidgetShowBudget(val);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: _widgetTheme);
  }

  Future<void> _updateContinents(bool val) async {
    setState(() => _showContinents = val);
    await PreferencesService.instance.setWidgetShowContinents(val);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: _widgetTheme);
  }

  Future<void> _updateWishlist(bool val) async {
    setState(() => _showWishlist = val);
    await PreferencesService.instance.setWidgetShowWishlist(val);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: _widgetTheme);
  }

  Future<void> _updateLiveRate(bool val) async {
    setState(() => _showLiveRate = val);
    await PreferencesService.instance.setWidgetShowLiveRate(val);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: _widgetTheme);
  }

  Future<void> _updateReverseRate(bool val) async {
    setState(() => _showReverseRate = val);
    await PreferencesService.instance.setWidgetShowReverseRate(val);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: _widgetTheme);
  }

  Future<void> _updateRemainingBudget(bool val) async {
    setState(() => _showRemainingBudget = val);
    await PreferencesService.instance.setWidgetShowRemainingBudget(val);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: _widgetTheme);
  }

  Future<void> _updateLastExpense(bool val) async {
    setState(() => _showLastExpense = val);
    await PreferencesService.instance.setWidgetShowLastExpense(val);
    await AppWidgetService.syncCurrentState(widgetMode: _widgetMode, widgetTheme: _widgetTheme);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeLocale = ref.watch(localeProvider);
    final lang = Localizations.maybeLocaleOf(context)?.languageCode ?? activeLocale.languageCode;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.widgets_rounded, color: theme.colorScheme.primary, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.widgetSettings ?? 'Home Screen Widget',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      AppWidgetLocalization.getHeaderSubtitle(lang),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Widget Mode Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildModeChoiceChip(
                  key: 'trip',
                  label: AppWidgetLocalization.getTripModeLabel(lang),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildModeChoiceChip(
                  key: 'world_map',
                  label: AppWidgetLocalization.getWorldMapModeLabel(lang),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildModeChoiceChip(
                  key: 'currency_converter',
                  label: AppWidgetLocalization.getCurrencyConverterModeLabel(lang),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildModeChoiceChip(
                  key: 'quick_expense',
                  label: AppWidgetLocalization.getQuickExpenseModeLabel(lang),
                  theme: theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Size Selector Tabs (Small, Medium, Large)
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text(l10n?.widgetSizeSmall ?? 'Small'),
                    icon: const Icon(Icons.crop_square_rounded, size: 16),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text(l10n?.widgetSizeMedium ?? 'Medium'),
                    icon: const Icon(Icons.crop_16_9_rounded, size: 16),
                  ),
                  ButtonSegment<int>(
                    value: 2,
                    label: Text(l10n?.widgetSizeLarge ?? 'Large'),
                    icon: const Icon(Icons.aspect_ratio_rounded, size: 16),
                  ),
                ],
                selected: {_selectedSize},
                onSelectionChanged: (val) {
                  setState(() => _selectedSize = val.first);
                },
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Theme & Style Selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppWidgetLocalization.getThemeSectionTitle(lang),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Category Switch: [ 🌙 Dark (9) ]  [ ☀️ Light (7) ]
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          _selectedThemeCategory = 0;
                          if (lightWidgetThemes.contains(_widgetTheme)) {
                            _updateWidgetTheme(darkWidgetThemes.first);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 6.5),
                        decoration: BoxDecoration(
                          color: _selectedThemeCategory == 0
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedThemeCategory == 0
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🌙 ${AppWidgetLocalization.getDarkThemesCategory(lang)} (${darkWidgetThemes.length})',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: _selectedThemeCategory == 0 ? FontWeight.w800 : FontWeight.w600,
                            color: _selectedThemeCategory == 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          _selectedThemeCategory = 1;
                          if (darkWidgetThemes.contains(_widgetTheme)) {
                            _updateWidgetTheme(lightWidgetThemes.first);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 6.5),
                        decoration: BoxDecoration(
                          color: _selectedThemeCategory == 1
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedThemeCategory == 1
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '☀️ ${AppWidgetLocalization.getLightThemesCategory(lang)} (${lightWidgetThemes.length})',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: _selectedThemeCategory == 1 ? FontWeight.w800 : FontWeight.w600,
                            color: _selectedThemeCategory == 1
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Theme Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: (_selectedThemeCategory == 0 ? darkWidgetThemes : lightWidgetThemes)
                      .map((key) {
                    final config = WidgetThemeConfig.fromKey(key);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildThemeChip(
                        key,
                        config.cardBgColor,
                        config.accentColor,
                        config.emoji,
                        lang,
                        theme,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Widget Preview Canvas (Simulating iOS/Android widget)
          Center(
            child: _buildWidgetPreview(theme, isDark, l10n, lang),
          ),
          const SizedBox(height: 16),

          // Customization switches dynamically matching the selected mode
          if (_widgetMode == 'trip') ...[
            _buildSwitchRow(
              title: l10n?.showCountdown ?? 'Show Countdown',
              value: _showCountdown,
              onChanged: _updateCountdown,
            ),
            _buildSwitchRow(
              title: l10n?.showPackingProgress ?? 'Show Packing Progress',
              value: _showPacking,
              onChanged: _updatePacking,
            ),
            _buildSwitchRow(
              title: l10n?.showBudgetData ?? 'Show Budget Summary',
              value: _showBudget,
              onChanged: _updateBudget,
            ),
          ] else if (_widgetMode == 'world_map') ...[
            _buildSwitchRow(
              title: AppWidgetLocalization.getShowContinentsLabel(lang),
              value: _showContinents,
              onChanged: _updateContinents,
            ),
            _buildSwitchRow(
              title: AppWidgetLocalization.getShowWishlistLabel(lang),
              value: _showWishlist,
              onChanged: _updateWishlist,
            ),
          ] else if (_widgetMode == 'currency_converter') ...[
            _buildSwitchRow(
              title: AppWidgetLocalization.getShowLiveRateLabel(lang),
              value: _showLiveRate,
              onChanged: _updateLiveRate,
            ),
            _buildSwitchRow(
              title: AppWidgetLocalization.getShowReverseRateLabel(lang),
              value: _showReverseRate,
              onChanged: _updateReverseRate,
            ),
          ] else if (_widgetMode == 'quick_expense') ...[
            _buildSwitchRow(
              title: AppWidgetLocalization.getShowRemainingBudgetLabel(lang),
              value: _showRemainingBudget,
              onChanged: _updateRemainingBudget,
            ),
            _buildSwitchRow(
              title: AppWidgetLocalization.getShowLastExpenseLabel(lang),
              value: _showLastExpense,
              onChanged: _updateLastExpense,
            ),
          ],
          const SizedBox(height: 14),

          // Pin Widget to Home Screen Action Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _pinWidgetToHomeScreen,
              icon: const Icon(Icons.add_to_home_screen_rounded, size: 18),
              label: Text(
                l10n?.addWidgetToHomeScreen ?? 'Add Widget to Home Screen',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChoiceChip({
    required String key,
    required String label,
    required ThemeData theme,
  }) {
    final isSelected = _widgetMode == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _updateWidgetMode(key),
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      ),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildThemeChip(
    String key,
    Color swatchColor,
    Color accentColor,
    String emoji,
    String lang,
    ThemeData theme,
  ) {
    final isSelected = _widgetTheme == key;
    final label = AppWidgetLocalization.getThemeName(lang, key);
    return InkWell(
      onTap: () => _updateWidgetTheme(key),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: swatchColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$emoji $label',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Master preview router: delegates 1:1 to WidgetCardRenderer
  Widget _buildWidgetPreview(ThemeData theme, bool isDark, AppLocalizations? l10n, String lang) {
    final themeConfig = WidgetThemeConfig.fromKey(_widgetTheme);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: WidgetCardRenderer.buildWidgetCard(
        mode: _widgetMode,
        sizeIndex: _selectedSize,
        themeConfig: themeConfig,
        widgetData: _widgetData,
        countries: _countries,
        lang: lang,
        l10n: l10n,
        showContinents: _showContinents,
        showWishlist: _showWishlist,
        showCountdown: _showCountdown,
        showPacking: _showPacking,
        showBudget: _showBudget,
        showLiveRate: _showLiveRate,
        showReverseRate: _showReverseRate,
        showRemainingBudget: _showRemainingBudget,
        showLastExpense: _showLastExpense,
      ),
    );
  }
}
