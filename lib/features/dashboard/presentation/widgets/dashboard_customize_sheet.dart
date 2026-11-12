import 'package:flutter/material.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../dashboard_localization.dart';

/// Interactive modal sheet allowing users to drag-and-drop reorder and toggle
/// any dashboard section (including wide cards and mini boxes).
class DashboardCustomizeSheet extends StatefulWidget {
  final List<String> currentOrder;
  final Set<String> hiddenSections;
  final ValueChanged<List<String>> onOrderChanged;
  final ValueChanged<Set<String>> onHiddenChanged;
  final VoidCallback onResetToDefault;

  const DashboardCustomizeSheet({
    super.key,
    required this.currentOrder,
    required this.hiddenSections,
    required this.onOrderChanged,
    required this.onHiddenChanged,
    required this.onResetToDefault,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> currentOrder,
    required Set<String> hiddenSections,
    required ValueChanged<List<String>> onOrderChanged,
    required ValueChanged<Set<String>> onHiddenChanged,
    required VoidCallback onResetToDefault,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          child: SafeArea(
            top: false,
            child: DashboardCustomizeSheet(
              currentOrder: currentOrder,
              hiddenSections: hiddenSections,
              onOrderChanged: onOrderChanged,
              onHiddenChanged: onHiddenChanged,
              onResetToDefault: onResetToDefault,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<DashboardCustomizeSheet> createState() => _DashboardCustomizeSheetState();
}

class _DashboardCustomizeSheetState extends State<DashboardCustomizeSheet> {
  late List<String> _order;
  late Set<String> _hidden;

  @override
  void initState() {
    super.initState();
    _order = List<String>.from(widget.currentOrder);
    _hidden = Set<String>.from(widget.hiddenSections);
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    setState(() {
      final item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
    widget.onOrderChanged(_order);
  }

  void _toggleVisibility(String sectionId) {
    setState(() {
      if (_hidden.contains(sectionId)) {
        _hidden.remove(sectionId);
      } else {
        _hidden.add(sectionId);
      }
    });
    widget.onHiddenChanged(_hidden);
  }

  void _reset() {
    setState(() {
      _order = List<String>.from(PreferencesService.defaultDashboardSectionOrder);
      _hidden.clear();
    });
    widget.onResetToDefault();
  }

  _SectionMeta _getSectionMeta(String id, String lang, ThemeData theme) {
    switch (id) {
      case 'active_trip':
        return _SectionMeta(
          title: DashboardLocalization.sectionActiveTrip(lang),
          badge: DashboardLocalization.wideCard(lang),
          icon: Icons.flight_takeoff_rounded,
          iconColor: theme.colorScheme.primary,
        );
      case 'luggage_checklist':
        return _SectionMeta(
          title: DashboardLocalization.sectionLuggageChecklist(lang),
          badge: DashboardLocalization.wideCard(lang),
          icon: Icons.luggage_rounded,
          iconColor: AppColors.secondaryLight,
        );
      case 'currency_converter':
        return _SectionMeta(
          title: DashboardLocalization.sectionCurrencyConverter(lang),
          badge: DashboardLocalization.wideCard(lang),
          icon: Icons.currency_exchange_rounded,
          iconColor: const Color(0xFFD97706),
        );
      case 'mini_travel_map':
        return _SectionMeta(
          title: DashboardLocalization.sectionTravelMap(lang),
          badge: DashboardLocalization.miniBox(lang),
          icon: Icons.public_rounded,
          iconColor: const Color(0xFF10B981),
        );
      case 'mini_vault':
        return _SectionMeta(
          title: DashboardLocalization.sectionVault(lang),
          badge: DashboardLocalization.miniBox(lang),
          icon: Icons.shield_rounded,
          iconColor: const Color(0xFF8B5CF6),
        );
      case 'mini_all_trips':
        return _SectionMeta(
          title: DashboardLocalization.sectionAllTrips(lang),
          badge: DashboardLocalization.miniBox(lang),
          icon: Icons.account_balance_wallet_rounded,
          iconColor: theme.colorScheme.primary,
        );
      case 'mini_trip_comparison':
        return _SectionMeta(
          title: DashboardLocalization.sectionTripComparison(lang),
          badge: DashboardLocalization.miniBox(lang),
          icon: Icons.compare_arrows_rounded,
          iconColor: const Color(0xFF6366F1),
        );
      default:
        return _SectionMeta(
          title: id,
          badge: DashboardLocalization.miniBox(lang),
          icon: Icons.dashboard_customize_rounded,
          iconColor: theme.colorScheme.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grab Handle
        Center(
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Header with Reset Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DashboardLocalization.customizeHome(lang),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DashboardLocalization.customizeSubtitle(lang),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: Text(
                DashboardLocalization.resetDefault(lang),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Reorderable List
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 420),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: _order.length,
                onReorderItem: _onReorderItem,
                itemBuilder: (context, index) {
                  final sectionId = _order[index];
                  final isHidden = _hidden.contains(sectionId);
                  final meta = _getSectionMeta(sectionId, lang, theme);

                  return Container(
                    key: ValueKey('section-reorder-$sectionId'),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? (isHidden
                              ? theme.colorScheme.surface.withValues(alpha: 0.3)
                              : theme.colorScheme.surface)
                          : (isHidden
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(
                          alpha: isHidden ? 0.15 : 0.4,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Drag Handle
                        Icon(
                          Icons.drag_indicator_rounded,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        const SizedBox(width: 10),

                        // Section Icon
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: meta.iconColor.withValues(alpha: isHidden ? 0.08 : 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            meta.icon,
                            color: isHidden
                                ? meta.iconColor.withValues(alpha: 0.5)
                                : meta.iconColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title & Type Badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                meta.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isHidden
                                      ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                                      : theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? theme.colorScheme.surfaceContainerHighest
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  meta.badge,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Visibility Toggle Switch
                        Switch.adaptive(
                          value: !isHidden,
                          activeThumbColor: theme.colorScheme.primary,
                          activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                          onChanged: (_) => _toggleVisibility(sectionId),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Done / Close Button
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            MaterialLocalizations.of(context).okButtonLabel,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _SectionMeta {
  final String title;
  final String badge;
  final IconData icon;
  final Color iconColor;

  const _SectionMeta({
    required this.title,
    required this.badge,
    required this.icon,
    required this.iconColor,
  });
}

