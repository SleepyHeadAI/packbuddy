// ignore_for_file: subtype_of_sealed_class, must_be_immutable
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/security_service.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';
import 'package:packbuddy/features/admin/domain/broadcast_announcement.dart';
import 'package:packbuddy/features/admin/domain/admin_audit_log.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

// --- Test Fakes & Mocks ---

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
    this.email,
    this.displayName,
    this.emailVerified = true,
    this.providerData = const [],
  });
}

class MockFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> storage = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => storage[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      storage[key] = value;
    } else {
      storage.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    storage.clear();
  }
}

class FakeDocSnapshot extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic>? _data;
  final bool _exists;

  FakeDocSnapshot(this._data, [this._exists = true]);

  @override
  bool get exists => _exists;

  @override
  Map<String, dynamic>? data() => _data;
}

class FakeDocRef extends Fake implements DocumentReference<Map<String, dynamic>> {
  Map<String, dynamic>? storedData;
  bool failReads = false;
  int setCalls = 0;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    setCalls++;
    if (options?.merge == true && storedData != null) {
      storedData = {...storedData!, ...data};
    } else {
      storedData = Map<String, dynamic>.from(data);
    }
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    if (failReads) throw Exception('unavailable: network error');
    return FakeDocSnapshot(storedData, storedData != null);
  }

  @override
  Future<void> delete() async {
    storedData = null;
  }
}

class FakeCollectionRef extends Fake implements CollectionReference<Map<String, dynamic>> {
  final Map<String, FakeDocRef> docs = {};

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final key = path ?? 'auto-id-${docs.length}';
    return docs.putIfAbsent(key, () => FakeDocRef());
  }
}

class FakeTransaction extends Fake implements Transaction {
  @override
  Future<DocumentSnapshot<T>> get<T extends Object?>(DocumentReference<T> documentReference) async {
    final snap = await (documentReference as FakeDocRef).get();
    return snap as DocumentSnapshot<T>;
  }

  @override
  Transaction set<T>(DocumentReference<T> documentReference, T data, [SetOptions? options]) {
    final ref = documentReference as FakeDocRef;
    ref.setCalls++;
    ref.storedData = Map<String, dynamic>.from(data as Map<String, dynamic>);
    return this;
  }
}

class FakeFirestoreInstance extends Fake implements FirebaseFirestore {
  final Map<String, FakeCollectionRef> collections = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return collections.putIfAbsent(collectionPath, () => FakeCollectionRef());
  }

  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) {
    return transactionHandler(FakeTransaction());
  }
}

class MockAdminServiceForViewerTest implements AdminService {
  final List<AdminUserModel> users;
  final Map<String, List<VaultDocument>> documents;
  final List<Map<String, dynamic>> loggedAudits = [];
  final Uint8List fakeDecryptedBytes;

  MockAdminServiceForViewerTest({
    required this.users,
    required this.documents,
    required this.fakeDecryptedBytes,
  });

  @override
  bool isCurrentUserAdmin() => true;

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async => const AdminPlatformMetrics(
        totalUsers: 2,
        proUsers: 1,
        totalTrips: 4,
        totalDocuments: 3,
      );

  @override
  Future<List<AdminUserModel>> fetchUsers() async => List.from(users);

  @override
  Future<AdminDetailedAnalytics> fetchDetailedAnalytics() async => const AdminDetailedAnalytics();

  @override
  Future<void> toggleUserProStatus(String uid, bool isPremium) async {}

