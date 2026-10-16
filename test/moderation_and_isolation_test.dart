// ignore_for_file: subtype_of_sealed_class, must_be_immutable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/features/auth/auth_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/presentation/screens/banned_screen.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/admin/user_moderation_provider.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_theme.dart';

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
    this.email = 'test@example.com',
    this.displayName = 'Test User',
    this.emailVerified = true,
    this.providerData = const [],
  });
}

class FakeDocSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic>? _data;
  final bool _exists;

  FakeDocSnapshot(this._data, [this._exists = true]);

  @override
  bool get exists => _exists;

  @override
  Map<String, dynamic>? data() => _data;
}

class FakeDocRef extends Fake implements DocumentReference<Map<String, dynamic>> {
  Map<String, dynamic>? storedData;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    if (options?.merge == true && storedData != null) {
      storedData = {...storedData!, ...data};
    } else {
      storedData = Map<String, dynamic>.from(data);
    }
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return FakeDocSnapshot(storedData, storedData != null);
  }
}

class FakeCollectionRef extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, FakeDocRef> docs = {};

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final key = path ?? 'auto-id';
    return docs.putIfAbsent(key, () => FakeDocRef());
  }
}

class FakeFirestoreInstance extends Fake implements FirebaseFirestore {
  final Map<String, FakeCollectionRef> collections = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return collections.putIfAbsent(collectionPath, () => FakeCollectionRef());
  }
}

class MockAdminServiceForTest implements AdminService {
  final List<AdminUserModel> users;
  final List<Map<String, dynamic>> moderationUpdates = [];

  MockAdminServiceForTest(this.users);

