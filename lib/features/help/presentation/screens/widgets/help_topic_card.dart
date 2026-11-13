import 'package:flutter/material.dart';
import 'package:packbuddy/features/help/data/faq_data.dart';
import 'package:packbuddy/features/help/domain/help_localization.dart';

/// Serene Voyage horizontal categories bar for filtering FAQ topics
class HelpTopicSelector extends StatelessWidget {
  final String selectedCategory;
  final String languageCode;
  final ValueChanged<String> onCategorySelected;

  const HelpTopicSelector({
    super.key,
    required this.selectedCategory,
    required this.languageCode,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allItems = ['all', ...FaqData.categories];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: allItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = allItems[index];
          final isSelected = selectedCategory == cat;
          final label = cat == 'all'
              ? HelpLocalization.getAllTopics(languageCode)
              : HelpLocalization.getCategoryName(cat, languageCode);
          final icon = cat == 'all'
              ? Icons.auto_awesome_motion_rounded
              : FaqData.getCategoryIcon(cat);

          final activeBg = isDark
              ? theme.colorScheme.primary.withValues(alpha: 0.28)
              : theme.colorScheme.primaryContainer;
          final activeFg = isDark
              ? theme.colorScheme.primary
              : theme.colorScheme.onPrimaryContainer;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onCategorySelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeBg
                      : (isDark ? theme.colorScheme.surfaceContainer : theme.colorScheme.surface),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.4))
                        : (isDark ? theme.colorScheme.outlineVariant.withValues(alpha: 0.2) : theme.colorScheme.outlineVariant),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? activeFg : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? activeFg : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
