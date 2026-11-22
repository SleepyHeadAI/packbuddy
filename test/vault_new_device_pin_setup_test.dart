import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/vault_pin_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_pin_recovery_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// New device / reinstall: the PIN is device-local (C3), so there is no local PIN hash.
/// The vault must offer "create PIN" directly, without forcing e-mail recovery.
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

  Widget buildApp(ProviderContainer container) => UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: VaultLockView()),
        ),
      );

  ProviderContainer makeContainer() => ProviderContainer(overrides: [
        authUserProvider.overrideWithValue(null),
        mainNavigationIndexProvider.overrideWith((ref) => 3),
      ]);

  testWidgets('hasPin == false shows "create PIN" directly; no forgot-PIN / e-mail recovery', (tester) async {
    final container = makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(container.read(vaultControllerProvider).hasPin, isFalse);
    expect(find.text(l10n.createPinAndProtect), findsOneWidget);
    expect(find.byKey(const Key('forgot_vault_pin_button')), findsNothing);

    await tester.tap(find.text(l10n.createPinAndProtect));
    await tester.pumpAndSettle();

    // The create-PIN dialog opens directly — not the e-mail recovery sheet.
    expect(find.byType(VaultPinRecoverySheet), findsNothing);
    expect(find.text(l10n.setVaultPin), findsOneWidget);

    await tester.enterText(find.byType(TextField), '2580');
    await tester.tap(find.text(l10n.saveAndOpen));
    await tester.pumpAndSettle();

    expect(pins.hasPin(), isTrue);
    expect(pins.verifyPin('2580'), isTrue);
    expect(container.read(vaultControllerProvider).hasPin, isTrue);
    expect(container.read(vaultControllerProvider).isLocked, isFalse);
  });

  testWidgets('"create PIN" never overwrites a PIN that exists but was not yet in the UI state', (tester) async {
    final container = makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.createPinAndProtect), findsOneWidget);

    // A PIN appears in secure storage behind the UI's back (e.g. account switch race).
    await pins.setPin('1111');

    await tester.tap(find.text(l10n.createPinAndProtect));
    await tester.pumpAndSettle();

    // No create dialog; the view refreshes to the PIN pad and the existing PIN is intact.
    expect(find.text(l10n.setVaultPin), findsNothing);
    expect(container.read(vaultControllerProvider).hasPin, isTrue);
    expect(pins.verifyPin('1111'), isTrue);
  });
}