  @override
  bool isCurrentUserAdmin() => true;

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async => const AdminPlatformMetrics(
        totalUsers: 10,
        proUsers: 4,
        totalTrips: 15,
        totalExpenses: 40,
        totalDocuments: 8,
        totalChecklistItems: 60,
        totalStorageBytes: 1024 * 1024 * 5,
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
  }) async {
    moderationUpdates.add({
      'uid': uid,
      'isPremium': isPremium,
      'banStatus': banStatus,
      'banExpiresAt': banExpiresAt,
      'banReason': banReason,
      'restrictedFeatures': restrictedFeatures,
    });
  }

  @override
  Future<List<VaultDocument>> fetchUserDocuments(String uid) async => [];

  @override
  Future<void> deleteUserDocumentAsAdmin({required String uid, required String documentId}) async {}

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {}

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
    await PreferencesService.instance.clearDeviceProStatus();
  });

  group('Phase 1: Multi-Account Pro Isolation & Zero Contagion', () {
    test('Scoped Pro status prevents Account B from inheriting Account A Pro status', () async {
      final prefs = PreferencesService.instance;
      const userA = 'uid-account-a';
      const userB = 'uid-account-b';

      // 1. Account A is Pro
      await prefs.setProUser(true, uid: userA);
      expect(prefs.isProUser(uid: userA), isTrue);

      // 2. Account B is free
      expect(prefs.isProUser(uid: userB), isFalse);

      // Device legacy Pro status is cleared
      await prefs.clearDeviceProStatus();
      expect(prefs.isProUser(uid: userB), isFalse);
      expect(prefs.isProUser(uid: userA), isTrue);
    });

    test('syncUserProfile initializes new user with isPremium: false in Firestore', () async {
      final fakeDb = FakeFirestoreInstance();
      final authService = FirebaseAuthService(firestore: fakeDb);
      final newUser = FakeUser(uid: 'uid-brand-new');

      final isPro = await authService.syncUserProfile(newUser);
      expect(isPro, isFalse);

      final doc = fakeDb.collection('users').doc(newUser.uid) as FakeDocRef;
      expect(doc.storedData!['isPremium'], isFalse);
      expect(doc.storedData!['banStatus'], 'none');
      expect(doc.storedData!['countryCode'], isNotEmpty);
    });

    test('Domain controllers reset cleanly on account switch', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final tripController = container.read(tripControllerProvider.notifier);
      final now = DateTime.now();
      tripController.state = TripState(
        trips: [
          Trip(
            id: 'trip-1',
            title: 'Account A Trip',
            destination: 'Rome',
            startDate: now,
            endDate: now.add(const Duration(days: 3)),
            budgetLimit: 1000,
            defaultCurrency: 'EUR',
            createdAt: now,
            updatedAt: now,
          )
        ],
      );
      expect(tripController.state.trips.length, 1);

      // Account switch -> resetState
      tripController.resetState();
      expect(tripController.state.trips, isEmpty);
      expect(tripController.state.isLoading, isFalse);

      final vaultController = container.read(vaultControllerProvider.notifier);
      vaultController.resetState();
      expect(vaultController.state.documents, isEmpty);

      final checklistController = container.read(checklistControllerProvider.notifier);
      checklistController.resetState();
      expect(checklistController.state.items, isEmpty);
    });
  });

  group('Phase 2: Automatic Country & Currency Detection', () {
    test('CountryDetector resolves native currency from country catalog', () {
      final trCurrency = CountryDetector.getCurrencyForCountry('TR');
      expect(trCurrency, 'TRY');

      final deCurrency = CountryDetector.getCurrencyForCountry('DE');
      expect(deCurrency, 'EUR');

      final gbCurrency = CountryDetector.getCurrencyForCountry('GB');
      expect(gbCurrency, 'GBP');

      final jpCurrency = CountryDetector.getCurrencyForCountry('JP');
      expect(jpCurrency, 'JPY');

      final usCurrency = CountryDetector.getCurrencyForCountry('US');
      expect(usCurrency, 'USD');
    });

    test('CountryDetector maps language to country fallback when countryCode is absent', () {
      final trCountry = CountryDetector.getCountryForLanguage('tr');
      expect(trCountry, 'TR');

      final deCountry = CountryDetector.getCountryForLanguage('de');
      expect(deCountry, 'DE');

      final jaCountry = CountryDetector.getCountryForLanguage('ja');
      expect(jaCountry, 'JP');

      final koCountry = CountryDetector.getCountryForLanguage('ko');
      expect(koCountry, 'KR');
    });

    test('CurrencyNotifier auto-initializes to country currency if user has not selected', () async {
      final notifier = CurrencyNotifier();
      expect(notifier.state, isNotEmpty);
      expect(PreferencesService.instance.hasUserSelectedCurrency(), isFalse);

      // Setting currency sets userSelected flag
      await notifier.setCurrency('GBP');
      expect(notifier.state, 'GBP');
      expect(PreferencesService.instance.hasUserSelectedCurrency(), isTrue);
    });
  });

  group('Phase 3: Ban Enforcement & Feature Restriction Guards', () {
    test('UserModerationState correctly calculates isCurrentlyBanned', () {
      // 1. None
      const unbanned = UserModerationState(banStatus: 'none');
      expect(unbanned.isCurrentlyBanned, isFalse);

      // 2. Permanent
      const permanent = UserModerationState(banStatus: 'permanent');
      expect(permanent.isCurrentlyBanned, isTrue);

      // 3. Temporary in future
      final futureExpiry = DateTime.now().add(const Duration(hours: 12)).toIso8601String();
      final tempActive = UserModerationState(
        banStatus: 'temporary',
        banExpiresAt: futureExpiry,
      );
      expect(tempActive.isCurrentlyBanned, isTrue);

      // 4. Temporary expired
      final pastExpiry = DateTime.now().subtract(const Duration(hours: 2)).toIso8601String();
      final tempExpired = UserModerationState(
        banStatus: 'temporary',
        banExpiresAt: pastExpiry,
      );
      expect(tempExpired.isCurrentlyBanned, isFalse);
    });

    test('UserModerationState checks feature restrictions correctly', () {
      const state = UserModerationState(
        restrictedFeatures: ['trip_create', 'vault_upload'],
      );
      expect(state.isFeatureRestricted('trip_create'), isTrue);
      expect(state.isFeatureRestricted('vault_upload'), isTrue);
      expect(state.isFeatureRestricted('expense_add'), isFalse);
      expect(state.isFeatureRestricted('cloud_sync'), isFalse);
    });

    testWidgets('BannedScreen renders styled temporary ban lock with countdown and reason', (tester) async {
      final expiry = DateTime.now().add(const Duration(days: 3)).toIso8601String();
      final moderation = UserModerationState(
        banStatus: 'temporary',
        banExpiresAt: expiry,
        banReason: 'Suspicious login activity',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BannedScreen(moderation: moderation),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.gpp_bad_rounded), findsOneWidget);
      expect(find.text('Account Temporarily Suspended'), findsOneWidget);
      expect(find.text('Suspicious login activity'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('BannedScreen renders permanent ban with zero overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const moderation = UserModerationState(
        banStatus: 'permanent',
        banReason: 'Severe Terms of Service Violation',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: const BannedScreen(moderation: moderation),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);
      expect(find.text('Severe Terms of Service Violation'), findsOneWidget);
    });
  });

  group('Phase 4: Geo-Analytics & User Moderation Command Center', () {
    final testUsers = [
      AdminUserModel(
        uid: 'user-1',
        email: 'turkey1@packbuddy.com',
        displayName: 'Ahmet TR',
        countryCode: 'TR',
        countryName: 'Turkey',
        currencyCode: 'TRY',
        isPremium: true,
        lastActiveAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      AdminUserModel(
        uid: 'user-2',
        email: 'turkey2@packbuddy.com',
        displayName: 'Ayse TR',
        countryCode: 'TR',
        countryName: 'Turkey',
        currencyCode: 'TRY',
        isPremium: false,
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AdminUserModel(
        uid: 'user-3',
        email: 'germany@packbuddy.com',
        displayName: 'Hans DE',
        countryCode: 'DE',
        countryName: 'Germany',
        currencyCode: 'EUR',
        isPremium: true,
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      AdminUserModel(
        uid: 'user-4',
        email: 'usa@packbuddy.com',
        displayName: 'John US',
        countryCode: 'US',
        countryName: 'United States',
        currencyCode: 'USD',
        isPremium: false,
        lastActiveAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      AdminUserModel(
        uid: 'user-5',
        email: 'inactive@packbuddy.com',
        displayName: 'Inactive User',
        countryCode: 'GB',
        countryName: 'United Kingdom',
        currencyCode: 'GBP',
        isPremium: false,
        lastActiveAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    test('Geo-Analytics calculates periods and country breakdown accurately', () {
      final mockService = MockAdminServiceForTest(testUsers);
      final controller = AdminController(mockService);
      controller.state = controller.state.copyWith(allUsers: testUsers);

      // 1. Live (15m): user-1 only
      controller.setAnalyticsPeriod(AnalyticsPeriod.live);
      expect(controller.state.activeUsersInPeriod.length, 1);
      expect(controller.state.countryBreakdown.length, 1);
      expect(controller.state.countryBreakdown.first.countryCode, 'TR');
      expect(controller.state.countryBreakdown.first.activeUserCount, 1);
      expect(controller.state.countryBreakdown.first.percentage, 1.0);

      // 2. Daily (24h): user-1 (TR), user-2 (TR), user-3 (DE) -> 3 active
      controller.setAnalyticsPeriod(AnalyticsPeriod.daily);
      expect(controller.state.activeUsersInPeriod.length, 3);
      final dailyBreakdown = controller.state.countryBreakdown;
      expect(dailyBreakdown.length, 2);
      expect(dailyBreakdown[0].countryCode, 'TR');
      expect(dailyBreakdown[0].activeUserCount, 2);
      expect(dailyBreakdown[0].percentage, closeTo(2 / 3, 0.01));
      expect(dailyBreakdown[1].countryCode, 'DE');
      expect(dailyBreakdown[1].activeUserCount, 1);

      // 3. Weekly (7d): includes user-4 (US) -> 4 active
      controller.setAnalyticsPeriod(AnalyticsPeriod.weekly);
      expect(controller.state.activeUsersInPeriod.length, 4);

      // 4. Yearly (365d): includes inactive (GB) -> 5 active
      controller.setAnalyticsPeriod(AnalyticsPeriod.yearly);
      expect(controller.state.activeUsersInPeriod.length, 5);
      expect(controller.state.countryBreakdown.length, 4);
    });

    test('User directory filter chips filter users correctly', () {
      final bannedUser = AdminUserModel(
        uid: 'user-banned',
        email: 'banned@test.com',
        displayName: 'Banned Person',
        banStatus: 'permanent',
        countryCode: 'US',
      );
      final restrictedUser = AdminUserModel(
        uid: 'user-res',
        email: 'restricted@test.com',
        displayName: 'Restricted Person',
        restrictedFeatures: ['vault_upload'],
        countryCode: 'US',
      );

      final mixedUsers = [...testUsers, bannedUser, restrictedUser];
      final mockService = MockAdminServiceForTest(mixedUsers);
      final controller = AdminController(mockService);
      controller.state = controller.state.copyWith(allUsers: mixedUsers);

      // All
      controller.setUserFilter(UserFilterChip.all);
      expect(controller.state.filteredUsers.length, 7);

      // Pro only
      controller.setUserFilter(UserFilterChip.pro);
      expect(controller.state.filteredUsers.every((u) => u.isPremium), isTrue);
      expect(controller.state.filteredUsers.length, 2);

      // Banned only
      controller.setUserFilter(UserFilterChip.banned);
      expect(controller.state.filteredUsers.length, 1);
      expect(controller.state.filteredUsers.first.uid, 'user-banned');

      // Restricted only
      controller.setUserFilter(UserFilterChip.restricted);
      expect(controller.state.filteredUsers.length, 1);
      expect(controller.state.filteredUsers.first.uid, 'user-res');
    });

    test('updateUserModeration updates user model and invokes service', () async {
      final mockService = MockAdminServiceForTest(testUsers);
      final controller = AdminController(mockService);
      controller.state = controller.state.copyWith(allUsers: testUsers);

      final success = await controller.updateUserModeration(
        uid: 'user-2',
        isPremium: true,
        banStatus: 'temporary',
        banExpiresAt: '2026-10-20T00:00:00.000Z',
        banReason: 'Spamming',
        restrictedFeatures: ['trip_create'],
      );

      expect(success, isTrue);
      expect(mockService.moderationUpdates.length, 1);
      expect(mockService.moderationUpdates.first['uid'], 'user-2');
      expect(mockService.moderationUpdates.first['isPremium'], isTrue);
      expect(mockService.moderationUpdates.first['banReason'], 'Spamming');

      // Optimistic update verified
      final updatedUser = controller.state.allUsers.firstWhere((u) => u.uid == 'user-2');
      expect(updatedUser.isPremium, isTrue);
      expect(updatedUser.banStatus, 'temporary');
      expect(updatedUser.banReason, 'Spamming');
      expect(updatedUser.restrictedFeatures, ['trip_create']);
    });

    testWidgets('AdminDashboardScreen renders Geo-Analytics and directory with zero overflows on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockService = MockAdminServiceForTest(testUsers);
      final controller = AdminController(mockService);
      controller.state = controller.state.copyWith(allUsers: testUsers);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isAdminProvider.overrideWithValue(true),
            authUserProvider.overrideWithValue(FakeUser(uid: 'admin-1', email: 'sleepyheadaitr@gmail.com')),
            adminControllerProvider.overrideWith((ref) => controller),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Geographic & Activity Analytics'), findsOneWidget);
      expect(find.text('Live (15m)'), findsOneWidget);
      expect(find.text('Daily (24h)'), findsOneWidget);

      // Verify Country Breakdown appears
      expect(find.textContaining('Turkey (TR)'), findsWidgets);
    });
  });
}
