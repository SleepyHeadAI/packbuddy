import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Fake Firebase [User] for testing
class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  FakeUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}

/// Mock [AdminService] implementation for testing
class MockAdminService implements AdminService {
  AdminPlatformMetrics metricsToReturn = const AdminPlatformMetrics(
    totalUsers: 42,
    verifiedUsers: 30,
    proUsers: 15,
    totalTrips: 88,
    totalExpenses: 210,
    totalDocuments: 35,
    totalChecklistItems: 340,
  );

  List<AdminUserModel> usersToReturn = [
    AdminUserModel(
      uid: 'user-admin-1',
      email: 'sleepyheadaitr@gmail.com',
      displayName: 'SleepyHead Admin',
      emailVerified: true,
      isPremium: true,
      provider: 'google.com',
      lastLoginAt: DateTime(2026, 10, 13, 14, 30),
      createdAt: DateTime(2026, 1, 1),
    ),
    AdminUserModel(
      uid: 'user-2',
      email: 'traveler@example.com',
      displayName: 'Alice Traveler',
      emailVerified: true,
      isPremium: false,
      provider: 'password',
      lastLoginAt: DateTime(2026, 10, 12, 10, 15),
      createdAt: DateTime(2026, 2, 1),
    ),
    AdminUserModel(
      uid: 'user-3',
      email: 'bob@nomad.com',
      displayName: 'Bob Nomad',
      emailVerified: false,
      isPremium: true,
      provider: 'apple.com',
      lastLoginAt: DateTime(2026, 10, 11, 9, 0),
      createdAt: DateTime(2026, 3, 1),
    ),
  ];

  final List<Map<String, dynamic>> toggledCalls = [];
  bool shouldThrowOnFetch = false;
  bool shouldThrowOnToggle = false;

  @override
  bool isCurrentUserAdmin() => true;

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async {
    if (shouldThrowOnFetch) {
      throw Exception('Network error fetching metrics');
    }
    return metricsToReturn;
  }

  @override
  Future<List<AdminUserModel>> fetchUsers() async {
    if (shouldThrowOnFetch) {
      throw Exception('Network error fetching users');
    }
    return List.from(usersToReturn);
  }

  AdminDetailedAnalytics analyticsToReturn = const AdminDetailedAnalytics(
    topWishlistCountries: [
      CountryTravelMetric(
        countryCode: 'JP',
        countryName: 'Japonya',
        flag: '🇯🇵',
        count: 12,
        percentage: 0.4,
        continent: 'Asia',
      ),
      CountryTravelMetric(
        countryCode: 'IT',
        countryName: 'İtalya',
        flag: '🇮🇹',
        count: 8,
        percentage: 0.26,
        continent: 'Europe',
      ),
    ],
    topVisitedCountries: [
      CountryTravelMetric(
        countryCode: 'FR',
        countryName: 'Fransa',
        flag: '🇫🇷',
        count: 15,
        percentage: 0.5,
        continent: 'Europe',
      ),
    ],
    topLivedCountries: [
      CountryTravelMetric(
        countryCode: 'TR',
        countryName: 'Türkiye',
        flag: '🇹🇷',
        count: 25,
        percentage: 0.6,
        continent: 'Europe',
      ),
    ],
    continentShares: [
      ContinentShareMetric(
        continentName: 'Europe',
        icon: '🇪🇺',
        count: 20,
        percentage: 0.65,
      ),
      ContinentShareMetric(
        continentName: 'Asia',
        icon: '⛩️',
        count: 10,
        percentage: 0.35,
      ),
    ],
    transportPreferences: [
      TransportPreferenceMetric(
        mode: 'plane',
        label: 'Uçak',
        icon: '✈️',
        count: 18,
        percentage: 0.72,
      ),
    ],
    currencyShares: [
      CurrencyShareMetric(
        currencyCode: 'USD',
        count: 14,
        percentage: 0.56,
      ),
    ],
    vaultCategories: [
      VaultCategoryShareMetric(
        category: 'passport',
        label: 'Pasaport',
        count: 10,
        percentage: 0.5,
      ),
    ],
    totalPlatformSessionSeconds: 15400,
    totalPlatformSessions: 30,
    averageSessionDurationSeconds: 513.3,
    averageTripDurationDays: 5.5,
    averageExpensePerTrip: 320.0,
    proConversionRate: 0.357,
    emailVerificationRate: 0.714,
  );

