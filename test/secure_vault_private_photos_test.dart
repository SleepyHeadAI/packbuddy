import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  FakeVaultController([VaultState? state])
      : super(state ?? const VaultState(isLoading: false, documents: []));

  int _failedAttempts = 0;

  @override
  void lockVault() {
    state = state.copyWith(isLocked: true);
  }

  @override
  bool unlockVault(String pin) {
    if (pin == '1234') {
      state = state.copyWith(isLocked: false);
      _failedAttempts = 0;
      return true;
    }
    _failedAttempts++;
    return false;
  }

  @override
  bool isPinLockedOut() => _failedAttempts >= 5;

  @override
  int getPinLockoutRemainingSeconds() => _failedAttempts >= 5 ? 600 : 0;

  @override
  int getRemainingPinAttempts() => (5 - _failedAttempts).clamp(0, 5);

  @override
  Future<void> resetFailedPinAttempts() async {
    _failedAttempts = 0;
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

  group('Güvenli Kasa & Özel Resimler (Private Photos) Suite', () {
    final regularDoc = Document(
      id: 'doc-1',
      userId: 'user-1',
      title: 'Uçak Bileti IST-JFK',
      category: 'Ticket',
      localImagePath: '/vault/ticket.pdf',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final privatePhoto = Document(
      id: 'doc-private-1',
      userId: 'user-1',
      title: 'Gizli Aile Resmi',
      category: 'PrivatePhotos',
      localImagePath: '/vault/private_pic.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('1. Vault title renders as "Güvenli Kasa" (not "Belge Kasası")', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith(
              (ref) => FakeVaultController(
                VaultState(
                  isLocked: false,
                  hasPin: true,
                  documents: [regularDoc],
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(isTabMode: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Güvenli Kasa'), findsWidgets);
      expect(find.text('Belge Kasası'), findsNothing);
    });

    testWidgets('2. Opening vault with PIN locks it immediately, unlocking reveals regular docs but hides private photos', (tester) async {
      final controller = FakeVaultController(
        VaultState(
          isLocked: true,
          hasPin: true,
          documents: [regularDoc, privatePhoto],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(isTabMode: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vault is initially locked
      expect(find.byType(VaultLockView), findsOneWidget);

      // User unlocks vault by entering 4-digit PIN
      await tester.tap(find.text('1').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Lock view is gone
      expect(find.byType(VaultLockView), findsNothing);

      // Regular document must be visible
      expect(find.text('Uçak Bileti IST-JFK'), findsOneWidget);

      // Private photo MUST NOT appear on the safe main page
      expect(find.text('Gizli Aile Resmi'), findsNothing);

      // Public count in hero card and chip must only show 1 (excluding private photo)
      expect(find.text('Tüm Belgeler (1)'), findsOneWidget);
    });

    testWidgets('3. Tapping "Özel Kasa" opens authentication sheet when locked, unlocking shows private photos', (tester) async {
      final controller = FakeVaultController(
        VaultState(
          isLocked: true,
          hasPin: true,
          documents: [regularDoc, privatePhoto],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(isTabMode: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First unlock the main vault
      await tester.tap(find.text('1').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Find and tap the "Özel Kasa" portal card
      final privateChip = find.byKey(const Key('private_photos_chip'));
      expect(privateChip, findsOneWidget);
      expect(find.text('Özel Kasa'), findsOneWidget);

      await tester.tap(privateChip);
      await tester.pumpAndSettle();

      // PIN keypad bottom sheet must appear prompting for PIN/Biometric verification
      expect(find.text('Pasaport ve seyahat belgelerinizi açmak için PIN kodunu girin'), findsOneWidget);

      // Type 4 digits in modal sheet: 1, 2, 3, 4
      await tester.tap(find.text('1').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Bottom sheet closes and Private Photos view is now revealed!
      expect(find.text('Gizli Aile Resmi'), findsOneWidget);
      expect(find.text('Kilitle ve Çık'), findsOneWidget);

      // Regular documents should now be excluded from this private category view
      expect(find.text('Uçak Bileti IST-JFK'), findsNothing);
    });

    testWidgets('4. "Kilitle ve Çık" locks private photos and returns to main view', (tester) async {
      final controller = FakeVaultController(
        VaultState(
          isLocked: true,
          hasPin: true,
          documents: [regularDoc, privatePhoto],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(isTabMode: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Unlock main vault
      await tester.tap(find.text('1').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Tap Özel Kasa portal card and authenticate
      await tester.tap(find.byKey(const Key('private_photos_chip')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      expect(find.text('Gizli Aile Resmi'), findsOneWidget);

      // Now tap "Kilitle ve Çık"
      await tester.tap(find.text('Kilitle ve Çık'));
      await tester.pumpAndSettle();

      // Private photo is hidden again!
      expect(find.text('Gizli Aile Resmi'), findsNothing);
      expect(find.text('Uçak Bileti IST-JFK'), findsOneWidget);
    });

    test('5. Document with category "Ticket" but titled "Private Photos" evaluates isPrivate == true', () {
      final docTitledPrivate = Document(
        id: 'doc-user-upload',
        userId: 'user-roan',
        title: 'Private Photos',
        category: 'Ticket',
        localImagePath: '/vault/photo1.jpg',
        fileSizeBytes: 1300000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(docTitledPrivate.isPrivate, isTrue);

      final json = docTitledPrivate.toJson();
      expect(json['isPrivate'], isTrue);
      expect(json['is_private'], 1);

      final restored = Document.fromJson(json);
      expect(restored.isPrivate, isTrue);
    });

    test('6. Document with Turkish title "Özel Resimler" evaluates isPrivate == true across serialization', () {
      final docTr = Document(
        id: 'doc-tr-1',
        userId: 'user-enes',
        title: 'Özel Resimler',
        category: 'Ticket',
        localImagePath: '/vault/photo2.jpg',
        fileSizeBytes: 800000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(docTr.isPrivate, isTrue);

      final map = docTr.toMap();
      expect(map['is_private'], 1);

      final fromMap = Document.fromMap(map);
      expect(fromMap.isPrivate, isTrue);
    });

    testWidgets('7. Incorrect PIN in Private Photos modal displays visible remaining attempts counter (4/5) and notification', (tester) async {
      final controller = FakeVaultController(
        VaultState(
          isLocked: true,
          hasPin: true,
          documents: [regularDoc, privatePhoto],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(isTabMode: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Unlock main vault with correct PIN: 1, 2, 3, 4
      await tester.tap(find.text('1').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('2').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('3').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // Tap "Özel Kasa" chip to open Private Photos authentication modal
      await tester.tap(find.byKey(const Key('private_photos_chip')));
      await tester.pumpAndSettle();

      // Modal is open, enter WRONG PIN: 9, 9, 9, 9
      await tester.tap(find.text('9').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('9').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('9').last);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('9').last);
      await tester.pumpAndSettle();

      // Visible in-place attempt limit text must appear on the modal!
      expect(find.textContaining('Hatalı PIN kodu! Kalan deneme hakkı: 4/5'), findsWidgets);
    });
  });
}
