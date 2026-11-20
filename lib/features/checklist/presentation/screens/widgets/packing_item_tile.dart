import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_spacing.dart';
import 'package:packbuddy/core/theme/app_typography.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
import 'package:packbuddy/features/checklist/domain/canonical_packing_catalog.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_animations.dart';

/// Highly refined, accessible packing list tile with non-conflicting dismissible swipe gestures,
/// multi-line wrapping with clean trailing ellipsis, isolated title strikethrough,
/// WCAG 2.1 AA compliant secondary tags, and 44x44 dp stepper tap targets.
class PackingItemTile extends StatelessWidget {
  final PackingItem item;
  final VoidCallback onTogglePacked;
  final ValueChanged<int> onUpdateQuantity;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const PackingItemTile({
    super.key,
    required this.item,
    required this.onTogglePacked,
    required this.onUpdateQuantity,
    required this.onDelete,
    this.onTap,
  });

  String _getCategoryLabel(String cat, AppLocalizations l10n) {
    switch (cat.toLowerCase()) {
      case 'kıyafet':
      case 'clothing':
        return l10n.categoryClothing;
      case 'elektronik':
      case 'electronics':
        return l10n.categoryElectronics;
      case 'kişisel bakım':
      case 'toiletries':
        return l10n.categoryToiletries;
      case 'belgeler':
      case 'documents':
        return l10n.categoryDocuments;
      case 'aksesuar':
      case 'accessories':
        return l10n.categoryAccessories;
      case 'diğer':
      case 'other':
      case 'others':
        return l10n.other == 'Other' ? 'Others' : l10n.other;
      default:
        return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Clean semantic surface colors for swipe backgrounds (no harsh neon gradients)
    final deleteBgColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
    final deleteTextColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);

    final packedBgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
    final packedTextColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669);

    final tileBgColor = isDark
        ? (item.isPacked ? AppColors.surfaceDark : AppColors.surfaceRaisedDark)
        : (item.isPacked ? const Color(0xFFF8FAFC) : Colors.white);

    final tileBorderColor = isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs + 1, // 3px vertical padding for clean list rhythm
        ),
        child: Dismissible(
          key: ValueKey('packing_item_${item.id}'),
          direction: DismissDirection.horizontal,
          // Ensures vertical scroll gestures pass cleanly to parent scroll view
          dragStartBehavior: DragStartBehavior.down,
          // Right swipe background: Delete with refined flat surface
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: deleteBgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(AppIcons.delete, color: deleteTextColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  l10n.delete,
                  style: TextStyle(
                    color: deleteTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          // Left swipe background: Complete/Packed toggle with refined flat surface
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: packedBgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  item.isPacked ? l10n.undo : l10n.packed,
                  style: TextStyle(
                    color: packedTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  item.isPacked ? Icons.undo_rounded : Icons.check_circle_rounded,
                  color: packedTextColor,
                  size: 22,
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Left swipe: Toggle complete/packed without removing from tree
              AppHaptics.light();
              onTogglePacked();
              return false;
            } else if (direction == DismissDirection.startToEnd) {
              // Right swipe: Delete and trigger undo snackbar
              AppHaptics.medium();
              onDelete();
              return true;
            }
            return false;
          },
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.smoothCurve,
            decoration: BoxDecoration(
              color: tileBgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: tileBorderColor,
                width: 0.8,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: onTap ?? onTogglePacked,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  child: Row(
                    children: [
                      // Packed status tactile checkbox with 44x44 minimum touch target
                      Semantics(
                        label: item.isPacked ? l10n.markedAsPacked : l10n.notPacked,
                        child: IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, animation) => ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ),
                              child: child,
                            ),
                            child: item.isPacked
                                ? Container(
                                    key: const ValueKey('packed'),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  )
                                : Container(
                                    key: const ValueKey('unpacked'),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? AppColors.borderSubtleDark
                                            : AppColors.borderSubtleLight,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                          ),
                          onPressed: () {
                            if (!item.isPacked) {
                              AppHaptics.light();
                            } else {
                              AppHaptics.selection();
                            }
                            onTogglePacked();
                          },
                          visualDensity: VisualDensity.compact,
                          splashRadius: 20,
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Product title, tags, and metadata (with strict strikethrough isolation)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Product Title: dynamically localized for catalog/seeded items, or raw custom string
                            AnimatedStrikethroughText(
                              text: CanonicalPackingCatalog.getLocalizedItemName(
                                item.name,
                                Localizations.localeOf(context).languageCode,
                              ),
                              isCrossed: item.isPacked,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: item.isPacked
                                    ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                              strikethroughColor: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              strokeWidth: 1.8,
                            ),
                            const SizedBox(height: 3),

                            // Category Subtitle
                            Text(
                              _getCategoryLabel(item.category, l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                decoration: TextDecoration.none,
                              ),
                            ),

                            // Mini Luggage Tag Badge & Assignee Chip
                            if (item.tag.isNotEmpty || (item.assignedTo != null && item.assignedTo!.isNotEmpty)) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  if (item.tag.isNotEmpty)
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: PackingTagHelper.getTagBgColor(item.tag, isDark),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: PackingTagHelper.getTagBorderColor(item.tag, isDark),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              PackingTagHelper.getTagIcon(item.tag),
                                              size: 10,
                                              color: PackingTagHelper.getTagColor(item.tag, isDark),
                                            ),
                                            const SizedBox(width: 3),
                                            Flexible(
                                              child: Text(
                                                PackingTagHelper.getShortTag(
                                                  item.tag,
                                                  Localizations.localeOf(context).languageCode,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: PackingTagHelper.getTagColor(item.tag, isDark),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (item.assignedTo != null && item.assignedTo!.isNotEmpty) ...[
                                    if (item.tag.isNotEmpty) const SizedBox(width: 4),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.person_rounded, size: 10, color: theme.colorScheme.primary),
                                            const SizedBox(width: 3),
                                            Flexible(
                                              child: Text(
                                                item.assignedTo!.startsWith('@')
                                                    ? item.assignedTo!
                                                    : '@${item.assignedTo!}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Counter & Stepper Component with guaranteed minimum 44x44 dp touch targets
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
                          borderRadius: BorderRadius.circular(AppRadius.sm + 4),
                          border: Border.all(
                            color: tileBorderColor,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Decrement button with >= 44x44 dp target
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(AppRadius.sm + 4)),
                                onTap: item.quantity > 1
                                    ? () {
                                        AppHaptics.selection();
                                        onUpdateQuantity(-1);
                                      }
                                    : null,
                                child: Center(
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: 16,
                                    color: item.quantity > 1
                                        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                                        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                                  ),
                                ),
                              ),
                            ),

                            // Quantity Label in JetBrains Mono tabular figures
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                '${item.quantity}',
                                style: AppTypography.mono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  tabularFigures: true,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),

                            // Increment button with >= 44x44 dp target
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(AppRadius.sm + 4)),
                                onTap: () {
                                  AppHaptics.selection();
                                  onUpdateQuantity(1);
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary,
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
          ),
        ),
      ),
    );
  }
}
