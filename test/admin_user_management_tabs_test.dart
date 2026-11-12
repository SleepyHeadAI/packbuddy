import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/admin/domain/broadcast_announcement.dart';
import 'package:packbuddy/features/admin/domain/admin_audit_log.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  FakeUser({required this.uid, this.email, this.displayName});
}

class MockAdminServiceForTabs implements AdminService {
  final List<AdminUserModel> users;
  final List<Trip> trips;
  final List<Expense> expenses;
  final List<VaultDocument> documents;
  final List<AdminUserSessionLog> sessions;
  final List<Map<String, dynamic>> moderationUpdates = [];
  final List<String> purgedUsers = [];

  MockAdminServiceForTabs({
    required this.users,
    this.trips = const [],
    this.expenses = const [],
    this.documents = const [],
    this.sessions = const [],
  });

  @override
  bool isCurrentUserAdmin() => true;

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async => const AdminPlatformMetrics(
        totalUsers: 2,
        proUsers: 1,
        totalTrips: 5,
        totalExpenses: 12,
        totalDocuments: 3,
      );

  @override
  Future<List<AdminUserModel>> fetchUsers() async => List.from(users);

  @override
  Future<AdminDetailedAnalytics> fetchDetailedAnalytics() async =>
      const AdminDetailedAnalytics();

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
  Future<List<VaultDocument>> fetchUserDocuments(String uid) async => documents;

  @override
  Future<List<Trip>> fetchUserTrips(String uid) async => trips;

  @override
  Future<List<Expense>> fetchUserExpenses(String uid) async => expenses;

  @override
  Future<List<AdminUserSessionLog>> fetchUserSessions(String uid) async => sessions;

  @override
  Future<List<TravelCountry>> fetchUserTravelCountries(String uid) async {
    final user = users.cast<AdminUserModel?>().firstWhere((u) => u?.uid == uid, orElse: () => null);
    if (user == null || user.travelMapCountries.isEmpty) return const [];
    return WorldCountriesData.allCountries.map((c) {
      final val = user.travelMapCountries[c.code.toUpperCase().trim()];
      if (val == null) return c;
      final statusStr = (val is Map ? val['status'] : val).toString().toLowerCase();
      var status = CountryStatus.none;
      if (statusStr.contains('visited') || statusStr == 'gezilen') status = CountryStatus.visited;
      if (statusStr.contains('wish') || statusStr == 'hedef') status = CountryStatus.wishlist;
      if (statusStr.contains('lived') || statusStr == 'yasayan') status = CountryStatus.lived;
      return c.copyWith(status: status);
    }).toList();
  }

