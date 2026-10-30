import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/telemetry_service.dart';
import '../../../../data/local_db/database_helper.dart';
import '../../../../data/sync_engine/sync_engine.dart';
import '../../domain/trip.dart';
import '../../domain/expense.dart';
import '../../../checklist/domain/packing_item.dart';
import '../../../auth/auth_controller.dart';

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

/// Controller managing trips persistence, background cloud sync, and smart notifications
class TripController extends StateNotifier<TripState> {
  final Ref _ref;
  final DatabaseHelper _dbHelper;
  final INotificationService? _notificationService;
  final _uuid = const Uuid();

  TripController(
    this._ref, {
    DatabaseHelper? dbHelper,
    INotificationService? notificationService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        // ignore: prefer_initializing_formals
        _notificationService = notificationService,
        super(const TripState()) {
    loadTrips();
  }

  INotificationService get _notifications =>
      _notificationService ?? _ref.read(notificationServiceProvider);

  /// Resets controller state on logout or account switch
  void resetState() {
    state = const TripState();
  }

  /// Loads non-deleted trips from SQLite
  Future<void> loadTrips({String? userId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final trips = await _dbHelper.getTrips(userId: userId, includeDeleted: false);
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        trips: trips,
      );

      // Sync active reminders for upcoming trips
      try {
        _notifications.syncAllTripReminders(trips);
      } catch (_) {}

      // Register real-time live listeners for shared collaborative trips
      for (final t in trips) {
        if (t.isShared || t.collaborators.isNotEmpty) {
          try {
            _ref.read(syncEngineProvider.notifier).listenToSharedTrip(t.id);
          } catch (_) {}
        }
      }
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
    // Feature restriction guard (Phase 3)
    if (PreferencesService.instance.getRestrictedFeatures().contains('trip_create')) {
      state = state.copyWith(errorMessage: 'restricted_trip_create');
      return null;
    }

    try {
      final now = DateTime.now();
      final currentUid = _ref.read(authUserProvider)?.uid ?? '';
      final newTrip = Trip(
        id: _uuid.v4(),
        userId: currentUid,
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

      // Log telemetry event
      TelemetryService.instance.logTripCreated(
        destination: destination,
        transportMode: transportMode ?? 'unspecified',
        budget: budgetLimit ?? 0.0,
        currency: defaultCurrency,
      );

      // Schedule smart packing notifications (48h & 24h prior to departure)
      try {
        await _notifications.scheduleTripReminder(newTrip);
      } catch (_) {}

      // Trigger background two-way sync safely
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

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

      // Start real-time live listener if this trip is collaborative
      if (tripToSave.isShared || tripToSave.collaborators.isNotEmpty) {
        try {
          _ref.read(syncEngineProvider.notifier).listenToSharedTrip(tripToSave.id);
        } catch (_) {}
      }

      // Reschedule packing reminders with updated departure dates
      try {
        await _notifications.cancelReminder(tripToSave.id);
        await _notifications.scheduleTripReminder(tripToSave);
      } catch (_) {}

      // Trigger background two-way sync safely
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

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

      // Cancel associated packing reminders
      try {
        await _notifications.cancelReminder(tripId);
      } catch (_) {}

      // Trigger background two-way sync safely (soft-deleted trip will cascade to cloud)
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Generates or retrieves a 6-character collaboration invite code for a trip (Feature F-1)
  Future<String?> generateInviteCode(String tripId) async {
    final index = state.trips.indexWhere((t) => t.id == tripId);
    if (index == -1) return null;

    final trip = state.trips[index];
    if (trip.inviteCode != null && trip.inviteCode!.isNotEmpty) {
      return trip.inviteCode;
    }

    final code = 'PB-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase().padRight(5, '0').substring(0, 5)}';
    final updated = trip.copyWith(
      isShared: true,
      inviteCode: code,
      sharedRole: 'owner',
    );
    await updateTrip(updated);
    return code;
  }

  /// Joins a shared trip by 6-character invite code (Feature F-1)
  Future<Trip?> joinTripByInviteCode(String rawCode, {String? userIdentifier}) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return null;

    // 1. Search in local memory
    Trip? targetTrip;
    for (final t in state.trips) {
      if (t.inviteCode?.toUpperCase() == code) {
        targetTrip = t;
        break;
      }
    }

    // 2. Search in SQLite
    if (targetTrip == null) {
      final allTrips = await _dbHelper.getTrips(includeDeleted: false);
      for (final t in allTrips) {
        if (t.inviteCode?.toUpperCase() == code) {
          targetTrip = t;
          break;
        }
      }
    }

    // 3. Search in Cloud Firestore if not found locally
    if (targetTrip == null && Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        var snap = await firestore
            .collection('trips')
            .where('inviteCode', isEqualTo: code)
            .limit(1)
            .get();

        if (snap.docs.isEmpty) {
          snap = await firestore
              .collection('trips')
              .where('invite_code', isEqualTo: code)
              .limit(1)
              .get();
        }

        if (snap.docs.isNotEmpty) {
          final doc = snap.docs.first;
          targetTrip = Trip.fromJson(doc.data());
        }
      } catch (e) {
        // Fallback gracefully
      }
    }

    if (targetTrip == null) {
      // Attempt cloud sync in case another user shared it
      try {
        await _ref.read(syncEngineProvider.notifier).performSync();
        final refreshed = await _dbHelper.getTrips(includeDeleted: false);
        for (final t in refreshed) {
          if (t.inviteCode?.toUpperCase() == code) {
            targetTrip = t;
            break;
          }
        }
      } catch (_) {}
    }

    if (targetTrip == null) return null;

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final currentEmail = FirebaseAuth.instance.currentUser?.email;
    final member = userIdentifier ?? currentEmail ?? currentUid ?? 'Collaborator';
    final currentCollabs = List<String>.from(targetTrip.collaborators);
    if (!currentCollabs.contains(member)) {
      currentCollabs.add(member);
    }
    if (currentUid != null && !currentCollabs.contains(currentUid)) {
      currentCollabs.add(currentUid);
    }

    final joinedTrip = targetTrip.copyWith(
      isShared: true,
      collaborators: currentCollabs,
      updatedAt: DateTime.now(),
    );

    // Save joined trip to local SQLite
    await _dbHelper.insertTrip(joinedTrip);

    // Sync remote Firestore document so all members see the new collaborator
    if (Firebase.apps.isNotEmpty) {
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('trips')
            .doc(joinedTrip.id)
            .set(joinedTrip.toJson(), SetOptions(merge: true));

        // Pull expenses for this shared trip into local SQLite
        final expSnap = await firestore
            .collection('expenses')
            .where('trip_id', isEqualTo: joinedTrip.id)
            .get();
        for (final d in expSnap.docs) {
          try {
            await _dbHelper.insertExpense(Expense.fromJson(d.data()));
          } catch (_) {}
        }

        // Pull packing checklist items for this shared trip into local SQLite
        final itemSnap = await firestore
            .collection('checklist_items')
            .where('trip_id', isEqualTo: joinedTrip.id)
            .get();
        for (final d in itemSnap.docs) {
          try {
            await _dbHelper.insertChecklistItem(PackingItem.fromJson(d.data()));
          } catch (_) {}
        }
      } catch (_) {}
    }

    // Update in-memory state
    final updatedList = List<Trip>.from(state.trips);
    final existingIdx = updatedList.indexWhere((t) => t.id == joinedTrip.id);
    if (existingIdx >= 0) {
      updatedList[existingIdx] = joinedTrip;
    } else {
      updatedList.insert(0, joinedTrip);
    }
    state = state.copyWith(trips: updatedList);

    // Start real-time live listener for this newly joined shared trip
    try {
      _ref.read(syncEngineProvider.notifier).listenToSharedTrip(joinedTrip.id);
    } catch (_) {}

    return joinedTrip;
  }

  /// Adds a collaborator email or name to the trip (Feature F-1)
  Future<bool> addCollaborator(String tripId, String collaborator) async {
    final index = state.trips.indexWhere((t) => t.id == tripId);
    if (index == -1) return false;

    final trip = state.trips[index];
    final updatedList = List<String>.from(trip.collaborators);
    if (!updatedList.contains(collaborator.trim())) {
      updatedList.add(collaborator.trim());
      final updated = trip.copyWith(isShared: true, collaborators: updatedList);
      await updateTrip(updated);
      return true;
    }
    return false;
  }

  /// Removes a collaborator from the trip (Feature F-1)
  Future<bool> removeCollaborator(String tripId, String collaborator) async {
    final index = state.trips.indexWhere((t) => t.id == tripId);
    if (index == -1) return false;

    final trip = state.trips[index];
    final updatedList = List<String>.from(trip.collaborators);
    if (updatedList.remove(collaborator.trim())) {
      final updated = trip.copyWith(collaborators: updatedList);
      await updateTrip(updated);
      return true;
    }
    return false;
  }
}

/// Global provider for TripController
final tripControllerProvider =
    StateNotifierProvider<TripController, TripState>((ref) {
  return TripController(ref);
});
