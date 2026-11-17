// ignore_for_file: subtype_of_sealed_class, must_be_immutable
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/auth/auth_service.dart';
import 'package:packbuddy/features/profile/data/profile_service.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/widgets/animal_avatar_widget.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;
  @override
  final bool emailVerified;
  @override
  final List<UserInfo> providerData;

  FakeUser({
    required this.uid,
    this.email = 'sleepyhead@example.com',
    this.displayName = 'SleepyHead',
    this.photoURL,
    this.emailVerified = true,
    this.providerData = const [],
  });
}

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

  void dispose() {
    _controller.close();
  }
}

class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Map<String, FakeDocumentReference> docs = {};

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final key = path ?? 'default';
    return docs.putIfAbsent(key, () => FakeDocumentReference());
  }
}

class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, FakeCollectionReference> collections = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return collections.putIfAbsent(collectionPath, () => FakeCollectionReference());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;
  late FakeUser testUser;
  const duckUri = 'avatar:animal_duck';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
    fakeFirestore = FakeFirebaseFirestore();
    testUser = FakeUser(uid: 'sleepyhead_user_42', photoURL: null);
  });

  group('Avatar Persistence & Cloud Sync Resilience Tests', () {
    test('1. Selecting yellow duck avatar writes to Firestore, local cache, and dedicated storage', () async {
      final profileService = ProfileService(firestore: fakeFirestore);

      final updated = await profileService.updateProfile(
        testUser.uid,
        displayName: 'SleepyHead',
        photoUrl: duckUri,
      );

      expect(updated.photoUrl, equals(duckUri));

      // Verify offline cache
      final cachedJson = PreferencesService.instance.getCachedUserProfile(testUser.uid);
      expect(cachedJson, isNotNull);
      final cachedProfile = UserProfile.fromJson(cachedJson!);
      expect(cachedProfile.photoUrl, equals(duckUri));

      // Verify dedicated storage
      expect(PreferencesService.instance.getUserAvatar(uid: testUser.uid), equals(duckUri));

      // Verify Firestore
      final userDoc = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      expect(userDoc.storedData?['photoUrl'], equals(duckUri));
    });

    test('2. syncUserProfile NEVER overwrites chosen avatar with null when user.photoURL is null', () async {
      // Setup: Remote Firestore document already has Yellow Duck
      final userDoc = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      userDoc.storedData = {
        'uid': testUser.uid,
        'email': testUser.email,
        'displayName': 'SleepyHead',
        'photoUrl': duckUri,
        'createdAt': '2026-01-01T00:00:00.000Z',
      };

      final authService = FirebaseAuthService(firestore: fakeFirestore);

      // Act: App launch triggers syncUserProfile with user.photoURL == null
      await authService.syncUserProfile(testUser);

      // Assert: Firestore document still has Yellow Duck, NOT null!
      expect(userDoc.storedData?['photoUrl'], equals(duckUri));
      // And dedicated storage was updated with duck
      expect(PreferencesService.instance.getUserAvatar(uid: testUser.uid), equals(duckUri));
    });

    test('3. Reinstall scenario: Restores yellow duck from cloud without being wiped by syncUserProfile', () async {
      // Setup reinstall: local storage is completely wiped
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
      expect(PreferencesService.instance.getCachedUserProfile(testUser.uid), isNull);
      expect(PreferencesService.instance.getUserAvatar(uid: testUser.uid), isNull);

      // Cloud Firestore still has the yellow duck from prior usage
      final userDoc = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      userDoc.storedData = {
        'uid': testUser.uid,
        'email': testUser.email,
        'displayName': 'SleepyHead',
        'photoUrl': duckUri,
        'createdAt': '2026-01-01T00:00:00.000Z',
      };

      final authService = FirebaseAuthService(firestore: fakeFirestore);
      final profileService = ProfileService(firestore: fakeFirestore);

      // Step A: On login/reinstall, syncUserProfile runs first with null photoURL
      await authService.syncUserProfile(testUser);

      // Verify syncUserProfile did NOT wipe remote duck
      expect(userDoc.storedData?['photoUrl'], equals(duckUri));

      // Step B: ProfileService fetches profile from Firestore
      final profile = await profileService.fetchProfile(testUser.uid);

      expect(profile, isNotNull);
      expect(profile!.photoUrl, equals(duckUri));

      // Verify local cache and dedicated avatar were restored
      final cachedJson = PreferencesService.instance.getCachedUserProfile(testUser.uid);
      expect(cachedJson, isNotNull);
      expect(UserProfile.fromJson(cachedJson!).photoUrl, equals(duckUri));
      expect(PreferencesService.instance.getUserAvatar(uid: testUser.uid), equals(duckUri));
    });

    test('4. Self-healing: If Firestore was wiped to null by old bug, local cache heals Firestore', () async {
      // Setup: Firestore has photoUrl: null (corrupted by prior bug)
      final userDoc = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      userDoc.storedData = {
        'uid': testUser.uid,
        'email': testUser.email,
        'displayName': 'SleepyHead',
        'photoUrl': null,
        'createdAt': '2026-01-01T00:00:00.000Z',
      };

      // But local offline cache still has the Yellow Duck
      final cachedProfile = UserProfile(
        uid: testUser.uid,
        displayName: 'SleepyHead',
        photoUrl: duckUri,
        createdAt: DateTime(2026, 1, 1),
      );
      await PreferencesService.instance.setCachedUserProfile(testUser.uid, cachedProfile.toJson());
      await PreferencesService.instance.setUserAvatar(duckUri, uid: testUser.uid);

      final profileService = ProfileService(firestore: fakeFirestore);

      // Act: fetchProfile runs
      final fetched = await profileService.fetchProfile(testUser.uid);

      // Assert: fetched profile preserved duckUri
      expect(fetched, isNotNull);
      expect(fetched!.photoUrl, equals(duckUri));

      // Firestore was healed back to duckUri!
      expect(userDoc.storedData?['photoUrl'], equals(duckUri));
    });

    test('5. Explicit removal: when user removes photo, it clears cleanly without ghost restoration', () async {
      final profileService = ProfileService(firestore: fakeFirestore);

      // 1. Initially set duck
      await profileService.updateProfile(testUser.uid, photoUrl: duckUri);
      expect(PreferencesService.instance.getUserAvatar(uid: testUser.uid), equals(duckUri));

      // 2. Clear photo explicitly
      final cleared = await profileService.updateProfile(testUser.uid, clearPhoto: true);
      expect(cleared.photoUrl, isNull);
      expect(PreferencesService.instance.getUserAvatar(uid: testUser.uid), isNull);

      final userDoc = fakeFirestore.collection('users').doc(testUser.uid) as FakeDocumentReference;
      expect(userDoc.storedData?['photoUrl'], isNull);
    });

    testWidgets('6. UserAvatar widget renders Sunny Duck and falls back to dedicated storage on transient null', (tester) async {
      await PreferencesService.instance.setUserAvatar(duckUri);

      // Pass photoUrl: null to simulate transient reload
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              photoUrl: null,
              displayName: 'SleepyHead',
              size: 80,
              isAnimated: false,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify AnimalAvatarWidget is found and rendered for Yellow Duck!
      final animalWidgetFinder = find.byType(AnimalAvatarWidget);
      expect(animalWidgetFinder, findsOneWidget);

      final animalWidget = tester.widget<AnimalAvatarWidget>(animalWidgetFinder);
      expect(animalWidget.avatar.id, equals('animal_duck'));
      expect(animalWidget.avatar.trName, equals('Sarı Ördek'));
    });
  });
}
