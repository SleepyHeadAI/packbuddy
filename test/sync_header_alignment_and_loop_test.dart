import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/status_badge.dart';

class MockUser extends Fake implements User {
  @override
  final String uid = 'test-uid';
  @override
  final String? displayName = 'ENES';
  @override
  final String? email = 'enes@packbuddy.app';
  @override
  final bool emailVerified = true;
}

class FakeAuthController extends StateNotifier<AuthState> implements AuthController {
  FakeAuthController() : super(AuthState(user: MockUser()));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeSyncEngine extends StateNotifier<SyncState> implements SyncEngine {
  FakeSyncEngine([SyncState? state]) : super(state ?? const SyncState(status: SyncStatus.upToDate));

  int syncCallCount = 0;
  int forceSyncCallCount = 0;

  @override
  Future<void> performSync() async {
    syncCallCount++;
  }

  @override
  Future<void> forceSync() async {
    forceSyncCallCount++;
  }

  void setStatus(SyncStatus status) {
    state = state.copyWith(status: status);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

Widget buildTestWidget({
  required Size screenSize,
  required String langCode,
  required SyncStatus syncStatus,
  FakeSyncEngine? engine,
}) {
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith((ref) => FakeAuthController()),
      syncEngineProvider.overrideWith((ref) => engine ?? FakeSyncEngine(SyncState(status: syncStatus))),
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

  group('Sync Header Alignment & Layout Symmetry Tests', () {
    testWidgets('StatusBadge fits full text "Eşitleniyor..." without being truncated into "Eşitleniyo..."', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatusBadge(
                label: 'Eşitleniyor...',
                icon: Icons.sync_rounded,
                backgroundColor: Color(0x263B82F6),
                textColor: Color(0xFF3B82F6),
                maxWidth: 140,
                isSpinning: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Ensure the text widget with the full string exists
      expect(find.text('Eşitleniyor...'), findsOneWidget);

      // Verify the rendered box width accommodates the text and icon comfortably
      final badgeFinder = find.byType(StatusBadge);
      final size = tester.getSize(badgeFinder);
      expect(size.width, greaterThan(90));
      expect(size.width, lessThanOrEqualTo(140));
    });

    testWidgets('Header right buttons remain pinned to the far right edge without empty gap when switching from syncing to upToDate', (tester) async {
      final fakeEngine = FakeSyncEngine(const SyncState(status: SyncStatus.syncing));

      await tester.pumpWidget(
        buildTestWidget(
          screenSize: const Size(390, 844),
          langCode: 'tr',
          syncStatus: SyncStatus.syncing,
          engine: fakeEngine,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. In 'syncing' state:
      expect(find.text('Eşitleniyor...'), findsOneWidget);
      final tuneIconSyncing = find.byIcon(Icons.tune_rounded);
      expect(tuneIconSyncing, findsOneWidget);
      final tuneRightSyncing = tester.getTopRight(tuneIconSyncing).dx;

      // 2. Change state to 'upToDate':
      fakeEngine.setStatus(SyncStatus.upToDate);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Güncel'), findsOneWidget);
      final tuneIconUpToDate = find.byIcon(Icons.tune_rounded);
      expect(tuneIconUpToDate, findsOneWidget);
      final tuneRightUpToDate = tester.getTopRight(tuneIconUpToDate).dx;

      // Crucial assertion: Tune button must NOT move to the left and create a void!
      // Its right coordinate should remain anchored at the exact same right boundary!
      expect(
        tuneRightUpToDate,
        equals(tuneRightSyncing),
        reason: 'Tune button shifted to the left when status changed to "Güncel", causing a gap!',
      );
    });

    testWidgets('Buttons stay anchored to right across various languages and screen widths', (tester) async {
      final testSizes = [
        const Size(320, 568),
        const Size(360, 640),
        const Size(390, 844),
        const Size(412, 915),
      ];

      final testLangs = ['tr', 'en', 'de', 'fr', 'es', 'it', 'ru'];

      for (final size in testSizes) {
        for (final lang in testLangs) {
          final fakeEngine = FakeSyncEngine(const SyncState(status: SyncStatus.syncing));

          await tester.pumpWidget(
            buildTestWidget(
              screenSize: size,
              langCode: lang,
              syncStatus: SyncStatus.syncing,
              engine: fakeEngine,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));

          expect(tester.takeException(), isNull, reason: 'Overflow in $lang at $size');

          final tuneRightSyncing = tester.getTopRight(find.byIcon(Icons.tune_rounded)).dx;

          fakeEngine.setStatus(SyncStatus.upToDate);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));

          expect(tester.takeException(), isNull, reason: 'Overflow in $lang at $size (upToDate)');
          final tuneRightUpToDate = tester.getTopRight(find.byIcon(Icons.tune_rounded)).dx;

          expect(
            tuneRightUpToDate,
            equals(tuneRightSyncing),
            reason: 'Mismatch at $size in $lang: $tuneRightUpToDate != $tuneRightSyncing',
          );
        }
      }
    });
  });
}
