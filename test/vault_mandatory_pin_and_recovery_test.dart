import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_pin_recovery_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVaultController extends StateNotifier<VaultState> implements VaultController {
  String? savedPin;

  MockVaultController({
    bool isLocked = true,
    bool hasPin = false,
    this.savedPin,
  }) : super(VaultState(isLocked: isLocked, hasPin: hasPin));

  @override
  bool unlockVault(String pin) {
    if (savedPin != null && savedPin == pin) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  @override
  void lockVault() {
    state = state.copyWith(isLocked: true);
  }

  @override
  Future<void> setPin(String pin) async {
    savedPin = pin;
    state = state.copyWith(hasPin: true);
  }

  @override
  Future<void> removePin() async {
    savedPin = null;
    state = state.copyWith(hasPin: false, isLocked: true);
  }

  @override
  bool isPinLockedOut() => false;

  @override
  int getPinLockoutRemainingSeconds() => 0;

  @override
  int getRemainingPinAttempts() => 5;

  @override
  Future<void> resetFailedPinAttempts() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Mandatory Vault PIN & Email Recovery Verification Suite', () {
    testWidgets('1. VaultLockView requires PIN when unconfigured and has NO bypass button', (tester) async {
      final mockController = MockVaultController(isLocked: true, hasPin: false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => mockController),
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

      // Verify mandatory PIN title & description are shown
      expect(find.text('Kasa PIN Kodu Zorunludur'), findsOneWidget);
      expect(find.textContaining('4 haneli bir PIN kodu oluşturmanız zorunludur'), findsOneWidget);
      expect(find.text('PIN Kodu Oluştur & Korumaya Al'), findsOneWidget);

      // Verify STRICT absence of "Kilitsiz Devam Et" / "Pinsiz Devam Et" bypass
      expect(find.text('Kilitsiz Devam Et'), findsNothing);
      expect(find.text('Pinsiz Devam Et'), findsNothing);
      expect(find.text('Şimdi Kilitsiz Devam Et'), findsNothing);
      expect(find.text('Devam Et'), findsNothing);
      expect(find.byKey(const Key('forgot_vault_pin_button')), findsNothing);
    });

    testWidgets('2. VaultLockView shows PIN keypad and "PIN\'imi Unuttum" button when PIN configured', (tester) async {
      final mockController = MockVaultController(isLocked: true, hasPin: true, savedPin: '1234');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => mockController),
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

      expect(find.text('Kasa Kilitli'), findsOneWidget);
      expect(find.text('Pasaport ve seyahat belgelerinizi açmak için PIN kodunu girin'), findsOneWidget);
      expect(find.byKey(const Key('forgot_vault_pin_button')), findsOneWidget);
      expect(find.text("PIN Kodumu Unuttum"), findsOneWidget);

      // Verify keypad keys 1-9 and 0 exist
      for (var digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
        expect(find.text(digit), findsOneWidget);
      }
    });

    testWidgets('3. Complete 3-Step Email Verification & Vault PIN Recovery Flow', (tester) async {
      final mockController = MockVaultController(isLocked: true, hasPin: true, savedPin: '1234');
      const testCode = '749201';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => mockController),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: Scaffold(
              body: VaultPinRecoverySheet(testVerificationCode: testCode),
            ),
          ),
        ),
      );
      await tester.pump();

      // --- STEP 0: Email Input ---
      expect(find.text('Kasa PIN Kodunu Sıfırla'), findsOneWidget);
      expect(find.byKey(const Key('recovery_email_field')), findsOneWidget);
      expect(find.byKey(const Key('send_recovery_code_button')), findsOneWidget);

      // Enter valid email and submit
      await tester.enterText(find.byKey(const Key('recovery_email_field')), 'traveler@example.com');
      await tester.pump();
      await tester.tap(find.byKey(const Key('send_recovery_code_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // --- STEP 1: 6-Digit Code Verification ---
      expect(find.byKey(const Key('recovery_verification_code_field')), findsOneWidget);
      expect(find.byKey(const Key('verify_recovery_code_button')), findsOneWidget);

      // Try invalid code first
      await tester.enterText(find.byKey(const Key('recovery_verification_code_field')), '111111');
      await tester.pump();
      await tester.tap(find.byKey(const Key('verify_recovery_code_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Error message should appear
      expect(find.text('Doğrulama kodu hatalı. Lütfen kontrol edip tekrar deneyin.'), findsOneWidget);

      // Enter correct code and submit
      await tester.enterText(find.byKey(const Key('recovery_verification_code_field')), testCode);
      await tester.pump();
      await tester.tap(find.byKey(const Key('verify_recovery_code_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // --- STEP 2: Set New PIN ---
      expect(find.text('Yeni Kasa PIN Kodu Belirleyin'), findsOneWidget);
      expect(find.byKey(const Key('new_vault_pin_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_vault_pin_field')), findsOneWidget);
      expect(find.byKey(const Key('save_new_vault_pin_button')), findsOneWidget);

      // Enter mismatched PINs
      await tester.enterText(find.byKey(const Key('new_vault_pin_field')), '9876');
      await tester.enterText(find.byKey(const Key('confirm_vault_pin_field')), '9877');
      await tester.pump();
      await tester.tap(find.byKey(const Key('save_new_vault_pin_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Error message for mismatch
      expect(find.text('Girdiğiniz PIN kodları birbiriyle eşleşmiyor.'), findsOneWidget);

      // Enter matching PINs
      await tester.enterText(find.byKey(const Key('new_vault_pin_field')), '9876');
      await tester.enterText(find.byKey(const Key('confirm_vault_pin_field')), '9876');
      await tester.pump();
      await tester.tap(find.byKey(const Key('save_new_vault_pin_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that controller updated PIN and unlocked vault
      expect(mockController.savedPin, '9876');
      expect(mockController.state.isLocked, isFalse);
      expect(mockController.state.hasPin, isTrue);
    });

    testWidgets('4. Multilingual & Multi-Size Screen Verification for PIN Recovery Sheet', (tester) async {
      const locales = [Locale('en'), Locale('de'), Locale('es'), Locale('fr'), Locale('ar'), Locale('ja')];
      const viewports = [Size(320, 568), Size(390, 844), Size(800, 1280)];

      for (final locale in locales) {
        for (final size in viewports) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authUserProvider.overrideWithValue(null),
              ],
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: locale,
                home: const Scaffold(
                  body: VaultPinRecoverySheet(testVerificationCode: '123456'),
                ),
              ),
            ),
          );
          await tester.pump();

          // Check that no RenderFlex overflow error occurs
          expect(tester.takeException(), isNull,
              reason: 'Overflow on size: $size with locale: ${locale.languageCode}');
        }
      }
    });

    test('5. VaultController Unit: PIN is strictly required to unlock', () async {
      final prefs = PreferencesService.instance;
      await prefs.setVaultPin(null);

      // Fake Ref mock
      final container = ProviderContainer();
      final controller = container.read(vaultControllerProvider.notifier);

      // Trying to unlock when savedPin is null must fail
      expect(controller.unlockVault('1234'), isFalse);
      expect(controller.unlockVault(''), isFalse);

      // Setting a PIN
      await controller.setPin('4321');
      expect(controller.state.hasPin, isTrue);

      // Unlocking with wrong PIN must fail
      expect(controller.unlockVault('0000'), isFalse);

      // Unlocking with correct PIN succeeds
      expect(controller.unlockVault('4321'), isTrue);
      expect(controller.state.isLocked, isFalse);

      // Removing PIN locks the vault
      await controller.removePin();
      expect(controller.state.hasPin, isFalse);
      expect(controller.state.isLocked, isTrue);
    });
  });
}