  @override
  Future<void> deleteUserDocumentAsAdmin({required String uid, required String documentId}) async {}

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {}

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {
    purgedUsers.add(uid);
    users.removeWhere((u) => u.uid == uid);
  }

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
  }) async =>
      true;

  @override
  Future<InactivityScanResult> processInactivityPolicies() async =>
      const InactivityScanResult(totalScanned: 2, warningsSent: 0, accountsPurged: 0);

  @override
  Future<bool> sendBroadcastAnnouncement({
    required String title,
    required String message,
    String type = 'discount',
    String targetAction = 'paywall',
    String targetAudience = 'all',
    int? discountPercent,
    String? actionLabel,
  }) async => true;

  @override
  Future<List<BroadcastAnnouncement>> fetchBroadcastAnnouncements() async => [];

  @override
  Future<bool> toggleBroadcastActive(String broadcastId, bool active) async => true;

  @override
  Future<bool> deleteBroadcastAnnouncement(String broadcastId) async => true;

  @override
  Future<void> recordAuditLog({
    required String action,
    required String actionTitle,
    required String targetUid,
    String? targetUserEmail,
    String? targetUserName,
    Map<String, dynamic> details = const {},
  }) async {}

  @override
  Future<List<AdminAuditLog>> fetchAuditLogs({int limit = 100}) async => const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testUser = AdminUserModel(
    uid: 'test-user-42',
    email: 'traveler42@example.com',
    displayName: 'Marco Polo',
    countryCode: 'TR',
    countryName: 'Turkey',
    currencyCode: 'EUR',
    liveCountryCode: 'TR',
    liveCountryName: 'Türkiye',
    liveCity: 'Istanbul',
    isPremium: false,
    banStatus: 'none',
    restrictedFeatures: const [],
    totalSessionSeconds: 7200,
    sessionCount: 6,
    lastSessionSeconds: 1200,
    totalVaultStorageBytes: 1024 * 512,
    createdAt: DateTime(2026, 1, 1),
    lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
    travelMapCountries: const {
      'TR': {'status': 'lived'},
      'FR': {'status': 'visited'},
      'IT': {'status': 'visited'},
      'JP': {'status': 'wishlist'},
    },
  );

  final testTrips = [
    Trip(
      id: 'trip-1',
      userId: 'test-user-42',
      title: 'Paris Sanat Gezisi',
      destination: 'Paris, Fransa',
      startDate: DateTime(2026, 11, 20),
      endDate: DateTime(2026, 11, 27),
      countryCode: 'FR',
      defaultCurrency: 'EUR',
      budgetLimit: 1500.0,
      transportMode: 'flight',
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
    ),
    Trip(
      id: 'trip-2',
      userId: 'test-user-42',
      title: 'Roma Tarih Turu',
      destination: 'Roma, İtalya',
      startDate: DateTime(2026, 8, 10),
      endDate: DateTime(2026, 8, 18),
      countryCode: 'IT',
      defaultCurrency: 'EUR',
      budgetLimit: 1200.0,
      transportMode: 'train',
      createdAt: DateTime(2026, 7, 1),
      updatedAt: DateTime(2026, 7, 1),
    ),
  ];

  final testExpenses = [
    Expense(
      id: 'exp-1',
      tripId: 'trip-1',
      userId: 'test-user-42',
      title: 'Louvre Müzesi Bileti',
      amount: 45.0,
      currency: 'EUR',
      category: 'Etkinlik',
      date: DateTime(2026, 11, 21),
      createdAt: DateTime(2026, 11, 21),
      updatedAt: DateTime(2026, 11, 21),
    ),
    Expense(
      id: 'exp-2',
      tripId: 'trip-1',
      userId: 'test-user-42',
      title: 'Kruvasan & Kahve',
      amount: 12.5,
      currency: 'EUR',
      category: 'Yeme-İçme',
      date: DateTime(2026, 11, 22),
      createdAt: DateTime(2026, 11, 22),
      updatedAt: DateTime(2026, 11, 22),
    ),
  ];

  final List<VaultDocument> testDocs = [
    VaultDocument(
      id: 'doc-pass-1',
      userId: 'test-user-42',
      title: 'Biyometrik Pasaport.pdf',
      category: 'Pasaport',
      fileExtension: 'PDF',
      fileSizeBytes: 1024 * 350,
      localImagePath: '',
      cloudDataBase64: base64Encode(utf8.encode('%PDF-1.4 Mock PDF Header')),
      createdAt: DateTime(2026, 9, 10),
      updatedAt: DateTime(2026, 9, 10),
    ),
    VaultDocument(
      id: 'doc-private-1',
      userId: 'test-user-42',
      title: 'Özel Pasaport Yedek Fotoğrafı.jpg',
      category: 'PrivatePhotos',
      fileExtension: 'JPG',
      fileSizeBytes: 1024 * 500,
      localImagePath: '',
      cloudDataBase64: base64Encode(utf8.encode('Mock JPG Data')),
      createdAt: DateTime(2026, 9, 11),
      updatedAt: DateTime(2026, 9, 11),
    ),
  ];

  final testSessions = [
    AdminUserSessionLog(
      durationSeconds: 1200,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AdminUserSessionLog(
      durationSeconds: 1800,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AdminUserSessionLog(
      durationSeconds: 2400,
      timestamp: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  Widget createHarness({
    required MockAdminServiceForTabs service,
    required AdminController controller,
    Locale locale = const Locale('tr'),
  }) {
    return ProviderScope(
      overrides: [
        isAdminProvider.overrideWithValue(true),
        authUserProvider.overrideWithValue(
          FakeUser(uid: 'admin-super', email: 'sleepyheadaitr@gmail.com', displayName: 'Admin'),
        ),
        adminServiceProvider.overrideWithValue(service),
        adminControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: const Scaffold(body: AdminDashboardScreen()),
      ),
    );
  }

  testWidgets('Admin Moderation Sheet renders TWO DISTINCT TABS and navigates between them', (tester) async {
    tester.view.physicalSize = const Size(1000, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final service = MockAdminServiceForTabs(
      users: [testUser],
      trips: testTrips,
      expenses: testExpenses,
      documents: testDocs,
      sessions: testSessions,
    );
    final controller = AdminController(service);
    controller.state = controller.state.copyWith(allUsers: [testUser]);

    await tester.pumpWidget(createHarness(service: service, controller: controller));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final moderateBtn = find.byIcon(Icons.tune_rounded);
    expect(moderateBtn, findsOneWidget);
    await tester.scrollUntilVisible(
      moderateBtn,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(moderateBtn);
    await tester.pumpAndSettle();

    // 1. Verify BOTH TAB HEADERS are visible
    expect(find.byKey(const ValueKey('tab_moderation_actions')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab_user_stats_details')), findsOneWidget);
    expect(find.text('Aksiyon & Yönetim'), findsOneWidget);
    expect(find.text('İstatistikler & Detaylar'), findsOneWidget);

    // 2. PAGE 1 (Aksiyon & Yönetim) content is visible by default
    expect(find.text('Kullanıcıya Uyarı Gönderme'), findsOneWidget);
    expect(find.text('Hesap Engeli / Askıya Alma'), findsOneWidget);
    expect(find.text('Kalıcı Engel'), findsOneWidget);
    expect(find.text('24 Saat'), findsOneWidget);
    expect(find.text('Ayrıntılı Özellik Kısıtlamaları'), findsOneWidget);
    expect(find.text('Seyahat Oluşturma'), findsOneWidget);
    expect(find.text('Hesabı ve Tüm Verilerini Sil'), findsOneWidget);
    expect(find.text('Değişiklikleri Kaydet'), findsOneWidget);

    // 3. SWITCH TO PAGE 2 (İstatistikler & Detaylar)
    await tester.tap(find.byKey(const ValueKey('tab_user_stats_details')), warnIfMissed: false);
    await tester.pumpAndSettle();

    // 4. Verify PAGE 2 (İstatistikler & Detaylar) elements appear
    expect(find.text('Konum ve Sistem Bilgileri'), findsOneWidget);
    expect(find.text('Ülke ve Seyahat Haritası'), findsOneWidget);
    expect(find.textContaining('Yaşadığı Ülke'), findsOneWidget);
    expect(find.textContaining('Gezdiği Ülkeler'), findsOneWidget);
    expect(find.textContaining('Gezmek İstediği Ülkeler'), findsOneWidget);

    // 5. Verify App Usage Duration Section with Filter Chips
    expect(find.text('Uygulama Kullanım Süresi'), findsOneWidget);
    expect(find.byKey(const ValueKey('moderation_chip_daily')), findsOneWidget);
    expect(find.byKey(const ValueKey('moderation_chip_weekly')), findsOneWidget);
    expect(find.byKey(const ValueKey('moderation_chip_monthly')), findsOneWidget);
    expect(find.byKey(const ValueKey('moderation_chip_all_time')), findsOneWidget);
    expect(find.byKey(const ValueKey('moderation_chip_custom')), findsOneWidget);

    // 6. Verify Kasadakileri Görme (Vault Documents) is in Page 2 with dedicated Özel Kasa section
    expect(find.text('Yüklenen Kasa Belgeleri (İncele / Yönet)'), findsOneWidget);
    expect(find.text('Genel Kasa Belgeleri'), findsOneWidget);
    expect(find.text('Biyometrik Pasaport.pdf'), findsOneWidget);
    expect(find.text('Özel Kasa (Özel Resimler)'), findsOneWidget);
    expect(find.text('Özel Pasaport Yedek Fotoğrafı.jpg'), findsOneWidget);
    expect(find.text('GİZLİ'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'İncele'), findsNWidgets(2));

    // 7. Verify Seyahat Planlarını Görme (Trips)
    expect(find.text('Seyahat Planları'), findsOneWidget);
    expect(find.text('Paris Sanat Gezisi'), findsOneWidget);
    expect(find.text('Roma Tarih Turu'), findsOneWidget);

    // 8. Verify Harcamalarını Görme (Expenses)
    expect(find.text('Harcamalar & Bütçe'), findsOneWidget);
    expect(find.text('Louvre Müzesi Bileti'), findsOneWidget);
    expect(find.text('Kruvasan & Kahve'), findsOneWidget);
    expect(find.text('Toplam Harcama:'), findsOneWidget);
    expect(find.textContaining('57.50 EUR'), findsOneWidget);
  });

  testWidgets('Page 2: Usage duration switches dynamically across periods', (tester) async {
    tester.view.physicalSize = const Size(1000, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final service = MockAdminServiceForTabs(
      users: [testUser],
      trips: testTrips,
      expenses: testExpenses,
      documents: testDocs,
      sessions: testSessions,
    );
    final controller = AdminController(service);
    controller.state = controller.state.copyWith(allUsers: [testUser]);

    await tester.pumpWidget(createHarness(service: service, controller: controller));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final moderateBtn = find.byIcon(Icons.tune_rounded);
    expect(moderateBtn, findsOneWidget);
    await tester.scrollUntilVisible(
      moderateBtn,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(moderateBtn);
    await tester.pumpAndSettle();

    // Switch to Page 2
    await tester.tap(find.byKey(const ValueKey('tab_user_stats_details')), warnIfMissed: false);
    await tester.pumpAndSettle();

    // In daily period (last 24h), session with 1200 seconds is present
    expect(find.text('1 oturum'), findsOneWidget);

    // Tap "Haftalık (7g)"
    await tester.tap(find.byKey(const ValueKey('moderation_chip_weekly')));
    await tester.pumpAndSettle();

    // Last 7 days includes 1200s and 1800s => 2 sessions
    expect(find.text('2 oturum'), findsOneWidget);

    // Tap "Tüm Zamanlar"
    await tester.tap(find.byKey(const ValueKey('moderation_chip_all_time')));
    await tester.pumpAndSettle();

    // All-time includes all 3 sessions
    expect(find.text('3 oturum'), findsOneWidget);
  });

  testWidgets('Page 1: Save moderation changes calls updateUserModeration and shows snackbar', (tester) async {
    tester.view.physicalSize = const Size(1000, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final service = MockAdminServiceForTabs(
      users: [testUser],
      trips: testTrips,
      expenses: testExpenses,
      documents: testDocs,
      sessions: testSessions,
    );
    final controller = AdminController(service);
    controller.state = controller.state.copyWith(allUsers: [testUser]);

    await tester.pumpWidget(createHarness(service: service, controller: controller));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final moderateBtn = find.byIcon(Icons.tune_rounded);
    expect(moderateBtn, findsOneWidget);
    await tester.scrollUntilVisible(
      moderateBtn,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(moderateBtn);
    await tester.pumpAndSettle();

    // Select 24h Ban
    await tester.tap(find.text('24 Saat'));
    await tester.pumpAndSettle();

    // Enter Ban Reason
    await tester.enterText(find.byType(TextField).last, 'Topluluk kurallarını ihlal');
    await tester.pumpAndSettle();

    // Toggle a restriction switch (Seyahat Oluşturma)
    final restrictionSwitch = find.byKey(const ValueKey('switch_restriction_trip_create'));
    expect(restrictionSwitch, findsOneWidget);
    await tester.tap(restrictionSwitch);
    await tester.pumpAndSettle();

    // Tap "Değişiklikleri Kaydet"
    await tester.tap(find.text('Değişiklikleri Kaydet'));
    await tester.pumpAndSettle();

    // Verify service was called with updated moderation
    expect(service.moderationUpdates.length, 1);
    final update = service.moderationUpdates.first;
    expect(update['uid'], 'test-user-42');
    expect(update['banStatus'], 'temporary');
    expect(update['banReason'], 'Topluluk kurallarını ihlal');
    expect(update['restrictedFeatures'], contains('trip_create'));

    // Verify snackbar feedback
    expect(find.text('Yönetim değişiklikleri başarıyla kaydedildi'), findsOneWidget);
  });

  testWidgets('Page 1: Account purge button opens confirmation dialog and purges data', (tester) async {
    tester.view.physicalSize = const Size(1000, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final service = MockAdminServiceForTabs(
      users: [testUser],
      trips: testTrips,
      expenses: testExpenses,
      documents: testDocs,
      sessions: testSessions,
    );
    final controller = AdminController(service);
    controller.state = controller.state.copyWith(allUsers: [testUser]);

    await tester.pumpWidget(createHarness(service: service, controller: controller));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final moderateBtn = find.byIcon(Icons.tune_rounded);
    expect(moderateBtn, findsOneWidget);
    await tester.scrollUntilVisible(
      moderateBtn,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(moderateBtn);
    await tester.pumpAndSettle();

    // Tap Purge button in Page 1
    final purgeBtn = find.text('Hesabı ve Tüm Verileri Temizle (Purge)');
    expect(purgeBtn, findsOneWidget);
    await tester.tap(purgeBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Kullanıcı Verileri Kalıcı Silinsin mi?'), findsOneWidget);

    // Confirm Purge
    final confirmPurgeBtn = find.widgetWithText(FilledButton, 'Verileri Şimdi Kalıcı Sil');
    expect(confirmPurgeBtn, findsOneWidget);
    await tester.tap(confirmPurgeBtn);
    await tester.pumpAndSettle();

    // Verify service was called
    expect(service.purgedUsers, contains('test-user-42'));
    expect(find.text('Tüm kullanıcı verileri kalıcı olarak silindi'), findsOneWidget);
  });

  testWidgets('Page 2: Country journey displays strictly per-user countries without cross-contamination', (tester) async {
    tester.view.physicalSize = const Size(1000, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final user1 = AdminUserModel(
      uid: 'user-fr-jp',
      displayName: 'Alice France',
      email: 'alice@france.com',
      liveCountryCode: 'FR',
      liveCountryName: 'France',
      travelMapCountries: {
        'FR': 'lived',
        'IT': 'visited',
        'JP': 'wishlist',
      },
    );

    final user2 = AdminUserModel(
      uid: 'user-de-us',
      displayName: 'Bob Germany',
      email: 'bob@germany.com',
      liveCountryCode: 'DE',
      liveCountryName: 'Germany',
      travelMapCountries: {
        'DE': 'lived',
        'ES': 'visited',
        'US': 'wishlist',
      },
    );

    final service = MockAdminServiceForTabs(users: [user1, user2]);
    final controller = AdminController(service);
    controller.state = controller.state.copyWith(allUsers: [user1, user2]);

    await tester.pumpWidget(
      createHarness(
        service: service,
        controller: controller,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // 1. Open User 1 Moderation Sheet
    final tuneIcons = find.byIcon(Icons.tune_rounded);
    expect(tuneIcons, findsNWidgets(2));
    await tester.tap(tuneIcons.at(0));
    await tester.pumpAndSettle();

    // Switch to Page 2
    await tester.tap(find.byKey(const ValueKey('tab_user_stats_details')), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify User 1's countries (IT visited, JP wishlist) exist and user 2's (ES visited, US wishlist) do NOT
    expect(find.text('İtalya'), findsOneWidget);
    expect(find.text('Japonya'), findsOneWidget);
    expect(find.text('İspanya'), findsNothing);
    expect(find.text('Amerika Birleşik Devletleri'), findsNothing);

    // Close User 1 sheet
    await tester.tap(find.byIcon(Icons.close_rounded).first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // 2. Open User 2 Moderation Sheet
    await tester.tap(tuneIcons.at(1));
    await tester.pumpAndSettle();

    // Switch to Page 2
    await tester.tap(find.byKey(const ValueKey('tab_user_stats_details')), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify User 2's countries (ES visited, US wishlist) exist and user 1's (IT visited, JP wishlist) do NOT
    expect(find.text('İspanya'), findsOneWidget);
    expect(find.text('Amerika Birleşik Devletleri'), findsOneWidget);
    expect(find.text('İtalya'), findsNothing);
    expect(find.text('Japonya'), findsNothing);
  });
}
