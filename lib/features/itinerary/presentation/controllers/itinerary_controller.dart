import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_item.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';

class ItineraryState {
  final String tripId;
  final int selectedDay;
  final int totalDays;
  final List<ItineraryItem> items;
  final bool isLoading;
  final String? errorMessage;

  const ItineraryState({
    required this.tripId,
    this.selectedDay = 1,
    this.totalDays = 1,
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ItineraryState copyWith({
    String? tripId,
    int? selectedDay,
    int? totalDays,
    List<ItineraryItem>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ItineraryState(
      tripId: tripId ?? this.tripId,
      selectedDay: selectedDay ?? this.selectedDay,
      totalDays: totalDays ?? this.totalDays,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<ItineraryItem> get itemsForSelectedDay {
    return items.where((i) => i.dayNumber == selectedDay).toList();
  }

  int get completedCount => items.where((i) => i.isCompleted).length;
  int get totalCount => items.length;
  double get progressRatio => totalCount > 0 ? (completedCount / totalCount) : 0.0;
}

class ItineraryController extends StateNotifier<ItineraryState> {
  final Ref _ref;
  final DatabaseHelper _dbHelper;

  ItineraryController(
    this._ref,
    String tripId, {
    DatabaseHelper? dbHelper,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        super(ItineraryState(tripId: tripId)) {
    loadItinerary();
  }

  int _calculateTotalDays(Trip? trip) {
    if (trip == null) {
      return 3; // sensible default
    }
    final diff = trip.endDate.difference(trip.startDate).inDays + 1;
    return diff > 0 ? diff : 1;
  }

  Future<void> loadItinerary() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = _ref.read(authUserProvider);
      final trips = _ref.read(tripControllerProvider).trips;
      final trip = trips.where((t) => t.id == state.tripId).firstOrNull;

      final totalDays = _calculateTotalDays(trip);

      final raw = await _dbHelper.getItineraryItemsByTrip(
        state.tripId,
        userId: user?.uid,
      );

      final items = raw.map((m) => ItineraryItem.fromMap(m)).toList();

      state = state.copyWith(
        items: items,
        totalDays: totalDays,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectDay(int day) {
    if (state.selectedDay != day) {
      state = state.copyWith(selectedDay: day);
    }
  }

  Future<bool> addActivity({
    required String title,
    required int dayNumber,
    required String date,
    String? time,
    String? endTime,
    String? description,
    String? location,
    String category = 'sightseeing',
    double? cost,
    String? currency,
  }) async {
    try {
      final user = _ref.read(authUserProvider);
      final profile = _ref.read(profileControllerProvider).profile;
      final authorName = (profile?.displayName != null && profile!.displayName!.trim().isNotEmpty)
          ? profile.displayName!.trim()
          : (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
              ? user.displayName!.trim()
              : (user?.email != null && user!.email!.trim().isNotEmpty)
                  ? user.email!.trim().split('@').first
                  : null;

      final now = DateTime.now();
      final id = 'itin_${now.millisecondsSinceEpoch}_${state.tripId}';

      final newItem = ItineraryItem(
        id: id,
        userId: user?.uid ?? '',
        tripId: state.tripId,
        dayNumber: dayNumber,
        date: date,
        time: time,
        endTime: endTime,
        title: title,
        description: description,
        location: location,
        category: category,
        cost: cost,
        currency: currency,
        createdAt: now,
        updatedAt: now,
        createdByName: authorName,
      );

      await _dbHelper.insertItineraryItem(newItem.toMap());

      // If collaborative trip, push immediately to Firestore for real-time collaborator view
      final trips = _ref.read(tripControllerProvider).trips;
      final trip = trips.where((t) => t.id == state.tripId).firstOrNull;
      if (trip != null && trip.isCollaborative) {
        try {
          _ref.read(syncEngineProvider.notifier).pushItineraryItem(newItem);
        } catch (_) {}
      }

      final updatedList = List<ItineraryItem>.from(state.items)..add(newItem);
      // Sort
      updatedList.sort((a, b) {
        if (a.dayNumber != b.dayNumber) return a.dayNumber.compareTo(b.dayNumber);
        if (a.time != null && b.time != null) return a.time!.compareTo(b.time!);
        if (a.time != null) return -1;
        if (b.time != null) return 1;
        return a.createdAt.compareTo(b.createdAt);
      });

      state = state.copyWith(items: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateActivity({
    required String id,
    required String title,
    required int dayNumber,
    required String date,
    String? time,
    String? endTime,
    String? description,
    String? location,
    String category = 'sightseeing',
    double? cost,
    String? currency,
  }) async {
    try {
      final index = state.items.indexWhere((i) => i.id == id);
      if (index == -1) return false;

      final existing = state.items[index];
      final now = DateTime.now();
      final user = _ref.read(authUserProvider);
      final profile = _ref.read(profileControllerProvider).profile;
      final updaterName = (profile?.displayName != null && profile!.displayName!.trim().isNotEmpty)
          ? profile.displayName!.trim()
          : (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
              ? user.displayName!.trim()
              : null;

      final updatedItem = existing.copyWith(
        dayNumber: dayNumber,
        date: date,
        time: time,
        endTime: endTime,
        clearTime: time == null,
        clearEndTime: endTime == null,
        title: title,
        description: description,
        location: location,
        category: category,
        cost: cost,
        currency: currency,
        updatedAt: now,
        createdByName: updaterName ?? existing.createdByName,
      );

      await _dbHelper.updateItineraryItem(updatedItem.toMap());

      // If collaborative trip, push immediately to Firestore
      final trips = _ref.read(tripControllerProvider).trips;
      final trip = trips.where((t) => t.id == state.tripId).firstOrNull;
      if (trip != null && trip.isCollaborative) {
        try {
          _ref.read(syncEngineProvider.notifier).pushItineraryItem(updatedItem);
        } catch (_) {}
      }

      final updatedList = List<ItineraryItem>.from(state.items);
      updatedList[index] = updatedItem;
      // Sort
      updatedList.sort((a, b) {
        if (a.dayNumber != b.dayNumber) return a.dayNumber.compareTo(b.dayNumber);
        if (a.time != null && b.time != null) return a.time!.compareTo(b.time!);
        if (a.time != null) return -1;
        if (b.time != null) return 1;
        return a.createdAt.compareTo(b.createdAt);
      });

      state = state.copyWith(items: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> toggleCompleted(String itemId) async {
    final index = state.items.indexWhere((i) => i.id == itemId);
    if (index == -1) return false;

    final current = state.items[index];
    final updated = current.copyWith(
      isCompleted: !current.isCompleted,
      updatedAt: DateTime.now(),
    );

    final updatedList = List<ItineraryItem>.from(state.items);
    updatedList[index] = updated;
    state = state.copyWith(items: updatedList);

    try {
      await _dbHelper.toggleItineraryItemCompletion(itemId, updated.isCompleted);

      // If collaborative trip, push update immediately
      final trips = _ref.read(tripControllerProvider).trips;
      final trip = trips.where((t) => t.id == state.tripId).firstOrNull;
      if (trip != null && trip.isCollaborative) {
        try {
          _ref.read(syncEngineProvider.notifier).pushItineraryItem(updated);
        } catch (_) {}
      }

      return true;
    } catch (e) {
      // Rollback on error
      updatedList[index] = current;
      state = state.copyWith(items: updatedList, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteActivity(String itemId) async {
    try {
      await _dbHelper.deleteItineraryItem(itemId);
      final updatedList = state.items.where((i) => i.id != itemId).toList();
      state = state.copyWith(items: updatedList);

      // If collaborative trip, delete immediately from Firestore
      final trips = _ref.read(tripControllerProvider).trips;
      final trip = trips.where((t) => t.id == state.tripId).firstOrNull;
      if (trip != null && trip.isCollaborative) {
        try {
          _ref.read(syncEngineProvider.notifier).deleteRemoteItineraryItem(itemId);
        } catch (_) {}
      }

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final itineraryControllerFamily =
    StateNotifierProvider.family<ItineraryController, ItineraryState, String>(
        (ref, tripId) {
  return ItineraryController(ref, tripId);
});
