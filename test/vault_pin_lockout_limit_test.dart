import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/vault_pin_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final pins = VaultPinService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    pins.setMockStorage(null);
    await PreferencesService.init();
    await pins.ensureLoaded();
  });

  group('Vault PIN 5-Attempt 10-Minute Lockout Suite', () {
    test('VaultPinService records failed attempts and enforces 5-attempt 10-min lockout', () async {
      expect(pins.isLockedOut(), isFalse);
      expect(pins.failedAttemptsCount(), 0);

      // Record 4 attempts
      for (int i = 1; i <= 4; i++) {
        await pins.recordFailedAttempt();
        expect(pins.failedAttemptsCount(), i);
        expect(pins.isLockedOut(), isFalse);
        expect(pins.lockoutRemainingSeconds(), 0);
      }

      // Record 5th attempt -> triggers lockout
      await pins.recordFailedAttempt();
      expect(pins.failedAttemptsCount(), 5);
      expect(pins.isLockedOut(), isTrue);
      expect(pins.lockoutRemainingSeconds(), inInclusiveRange(590, 600));

      // Reset clears lockout
      await pins.resetFailedAttempts();
      expect(pins.isLockedOut(), isFalse);
      expect(pins.failedAttemptsCount(), 0);
      expect(pins.lockoutRemainingSeconds(), 0);
    });

    test('Old failed attempts (>10 minutes) are pruned and do not trigger lockout', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elevenMinutesAgo = now - (11 * 60 * 1000);

      // Attempt history lives in secure storage (uid-scoped; 'guest' without Firebase user)
      FlutterSecureStorage.setMockInitialValues({
        'guest_vault_pin_failed_attempts': jsonEncode([
          elevenMinutesAgo,
          elevenMinutesAgo + 1000,
          elevenMinutesAgo + 2000,
          elevenMinutesAgo + 3000,
          now,
        ]),
      });
      pins.resetCacheForTesting();
      await pins.ensureLoaded();

      // Only the 1 recent attempt within 10 minutes should count!
      expect(pins.failedAttemptsCount(), 1);
      expect(pins.isLockedOut(), isFalse);
    });

    testWidgets('VaultLockView displays lockout timer and disables digits when locked out', (tester) async {
      await pins.setPin('4321');

      // Record 5 failed attempts to lock out
      for (int i = 0; i < 5; i++) {
        await pins.recordFailedAttempt();
      }
      expect(pins.isLockedOut(), isTrue);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(body: VaultLockView()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Lockout warning and timer should be rendered
      expect(find.textContaining('Kasa Kilitlendi'), findsOneWidget);
      expect(find.textContaining('Son 10 dakikada 5 kez hatalı PIN girildi'), findsOneWidget);

      // Tapping number buttons does not change input
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(find.byType(AnimatedContainer), findsNWidgets(4)); // PIN dots remain empty

      // Forgot PIN button is still available to allow legit recovery
      expect(find.byKey(const Key('forgot_vault_pin_button')), findsOneWidget);
    });

    testWidgets('Entering incorrect PIN in VaultLockView displays both SnackBar and in-place remaining attempts counter (4/5)', (tester) async {
      await pins.setPin('9999');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(body: VaultLockView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter wrong PIN: 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // In-place prominent warning banner under dots must be visible!
      expect(find.textContaining('Hatalı PIN kodu! Kalan deneme hakkı: 4/5'), findsWidgets);

      // Enter 2nd wrong PIN: 1, 1, 1, 1
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      // Count decrements to 3/5!
      expect(find.textContaining('Hatalı PIN kodu! Kalan deneme hakkı: 3/5'), findsWidgets);
    });

    testWidgets('Entering incorrect PIN in English locale displays "Attempts remaining: 4/5"', (tester) async {
      await pins.setPin('9999');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(body: VaultLockView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter wrong PIN: 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // In English locale
      expect(find.textContaining('Incorrect PIN! Attempts remaining: 4/5'), findsWidgets);
    });
  });
}
