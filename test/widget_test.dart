import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/auth_screen.dart';
import 'package:packbuddy/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/main.dart';

class _FakeUserInfo extends Fake implements UserInfo {
  @override
  final String providerId;

  _FakeUserInfo({required this.providerId});
}

class _FakeUser extends Fake implements User {
  @override
  final String uid = 'test-smoke-uid';
  @override
  final String? email = 'smoke@packbuddy.com';
  @override
  final bool emailVerified;
  @override
  final List<UserInfo> providerData;

  _FakeUser({
    this.emailVerified = true,
    this.providerData = const [],
  });
}

void main() {
  testWidgets('PackBuddy smoke test - unauthenticated user strictly lands on Auth Wall', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PackBuddyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that PackBuddy Auth Wall renders
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('PackBuddy'), findsWidgets);
    expect(find.text('Google ile Devam Et'), findsOneWidget);
  });

  testWidgets('PackBuddy smoke test - unverified email user lands on EmailVerificationScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserProvider.overrideWithValue(
            _FakeUser(
              emailVerified: false,
              providerData: [_FakeUserInfo(providerId: 'password')],
            ),
          ),
        ],
        child: const PackBuddyApp(),
      ),
    );

    await tester.pump();

    // Verify that EmailVerificationScreen renders
    expect(find.byType(EmailVerificationScreen), findsOneWidget);
    expect(find.text('E-postanızı Doğrulayın'), findsOneWidget);
  });

  testWidgets('PackBuddy smoke test - authenticated and verified user accesses Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserProvider.overrideWithValue(
            _FakeUser(
              emailVerified: true,
              providerData: [_FakeUserInfo(providerId: 'password')],
            ),
          ),
        ],
        child: const PackBuddyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that DashboardScreen renders
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('PackBuddy'), findsWidgets);
    expect(find.text("PackBuddy'ye Hoş Geldiniz"), findsOneWidget);
  });
}
