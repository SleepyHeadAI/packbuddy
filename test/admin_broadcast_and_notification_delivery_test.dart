import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/admin/domain/broadcast_announcement.dart';
import 'package:packbuddy/features/admin/domain/admin_audit_log.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class MockNotificationServiceForBroadcast implements INotificationService {
  final List<Map<String, dynamic>> displayedNotifications = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleTripReminder(Trip trip) async {}

  @override
  Future<void> cancelReminder(String tripId) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> syncAllTripReminders(List<Trip> trips) async {}

  @override
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    displayedNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
    });
  }
}

class MockAdminServiceForBroadcast implements AdminService {
  final List<BroadcastAnnouncement> announcements = [];
  final List<Map<String, dynamic>> sentWarnings = [];

  @override
  bool isCurrentUserAdmin() => true;

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async => const AdminPlatformMetrics(
        totalUsers: 100,
        proUsers: 30,
        totalTrips: 150,
      );

  @override
  Future<List<AdminUserModel>> fetchUsers() async => [
        AdminUserModel(
          uid: 'admin-user-1',
          email: 'sleepyheadaitr@gmail.com',
          displayName: 'Admin User',
          isPremium: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  Future<AdminDetailedAnalytics> fetchDetailedAnalytics() async => const AdminDetailedAnalytics();

  @override
  Future<void> toggleUserProStatus(String uid, bool isPremium) async {}

  @override
  Future<void> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  }) async {}

  @override
  Future<List<VaultDocument>> fetchUserDocuments(String uid) async => [];

  @override
  Future<List<Trip>> fetchUserTrips(String uid) async => [];

  @override
  Future<List<Expense>> fetchUserExpenses(String uid) async => [];

  @override
  Future<List<AdminUserSessionLog>> fetchUserSessions(String uid) async => [];

  @override
  Future<List<TravelCountry>> fetchUserTravelCountries(String uid) async => [];

  @override
  Future<void> deleteUserDocumentAsAdmin({required String uid, required String documentId}) async {}

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {}

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {}

  @override
  Future<void> sendInactivityWarningEmail(String uid) async {}

  @override
  Future<bool> sendUserWarning({
    required String uid,
    required String title,
    required String message,
    required String warningType,
    bool sendInAppNotification = true,
    bool sendEmail = true,
  }) async {
    sentWarnings.add({
      'uid': uid,
      'title': title,
      'message': message,
      'warningType': warningType,
    });
    return true;
  }

  @override
  Future<bool> sendBroadcastAnnouncement({
    required String title,
    required String message,
    String type = 'discount',
    String targetAction = 'paywall',
    String targetAudience = 'all',
    int? discountPercent,
    String? actionLabel,
  }) async {
    final announcement = BroadcastAnnouncement(
      id: 'announcement_${announcements.length + 1}',
      title: title,
      message: message,
      type: type,
      targetAction: targetAction,
      targetAudience: targetAudience,
      discountPercent: discountPercent,
      actionLabel: actionLabel,
      createdAt: DateTime.now(),
      active: true,
      sentBy: 'sleepyheadaitr@gmail.com',
    );
    announcements.insert(0, announcement);
    return true;
  }

  @override
  Future<List<BroadcastAnnouncement>> fetchBroadcastAnnouncements() async {
    return List.from(announcements);
  }

