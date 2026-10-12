import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/local_db/database_helper.dart';
import '../../../../data/sync_engine/sync_engine.dart';
import '../../domain/trip.dart';

/// State representation for trips list
class TripState {
  final bool isLoading;
  final List<Trip> trips;
  final String? errorMessage;

  const TripState({
    this.isLoading = false,
    this.trips = const [],
    this.errorMessage,
  });

  TripState copyWith({
    bool? isLoading,
    List<Trip>? trips,
    String? errorMessage,
  }) {
    return TripState(
      isLoading: isLoading ?? this.isLoading,
      trips: trips ?? this.trips,
      errorMessage: errorMessage,
    );
  }
}

/// Controller managing trips persistence and background cloud sync
class TripController extends StateNotifier<TripState> {
  final Ref _ref;
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  TripController(this._ref, {DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        super(const TripState()) {
    loadTrips();
  }

  /// Loads non-deleted trips from SQLite
  Future<void> loadTrips() async {
    state = state.copyWith(isLoading: true);
    try {
      final trips = await _dbHelper.getTrips(includeDeleted: false);
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        trips: trips,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Adds a new trip, persists to SQLite and triggers background sync
  Future<Trip?> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required String defaultCurrency,
    double? budgetLimit,
    String? countryCode,
    String? transportMode,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final newTrip = Trip(
        id: _uuid.v4(),
        title: title,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        defaultCurrency: defaultCurrency,
        budgetLimit: budgetLimit,
        countryCode: countryCode,
        transportMode: transportMode,
        notes: notes,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      await _dbHelper.insertTrip(newTrip);

      // Update state locally first (Offline-First immediate feedback)
      state = state.copyWith(
        trips: [newTrip, ...state.trips],
      );

      // Trigger background two-way sync
      _ref.read(syncEngineProvider.notifier).performSync();

      return newTrip;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// Updates an existing trip, persists to SQLite and triggers background sync
  Future<Trip?> updateTrip(Trip updated) async {
    try {
      final tripToSave = updated.copyWith(updatedAt: DateTime.now());
      await _dbHelper.updateTrip(tripToSave);

      final index = state.trips.indexWhere((t) => t.id == updated.id);
      final updatedList = List<Trip>.from(state.trips);
      if (index != -1) {
        updatedList[index] = tripToSave;
      } else {
        updatedList.insert(0, tripToSave);
      }

      state = state.copyWith(trips: updatedList);

      // Trigger background two-way sync
      _ref.read(syncEngineProvider.notifier).performSync();

      return tripToSave;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// Soft deletes a trip, updates state and triggers background sync
  Future<bool> deleteTrip(String tripId) async {
    try {
      await _dbHelper.deleteTrip(tripId);

      // Remove from active list in memory
      state = state.copyWith(
        trips: state.trips.where((t) => t.id != tripId).toList(),
      );

      // Trigger background two-way sync (soft-deleted trip will cascade to cloud)
      _ref.read(syncEngineProvider.notifier).performSync();

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

/// Global provider for TripController
final tripControllerProvider =
    StateNotifierProvider<TripController, TripState>((ref) {
  return TripController(ref);
});
