import 'package:flutter/material.dart';
import 'package:packbuddy/features/search/domain/search_localization.dart';
import 'package:packbuddy/features/search/presentation/controllers/search_controller.dart';

/// Horizontal filter chips selector with active count indicators
class SearchFilterBar extends StatelessWidget {
  final SearchFilter selectedFilter;
  final ValueChanged<SearchFilter> onFilterSelected;
  final String languageCode;
  final Map<SearchFilter, int>? counts;

  const SearchFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.languageCode,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filters = [
      SearchFilter.all,
      SearchFilter.trips,
      SearchFilter.packing,
      SearchFilter.documents,
      SearchFilter.expenses,
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;
          final label = _getFilterLabel(filter, languageCode);
          final count = counts?[filter];

          final displayText = count != null && count > 0 ? '$label ($count)' : label;

          return InkWell(
            onTap: () => onFilterSelected(filter),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark
                        ? theme.colorScheme.surfaceContainer
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFilterLabel(SearchFilter filter, String lang) {
    switch (filter) {
      case SearchFilter.all:
        return SearchLocalization.getFilterAll(lang);
      case SearchFilter.trips:
        return SearchLocalization.getFilterTrips(lang);
      case SearchFilter.packing:
        return SearchLocalization.getFilterPacking(lang);
      case SearchFilter.documents:
        return SearchLocalization.getFilterDocuments(lang);
      case SearchFilter.expenses:
        return SearchLocalization.getFilterExpenses(lang);
    }
  }
}
