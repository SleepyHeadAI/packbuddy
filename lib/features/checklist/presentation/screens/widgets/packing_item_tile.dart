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

/// High-density, tactile travel checklist tile with Apple Reminders / Things 3 aesthetics.
/// Features a compact footprint (~52px), circular pine-emerald checkbox,
/// inline category/tag badge, and a refined micro-stepper.
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

    // Clean semantic surface colors for swipe backgrounds
    final deleteBgColor = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
    final deleteTextColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);

    final packedBgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
    final packedTextColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669);

    final tileBgColor = isDark
        ? (item.isPacked ? const Color(0xFF101726) : AppColors.surfaceRaisedDark)
        : (item.isPacked ? const Color(0xFFF8FAFC) : Colors.white);

    final tileBorderColor = isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 2.0, // High-density list vertical spacing
        ),
        child: Dismissible(
          key: ValueKey('packing_item_${item.id}'),
          direction: DismissDirection.horizontal,
          dragStartBehavior: DragStartBehavior.down,
          // Right swipe: Delete
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: deleteBgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(AppIcons.delete, color: deleteTextColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  l10n.delete,
                  style: TextStyle(
                    color: deleteTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          // Left swipe: Complete / Packed toggle
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  item.isPacked ? AppIcons.undo : AppIcons.checkCircle,
                  color: packedTextColor,
                  size: 18,
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              AppHaptics.light();
              onTogglePacked();
              return false;
            } else if (direction == DismissDirection.startToEnd) {
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
                color: item.isPacked
                    ? tileBorderColor.withValues(alpha: 0.5)
                    : tileBorderColor,
                width: 0.6,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: onTap ?? onTogglePacked,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // Tactile Checkbox Target
                      Semantics(
                        label: item.isPacked ? l10n.markedAsPacked : l10n.notPacked,
                        child: InkResponse(
                          onTap: () {
                            if (!item.isPacked) {
                              AppHaptics.light();
                            } else {
                              AppHaptics.selection();
                            }
                            onTogglePacked();
                          },
                          radius: 18,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
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
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF10B981)
                                            : AppColors.pineEmerald,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        AppIcons.check,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    )
                                  : Container(
                                      key: const ValueKey('unpacked'),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF475569)
                                              : const Color(0xFFCBD5E1),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // Item Title, Category & Micro Tag Badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Product Title with localized name & clean strikethrough
                            AnimatedStrikethroughText(
                              text: CanonicalPackingCatalog.getLocalizedItemName(
                                item.name,
                                Localizations.localeOf(context).languageCode,
                              ),
                              isCrossed: item.isPacked,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                fontSize: 14.0,
                                fontWeight: item.isPacked ? FontWeight.w500 : FontWeight.w600,
                                letterSpacing: -0.2,
                                color: item.isPacked
                                    ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                              strikethroughColor: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              strokeWidth: 1.6,
                            ),
                            const SizedBox(height: 2),

                            // Subtitle Metadata Line: Category • Tag • Assignee
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _getCategoryLabel(item.category, l10n),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ),
                                if (item.tag.isNotEmpty) ...[
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: PackingTagHelper.getTagBgColor(item.tag, isDark),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: PackingTagHelper.getTagBorderColor(item.tag, isDark),
                                          width: 0.6,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            PackingTagHelper.getTagIcon(item.tag),
                                            size: 9.5,
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
                                                fontSize: 9.0,
                                                fontWeight: FontWeight.w700,
                                                color: PackingTagHelper.getTagColor(item.tag, isDark),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                if (item.assignedTo != null && item.assignedTo!.isNotEmpty) ...[
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(AppIcons.users, size: 9.5, color: theme.colorScheme.primary),
                                          const SizedBox(width: 2),
                                          Flexible(
                                            child: Text(
                                              item.assignedTo!.startsWith('@')
                                                  ? item.assignedTo!
                                                  : '@${item.assignedTo!}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 9.0,
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
                        ),
                      ),
                      const SizedBox(width: 8),

                      // High-density Micro Stepper Component
                      AnimatedOpacity(
                        duration: AppMotion.fast,
                        opacity: item.isPacked ? 0.45 : 1.0,
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: tileBorderColor,
                              width: 0.6,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Decrement Button
                              InkResponse(
                                radius: 14,
                                onTap: item.quantity > 1
                                    ? () {
                                        AppHaptics.selection();
                                        onUpdateQuantity(-1);
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                  child: Icon(
                                    AppIcons.remove,
                                    size: 11,
                                    color: item.quantity > 1
                                        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                                        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                                  ),
                                ),
                              ),

                              // Tabular Monospace Quantity
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1),
                                child: Text(
                                  '${item.quantity}',
                                  style: AppTypography.mono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    tabularFigures: true,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),

                              // Increment Button
                              InkResponse(
                                radius: 14,
                                onTap: () {
                                  AppHaptics.selection();
                                  onUpdateQuantity(1);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                  child: Icon(
                                    AppIcons.add,
                                    size: 11,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
