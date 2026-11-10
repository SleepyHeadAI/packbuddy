import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/domain/packing_tag.dart';
import 'package:packbuddy/features/checklist/domain/canonical_packing_catalog.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

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

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Dismissible(
        key: ValueKey('packing_item_${item.id}'),
        direction: DismissDirection.horizontal,
        // Ensures vertical scroll gestures pass cleanly to parent scroll view
        dragStartBehavior: DragStartBehavior.down,
        // Right swipe background (Delete with subtle Undo snackbar)
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.delete,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Left swipe background (Complete / Packed toggle)
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                item.isPacked ? l10n.undo : l10n.packed,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                item.isPacked ? Icons.undo_rounded : Icons.check_circle_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          if (direction == DismissDirection.endToStart) {
            // Left swipe: Toggle complete/packed without removing from tree
            onTogglePacked();
            return false;
          } else if (direction == DismissDirection.startToEnd) {
            // Right swipe: Delete and trigger undo snackbar
            onDelete();
            return true;
          }
          return false;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isDark
                ? (item.isPacked
                    ? theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.6)
                    : theme.colorScheme.surface)
                : (item.isPacked
                    ? AppColors.surfaceVariantLight.withValues(alpha: 0.5)
                    : AppColors.surfaceLight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.isPacked
                  ? (isDark
                      ? AppColors.outlineDark.withValues(alpha: 0.5)
                      : AppColors.outlineLight.withValues(alpha: 0.6))
                  : (isDark
                      ? AppColors.outlineDark
                      : AppColors.outlineLight),
              width: 1,
            ),
            boxShadow: item.isPacked
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.25 : 0.035),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap ?? onTogglePacked,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Packed status checkbox with touch target
                    Semantics(
                      label: item.isPacked ? l10n.markedAsPacked : l10n.notPacked,
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, animation) => ScaleTransition(
                            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                            child: child,
                          ),
                          child: item.isPacked
                              ? Container(
                                  key: const ValueKey('packed'),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.successPastel,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.successPastel.withValues(alpha: 0.35),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
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
                                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withValues(alpha: 0.7),
                                      width: 1.8,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
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
                          // Strikethrough decoration is strictly applied ONLY to this Text widget!
                          Text(
                            CanonicalPackingCatalog.getLocalizedItemName(
                              item.name,
                              Localizations.localeOf(context).languageCode,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                              letterSpacing: -0.2,
                              color: item.isPacked
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                                  : theme.colorScheme.onSurface,
                              decoration: item.isPacked
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              decorationThickness: 1.8,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Category Subtitle
                          Text(
                            _getCategoryLabel(item.category, l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: item.isPacked ? 0.5 : 0.8,
                              ),
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
                                      child: Text(
                                        '@${item.assignedTo}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
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
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.25),
                          width: 1,
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
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                              onTap: item.quantity > 1
                                  ? () {
                                      HapticFeedback.selectionClick();
                                      onUpdateQuantity(-1);
                                    }
                                  : null,
                              child: Center(
                                child: Icon(
                                  Icons.remove_rounded,
                                  size: 16,
                                  color: item.quantity > 1
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.25),
                                ),
                              ),
                            ),
                          ),

                          // Quantity Label
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
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
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
                              onTap: () {
                                HapticFeedback.selectionClick();
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
