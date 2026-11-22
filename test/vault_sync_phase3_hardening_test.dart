import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/vault_pin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final pins = VaultPinService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    pins.setMockStorage(null);
    await PreferencesService.init();
  });

  group('C3 - vault PIN is a salted hash in secure storage', () {
    test('PIN is never stored in plaintext; only salt + PBKDF2 hash', () async {
      await pins.ensureLoaded(uid: 'u1');
      await pins.setPin('4821', uid: 'u1');

      const storage = FlutterSecureStorage(aOptions: AndroidOptions(storageNamespace: 'packbuddy_vault_pin'));
      final raw = await storage.read(key: 'u1_vault_pin_hash');
      expect(raw, isNotNull);
      expect(raw, isNot(contains('4821')));
      final record = jsonDecode(raw!) as Map<String, dynamic>;
      expect(base64Decode(record['salt'] as String).length, 16);
      expect(base64Decode(record['hash'] as String).length, 32);
      expect(record['iter'], VaultPinService.pbkdf2Iterations);

      expect(pins.verifyPin('4821', uid: 'u1'), isTrue);
      expect(pins.verifyPin('4822', uid: 'u1'), isFalse);
    });

    test('same PIN for two users yields different salts/hashes', () async {
      await pins.ensureLoaded(uid: 'a');
      await pins.ensureLoaded(uid: 'b');
      await pins.setPin('1111', uid: 'a');
      await pins.setPin('1111', uid: 'b');
      const storage = FlutterSecureStorage(aOptions: AndroidOptions(storageNamespace: 'packbuddy_vault_pin'));
      expect(await storage.read(key: 'a_vault_pin_hash'), isNot(await storage.read(key: 'b_vault_pin_hash')));
    });

    test('legacy plaintext PIN is migrated to a hash and wiped from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        '${PreferencesService.keyVaultPin}_u9': '2468',
        PreferencesService.keyVaultPin: '2468',
        'packbuddy_vault_failed_pin_attempts_u9': <String>['1'],
      });
      await PreferencesService.init();

      await pins.ensureLoaded(uid: 'u9');

      expect(pins.verifyPin('2468', uid: 'u9'), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().where((k) => k.contains('vault_pin')), isEmpty);
    });

    test('device-global legacy PIN is never adopted by an account', () async {
      SharedPreferences.setMockInitialValues({PreferencesService.keyVaultPin: '0000'});
      await PreferencesService.init();

      await pins.ensureLoaded(uid: 'other_user');
      expect(pins.hasPin(uid: 'other_user'), isFalse);
    });

    test('failed-attempt counter is uid-scoped and stored in secure storage', () async {
      await pins.ensureLoaded(uid: 'x');
      await pins.ensureLoaded(uid: 'y');
      for (var i = 0; i < 5; i++) {
        await pins.recordFailedAttempt(uid: 'x');
      }
      expect(pins.isLockedOut(uid: 'x'), isTrue);
      expect(pins.isLockedOut(uid: 'y'), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().where((k) => k.contains('failed_pin')), isEmpty);
    });
  });

  group('Source guards (C3 / C4 / D1 / OOM)', () {
    final syncEngine = File('lib/data/sync_engine/sync_engine.dart').readAsStringSync();
    final vaultController =
        File('lib/features/vault/presentation/controllers/vault_controller.dart').readAsStringSync();
    final authService = File('lib/features/auth/auth_service.dart').readAsStringSync();

    test('C4: sync engine never writes plaintext base64 file payloads', () {
      expect(syncEngine, isNot(contains('base64Encode(rawBytes)')));
      expect(syncEngine, isNot(contains('cloudDataBase64: payload')));
      expect(syncEngine, contains('retry on next sync'));
    });

    test('C4: vault controller never uploads plaintext bytes/chunks to Firestore', () {
      expect(vaultController, isNot(contains('base64Encode(')));
      expect(vaultController, isNot(contains("collection('chunks')")));
    });

    test('D1: failed batch commits block last_synced_at from advancing', () {
      expect(syncEngine, contains('batchCommitFailed = true'));
      expect(syncEngine, contains('if (!batchCommitFailed)'));
    });

    test('C3: vault PIN is never written to or read from Firestore', () {
      expect(vaultController, isNot(contains("data['vaultPin']")));
      expect(syncEngine, isNot(contains("userData['vaultPin']")));
      expect(authService, isNot(contains("'vaultPin': localPin")));
      expect(authService, isNot(contains("remoteData?['vaultPin']")));
    });

    test('OOM: 10 MB size is checked via file.length() before readAsBytes()', () {
      final lengthIdx = vaultController.indexOf('await originalFile.length()');
      final readIdx = vaultController.indexOf('await originalFile.readAsBytes()');
      expect(lengthIdx, greaterThan(-1));
      expect(readIdx, greaterThan(lengthIdx));
      expect('await originalFile.length()'.allMatches(vaultController).length, 2);
    });
  });
}
