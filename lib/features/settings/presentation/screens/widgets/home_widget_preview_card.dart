import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
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
      await HomeWidget.saveWidgetData<int>('user_selected_size', _selectedSize);

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

        await HomeWidget.requestPinWidget(
          name: providerName,
          androidName: providerName,
          qualifiedAndroidName: 'com.sleepyhead.packbuddy.$providerName',
        );
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

  /// Master preview router: switches dimensions and layout based on Small (0), Medium (1), and Large (2)
  Widget _buildWidgetPreview(ThemeData theme, bool isDark, AppLocalizations? l10n, String lang) {
    final double width = switch (_selectedSize) {
      0 => 156.0,
      1 => 310.0,
      2 => 310.0,
      _ => 310.0,
    };
    final double height = switch (_selectedSize) {
      0 => 156.0,
      1 => 140.0,
      2 => 300.0,
      _ => 140.0,
    };

    final themeConfig = WidgetThemeConfig.fromKey(_widgetTheme);

    // Build the country color map for our miniature vector World Map
    final colorMap = <String, Color>{};
    for (final country in _countries) {
      final code = country.code.toLowerCase().trim();
      if (country.isLived) {
        colorMap[code] = themeConfig.livedColor;
      } else if (country.isVisited) {
        colorMap[code] = themeConfig.visitedColor;
      } else if (country.isWishlist) {
        colorMap[code] = themeConfig.wishlistColor;
      }
    }
    // Also map Northern Cyprus color onto Cyprus polygon if set
    final nc = _countries.where((c) => c.code == 'NC').firstOrNull;
    if (nc != null && (colorMap['cy'] == null || nc.isLived || nc.isVisited)) {
      if (nc.isLived) {
        colorMap['cy'] = themeConfig.livedColor;
      } else if (nc.isVisited) {
        colorMap['cy'] = themeConfig.visitedColor;
      } else if (nc.isWishlist && colorMap['cy'] == null) {
        colorMap['cy'] = themeConfig.wishlistColor;
      }
    }

    final int livedCount = _countries.where((c) => c.isLived).length;
    final int visitedCount = _countries.isNotEmpty
        ? _countries.where((c) => c.isVisited || c.isLived).length
        : (_widgetData?.visitedCountriesCount ?? 0);
    final int wishlistCount = _countries.isNotEmpty
        ? _countries.where((c) => c.isWishlist).length
        : (_widgetData?.wishlistCountriesCount ?? 0);
    final int continentsCount = _countries.isNotEmpty
        ? _countries
            .where((c) => c.isVisited || c.isLived)
            .map((c) => c.continent)
            .where((c) => c.isNotEmpty)
            .toSet()
            .length
        : (_widgetData?.continentsCount ?? 0);

    final String rawPct = (_widgetData?.worldPercentage ?? '0.0').replaceAll('%', '').trim();
    final double worldPercent = double.tryParse(rawPct) ??
        (visitedCount > 0 ? (visitedCount / 229.0 * 100.0) : 0.0);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeConfig.cardBgColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: themeConfig.cardBorderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: switch (_widgetMode) {
          'world_map' => _buildWorldMapContent(
              theme: theme,
              isDark: isDark,
              lang: lang,
              themeConfig: themeConfig,
              visitedCount: visitedCount,
              livedCount: livedCount,
              wishlistCount: wishlistCount,
              continentsCount: continentsCount,
              worldPercent: worldPercent,
              colorMap: colorMap,
            ),
          'currency_converter' => _buildCurrencyContent(
              theme: theme,
              isDark: isDark,
              lang: lang,
              themeConfig: themeConfig,
            ),
          'quick_expense' => _buildQuickExpenseContent(
              theme: theme,
              isDark: isDark,
              lang: lang,
              themeConfig: themeConfig,
            ),
          _ => _buildTripContent(
              theme: theme,
              isDark: isDark,
              lang: lang,
              l10n: l10n,
            ),
        },
      ),
    );
  }

  // ==========================================
  // WORLD MAP WIDGET PREVIEWS (Small / Medium / Large)
  // ==========================================

  Widget _buildWorldMapContent({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required int visitedCount,
    required int livedCount,
    required int wishlistCount,
    required int continentsCount,
    required double worldPercent,
    required Map<String, Color> colorMap,
  }) {
    switch (_selectedSize) {
      case 0:
        return _buildSmallWorldMap(
          theme: theme,
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          visitedCount: visitedCount,
          wishlistCount: wishlistCount,
          continentsCount: continentsCount,
          worldPercent: worldPercent,
        );
      case 1:
        return _buildMediumWorldMap(
          theme: theme,
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          visitedCount: visitedCount,
          wishlistCount: wishlistCount,
          continentsCount: continentsCount,
          worldPercent: worldPercent,
          colorMap: colorMap,
        );
      case 2:
      default:
        return _buildLargeWorldMap(
          theme: theme,
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          visitedCount: visitedCount,
          livedCount: livedCount,
          wishlistCount: wishlistCount,
          continentsCount: continentsCount,
          worldPercent: worldPercent,
          colorMap: colorMap,
        );
    }
  }

  /// Small World Map Widget (156x156): Compact glanceable stats with big bold number
  Widget _buildSmallWorldMap({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required int visitedCount,
    required int wishlistCount,
    required int continentsCount,
    required double worldPercent,
  }) {
    final visitedTitle = AppWidgetLocalization.getVisitedTitle(lang, visitedCount);
    final continentsSub = AppWidgetLocalization.getContinentsSubtitle(lang, continentsCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.public_rounded, size: 13, color: themeConfig.accentColor),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                'PackBuddy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '%${worldPercent.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Big Prominent Stat
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$visitedCount',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: themeConfig.accentColor,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              visitedTitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: themeConfig.titleTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              continentsSub,
              style: TextStyle(
                fontSize: 9.5,
                color: themeConfig.subtitleTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // Bottom progress & stats
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (worldPercent / 100.0).clamp(0.0, 1.0),
                minHeight: 3.5,
                backgroundColor: themeConfig.unvisitedLandColor.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(themeConfig.accentColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '✈️ $visitedCount',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
                ),
                Text(
                  '🌟 $wishlistCount',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Medium World Map Widget (310x140): Horizontal 2-column layout with miniature vector map thumbnail
  Widget _buildMediumWorldMap({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required int visitedCount,
    required int wishlistCount,
    required int continentsCount,
    required double worldPercent,
    required Map<String, Color> colorMap,
  }) {
    final worldHeader = AppWidgetLocalization.getWorldHeader(lang);
    final visitedTitle = AppWidgetLocalization.getVisitedTitle(lang, visitedCount);
    final explorationRateLabel = AppWidgetLocalization.getExplorationRateLabel(lang);
    final visitedStatLabel = AppWidgetLocalization.getVisitedStatLabel(lang, visitedCount);
    final wishlistStatLabel = AppWidgetLocalization.getWishlistStatLabel(lang, wishlistCount);
    final continentsStatLabel = AppWidgetLocalization.getContinentsStatLabel(lang, continentsCount);

    final unvisitedLandColor = themeConfig.unvisitedLandColor;
    final countryBorderColor = themeConfig.countryBorderColor;
    final oceanColor = themeConfig.oceanColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Stats & Progress
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.public_rounded, size: 14, color: themeConfig.accentColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            worldHeader,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: themeConfig.accentColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeConfig.badgeBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '%${worldPercent.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Title
              Text(
                visitedTitle,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: themeConfig.titleTextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    explorationRateLabel,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (worldPercent / 100.0).clamp(0.0, 1.0),
                      minHeight: 3.5,
                      backgroundColor: themeConfig.unvisitedLandColor.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(themeConfig.accentColor),
                    ),
                  ),
                ],
              ),

              // Bottom row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      visitedStatLabel,
                      style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      wishlistStatLabel,
                      style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Right Column: Miniature Painted World Map Card
        SizedBox(
          width: 110,
          child: Container(
            decoration: BoxDecoration(
              color: oceanColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: themeConfig.mapBorderColor,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 2000 / 857,
                        child: SimpleMap(
                          instructions: SMapWorld.instructions,
                          defaultColor: unvisitedLandColor,
                          colors: colorMap,
                          countryBorder: CountryBorder(
                            color: countryBorderColor,
                            width: 0.35,
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: themeConfig.statBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    continentsStatLabel,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: themeConfig.accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Large World Map Widget (310x300): Hero miniature painted world map with legend
  Widget _buildLargeWorldMap({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required int visitedCount,
    required int livedCount,
    required int wishlistCount,
    required int continentsCount,
    required double worldPercent,
    required Map<String, Color> colorMap,
  }) {
    final worldHeader = AppWidgetLocalization.getWorldHeader(lang);
    final continentsStatLabel = AppWidgetLocalization.getContinentsStatLabel(lang, continentsCount);

    final legendLived = AppWidgetLocalization.getLegendLived(lang);
    final legendVisited = AppWidgetLocalization.getLegendVisited(lang);
    final legendWishlist = AppWidgetLocalization.getLegendWishlist(lang);

    final unvisitedLandColor = themeConfig.unvisitedLandColor;
    final countryBorderColor = themeConfig.countryBorderColor;
    final oceanColor = themeConfig.oceanColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Row(
          children: [
            Icon(Icons.public_rounded, size: 16, color: themeConfig.accentColor),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                worldHeader,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '%${worldPercent.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Hero Miniature Vector World Map Showcase
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: oceanColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeConfig.mapBorderColor,
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: 2000 / 857,
                    child: SimpleMap(
                      instructions: SMapWorld.instructions,
                      defaultColor: unvisitedLandColor,
                      colors: colorMap,
                      countryBorder: CountryBorder(
                        color: countryBorderColor,
                        width: 0.45,
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Floating interactive map legend banner
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: themeConfig.legendBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: themeConfig.legendBorderColor,
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLegendIndicator(themeConfig.livedColor, '$legendLived ($livedCount)', themeConfig.legendTextColor),
                          const SizedBox(width: 8),
                          _buildLegendIndicator(themeConfig.visitedColor, '$legendVisited ($visitedCount)', themeConfig.legendTextColor),
                          const SizedBox(width: 8),
                          _buildLegendIndicator(themeConfig.wishlistColor, '$legendWishlist ($wishlistCount)', themeConfig.legendTextColor),
                          if (continentsCount > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              continentsStatLabel,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: themeConfig.legendTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendIndicator(Color color, String text, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3.5),
        Text(
          text,
          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: textColor),
        ),
      ],
    );
  }



  // ==========================================
  // TRIP WIDGET PREVIEWS (Small / Medium / Large)
  // ==========================================

  Widget _buildTripContent({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required AppLocalizations? l10n,
  }) {
    switch (_selectedSize) {
      case 0:
        return _buildSmallTrip(theme: theme, isDark: isDark, lang: lang, l10n: l10n);
      case 1:
        return _buildMediumTrip(theme: theme, isDark: isDark, lang: lang, l10n: l10n);
      case 2:
      default:
        return _buildLargeTrip(theme: theme, isDark: isDark, lang: lang, l10n: l10n);
    }
  }

  Widget _buildSmallTrip({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required AppLocalizations? l10n,
  }) {
    final defaultDestination = AppWidgetLocalization.getDefaultDestination(lang);
    final tripTitle = _widgetData?.tripTitle ?? (l10n?.appName ?? 'PackBuddy');
    final destination = _widgetData?.destination ?? defaultDestination;
    final int days = _widgetData?.daysUntil ?? 0;
    final String daysText = AppWidgetLocalization.formatDaysUntil(lang, days);
    final int totalItems = _widgetData?.totalItems ?? 0;
    final int packedItems = _widgetData?.packedItems ?? 0;
    final double packingProgress = totalItems > 0 ? (packedItems / totalItems).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.flight_takeoff_rounded, size: 13, color: theme.colorScheme.primary),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                'PackBuddy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            if (_showCountdown) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$days${AppWidgetLocalization.getDaysSuffix(lang)}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),

        // Destination / Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tripTitle,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              destination,
              style: TextStyle(
                fontSize: 9.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // Packing
        if (_showPacking)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${AppWidgetLocalization.getPackingLabel(lang)}: $packedItems/$totalItems',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: packingProgress,
                  minHeight: 3.5,
                  backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.successPastel),
                ),
              ),
            ],
          )
        else
          Text(
            daysText,
            style: TextStyle(fontSize: 9.5, color: theme.colorScheme.onSurfaceVariant),
          ),
      ],
    );
  }

  Widget _buildMediumTrip({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required AppLocalizations? l10n,
  }) {
    final tripHeader = AppWidgetLocalization.getTripHeader(lang);
    final defaultDestination = AppWidgetLocalization.getDefaultDestination(lang);
    final tripTitle = _widgetData?.tripTitle ?? (l10n?.appName ?? 'PackBuddy');
    final destination = _widgetData?.destination ?? defaultDestination;
    final int days = _widgetData?.daysUntil ?? 0;
    final String daysText = AppWidgetLocalization.formatDaysUntil(lang, days);
    final int totalItems = _widgetData?.totalItems ?? 0;
    final int packedItems = _widgetData?.packedItems ?? 0;
    final int packingPercent = _widgetData?.packingPercent ?? 0;
    final double packingProgress = totalItems > 0 ? (packedItems / totalItems).clamp(0.0, 1.0) : 0.0;
    final String budgetSpent = _widgetData?.budgetSpent ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.flight_takeoff_rounded, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tripHeader,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Title & destination
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tripTitle,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    destination,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // Countdown badge
              if (_showCountdown)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    daysText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Right Column: Packing & Budget Progress
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_showPacking) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            AppWidgetLocalization.getPackingLabel(lang),
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$packingPercent%',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: packingProgress,
                        minHeight: 4,
                        backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.successPastel),
                      ),
                    ),
                    Text(
                      '$packedItems/$totalItems',
                      style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
              if (_showBudget) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppWidgetLocalization.getSpentLabel(lang),
                        style: TextStyle(fontSize: 8.5, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        budgetSpent.isNotEmpty ? budgetSpent : AppWidgetLocalization.getBudgetLabel(lang),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeTrip({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required AppLocalizations? l10n,
  }) {
    final tripHeader = AppWidgetLocalization.getTripHeader(lang);
    final defaultDestination = AppWidgetLocalization.getDefaultDestination(lang);
    final tripTitle = _widgetData?.tripTitle ?? (l10n?.appName ?? 'PackBuddy');
    final destination = _widgetData?.destination ?? defaultDestination;
    final int days = _widgetData?.daysUntil ?? 0;
    final String daysText = AppWidgetLocalization.formatDaysUntil(lang, days);
    final int totalItems = _widgetData?.totalItems ?? 0;
    final int packedItems = _widgetData?.packedItems ?? 0;
    final int packingPercent = _widgetData?.packingPercent ?? 0;
    final double packingProgress = totalItems > 0 ? (packedItems / totalItems).clamp(0.0, 1.0) : 0.0;
    final String budgetSpent = _widgetData?.budgetSpent ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Row(
            children: [
              Icon(Icons.flight_takeoff_rounded, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  tripHeader,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_showCountdown) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      daysText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Destination Showcase Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tripTitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 12, color: theme.colorScheme.primary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        destination,
                        style: TextStyle(fontSize: 10.5, color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Packing Checklist Progress Card
          if (_showPacking) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${AppWidgetLocalization.getPackingLabel(lang)}: $packedItems/$totalItems',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$packingPercent%',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: packingProgress,
                      minHeight: 4.5,
                      backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.successPastel),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Budget Card
          if (_showBudget) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      AppWidgetLocalization.getSpentLabel(lang),
                      style: TextStyle(fontSize: 10.5, color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    budgetSpent.isNotEmpty ? budgetSpent : '-',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Bottom status footer
          Center(
            child: Text(
              AppWidgetLocalization.getCountdownActive(lang),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

  // ==========================================
  // CURRENCY CONVERTER WIDGET PREVIEWS
  // ==========================================

  Widget _buildCurrencyContent({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
  }) {
    switch (_selectedSize) {
      case 0:
        return _buildSmallCurrency(
          theme: theme,
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
        );
      case 1:
        return _buildMediumCurrency(
          theme: theme,
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
        );
      case 2:
      default:
        return _buildLargeCurrency(
          theme: theme,
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
        );
    }
  }

  Widget _buildSmallCurrency({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
  }) {
    final currencyHeader = AppWidgetLocalization.getCurrencyHeader(lang);
    final userCurrency = _widgetData?.userCurrency ?? 'TRY';
    final usdRate = _widgetData?.currencyRateUSD ?? '34.25';
    final eurRate = _widgetData?.currencyRateEUR ?? '37.10';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top header
        Row(
          children: [
            Icon(Icons.currency_exchange_rounded, size: 13, color: themeConfig.accentColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                currencyHeader,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                userCurrency,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Main Rate
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1 USD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: themeConfig.subtitleTextColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              usdRate,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: themeConfig.titleTextColor,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // Bottom EUR rate
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 EUR',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
              ),
              Text(
                eurRate,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: themeConfig.titleTextColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediumCurrency({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
  }) {
    final currencyHeader = AppWidgetLocalization.getCurrencyHeader(lang);
    final userCurrency = _widgetData?.userCurrency ?? 'TRY';
    final usdRate = _widgetData?.currencyRateUSD ?? '34.25';
    final eurRate = _widgetData?.currencyRateEUR ?? '37.10';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Rates & Details
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.currency_exchange_rounded, size: 13, color: themeConfig.accentColor),
                  const SizedBox(width: 4),
                  Text(
                    currencyHeader,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.accentColor,
                    ),
                  ),
                ],
              ),

              // Rates Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeConfig.statBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1 USD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor)),
                          const SizedBox(height: 2),
                          Text(usdRate, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: themeConfig.titleTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeConfig.statBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1 EUR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor)),
                          const SizedBox(height: 2),
                          Text(eurRate, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: themeConfig.titleTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '● Canlı Kurlar',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                  ),
                  if (_showReverseRate)
                    Text(
                      '1 $userCurrency ≈ \$${(1.0 / (double.tryParse(usdRate.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 34.25)).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 9, color: themeConfig.subtitleTextColor),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Right Column: Currency Badge Box
        Container(
          width: 90,
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: themeConfig.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.swap_horiz_rounded, color: themeConfig.accentColor, size: 22),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                userCurrency,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: themeConfig.titleTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeCurrency({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
  }) {
    final currencyHeader = AppWidgetLocalization.getCurrencyHeader(lang);
    final userCurrency = _widgetData?.userCurrency ?? 'TRY';
    final usdRate = _widgetData?.currencyRateUSD ?? '34.25';
    final eurRate = _widgetData?.currencyRateEUR ?? '37.10';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.currency_exchange_rounded, size: 14, color: themeConfig.accentColor),
                const SizedBox(width: 4),
                Text(
                  currencyHeader,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: themeConfig.accentColor,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                userCurrency,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ],
        ),

        // Hero Rates Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeConfig.statBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1 USD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor)),
                    const SizedBox(height: 4),
                    Text(usdRate, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: themeConfig.titleTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeConfig.statBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1 EUR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor)),
                    const SizedBox(height: 4),
                    Text(eurRate, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: themeConfig.titleTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Quick Conversions Presets
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hızlı Çevrimler',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: themeConfig.titleTextColor),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$10 ≈ ${(10 * (double.tryParse(usdRate.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 34.25)).toStringAsFixed(1)} $userCurrency',
                      style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor)),
                  Text('\$50 ≈ ${(50 * (double.tryParse(usdRate.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 34.25)).toStringAsFixed(1)} $userCurrency',
                      style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor)),
                  Text('\$100 ≈ ${(100 * (double.tryParse(usdRate.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 34.25)).toStringAsFixed(0)} $userCurrency',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: themeConfig.accentColor)),
                ],
              ),
            ],
          ),
        ),

        // Live Rate footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '✓ Otomatik Çift Yönlü Senkron',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
            ),
            const Text(
              'Çevrim Çevrimdışı Hazır',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // QUICK EXPENSE WIDGET PREVIEWS
  // ==========================================

  Widget _buildQuickExpenseContent({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
  }) {
    switch (_selectedSize) {
      case 0:
        return _buildSmallQuickExpense(
          theme: theme,
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
        );
      case 1:
        return _buildMediumQuickExpense(
          theme: theme,
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
        );
      case 2:
      default:
        return _buildLargeQuickExpense(
          theme: theme,
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
        );
    }
  }

  Widget _buildSmallQuickExpense({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
  }) {
    final expenseHeader = AppWidgetLocalization.getExpenseHeader(lang);
    final budgetSpent = _widgetData?.budgetSpent ?? '₺0.00';
    final remainingBudget = _widgetData?.remainingBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Header
        Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, size: 13, color: themeConfig.accentColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                expenseHeader,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '+',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Big Spent
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Harcanan',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
            ),
            const SizedBox(height: 1),
            Text(
              budgetSpent,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: themeConfig.titleTextColor,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // Remaining or prompt
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showRemainingBudget && remainingBudget != null ? 'Kalan' : '+ Hızlı Harcama',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: themeConfig.accentColor),
              ),
              if (_showRemainingBudget && remainingBudget != null)
                Text(
                  remainingBudget,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: themeConfig.titleTextColor),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediumQuickExpense({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
  }) {
    final expenseHeader = AppWidgetLocalization.getExpenseHeader(lang);
    final budgetSpent = _widgetData?.budgetSpent ?? '₺0.00';
    final remainingBudget = _widgetData?.remainingBudget;
    final lastExpense = _widgetData?.lastExpenseText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Spent & Remaining
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, size: 13, color: themeConfig.accentColor),
                  const SizedBox(width: 4),
                  Text(
                    expenseHeader,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: themeConfig.accentColor,
                    ),
                  ),
                ],
              ),

              // Big Spent & Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budgetSpent,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: themeConfig.titleTextColor,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (remainingBudget != null && _showRemainingBudget)
                    Text(
                      'Kalan Bütçe: $remainingBudget',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: themeConfig.subtitleTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),

              // Last Expense or Trip title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _showLastExpense && lastExpense != null ? 'Son: $lastExpense' : (_widgetData?.tripTitle ?? 'PackBuddy'),
                      style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right Column: Big Add Expense Button
        Container(
          width: 95,
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: themeConfig.accentColor,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.add_rounded, color: themeConfig.accentColor, size: 22),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Harcama Ekle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeQuickExpense({
    required ThemeData theme,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
  }) {
    final expenseHeader = AppWidgetLocalization.getExpenseHeader(lang);
    final budgetSpent = _widgetData?.budgetSpent ?? '₺0.00';
    final remainingBudget = _widgetData?.remainingBudget;
    final lastExpense = _widgetData?.lastExpenseText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, size: 14, color: themeConfig.accentColor),
                const SizedBox(width: 4),
                Text(
                  expenseHeader,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: themeConfig.accentColor,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Hızlı Kayıt',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ],
        ),

        // Big Spent & Remaining cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeConfig.statBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Harcanan Bütçe', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor)),
                    const SizedBox(height: 4),
                    Text(budgetSpent, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: themeConfig.titleTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            if (remainingBudget != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeConfig.statBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kalan Bütçe', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor)),
                      const SizedBox(height: 4),
                      Text(remainingBudget, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF10B981)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),

        // Last logged expense card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 16, color: themeConfig.accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Son Harcama',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
                    ),
                    Text(
                      lastExpense ?? 'Henüz harcama kaydedilmedi',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: themeConfig.titleTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action Button: Tap to add expense
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: themeConfig.accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text(
                '+ Harcama Ekle',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
