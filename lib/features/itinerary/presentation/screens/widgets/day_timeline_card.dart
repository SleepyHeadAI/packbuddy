import 'package:flutter/material.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_item.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_localization.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Serene Voyage vertical timeline card for an itinerary activity
class DayTimelineCard extends StatelessWidget {
  final ItineraryItem item;
  final String languageCode;
  final VoidCallback onToggleCompleted;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const DayTimelineCard({
    super.key,
    required this.item,
    required this.languageCode,
    required this.onToggleCompleted,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryColor = item.color;
    final displayTime = item.formattedTimeRange ?? item.time;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Timeline indicator (Icon node)
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.isCompleted
                      ? const Color(0xFF10B981)
                      : categoryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isCompleted ? const Color(0xFF10B981) : categoryColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    item.isCompleted ? Icons.check_rounded : item.icon,
                    size: 18,
                    color: item.isCompleted ? Colors.white : categoryColor,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 48,
                color: theme.colorScheme.outline.withValues(alpha: 0.18),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // 2. Activity Content Card
          Expanded(
            child: AppCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(12),
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Badges (Time, Category) & Actions (Complete, Edit, Delete)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Badges on left: Time and Category
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (displayTime != null && displayTime.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 12,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      displayTime,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Category Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ItineraryLocalization.getCategoryLabel(item.category, languageCode),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Action buttons on right (aligned to trailing edge)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Checkbox Button
                          InkWell(
                            onTap: onToggleCompleted,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                item.isCompleted
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded,
                                size: 20,
                                color: item.isCompleted
                                    ? const Color(0xFF10B981)
                                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          if (onEdit != null) ...[
                            const SizedBox(width: 2),
                            // Edit Button
                            InkWell(
                              onTap: onEdit,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 2),
                          // Delete Button
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: theme.colorScheme.error.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                      color: item.isCompleted
                          ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                          : theme.colorScheme.onSurface,
                    ),
                  ),

                  // Location
                  if (item.location != null && item.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location!,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Description / Notes
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Cost tag if present
                  if (item.cost != null && item.cost! > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '${item.cost!.toStringAsFixed(2)} ${item.currency ?? "USD"}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

