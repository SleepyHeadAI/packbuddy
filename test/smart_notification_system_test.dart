import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeSyncEngine extends StateNotifier<SyncState> implements SyncEngine {
  FakeSyncEngine() : super(const SyncState());

  @override
  Future<void> performSync() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTestDbHelper implements DatabaseHelper {
  final List<Trip> trips;

  FakeTestDbHelper({List<Trip>? initialTrips})
      : trips = initialTrips ?? [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<Trip>> getTrips({String? userId, bool includeDeleted = false}) async {
    return trips.where((t) => includeDeleted || !t.isDeleted).toList();
  }

  @override
  Future<int> insertTrip(Trip trip, {String? userId}) async {
    trips.removeWhere((t) => t.id == trip.id);
    trips.add(trip);
    return 1;
  }

  @override
  Future<int> updateTrip(Trip trip, {String? userId}) async {
    final index = trips.indexWhere((t) => t.id == trip.id);
    if (index != -1) {
      trips[index] = trip;
    } else {
      trips.add(trip);
    }
    return 1;
  }

  @override
  Future<int> deleteTrip(String id, {String? userId}) async {
    trips.removeWhere((t) => t.id == id);
    return 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeNotificationService fakeNotifications;
  late FakeTestDbHelper fakeDb;

  final sampleTrip = Trip(
    id: 'trip-test-tokyo',
    title: 'Tokyo Spring Adventure',
    destination: 'Tokyo, Japan',
    startDate: DateTime.now().add(const Duration(days: 5)), // 120 hours in future
    endDate: DateTime.now().add(const Duration(days: 12)),
    defaultCurrency: 'JPY',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    fakeNotifications = FakeNotificationService();
    fakeDb = FakeTestDbHelper(initialTrips: [sampleTrip]);
  });

  group('1. Notification ID & Deterministic Hashing Tests', () {
    test('LocalNotificationService generates valid positive 31-bit IDs', () {
      final service = LocalNotificationService();
      final id48 = service.generateNotificationId('trip-abc-123', 48);
      final id24 = service.generateNotificationId('trip-abc-123', 24);

      expect(id48, isNonNegative);
      expect(id24, isNonNegative);
      expect(id48, lessThan(1000000000));
      expect(id24, lessThan(1000000000));
      expect(id48, isNot(equals(id24)));

      // Determinism
      expect(service.generateNotificationId('trip-abc-123', 48), equals(id48));
    });
  });

  group('2. FakeNotificationService Contract Tests', () {
    test('Schedules and cancels trip reminders according to interface contract', () async {
      expect(fakeNotifications.scheduledTripIds, isEmpty);

      await fakeNotifications.scheduleTripReminder(sampleTrip);
      expect(fakeNotifications.scheduledTripIds, contains('trip-test-tokyo'));

      await fakeNotifications.cancelReminder('trip-test-tokyo');
      expect(fakeNotifications.scheduledTripIds, isNot(contains('trip-test-tokyo')));
      expect(fakeNotifications.cancelledTripIds, contains('trip-test-tokyo'));

      await fakeNotifications.scheduleTripReminder(sampleTrip);
      await fakeNotifications.cancelAll();
      expect(fakeNotifications.scheduledTripIds, isEmpty);
      expect(fakeNotifications.isAllCancelled, isTrue);
    });
  });

  group('3. TripController Integration Tests with Smart Notifications', () {
    test('addTrip automatically schedules smart packing reminders', () async {
      final container = ProviderContainer(
        overrides: [
          syncEngineProvider.overrideWith((ref) => FakeSyncEngine()),
          notificationServiceProvider.overrideWithValue(fakeNotifications),
          tripControllerProvider.overrideWith(
            (ref) => TripController(
              ref,
              dbHelper: fakeDb,
              notificationService: fakeNotifications,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(tripControllerProvider.notifier);

      final newTrip = await controller.addTrip(
        title: 'Paris Getaway',
        destination: 'Paris, France',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 14)),
        defaultCurrency: 'EUR',
      );

      expect(newTrip, isNotNull);
      expect(fakeNotifications.scheduledTripIds, contains(newTrip!.id));
    });

    test('updateTrip cancels previous reminders and reschedules', () async {
      final container = ProviderContainer(
        overrides: [
          syncEngineProvider.overrideWith((ref) => FakeSyncEngine()),
          notificationServiceProvider.overrideWithValue(fakeNotifications),
          tripControllerProvider.overrideWith(
            (ref) => TripController(
              ref,
              dbHelper: fakeDb,
              notificationService: fakeNotifications,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(tripControllerProvider.notifier);

      final updatedTrip = sampleTrip.copyWith(
        destination: 'Kyoto, Japan',
        startDate: DateTime.now().add(const Duration(days: 6)),
      );

      await controller.updateTrip(updatedTrip);

      expect(fakeNotifications.cancelledTripIds, contains(sampleTrip.id));
      expect(fakeNotifications.scheduledTripIds, contains(sampleTrip.id));
    });

    test('deleteTrip cancels associated reminders', () async {
      final container = ProviderContainer(
        overrides: [
          syncEngineProvider.overrideWith((ref) => FakeSyncEngine()),
          notificationServiceProvider.overrideWithValue(fakeNotifications),
          tripControllerProvider.overrideWith(
            (ref) => TripController(
              ref,
              dbHelper: fakeDb,
              notificationService: fakeNotifications,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(tripControllerProvider.notifier);

      final deleted = await controller.deleteTrip(sampleTrip.id);

      expect(deleted, isTrue);
      expect(fakeNotifications.cancelledTripIds, contains(sampleTrip.id));
    });
  });

  group('4. Settings UI & Packing Reminders Toggle Tests', () {
    test('PackingRemindersNotifier toggles preference and cancels/reschedules correctly', () async {
      final container = ProviderContainer(
        overrides: [
          syncEngineProvider.overrideWith((ref) => FakeSyncEngine()),
          notificationServiceProvider.overrideWithValue(fakeNotifications),
          tripControllerProvider.overrideWith(
            (ref) => TripController(
              ref,
              dbHelper: fakeDb,
              notificationService: fakeNotifications,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(packingRemindersProvider.notifier);

      // Turn OFF
      await notifier.toggle(false);
      expect(container.read(packingRemindersProvider), isFalse);
      expect(fakeNotifications.isAllCancelled, isTrue);

      // Turn ON
      await notifier.toggle(true);
      expect(container.read(packingRemindersProvider), isTrue);
      expect(fakeNotifications.scheduledTripIds, contains(sampleTrip.id));
    });

    testWidgets('SettingsScreen renders Packing Reminders toggle switch cleanly', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          syncEngineProvider.overrideWith((ref) => FakeSyncEngine()),
          notificationServiceProvider.overrideWithValue(fakeNotifications),
          tripControllerProvider.overrideWith(
            (ref) => TripController(
              ref,
              dbHelper: fakeDb,
              notificationService: fakeNotifications,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag ListView down to reveal Packing Reminders tile
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Tap Switch to toggle OFF
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(container.read(packingRemindersProvider), isFalse);
      expect(fakeNotifications.isAllCancelled, isTrue);
    });
  });
}
