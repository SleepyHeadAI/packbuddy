import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/travel_map/data/travel_map_service.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';

/// Detailed statistical progress model for an individual continent
class ContinentProgress {
  final String continent; // 'Europe', 'Asia', 'Americas', 'Africa', 'Oceania'
  final int totalCountries;
  final int visitedCountries;
  final double percentage;

  const ContinentProgress({
    required this.continent,
    required this.totalCountries,
    required this.visitedCountries,
    required this.percentage,
  });
}

class TravelMapState {
  final bool isLoading;
  final List<TravelCountry> countries;
  final String filter; // 'all', 'visited', 'wishlist', 'Europe', 'Asia', 'Americas', 'Africa', 'Oceania'
  final String searchQuery;

  const TravelMapState({
    this.isLoading = false,
    this.countries = const [],
    this.filter = 'all',
    this.searchQuery = '',
  });

  int get totalVisited => countries.where((c) => c.isVisited || c.isLived).length;
  int get totalWishlist => countries.where((c) => c.isWishlist).length;
  int get totalLived => countries.where((c) => c.isLived).length;
  int get visitedCount => totalVisited;
  int get wishlistCount => totalWishlist;
  int get livedCount => totalLived;
  int get totalCountries => countries.length;

  double get worldPercentage =>
      totalCountries > 0 ? ((totalVisited / totalCountries) * 100) : 0.0;

  List<ContinentProgress> get continentProgressList {
    const continents = ['Europe', 'Asia', 'Americas', 'Africa', 'Oceania'];
    return continents.map((cont) {
      final inContinent = countries.where((c) => c.isInContinent(cont)).toList();
      final explored = inContinent.where((c) => c.isVisited || c.isLived).length;
      final total = inContinent.length;
      final pct = total > 0 ? (explored / total) * 100 : 0.0;
      return ContinentProgress(
        continent: cont,
        totalCountries: total,
        visitedCountries: explored,
        percentage: pct,
      );
    }).toList();
  }

  Map<String, double> get continentStats {
    final map = <String, double>{};
    for (final cp in continentProgressList) {
      map[cp.continent] = cp.percentage;
    }
    return map;
  }

  List<TravelCountry> get filteredCountries {
    final list = countries.where((c) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final match = c.nameTr.toLowerCase().contains(q) ||
            c.nameEn.toLowerCase().contains(q) ||
            c.capital.toLowerCase().contains(q) ||
            c.code.toLowerCase().contains(q);
        if (!match) return false;
      }

      switch (filter) {
        case 'visited':
          return c.isVisited || c.isLived;
        case 'wishlist':
          return c.isWishlist;
        case 'lived':
          return c.isLived;
        case 'Europe':
        case 'Asia':
        case 'Americas':
        case 'Africa':
        case 'Oceania':
          return c.isInContinent(filter);
        case 'all':
        default:
          return true;
      }
    }).toList();

    list.sort((a, b) {
      int priority(TravelCountry c) {
        if (c.isLived) return 0;
        if (c.isVisited) return 1;
        if (c.isWishlist) return 2;
        return 3;
      }

      final pComp = priority(a).compareTo(priority(b));
      if (pComp != 0) return pComp;
      return a.nameTr.compareTo(b.nameTr);
    });

    return list;
  }

  TravelMapState copyWith({
    bool? isLoading,
    List<TravelCountry>? countries,
    String? filter,
    String? searchQuery,
  }) {
    return TravelMapState(
      isLoading: isLoading ?? this.isLoading,
      countries: countries ?? this.countries,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TravelMapController extends StateNotifier<TravelMapState> {
  final TravelMapService _service;
  final Ref? _ref;

  TravelMapController([TravelMapService? service, this._ref])
      : _service = service ?? TravelMapService.instance,
        super(const TravelMapState(isLoading: true)) {
    loadCountries();
  }

  String? get _currentUserId => _ref?.read(authUserProvider)?.uid;

  void resetState() {
    state = const TravelMapState(
      countries: WorldCountriesData.allCountries,
      isLoading: false,
    );
  }

  Future<void> loadCountries({String? userId}) async {
    state = state.copyWith(isLoading: true);
    final effectiveUid = userId ?? _currentUserId;
    final countries = await _service.getCountries(uid: effectiveUid);
    state = state.copyWith(isLoading: false, countries: countries);

    // Sync completed trips if available
    if (_ref != null) {
      final trips = _ref.read(tripControllerProvider).trips;
      if (trips.isNotEmpty) {
        syncWithTrips(trips, userId: effectiveUid);
      }
    }
  }

  Future<void> setCountryStatus({
    required String code,
    required CountryStatus status,
    DateTime? visitedDate,
    String? notes,
  }) async {
    final effectiveUid = _currentUserId;
    final codeUpper = code.toUpperCase().trim();

    // 1. Immediate optimistic UI update so state listeners rebuild in 0ms
    final currentList = state.countries;
    final optimisticList = currentList.map((c) {
      if (c.code.toUpperCase().trim() == codeUpper) {
        return c.copyWith(
          status: status,
          visitedDate: status == CountryStatus.none ? null : (visitedDate ?? c.visitedDate ?? DateTime.now()),
          notes: notes ?? c.notes,
        );
      }
      return c;
    }).toList();
    state = state.copyWith(countries: optimisticList);

    // 2. Persist to storage in background and confirm
    final updated = await _service.setStatus(
      code: codeUpper,
      status: status,
      visitedDate: visitedDate,
      notes: notes,
      uid: effectiveUid,
    );
    state = state.copyWith(countries: updated);
  }

  Future<void> syncWithTrips(List<Trip> trips, {String? userId}) async {
    final effectiveUid = userId ?? _currentUserId;
    final updated = await _service.syncFromTrips(trips, uid: effectiveUid);
    state = state.copyWith(countries: updated);
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final travelMapServiceProvider = Provider<TravelMapService>((ref) {
  return TravelMapService.instance;
});

final travelMapControllerProvider =
    StateNotifierProvider<TravelMapController, TravelMapState>((ref) {
  final service = ref.watch(travelMapServiceProvider);
  return TravelMapController(service, ref);
});
