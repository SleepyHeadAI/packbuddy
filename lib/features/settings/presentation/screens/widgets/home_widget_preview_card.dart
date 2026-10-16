import 'package:flutter/material.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// In-App Home Screen Widget Preview & Customization Card (Feature F-9)
class HomeWidgetPreviewCard extends StatefulWidget {
  const HomeWidgetPreviewCard({super.key});

  @override
  State<HomeWidgetPreviewCard> createState() => _HomeWidgetPreviewCardState();
}

class _HomeWidgetPreviewCardState extends State<HomeWidgetPreviewCard> {
  int _selectedSize = 1; // 0: Small, 1: Medium, 2: Large
  late bool _showCountdown;
  late bool _showPacking;
  late bool _showBudget;

  @override
  void initState() {
    super.initState();
    final prefs = PreferencesService.instance;
    _showCountdown = prefs.isWidgetShowCountdown();
    _showPacking = prefs.isWidgetShowPacking();
    _showBudget = prefs.isWidgetShowBudget();
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
                      '3d',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),

          // Destination
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paris Getaway',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'France',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
                        '${l10n?.shareChecklist ?? "Packing"}: 18/24',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('75%', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 0.75,
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
                    '${l10n?.spent ?? "Spent"}: \$620',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${l10n?.remaining ?? "Rem"}: \$1,880',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
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
