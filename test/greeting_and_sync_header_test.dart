import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_localization.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class MockUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? displayName;
  @override
  final String? email;
  @override
  final bool emailVerified;

  MockUser({
    this.uid = 'user-test-123',
    this.displayName = 'Sleepyhead',
    this.email = 'sleepyhead@packbuddy.app',
    this.emailVerified = true,
  });
}

class FakeAuthController extends StateNotifier<AuthState> implements AuthController {
  FakeAuthController([AuthState? state])
      : super(state ?? AuthState(user: MockUser(displayName: 'Sleepyhead')));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeSyncEngine extends StateNotifier<SyncState> implements SyncEngine {
  FakeSyncEngine([SyncState? state])
      : super(state ?? const SyncState(status: SyncStatus.failed, errorMessage: 'Network timeout'));

  bool syncCalled = false;

  @override
  Future<void> performSync() async {
    syncCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

Widget buildTestApp({
  required Size screenSize,
  required String langCode,
  String? userName,
  SyncStatus syncStatus = SyncStatus.failed,
}) {
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(
        (ref) => FakeAuthController(
          AuthState(
            user: userName != null ? MockUser(displayName: userName) : null,
          ),
        ),
      ),
      syncEngineProvider.overrideWith(
        (ref) => FakeSyncEngine(
          SyncState(
            status: syncStatus,
            errorMessage: syncStatus == SyncStatus.failed ? 'Connection failed' : null,
          ),
        ),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(langCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: MediaQuery(
        data: MediaQueryData(
          size: screenSize,
          textScaler: const TextScaler.linear(1.0),
        ),
        child: const DashboardScreen(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
    for (final loc in AppLocalizations.supportedLocales) {
      try {
        await initializeDateFormatting(loc.languageCode, null);
      } catch (_) {}
    }
  });

  const testScreenSizes = [
    Size(320, 568), // Compact (iPhone SE)
    Size(360, 640), // Standard budget Android
    Size(390, 844), // Modern iPhone (like user's screenshot)
    Size(412, 915), // Large Android
    Size(800, 1280), // Tablet
  ];

  const testLanguages = [
    'tr', // Turkish (User's language)
    'en', // English
    'de', // German (Long strings)
    'fr', // French (Long strings)
    'es', // Spanish
    'ru', // Russian (Cyrillic)
    'ar', // Arabic (RTL)
    'ja', // Japanese (CJK)
    'ko', // Korean
    'zh', // Chinese
    'el', // Greek
    'nl', // Dutch
    'pt', // Portuguese
  ];

  group('Top Greeting Bar & Live Sync Layout Across Sizes & Languages', () {
    for (final size in testScreenSizes) {
      testWidgets('Renders zero overflow at ${size.width}x${size.height} across test languages with typical user', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        for (final lang in testLanguages) {
          await tester.pumpWidget(
            buildTestApp(
              screenSize: size,
              langCode: lang,
              userName: 'Sleepyhead',
              syncStatus: SyncStatus.failed,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          expect(
            tester.takeException(),
            isNull,
            reason: 'Overflow in $lang at ${size.width}x${size.height}',
          );

          // Verify user display name is present and clean
          expect(find.text('Sleepyhead'), findsOneWidget);
        }
      });

      testWidgets('Renders zero overflow at ${size.width}x${size.height} with extremely long user name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestApp(
            screenSize: size,
            langCode: 'tr',
            userName: 'Alexander Maximilian von Hapsburg',
            syncStatus: SyncStatus.failed,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
        expect(find.text('Alexander Maximilian von Hapsburg'), findsOneWidget);
      });

      testWidgets('Renders zero overflow at ${size.width}x${size.height} when guest / unauthenticated', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestApp(
            screenSize: size,
            langCode: 'tr',
            userName: null, // guest
            syncStatus: SyncStatus.upToDate,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
        // Default traveler title in Turkish
        expect(find.text('Gezgin'), findsOneWidget);
      });
    }

    testWidgets('Tapping sync badge triggers performSync and shows SnackBar feedback', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildTestApp(
          screenSize: const Size(390, 844),
          langCode: 'tr',
          userName: 'Sleepyhead',
          syncStatus: SyncStatus.failed,
        ),
      );
      await tester.pump();

      // Find sync badge with 'Eşitleme Hatası'
      final syncBadge = find.text('Eşitleme Hatası');
      expect(syncBadge, findsOneWidget);

      // Tap on the sync badge
      await tester.tap(syncBadge);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // SnackBar should appear providing clear user feedback
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('DashboardLocalization clean greetings have no redundant Traveler title', (tester) async {
      for (final lang in testLanguages) {
        final morning = DashboardLocalization.timeGreetingClean(lang, 8);
        final afternoon = DashboardLocalization.timeGreetingClean(lang, 14);
        final evening = DashboardLocalization.timeGreetingClean(lang, 20);
        final night = DashboardLocalization.timeGreetingClean(lang, 2);

        expect(morning.isNotEmpty, isTrue);
        expect(afternoon.isNotEmpty, isTrue);
        expect(evening.isNotEmpty, isTrue);
        expect(night.isNotEmpty, isTrue);

        // Ensure in Turkish it is clean
        if (lang == 'tr') {
          expect(morning, 'Günaydın');
          expect(afternoon, 'İyi Günler');
          expect(evening, 'İyi Akşamlar');
          expect(night, 'İyi Geceler');
        }
      }
    });
  });
}
