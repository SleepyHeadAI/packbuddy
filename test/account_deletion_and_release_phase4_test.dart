// ignore_for_file: subtype_of_sealed_class
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/telemetry_service.dart';
import 'package:packbuddy/features/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Minimal in-memory Firestore (paths -> data) for the deletion purge.
// ---------------------------------------------------------------------------
class _Store {
  final Map<String, Map<String, dynamic>> docs = {};
  final Set<String> failDeletesUnder = {};

  bool isDirectChild(String docPath, String collectionPath) {
    if (!docPath.startsWith('$collectionPath/')) return false;
    return !docPath.substring(collectionPath.length + 1).contains('/');
  }
}

class _Fs extends Fake implements FirebaseFirestore {
  final _Store store;
  _Fs(this.store);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) => _Coll(store, path);

  @override
  WriteBatch batch() => _Batch();
}

class _Query extends Fake implements Query<Map<String, dynamic>> {
  final _Store store;
  final String path;
  final bool Function(Map<String, dynamic>) predicate;
  _Query(this.store, this.path, this.predicate);

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final matches = store.docs.entries
        .where((e) => store.isDirectChild(e.key, path) && predicate(e.value))
        .map((e) => _QDoc(_Doc(store, e.key), e.value))
        .toList();
    return _QSnap(matches);
  }

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return _Query(store, path, (d) {
      if (!predicate(d)) return false;
      final v = d[field as String];
      if (isEqualTo != null) return v == isEqualTo;
      if (arrayContains != null) return v is List && v.contains(arrayContains);
      return true;
    });
  }
}

class _Coll extends _Query implements CollectionReference<Map<String, dynamic>> {
  _Coll(_Store store, String path) : super(store, path, (_) => true);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) => _Doc(store, '$path/$id');
}

class _Doc extends Fake implements DocumentReference<Map<String, dynamic>> {
  final _Store store;
  @override
  final String path;
  _Doc(this.store, this.path);

  @override
  String get id => path.split('/').last;

  @override
  CollectionReference<Map<String, dynamic>> collection(String sub) => _Coll(store, '$path/$sub');

  @override
  Future<void> delete() async {
    if (store.failDeletesUnder.any((p) => path.startsWith(p))) {
      throw Exception('permission-denied');
    }
    store.docs.remove(path);
  }
}

class _QDoc extends Fake implements QueryDocumentSnapshot<Map<String, dynamic>> {
  @override
  final DocumentReference<Map<String, dynamic>> reference;
  final Map<String, dynamic> _data;
  _QDoc(this.reference, this._data);

  @override
  String get id => reference.id;

  @override
  Map<String, dynamic> data() => _data;
}

class _QSnap extends Fake implements QuerySnapshot<Map<String, dynamic>> {
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  _QSnap(this.docs);
}

class _Batch extends Fake implements WriteBatch {
  final List<DocumentReference> _pending = [];

  @override
  void delete(DocumentReference document) => _pending.add(document);

