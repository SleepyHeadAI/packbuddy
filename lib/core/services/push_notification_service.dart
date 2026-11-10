import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/core/services/app_widget_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/features/dashboard/presentation/widgets/notifications_center_sheet.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';

/// Top-level background message handler executed by the OS when the app is
/// suspended in background or completely terminated / killed.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}

  try {
    final data = message.data;
    final notification = message.notification;
    final String notifId = data['id']?.toString() ??
        message.messageId ??
        'bg_${DateTime.now().millisecondsSinceEpoch}';

    final prefs = await SharedPreferences.getInstance();
    final deliveredList = prefs.getStringList(PreferencesService.keyDeliveredNotificationIds) ?? [];

    // Deduplication check: Do not re-notify if this ID was already delivered to device
    if (deliveredList.contains(notifId)) {
      debugPrint('[PushNotificationService] Background message $notifId already delivered. Skipping.');
      return;
    }

    // Mark as delivered
    deliveredList.add(notifId);
    if (deliveredList.length > 200) {
      deliveredList.removeRange(0, deliveredList.length - 200);
    }
    await prefs.setStringList(PreferencesService.keyDeliveredNotificationIds, deliveredList);

    final title = notification?.title ?? data['title']?.toString() ?? 'PackBuddy';
    final body = notification?.body ?? data['body']?.toString() ?? data['message']?.toString() ?? '';
    final type = data['type']?.toString() ?? 'admin_broadcast';
    final targetAction = data['targetAction']?.toString() ?? '';

    // Record into notification history
    final historyList = prefs.getStringList(PreferencesService.keyNotificationHistoryList) ?? [];
    final recordJson = jsonEncode({
      'id': notifId,
      'title': title,
      'body': body,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'targetAction': targetAction,
    });
    historyList.insert(0, recordJson);
    if (historyList.length > 60) historyList.removeLast();
    await prefs.setStringList(PreferencesService.keyNotificationHistoryList, historyList);

    // If message is a data-only payload, display high-priority system notification directly
    if (notification == null && (title.isNotEmpty || body.isNotEmpty)) {
      final flnp = FlutterLocalNotificationsPlugin();
      const androidDetails = AndroidNotificationDetails(
        LocalNotificationService.urgentAlertChannelId,
        LocalNotificationService.urgentAlertChannelName,
        channelDescription: LocalNotificationService.urgentAlertChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );
      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      final int numericId = (notifId.hashCode % 1000000000).abs();
      await flnp.show(
        id: numericId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: 'broadcast:$targetAction:$notifId',
      );
    }
  } catch (e) {
    debugPrint('[PushNotificationService] Error in background message handler: $e');
  }
}

