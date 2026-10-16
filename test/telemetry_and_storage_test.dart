import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/services/telemetry_service.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

// =============================================================================
// TEST DOUBLES
// =============================================================================

class FakeUser extends Fake implements User {
  @override
  final String uid = 'test-telemetry-admin-uid';
  @override
  final String? email = 'sleepyheadaitr@gmail.com';
  @override
  final String? displayName = 'Telemetry Admin';
  @override
  final bool emailVerified = true;
  @override
  final List<UserInfo> providerData = const [];
}

class FakeAdminController extends StateNotifier<AdminState>
    implements AdminController {
  FakeAdminController(super.state);

  @override
  Future<void> refreshData() async {}

  @override
  Future<void> loadUsers() async {}

  @override
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  @override
  Future<bool> toggleUserProStatus(String uid, bool isPremium) async {
    return true;
  }

  @override
  void setAnalyticsPeriod(AnalyticsPeriod period) {
    state = state.copyWith(analyticsPeriod: period);
  }

  @override
  void setUserFilter(UserFilterChip filter) {
    state = state.copyWith(userFilter: filter);
  }

  @override
  Future<bool> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  }) async {
    return true;
  }

  @override
  void clearError() {}
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('tr', null);
    await initializeDateFormatting('de', null);
    await initializeDateFormatting('ru', null);
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 2 & 4: TelemetryService & Test-Safety', () {
    late TelemetryService telemetry;

    setUp(() {
      telemetry = TelemetryService.instance;
      telemetry.clearTestHistory();
    });

    test('TelemetryService singleton and provider access', () {
      expect(telemetry, isNotNull);
      final container = ProviderContainer();
      final fromProvider = container.read(telemetryServiceProvider);
      expect(identical(telemetry, fromProvider), isTrue);
      container.dispose();
    });

    test('TelemetryService wraps PostHog calls safely without platform crashes', () async {
      // In headless unit test environment, native platform channels do not exist.
      // Every TelemetryService call must succeed gracefully and record to testHistory.
      await telemetry.identifyUser(
        uid: 'user-telemetry-123',
        email: 'traveler@packbuddy.app',
        displayName: 'Pack Traveler',
        isPro: true,
        totalStorageBytes: 1048576,
        locale: 'tr',
      );

      expect(telemetry.testHistory.length, 1);
      final identifyEvent = telemetry.testHistory.first;
      expect(identifyEvent.name, r'$identify');
      final props = identifyEvent.properties!;
      expect(props['user_id'], 'user-telemetry-123');
      expect(props['email'], 'traveler@packbuddy.app');
      expect(props['name'], 'Pack Traveler');
      expect(props['is_pro'], true);
      expect(props['project_id'], 305038);
      expect(props['total_storage_bytes'], 1048576);
      expect(props['locale'], 'tr');

      await telemetry.resetUser();
      expect(telemetry.testHistory.length, 2);
      expect(telemetry.testHistory.last.name, r'$reset');
    });

    test('TelemetryService captures all 9 feature & funnel events', () {
      telemetry.logScreen('TripsOverviewScreen', properties: {'tab': 'active'});
      telemetry.logTripCreated(
        destination: 'Tokyo, Japan',
        transportMode: 'flight',
        budget: 2500.0,
        currency: 'USD',
      );
      telemetry.logExpenseLogged(
        category: 'Food',
        amount: 45.5,
        currency: 'USD',
      );
      telemetry.logChecklistAction(
        action: 'pack',
        category: 'Clothing',
        itemCount: 3,
      );
      telemetry.logDocumentUploaded(
        category: 'Passport',
        fileSizeBytes: 204800,
        fileExtension: 'pdf',
      );
      telemetry.logPaywallViewed(triggerSource: 'vault_limit');
      telemetry.logProStatusChanged(isPro: true, source: 'annual_purchase');
      telemetry.logPreferenceChanged(setting: 'theme_mode', value: 'dark');
      telemetry.logAdminAction(action: 'grant_pro', targetUid: 'user-789');

      expect(telemetry.testHistory.length, 9);

      final eventNames = telemetry.testHistory.map((e) => e.name).toList();
      expect(eventNames, [
        r'$screen',
        'trip_created',
        'expense_logged',
        'checklist_action',
        'document_uploaded',
        'paywall_viewed',
        'pro_status_changed',
        'preference_changed',
        'admin_action',
      ]);

      // Verify payloads
      final tripEvt = telemetry.testHistory[1].properties!;
      expect(tripEvt['destination'], 'Tokyo, Japan');
      expect(tripEvt['transport_mode'], 'flight');
      expect(tripEvt['budget'], 2500.0);
      expect(tripEvt['currency'], 'USD');

      final docEvt = telemetry.testHistory[4].properties!;
      expect(docEvt['category'], 'Passport');
      expect(docEvt['file_size_bytes'], 204800);
      expect(docEvt['file_extension'], 'pdf');
    });
  });

  group('Phase 3 & 4: Vault Storage Metering & Admin Platform Metrics', () {
    test('VaultDocument fileSizeBytes serialization and copyWith', () {
      final docDefault = VaultDocument(
        id: 'doc-1',
        title: 'Passport Copy',
        category: 'Passports',
        localImagePath: '/storage/passport.png',
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );
      expect(docDefault.fileSizeBytes, 0);

      final docWithBytes = docDefault.copyWith(fileSizeBytes: 450000);
      expect(docWithBytes.fileSizeBytes, 450000);

      // toMap & fromMap (SQLite)
      final map = docWithBytes.toMap();
      expect(map['file_size_bytes'], 450000);
      final fromDb = VaultDocument.fromMap(map);
      expect(fromDb.fileSizeBytes, 450000);

      // toJson & fromJson (Firestore/Cloud)
      final json = docWithBytes.toJson();
      expect(json['fileSizeBytes'], 450000);
      final fromCloud = VaultDocument.fromJson(json);
      expect(fromCloud.fileSizeBytes, 450000);
    });

    test('formatStorageBytes formats various byte ranges cleanly', () {
      expect(formatStorageBytes(0), '0 B');
      expect(formatStorageBytes(512), '512 B');
      expect(formatStorageBytes(1024), '1 KB');
      expect(formatStorageBytes(450 * 1024), '450 KB');
      expect(formatStorageBytes((3.2 * 1024 * 1024).round()), '3.2 MB');
      expect(formatStorageBytes((1.5 * 1024 * 1024 * 1024).round()), '1.5 GB');
    });

    test('AdminUserModel & AdminPlatformMetrics storage parsing and aggregation', () {
      final userMap = {
        'email': 'traveler@packbuddy.app',
        'displayName': 'Traveler Max',
        'emailVerified': true,
        'isPremium': true,
        'provider': 'google.com',
        'totalVaultStorageBytes': 5242880, // 5 MB
        'createdAt': '2026-01-01T00:00:00.000Z',
      };

      final user = AdminUserModel.fromMap('user-1', userMap);
      expect(user.totalVaultStorageBytes, 5242880);

      final metrics = const AdminPlatformMetrics().copyWith(
        totalUsers: 1,
        totalStorageBytes: 5242880,
      );
      expect(metrics.totalStorageBytes, 5242880);
    });
  });

  group('Phase 4: Admin Dashboard Screen Viewport Stress Testing', () {
    final testMetrics = const AdminPlatformMetrics(
      totalUsers: 1542,
      verifiedUsers: 1420,
      proUsers: 380,
      totalTrips: 4520,
      totalExpenses: 12450,
      totalDocuments: 890,
      totalChecklistItems: 18400,
      totalStorageBytes: 471859200, // ~450 MB
    );

    final testUsers = [
      AdminUserModel(
        uid: 'user-test-1',
        email: 'alexander.von.humboldt.explorer@packbuddy.app',
        displayName: 'Alexander von Humboldt',
        emailVerified: true,
        isPremium: true,
        provider: 'google.com',
        totalVaultStorageBytes: 47185920, // 45 MB
        lastLoginAt: DateTime(2026, 10, 14, 0, 15),
        createdAt: DateTime(2026, 1, 1),
      ),
      AdminUserModel(
        uid: 'user-test-2',
        email: 'konstantin.konstantinopolsky@travels.org',
        displayName: 'Константин Константинопольский',
        emailVerified: false,
        isPremium: false,
        provider: 'password',
        totalVaultStorageBytes: 1572864, // 1.5 MB
        lastLoginAt: DateTime(2026, 10, 13, 22, 10),
        createdAt: DateTime(2026, 2, 1),
      ),
    ];

    Widget buildTestApp({
      required Locale locale,
      required ThemeData theme,
    }) {
      return ProviderScope(
        overrides: [
          isAdminProvider.overrideWithValue(true),
          authUserProvider.overrideWithValue(FakeUser()),
          adminControllerProvider.overrideWith(
            (ref) => FakeAdminController(
              AdminState(
                isLoading: false,
                metrics: testMetrics,
                allUsers: testUsers,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: theme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AdminDashboardScreen(),
        ),
      );
    }

    testWidgets(
        'AdminDashboardScreen renders Total Storage and per-user storage badges with zero overflows on 320x568 (German & Dark)',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('de'),
          theme: AppTheme.darkTheme,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.byType(AdminDashboardScreen), findsOneWidget);

      // Verify that total storage metric is present in the metrics grid
      expect(find.text(formatStorageBytes(testMetrics.totalStorageBytes)), findsOneWidget);

      // Scroll down in the ListView to reveal user cards on 320x568 screen
      await tester.scrollUntilVisible(
        find.text(formatStorageBytes(testUsers[0].totalVaultStorageBytes)),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(formatStorageBytes(testUsers[0].totalVaultStorageBytes)), findsOneWidget);
    });

    testWidgets(
        'AdminDashboardScreen renders zero overflows on 320x568 (Russian & Light)',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('ru'),
          theme: AppTheme.lightTheme,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.byType(AdminDashboardScreen), findsOneWidget);
    });
  });
}