  @override
  Future<void> commit() async {
    for (final d in _pending) {
      await d.delete();
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('E1/E2 - complete account data purge', () {
    late _Store store;
    const uid = 'user_1';

    setUp(() {
      store = _Store();
      final d = store.docs;
      // Owned records under BOTH owner field spellings
      d['trips/t1'] = {'user_id': uid};
      d['trips/t2'] = {'userId': uid};
      d['trips/other'] = {'user_id': 'someone_else'};
      d['expenses/e1'] = {'user_id': uid, 'userId': uid};
      d['checklist_items/c1'] = {'userId': uid};
      d['itinerary_items/i1'] = {'user_id': uid};
      d['travel_map/m1'] = {'userId': uid};
      // Vault document with legacy plaintext chunk subcollection
      d['documents/doc1'] = {'user_id': uid};
      d['documents/doc1/chunks/chunk_0'] = {'index': 0, 'chunk': 'AAAA'};
      d['documents/doc1/chunks/chunk_1'] = {'index': 1, 'chunk': 'BBBB'};
      d['documents/doc2'] = {'userId': uid};
      d['documents/doc2/chunks/chunk_0'] = {'index': 0, 'chunk': 'CCCC'};
      d['documents/foreign'] = {'user_id': 'someone_else'};
      d['documents/foreign/chunks/chunk_0'] = {'index': 0, 'chunk': 'DDDD'};
      // Account-linked records
      d['vault_keys/$uid'] = {'key': 'k'};
      d['usernames/traveler'] = {'uid': uid};
      d['usernames/other'] = {'uid': 'someone_else'};
      d['friendships/f1'] = {'users': [uid, 'friend']};
      d['friendships/f2'] = {'users': ['a', 'b']};
      d['users/$uid/notifications/n1'] = {'title': 'x'};
      d['users/$uid/sessions/s1'] = {'durationSeconds': 10};
      d['user_feedback/fb1'] = {'user_id': uid};
      d['user_feedback/fb2'] = {'user_id': 'someone_else'};
      d['users/$uid'] = {'name': 'Profile'};
    });

    test('deletes every owned record incl. documents/{id}/chunks, keeps others', () async {
      final failures = <String>[];
      await FirebaseAuthService.purgeUserFirestoreData(_Fs(store), uid, failures);

      expect(failures, isEmpty);
      final remaining = store.docs.keys.toSet();
      expect(remaining, {
        'trips/other',
        'documents/foreign',
        'documents/foreign/chunks/chunk_0',
        'usernames/other',
        'friendships/f2',
        'user_feedback/fb2',
        // The profile is deleted separately AFTER the purge succeeded.
        'users/$uid',
      });
    });

    test('a failing deletion is reported (caller keeps the Auth user for retry)', () async {
      store.failDeletesUnder.add('documents/doc1/chunks');
      final failures = <String>[];
      await FirebaseAuthService.purgeUserFirestoreData(_Fs(store), uid, failures);

      expect(failures, isNotEmpty);
      expect(failures.first, startsWith('documents'));
      // Parent doc is not deleted before its chunks, so nothing is orphaned unreadably.
      expect(store.docs.containsKey('documents/doc1'), isTrue);
    });

    test('owned collection list covers both spellings and all user collections', () {
      expect(FirebaseAuthService.ownedCollections, containsAll([
        'trips', 'expenses', 'documents', 'checklist_items', 'itinerary_items', 'travel_map',
      ]));
      final src = File('lib/features/auth/auth_service.dart').readAsStringSync();
      expect(src, contains("for (final field in const ['user_id', 'userId'])"));
    });

    test('order: re-authentication first, Auth user deletion last', () {
      final src = File('lib/features/auth/auth_service.dart').readAsStringSync();
      final body = src.substring(src.indexOf('Future<void> deleteAccountPermanently('));
      final reauth = body.indexOf('_reauthenticateForDeletion(user');
      final purge = body.indexOf('purgeUserFirestoreData(firestore');
      final profile = body.indexOf("collection('users').doc(uid).delete()");
      final authDelete = body.indexOf('await user.delete()');
      expect(reauth, greaterThan(-1));
      expect(reauth, lessThan(purge));
      expect(purge, lessThan(profile));
      expect(profile, lessThan(authDelete));
      expect(body, contains('reauthenticateWithProvider(GoogleAuthProvider())'));
    });
  });

  group('F2 / F1 - Android release configuration', () {
    test('F2: broad media permissions are removed', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest, contains('android.permission.READ_MEDIA_IMAGES" tools:node="remove"'));
      expect(manifest, contains('android.permission.READ_MEDIA_VIDEO" tools:node="remove"'));
      expect(
        RegExp(r'READ_MEDIA_(IMAGES|VIDEO)"\s*/>').hasMatch(manifest),
        isFalse,
        reason: 'no plain READ_MEDIA_* grant may remain',
      );
    });

    test('F3: PostHog native auto-init is disabled (consent-gated setup in Dart)', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest, contains('com.posthog.posthog.AUTO_INIT'));
      expect(manifest, contains('android:value="false"'));
    });

    test('F1: release signing comes from key.properties, never the debug key', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      expect(gradle, contains('rootProject.file("key.properties")'));
      expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
      expect(gradle, contains('Release signing is not configured'));
    });
  });

  group('F3 - telemetry privacy', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
      TelemetryService.instance.clearTestHistory();
    });

    test('no recorded choice means no analytics consent', () {
      expect(PreferencesService.instance.isAnalyticsConsentGiven(), isFalse);
    });

    test('identify sends uid only — no e-mail or name', () async {
      await TelemetryService.instance.identifyUser(uid: 'u1', isPro: false);
      final record = TelemetryService.instance.testHistory.last;
      expect(record.name, r'$identify');
      expect(record.properties!['user_id'], 'u1');
      expect(record.properties!.containsKey('email'), isFalse);
      expect(record.properties!.containsKey('name'), isFalse);
    });

    test('session replay and touch capture are off; SDK starts opted out', () {
      final src = File('lib/core/services/telemetry_service.dart').readAsStringSync();
      expect(src, contains('config.sessionReplay = false;'));
      expect(src, contains('config.sessionReplayConfig.captureTouches = false;'));
      expect(src, contains('config.optOut = true;'));
    });

    test('applyConsent toggles opt-in state', () async {
      await TelemetryService.instance.applyConsent(true);
      expect(TelemetryService.instance.isConsentGranted, isTrue);
      await TelemetryService.instance.applyConsent(false);
      expect(TelemetryService.instance.isConsentGranted, isFalse);
    });
  });
}