/// Unified Push Notification & Broadcast Service handling FCM lifecycle,
/// device tokens, topic subscriptions, anti-repeat deduplication, and deep links.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  bool _initialized = false;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initializes FCM listeners, requests permissions, and subscribes to broadcast topics.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (kIsWeb) return;

      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('[PushNotificationService] Firebase not initialized yet, skipping FCM warmup.');
        return;
      }

      final messaging = FirebaseMessaging.instance;

      // 1. Request notification permissions (Android 13+ / iOS)
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('[PushNotificationService] User granted permission: ${settings.authorizationStatus}');

      // 2. Set presentation options for foreground notifications
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Register top-level background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 4. Subscribe to global broadcast & campaign topics
      try {
        await messaging.subscribeToTopic('all_users');
        await messaging.subscribeToTopic('announcements');
        await messaging.subscribeToTopic('promotions');
      } catch (e) {
        debugPrint('[PushNotificationService] Topic subscription notice: $e');
      }

      // 5. Fetch device FCM Token
      try {
        _fcmToken = await messaging.getToken();
        debugPrint('[PushNotificationService] FCM Token resolved: ${_fcmToken?.substring(0, _fcmToken!.length > 10 ? 10 : _fcmToken!.length)}...');
      } catch (e) {
        debugPrint('[PushNotificationService] getToken notice: $e');
      }

      // 6. Listen to token refreshes
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
      });

      // 7. Foreground message handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        await _handleIncomingForegroundMessage(message);
      });

      // 8. Handle notification tap when app opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[PushNotificationService] Notification opened from background: ${message.data}');
        final payload = message.data['payload'] ?? message.data['route'] ?? 'broadcast:${message.data['targetAction'] ?? ''}:${message.data['id'] ?? ''}';
        handlePayloadRoute(payload.toString());
      });

      // 9. Check if app was cold-started from a notification tap
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        final payload = initialMessage.data['payload'] ?? initialMessage.data['route'] ?? 'broadcast:${initialMessage.data['targetAction'] ?? ''}:${initialMessage.data['id'] ?? ''}';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handlePayloadRoute(payload.toString());
        });
      }

      _initialized = true;
    } catch (e) {
      debugPrint('[PushNotificationService] Initialization error (continuing gracefully): $e');
    }
  }

  /// Syncs the current FCM token with the user's Firestore profile so the admin
  /// can target specific users or devices.
  Future<void> syncUserFcmToken(String uid) async {
    if (uid.isEmpty || _fcmToken == null || _fcmToken!.isEmpty) return;
    try {
      if (Firebase.apps.isEmpty) return;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fcmToken': _fcmToken,
        'fcmTokens': FieldValue.arrayUnion([_fcmToken]),
        'lastFcmTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[PushNotificationService] syncUserFcmToken notice: $e');
    }
  }

  /// Handles incoming foreground FCM message with deduplication & heads-up alert.
  Future<void> _handleIncomingForegroundMessage(RemoteMessage message) async {
    final data = message.data;
    final notification = message.notification;
    final notifId = data['id']?.toString() ?? message.messageId ?? '${DateTime.now().millisecondsSinceEpoch}';

    // Anti-repeat deduplication
    if (PreferencesService.instance.hasDeliveredNotification(notifId)) {
      debugPrint('[PushNotificationService] Foreground message $notifId already delivered. Suppressing.');
      return;
    }

    await PreferencesService.instance.markNotificationDelivered(notifId);

    final title = notification?.title ?? data['title']?.toString() ?? 'PackBuddy Bildirimi';
    final body = notification?.body ?? data['body']?.toString() ?? data['message']?.toString() ?? '';
    final targetAction = data['targetAction']?.toString() ?? '';
    final type = data['type']?.toString() ?? 'admin_broadcast';

    // Save to local notification history
    final recordJson = jsonEncode({
      'id': notifId,
      'title': title,
      'body': body,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': type,
      'targetAction': targetAction,
    });
    await PreferencesService.instance.addNotificationHistoryItem(recordJson);

    // Show heads-up banner via LocalNotificationService
    try {
      await LocalNotificationService().showInstantNotification(
        id: (notifId.hashCode % 1000000000).abs(),
        title: title,
        body: body,
        payload: 'broadcast:$targetAction:$notifId',
      );
    } catch (e) {
      debugPrint('[PushNotificationService] Foreground alert dispatch error: $e');
    }
  }

  /// Global route dispatcher triggered when user taps any system notification
  static void handlePayloadRoute(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final ctx = AppWidgetService.navigatorKey.currentContext;
    if (ctx == null) return;

    try {
      // 1. Paywall / Pro Discount Promotion
      if (payload.contains('paywall') || payload.contains('discount') || payload.contains('pro')) {
        PaywallSheet.show(ctx);
        return;
      }

      // 2. Admin Warning or Notification Center
      if (payload.startsWith('admin_warning') || payload.contains('notifications_center')) {
        NotificationsCenterSheet.show(ctx);
        return;
      }

      // 3. Vault Documents
      if (payload.contains('vault')) {
        Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const VaultScreen()),
        );
        return;
      }
    } catch (e) {
      debugPrint('[PushNotificationService] handlePayloadRoute error: $e');
    }
  }
}
