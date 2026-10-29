import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/core/services/app_widget_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// In-App Home Screen Widget Preview & Customization Card (Feature F-9)
class HomeWidgetPreviewCard extends ConsumerStatefulWidget {
  const HomeWidgetPreviewCard({super.key});

  @override
  ConsumerState<HomeWidgetPreviewCard> createState() => _HomeWidgetPreviewCardState();
}

class _HomeWidgetPreviewCardState extends ConsumerState<HomeWidgetPreviewCard> {
  int _selectedSize = 1; // 0: Small, 1: Medium, 2: Large
  late bool _showCountdown;
  late bool _showPacking;
  late bool _showBudget;
  AppWidgetData? _widgetData;

  @override
  void initState() {
    super.initState();
    final prefs = PreferencesService.instance;
    _showCountdown = prefs.isWidgetShowCountdown();
    _showPacking = prefs.isWidgetShowPacking();
    _showBudget = prefs.isWidgetShowBudget();
    _loadPayload();
  }

  Future<void> _loadPayload() async {
    final data = await AppWidgetService.getWidgetPayload();
    if (mounted) {
      setState(() {
        _widgetData = data;
      });
    }
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
      );

      final isSupported = await HomeWidget.isRequestPinWidgetSupported() ?? false;
      if (isSupported) {
        await HomeWidget.requestPinWidget(
          name: 'PackBuddyWidgetProvider',
          androidName: 'PackBuddyWidgetProvider',
          qualifiedAndroidName: 'com.sleepyhead.packbuddy.PackBuddyWidgetProvider',
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
                      l10n?.pinWidgetSuccess ?? 'Widget ana ekrana eklendi.',
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
                          'Ana ekranınıza uzun basarak Widget\'lar > PackBuddy seçeneğiyle widget ekleyebilirsiniz.',
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
                  'Ana ekranınıza uzun basarak Widget\'lar > PackBuddy seçeneğiyle widget ekleyebilirsiniz.',
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
  }

  Future<void> _updatePacking(bool val) async {
    setState(() => _showPacking = val);
    await PreferencesService.instance.setWidgetShowPacking(val);
  }

  Future<void> _updateBudget(bool val) async {
    setState(() => _showBudget = val);
    await PreferencesService.instance.setWidgetShowBudget(val);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                      l10n?.widgetPreview ?? 'Glanceable packing & countdown',
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
          const SizedBox(height: 16),

          // Widget Preview Canvas (Simulating iOS/Android widget)
          Center(
            child: _buildWidgetPreview(theme, isDark, l10n),
          ),
          const SizedBox(height: 16),

          // Customization switches
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

  Widget _buildWidgetPreview(ThemeData theme, bool isDark, AppLocalizations? l10n) {
    final double width = switch (_selectedSize) {
      0 => 148.0,
      1 => 280.0,
      2 => 280.0,
      _ => 280.0,
    };
    final double height = switch (_selectedSize) {
      0 => 148.0,
      1 => 130.0,
      2 => 210.0,
      _ => 130.0,
    };

    final String tripTitle = _widgetData?.tripTitle ?? l10n?.appName ?? 'PackBuddy';
    final String destination = _widgetData?.destination ?? 'Plan your next trip';
    final String daysText = _widgetData != null && _widgetData!.daysUntil > 0
        ? '${_widgetData!.daysUntil}d'
        : (_widgetData != null ? '0d' : '-');
    final int totalItems = _widgetData?.totalItems ?? 0;
    final int packedItems = _widgetData?.packedItems ?? 0;
    final int packingPercent = _widgetData?.packingPercent ?? 0;
    final double packingProgress = totalItems > 0 ? (packedItems / totalItems).clamp(0.0, 1.0) : 0.0;
    final String budgetSpent = _widgetData?.budgetSpent ?? '';

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Widget Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flight_takeoff_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'PackBuddy',
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
                ),
                if (_showCountdown)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Packing Progress
            if (_showPacking) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${l10n?.shareChecklist ?? "Packing"}: $packedItems/$totalItems',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('$packingPercent%', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: packingProgress,
                      minHeight: 4,
                      backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.successPastel),
                    ),
                  ),
                ],
              ),
            ],

            // Budget Summary (Medium / Large)
            if (_showBudget && _selectedSize != 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      budgetSpent.isNotEmpty ? '${l10n?.spent ?? "Spent"}: $budgetSpent' : (l10n?.budget ?? 'Budget'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
