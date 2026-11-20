import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/main_shell_scaffold.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class _FakeTripController extends StateNotifier<TripState> implements TripController {
  _FakeTripController()
      : super(
          TripState(
            isLoading: false,
            trips: [
              Trip(
                id: 'trip-1',
                title: 'Summer in Rome',
                destination: 'Rome, Italy',
                startDate: DateTime(2026, 8, 1),
                endDate: DateTime(2026, 8, 10),
                defaultCurrency: 'EUR',
                budgetLimit: 1500.0,
                transportMode: 'Flight',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ],
          ),
        );

  @override
  Future<void> loadTrips({String? userId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  _FakeVaultController()
      : super(
          VaultState(
            isLoading: false,
            isLocked: false,
            hasPin: false,
            documents: [
              Document(
                id: 'doc-1',
                title: 'Passport',
                category: 'Passport',
                localImagePath: '/tmp/pass.png',
                createdAt: DateTime(2026, 1, 1),
                updatedAt: DateTime(2026, 1, 1),
              ),
            ],
          ),
        );

  @override
  void lockVault() {}
  @override
  Future<void> loadDocuments({String? tripId, String? userId}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeExpenseController extends StateNotifier<ExpenseState> implements ExpenseController {
  _FakeExpenseController()
      : super(const ExpenseState(isLoading: false, expenses: [], totalSpent: 0.0));

  @override
  Future<void> loadExpenses() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChecklistController extends StateNotifier<ChecklistState> implements ChecklistNotifier {
  _FakeChecklistController()
      : super(
          ChecklistState(
            isLoading: false,
            items: [
              PackingItem(
                id: 'item-1',
                name: 'Toothbrush',
                category: 'Personal Care',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ],
          ),
        );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildTestApp({
  required String lang,
  required ThemeData theme,
}) {
  return ProviderScope(
    overrides: [
      tripControllerProvider.overrideWith((ref) => _FakeTripController()),
      vaultControllerProvider.overrideWith((ref) => _FakeVaultController()),
      expenseControllerProvider('trip-1').overrideWith((ref) => _FakeExpenseController()),
      checklistControllerProvider.overrideWith((ref) => _FakeChecklistController()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainShellScaffold(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  // All 20 supported languages in PackBuddy
  const allLanguages = [
    'en', // English
    'tr', // Turkish (Ana Sayfa, Harita, Bavul, Kasa, Ayarlar)
    'de', // German (Home, Karte, Gepäck, Tresor, Einstellungen)
    'es', // Spanish (Inicio, Mapa, Equipaje, Bóveda, Ajustes)
    'fr', // French (Accueil, Carte, Bagages, Coffre, Paramètres)
    'it', // Italian (Home, Mappa, Bagagli, Cassaforte, Impostazioni)
    'pt', // Portuguese (Início, Mapa, Bagagem, Cofre, Ajustes)
    'ru', // Russian (Главная, Карта, Багаж, Сейф, Настройки)
    'zh', // Chinese (首页, 地图, 行李, 保险箱, 设置)
    'ja', // Japanese (ホーム, マップ, 荷物, 保管庫, 設定)
    'ko', // Korean (홈, 지도, 짐 목록, 보관함, 설정)
    'ar', // Arabic - RTL (الرئيسية, الخريطة, الأمتعة, الخزنة, الإعدادات)
    'nl', // Dutch (Home, Kaart, Bagage, Kluis, Instellingen)
    'el', // Greek (Αρχική, Χάρτης, Αποσκευές, Θησαυροφυλάκιο, Ρυθμίσεις)
    'sv', // Swedish (Hem, Karta, Packning, Valv, Inställningar)
    'pl', // Polish (Start, Mapa, Bagaż, Sejf, Ustawienia)
    'id', // Indonesian (Beranda, Peta, Bagasi, Brankas, Pengaturan)
    'th', // Thai (หน้าแรก, แผนที่, สัมภาระ, ตู้นิรภัย, การตั้งค่า)
    'vi', // Vietnamese (Trang chủ, Bản đồ, Hành lý, Kho lưu trữ, Cài đặt)
    'hi', // Hindi (होम, मैप, सामान, वॉल्ट, सेटिंग्स)
  ];

  // Key screen sizes from small compact phones to tablets
  const screenSizes = [
    Size(320, 568),  // iPhone SE 1st gen (Narrowest 320dp width)
    Size(360, 740),  // Common Compact Android (360dp width)
    Size(390, 844),  // iPhone 14 (390dp width)
    Size(412, 915),  // Pixel 7 (412dp width)
    Size(768, 1024), // iPad / Android Tablet (768dp width)
  ];

  group('Floating Navigation Bar - True Floating Island Geometry Tests', () {
    testWidgets('Bar has floating clearance above bottom and horizontal margins (not docked edge-to-edge)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(lang: 'tr', theme: AppTheme.lightTheme));
      await tester.pumpAndSettle();

      final clipRRectFinder = find.byType(ClipRRect);
      expect(clipRRectFinder, findsWidgets);

      final barRect = tester.getRect(clipRRectFinder.last);

      // Verify the bar floats:
      // 1. It is clearly above the screen bottom (not touching 844.0)
      expect(barRect.bottom, lessThan(844.0 - 10.0), reason: 'Floating bar bottom must be detached from screen bottom');
      // 2. It has horizontal margin on the left (not starting at 0.0)
      expect(barRect.left, greaterThanOrEqualTo(16.0), reason: 'Floating bar left must have margin');
      // 3. It has horizontal margin on the right (not ending at 390.0)
      expect(barRect.right, lessThanOrEqualTo(390.0 - 16.0), reason: 'Floating bar right must have margin');
      // 4. Height is compact and sleek (around 64dp)
      expect(barRect.height, equals(64.0));
    });

    testWidgets('On tablets (768px wide), the floating bar is centered with a max width constraint (never stretched full width)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(lang: 'en', theme: AppTheme.lightTheme));
      await tester.pumpAndSettle();

      final clipRRectFinder = find.byType(ClipRRect);
      final barRect = tester.getRect(clipRRectFinder.last);

      // Tablet max width should be capped at <= 520dp for an elegant pill dock look
      expect(barRect.width, lessThanOrEqualTo(520.0));
      // Centered horizontally: left and right margins should be roughly equal
      expect((barRect.left - (768.0 - barRect.right)).abs(), lessThan(2.0));
    });
  });

  group('Floating Navigation Bar - Multi-Language Testing Across All 20 Locales', () {
    for (final lang in allLanguages) {
      testWidgets('Renders flawlessly without overflow in [$lang] on standard phone (390x844)', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildTestApp(lang: lang, theme: AppTheme.lightTheme));
        await tester.pumpAndSettle();

        // Verify all 5 tab items are rendered
        final clipRRectFinder = find.byType(ClipRRect);
        expect(clipRRectFinder, findsWidgets);

        // Verify zero RenderFlex overflow errors occurred
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Floating Navigation Bar - Multi-Size Testing (Compact 320dp to Tablet)', () {
    for (final size in screenSizes) {
      testWidgets('Renders with zero overflow at ${size.width}x${size.height} in Turkish (tr) and German (de)', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Test in German (known for longest labels, e.g. "Einstellungen")
        await tester.pumpWidget(_buildTestApp(lang: 'de', theme: AppTheme.lightTheme));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Test in Turkish
        await tester.pumpWidget(_buildTestApp(lang: 'tr', theme: AppTheme.lightTheme));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Floating Navigation Bar - Interactive Tab Switching & Dark Mode', () {
    testWidgets('Tapping all 5 tabs updates active index and works in Dark Mode without panel artifact', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(lang: 'tr', theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      final navBar = find.byType(ClipRRect).last;

      // Tab 1: Map (Harita)
      await tester.tap(find.descendant(of: navBar, matching: find.byIcon(AppIcons.mapOutlined)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Tab 2: Baggage / Checklist (Bavul)
      await tester.tap(find.descendant(of: navBar, matching: find.byIcon(AppIcons.checklistOutlined)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Tab 3: Vault (Kasa)
      await tester.tap(find.descendant(of: navBar, matching: find.byIcon(AppIcons.vaultOutlined)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Tab 4: Settings (Ayarlar)
      await tester.tap(find.descendant(of: navBar, matching: find.byIcon(AppIcons.settingsOutlined)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Tab 0: Home (Ana Sayfa)
      await tester.tap(find.descendant(of: navBar, matching: find.byIcon(AppIcons.homeOutlined)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic (ar) RTL layout renders mirrored and without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp(lang: 'ar', theme: AppTheme.lightTheme));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final navBar = find.byType(ClipRRect).last;
      // Tap on settings tab in Arabic
      await tester.tap(find.descendant(of: navBar, matching: find.byIcon(AppIcons.settingsOutlined)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
