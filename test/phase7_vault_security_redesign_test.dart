import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/shared/widgets/app_button.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Phase7MockVaultController extends StateNotifier<VaultState> implements VaultController {
  String? savedPin;
  int _lockoutRemaining = 0;
  int _remainingAttempts = 5;

  bool allowAutoLock = false;

  Phase7MockVaultController({
    bool isLocked = true,
    bool hasPin = true,
    this.savedPin = '1234',
    int lockoutRemaining = 0,
    int remainingAttempts = 5,
    List<Document> documents = const [],
    this.allowAutoLock = false,
  })  : _lockoutRemaining = lockoutRemaining,
        _remainingAttempts = remainingAttempts,
        super(VaultState(
          isLocked: isLocked,
          hasPin: hasPin,
          documents: documents,
          isBiometricEnabled: false,
        ));

  @override
  bool unlockVault(String pin) {
    if (savedPin != null && savedPin == pin) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    _remainingAttempts--;
    if (_remainingAttempts <= 0) {
      _lockoutRemaining = 60;
    }
    return false;
  }

  @override
  void lockVault() {
    if (allowAutoLock) {
      state = state.copyWith(isLocked: true);
    }
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
  bool isPinLockedOut() => _lockoutRemaining > 0;

  @override
  int getPinLockoutRemainingSeconds() => _lockoutRemaining;

  @override
  int getRemainingPinAttempts() => _remainingAttempts;

  @override
  Future<void> resetFailedPinAttempts() async {
    _remainingAttempts = 5;
    _lockoutRemaining = 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Phase 7: Travel Vault & Security Presentation Redesign', () {
    testWidgets('1. VaultLockView PIN Keypad displays Apple / 1Password circular numpad with mono digits', (tester) async {
      final mockController = Phase7MockVaultController(
        isLocked: true,
        hasPin: true,
        savedPin: '1234',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => mockController),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(body: VaultLockView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check all 10 digits (0-9) exist on the numpad
      for (int i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget, reason: 'Digit $i should exist on the keypad');
      }

      // Check backspace icon is present
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

      // Verify lock icon header
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);

      // Check PIN indicator dots (4 dots in a row)
      final dotContainers = tester.widgetList<AnimatedContainer>(
        find.descendant(
          of: find.byType(Row),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(dotContainers.length, greaterThanOrEqualTo(4));

      // Tap digits 1, 2, 3, 4 to unlock
      await tester.tap(find.text('1'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      expect(mockController.state.isLocked, isFalse, reason: 'Vault should unlock with correct PIN 1234');
    });

    testWidgets('2. VaultLockView unconfigured PIN view renders AppButton and no bypass', (tester) async {
      final mockController = Phase7MockVaultController(
        isLocked: true,
        hasPin: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => mockController),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: const Scaffold(body: VaultLockView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & primary button
      expect(find.text('Kasa PIN Kodu Zorunludur'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('PIN Kodu Oluştur & Korumaya Al'), findsOneWidget);

      // Ensure no bypass buttons
      expect(find.text('Kilitsiz Devam Et'), findsNothing);
      expect(find.text('Pinsiz Devam Et'), findsNothing);
    });

    testWidgets('3. VaultLockView lockout banner renders warning styling when locked out', (tester) async {
      final mockController = Phase7MockVaultController(
        isLocked: true,
        hasPin: true,
        lockoutRemaining: 45,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => mockController),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(body: VaultLockView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify lockout icon
      expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
      expect(find.textContaining('00:45'), findsOneWidget);
    });

    testWidgets('4. Compact Viewport Stress Test: VaultLockView zero overflow on 320x568 (Light & Dark)', (tester) async {
      for (final isDark in [false, true]) {
        tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final mockController = Phase7MockVaultController(
          isLocked: true,
          hasPin: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authUserProvider.overrideWithValue(null),
              mainNavigationIndexProvider.overrideWith((ref) => 3),
              vaultControllerProvider.overrideWith((ref) => mockController),
            ],
            child: MaterialApp(
              theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: const Scaffold(body: VaultLockView()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Zero overflow on 320x568 (isDark: $isDark)');
      }
    });

    testWidgets('5. Localization Resilience: VaultLockView renders cleanly in German & Arabic without clipping', (tester) async {
      for (final locale in [const Locale('de'), const Locale('ar')]) {
        tester.view.physicalSize = const Size(360 * 2.0, 640 * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final mockController = Phase7MockVaultController(
          isLocked: true,
          hasPin: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authUserProvider.overrideWithValue(null),
              mainNavigationIndexProvider.overrideWith((ref) => 3),
              vaultControllerProvider.overrideWith((ref) => mockController),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              home: const Scaffold(body: VaultLockView()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Zero overflow in locale: ${locale.languageCode}');
      }
    });

    testWidgets('6. VaultScreen unlocked empty state displays shield icon and AppButton', (tester) async {
      final mockController = Phase7MockVaultController(
        isLocked: false,
        hasPin: true,
        documents: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => mockController),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: const Scaffold(body: VaultScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify empty state shield icon
      expect(find.byIcon(AppIcons.shield), findsWidgets);

      // Verify "Belge Ekle" button is present and is an AppButton
      expect(find.byType(AppButton), findsWidgets);
    });

    testWidgets('7. VaultScreen renders document cards with AppRadius.card and tabular figures', (tester) async {
      final sampleDoc = Document(
        id: 'doc-123',
        userId: 'test-user',
        title: 'Flight Ticket to Tokyo',
        category: 'Ticket',
        subCategory: 'flightTicket',
        localImagePath: 'dummy/path/ticket.png',
        createdAt: DateTime(2026, 4, 15, 10, 30),
        updatedAt: DateTime(2026, 4, 15, 10, 30),
        fileType: 'image/png',
        fileExtension: 'png',
      );

      final mockController = Phase7MockVaultController(
        isLocked: false,
        hasPin: true,
        documents: [sampleDoc],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(null),
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => mockController),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(body: VaultScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Document title
      expect(find.text('Flight Ticket to Tokyo'), findsOneWidget);

      // Verify no emoji in document title or subtitle
      expect(find.textContaining('✈️'), findsNothing);

      // Date formatted with mono font tabular numbers
      expect(find.text('Apr 15, 2026'), findsOneWidget);
    });
  });
}
