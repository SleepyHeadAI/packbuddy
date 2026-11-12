import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Vault PIN 5-Attempt 10-Minute Lockout Suite', () {
    test('PreferencesService records failed attempts and enforces 5-attempt 10-min lockout', () async {
      final prefs = PreferencesService.instance;
      expect(prefs.isVaultPinLockedOut(), isFalse);
      expect(prefs.getRecentVaultFailedPinAttemptsCount(), 0);

      // Record 4 attempts
      for (int i = 1; i <= 4; i++) {
        await prefs.recordVaultFailedPinAttempt();
        expect(prefs.getRecentVaultFailedPinAttemptsCount(), i);
        expect(prefs.isVaultPinLockedOut(), isFalse);
        expect(prefs.getVaultPinLockoutRemainingSeconds(), 0);
      }

      // Record 5th attempt -> triggers lockout
      await prefs.recordVaultFailedPinAttempt();
      expect(prefs.getRecentVaultFailedPinAttemptsCount(), 5);
      expect(prefs.isVaultPinLockedOut(), isTrue);
      expect(prefs.getVaultPinLockoutRemainingSeconds(), inInclusiveRange(590, 600));

      // Reset clears lockout
      await prefs.resetVaultFailedPinAttempts();
      expect(prefs.isVaultPinLockedOut(), isFalse);
      expect(prefs.getRecentVaultFailedPinAttemptsCount(), 0);
      expect(prefs.getVaultPinLockoutRemainingSeconds(), 0);
    });

    test('Old failed attempts (>10 minutes) are pruned and do not trigger lockout', () async {
      final prefs = PreferencesService.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final elevenMinutesAgo = now - (11 * 60 * 1000);

      // Manually set 4 old attempts and 1 new attempt in SharedPreferences
      final rawPrefs = await SharedPreferences.getInstance();
      await rawPrefs.setStringList(
        PreferencesService.keyVaultFailedPinAttempts,
        [
          elevenMinutesAgo.toString(),
          (elevenMinutesAgo + 1000).toString(),
          (elevenMinutesAgo + 2000).toString(),
          (elevenMinutesAgo + 3000).toString(),
          now.toString(),
        ],
      );

      // Only the 1 recent attempt within 10 minutes should count!
      expect(prefs.getRecentVaultFailedPinAttemptsCount(), 1);
      expect(prefs.isVaultPinLockedOut(), isFalse);
    });

    testWidgets('VaultLockView displays lockout timer and disables digits when locked out', (tester) async {
      final prefs = PreferencesService.instance;
      await prefs.setVaultPin('4321');

      // Record 5 failed attempts to lock out
      for (int i = 0; i < 5; i++) {
        await prefs.recordVaultFailedPinAttempt();
      }
      expect(prefs.isVaultPinLockedOut(), isTrue);

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
      final prefs = PreferencesService.instance;
      await prefs.setVaultPin('9999');

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
      final prefs = PreferencesService.instance;
      await prefs.setVaultPin('9999');

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