  @override
  Future<bool> toggleBroadcastActive(String broadcastId, bool active) async {
    final idx = announcements.indexWhere((a) => a.id == broadcastId);
    if (idx != -1) {
      announcements[idx] = announcements[idx].copyWith(active: active);
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteBroadcastAnnouncement(String broadcastId) async {
    announcements.removeWhere((a) => a.id == broadcastId);
    return true;
  }

  final List<AdminAuditLog> mockAuditLogs = [];

  @override
  Future<void> recordAuditLog({
    required String action,
    required String actionTitle,
    required String targetUid,
    String? targetUserEmail,
    String? targetUserName,
    Map<String, dynamic> details = const {},
  }) async {
    mockAuditLogs.insert(
      0,
      AdminAuditLog(
        id: 'mock_audit_${mockAuditLogs.length + 1}',
        action: action,
        actionTitle: actionTitle,
        adminEmail: 'sleepyheadaitr@gmail.com',
        targetUid: targetUid,
        targetUserEmail: targetUserEmail,
        targetUserName: targetUserName,
        details: details,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<AdminAuditLog>> fetchAuditLogs({int limit = 100}) async {
    return List.from(mockAuditLogs);
  }

  @override
  Future<InactivityScanResult> processInactivityPolicies() async => const InactivityScanResult();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Anti-Repeat Notification Deduplication Engine Tests', () {
    test('PreferencesService correctly tracks and prevents duplicate notifications', () async {
      final prefs = PreferencesService.instance;
      const notifId = 'warning_1715000000';

      expect(prefs.hasDeliveredNotification(notifId), isFalse);

      await prefs.markNotificationDelivered(notifId);
      expect(prefs.hasDeliveredNotification(notifId), isTrue);

      // Re-marking the same ID should not cause errors or duplicate entries
      await prefs.markNotificationDelivered(notifId);
      expect(prefs.hasDeliveredNotification(notifId), isTrue);
      expect(prefs.getDeliveredNotificationIds().where((id) => id == notifId).length, equals(1));
    });

    test('Simulated rapid successive delivery attempts only trigger 1 alert', () async {
      final prefs = PreferencesService.instance;
      final mockNotif = MockNotificationServiceForBroadcast();
      const testId = 'warning_fast_burst_99';

      int alertCount = 0;
      void onReceiveAlert() {
        if (!prefs.hasDeliveredNotification(testId)) {
          prefs.markNotificationDelivered(testId);
          mockNotif.showInstantNotification(
            id: 1234,
            title: 'Test Warning',
            body: 'Policy update',
          );
          alertCount++;
        }
      }

      // 5 rapid snapshot callbacks from Firestore / FCM
      onReceiveAlert();
      onReceiveAlert();
      onReceiveAlert();
      onReceiveAlert();
      onReceiveAlert();

      expect(alertCount, equals(1));
      expect(mockNotif.displayedNotifications.length, equals(1));
    });

    test('Warning sent while app was closed is delivered upon start and never repeated', () async {
      final prefs = PreferencesService.instance;
      final mockNotif = MockNotificationServiceForBroadcast();
      const warningId = 'cloud_warning_sent_10_minutes_ago';

      // Verify not yet seen
      expect(prefs.hasDeliveredNotification(warningId), isFalse);

      // App cold start sync delivers it
      if (!prefs.hasDeliveredNotification(warningId)) {
        await prefs.markNotificationDelivered(warningId);
        await mockNotif.showInstantNotification(
          id: 555,
          title: 'Önemli Güvenlik Bildirimi',
          body: 'Hesap durumunuz güncellendi.',
          payload: 'admin_warning:$warningId',
        );
      }

      expect(mockNotif.displayedNotifications.length, equals(1));
      expect(mockNotif.displayedNotifications.first['title'], equals('Önemli Güvenlik Bildirimi'));

      // Next app sync or app resume should NOT alert again
      if (!prefs.hasDeliveredNotification(warningId)) {
        await mockNotif.showInstantNotification(
          id: 555,
          title: 'Önemli Güvenlik Bildirimi',
          body: 'Hesap durumunuz güncellendi.',
        );
      }

      expect(mockNotif.displayedNotifications.length, equals(1));
    });
  });

  group('Admin Broadcast & Marketing Campaign Hub Controller Tests', () {
    test('Super Admin can compose, dispatch, toggle, and fetch broadcast announcements', () async {
      final mockService = MockAdminServiceForBroadcast();
      final container = ProviderContainer(
        overrides: [
          adminServiceProvider.overrideWithValue(mockService),
        ],
      );

      final controller = container.read(adminControllerProvider.notifier);

      // 1. Dispatch %50 Pro Discount Campaign
      final success = await controller.sendBroadcastAnnouncement(
        title: "PackBuddy Pro'da %50 İndirim! 🚀",
        message: "Sınırsız seyahat ve belge kasası şimdi indirimde!",
        type: 'discount',
        targetAction: 'paywall',
        targetAudience: 'free_only',
        discountPercent: 50,
      );

      expect(success, isTrue);
      expect(mockService.announcements.length, equals(1));
      expect(mockService.announcements.first.discountPercent, equals(50));
      expect(mockService.announcements.first.targetAudience, equals('free_only'));
      expect(mockService.announcements.first.active, isTrue);

      // 2. Fetch History
      final history = await controller.fetchBroadcastHistory();
      expect(history.length, equals(1));
      expect(history.first.title, contains('%50 İndirim'));

      // 3. Toggle Active Status
      final toggled = await controller.toggleBroadcastActive(history.first.id, false);
      expect(toggled, isTrue);
      expect(mockService.announcements.first.active, isFalse);

      // 4. Delete Announcement
      final deleted = await controller.deleteBroadcastAnnouncement(history.first.id);
      expect(deleted, isTrue);
      expect(mockService.announcements.isEmpty, isTrue);
    });
  });

  group('Admin Broadcast UI Widget Tests', () {
    testWidgets('AdminDashboardScreen renders Toplu Bildirim & Reklam Paneli card and opens composer',
        (tester) async {
      final mockService = MockAdminServiceForBroadcast();
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminServiceProvider.overrideWithValue(mockService),
            isAdminProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AdminDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the Broadcast Hub card renders
      expect(find.text('Toplu Bildirim & Reklam Paneli'), findsOneWidget);
      expect(find.text('Yeni Reklam / Bildirim Gönder'), findsOneWidget);
      expect(find.text('Geçmiş'), findsOneWidget);

      // Tap to open the composer bottom sheet
      await tester.tap(find.text('Yeni Reklam / Bildirim Gönder'));
      await tester.pumpAndSettle();

      // Verify BottomSheet components
      expect(find.text('Toplu Bildirim & Reklam Gönder'), findsOneWidget);
      expect(find.text('Hedef Kitle Segmenti'), findsOneWidget);
      expect(find.text('Hazır Reklam Şablonları'), findsOneWidget);
      expect(find.text('%50 Pro İndirimi'), findsOneWidget);
      expect(find.text('Canlı Telefon Bildirim Önizlemesi'), findsOneWidget);
      expect(find.text('Toplu Bildirimi Yayınla & Gönder'), findsOneWidget);

      // Tap preset to test dynamic form fill
      await tester.tap(find.text('Dünya Haritası'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Dünya Seyahat Haritanızı Keşfedin'), findsWidgets);

      // Tap to send
      await tester.tap(find.text('Toplu Bildirimi Yayınla & Gönder'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Toplu Bildirimi Onayla'), findsOneWidget);
      expect(find.text('Hemen Gönder'), findsOneWidget);

      // Confirm send
      await tester.tap(find.text('Hemen Gönder'));
      await tester.pumpAndSettle();

      // Verify the announcement was dispatched
      expect(mockService.announcements.length, equals(1));
      expect(mockService.announcements.first.type, equals('feature'));
    });
  });
}

