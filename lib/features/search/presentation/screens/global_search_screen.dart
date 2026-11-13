import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/search/domain/search_localization.dart';
import 'package:packbuddy/features/search/domain/search_result.dart';
import 'package:packbuddy/features/search/presentation/controllers/search_controller.dart';
import 'package:packbuddy/features/search/presentation/screens/widgets/search_filter_bar.dart';
import 'package:packbuddy/features/search/presentation/screens/widgets/search_result_tile.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/document_viewer_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Serene Voyage Global Search Screen providing instant local SQLite search across
/// Trips, Luggage Items, Encrypted Documents, and Travel Expenses.
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  late final TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onResultTap(SearchResult result) {
    switch (result.type) {
      case SearchResultType.trip:
        final trips = ref.read(tripControllerProvider).trips;
        final trip = trips.where((t) => t.id == result.id).firstOrNull;
        if (trip != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TripDetailScreen(trip: trip),
            ),
          );
        } else {
          _showTripNotFoundMessage();
        }
        break;

      case SearchResultType.packingItem:
        if (result.tripId != null && result.tripId!.isNotEmpty) {
          final trips = ref.read(tripControllerProvider).trips;
          final trip = trips.where((t) => t.id == result.tripId).firstOrNull;
          if (trip != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TripDetailScreen(trip: trip),
              ),
            );
            return;
          }
        }
        // General item fallback: switch to Checklist tab
        ref.read(mainNavigationIndexProvider.notifier).state = 2;
        Navigator.of(context).pop();
        break;

      case SearchResultType.document:
        final docs = ref.read(vaultControllerProvider).documents;
        final doc = docs.where((d) => d.id == result.id).firstOrNull;
        if (doc != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DocumentViewerScreen(document: doc),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VaultScreen(initialTripId: result.tripId),
            ),
          );
        }
        break;

      case SearchResultType.expense:
        if (result.tripId != null && result.tripId!.isNotEmpty) {
          final trips = ref.read(tripControllerProvider).trips;
          final trip = trips.where((t) => t.id == result.tripId).firstOrNull;
          if (trip != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TripDetailScreen(trip: trip),
              ),
            );
            return;
          }
        }
        _showTripNotFoundMessage();
        break;
    }
  }

  void _showTripNotFoundMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip details could not be found'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Map<SearchFilter, int> _computeCounts(List<SearchResult> all) {
    int trips = 0;
    int packing = 0;
    int docs = 0;
    int expenses = 0;

    for (final r in all) {
      switch (r.type) {
        case SearchResultType.trip:
          trips++;
          break;
        case SearchResultType.packingItem:
          packing++;
          break;
        case SearchResultType.document:
          docs++;
          break;
        case SearchResultType.expense:
          expenses++;
          break;
      }
    }

    return {
      SearchFilter.all: all.length,
      SearchFilter.trips: trips,
      SearchFilter.packing: packing,
      SearchFilter.documents: docs,
      SearchFilter.expenses: expenses,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;
    final searchState = ref.watch(globalSearchControllerProvider);
    final searchNotifier = ref.read(globalSearchControllerProvider.notifier);

    final counts = _computeCounts(searchState.allResults);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainer
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            autofocus: true,
            style: const TextStyle(fontSize: 14.5),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: SearchLocalization.getSearchHint(langCode),
              hintStyle: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        searchNotifier.onQueryChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            ),
            onChanged: (text) => searchNotifier.onQueryChanged(text),
            onSubmitted: (text) => searchNotifier.executeSearch(text),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Horizontal Filter Bar
          SearchFilterBar(
            selectedFilter: searchState.filter,
            onFilterSelected: (f) => searchNotifier.setFilter(f),
            languageCode: langCode,
            counts: searchState.allResults.isNotEmpty ? counts : null,
          ),
          const SizedBox(height: 10),

          // Main Search Results / Recent Searches Area
          Expanded(
            child: _buildBody(
              context: context,
              state: searchState,
              notifier: searchNotifier,
              theme: theme,
              isDark: isDark,
              langCode: langCode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required SearchState state,
    required GlobalSearchController notifier,
    required ThemeData theme,
    required bool isDark,
    required String langCode,
  }) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 1. Query is empty: Show Recent Searches & Helpful prompt
    if (state.query.trim().isEmpty) {
      return _buildRecentSearchesSection(
        context: context,
        state: state,
        notifier: notifier,
        theme: theme,
        langCode: langCode,
      );
    }

    // 2. No Results found
    if (state.filteredResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                SearchLocalization.getNoResults(langCode),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                SearchLocalization.getNoResultsHint(langCode),
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 3. Results List
    return ListView.builder(
      itemCount: state.filteredResults.length,
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemBuilder: (context, index) {
        final result = state.filteredResults[index];
        return SearchResultTile(
          result: result,
          onTap: () => _onResultTap(result),
        );
      },
    );
  }

  Widget _buildRecentSearchesSection({
    required BuildContext context,
    required SearchState state,
    required GlobalSearchController notifier,
    required ThemeData theme,
    required String langCode,
  }) {
    final recent = state.recentSearches;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recent.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  SearchLocalization.getRecentSearches(langCode),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                TextButton(
                  onPressed: () => notifier.clearRecentSearches(),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: Text(
                    SearchLocalization.getClear(langCode),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recent.map((item) {
                return Chip(
                  label: Text(item, style: const TextStyle(fontSize: 12.5)),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  onDeleted: () => notifier.removeRecentSearch(item),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // Guidance card
          AppCard(
            borderRadius: 18,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.travel_explore_rounded,
                    size: 26,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    SearchLocalization.getStartTyping(langCode),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

