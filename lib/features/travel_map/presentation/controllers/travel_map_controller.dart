import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/app_widget_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
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
  final bool is3DMode;

  const TravelMapState({
    this.isLoading = false,
    this.countries = const [],
    this.filter = 'all',
    this.searchQuery = '',
    this.is3DMode = false,
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

  List<TravelCountry> get filteredCountries => getFilteredCountries('tr');

  List<TravelCountry> getFilteredCountries([String langCode = 'tr']) {
    final list = countries.where((c) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final localizedName = c.getLocalizedName(langCode).toLowerCase();
        final match = c.nameTr.toLowerCase().contains(q) ||
            c.nameEn.toLowerCase().contains(q) ||
            localizedName.contains(q) ||
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

      final nameA = a.getLocalizedName(langCode);
      final nameB = b.getLocalizedName(langCode);
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    return list;
  }

  TravelMapState copyWith({
    bool? isLoading,
    List<TravelCountry>? countries,
    String? filter,
    String? searchQuery,
    bool? is3DMode,
  }) {
    return TravelMapState(
      isLoading: isLoading ?? this.isLoading,
      countries: countries ?? this.countries,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      is3DMode: is3DMode ?? this.is3DMode,
    );
  }
}

class TravelMapController extends StateNotifier<TravelMapState> {
  final TravelMapService _service;
  final Ref? _ref;

  TravelMapController([TravelMapService? service, this._ref])
      : _service = service ?? TravelMapService.instance,
        super(TravelMapState(
          isLoading: true,
          is3DMode: PreferencesService.instance.getTravelMapIs3D(),
        )) {
    loadCountries();
  }

  String? get _currentUserId => _ref?.read(authUserProvider)?.uid;

  void resetState() {
    state = TravelMapState(
      countries: WorldCountriesData.allCountries,
      isLoading: false,
      is3DMode: PreferencesService.instance.getTravelMapIs3D(),
    );
  }

  void set3DMode(bool is3D) {
    PreferencesService.instance.setTravelMapIs3D(is3D);
    state = state.copyWith(is3DMode: is3D);
  }

  Future<void> loadCountries({String? userId, bool showLoading = false}) async {
    // Only display full loading screen if countries haven't been loaded yet or explicitly requested
    if (showLoading || state.countries.isEmpty) {
      state = state.copyWith(isLoading: true);
    }
    final effectiveUid = userId ?? _currentUserId;
    var countries = await _service.getCountries(uid: effectiveUid);

    // If logged in and all countries are unvisited/empty locally (e.g. fresh install), sync from Firestore
    if (effectiveUid != null && countries.every((c) => c.status == CountryStatus.none)) {
      try {
        countries = await _service.syncWithCloud(uid: effectiveUid);
      } catch (_) {}
    }

    state = state.copyWith(isLoading: false, countries: countries);

    // Sync completed trips if available
    if (_ref != null) {
      final trips = _ref.read(tripControllerProvider).trips;
      if (trips.isNotEmpty) {
        await syncWithTrips(trips, userId: effectiveUid);
      }
    }
    AppWidgetService.syncCurrentState(countries: state.countries);
  }

  /// Forces an authoritative Cloud Firestore synchronization and refetches live country data
  Future<void> refreshFromCloud({String? userId}) async {
    state = state.copyWith(isLoading: true);
    final effectiveUid = userId ?? _currentUserId;
    if (effectiveUid != null) {
      await _service.syncWithCloud(uid: effectiveUid);
    }
    final countries = await _service.getCountries(uid: effectiveUid, forceRemote: true);
    state = state.copyWith(isLoading: false, countries: countries);

    if (_ref != null) {
      final trips = _ref.read(tripControllerProvider).trips;
      if (trips.isNotEmpty) {
        await syncWithTrips(trips, userId: effectiveUid);
      }
    }
    AppWidgetService.syncCurrentState(countries: state.countries);
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
    AppWidgetService.syncCurrentState(countries: optimisticList);

    // 2. Persist to storage in background and confirm
    final updated = await _service.setStatus(
      code: codeUpper,
      status: status,
      visitedDate: visitedDate,
      notes: notes,
      uid: effectiveUid,
    );
    state = state.copyWith(countries: updated);
    AppWidgetService.syncCurrentState(countries: updated);
  }

  Future<void> syncWithTrips(List<Trip> trips, {String? userId}) async {
    final effectiveUid = userId ?? _currentUserId;
    final updated = await _service.syncFromTrips(trips, uid: effectiveUid);
    if (updated != null) {
      state = state.copyWith(countries: updated);
      AppWidgetService.syncCurrentState(countries: updated);
    }
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
  final controller = TravelMapController(service, ref);

  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    ref.listen<User?>(authUserProvider, (prev, next) {
      if (next != null) {
        controller.loadCountries(userId: next.uid);
      } else {
        controller.resetState();
      }
    });
  }

  return controller;
});
