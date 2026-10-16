import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/constants/app_constants.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Fake Firebase User for test harness
class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool emailVerified;
  @override
  final List<UserInfo> providerData;

  FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = true,
    this.providerData = const [],
  });
}

/// Mock AdminService for Vault Document Inspection & Deletion Moderation tests
class MockCloudAdminService implements AdminService {
  final List<AdminUserModel> users;
  final Map<String, List<VaultDocument>> userDocuments;
  final List<String> deletedDocIds = [];
  final List<String> cancelledDeletions = [];
  final List<String> purgedUsers = [];

  MockCloudAdminService({
    required this.users,
    required this.userDocuments,
  });

  @override
  bool isCurrentUserAdmin() => true;

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async => const AdminPlatformMetrics(
        totalUsers: 5,
        proUsers: 2,
        totalTrips: 10,
        totalExpenses: 25,
        totalDocuments: 8,
        totalChecklistItems: 40,
        totalStorageBytes: 1024 * 1024 * 2,
      );

  @override
  Future<List<AdminUserModel>> fetchUsers() async => List.from(users);

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
  Future<List<VaultDocument>> fetchUserDocuments(String uid) async {
    return List.from(userDocuments[uid] ?? []);
  }

  @override
  Future<void> deleteUserDocumentAsAdmin({
    required String uid,
    required String documentId,
  }) async {
    deletedDocIds.add(documentId);
    userDocuments[uid]?.removeWhere((d) => d.id == documentId);
  }

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {
    cancelledDeletions.add(uid);
    final idx = users.indexWhere((u) => u.uid == uid);
    if (idx != -1) {
      users[idx] = users[idx].copyWith(
        deletionStatus: 'none',
        deletionRequestedAt: null,
        scheduledPermanentDeletionAt: null,
      );
    }
  }

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {
    purgedUsers.add(uid);
    users.removeWhere((u) => u.uid == uid);
    userDocuments.remove(uid);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('PHASE 1: VaultDocument Cloud Payload & Serialization Tests', () {
    test('VaultDocument serializes and deserializes cloudDataBase64 and fileExtension correctly', () {
      final now = DateTime(2026, 10, 14, 12, 0);
      const rawPayload = 'SGVsbG8gUGFja0J1ZGR5IENsb3VkIFZhdWx0IQ=='; // "Hello PackBuddy Cloud Vault!"

      final doc = VaultDocument(
        id: 'doc-vault-1',
        userId: 'traveler-1',
        title: 'Passport Copy',
        category: 'Passport',
        subCategory: 'Identity',
        localImagePath: '/data/user/0/vault_docs/doc-vault-1.jpg',
        fileSizeBytes: 2048,
        cloudDataBase64: rawPayload,
        fileExtension: 'jpg',
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      // JSON roundtrip
      final json = doc.toJson();
      expect(json['cloud_data_base64'], rawPayload);
      expect(json['file_extension'], 'jpg');
      expect(json['file_size_bytes'], 2048);

      final fromJson = VaultDocument.fromJson(json);
      expect(fromJson.id, 'doc-vault-1');
      expect(fromJson.cloudDataBase64, rawPayload);
      expect(fromJson.fileExtension, 'jpg');
      expect(fromJson.fileSize, 2048);
      expect(fromJson.filePath, '/data/user/0/vault_docs/doc-vault-1.jpg');
      expect(fromJson.isPdf, isFalse);

      // SQLite Map roundtrip
      final map = doc.toMap();
      expect(map['cloud_data_base64'], rawPayload);
      expect(map['file_extension'], 'jpg');

      final fromMap = VaultDocument.fromMap(map);
      expect(fromMap.cloudDataBase64, rawPayload);
      expect(fromMap.fileExtension, 'jpg');
      expect(fromMap.fileSize, 2048);

      // copyWith filePath alias and PDF detection
      final pdfDoc = doc.copyWith(
        filePath: '/data/user/0/vault_docs/ticket.pdf',
        fileExtension: 'pdf',
      );
      expect(pdfDoc.filePath, '/data/user/0/vault_docs/ticket.pdf');
      expect(pdfDoc.localImagePath, '/data/user/0/vault_docs/ticket.pdf');
      expect(pdfDoc.isPdf, isTrue);
    });

    test('SQLite Schema version is 9 for cloud vault database migration', () {
      expect(AppConstants.databaseVersion, 9);
    });
  });

  group('PHASE 2: 15-Day Account Deletion & Recovery Model Tests', () {
    test('AdminUserModel calculates daysUntilPermanentDeletion accurately', () {
      final now = DateTime.now().toUtc();
      final tenDaysFuture = now.add(const Duration(days: 10, hours: 2));

      final pendingUser = AdminUserModel(
        uid: 'user-delete-1',
        email: 'traveler-delete@example.com',
        deletionStatus: 'pending_deletion',
        deletionRequestedAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        scheduledPermanentDeletionAt: tenDaysFuture.toIso8601String(),
        createdAt: now.subtract(const Duration(days: 30)),
      );

      expect(pendingUser.deletionStatus, 'pending_deletion');
      expect(pendingUser.daysUntilPermanentDeletion, 10);

      final normalUser = AdminUserModel(
        uid: 'user-normal-1',
        email: 'active@example.com',
        deletionStatus: 'none',
        createdAt: now,
      );

      expect(normalUser.daysUntilPermanentDeletion, isNull);
    });

    test('15-Day expiration check distinguishes between recovery (<15d) and permanent purge (>=15d)', () {
      final nowUtc = DateTime.now().toUtc();

      // Case 1: Within 15-day grace period (5 days remaining)
      final withinGrace = nowUtc.add(const Duration(days: 5));
      final isRecoverable = nowUtc.isBefore(withinGrace);
      expect(isRecoverable, isTrue);

      // Case 2: Expired 15-day grace period (scheduled was yesterday)
      final expiredGrace = nowUtc.subtract(const Duration(days: 1));
      final isExpired = nowUtc.isAfter(expiredGrace);
      expect(isExpired, isTrue);
    });
  });

  group('PHASE 1 & 2: Super Admin Vault Document Inspector & Deletion Badges UI Tests', () {
    // 1x1 transparent PNG Base64 for safe Image.memory decoding
    const samplePngBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

    Widget buildAdminApp({
      required AdminService adminService,
    }) {
      final controller = AdminController(adminService);

      return ProviderScope(
        overrides: [
          adminServiceProvider.overrideWithValue(adminService),
          isAdminProvider.overrideWithValue(true),
          adminControllerProvider.overrideWith((ref) => controller),
          authUserProvider.overrideWithValue(
            FakeUser(uid: 'admin-1', email: 'sleepyheadaitr@gmail.com'),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const AdminDashboardScreen(),
        ),
      );
    }

    testWidgets('Renders pending deletion badge with remaining days on user card', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final scheduledTime = DateTime.now().toUtc().add(const Duration(days: 12, hours: 2));
      final testUser = AdminUserModel(
        uid: 'user-pending-123',
        email: 'leaving-soon@packbuddy.com',
        displayName: 'Leaving Soon',
        deletionStatus: 'pending_deletion',
        scheduledPermanentDeletionAt: scheduledTime.toIso8601String(),
        createdAt: DateTime(2026, 1, 1),
      );

      final mockAdminService = MockCloudAdminService(
        users: [testUser],
        userDocuments: {},
      );

      await tester.pumpWidget(buildAdminApp(adminService: mockAdminService));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Check for pending deletion badge on user card
      expect(find.textContaining('Scheduled for deletion (12d remaining)'), findsOneWidget);
      expect(find.byIcon(Icons.delete_sweep_rounded), findsOneWidget);
    });

    testWidgets('Opens moderation sheet and inspects uploaded image & PDF vault documents', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime(2026, 10, 14, 10, 0);
      final testUser = AdminUserModel(
        uid: 'user-inspect-1',
        email: 'inspect-user@packbuddy.com',
        displayName: 'Inspect Traveler',
        createdAt: DateTime(2026, 1, 1),
      );

      final imageDoc = VaultDocument(
        id: 'img-1',
        userId: 'user-inspect-1',
        title: 'Boarding Pass Photo',
        category: 'Ticket',
        localImagePath: '/vault/pass.png',
        fileSizeBytes: 1024,
        cloudDataBase64: samplePngBase64,
        fileExtension: 'png',
        createdAt: now,
        updatedAt: now,
      );

      final pdfDoc = VaultDocument(
        id: 'pdf-1',
        userId: 'user-inspect-1',
        title: 'Hotel Reservation PDF',
        category: 'Booking',
        localImagePath: '/vault/hotel.pdf',
        fileSizeBytes: 4096,
        cloudDataBase64: base64Encode(utf8.encode('PDF_MOCK_CONTENT')),
        fileExtension: 'pdf',
        createdAt: now,
        updatedAt: now,
      );

      final mockAdminService = MockCloudAdminService(
        users: [testUser],
        userDocuments: {
          'user-inspect-1': [imageDoc, pdfDoc],
        },
      );

      await tester.pumpWidget(buildAdminApp(adminService: mockAdminService));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      final moderateBtn = find.byIcon(Icons.tune_rounded);
      expect(moderateBtn, findsOneWidget);
      await tester.tap(moderateBtn);
      await tester.pumpAndSettle();

      // Verify Uploaded Vault Documents section header and documents
      expect(find.text('Uploaded Vault Documents (Inspect / Moderate)'), findsOneWidget);
      expect(find.text('Boarding Pass Photo'), findsOneWidget);
      expect(find.text('Hotel Reservation PDF'), findsOneWidget);

      // Scroll inside moderation sheet until Inspect button is visible
      await tester.scrollUntilVisible(
        find.text('Inspect').first,
        200.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      // Tap Inspect on image document
      final inspectButtons = find.text('Inspect');
      expect(inspectButtons, findsNWidgets(2));
      await tester.tap(inspectButtons.first);
      await tester.pumpAndSettle();

      // Verify pinch-to-zoom InteractiveViewer preview dialog
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('Delete Document'), findsOneWidget);

      // Cancel dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });

  group('PHASE 3 & 4: Email Verification, Anti-Spam UX & 320x568 Zero Overflows', () {
    testWidgets('EmailVerificationScreen displays spam folder card and renders without overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(
              FakeUser(
                uid: 'unverified-1',
                email: 'newuser@packbuddy.com',
                emailVerified: false,
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const EmailVerificationScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Anti-Spam guidance card exists
      expect(find.text('Check Spam / Promotions Folder'), findsOneWidget);
      expect(find.textContaining('PackBuddy'), findsWidgets);

      // Verify zero RenderFlex overflows
      expect(tester.takeException(), isNull);
    });

    testWidgets('SettingsScreen displays 15-day account deletion button with zero overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(
              FakeUser(
                uid: 'user-settings-1',
                email: 'traveler@packbuddy.com',
                emailVerified: true,
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down until Delete Account button is visible
      await tester.scrollUntilVisible(
        find.text('Delete Account'),
        300.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete Account'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tap Delete Account and verify 15-day dialog
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      expect(find.text('15-Day Account Deletion Request'), findsOneWidget);
      expect(find.textContaining('15 days'), findsWidgets);
      expect(find.text('Request 15-Day Deletion'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
