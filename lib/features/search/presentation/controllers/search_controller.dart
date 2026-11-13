import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/search/domain/search_result.dart';

enum SearchFilter {
  all,
  trips,
  packing,
  documents,
  expenses,
}

class SearchState {
  final String query;
  final SearchFilter filter;
  final List<SearchResult> allResults;
  final List<SearchResult> filteredResults;
  final List<String> recentSearches;
  final bool isLoading;
  final String? errorMessage;

  const SearchState({
    this.query = '',
    this.filter = SearchFilter.all,
    this.allResults = const [],
    this.filteredResults = const [],
    this.recentSearches = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SearchState copyWith({
    String? query,
    SearchFilter? filter,
    List<SearchResult>? allResults,
    List<SearchResult>? filteredResults,
    List<String>? recentSearches,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      allResults: allResults ?? this.allResults,
      filteredResults: filteredResults ?? this.filteredResults,
      recentSearches: recentSearches ?? this.recentSearches,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class GlobalSearchController extends StateNotifier<SearchState> {
  final Ref _ref;
  final DatabaseHelper _dbHelper;
  final PreferencesService _prefs;
  Timer? _debounceTimer;

  GlobalSearchController(
    this._ref, {
    DatabaseHelper? dbHelper,
    PreferencesService? prefs,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _prefs = prefs ?? PreferencesService.instance,
        super(const SearchState()) {
    loadRecentSearches();
  }

  void loadRecentSearches() {
    final recent = _prefs.getRecentSearches();
    state = state.copyWith(recentSearches: recent);
  }

  void setFilter(SearchFilter filter) {
    if (state.filter == filter) return;
    final filtered = _applyFilter(state.allResults, filter);
    state = state.copyWith(filter: filter, filteredResults: filtered);
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(
        allResults: const [],
        filteredResults: const [],
        isLoading: false,
      );
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      executeSearch(query);
    });
  }

  Future<void> executeSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = _ref.read(authUserProvider);
      final rawResults = await _dbHelper.globalSearch(
        query: trimmed,
        userId: user?.uid,
        limit: 100,
      );

      final results = rawResults.map((m) => SearchResult.fromMap(m)).toList();
      final filtered = _applyFilter(results, state.filter);

      state = state.copyWith(
        allResults: results,
        filteredResults: filtered,
        isLoading: false,
      );

      // Persist in recent searches if query is meaningful (>= 2 chars)
      if (trimmed.length >= 2) {
        await _prefs.addRecentSearch(trimmed);
        loadRecentSearches();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  List<SearchResult> _applyFilter(List<SearchResult> list, SearchFilter filter) {
    switch (filter) {
      case SearchFilter.trips:
        return list.where((r) => r.type == SearchResultType.trip).toList();
      case SearchFilter.packing:
        return list.where((r) => r.type == SearchResultType.packingItem).toList();
      case SearchFilter.documents:
        return list.where((r) => r.type == SearchResultType.document).toList();
      case SearchFilter.expenses:
        return list.where((r) => r.type == SearchResultType.expense).toList();
      case SearchFilter.all:
        return list;
    }
  }

  Future<void> removeRecentSearch(String query) async {
    await _prefs.removeRecentSearch(query);
    loadRecentSearches();
  }

  Future<void> clearRecentSearches() async {
    await _prefs.clearRecentSearches();
    state = state.copyWith(recentSearches: const []);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final globalSearchControllerProvider =
    StateNotifierProvider<GlobalSearchController, SearchState>((ref) {
  return GlobalSearchController(ref);
});
