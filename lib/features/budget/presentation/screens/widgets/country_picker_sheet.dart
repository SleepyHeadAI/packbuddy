import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/country_flag.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Searchable modal bottom sheet to select travel destinations & countries
class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({super.key});

  static Future<Country?> show(BuildContext context) {
    return showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => const RepaintBoundary(child: CountryPickerSheet()),
    );
  }

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    // 1. Sort all countries strictly alphabetically based on the user's active locale
    final sortedAllCountries = List<Country>.from(Country.allCountries)
      ..sort((a, b) => a.getLocalizedName(locale).toLowerCase().compareTo(b.getLocalizedName(locale).toLowerCase()));

    // 2. Filter countries based on search query
    final filtered = _searchQuery.isEmpty
        ? sortedAllCountries
        : sortedAllCountries.where((c) {
            final loc = c.getLocalizedName(locale).toLowerCase();
            final en = c.name.toLowerCase();
            final tr = c.localName.toLowerCase();
            final code = c.code.toLowerCase();
            final matchCity = c.popularDestinations.any((d) => d.toLowerCase().contains(_searchQuery));
            return loc.contains(_searchQuery) || en.contains(_searchQuery) || tr.contains(_searchQuery) || code.contains(_searchQuery) || matchCity;
          }).toList();

    // 3. Quick popular countries localized
    const popularCodes = ['TR', 'DE', 'US', 'FR', 'IT', 'ES', 'GB', 'JP'];
    final popularQuickCountries = popularCodes
        .map((code) => Country.findByCode(code))
        .whereType<Country>()
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              children: [
                const Icon(Icons.travel_explore_rounded, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.selectCountryAndRoute,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${filtered.length} ${l10n.countriesLabel}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            controller: _searchController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: l10n.searchCountryOrCity,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // Quick Selection Chips for top destinations (Localized)
          if (_searchController.text.isEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: popularQuickCountries.map((country) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: CountryFlag(code: country.code, fallbackEmoji: country.flag, size: 16),
                      label: Text(country.getLocalizedName(locale), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onPressed: () => Navigator.of(context).pop(country),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          const Divider(height: 1),

          // Country List (Strictly Alphabetical in Active Locale)
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.travel_explore_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noMatchingCountry,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
                    itemBuilder: (context, index) {
                      final country = filtered[index];
                      final localizedName = country.getLocalizedName(locale);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        leading: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CountryFlag(
                            code: country.code,
                            fallbackEmoji: country.flag,
                            size: 24,
                          ),
                        ),
                        title: Text.rich(
                          TextSpan(
                            text: localizedName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            children: [
                              if (localizedName.toLowerCase() != country.name.toLowerCase())
                                TextSpan(
                                  text: ' (${country.name})',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: country.popularDestinations.isNotEmpty
                            ? Text(
                                country.popularDestinations.take(3).join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              )
                            : null,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            country.defaultCurrency,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(country),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}
}
