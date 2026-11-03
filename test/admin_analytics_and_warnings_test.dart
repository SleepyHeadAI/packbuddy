import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/email_dispatch_service.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class MockAdminServiceForAnalytics implements AdminService {
  final List<AdminUserModel> users;
  final List<Map<String, dynamic>> dispatchedWarnings = [];

  MockAdminServiceForAnalytics({required this.users});

  @override
  bool isCurrentUserAdmin() => true;

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async => const AdminPlatformMetrics(
        totalUsers: 10,
        proUsers: 4,
        totalTrips: 20,
      );

  @override
  Future<List<AdminUserModel>> fetchUsers() async => List.from(users);

  @override
  Future<AdminDetailedAnalytics> fetchDetailedAnalytics() async {
    return const AdminDetailedAnalytics(
      // World Map Data (Wishlist, Visited, Lived, Continents)
      topWishlistCountries: [
        CountryTravelMetric(
          countryCode: 'JP',
          countryName: 'Japonya',
          flag: '🇯🇵',
          count: 8,
          percentage: 0.8,
          continent: 'Asia',
        ),
      ],
      topVisitedCountries: [
        CountryTravelMetric(
          countryCode: 'FR',
          countryName: 'Fransa',
          flag: '🇫🇷',
          count: 5,
          percentage: 0.5,
          continent: 'Europe',
        ),
      ],
      topLivedCountries: [
        CountryTravelMetric(
          countryCode: 'TR',
          countryName: 'Türkiye',
          flag: '🇹🇷',
          count: 9,
          percentage: 0.9,
          continent: 'Europe',
        ),
      ],
      continentShares: [
        ContinentShareMetric(
          continentName: 'Europe',
          icon: '🇪🇺',
          count: 14,
          percentage: 0.7,
        ),
      ],
      totalWorldMapMarks: 22,

      // Trip Data Analytics
      topTripDestinations: [
        CountryTravelMetric(
          countryCode: 'ES',
          countryName: 'İspanya',
          flag: '🇪🇸',
          count: 12,
          percentage: 0.6,
          continent: 'Europe',
        ),
      ],
      upcomingTripsCount: 14,
      completedTripsCount: 6,
      averageTripDurationDays: 6.8,
      averageExpensePerTrip: 450.0,
      transportPreferences: [
        TransportPreferenceMetric(
          mode: 'plane',
          label: 'Uçak',
          icon: '✈️',
          count: 15,
          percentage: 0.75,
        ),
      ],
      currencyShares: [
        CurrencyShareMetric(
          currencyCode: 'EUR',
          count: 16,
          percentage: 0.8,
        ),
      ],
    );
  }

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
  Future<void> deleteUserDocumentAsAdmin({required String uid, required String documentId}) async {}

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {}

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {
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
  }) async {
    dispatchedWarnings.add({
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
  Future<InactivityScanResult> processInactivityPolicies() async => const InactivityScanResult();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Admin Analytics & Warning Dispatch Suite', () {
    test('AdminDetailedAnalytics strictly separates World Map metrics from Trip metrics', () {
      const analytics = AdminDetailedAnalytics(
        topWishlistCountries: [
          CountryTravelMetric(
            countryCode: 'JP',
            countryName: 'Japonya',
            flag: '🇯🇵',
            count: 7,
            percentage: 0.7,
          ),
        ],
        topTripDestinations: [
          CountryTravelMetric(
            countryCode: 'IT',
            countryName: 'İtalya',
            flag: '🇮🇹',
            count: 11,
            percentage: 0.55,
          ),
        ],
        upcomingTripsCount: 15,
        completedTripsCount: 5,
        totalWorldMapMarks: 18,
      );

      // World map wishlist is strictly Japan, trips destination is strictly Italy
      expect(analytics.topWishlistCountries.first.countryCode, 'JP');
      expect(analytics.topTripDestinations.first.countryCode, 'IT');
      expect(analytics.upcomingTripsCount, 15);
      expect(analytics.completedTripsCount, 5);
      expect(analytics.totalWorldMapMarks, 18);
    });

    test('AdminController dispatches sendUserWarning correctly', () async {
      final mockService = MockAdminServiceForAnalytics(users: [
        const AdminUserModel(
          uid: 'target-user-1',
          email: 'target@example.com',
          displayName: 'Target User',
        ),
      ]);
      final controller = AdminController(mockService);

      final result = await controller.sendUserWarning(
        uid: 'target-user-1',
        title: 'Önemli Uyarı',
        message: 'Lütfen hesabınızı kontrol ediniz.',
        warningType: 'inactivity',
        sendInAppNotification: true,
        sendEmail: true,
      );

      expect(result, isTrue);
      expect(mockService.dispatchedWarnings.length, 1);
      final warning = mockService.dispatchedWarnings.first;
      expect(warning['uid'], 'target-user-1');
      expect(warning['title'], 'Önemli Uyarı');
      expect(warning['message'], 'Lütfen hesabınızı kontrol ediniz.');
      expect(warning['warningType'], 'inactivity');
      expect(warning['sendInApp'], isTrue);
      expect(warning['sendEmail'], isTrue);
    });

    test('PreferencesService records and retrieves in-app admin warning notifications', () async {
      final prefs = PreferencesService.instance;
      expect(prefs.getLastSeenAdminWarningAt(uid: 'u123'), 0);

      await prefs.setLastSeenAdminWarningAt(1730000000000, uid: 'u123');
      expect(prefs.getLastSeenAdminWarningAt(uid: 'u123'), 1730000000000);

      final warningJson = jsonEncode({
        'id': 'warn-01',
        'title': 'Sistem Bildirimi',
        'body': 'Hesabınıza 5 aydır girilmedi.',
        'timestamp': 1730000000000,
        'type': 'admin_warning',
      });

      await prefs.addNotificationHistoryItem(warningJson);
      final history = prefs.getNotificationHistory();
      expect(history.length, 1);
      expect(history.first.contains('Sistem Bildirimi'), isTrue);
      expect(history.first.contains('admin_warning'), isTrue);
    });

    test('EmailDispatchService formats plain text and HTML warning email bodies with user details', () {
      final emailService = EmailDispatchService.instance;
      final text = emailService.formatWarningEmailText(
        displayName: 'Ahmet',
        title: 'Önemli Uyarı',
        message: 'Lütfen seyahat listenizi kontrol ediniz.',
      );
      expect(text.contains('Merhaba Ahmet'), isTrue);
      expect(text.contains('Önemli Uyarı'), isTrue);
      expect(text.contains('Lütfen seyahat listenizi kontrol ediniz.'), isTrue);
      expect(text.contains('PackBuddy Yönetim Ekibi'), isTrue);

      final html = emailService.formatWarningEmailHtml(
        displayName: 'Ahmet',
        title: 'Önemli Uyarı',
        message: 'Lütfen seyahat listenizi kontrol ediniz.',
      );
      expect(html.contains('<strong>Ahmet</strong>'), isTrue);
      expect(html.contains('Önemli Uyarı'), isTrue);
      expect(html.contains('#ea580c'), isTrue);
    });

    test('EmailDispatchService returns false when toEmail is empty', () async {
      final emailService = EmailDispatchService.instance;
      final result = await emailService.launchEmailDraft(
        toEmail: '   ',
        subject: 'Title',
        body: 'Body',
      );
      expect(result, isFalse);
    });

    test('LocalNotificationService exposes urgent alerts channel configurations', () {
      expect(LocalNotificationService.urgentAlertChannelId, 'packbuddy_urgent_alerts');
      expect(LocalNotificationService.urgentAlertChannelName, 'System & Admin Alerts');
      expect(LocalNotificationService.channelId, 'packbuddy_trip_reminders');
    });

    testWidgets('AdminDashboardScreen renders both World Map and Trip sections separately',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockService = MockAdminServiceForAnalytics(users: [
        const AdminUserModel(
          uid: 'user-01',
          email: 'user1@packbuddy.com',
          displayName: 'Traveler One',
        ),
      ]);
      final controller = AdminController(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminServiceProvider.overrideWithValue(mockService),
            adminControllerProvider.overrideWith((ref) => controller),
            isAdminProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(
              body: AdminDashboardScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 1. World Travel Map Analytics Section
      expect(find.text('Dünya Haritası Verileri İstatistikleri'), findsOneWidget);
      expect(find.text('Harita Kaynaklı'), findsOneWidget);
      expect(find.text('Japonya'), findsOneWidget); // Wishlist country from map

      // 2. Trip Data Analytics Section
      expect(find.text('Seyahat Verileri İstatistikleri'), findsOneWidget);
      expect(find.text('Seyahatler Kaynaklı'), findsOneWidget);
      expect(find.text('14'), findsWidgets); // Upcoming trips
      expect(find.text('6'), findsWidgets); // Past trips
      expect(find.text('İspanya'), findsOneWidget); // Top trip destination
      expect(find.text('Uçak'), findsOneWidget); // Transport mode
      expect(find.text('EUR'), findsOneWidget); // Currency
    });
  });
}
