import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/connectivity/domain/connectivity_localization.dart';
import 'package:packbuddy/features/connectivity/domain/sync_log_entry.dart';
import 'package:packbuddy/features/connectivity/presentation/screens/sync_status_screen.dart';
import 'package:packbuddy/features/connectivity/presentation/screens/widgets/pending_changes_card.dart';
import 'package:packbuddy/features/connectivity/presentation/screens/widgets/sync_history_tile.dart';
import 'package:packbuddy/features/connectivity/presentation/widgets/connectivity_banner.dart';

void main() {
  group('Connectivity & Sync Log Domain Tests', () {
    test('SyncLogEntry serializes and deserializes correctly', () {
      final now = DateTime.now();
      final entry = SyncLogEntry(
        id: 'sync_test_1',
        timestamp: now,
        status: 'upToDate',
        itemsSynced: 5,
        conflictsResolved: 1,
        errorMessage: null,
      );

      final jsonStr = entry.toJson();
      final decoded = SyncLogEntry.fromJson(jsonStr);

      expect(decoded.id, equals('sync_test_1'));
      expect(decoded.status, equals('upToDate'));
      expect(decoded.itemsSynced, equals(5));
      expect(decoded.conflictsResolved, equals(1));
    });

    test('ConnectivityLocalization returns strings for all tested languages', () {
      final sampleLangs = ['en', 'tr', 'de', 'es', 'fr', 'ja', 'ru'];
      for (final lang in sampleLangs) {
        expect(ConnectivityLocalization.getOfflineBanner(lang).isNotEmpty, isTrue);
        expect(ConnectivityLocalization.getSyncingBanner(lang).isNotEmpty, isTrue);
        expect(ConnectivityLocalization.getSyncFailedBanner(lang).isNotEmpty, isTrue);
        expect(ConnectivityLocalization.getSyncStatusTitle(lang).isNotEmpty, isTrue);
      }
    });
  });

  group('ConnectivityBanner Widget Tests', () {
    testWidgets('ConnectivityBanner is hidden when sync status is upToDate or idle', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncEngineProvider.overrideWith((ref) => SyncEngineMock(const SyncState(status: SyncStatus.upToDate))),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ConnectivityBanner(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('ConnectivityBanner is visible when offline with wifi_off icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncEngineProvider.overrideWith((ref) => SyncEngineMock(const SyncState(status: SyncStatus.noInternet))),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ConnectivityBanner(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('ConnectivityBanner is hidden when syncing in silent mode', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncEngineProvider.overrideWith((ref) => SyncEngineMock(const SyncState(status: SyncStatus.syncing))),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ConnectivityBanner(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Silent mode: routine background sync does not show banner
      expect(find.byIcon(Icons.wifi_off_rounded), findsNothing);
      expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
    });

    testWidgets('ConnectivityBanner is visible when failed with retry action', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncEngineProvider.overrideWith((ref) => SyncEngineMock(const SyncState(status: SyncStatus.failed))),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ConnectivityBanner(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });

  group('SyncStatusScreen & Widgets Tests', () {
    testWidgets('PendingChangesCard renders correct breakdown when pending changes exist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PendingChangesCard(
              totalPending: 3,
              breakdown: {'trips': 1, 'checklist': 2, 'expenses': 0, 'documents': 0},
              languageCode: 'en',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 Trips'), findsOneWidget);
      expect(find.text('2 Items'), findsOneWidget);
    });

    testWidgets('SyncHistoryTile renders sync success tile properly', (tester) async {
      final entry = SyncLogEntry(
        id: '1',
        timestamp: DateTime(2026, 11, 13, 16, 30),
        status: 'upToDate',
        itemsSynced: 4,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncHistoryTile(entry: entry, languageCode: 'en'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sync Succeeded'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('SyncStatusScreen renders all primary diagnostic sections', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            syncEngineProvider.overrideWith((ref) => SyncEngineMock(const SyncState(status: SyncStatus.upToDate))),
          ],
          child: const MaterialApp(
            home: SyncStatusScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PendingChangesCard), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });
}

class SyncEngineMock extends StateNotifier<SyncState> implements SyncEngine {
  SyncEngineMock(super.state);

  @override
  bool get isSyncing => state.status == SyncStatus.syncing;

  @override
  Future<void> performSync() async {}

  @override
  Future<bool> hasInternetConnection() async => true;

  @override
  void listenToUserDoc(String uid) {}

  @override
  void cancelUserDocSubscription() {}

  @override
  void listenToSharedTrip(String tripId) {}

  @override
  void cancelSharedTripListener(String tripId) {}

  @override
  void cancelAllSharedTripListeners() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

