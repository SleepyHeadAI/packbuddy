import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeVaultController extends VaultController {
  FakeVaultController(super.ref, VaultState initialState) {
    state = initialState;
  }

  @override
  void lockVault() {
    state = state.copyWith(isLocked: true);
  }

  @override
  bool unlockVault(String pin) {
    state = state.copyWith(isLocked: false);
    return true;
  }
}

void main() {
  group('Vault Biometric Strict Tab Isolation Suite', () {
    testWidgets('VaultScreen in shell mode (isTabMode: true) renders empty shell when user is on Home tab (0)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mainNavigationIndexProvider.overrideWith((ref) => 0),
            vaultControllerProvider.overrideWith(
              (ref) => FakeVaultController(
                ref,
                const VaultState(
                  hasPin: true,
                  isLocked: true,
                  isBiometricEnabled: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(isTabMode: true),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Because user is on tab 0 (Home), VaultLockView must NOT be built or mounted in the tree!
      expect(find.byType(VaultLockView), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('VaultScreen renders VaultLockView when user navigates to Vault tab (3)', (tester) async {
      final container = ProviderContainer(
        overrides: [
          mainNavigationIndexProvider.overrideWith((ref) => 3),
          vaultControllerProvider.overrideWith(
            (ref) => FakeVaultController(
              ref,
              const VaultState(
                hasPin: true,
                isLocked: true,
                isBiometricEnabled: true,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(isTabMode: true),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // On Vault tab (3), VaultLockView must be present and active
      expect(find.byType(VaultLockView), findsOneWidget);
    });

    testWidgets('Switching away from Vault tab (3 -> 0) locks vault and unmounts VaultLockView', (tester) async {
      final container = ProviderContainer(
        overrides: [
          mainNavigationIndexProvider.overrideWith((ref) => 3),
          vaultControllerProvider.overrideWith(
            (ref) => FakeVaultController(
              ref,
              const VaultState(
                hasPin: true,
                isLocked: true,
                isBiometricEnabled: true,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(isTabMode: true),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(VaultLockView), findsOneWidget);

      // User switches to Home tab (0)
      container.read(mainNavigationIndexProvider.notifier).state = 0;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // VaultLockView is unmounted completely so zero biometrics can trigger in background
      expect(find.byType(VaultLockView), findsNothing);
    });

    testWidgets('VaultLockView with isTabMode: true suppresses biometrics when active tab is not 3', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mainNavigationIndexProvider.overrideWith((ref) => 1), // Map tab
            vaultControllerProvider.overrideWith(
              (ref) => FakeVaultController(
                ref,
                const VaultState(
                  hasPin: true,
                  isLocked: true,
                  isBiometricEnabled: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: VaultLockView(isTabMode: true),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Renders UI safely but no error snackbars or biometric triggers
      expect(find.text('0'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}

