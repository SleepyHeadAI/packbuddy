import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';

Trip _trip({required String owner, List<String> collaborators = const [], bool shared = false}) => Trip(
      id: 'trip-$owner',
      userId: owner,
      title: 'Rome',
      destination: 'Rome',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 7),
      budgetLimit: 1000,
      defaultCurrency: 'EUR',
      isShared: shared,
      collaborators: collaborators,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sync = File('lib/data/sync_engine/sync_engine.dart').readAsStringSync();
  final admin = File('lib/features/admin/admin_service.dart').readAsStringSync();
  final db = File('lib/data/local_db/database_helper.dart').readAsStringSync();

  group('#1 Firebase billing: delta sync, indexes, heartbeat', () {
    test('collection reads use updated_at delta after the first full sync', () {
      expect(sync, contains("base.where('updated_at', isGreaterThan: deltaSince)"));
      expect(sync, contains('final int deltaSince = lastSyncedAt > 0 ? lastSyncedAt - deltaSafetyMarginMs : 0;'));
      // Full read stays for the first sync / missing index
      expect(sync, contains('if (deltaSince <= 0) return base.get();'));
      expect('getWithDelta('.allMatches(sync).length, greaterThanOrEqualTo(6));
    });

    test('composite indexes exist for every delta query (incl. itinerary_items and userId)', () {
      final idx = jsonDecode(File('firestore.indexes.json').readAsStringSync()) as Map<String, dynamic>;
      final keys = (idx['indexes'] as List).map((i) {
        final fields = (i['fields'] as List).map((f) => f['fieldPath']).join(',');
        return '${i['collectionGroup']}|$fields';
      }).toSet();
      for (final c in ['trips', 'expenses', 'documents', 'checklist_items', 'itinerary_items']) {
        expect(keys, contains('$c|user_id,updated_at'));
        expect(keys, contains('$c|userId,updated_at'));
      }
      expect(keys, contains('trips|collaborators,updated_at'));
      expect(keys, contains('expenses|trip_id,updated_at'));
      expect(keys, contains('itinerary_items|trip_id,updated_at'));
    });

    test('heartbeat is 30 minutes and foreground-only', () {
      expect(SyncEngine.heartbeatInterval, const Duration(minutes: 30));
      expect(sync, contains('with WidgetsBindingObserver'));
      expect(sync, contains('void didChangeAppLifecycleState('));
      expect(sync, contains('lifecycle == AppLifecycleState.resumed'));
      expect(sync, isNot(contains('Duration(minutes: 5)')));
    });
  });

  group('#2 #3 #4 shared trips and users/{uid} traffic', () {
    test('shared trip children are fetched with whereIn chunks of 30 (no N+1)', () {
      expect(SyncEngine.whereInChunkSize, 30);
      expect("where('trip_id', whereIn: chunk)".allMatches(sync).length, 2);
      expect(sync, isNot(contains("where('trip_id', isEqualTo: t.id)")));
    });

    test('lastActiveAt is throttled and storage metering only writes on change', () {
      expect(SyncEngine.lastActiveWriteInterval, const Duration(hours: 1));
      expect(sync, contains('nowForActive.difference(_lastActiveWrittenAt!) >= lastActiveWriteInterval'));
      expect(sync, contains('if (knownValue != totalStorage)'));
    });

    test('sync reuses the live users/{uid} snapshot instead of an extra get()', () {
      expect(sync, contains('_latestUserDocData = Map<String, dynamic>.from(data);'));
      expect(sync, contains('(_userDocSubscription != null && _latestUserDocUid == uid) ? _latestUserDocData : null'));
    });
  });

  group('#5 admin read protection', () {
    test('platform metrics use count()/sum() aggregations', () {
      expect(admin, contains("users.aggregate(count(), sum('totalVaultStorageBytes'))"));
      expect(admin, contains(".where('status', isEqualTo: 'accepted').count()"));
    });

    test('user lists and analytics are bounded / paginated', () {
      expect(FirebaseAdminService.adminUserPageSize, 300);
      expect(FirebaseAdminService.analyticsSampleSize, 1000);
      expect(admin, contains('.limit(adminUserPageSize)'));
      expect(admin, contains('query.startAfterDocument(cursor)'));
      expect(admin, contains('Future<QuerySnapshot<Map<String, dynamic>>> _boundedGet('));
      expect(admin, isNot(contains("await firestore.collection('trips').get()")));
      expect(admin, isNot(contains("await firestore.collection('expenses').get()")));
      expect(admin, isNot(contains("await firestore.collection('documents').get()")));
    });

    test('inactivity scan reads oldest logins first and stops at active users', () {
      expect(admin, contains("firestore.collection('users').orderBy('lastLoginAt').limit(adminUserPageSize)"));
      expect(admin, contains('final users = await _fetchInactivityCandidates();'));
    });
  });

  group('#16 local SQLite account isolation', () {
    test('own trip is visible', () {
      expect(DatabaseHelper.isTripVisibleTo(_trip(owner: 'me'), 'me'), isTrue);
    });

    test('another account\'s shared trip is hidden unless it lists the user', () {
      final foreignShared = _trip(owner: 'other', shared: true, collaborators: ['someone@x.com']);
      expect(DatabaseHelper.isTripVisibleTo(foreignShared, 'me', email: 'me@x.com'), isFalse);
    });

    test('collaborator by uid or (case-insensitive) e-mail sees the shared trip', () {
      expect(DatabaseHelper.isTripVisibleTo(_trip(owner: 'other', shared: true, collaborators: ['me']), 'me'), isTrue);
      expect(
        DatabaseHelper.isTripVisibleTo(
          _trip(owner: 'other', shared: true, collaborators: ['Me@X.com']),
          'me',
          email: 'me@x.com',
        ),
        isTrue,
      );
    });

    test('guest rows (empty user_id) are not returned to a signed-in account', () {
      expect(DatabaseHelper.isTripVisibleTo(_trip(owner: ''), 'me'), isFalse);
      final getTrips = db.substring(db.indexOf('Future<List<Trip>> getTrips('), db.indexOf('/// Retrieves a single trip by ID'));
      expect(getTrips, isNot(contains("user_id = ''")));
      expect(getTrips, isNot(contains("LIKE '%isShared%true%'")));
      expect(getTrips, contains('isTripVisibleTo(t, effectiveUserId, email: email)'));
    });
  });

  group('#17 widget receiver lockdown', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final provider =
        File('android/app/src/main/kotlin/com/sleepyhead/packbuddy/PackBuddyWidgetProvider.kt').readAsStringSync();
    final receiver =
        File('android/app/src/main/kotlin/com/sleepyhead/packbuddy/PackBuddyWidgetActionReceiver.kt').readAsStringSync();

    test('custom widget actions are not exposed by exported providers', () {
      expect(manifest, isNot(contains('com.sleepyhead.packbuddy.action.QUICK_EXPENSE_INCREMENT')));
      expect(manifest, isNot(contains('com.sleepyhead.packbuddy.action.')));
      expect(
        RegExp(r'android:name="\.PackBuddyWidgetActionReceiver"\s*android:exported="false"').hasMatch(manifest),
        isTrue,
      );
    });

    test('widget buttons target the non-exported receiver; provider ignores direct custom actions', () {
      expect(provider, contains('Intent(context, PackBuddyWidgetActionReceiver::class.java)'));
      final onReceive = provider.substring(
        provider.indexOf('override fun onReceive('),
        provider.indexOf('fun handleWidgetAction('),
      );
      expect(onReceive, isNot(contains('ACTION_QUICK_EXPENSE_INCREMENT')));
      expect(receiver, contains('provider.handleWidgetAction(context, intent)'));
      expect(receiver, contains('info.provider.packageName != context.packageName'));
    });
  });

  group('#20 Firebase App Check', () {
    test('activated at startup: Play Integrity in release, debug provider otherwise, never crashes', () {
      final main = File('lib/main.dart').readAsStringSync();
      expect(main, contains('FirebaseAppCheck.instance.activate('));
      expect(main, contains('kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug'));
      expect(main, contains("debugPrint('[AppCheck] Activation notice: \$e');"));
    });
  });

  group('#14 quota flag stays intact across copyWith', () {
    test('SyncState keeps quota flag', () {
      const s = SyncState(isCloudQuotaExceeded: true, quotaSkippedFiles: 1);
      expect(s.copyWith(status: SyncStatus.upToDate).isCloudQuotaExceeded, isTrue);
    });
  });
}