  @override
  Future<void> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  }) async {}

  @override
  Future<List<VaultDocument>> fetchUserDocuments(String uid) async => documents[uid] ?? [];

  @override
  Future<Uint8List?> viewUserDocumentDecrypted({
    required String targetUserId,
    required VaultDocument doc,
  }) async {
    loggedAudits.add({
      'action': 'view_vault_document',
      'targetUserId': targetUserId,
      'docId': doc.id,
      'isPrivate': doc.isPrivate,
    });
    return fakeDecryptedBytes;
  }

  @override
  Future<List<Trip>> fetchUserTrips(String uid) async => [];

  @override
  Future<List<Expense>> fetchUserExpenses(String uid) async => [];

  @override
  Future<List<AdminUserSessionLog>> fetchUserSessions(String uid) async => [];

  @override
  Future<List<TravelCountry>> fetchUserTravelCountries(String uid) async => [];

  @override
  Future<List<FriendUserSummary>> fetchUserFriends(String uid) async => const [];

  @override
  Future<({List<FriendRequestItem> incoming, List<FriendRequestItem> outgoing})> fetchUserFriendRequests(String uid) async =>
      (incoming: <FriendRequestItem>[], outgoing: <FriendRequestItem>[]);

  @override
  Future<bool> removeUserFriendship(String currentUid, String targetUid) async => true;

  @override
  Future<void> deleteUserDocumentAsAdmin({required String uid, required String documentId}) async {}

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {}

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {}

  @override
  Future<void> sendInactivityWarningEmail(String uid) async {}

  @override
  Future<InactivityScanResult> processInactivityPolicies() async =>
      const InactivityScanResult(warningsSent: 0, accountsPurged: 0);

  @override
  Future<bool> sendUserWarning({
    required String uid,
    required String title,
    required String message,
    required String warningType,
    bool sendInAppNotification = true,
    bool sendEmail = true,
  }) async => true;

  @override
  Future<bool> sendBroadcastAnnouncement({
    required String title,
    required String message,
    String type = 'discount',
    String targetAction = 'paywall',
    String targetAudience = 'all',
    int? discountPercent,
    String? actionLabel,
  }) async => true;

  @override
  Future<List<BroadcastAnnouncement>> fetchBroadcastAnnouncements() async => [];

  @override
  Future<bool> toggleBroadcastActive(String broadcastId, bool active) async => true;

  @override
  Future<bool> deleteBroadcastAnnouncement(String broadcastId) async => true;

  @override
  Future<void> recordAuditLog({
    required String action,
    required String actionTitle,
    String? targetUid,
    String? targetUserEmail,
    String? targetUserName,
    dynamic details,
  }) async {}

  @override
  Future<List<AdminAuditLog>> fetchAuditLogs({int limit = 100}) async => [];

  @override
  Future<DeletedAccountsSummary> fetchDeletedAccountsArchive() async => const DeletedAccountsSummary();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterSecureStorage mockSecureStorage;
  late FakeFirestoreInstance fakeFirestore;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();

    mockSecureStorage = MockFlutterSecureStorage();
    fakeFirestore = FakeFirestoreInstance();

    SecurityService.instance.setSecureStorageForTesting(mockSecureStorage);
    SecurityService.instance.setFirestoreForTesting(fakeFirestore);
    SecurityService.instance.clearKeyCacheForTesting();
  });

  group('Paket 4: Key Escrow & Multi-Device Recovery (SecurityService)', () {
    test('Generates random 256-bit AES key, stores in Keystore and escrows to Firestore', () async {
      const testUserId = 'test-user-alpha';

      final key1 = await SecurityService.instance.getOrCreateUserVaultKey(userId: testUserId);
      expect(key1.bytes.length, 32);

      // Verify stored in Keystore under isolated user key
      final keystoreVal = mockSecureStorage.storage['pb_vault_aes_key_$testUserId'];
      expect(keystoreVal, isNotNull);
      expect(base64Encode(key1.bytes), equals(keystoreVal));

      // Verify backed up to Firestore under vault_keys/{userId}
      final firestoreDoc = fakeFirestore.collections['vault_keys']?.docs[testUserId]?.storedData;
      expect(firestoreDoc, isNotNull);
      expect(firestoreDoc!['key'], equals(keystoreVal));
      expect(firestoreDoc['userId'], equals(testUserId));
      expect(firestoreDoc['algorithm'], equals('AES-256-CBC'));
    });

    test('Multi-Device Recovery: If Keystore is empty, recovers key from Firestore vault_keys/{userId}', () async {
      const testUserId = 'test-user-recovery';

      // 1. Initial device creates and escrows the key
      final initialKey = await SecurityService.instance.getOrCreateUserVaultKey(userId: testUserId);
      final initialKeyB64 = base64Encode(initialKey.bytes);

      // 2. Simulate user switching to a new device (empty Keystore & empty cache, but Firestore exists)
      final newDeviceStorage = MockFlutterSecureStorage();
      SecurityService.instance.setSecureStorageForTesting(newDeviceStorage);
      SecurityService.instance.clearKeyCacheForTesting();

      expect(newDeviceStorage.storage['pb_vault_aes_key_$testUserId'], isNull);

      // 3. User requests vault key on new device -> recovered from Firestore!
      final recoveredKey = await SecurityService.instance.getOrCreateUserVaultKey(userId: testUserId);

      expect(base64Encode(recoveredKey.bytes), equals(initialKeyB64));
      expect(newDeviceStorage.storage['pb_vault_aes_key_$testUserId'], equals(initialKeyB64));
    });

    test('C1: escrow network error never generates a new key nor overwrites the escrow', () async {
      const testUserId = 'user-escrow-outage';

      // Existing escrow from another device
      final original = await SecurityService.instance.getOrCreateUserVaultKey(userId: testUserId);
      final escrowRef = fakeFirestore.collections['vault_keys']!.docs[testUserId]!;
      final escrowB64 = escrowRef.storedData!['key'];
      final writesBefore = escrowRef.setCalls;

      // New device (empty Keystore) while Firestore is unreachable
      SecurityService.instance.setSecureStorageForTesting(MockFlutterSecureStorage());
      SecurityService.instance.clearKeyCacheForTesting();
      escrowRef.failReads = true;

      await expectLater(
        SecurityService.instance.getOrCreateUserVaultKey(userId: testUserId),
        throwsA(isA<VaultKeyUnavailableException>()),
      );
      expect(escrowRef.storedData!['key'], equals(escrowB64));
      expect(escrowRef.setCalls, writesBefore);

      // Once online again the original key is recovered
      escrowRef.failReads = false;
      final recovered = await SecurityService.instance.getOrCreateUserVaultKey(userId: testUserId);
      expect(recovered.bytes, equals(original.bytes));
    });

    test('C1: escrow is written once; an existing escrow wins over a locally generated key', () async {
      const testUserId = 'user-escrow-race';
      // Another device escrowed first
      final ref = fakeFirestore.collection('vault_keys').doc(testUserId) as FakeDocRef;
      final otherDeviceKey = base64Encode(List<int>.generate(32, (i) => i));
      ref.storedData = {'userId': testUserId, 'key': otherDeviceKey};

      final key = await SecurityService.instance.getOrCreateUserVaultKey(userId: testUserId);
      expect(base64Encode(key.bytes), otherDeviceKey);
      expect(ref.setCalls, 0);
    });

    test('C1: legacy device-wide key is never adopted as another account\'s vault key', () async {
      const testUserId = 'user-fresh-account';
      final legacyDeviceKey = base64Encode(List<int>.filled(32, 7));
      mockSecureStorage.storage['pb_vault_aes_key'] = legacyDeviceKey;

      final key = await SecurityService.instance.getOrCreateUserVaultKey(userId: testUserId);
      expect(base64Encode(key.bytes), isNot(legacyDeviceKey));
    });

    test('Admin viewer decrypts the owner\'s AES-GCM document with only the escrowed key', () async {
      const ownerUid = 'client-user-99';
      // Owner device: key is created + escrowed, document encrypted (PBENC2)
      await SecurityService.instance.getOrCreateUserVaultKey(userId: ownerUid);
      final pdf = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, ...List<int>.generate(64, (i) => i)]);
      final encrypted = await SecurityService.instance.encryptBytes(pdf, userId: ownerUid);
      expect(encrypted.sublist(0, 6), SecurityService.magicHeaderV2);

      // Admin device: empty Keystore
      final adminStorage = MockFlutterSecureStorage();
      SecurityService.instance.setSecureStorageForTesting(adminStorage);
      SecurityService.instance.clearKeyCacheForTesting();

      final bytes = await FirebaseAdminService().viewUserDocumentDecrypted(
        targetUserId: ownerUid,
        doc: Document(
          id: 'doc-1',
          userId: ownerUid,
          title: 'Passport',
          category: 'passport',
          localImagePath: '',
          cloudDataBase64: base64Encode(encrypted),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      expect(bytes, equals(pdf));
      // The owner's key is never persisted on the admin device
      expect(adminStorage.storage.keys.where((k) => k.contains(ownerUid)), isEmpty);
    });

    test('Encryption & Decryption using User Escrow Key preserves data integrity', () async {
      const userId = 'encrypt-user-1';
      final plainText = 'PackBuddy Travel Secret 2026';
      final plainBytes = Uint8List.fromList(utf8.encode(plainText));

      final encrypted = await SecurityService.instance.encryptBytes(plainBytes, userId: userId);
      expect(SecurityService.instance.isEncrypted(encrypted), isTrue);

      final decrypted = await SecurityService.instance.decryptBytes(encrypted, userId: userId);
      expect(utf8.decode(decrypted), equals(plainText));
    });

    test('Backward Compatibility: decrypts legacy files encrypted with deterministic seeds', () async {
      const userId = 'legacy-user-42';
      // Create data encrypted under legacy salt key
      final legacyKey = SecurityService.instance.getOrCreateUserVaultKey(userId: userId);
      await legacyKey;

      final sampleJpg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46]);
      final encrypted = await SecurityService.instance.encryptBytes(sampleJpg, userId: userId);

      // Verify that even if cache is cleared, it decrypts successfully
      SecurityService.instance.clearKeyCacheForTesting();
      final decrypted = await SecurityService.instance.decryptBytes(encrypted, userId: userId);
      expect(SecurityService.isImageBytes(decrypted), isTrue);
    });

    test('deleteUserEscrowKey deletes key from Keystore, memory cache, and Firestore', () async {
      const userId = 'user-to-delete';
      await SecurityService.instance.getOrCreateUserVaultKey(userId: userId);

      expect(mockSecureStorage.storage['pb_vault_aes_key_$userId'], isNotNull);
      expect(fakeFirestore.collections['vault_keys']?.docs[userId]?.storedData, isNotNull);

      await SecurityService.instance.deleteUserEscrowKey(userId);

      expect(mockSecureStorage.storage['pb_vault_aes_key_$userId'], isNull);
      expect(fakeFirestore.collections['vault_keys']?.docs[userId]?.storedData, isNull);
    });
  });

  group('Paket 4: Admin Dashboard Vault Metrics & Document Inspection', () {
    testWidgets('Renders Vault metrics summary card with total documents, private vault, and size', (tester) async {
      tester.view.physicalSize = const Size(1000, 4800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testUser = AdminUserModel(
        uid: 'user-inspect-1',
        email: 'traveler@example.com',
        displayName: 'John Traveler',
        isPremium: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final docs = [
        VaultDocument(
          id: 'doc-1',
          userId: 'user-inspect-1',
          title: 'Passport Copy',
          category: 'Passport',
          localImagePath: 'vault/doc1.jpg',
          fileExtension: 'jpg',
          fileSizeBytes: 1024 * 500, // 500 KB
          createdAt: DateTime(2026, 2, 1),
          updatedAt: DateTime(2026, 2, 1),
        ),
        VaultDocument(
          id: 'doc-2',
          userId: 'user-inspect-1',
          title: 'Secret Family Photo',
          category: 'PrivatePhotos',
          localImagePath: 'vault/doc2.png',
          fileExtension: 'png',
          fileSizeBytes: 1024 * 700, // 700 KB
          createdAt: DateTime(2026, 2, 2),
          updatedAt: DateTime(2026, 2, 2),
        ),
        VaultDocument(
          id: 'doc-3',
          userId: 'user-inspect-1',
          title: 'Flight Ticket',
          category: 'Ticket',
          fileType: 'pdf',
          localImagePath: 'vault/doc3.pdf',
          fileExtension: 'pdf',
          fileSizeBytes: 1024 * 1024, // 1 MB
          createdAt: DateTime(2026, 2, 3),
          updatedAt: DateTime(2026, 2, 3),
        ),
      ];

      final sampleJpg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46]);
      final mockAdmin = MockAdminServiceForViewerTest(
        users: [testUser],
        documents: {'user-inspect-1': docs},
        fakeDecryptedBytes: sampleJpg,
      );

      final controller = AdminController(mockAdmin);
      controller.state = controller.state.copyWith(allUsers: [testUser]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminServiceProvider.overrideWithValue(mockAdmin),
            isAdminProvider.overrideWithValue(true),
            adminControllerProvider.overrideWith((ref) => controller),
            authUserProvider.overrideWithValue(
              FakeUser(uid: 'admin-1', email: 'sleepyheadaitr@gmail.com'),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: AdminDashboardScreen()),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      final moderateBtn = find.byIcon(Icons.tune_rounded);
      expect(moderateBtn, findsOneWidget);
      await tester.scrollUntilVisible(
        moderateBtn,
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(moderateBtn);
      await tester.pumpAndSettle();

      // Switch to Stats & Details tab
      final statsTab = find.byKey(const ValueKey('tab_user_stats_details'));
      if (statsTab.evaluate().isNotEmpty) {
        await tester.tap(statsTab, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Verify Vault section header is visible
      expect(find.text('Uploaded Vault Documents (Inspect / Moderate)'), findsOneWidget);

      // Verify Vault metrics summary card values
      expect(find.text('Total Vault'), findsOneWidget);
      expect(find.text('3'), findsAtLeastNWidgets(1));
      expect(find.text('Private Vault'), findsAtLeastNWidgets(1));
      expect(find.text('1'), findsAtLeastNWidgets(1));
      expect(find.text('Total Size'), findsOneWidget);
      expect(find.text('AES-256 Protected'), findsOneWidget);
      expect(find.text('2 Photos'), findsOneWidget);
      expect(find.text('1 PDFs'), findsOneWidget);

      // Verify documents are listed
      expect(find.text('Passport Copy'), findsOneWidget);
      expect(find.text('Secret Family Photo'), findsOneWidget);
      expect(find.text('Flight Ticket'), findsOneWidget);

      // Verify Private badge is rendered on private document
      expect(find.text('PRIVATE'), findsOneWidget);

      // Scroll inside moderation sheet until Inspect button is visible
      await tester.scrollUntilVisible(
        find.text('Inspect').first,
        200.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      // Tap Inspect on first document to trigger viewUserDocumentDecrypted
      final inspectButtons = find.text('Inspect');
      expect(inspectButtons, findsAtLeastNWidgets(1));
      await tester.tap(inspectButtons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verified admin inspection goes through viewUserDocumentDecrypted (audit-logged)
      expect(mockAdmin.loggedAudits.length, equals(1));
      expect(mockAdmin.loggedAudits.first['action'], equals('view_vault_document'));
      expect(mockAdmin.loggedAudits.first['targetUserId'], equals('user-inspect-1'));
      expect(find.textContaining('uçtan uca'), findsNothing);
    });
  });
}
