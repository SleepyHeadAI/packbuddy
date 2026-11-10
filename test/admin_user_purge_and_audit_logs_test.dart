import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/admin/domain/admin_audit_log.dart';
import 'package:packbuddy/features/admin/domain/broadcast_announcement.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class MockAuditAdminService implements AdminService {
  final List<AdminUserModel> users;
  final List<AdminAuditLog> auditLogs = [];
  bool purgeUserDataCalled = false;
  String? purgedUid;

  MockAuditAdminService({required this.users});

  @override
  bool isCurrentUserAdmin() => true;

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async => AdminPlatformMetrics(
        totalUsers: users.length,
        proUsers: users.where((u) => u.isPremium).length,
      );

  @override
  Future<List<AdminUserModel>> fetchUsers() async => List.from(users);

  @override
  Future<AdminDetailedAnalytics> fetchDetailedAnalytics() async =>
      const AdminDetailedAnalytics();

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {
    purgeUserDataCalled = true;
    purgedUid = uid;
    final user = users.where((u) => u.uid == uid).firstOrNull;
    users.removeWhere((u) => u.uid == uid);

    await recordAuditLog(
      action: 'purge_user',
      actionTitle: 'Kullanıcı ve Tüm Verileri Kalıcı Olarak Silindi',
      targetUid: uid,
      targetUserEmail: user?.email,
      targetUserName: user?.displayName,
      details: {
        'deletedCollections': ['trips', 'expenses', 'checklist_items', 'documents'],
        'reason': 'Manual purge',
      },
    );
  }

  @override
  Future<void> recordAuditLog({
    required String action,
    required String actionTitle,
    required String targetUid,
    String? targetUserEmail,
    String? targetUserName,
    Map<String, dynamic> details = const {},
  }) async {
    auditLogs.insert(
      0,
      AdminAuditLog(
        id: 'audit_${auditLogs.length + 1}',
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
    return List.from(auditLogs);
  }

  @override
  Future<void> toggleUserProStatus(String uid, bool isPremium) async {
    final idx = users.indexWhere((u) => u.uid == uid);
    if (idx != -1) {
      users[idx] = users[idx].copyWith(isPremium: isPremium);
    }
    await recordAuditLog(
      action: isPremium ? 'pro_grant' : 'pro_revoke',
      actionTitle: isPremium
          ? 'Kullanıcıya Pro Lisansı Verildi'
          : 'Kullanıcının Pro Lisansı Geri Alındı',
      targetUid: uid,
    );
  }

  @override
  Future<void> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  }) async {
    final idx = users.indexWhere((u) => u.uid == uid);
    if (idx != -1) {
      users[idx] = users[idx].copyWith(
        isPremium: isPremium,
        banStatus: banStatus,
        restrictedFeatures: restrictedFeatures,
      );
    }
    await recordAuditLog(
      action: banStatus == 'banned' ? 'ban_user' : 'unban_user',
      actionTitle: banStatus == 'banned'
          ? 'Kullanıcı Kalıcı Olarak Engellendi'
          : 'Kullanıcı Engeli Kaldırıldı',
      targetUid: uid,
      details: {'banReason': banReason ?? ''},
    );
  }

  @override
  Future<bool> sendUserWarning({
    required String uid,
    required String title,
    required String message,
    required String warningType,
    bool sendInAppNotification = true,
    bool sendEmail = true,
  }) async {
    await recordAuditLog(
      action: 'send_warning',
      actionTitle: 'Kullanıcıya Yönetici Uyarısı Gönderildi: $title',
      targetUid: uid,
      details: {'message': message, 'warningType': warningType},
    );
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
    await recordAuditLog(
      action: 'broadcast_sent',
      actionTitle: 'Toplu Kampanya / Reklam Gönderildi: $title',
      targetUid: 'broadcast_all',
      details: {'discountPercent': discountPercent},
    );
    return true;
  }

  @override
  Future<List<BroadcastAnnouncement>> fetchBroadcastAnnouncements() async => [];

  @override
  Future<bool> toggleBroadcastActive(String broadcastId, bool active) async => true;

  @override
  Future<bool> deleteBroadcastAnnouncement(String broadcastId) async => true;

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
  Future<void> deleteUserDocumentAsAdmin({
    required String uid,
    required String documentId,
  }) async {}

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {}

  @override
  Future<void> sendInactivityWarningEmail(String uid) async {}

  @override
  Future<InactivityScanResult> processInactivityPolicies() async =>
      const InactivityScanResult();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AdminUserModel userAlpha;
  late AdminUserModel userBeta;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();

    userAlpha = AdminUserModel(
      uid: 'user-alpha-123',
      email: 'alpha@example.com',
      displayName: 'Alpha Traveler',
      isPremium: true,
      createdAt: DateTime(2026, 1, 1),
      lastActiveAt: DateTime.now(),
    );

    userBeta = AdminUserModel(
      uid: 'user-beta-456',
      email: 'beta@example.com',
      displayName: 'Beta Nomad',
      isPremium: false,
      createdAt: DateTime(2026, 2, 1),
      lastActiveAt: DateTime.now(),
    );
  });

  group('Complete User Purge & System Elimination Tests', () {
    test('Purging user completely removes user from local state and updates metrics', () async {
      final mockService = MockAuditAdminService(users: [userAlpha, userBeta]);
      final controller = AdminController(mockService);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.state.allUsers.length, 2);
      expect(controller.state.metrics.totalUsers, 2);
      expect(controller.state.metrics.proUsers, 1);

      // Purge userAlpha
      final success = await controller.purgeUser('user-alpha-123');
      expect(success, isTrue);
      expect(mockService.purgeUserDataCalled, isTrue);
      expect(mockService.purgedUid, 'user-alpha-123');

      // Alpha is eradicated from state
      expect(controller.state.allUsers.length, 1);
      expect(controller.state.allUsers.any((u) => u.uid == 'user-alpha-123'), isFalse);
      expect(controller.state.allUsers.first.uid, 'user-beta-456');

      // Platform metrics decreased
      expect(controller.state.metrics.totalUsers, 1);
      expect(controller.state.metrics.proUsers, 0);

      // Audit log was automatically created and is present in state
      expect(controller.state.auditLogs.length, 1);
      final log = controller.state.auditLogs.first;
      expect(log.action, 'purge_user');
      expect(log.category, 'deletion');
      expect(log.targetUid, 'user-alpha-123');
      expect(log.targetUserEmail, 'alpha@example.com');
      expect(log.actionTitle, 'Kullanıcı ve Tüm Verileri Kalıcı Olarak Silindi');
    });
  });

  group('Real Live Admin Audit & Action Log Tracking Tests', () {
    test('All moderation operations create distinct, categorizable audit records', () async {
      final mockService = MockAuditAdminService(users: [userAlpha, userBeta]);
      final controller = AdminController(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      // 1. Ban userBeta
      await controller.updateUserModeration(
        uid: 'user-beta-456',
        isPremium: false,
        banStatus: 'banned',
        banReason: 'Spam behaviors',
        restrictedFeatures: const ['vault', 'trips'],
      );

      // 2. Send warning to userBeta
      await controller.sendUserWarning(
        uid: 'user-beta-456',
        title: 'Topluluk Kuralları Uyarısı',
        message: 'Lütfen kurallara uyunuz.',
        warningType: 'custom',
      );

      // 3. Grant Pro to userBeta
      await controller.toggleUserProStatus('user-beta-456', true);

      // 4. Send mass broadcast announcement
      await controller.sendBroadcastAnnouncement(
        title: 'Bahar İndirimi %50',
        message: 'Yıllık pakette geçerli %50 fırsat!',
        discountPercent: 50,
      );

      // 5. Purge userBeta
      await controller.purgeUser('user-beta-456');

      expect(controller.state.auditLogs.length, 5);

      // Verify category filtering
      controller.setAuditLogFilter('deletion');
      expect(controller.state.filteredAuditLogs.length, 1);
      expect(controller.state.filteredAuditLogs.first.action, 'purge_user');

      controller.setAuditLogFilter('ban');
      expect(controller.state.filteredAuditLogs.length, 1);
      expect(controller.state.filteredAuditLogs.first.action, 'ban_user');

      controller.setAuditLogFilter('warning');
      expect(controller.state.filteredAuditLogs.length, 1);
      expect(controller.state.filteredAuditLogs.first.action, 'send_warning');

      controller.setAuditLogFilter('pro');
      expect(controller.state.filteredAuditLogs.length, 1);
      expect(controller.state.filteredAuditLogs.first.action, 'pro_grant');

      controller.setAuditLogFilter('broadcast');
      expect(controller.state.filteredAuditLogs.length, 1);
      expect(controller.state.filteredAuditLogs.first.action, 'broadcast_sent');

      controller.setAuditLogFilter('all');
      expect(controller.state.filteredAuditLogs.length, 5);
    });
  });

  group('Admin Dashboard Audit Trail Widget UI Tests', () {
    testWidgets('Renders Yönetici Aksiyon & Denetim Günlüğü card and filters logs', (tester) async {
      tester.view.physicalSize = const Size(1000, 4800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockService = MockAuditAdminService(users: [userAlpha, userBeta]);

      // Prepopulate an audit log
      await mockService.recordAuditLog(
        action: 'ban_user',
        actionTitle: 'Kullanıcı Kalıcı Olarak Engellendi',
        targetUid: 'user-alpha-123',
        targetUserEmail: 'alpha@example.com',
        details: {'banReason': 'Test ban'},
      );
      await mockService.recordAuditLog(
        action: 'purge_user',
        actionTitle: 'Kullanıcı ve Tüm Verileri Kalıcı Olarak Silindi',
        targetUid: 'user-deleted-999',
        targetUserEmail: 'ghost@example.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminServiceProvider.overrideWithValue(mockService),
            isAdminProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: AdminDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Card Header exists
      expect(find.text('Yönetici Aksiyon & Denetim Günlüğü'), findsOneWidget);
      expect(find.text('2 Kayıt'), findsWidgets);

      // Audit log entries rendered
      expect(find.text('Kullanıcı Kalıcı Olarak Engellendi'), findsOneWidget);
      expect(find.text('Kullanıcı ve Tüm Verileri Kalıcı Olarak Silindi'), findsOneWidget);
      expect(find.text('ghost@example.com'), findsOneWidget);

      // Filter chip 'Silmeler'
      final silmelerChip = find.widgetWithText(ChoiceChip, 'Silmeler (1)');
      expect(silmelerChip, findsOneWidget);
      await tester.tap(silmelerChip);
      await tester.pumpAndSettle();

      // Only purge log is shown
      expect(find.text('Kullanıcı ve Tüm Verileri Kalıcı Olarak Silindi'), findsOneWidget);
      expect(find.text('Kullanıcı Kalıcı Olarak Engellendi'), findsNothing);
    });
  });
}

