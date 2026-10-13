// ignore_for_file: subtype_of_sealed_class, must_be_immutable
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/auth/auth_service.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';

/// Test Fake implementation of [User]
class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool emailVerified;
  @override
  final List<UserInfo> providerData;

  FakeUser({
    required this.uid,
    this.email = 'traveler@example.com',
    this.displayName = 'Traveler Test',
    this.emailVerified = true,
    this.providerData = const [],
  });
}

/// Fake Firestore DocumentSnapshot
class FakeDocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic>? _data;
  final bool _exists;

  FakeDocumentSnapshot(this._data, [this._exists = true]);

  @override
  bool get exists => _exists;

  @override
  Map<String, dynamic>? data() => _data;
}

/// Fake Firestore DocumentReference
class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  Map<String, dynamic>? storedData;
  final StreamController<DocumentSnapshot<Map<String, dynamic>>> _controller =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();

  FakeDocumentReference({this.storedData});


  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return FakeDocumentSnapshot(storedData, storedData != null);
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    if (options?.merge == true && storedData != null) {
      storedData = {...storedData!, ...data};
    } else {
      storedData = Map.from(data);
    }
    _controller.add(FakeDocumentSnapshot(storedData, true));
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    return _controller.stream;
  }

  void emitSnapshot(Map<String, dynamic> data) {
    storedData = Map.from(data);
    _controller.add(FakeDocumentSnapshot(storedData, true));
  }

  void dispose() {
    _controller.close();
  }
}

/// Fake Firestore CollectionReference
class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, FakeDocumentReference> docs = {};


  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final key = path ?? 'default';
    return docs.putIfAbsent(key, () => FakeDocumentReference());
  }
}

/// Fake Firestore instance
class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, FakeCollectionReference> collections = {};


  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return collections.putIfAbsent(collectionPath, () => FakeCollectionReference());
  }
}

/// Fake DatabaseHelper for SyncEngine tests
class FakeSyncDbHelper extends Fake implements DatabaseHelper {

  @override
  Future<int?> getLastSyncedAt({String key = 'sync_engine_last_synced_at'}) async => 0;
  @override
  Future<List<Trip>> getDeletedTrips({String? userId}) async => [];
  @override
  Future<List<Expense>> getDeletedExpenses({String? userId}) async => [];
  @override
  Future<List<Document>> getDeletedDocuments({String? userId}) async => [];
  @override
  Future<List<PackingItem>> getDeletedChecklistItems({String? userId}) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;
  late FakeUser testUser;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
    fakeFirestore = FakeFirebaseFirestore();
    testUser = FakeUser(uid: 'user-vip-101');
    // Ensure clean local state before each test
    await PreferencesService.instance.setProUser(false);
  });

  group('1. Remote Pro Status Preservation in syncUserProfile', () {
    test('Preserves remote isPremium: true granted by Admin when local is false', () async {
      // 1. Arrange: Firestore already has isPremium: true (Admin granted it)
      final userDocRef = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      userDocRef.storedData = {
        'uid': testUser.uid,
        'email': testUser.email,
        'isPremium': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
      };

      // Local is false
      expect(PreferencesService.instance.isProUser(), isFalse);

      final authService = FirebaseAuthService(firestore: fakeFirestore);

      // 2. Act: User logs in, triggering syncUserProfile
      final isPro = await authService.syncUserProfile(testUser);

      // 3. Assert:
      // a) Return value is true
      expect(isPro, isTrue);
      // b) Local PreferencesService is immediately updated to true (unlocked)
      expect(PreferencesService.instance.isProUser(), isTrue);
      // c) Remote Firestore document keeps isPremium: true (never overwritten to false)
      expect(userDocRef.storedData!['isPremium'], isTrue);
    });

    test('Writes isPremium: true to remote if user has local Pro membership', () async {
      // 1. Arrange: User bought Pro locally
      await PreferencesService.instance.setProUser(true);
      expect(PreferencesService.instance.isProUser(), isTrue);

      final userDocRef = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      userDocRef.storedData = {
        'uid': testUser.uid,
        'email': testUser.email,
        'isPremium': false,
      };

      final authService = FirebaseAuthService(firestore: fakeFirestore);

      // 2. Act:
      final isPro = await authService.syncUserProfile(testUser);

      // 3. Assert: Remote is updated to true
      expect(isPro, isTrue);
      expect(userDocRef.storedData!['isPremium'], isTrue);
    });

    test('Initializes isPremium: false for new registered user', () async {
      // 1. Arrange: Remote document does not exist, local is false
      expect(PreferencesService.instance.isProUser(), isFalse);

      final authService = FirebaseAuthService(firestore: fakeFirestore);

      // 2. Act:
      final isPro = await authService.syncUserProfile(testUser);

      // 3. Assert:
      expect(isPro, isFalse);
      final userDocRef = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      expect(userDocRef.storedData!['isPremium'], isFalse);
    });
  });

  group('2. AuthController & proSubscriptionProvider reactive integration', () {
    test('AuthController updates proSubscriptionProvider when syncUserProfile resolves', () async {
      // 1. Arrange: Firestore has isPremium: true
      final userDocRef = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      userDocRef.storedData = {
        'uid': testUser.uid,
        'email': testUser.email,
        'isPremium': true,
      };

      final authService = FirebaseAuthService(firestore: fakeFirestore);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(authService),
        ],
      );
      addTearDown(container.dispose);

      // Before sync, Riverpod pro subscription is false
      expect(container.read(proSubscriptionProvider).isPro, isFalse);

      // 2. Act: Trigger profile sync
      final isProResult = await authService.syncUserProfile(testUser);
      await container.read(proSubscriptionProvider.notifier).updateProStatus(isProResult);

      // 3. Assert: Riverpod state is reactively unlocked
      expect(container.read(proSubscriptionProvider).isPro, isTrue);
    });
  });

  group('3. SyncEngine Remote Pro Synchronization', () {
    test('SyncEngine synchronizes remote Pro status and notifies listener', () async {
      // 1. Arrange: Firestore has isPremium: true
      final userDocRef = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      userDocRef.storedData = {
        'uid': testUser.uid,
        'email': testUser.email,
        'isPremium': true,
      };

      bool? proCallbackValue;
      final engine = SyncEngine(
        dbHelper: FakeSyncDbHelper(),
        firestore: fakeFirestore,
        onProStatusSynced: (isPro) {
          proCallbackValue = isPro;
        },
      );
      addTearDown(engine.dispose);

      // 2. Act: listen to real-time doc changes
      engine.listenToUserDoc(testUser.uid);

      // Emit new snapshot with isPremium: true
      userDocRef.emitSnapshot({
        'uid': testUser.uid,
        'isPremium': true,
      });

      await Future.delayed(const Duration(milliseconds: 50));

      // 3. Assert:
      expect(proCallbackValue, isTrue);
      expect(PreferencesService.instance.isProUser(), isTrue);

      // 4. Admin revokes Pro status remotely
      userDocRef.emitSnapshot({
        'uid': testUser.uid,
        'isPremium': false,
      });

      await Future.delayed(const Duration(milliseconds: 50));

      expect(proCallbackValue, isFalse);
      expect(PreferencesService.instance.isProUser(), isFalse);
    });
  });
}
