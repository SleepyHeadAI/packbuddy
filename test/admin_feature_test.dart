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
      tester.view.physicalSize = const Size(800, 1600);
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
  });
}