  @override
  Future<AdminDetailedAnalytics> fetchDetailedAnalytics() async {
    if (shouldThrowOnFetch) {
      throw Exception('Network error fetching analytics');
    }
    return analyticsToReturn;
  }

  @override
  Future<void> toggleUserProStatus(String uid, bool isPremium) async {
    if (shouldThrowOnToggle) {
      throw Exception('Failed to toggle pro status');
    }
    toggledCalls.add({'uid': uid, 'isPremium': isPremium});
    final index = usersToReturn.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      usersToReturn[index] = usersToReturn[index].copyWith(isPremium: isPremium);
    }
  }

  final List<Map<String, dynamic>> moderationCalls = [];

  @override
  Future<void> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  }) async {
    moderationCalls.add({
      'uid': uid,
      'isPremium': isPremium,
      'banStatus': banStatus,
      'banExpiresAt': banExpiresAt,
      'banReason': banReason,
      'restrictedFeatures': restrictedFeatures,
    });
    final index = usersToReturn.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      usersToReturn[index] = usersToReturn[index].copyWith(
        isPremium: isPremium,
        banStatus: banStatus,
        banExpiresAt: banExpiresAt,
        banReason: banReason,
        restrictedFeatures: restrictedFeatures,
      );
    }
  }

  @override
  Future<List<VaultDocument>> fetchUserDocuments(String uid) async {
    return [];
  }

  @override
  Future<void> deleteUserDocumentAsAdmin({required String uid, required String documentId}) async {}

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {}

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {
    usersToReturn.removeWhere((u) => u.uid == uid);
  }

  final List<String> warningEmailCalls = [];
  bool processPoliciesCalled = false;

  @override
  Future<void> sendInactivityWarningEmail(String uid) async {
    warningEmailCalls.add(uid);
    final index = usersToReturn.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      usersToReturn[index] = usersToReturn[index].copyWith(
        lastInactivityWarningAt: DateTime.now(),
        inactivityWarningCount: usersToReturn[index].inactivityWarningCount + 1,
      );
    }
  }

  final List<Map<String, dynamic>> sentWarnings = [];

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
      'sendInApp': sendInAppNotification,
      'sendEmail': sendEmail,
    });
    return true;
  }

  @override
  Future<InactivityScanResult> processInactivityPolicies() async {
    processPoliciesCalled = true;
    final now = DateTime.now();
    int warningsSent = 0;
    int accountsPurged = 0;
    final List<String> warningEmails = [];
    final List<String> purgedEmails = [];

    final activeList = List<AdminUserModel>.from(usersToReturn);
    for (final user in activeList) {
      if (user.uid == 'user-admin-1') continue;
      if (user.is6thMonthPurgeReady) {
        accountsPurged++;
        purgedEmails.add(user.email);
        usersToReturn.removeWhere((u) => u.uid == user.uid);
      } else if (user.is5thMonthWarningPeriod) {
        warningsSent++;
        warningEmails.add(user.email);
        final idx = usersToReturn.indexWhere((u) => u.uid == user.uid);
        if (idx != -1) {
          usersToReturn[idx] = usersToReturn[idx].copyWith(
            lastInactivityWarningAt: now,
            inactivityWarningCount: usersToReturn[idx].inactivityWarningCount + 1,
          );
        }
      }
    }

    return InactivityScanResult(
      totalScanned: activeList.length,
      warningsSent: warningsSent,
      accountsPurged: accountsPurged,
      warningUserEmails: warningEmails,
      purgedUserEmails: purgedEmails,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdminPlatformMetrics Model Tests', () {
    test('Default values and custom constructor', () {
      const defaultMetrics = AdminPlatformMetrics();
      expect(defaultMetrics.totalUsers, 0);
      expect(defaultMetrics.verifiedUsers, 0);
      expect(defaultMetrics.proUsers, 0);
      expect(defaultMetrics.totalTrips, 0);
      expect(defaultMetrics.totalExpenses, 0);
      expect(defaultMetrics.totalDocuments, 0);
      expect(defaultMetrics.totalChecklistItems, 0);

      const customMetrics = AdminPlatformMetrics(
        totalUsers: 100,
        verifiedUsers: 80,
        proUsers: 25,
        totalTrips: 150,
        totalExpenses: 600,
        totalDocuments: 90,
        totalChecklistItems: 1200,
      );
      expect(customMetrics.totalUsers, 100);
      expect(customMetrics.verifiedUsers, 80);
      expect(customMetrics.proUsers, 25);
      expect(customMetrics.totalTrips, 150);
      expect(customMetrics.totalExpenses, 600);
      expect(customMetrics.totalDocuments, 90);
      expect(customMetrics.totalChecklistItems, 1200);
    });

    test('copyWith works correctly', () {
      const initial = AdminPlatformMetrics(totalUsers: 10);
      final updated = initial.copyWith(proUsers: 5, totalTrips: 20);
      expect(updated.totalUsers, 10);
      expect(updated.proUsers, 5);
      expect(updated.totalTrips, 20);
    });
  });

  group('AdminUserModel Model Tests', () {
    test('fromMap parses map and timestamps correctly', () {
      final now = DateTime.now();
      final map = {
        'email': 'user@example.com',
        'displayName': 'Test User',
        'emailVerified': true,
        'isPremium': false,
        'provider': 'google.com',
        'lastLoginAt': now.toIso8601String(),
        'createdAt': now.toIso8601String(),
      };

      final model = AdminUserModel.fromMap('user-101', map);
      expect(model.uid, 'user-101');
      expect(model.email, 'user@example.com');
      expect(model.displayName, 'Test User');
      expect(model.emailVerified, true);
      expect(model.isPremium, false);
      expect(model.provider, 'google.com');
      expect(model.lastLoginAt, isNotNull);
      expect(model.createdAt, isNotNull);
    });

    test('fromMap handles null and missing fields gracefully', () {
      final model = AdminUserModel.fromMap('user-empty', {});
      expect(model.uid, 'user-empty');
      expect(model.email, '');
      expect(model.displayName, '');
      expect(model.emailVerified, false);
      expect(model.isPremium, false);
      expect(model.provider, 'password');
      expect(model.lastLoginAt, isNull);
      expect(model.createdAt, isNull);
    });

    test('copyWith updates isPremium status and fields', () {
      const initial = AdminUserModel(
        uid: 'user-001',
        email: 'alice@test.com',
        displayName: 'Alice',
        emailVerified: true,
        isPremium: false,
        provider: 'apple.com',
      );

      final updated = initial.copyWith(isPremium: true);
      expect(updated.uid, 'user-001');
      expect(updated.isPremium, true);
      expect(updated.email, 'alice@test.com');
    });

    test('Calculates inactivity metrics, 5th-month warning, and 6-month purge states correctly', () {
      final now = DateTime.now();

      // Active user (logged in 10 days ago)
      final activeUser = AdminUserModel(
        uid: 'u-active',
        email: 'active@test.com',
        lastActiveAt: now.subtract(const Duration(days: 10)),
      );
      expect(activeUser.inactiveDays, 10);
      expect(activeUser.is5thMonthWarningPeriod, isFalse);
      expect(activeUser.is6thMonthPurgeReady, isFalse);

      // 5th-month inactive user (160 days inactive)
      final warningUser = AdminUserModel(
        uid: 'u-warning',
        email: 'warning@test.com',
        lastActiveAt: now.subtract(const Duration(days: 160)),
        lastInactivityWarningAt: now.subtract(const Duration(days: 8)),
        inactivityWarningCount: 1,
      );
      expect(warningUser.inactiveDays, 160);
      expect(warningUser.is5thMonthWarningPeriod, isTrue);
      expect(warningUser.is6thMonthPurgeReady, isFalse);

      // 6-month inactive user (185 days inactive)
      final purgeReadyUser = AdminUserModel(
        uid: 'u-purge',
        email: 'purge@test.com',
        lastActiveAt: now.subtract(const Duration(days: 185)),
      );
      expect(purgeReadyUser.inactiveDays, 185);
      expect(purgeReadyUser.is5thMonthWarningPeriod, isFalse);
      expect(purgeReadyUser.is6thMonthPurgeReady, isTrue);
    });
  });

  group('isAdminProvider Access Guard Tests', () {
    test('Returns true strictly for sleepyheadaitr@gmail.com', () {
      final container = ProviderContainer(
        overrides: [
          authUserProvider.overrideWithValue(
            FakeUser(uid: 'admin-1', email: 'sleepyheadaitr@gmail.com'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isAdminProvider), isTrue);
    });

    test('Returns true for case-insensitive admin email variants', () {
      final container = ProviderContainer(
        overrides: [
          authUserProvider.overrideWithValue(
            FakeUser(uid: 'admin-2', email: 'SleepyHeadAiTR@gmail.com '),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isAdminProvider), isTrue);
    });

    test('Returns false for any other email', () {
      final container = ProviderContainer(
        overrides: [
          authUserProvider.overrideWithValue(
            FakeUser(uid: 'user-1', email: 'regular@gmail.com'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isAdminProvider), isFalse);
    });

    test('Returns false when user is unauthenticated (null)', () {
      final container = ProviderContainer(
        overrides: [
          authUserProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isAdminProvider), isFalse);
    });
  });

  group('AdminController State Management Tests', () {
    late MockAdminService mockService;

    setUp(() {
      mockService = MockAdminService();
    });

    test('Initializes and loads platform metrics & users', () async {
      final controller = AdminController(mockService);
      // Wait for async constructor load to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.metrics.totalUsers, 42);
      expect(controller.state.metrics.proUsers, 15);
      expect(controller.state.allUsers.length, 3);
    });

    test('Filters users by search query (case-insensitive)', () async {
      final controller = AdminController(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.state.filteredUsers.length, 3);

      // Search by email substring
      controller.setSearchQuery('nomad');
      expect(controller.state.filteredUsers.length, 1);
      expect(controller.state.filteredUsers.first.displayName, 'Bob Nomad');

      // Search by displayName substring
      controller.setSearchQuery('ALICE');
      expect(controller.state.filteredUsers.length, 1);
      expect(controller.state.filteredUsers.first.email, 'traveler@example.com');

      // Clear search
      controller.setSearchQuery('');
      expect(controller.state.filteredUsers.length, 3);
    });

    test('Optimistically updates user pro status and calls service', () async {
      final controller = AdminController(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      // Alice is currently isPremium = false
      final aliceBefore = controller.state.allUsers.firstWhere((u) => u.uid == 'user-2');
      expect(aliceBefore.isPremium, isFalse);

      final success = await controller.toggleUserProStatus('user-2', true);
      expect(success, isTrue);

      final aliceAfter = controller.state.allUsers.firstWhere((u) => u.uid == 'user-2');
      expect(aliceAfter.isPremium, isTrue);
      expect(mockService.toggledCalls.length, 1);
      expect(mockService.toggledCalls.first, {'uid': 'user-2', 'isPremium': true});
    });

    test('Handles service failure during toggle with rollback', () async {
      mockService.shouldThrowOnToggle = true;
      final controller = AdminController(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      final success = await controller.toggleUserProStatus('user-2', true);
      expect(success, isFalse);
      expect(controller.state.errorMessage, isNotNull);

      // Alice should have rolled back to false
      final alice = controller.state.allUsers.firstWhere((u) => u.uid == 'user-2');
      expect(alice.isPremium, isFalse);
    });

    test('Inactivity filter chips isolate 5th-month warning and 6-month purge-ready users', () async {
      final now = DateTime.now();
      mockService.usersToReturn = [
        AdminUserModel(
          uid: 'u1',
          email: 'recent@test.com',
          lastActiveAt: now.subtract(const Duration(days: 5)),
        ),
        AdminUserModel(
          uid: 'u2',
          email: 'warning@test.com',
          lastActiveAt: now.subtract(const Duration(days: 155)),
        ),
        AdminUserModel(
          uid: 'u3',
          email: 'purge@test.com',
          lastActiveAt: now.subtract(const Duration(days: 190)),
        ),
      ];

      final controller = AdminController(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.state.filteredUsers.length, 3);

      controller.setUserFilter(UserFilterChip.inactive5thMonth);
      expect(controller.state.filteredUsers.length, 1);
      expect(controller.state.filteredUsers.first.email, 'warning@test.com');

      controller.setUserFilter(UserFilterChip.inactive6thMonth);
      expect(controller.state.filteredUsers.length, 1);
      expect(controller.state.filteredUsers.first.email, 'purge@test.com');
    });

    test('sendInactivityWarning increments warning count and updates timestamp', () async {
      final now = DateTime.now();
      mockService.usersToReturn = [
        AdminUserModel(
          uid: 'u-warn-test',
          email: 'warn@test.com',
          lastActiveAt: now.subtract(const Duration(days: 152)),
          inactivityWarningCount: 0,
        ),
      ];

      final controller = AdminController(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      final success = await controller.sendInactivityWarning('u-warn-test');
      expect(success, isTrue);
      expect(mockService.warningEmailCalls.contains('u-warn-test'), isTrue);

      final user = controller.state.allUsers.firstWhere((u) => u.uid == 'u-warn-test');
      expect(user.inactivityWarningCount, 1);
      expect(user.lastInactivityWarningAt, isNotNull);
    });

    test('runInactivityScan purges 6+ month inactive accounts and warns 5th-month users', () async {
      final now = DateTime.now();
      mockService.usersToReturn = [
        AdminUserModel(
          uid: 'u-active',
          email: 'active@test.com',
          lastActiveAt: now.subtract(const Duration(days: 20)),
        ),
        AdminUserModel(
          uid: 'u-warn',
          email: 'warn@test.com',
          lastActiveAt: now.subtract(const Duration(days: 160)),
        ),
        AdminUserModel(
          uid: 'u-purge',
          email: 'purge@test.com',
          lastActiveAt: now.subtract(const Duration(days: 185)),
        ),
      ];

      final controller = AdminController(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      final result = await controller.runInactivityScan();
      expect(result, isNotNull);
      expect(result!.totalScanned, 3);
      expect(result.warningsSent, 1);
      expect(result.accountsPurged, 1);
      expect(result.warningUserEmails, contains('warn@test.com'));
      expect(result.purgedUserEmails, contains('purge@test.com'));

      // In controller state, purged user should be gone and warning user should have incremented warning
      expect(controller.state.allUsers.any((u) => u.uid == 'u-purge'), isFalse);
      final warnedUser = controller.state.allUsers.firstWhere((u) => u.uid == 'u-warn');
      expect(warnedUser.inactivityWarningCount, 1);
    });
  });

  group('Admin Dashboard & Settings UI Widget Tests', () {
    Widget buildTestApp({
      required Widget child,
      required bool isAdmin,
      AdminController? customController,
    }) {
      final mockService = MockAdminService();
      final controller = customController ?? AdminController(mockService);

      return ProviderScope(
        overrides: [
          isAdminProvider.overrideWithValue(isAdmin),
          adminControllerProvider.overrideWith((ref) => controller),
          authUserProvider.overrideWithValue(
            isAdmin
                ? FakeUser(uid: 'admin-1', email: 'sleepyheadaitr@gmail.com')
                : FakeUser(uid: 'user-1', email: 'user@example.com'),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: child,
        ),
      );
    }

    testWidgets('Non-admin access restriction screen is rendered when !isAdmin',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const AdminDashboardScreen(),
          isAdmin: false,
        ),
      );
      await tester.pumpAndSettle();

      // Access restricted icon and message should be visible
      expect(find.byIcon(Icons.gpp_bad_rounded), findsOneWidget);
      expect(find.text('Access Restricted'), findsOneWidget);

      // Metric grid and user management must NOT be rendered
      expect(find.text('Platform Metrics'), findsNothing);
      expect(find.text('User Management'), findsNothing);
    });

    testWidgets('Admin dashboard renders platform metrics and user cards when isAdmin',
        (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockService = MockAdminService();
      final controller = AdminController(mockService);

      await tester.pumpWidget(
        buildTestApp(
          child: const AdminDashboardScreen(),
          isAdmin: true,
          customController: controller,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Executive dashboard header & title
      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('Platform Metrics'), findsOneWidget);

      // Metric values from MockAdminService
      expect(find.text('42'), findsOneWidget); // Total Users
      expect(find.text('15'), findsOneWidget); // Pro Subscribers
      expect(find.text('88'), findsOneWidget); // Trips
      expect(find.text('35'), findsOneWidget); // Total Docs
      expect(find.textContaining('340'), findsOneWidget); // Total Items

      // User cards
      expect(find.text('SleepyHead Admin'), findsOneWidget);
      expect(find.text('Alice Traveler'), findsOneWidget);
      expect(find.text('Bob Nomad'), findsOneWidget);

      // Search functionality
      await tester.enterText(find.byType(TextField), 'Alice');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Alice Traveler'), findsOneWidget);
      expect(find.text('Bob Nomad'), findsNothing);
    });

    testWidgets('Settings screen conditionally displays Admin Dashboard banner',
        (tester) async {
      // 1. When non-admin: Banner should NOT be present
      await tester.pumpWidget(
        buildTestApp(
          child: const SettingsScreen(),
          isAdmin: false,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('EXECUTIVE'), findsNothing);

      // 2. When admin: Banner should be visible
      await tester.pumpWidget(
        buildTestApp(
          child: const SettingsScreen(),
          isAdmin: true,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('EXECUTIVE'), findsOneWidget);
      expect(find.byIcon(Icons.admin_panel_settings_rounded), findsWidgets);
    });

    testWidgets('Admin dashboard renders Detailed Analytics Hub & Country Demand tabs',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockService = MockAdminService();
      final controller = AdminController(mockService);

      await tester.pumpWidget(
        buildTestApp(
          child: const AdminDashboardScreen(),
          isAdmin: true,
          customController: controller,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Usage & Session Analytics card
      expect(find.textContaining('Session Analytics'), findsOneWidget);
      expect(find.text('8 dk 33 sn'), findsOneWidget); // Avg session duration
      expect(find.text('4.3 sa'), findsOneWidget); // Total platform duration
      expect(find.text('5.5 gün'), findsWidgets); // Avg trip length
      expect(find.text('\$320'), findsWidgets); // Avg expense

      // Country Demand Hub tabs
      expect(find.text('🌟 Wishlist'), findsOneWidget);
      expect(find.text('✈️ Visited'), findsOneWidget);
      expect(find.text('🏠 Residence'), findsOneWidget);
      expect(find.text('🌍 Continents'), findsOneWidget);

      // Default active tab: Wishlist -> Shows Japonya & İtalya
      expect(find.text('Japonya'), findsOneWidget);
      expect(find.text('İtalya'), findsOneWidget);

      // Switch to Visited tab
      await tester.tap(find.text('✈️ Visited'));
      await tester.pump(const Duration(milliseconds: 100));

      // In visited tab: Shows Fransa
      expect(find.text('Fransa'), findsOneWidget);

      // Switch to Residence tab
      await tester.tap(find.text('🏠 Residence'));
      await tester.pump(const Duration(milliseconds: 100));

      // In residence tab: Shows Türkiye
      expect(find.text('Türkiye'), findsOneWidget);

      // Switch to Continents tab
      await tester.tap(find.text('🌍 Continents'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('Asia'), findsOneWidget);

      // Transport preferences
      expect(find.text('Uçak'), findsOneWidget);
    });
  });
}
