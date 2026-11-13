import 'package:flutter/material.dart';
import 'package:packbuddy/features/search/domain/search_result.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Serene Voyage search result item tile with badge icon, title, subtitle, and category pill
class SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: AppCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            // Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: result.color.withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  result.icon,
                  size: 22,
                  color: result.color,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title.isNotEmpty ? result.title : '—',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    result.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Type Label Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: result.color.withValues(alpha: isDark ? 0.18 : 0.09),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getTypeBadge(result.type),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: result.color,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeBadge(SearchResultType type) {
    switch (type) {
      case SearchResultType.trip:
        return 'Trip';
      case SearchResultType.packingItem:
        return 'Item';
      case SearchResultType.document:
        return 'Doc';
      case SearchResultType.expense:
        return 'Expense';
    }
  }
}

