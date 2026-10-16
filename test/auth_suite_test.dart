import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:packbuddy/features/auth/auth_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/auth_screen.dart';
import 'package:packbuddy/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/main.dart';

/// Test Fake implementation of [UserInfo]
class FakeUserInfo extends Fake implements UserInfo {
  @override
  final String providerId;

  FakeUserInfo({required this.providerId});
}

/// Test Fake implementation of [User]
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
    this.emailVerified = false,
    this.providerData = const [],
  });

  @override
  Future<void> reload() async {}

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}
}

/// Test Fake implementation of [UserCredential]
class FakeUserCredential extends Fake implements UserCredential {
  @override
  final User? user;

  FakeUserCredential({this.user});
}

/// Mock [AuthService] for testing
class MockAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _current;
  bool emailVerificationSent = false;
  bool reloadUserCalled = false;

  MockAuthService({User? initialUser}) : _current = initialUser;

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _current;

  void emitUser(User? user) {
    _current = user;
    _controller.add(user);
  }

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (password == 'wrong') {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'Invalid password',
      );
    }
    final user = FakeUser(
      uid: 'uid-email-123',
      email: email,
      emailVerified: true,
      providerData: [FakeUserInfo(providerId: 'password')],
    );
    emitUser(user);
    return FakeUserCredential(user: user);
  }

  @override
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (email == 'existing@test.com') {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'Email in use',
      );
    }
    final user = FakeUser(
      uid: 'uid-new-456',
      email: email,
      emailVerified: false,
      providerData: [FakeUserInfo(providerId: 'password')],
    );
    emailVerificationSent = true;
    emitUser(user);
    return FakeUserCredential(user: user);
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    final user = FakeUser(
      uid: 'uid-google-789',
      email: 'traveler@gmail.com',
      displayName: 'Google Traveler',
      emailVerified: true,
      providerData: [FakeUserInfo(providerId: 'google.com')],
    );
    emitUser(user);
    return FakeUserCredential(user: user);
  }

  @override
  Future<UserCredential?> signInWithApple() async {
    final user = FakeUser(
      uid: 'uid-apple-789',
      email: 'traveler@privaterelay.appleid.com',
      displayName: 'Apple Traveler',
      emailVerified: true,
      providerData: [FakeUserInfo(providerId: 'apple.com')],
    );
    emitUser(user);
    return FakeUserCredential(user: user);
  }

  @override
  Future<void> signOut() async {
    emitUser(null);
  }

  @override
  Future<void> sendEmailVerification() async {
    emailVerificationSent = true;
  }

  @override
  Future<User?> reloadUser() async {
    reloadUserCalled = true;
    return _current;
  }

  bool syncUserProfileCalled = false;
  User? syncedUser;

  @override
  Future<bool> syncUserProfile(User user) async {
    syncUserProfileCalled = true;
    syncedUser = user;
    return false;
  }

  @override
  Future<void> updateLastActive(String uid) async {}

  @override
  void Function(String uid)? onAccountRestoredFromDeletion;

  @override
  Future<void> requestAccountDeletion(String uid) async {}

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('1. AuthController Unit Tests & Verification State', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    tearDown(() {
      mockAuthService.dispose();
    });

    test('Initial state is unauthenticated with null user', () {
      final controller = AuthController(mockAuthService);
      expect(controller.state.user, isNull);
      expect(controller.state.isAuthenticated, isFalse);
      expect(controller.state.requiresEmailVerification, isFalse);
    });

    test('signUpWithEmail triggers automatic sendEmailVerification', () async {
      final controller = AuthController(mockAuthService);
      final success = await controller.signUpWithEmail(
        email: 'new@packbuddy.com',
        password: 'Password123',
      );

      expect(success, isTrue);
      expect(mockAuthService.emailVerificationSent, isTrue);
      expect(controller.state.user, isNotNull);
      expect(controller.state.user!.emailVerified, isFalse);
      expect(controller.state.requiresEmailVerification, isTrue);
    });

    test('sendEmailVerification manually triggers link dispatch', () async {
      final controller = AuthController(mockAuthService);
      mockAuthService.emailVerificationSent = false;

      final success = await controller.sendEmailVerification();
      expect(success, isTrue);
      expect(mockAuthService.emailVerificationSent, isTrue);
    });

    test('reloadUser fetches latest user verification state', () async {
      final unverifiedUser = FakeUser(
        uid: 'uid-test',
        email: 'test@packbuddy.com',
        emailVerified: false,
      );
      final service = MockAuthService(initialUser: unverifiedUser);
      final controller = AuthController(service);

      expect(controller.state.isEmailVerified, isFalse);

      // Simulate verification completion
      final verifiedUser = FakeUser(
        uid: 'uid-test',
        email: 'test@packbuddy.com',
        emailVerified: true,
      );
      service.emitUser(verifiedUser);

      final isVerified = await controller.reloadUser();
      expect(isVerified, isTrue);
      expect(service.reloadUserCalled, isTrue);
      expect(controller.state.isEmailVerified, isTrue);
      expect(controller.state.requiresEmailVerification, isFalse);
    });

    test('signUpWithEmail triggers syncUserProfile', () async {
      final controller = AuthController(mockAuthService);
      mockAuthService.syncUserProfileCalled = false;

      final success = await controller.signUpWithEmail(
        email: 'user@packbuddy.com',
        password: 'Password123',
      );

      expect(success, isTrue);
      expect(mockAuthService.syncUserProfileCalled, isTrue);
      expect(mockAuthService.syncedUser?.email, 'user@packbuddy.com');
    });

    test('signInWithEmail triggers syncUserProfile', () async {
      final controller = AuthController(mockAuthService);
      mockAuthService.syncUserProfileCalled = false;

      final success = await controller.signInWithEmail(
        email: 'login@packbuddy.com',
        password: 'Password123',
      );

      expect(success, isTrue);
      expect(mockAuthService.syncUserProfileCalled, isTrue);
      expect(mockAuthService.syncedUser?.email, 'login@packbuddy.com');
    });

    test('reloadUser triggers syncUserProfile when user reloads', () async {
      final verifiedUser = FakeUser(
        uid: 'uid-verified-1',
        email: 'verified@packbuddy.com',
        emailVerified: true,
      );
      final service = MockAuthService(initialUser: verifiedUser);
      final controller = AuthController(service);
      service.syncUserProfileCalled = false;

      await controller.reloadUser();
      expect(service.syncUserProfileCalled, isTrue);
      expect(service.syncedUser?.uid, 'uid-verified-1');
    });
  });

  group('2. Strict Password Validation in Sign-Up Flow', () {
    testWidgets('Rejects weak password in Sign-Up mode (<8 characters)', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockAuth = MockAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Kayıt Ol (Sign Up)
      await tester.tap(find.text('Kayıt Ol').first);
      await tester.pumpAndSettle();

      // Enter valid email but short password
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'traveler@packbuddy.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Pass1',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Pass1',
      );

      // Tap Submit
      await tester.ensureVisible(find.text('Hesap Oluştur'));
      await tester.tap(find.text('Hesap Oluştur'));
      await tester.pumpAndSettle();

      // Verify inline error message
      expect(
        find.text('Şifre kurallara uygun değil.'),
        findsOneWidget,
      );
    });

    testWidgets('Rejects password missing uppercase letter', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockAuth = MockAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Kayıt Ol').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'traveler@packbuddy.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'lowercase1234', // no uppercase
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'lowercase1234',
      );

      await tester.ensureVisible(find.text('Hesap Oluştur'));
      await tester.tap(find.text('Hesap Oluştur'));
      await tester.pumpAndSettle();

      expect(
        find.text('Şifre kurallara uygun değil.'),
        findsOneWidget,
      );
    });

    testWidgets('Rejects password missing numbers', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockAuth = MockAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Kayıt Ol').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'traveler@packbuddy.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'NoNumbersHere', // no digits
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'NoNumbersHere',
      );

      await tester.ensureVisible(find.text('Hesap Oluştur'));
      await tester.tap(find.text('Hesap Oluştur'));
      await tester.pumpAndSettle();

      expect(
        find.text('Şifre kurallara uygun değil.'),
        findsOneWidget,
      );
    });

    testWidgets('Accepts compliant strong password', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockAuth = MockAuthService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Kayıt Ol').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'valid@packbuddy.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'PackBuddy2026', // Meets all strict requirements
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'PackBuddy2026',
      );

      await tester.ensureVisible(find.text('Hesap Oluştur'));
      await tester.tap(find.text('Hesap Oluştur'));
      await tester.pumpAndSettle();

      // No validation errors should be present
      expect(
        find.text('Şifre kurallara uygun değil.'),
        findsNothing,
      );
    });
  });

  group('3. EmailVerificationScreen Widget Tests', () {
    testWidgets('Renders Envelope Icon, email pill, check and resend buttons', (tester) async {
      final unverifiedUser = FakeUser(
        uid: 'uid-unverified',
        email: 'security@packbuddy.com',
        emailVerified: false,
        providerData: [FakeUserInfo(providerId: 'password')],
      );
      final mockAuth = MockAuthService(initialUser: unverifiedUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: EmailVerificationScreen(),
          ),
        ),
      );

      await tester.pump();

      // Envelope Icon and Title
      expect(find.byIcon(Icons.mark_email_unread_rounded), findsOneWidget);
      expect(find.text('E-postanızı Doğrulayın'), findsOneWidget);
      expect(find.text('security@packbuddy.com'), findsOneWidget);

      // Buttons
      expect(find.text('Doğruladım, Devam Et'), findsOneWidget);
      expect(find.text('Doğrulama E-postasını Tekrar Gönder'), findsOneWidget);
      expect(find.text('Giriş Ekranına Dön'), findsOneWidget);
    });

    testWidgets('Tapping Giriş Ekranına Dön signs out user', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final unverifiedUser = FakeUser(
        uid: 'uid-unverified',
        email: 'security@packbuddy.com',
        emailVerified: false,
      );
      final mockAuth = MockAuthService(initialUser: unverifiedUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: EmailVerificationScreen(),
          ),
        ),
      );

      await tester.pump();

      await tester.ensureVisible(find.text('Giriş Ekranına Dön'));
      await tester.tap(find.text('Giriş Ekranına Dön'));
      await tester.pump();

      expect(mockAuth.currentUser, isNull);
    });
  });

  group('4. Auth Wall Gate Verification Routing Tests', () {
    testWidgets('Unauthenticated user is strictly routed to AuthScreen', (tester) async {
      final mockAuth = MockAuthService(initialUser: null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: AuthWallGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.byType(EmailVerificationScreen), findsNothing);
      expect(find.byType(DashboardScreen), findsNothing);
    });

    testWidgets('Unverified password user is strictly routed to EmailVerificationScreen', (tester) async {
      final unverifiedUser = FakeUser(
        uid: 'user-unverified-1',
        email: 'unverified@packbuddy.com',
        emailVerified: false,
        providerData: [FakeUserInfo(providerId: 'password')],
      );
      final mockAuth = MockAuthService(initialUser: unverifiedUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: AuthWallGate(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(EmailVerificationScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);
      expect(find.byType(AuthScreen), findsNothing);
    });

    testWidgets('Verified user is routed straight to DashboardScreen', (tester) async {
      final verifiedUser = FakeUser(
        uid: 'user-verified-1',
        email: 'verified@packbuddy.com',
        emailVerified: true,
        providerData: [FakeUserInfo(providerId: 'password')],
      );
      final mockAuth = MockAuthService(initialUser: verifiedUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: AuthWallGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(EmailVerificationScreen), findsNothing);
      expect(find.byType(AuthScreen), findsNothing);
    });

    testWidgets('Google OAuth user bypasses email verification gate to DashboardScreen', (tester) async {
      final googleUser = FakeUser(
        uid: 'user-google-1',
        email: 'google@packbuddy.com',
        emailVerified: false, // Even if raw flag is false, OAuth bypasses password gate
        providerData: [FakeUserInfo(providerId: 'google.com')],
      );
      final mockAuth = MockAuthService(initialUser: googleUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: AuthWallGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(EmailVerificationScreen), findsNothing);
    });
  });
}
