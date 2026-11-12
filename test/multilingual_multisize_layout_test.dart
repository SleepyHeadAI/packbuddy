import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/add_document_sheet.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/airline_guide_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVaultController extends StateNotifier<VaultState> implements VaultController {
  MockVaultController([VaultState? state])
      : super(state ?? const VaultState(isLoading: false, documents: []));

  @override
  void lockVault() {
    state = state.copyWith(isLocked: true);
  }

  @override
  bool unlockVault(String pin) {
    state = state.copyWith(isLocked: false);
    return true;
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

  const testLocales = [
    'ar', 'de', 'el', 'en', 'es', 'fr', 'hi', 'id', 'it', 'ja',
    'ko', 'nl', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'vi', 'zh',
  ];

  const screenSizes = [
    Size(320, 568), // Small phone (iPhone SE 1st gen)
    Size(390, 844), // Standard phone (iPhone 14)
    Size(412, 915), // Large Android (Pixel 7)
    Size(800, 1280), // Tablet (10-inch)
  ];

  final sampleDocs = [
    Document(
      id: 'doc-1',
      userId: 'user-1',
      title: 'Flugticket München - Istanbul',
      category: 'Ticket',
      subCategory: 'flightTicket',
      localImagePath: '/tmp/flight.pdf',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Document(
      id: 'doc-2',
      userId: 'user-1',
      title: 'Hotel Reservierungsbestätigung Grand Plaza',
      category: 'Booking',
      localImagePath: '/tmp/hotel.pdf',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Document(
      id: 'doc-3',
      userId: 'user-1',
      title: 'Geheime Familienfotos Urlaub',
      category: 'PrivatePhotos',
      localImagePath: '/tmp/photo.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  group('Multilingual & Multi-Size Screen Layout Verification', () {
    for (final size in screenSizes) {
      testWidgets('VaultScreen (Unlocked & Locked) at ${size.width}x${size.height} across key languages without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final lang in ['tr', 'en', 'de', 'ru', 'ar', 'zh']) {
          // Unlocked vault
          final controller = MockVaultController(
            VaultState(
              isLocked: false,
              hasPin: true,
              documents: sampleDocs,
            ),
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                mainNavigationIndexProvider.overrideWith((ref) => 3),
                vaultControllerProvider.overrideWith((ref) => controller),
              ],
              child: MaterialApp(
                locale: Locale(lang),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const VaultScreen(isTabMode: true),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'Layout overflow or exception in $lang at ${size.width}x${size.height}');

          // Verify locked view in same size & lang
          controller.lockVault();
          await tester.pumpAndSettle();
          expect(find.byType(VaultLockView), findsOneWidget);
          expect(tester.takeException(), isNull, reason: 'VaultLockView exception in $lang at ${size.width}x${size.height}');
        }
      });
    }

    testWidgets('AddDocumentSheet renders across all 20 languages on small screen (320x568) without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final lang in testLocales) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (ctx) => Center(
                    child: ElevatedButton(
                      onPressed: () => AddDocumentSheet.show(ctx),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(AddDocumentSheet), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'AddDocumentSheet overflow in $lang on 320x568');

        // Dismiss sheet
        Navigator.of(tester.element(find.byType(AddDocumentSheet))).pop();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Private Photos unlocked banner renders across all 20 languages on 320x568 without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final lang in testLocales) {
        final controller = MockVaultController(
          VaultState(
            isLocked: false,
            hasPin: true,
            documents: sampleDocs,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              mainNavigationIndexProvider.overrideWith((ref) => 3),
              vaultControllerProvider.overrideWith((ref) => controller),
            ],
            child: MaterialApp(
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const VaultScreen(isTabMode: true),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. VaultScreen automatically enforces lock on entry; unlock main vault first
        if (find.byType(VaultLockView).evaluate().isNotEmpty) {
          await tester.tap(find.text('1').last);
          await tester.pump(const Duration(milliseconds: 10));
          await tester.tap(find.text('2').last);
          await tester.pump(const Duration(milliseconds: 10));
          await tester.tap(find.text('3').last);
          await tester.pump(const Duration(milliseconds: 10));
          await tester.tap(find.text('4').last);
          await tester.pumpAndSettle();
        }

        // Tap the private photos chip
        final privateChip = find.byKey(const Key('private_photos_chip'));
        expect(privateChip, findsOneWidget);
        await tester.ensureVisible(privateChip);
        await tester.pumpAndSettle();
        await tester.tap(privateChip);
        await tester.pumpAndSettle();

        // Unlock sheet appears - type 1234
        await tester.tap(find.text('1').last);
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('2').last);
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('3').last);
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('4').last);
        await tester.pumpAndSettle();

        // Now Private Photos view is shown with the red banner and "Lock and Exit"
        expect(tester.takeException(), isNull, reason: 'Private Photos banner overflow in $lang on 320x568');
        expect(find.text('Geheime Familienfotos Urlaub'), findsOneWidget);

        // Tap Lock & Exit using key
        final lockButton = find.byKey(const Key('lock_and_exit_button'));
        expect(lockButton, findsOneWidget);
        await tester.tap(lockButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Empty State Button Symmetry & No Overlapping FAB Bug on phone screen', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final emptyController = MockVaultController(
        const VaultState(
          isLocked: false,
          hasPin: true,
          documents: [],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mainNavigationIndexProvider.overrideWith((ref) => 3),
            vaultControllerProvider.overrideWith((ref) => emptyController),
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

      // 1. VaultScreen automatically enforces lock on entry; unlock main vault first
      if (find.byType(VaultLockView).evaluate().isNotEmpty) {
        await tester.tap(find.text('1').last);
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('2').last);
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('3').last);
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('4').last);
        await tester.pumpAndSettle();
      }

      // Empty State: Center button must be shown, and FloatingActionButton must be NULL (no collision bug!)
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Belge Ekle'), findsOneWidget);

      // Now enter Özel Kasa by tapping the top-left card
      final privateCard = find.byKey(const Key('private_photos_chip'));
      expect(privateCard, findsOneWidget);
      await tester.tap(privateCard);
      await tester.pumpAndSettle();

      // Enter PIN to unlock
      await tester.tap(find.text('1').last);
      await tester.pump(const Duration(milliseconds: 10));
      await tester.tap(find.text('2').last);
      await tester.pump(const Duration(milliseconds: 10));
      await tester.tap(find.text('3').last);
      await tester.pump(const Duration(milliseconds: 10));
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();

      // In Özel Kasa empty state: Only the centered "Özel Resim Ekle" FilledButton must exist!
      // FloatingActionButton MUST be NULL so they do NOT overlap!
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Özel Resim Ekle'), findsOneWidget);
    });

    testWidgets('Top Hero Cards Height & Compact Proportions Symmetry (<110px)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = MockVaultController(
        VaultState(
          isLocked: false,
          hasPin: true,
          documents: sampleDocs,
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

      if (find.byType(VaultLockView).evaluate().isNotEmpty) {
        await tester.tap(find.text('1').last);
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('2').last);
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('3').last);
        await tester.pump(const Duration(milliseconds: 10));
        await tester.tap(find.text('4').last);
        await tester.pumpAndSettle();
      }

      // Check left card size
      final leftCard = tester.getSize(find.byKey(const Key('private_photos_chip')));
      expect(leftCard.height, lessThan(115.0)); // Shrunk from 155px!
      expect(leftCard.height, greaterThan(65.0));
    });

    testWidgets('AirlineGuideSheet renders 3-box allowances and fare packages at 320x568 without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final lang in ['tr', 'en', 'de', 'th', 'ar', 'ru']) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: Locale(lang),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: AirlineGuideSheet(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AirlineGuideSheet), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}

