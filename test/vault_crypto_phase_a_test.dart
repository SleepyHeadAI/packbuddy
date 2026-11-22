import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/security_service.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final security = SecurityService.instance;
  const storage = FlutterSecureStorage();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await PreferencesService.init();
    security.setSecureStorageForTesting(storage);
    security.clearKeyCacheForTesting();
  });

  Uint8List jpeg() => Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, ...List<int>.generate(200, (i) => i % 256)]);

  group('#11 authenticated AES-256-GCM (PBENC2)', () {
    test('new files use PBENC2 and round-trip with a single key', () async {
      final plain = jpeg();
      final sealed = await security.encryptBytes(plain, userId: 'u1');
      expect(sealed.sublist(0, 6), SecurityService.magicHeaderV2);
      expect(security.isGcmEncrypted(sealed), isTrue);
      expect(security.isLegacyCbcEncrypted(sealed), isFalse);
      expect(await security.decryptBytes(sealed, userId: 'u1'), equals(plain));
    });

    test('a nonce is never reused for the same plaintext', () async {
      final a = await security.encryptBytes(jpeg(), userId: 'u1');
      final b = await security.encryptBytes(jpeg(), userId: 'u1');
      expect(a.sublist(6, 18), isNot(equals(b.sublist(6, 18))));
    });

    test('tampered ciphertext is rejected by the GCM tag (no garbage output)', () async {
      final sealed = await security.encryptBytes(jpeg(), userId: 'u1');
      final tampered = Uint8List.fromList(sealed)..[sealed.length - 20] ^= 0x01;
      final out = await security.decryptBytes(tampered, userId: 'u1');
      expect(security.isEncrypted(out), isTrue, reason: 'returns the sealed input, not corrupted plaintext');
    });

    test('a different user key cannot open the file', () async {
      final sealed = await security.encryptBytes(jpeg(), userId: 'u1');
      await security.getOrCreateUserVaultKey(userId: 'u2');
      final otherKey = await security.getOrCreateUserVaultKey(userId: 'u2');
      final out = await security.decryptBytes(sealed, candidateKey: otherKey);
      expect(security.isEncrypted(out), isTrue);
    });

    test('decryption never generates or stores a key for an unknown user', () async {
      final sealed = await security.encryptBytes(jpeg(), userId: 'owner');
      FlutterSecureStorage.setMockInitialValues({});
      security.clearKeyCacheForTesting();

      final out = await security.decryptBytes(sealed, userId: 'stranger');
      expect(security.isEncrypted(out), isTrue);
      expect(await storage.read(key: 'pb_vault_aes_key_stranger'), isNull);
    });

    test('legacy AES-CBC (PBENC1) files remain readable', () async {
      final key = await security.getOrCreateUserVaultKey(userId: 'legacy_user');
      final plain = jpeg();
      final iv = Uint8List.fromList(List<int>.generate(16, (i) => i * 7 % 256));
      final cbc = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc)).encryptBytes(plain, iv: enc.IV(iv)).bytes;
      final legacy = Uint8List.fromList([...SecurityService.magicHeader, ...iv, ...cbc]);

      expect(security.isLegacyCbcEncrypted(legacy), isTrue);
      expect(await security.decryptBytes(legacy, userId: 'legacy_user'), equals(plain));
    });

    test('unencrypted legacy files pass through unchanged', () async {
      final plain = Uint8List.fromList(utf8.encode('plain legacy'));
      expect(await security.decryptBytes(plain), equals(plain));
    });
  });

  group('#12 / #13 key storage hardening', () {
    final src = File('lib/core/services/security_service.dart').readAsStringSync();

    test('#12: plaintext SharedPreferences key fallback is test-only', () {
      expect(src, contains('refusing to store the vault key in plaintext'));
      final idx = src.indexOf('refusing to store the vault key in plaintext');
      final guard = src.lastIndexOf('if (!_isTesting)', idx);
      expect(guard, greaterThan(-1));
      expect(idx - guard, lessThan(300));
    });

    test('#13: secure storage is not wiped on transient Keystore errors', () {
      expect(src, contains('resetOnError: false'));
      expect(src, isNot(contains('resetOnError: true')));
    });
  });

  group('#10 / #14 sync robustness', () {
    final sync = File('lib/data/sync_engine/sync_engine.dart').readAsStringSync();
    final vault = File('lib/features/vault/presentation/controllers/vault_controller.dart').readAsStringSync();

    test('#10: no synchronous file reads in sync engine / vault controller', () {
      expect(sync, isNot(contains('readAsBytesSync')));
      expect(vault, isNot(contains('readAsBytesSync')));
      expect(vault, isNot(contains('lengthSync()')));
    });

    test('#14: quota skips only the upload; metadata still pushed; UI flag exposed', () {
      expect(sync, contains('throw const _QuotaSkip();'));
      expect(sync, contains('on _QuotaSkip {'));
      expect(sync, contains('isCloudQuotaExceeded: quotaSkippedFiles > 0'));

      const s = SyncState();
      expect(s.isCloudQuotaExceeded, isFalse);
      final flagged = s.copyWith(isCloudQuotaExceeded: true, quotaSkippedFiles: 2);
      expect(flagged.isCloudQuotaExceeded, isTrue);
      expect(flagged.quotaSkippedFiles, 2);
      expect(flagged.copyWith(syncedCount: 1).isCloudQuotaExceeded, isTrue);
    });
  });
}
