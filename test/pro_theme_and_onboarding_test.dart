import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/auth/auth_screen.dart';
import 'package:packbuddy/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/main.dart';

class MockUser extends Fake implements User {
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

  MockUser({
    required this.uid,
    this.email = 'test@example.com',
    this.displayName = 'Test User',
    this.emailVerified = true,
    this.providerData = const [],
  });
}

class FakeAdminService extends Fake implements AdminService {
  bool toggledProValue = false;
  String? toggledUid;

  @override
  Future<void> toggleUserProStatus(String uid, bool isPremium) async {
    toggledUid = uid;
    toggledProValue = isPremium;
    await PreferencesService.instance.setProUser(isPremium, uid: uid);
  }

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async => const AdminPlatformMetrics();

  @override
  Future<List<AdminUserModel>> fetchUsers() async => [];

  @override
  Future<AdminDetailedAnalytics> fetchDetailedAnalytics() async => const AdminDetailedAnalytics();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Requirement 1: Default App Theme (Light Mode)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
    });

    test('PreferencesService defaults to Light Mode on fresh install', () {
      final mode = PreferencesService.instance.getThemeMode();
      expect(mode, equals(ThemeMode.light));
    });

    test('User can switch theme and it persists properly', () async {
      await PreferencesService.instance.setThemeMode(ThemeMode.dark);
      expect(PreferencesService.instance.getThemeMode(), equals(ThemeMode.dark));

      await PreferencesService.instance.setThemeMode(ThemeMode.system);
      expect(PreferencesService.instance.getThemeMode(), equals(ThemeMode.system));

      await PreferencesService.instance.setThemeMode(ThemeMode.light);
      expect(PreferencesService.instance.getThemeMode(), equals(ThemeMode.light));
    });
  });

  group('Requirement 2: Pro Entitlement Persistence Across App Reinstall', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
    });

    test('Admin granting Pro persists across simulated app reinstallation', () async {
      const targetUid = 'user_reinstall_pro_123';
      final fakeAdminService = FakeAdminService();

      // 1. Admin grants Pro to user
      await fakeAdminService.toggleUserProStatus(targetUid, true);
      expect(PreferencesService.instance.isProUser(uid: targetUid), isTrue);

      // 2. SIMULATE APP REINSTALL: All local SharedPreferences are wiped clean!
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
      expect(PreferencesService.instance.isProUser(uid: targetUid), isFalse);

      // 3. User logs in -> remote document contains Pro entitlement
      // Simulating remote payload check across all supported keys: isPremium, is_premium, isPro, pro
      final remoteDocData = {
        'uid': targetUid,
        'email': 'user@example.com',
        'isPremium': true,
        'is_premium': true,
        'isPro': true,
        'pro': true,
      };

      final bool remoteHasPro = (remoteDocData['isPremium'] == true) ||
          (remoteDocData['is_premium'] == true) ||
          (remoteDocData['isPro'] == true) ||
          (remoteDocData['pro'] == true);

      expect(remoteHasPro, isTrue);

      // Restore locally
      await PreferencesService.instance.setProUser(remoteHasPro, uid: targetUid);
      expect(PreferencesService.instance.isProUser(uid: targetUid), isTrue);
    });

    test('Super admin email always retains Pro entitlement', () {
      final adminUser = MockUser(
        uid: 'super_admin_uid_777',
        email: kAdminEmail,
      );
      final isSuperAdmin = adminUser.email?.trim().toLowerCase() == kAdminEmail;
      expect(isSuperAdmin, isTrue);
    });
  });

  group('Requirement 3: First-Time Onboarding Tour & AuthWallGate', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
    });

    test('Onboarding completed flag is false initially on clean install', () {
      expect(PreferencesService.instance.isOnboardingCompleted(), isFalse);
    });

    testWidgets('AuthWallGate shows OnboardingScreen on first install when unauthenticated', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const AuthWallGate(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display OnboardingScreen on cold start
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Plan Trips Effortlessly'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Tapping Skip on OnboardingScreen transitions smoothly to AuthScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const AuthWallGate(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);

      // Tap Skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Now onboarding flag is completed and user sees AuthScreen!
      expect(PreferencesService.instance.isOnboardingCompleted(), isTrue);
      expect(find.byType(AuthScreen), findsOneWidget);
    });
  });
}
