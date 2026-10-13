import 'package:flutter/material.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../features/budget/domain/trip.dart';
import '../../../features/budget/presentation/controllers/trip_controller.dart';
import 'preferences_service.dart';

/// Abstract contract for the Smart Notification System in PackBuddy.
/// Decouples UI and business logic from the underlying notification engine
/// (Local Notifications, Firebase Cloud Messaging, OneSignal, etc.).
abstract class INotificationService {
  /// Initializes background receivers, channels, and timezone databases.
  Future<void> initialize();

  /// Requests notification permissions gracefully for iOS and Android 13+.
  Future<bool> requestPermissions();

  /// Schedules smart packing reminders (48 hours & 24 hours prior to departure).
  Future<void> scheduleTripReminder(Trip trip);

  /// Cancels all scheduled packing reminders associated with a specific trip.
  Future<void> cancelReminder(String tripId);

  /// Cancels all scheduled notifications across the entire app.
  Future<void> cancelAll();

  /// Reschedules packing reminders for all active upcoming trips.
  Future<void> syncAllTripReminders(List<Trip> trips);
}

/// Production implementation of [INotificationService] powered by
/// `flutter_local_notifications` and `timezone`.
class LocalNotificationService implements INotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final PreferencesService _prefs;
  bool _isInitialized = false;

  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    PreferencesService? preferencesService,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _prefs = preferencesService ?? PreferencesService.instance;

  /// Android notification channel identifier
  static const String channelId = 'packbuddy_trip_reminders';
  static const String channelName = 'Trip Packing Reminders';
  static const String channelDescription =
      'Smart notifications and packing reminders before trip departure';

  /// Generates a deterministic, positive 31-bit integer notification ID
  /// from the trip UUID and the reminder offset in hours.
  @visibleForTesting
  int generateNotificationId(String tripId, int hoursBefore) {
    final rawHash = '$tripId:$hoursBefore'.hashCode;
    return rawHash.abs() % 1000000000;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Timezone database
      tz.initializeTimeZones();
      try {
        final timeZoneName = DateTime.now().timeZoneName;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        // Fallback: tz.local remains initialized to default
      }

      // 2. Platform initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('[LocalNotificationService] Notification tapped: ${response.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('[LocalNotificationService] Initialization error (continuing gracefully): $e');
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      bool granted = false;

      // Android 13+ (API 33+) runtime permissions
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final androidGranted = await androidImpl.requestNotificationsPermission();
        try {
          await androidImpl.requestExactAlarmsPermission();
        } catch (_) {}
        granted = androidGranted ?? false;
      }

      // iOS Darwin permissions
      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final iosGranted = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = iosGranted ?? false;
      }

      return granted;
    } catch (e) {
      debugPrint('[LocalNotificationService] requestPermissions error: $e');
      return false;
    }
  }

  @override
  Future<void> scheduleTripReminder(Trip trip) async {
    // 1. Check user preference
    if (!_prefs.isPackingRemindersEnabled()) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    final now = DateTime.now();

    // 2. Schedule 48-Hour Reminder
    final reminder48 = trip.startDate.subtract(const Duration(hours: 48));
    if (reminder48.isAfter(now)) {
      await _scheduleSingleReminder(
        id: generateNotificationId(trip.id, 48),
        scheduledDate: reminder48,
        title: _get48hTitle(trip),
        body: _get48hBody(trip),
        payload: 'trip:${trip.id}',
      );
    }

    // 3. Schedule 24-Hour Reminder
    final reminder24 = trip.startDate.subtract(const Duration(hours: 24));
    if (reminder24.isAfter(now)) {
      await _scheduleSingleReminder(
        id: generateNotificationId(trip.id, 24),
        scheduledDate: reminder24,
        title: _get24hTitle(trip),
        body: _get24hBody(trip),
        payload: 'trip:${trip.id}',
      );
    }
  }

  @override
  Future<void> cancelReminder(String tripId) async {
    try {
      await _plugin.cancel(id: generateNotificationId(tripId, 48));
      await _plugin.cancel(id: generateNotificationId(tripId, 24));
    } catch (e) {
      debugPrint('[LocalNotificationService] cancelReminder error for $tripId: $e');
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[LocalNotificationService] cancelAll error: $e');
    }
  }

  @override
  Future<void> syncAllTripReminders(List<Trip> trips) async {
    await cancelAll();
    if (!_prefs.isPackingRemindersEnabled()) return;

    for (final trip in trips) {
      if (!trip.isDeleted) {
        await scheduleTripReminder(trip);
      }
    }
  }

  Future<void> _scheduleSingleReminder({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final tzDateTime = _convertToTzDateTime(scheduledDate);

      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[LocalNotificationService] Failed to schedule notification #$id: $e');
    }
  }

  tz.TZDateTime _convertToTzDateTime(DateTime dateTime) {
    try {
      return tz.TZDateTime.from(dateTime, tz.local);
    } catch (_) {
      return tz.TZDateTime.from(dateTime.toUtc(), tz.UTC);
    }
  }

  // --- Context-Aware Messaging ---

  AppLocalizations _getL10n() {
    final locale = _prefs.getLocale() ?? const Locale('en');
    try {
      return lookupAppLocalizations(locale);
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }

  String _get48hTitle(Trip trip) {
    return _getL10n().notification48hTitle(trip.destination);
  }

  String _get48hBody(Trip trip) {
    return _getL10n().notification48hBody(trip.destination);
  }

  String _get24hTitle(Trip trip) {
    return _getL10n().notification24hTitle;
  }

  String _get24hBody(Trip trip) {
    return _getL10n().notification24hBody(trip.destination);
  }
}

/// In-memory mock implementation of [INotificationService] for tests and headless runners.
class FakeNotificationService implements INotificationService {
  final List<String> scheduledTripIds = [];
  final List<String> cancelledTripIds = [];
  bool permissionsGranted = true;
  bool isAllCancelled = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => permissionsGranted;

  @override
  Future<void> scheduleTripReminder(Trip trip) async {
    scheduledTripIds.add(trip.id);
  }

  @override
  Future<void> cancelReminder(String tripId) async {
    cancelledTripIds.add(tripId);
    scheduledTripIds.remove(tripId);
  }

  @override
  Future<void> cancelAll() async {
    isAllCancelled = true;
    scheduledTripIds.clear();
  }

  @override
  Future<void> syncAllTripReminders(List<Trip> trips) async {
    for (final trip in trips) {
      if (!trip.isDeleted) {
        await scheduleTripReminder(trip);
      }
    }
  }
}

/// Global Riverpod Provider for [INotificationService]
final notificationServiceProvider = Provider<INotificationService>((ref) {
  final service = LocalNotificationService();
  service.initialize();
  return service;
});

/// StateNotifier managing the user's packing reminders toggle preference
class PackingRemindersNotifier extends StateNotifier<bool> {
  final INotificationService _notificationService;
  final PreferencesService _prefs;
  final Ref _ref;

  PackingRemindersNotifier(this._notificationService, this._prefs, this._ref)
      : super(_prefs.isPackingRemindersEnabled());

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _prefs.setPackingRemindersEnabled(enabled);

    if (enabled) {
      await _notificationService.requestPermissions();
      final trips = _ref.read(tripControllerProvider).trips;
      await _notificationService.syncAllTripReminders(trips);
    } else {
      await _notificationService.cancelAll();
    }
  }
}

/// Riverpod provider for packing reminders preference toggle
final packingRemindersProvider =
    StateNotifierProvider<PackingRemindersNotifier, bool>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return PackingRemindersNotifier(
    notificationService,
    PreferencesService.instance,
    ref,
  );
});
