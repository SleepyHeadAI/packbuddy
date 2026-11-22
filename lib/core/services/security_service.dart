import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'preferences_service.dart';

class _CryptParams {
  final Uint8List payload;
  final Uint8List keyBytes;
  final Uint8List ivBytes;

  const _CryptParams(this.payload, this.keyBytes, this.ivBytes);
}

/// Legacy AES-CBC (PBENC1) decryption — read-only backward compatibility.
Uint8List _isolateDecryptBytes(_CryptParams params) {
  final key = enc.Key(params.keyBytes);
  final iv = enc.IV(params.ivBytes);
  final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
  final decrypted = encrypter.decryptBytes(enc.Encrypted(params.payload), iv: iv);
  return Uint8List.fromList(decrypted);
}

// AES-256-GCM via pointycastle GCMBlockCipher.process (default padding arg makes `encrypt` use the
// full AEAD process() path, which appends/verifies the 16-byte tag).
Uint8List _isolateEncryptGcm(_CryptParams params) {
  final encrypter = enc.Encrypter(enc.AES(enc.Key(params.keyBytes), mode: enc.AESMode.gcm));
  return Uint8List.fromList(encrypter.encryptBytes(params.payload, iv: enc.IV(params.ivBytes)).bytes);
}

Uint8List _isolateDecryptGcm(_CryptParams params) {
  final encrypter = enc.Encrypter(enc.AES(enc.Key(params.keyBytes), mode: enc.AESMode.gcm));
  return Uint8List.fromList(encrypter.decryptBytes(enc.Encrypted(params.payload), iv: enc.IV(params.ivBytes)));
}

/// Thrown when the vault key escrow can't be read/written. Callers must retry later instead of
/// generating a new key (which would make existing encrypted files unreadable).
class VaultKeyUnavailableException implements Exception {
  final String message;
  VaultKeyUnavailableException(this.message);
  @override
  String toString() => 'VaultKeyUnavailableException: $message';
}

/// Vault privacy & anti-spyware screen protection service with AES-256 at-rest file encryption.
/// Interfaces with Android Keystore via [FlutterSecureStorage], supports Isolate/compute offloading
/// for 120 FPS performance, and enforces zero hardcoded static keys in the binary.
class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();

  static const MethodChannel _channel = MethodChannel('com.sleepyhead.packbuddy/security');

  /// Magic header to identify PackBuddy encrypted files (PBENC1)
  static const List<int> magicHeader = [80, 66, 69, 78, 67, 49]; // ASCII 'PBENC1' (legacy AES-CBC, read-only)
  static const List<int> magicHeaderV2 = [80, 66, 69, 78, 67, 50]; // ASCII 'PBENC2' (AES-256-GCM)
  static const int ivLength = 16; // legacy CBC IV
  static const int gcmNonceLength = 12;
  static const int gcmTagLength = 16;
  static const int headerLength = 6; // header length (both versions)

  enc.Key? _cachedKey;
  final Map<String, enc.Key> _cachedUserKeys = {};
  FlutterSecureStorage? _customSecureStorage;
  FirebaseFirestore? _customFirestore;

  @visibleForTesting
  void setSecureStorageForTesting(FlutterSecureStorage storage) {
    _customSecureStorage = storage;
    _cachedKey = null;
    _cachedUserKeys.clear();
  }

  @visibleForTesting
  void setFirestoreForTesting(FirebaseFirestore firestore) {
    _customFirestore = firestore;
  }

  @visibleForTesting
  void clearKeyCacheForTesting() {
    _cachedKey = null;
    _cachedUserKeys.clear();
  }

  FirebaseFirestore? get _effectiveFirestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  FlutterSecureStorage get _secureStorage =>
      _customSecureStorage ??
      const FlutterSecureStorage(
        // #13: a transient Keystore error must not wipe all secure storage; keys are
        // recovered from the escrow instead.
        aOptions: AndroidOptions(
          resetOnError: false,
        ),
      );

  bool get _isTesting {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  String _userKeyStorageKey(String userId) => 'pb_vault_aes_key_$userId';

  /// Resolves or generates the persistent 256-bit AES key for a specific user.
  /// 1. Reads from Android Keystore via [FlutterSecureStorage] (_userKeyStorageKey(userId)).
  /// 2. If missing from Keystore, recovers it from the Firestore escrow `vault_keys/{userId}`.
  /// 3. Only when the escrow is confirmed absent, generates a fresh random key and writes the
  ///    escrow exactly once inside a transaction (`!exists`). If another device won the race,
  ///    the already-escrowed key is adopted instead.
  ///
  /// There is no fallback to the device-wide legacy key (`pb_vault_aes_key`): that key may
  /// belong to another account on this device (C1).
  ///
  /// Throws [VaultKeyUnavailableException] when the escrow can't be read or written (e.g. network
  /// failure). A new key is never generated in that case, so an existing escrow is never overwritten.
  Future<enc.Key> getOrCreateUserVaultKey({required String userId, bool syncToCloud = true}) async {
    final cleanUid = userId.trim();
    if (cleanUid.isEmpty) {
      return _getOrCreateKey();
    }

    if (_cachedUserKeys.containsKey(cleanUid)) {
      return _cachedUserKeys[cleanUid]!;
    }

    String? base64Key;
    final storageKey = _userKeyStorageKey(cleanUid);

    // 1. Read from Keystore
    try {
      base64Key = await _secureStorage.read(key: storageKey);
    } catch (e) {
      debugPrint('[SecurityService] Secure storage read notice for user $cleanUid: $e');
    }

    if (base64Key == null || base64Key.isEmpty) {
      // 2. Multi-device recovery from the escrow. Network errors propagate (no new key!).
      final escrow = await _readEscrow(cleanUid);
      if (escrow != null) {
        base64Key = escrow;
      } else {
        // 3. Escrow confirmed absent: create a key and escrow it exactly once.
        final candidate = _generateRandomKeyB64();
        base64Key = syncToCloud ? await _createEscrowIfAbsent(cleanUid, candidate) : candidate;
      }

      try {
        await _secureStorage.write(key: storageKey, value: base64Key);
      } catch (e) {
        // Never persist key material in plaintext SharedPreferences.
        debugPrint('[SecurityService] Secure storage write notice: $e');
      }
    } else if (syncToCloud) {
      // Make sure an escrow exists; never overwrite an existing one.
      unawaited(_ensureEscrowForExistingKey(cleanUid, base64Key));
    }

    final resolvedKey = enc.Key(base64Decode(base64Key));
    _cachedUserKeys[cleanUid] = resolvedKey;
    return resolvedKey;
  }

  String _generateRandomKeyB64() {
    final random = Random.secure();
    final keyBytes = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      keyBytes[i] = random.nextInt(256);
    }
    return base64Encode(keyBytes);
  }

  /// Reads the escrowed key. Returns null only when the escrow document is confirmed absent
  /// (or Firebase isn't configured at all). Any read error throws [VaultKeyUnavailableException].
  Future<String?> _readEscrow(String userId) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return null;
    final DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await firestore.collection('vault_keys').doc(userId).get();
    } catch (e) {
      throw VaultKeyUnavailableException('escrow read failed: $e');
    }
    if (!doc.exists) return null;
    final keyStr = doc.data()?['key'] as String?;
    if (keyStr == null || keyStr.trim().isEmpty) {
      // A document without key material is corrupt; don't mint a key that would diverge.
      throw VaultKeyUnavailableException('escrow document has no key');
    }
    return keyStr.trim();
  }

  /// Writes the escrow only if it doesn't exist yet (Firestore transaction). Returns the key
  /// that is authoritative afterwards: ours, or the one another device escrowed first.
  Future<String> _createEscrowIfAbsent(String userId, String base64Key) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return base64Key;
    try {
      return await firestore.runTransaction<String>((tx) async {
        final ref = firestore.collection('vault_keys').doc(userId);
        final snap = await tx.get(ref);
        if (snap.exists) {
          final existing = snap.data()?['key'] as String?;
          if (existing != null && existing.trim().isNotEmpty) {
            return existing.trim();
          }
          throw VaultKeyUnavailableException('escrow document has no key');
        }
        tx.set(ref, {
          'userId': userId,
          'key': base64Key,
          'algorithm': 'AES-256-CBC',
          'version': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return base64Key;
      });
    } on VaultKeyUnavailableException {
      rethrow;
    } catch (e) {
      throw VaultKeyUnavailableException('escrow create failed: $e');
    }
  }

  /// Background check for keys that already live in the Keystore: creates the escrow if it is
  /// missing, and only logs (never overwrites) if a different key is already escrowed.
  Future<void> _ensureEscrowForExistingKey(String userId, String base64Key) async {
    try {
      final authoritative = await _createEscrowIfAbsent(userId, base64Key);
      if (authoritative != base64Key) {
        debugPrint('[SecurityService] Escrow key differs from local Keystore key for $userId; escrow left untouched.');
      }
    } catch (e) {
      debugPrint('[SecurityService] Escrow ensure notice: $e');
    }
  }

  /// Admin vault inspection: reads [targetUserId]'s escrowed key (Firestore rules allow only the
  /// owner and a verified admin). Never generates, escrows or persists a key on this device.
  Future<enc.Key?> fetchUserEscrowKeyAsAdmin(String targetUserId) async {
    final uid = targetUserId.trim();
    if (uid.isEmpty) return null;
    try {
      final escrow = await _readEscrow(uid);
      return escrow == null ? null : enc.Key(base64Decode(escrow));
    } catch (e) {
      debugPrint('[SecurityService] Admin escrow read notice for $uid: $e');
      return null;
    }
  }

  /// Cleans up a user's encryption key from Keystore, memory cache, and Firestore (for GDPR / deletion)
  Future<void> deleteUserEscrowKey(String userId) async {
    final cleanUid = userId.trim();
    if (cleanUid.isEmpty) return;

    _cachedUserKeys.remove(cleanUid);
    try {
      await _secureStorage.delete(key: _userKeyStorageKey(cleanUid));
    } catch (_) {}

    final firestore = _effectiveFirestore;
    if (firestore != null) {
      try {
        await firestore.collection('vault_keys').doc(cleanUid).delete();
      } catch (e) {
        debugPrint('[SecurityService] Error deleting escrow key from Firestore: $e');
      }
    }
  }

  /// Resolves or generates the persistent 256-bit AES key bound to this device via Android Keystore.
  /// Automatically migrates existing keys from legacy SharedPreferences on first run.
  Future<enc.Key> _getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;

    String? base64Key;
    try {
      base64Key = await _secureStorage.read(key: 'pb_vault_aes_key');
    } catch (e) {
      debugPrint('[SecurityService] Secure storage read notice: $e');
    }

    // Migration from SharedPreferences if not found in Keystore
    if (base64Key == null || base64Key.isEmpty) {
      final prefs = PreferencesService.instance;
      final legacyKey = prefs.getVaultEncryptionKey();
      if (legacyKey != null && legacyKey.isNotEmpty) {
        base64Key = legacyKey;
        try {
          await _secureStorage.write(key: 'pb_vault_aes_key', value: base64Key);
          await prefs.setVaultEncryptionKey('');
          debugPrint('[SecurityService] Successfully migrated vault key from SharedPreferences to Keystore');
        } catch (e) {
          debugPrint('[SecurityService] Migration save notice: $e');
        }
      }
    }

    // Generate fresh cryptographic key if still missing
    if (base64Key == null || base64Key.isEmpty) {
      final random = Random.secure();
      final keyBytes = Uint8List(32);
      for (var i = 0; i < 32; i++) {
        keyBytes[i] = random.nextInt(256);
      }
      base64Key = base64Encode(keyBytes);
      try {
        await _secureStorage.write(key: 'pb_vault_aes_key', value: base64Key);
      } catch (e) {
        // #12: never persist key material in plaintext SharedPreferences in production.
        if (!_isTesting) {
          throw StateError('Secure storage unavailable; refusing to store the vault key in plaintext: $e');
        }
        // Headless unit tests only (no platform channel implementation)
        await PreferencesService.instance.setVaultEncryptionKey(base64Key);
      }
    }

    _cachedKey = enc.Key(base64Decode(base64Key));
    return _cachedKey!;
  }

  enc.Key _deriveKeyFromString(String seed) {
    final hash = sha256.convert(utf8.encode(seed)).bytes;
    return enc.Key(Uint8List.fromList(hash));
  }

  Future<List<enc.Key>> _resolveCandidateKeys({
    String? userId,
    List<String>? extraSeeds,
    enc.Key? candidateKey,
  }) async {
    final candidates = <enc.Key>[];
    final seenKeys = <String>{};

    void addKey(enc.Key key, String debugLabel) {
      final keyB64 = base64Encode(key.bytes);
      if (!seenKeys.contains(keyB64)) {
        seenKeys.add(keyB64);
        candidates.add(key);
      }
    }

    // 0. Explicit candidate key supplied by the caller
    if (candidateKey != null) {
      addKey(candidateKey, 'explicit_candidate_key');
    }

    // 1. User-specific Keystore / own escrow key. Read-only here: decryption must never
    //    mint or escrow a key (syncToCloud: false).
    if (userId != null && userId.isNotEmpty) {
      try {
        final userKey = await getOrCreateUserVaultKey(userId: userId, syncToCloud: false);
        addKey(userKey, 'user_keystore_or_escrow_key');
      } catch (_) {}
    } else {
      // 2. Device-bound key only for data that was never bound to an account (C1):
      //    it may belong to another account on this device.
      try {
        final primary = await _getOrCreateKey();
        addKey(primary, 'keystore_device_key');
      } catch (_) {}
    }

    // 3. Collect user identity seeds for authenticated device synchronization
    final seeds = <String>{};
    if (userId != null && userId.isNotEmpty) seeds.add(userId.trim());

    try {
      final authUser = FirebaseAuth.instance.currentUser;
      final currentUid = authUser?.uid;
      if (currentUid != null && currentUid.trim().isNotEmpty) {
        seeds.add(currentUid.trim());
      }
      final currentEmail = authUser?.email;
      if (currentEmail != null && currentEmail.trim().isNotEmpty) {
        seeds.add(currentEmail.trim());
      }
    } catch (_) {}

    if (extraSeeds != null) {
      for (final s in extraSeeds) {
        if (s.isNotEmpty) seeds.add(s.trim());
      }
    }

    // 4. User-specific and deterministic derived keys for each candidate seed (backward compatibility)
    for (final s in seeds) {
      addKey(_deriveKeyFromString('packbuddy_vault_key_${s}_salt_2026'), 'user_key_salt_2026');
      addKey(_deriveKeyFromString('pb_vault_$s'), 'pb_vault_short');
      addKey(_deriveKeyFromString('packbuddy_vault_$s'), 'packbuddy_vault');
      addKey(_deriveKeyFromString('vault_key_$s'), 'vault_key');
      addKey(_deriveKeyFromString('packbuddy_vault_key_${s}_salt_2025'), 'user_key_salt_2025');
      addKey(_deriveKeyFromString('packbuddy_vault_key_$s'), 'user_key_no_salt');
      addKey(_deriveKeyFromString(s), 'direct_seed');

      if (s.contains('@')) {
        final prefix = s.split('@').first;
        if (prefix.isNotEmpty) {
          addKey(_deriveKeyFromString('packbuddy_vault_key_${prefix}_salt_2026'), 'email_prefix_key');
          addKey(_deriveKeyFromString('pb_vault_$prefix'), 'email_prefix_pb_vault');
        }
      }
    }

    // Empty string UID fallback (if encrypted when user state was uninitialized/offline)
    addKey(_deriveKeyFromString('packbuddy_vault_key__salt_2026'), 'empty_uid_key');
    addKey(_deriveKeyFromString('pb_vault_'), 'empty_pb_vault');

    return candidates;
  }

  /// True for both the current AES-256-GCM format (PBENC2) and the legacy AES-CBC format (PBENC1).
  bool isEncrypted(Uint8List bytes) => isGcmEncrypted(bytes) || isLegacyCbcEncrypted(bytes);

  /// PBENC2: header(6) | nonce(12) | ciphertext | GCM tag(16)
  bool isGcmEncrypted(Uint8List bytes) =>
      _hasHeader(bytes, magicHeaderV2) && bytes.length >= headerLength + gcmNonceLength + gcmTagLength;

  /// PBENC1 (legacy, read-only): header(6) | IV(16) | AES-CBC ciphertext
  bool isLegacyCbcEncrypted(Uint8List bytes) =>
      _hasHeader(bytes, magicHeader) && bytes.length >= headerLength + ivLength;

  static bool _hasHeader(Uint8List bytes, List<int> header) {
    if (bytes.length < header.length) return false;
    for (var i = 0; i < header.length; i++) {
      if (bytes[i] != header[i]) return false;
    }
    return true;
  }

  /// Checks whether the provided binary data represents a PDF document (%PDF)
  static bool isPdfBytes(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46; // '%PDF'
  }

  /// Checks whether the provided binary data represents a supported image format
  static bool isImageBytes(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
    // GIF: GIF8
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38) return true;
    // WEBP: RIFF....WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
        bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
      return true;
    }
    // BMP: BM (0x42, 0x4D)
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) return true;
    return false;
  }

  /// Encrypts raw bytes with authenticated AES-256-GCM (#11) and writes the versioned PBENC2 format:
  /// header | 12-byte random nonce | ciphertext + 16-byte tag.
  /// Payloads >= 32KB are processed in a background isolate via [compute].
  Future<Uint8List> encryptBytes(Uint8List rawBytes, {String? userId}) async {
    if (rawBytes.isEmpty) return rawBytes;
    if (isEncrypted(rawBytes)) return rawBytes; // Guard against double-encryption

    enc.Key key;
    if (userId != null && userId.isNotEmpty) {
      key = await getOrCreateUserVaultKey(userId: userId);
    } else {
      String? currentUid;
      try {
        currentUid = FirebaseAuth.instance.currentUser?.uid;
      } catch (_) {}

      if (currentUid != null && currentUid.isNotEmpty) {
        key = await getOrCreateUserVaultKey(userId: currentUid);
      } else {
        key = await _getOrCreateKey();
      }
    }

    final random = Random.secure();
    final nonce = Uint8List(gcmNonceLength);
    for (var i = 0; i < gcmNonceLength; i++) {
      nonce[i] = random.nextInt(256);
    }

    final params = _CryptParams(rawBytes, key.bytes, nonce);
    final Uint8List sealed = (!_isTesting && rawBytes.length >= 32 * 1024)
        ? await compute(_isolateEncryptGcm, params)
        : _isolateEncryptGcm(params);

    final result = Uint8List(headerLength + gcmNonceLength + sealed.length);
    result.setRange(0, headerLength, magicHeaderV2);
    result.setRange(headerLength, headerLength + gcmNonceLength, nonce);
    result.setRange(headerLength + gcmNonceLength, result.length, sealed);
    return result;
  }

  /// Decrypts PackBuddy vault bytes.
  ///
  /// * PBENC2 (AES-GCM): decrypted with exactly ONE key — [candidateKey] if given, otherwise the
  ///   user's existing key (Keystore → escrow; a key is never generated here). The GCM tag is
  ///   verified, so tampered or wrong-key data is rejected instead of yielding garbage.
  /// * PBENC1 (legacy AES-CBC): read-only backward compatibility via the legacy candidate keys.
  /// * Anything else is returned unchanged (unencrypted legacy file).
  ///
  /// On failure the original bytes are returned (callers detect this via [isEncrypted]).
  Future<Uint8List> decryptBytes(
    Uint8List fileBytes, {
    String? userId,
    List<String>? extraSeeds,
    enc.Key? candidateKey,
  }) async {
    if (isGcmEncrypted(fileBytes)) {
      final key = candidateKey ?? await _resolveDecryptionKey(userId);
      if (key == null) {
        debugPrint('[SecurityService] Decryption notice: no vault key available for this file.');
        return fileBytes;
      }
      final nonce = fileBytes.sublist(headerLength, headerLength + gcmNonceLength);
      final sealed = fileBytes.sublist(headerLength + gcmNonceLength);
      final params = _CryptParams(sealed, key.bytes, nonce);
      try {
        return (!_isTesting && sealed.length >= 32 * 1024)
            ? await compute(_isolateDecryptGcm, params)
            : _isolateDecryptGcm(params);
      } catch (e) {
        debugPrint('[SecurityService] Decryption notice: GCM authentication failed ($e).');
        return fileBytes;
      }
    }

    if (isLegacyCbcEncrypted(fileBytes)) {
      return _decryptLegacyCbc(fileBytes, userId: userId, extraSeeds: extraSeeds, candidateKey: candidateKey);
    }

    return fileBytes; // Unencrypted legacy file - return as is
  }

  /// Key for decrypting the current format: user key from Keystore/escrow (never generated),
  /// or the device-bound key for data never bound to an account.
  Future<enc.Key?> _resolveDecryptionKey(String? userId) async {
    final uid = userId?.trim();
    if (uid == null || uid.isEmpty) {
      try {
        return await _getOrCreateKey();
      } catch (_) {
        return null;
      }
    }
    if (_cachedUserKeys.containsKey(uid)) return _cachedUserKeys[uid];
    try {
      final stored = await _secureStorage.read(key: _userKeyStorageKey(uid));
      if (stored != null && stored.isNotEmpty) {
        final key = enc.Key(base64Decode(stored));
        _cachedUserKeys[uid] = key;
        return key;
      }
    } catch (_) {}
    try {
      final escrow = await _readEscrow(uid);
      if (escrow != null) {
        final key = enc.Key(base64Decode(escrow));
        _cachedUserKeys[uid] = key;
        try {
          await _secureStorage.write(key: _userKeyStorageKey(uid), value: escrow);
        } catch (_) {}
        return key;
      }
    } catch (e) {
      debugPrint('[SecurityService] Escrow read notice during decryption: $e');
    }
    return null;
  }

  /// Legacy AES-CBC (PBENC1) read path: tries the historical candidate keys.
  Future<Uint8List> _decryptLegacyCbc(
    Uint8List fileBytes, {
    String? userId,
    List<String>? extraSeeds,
    enc.Key? candidateKey,
  }) async {
    final ivBytes = fileBytes.sublist(headerLength, headerLength + ivLength);
    final cipherBytes = fileBytes.sublist(headerLength + ivLength);

    final candidateKeys = await _resolveCandidateKeys(
      userId: userId,
      extraSeeds: extraSeeds,
      candidateKey: candidateKey,
    );

    Uint8List? firstValidCandidate;

    for (final key in candidateKeys) {
      try {
        Uint8List list;
        if (!_isTesting && cipherBytes.length >= 32 * 1024) {
          list = await compute(
            _isolateDecryptBytes,
            _CryptParams(cipherBytes, key.bytes, ivBytes),
          );
        } else {
          final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
          final decrypted = encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: enc.IV(ivBytes));
          list = Uint8List.fromList(decrypted);
        }

        if (!isEncrypted(list) && list.isNotEmpty) {
          if (isImageBytes(list) || isPdfBytes(list)) {
            return list;
          }
          firstValidCandidate ??= list;
        }
      } catch (_) {
        // Try next candidate key
      }
    }

    if (firstValidCandidate != null) {
      return firstValidCandidate;
    }

    debugPrint('[SecurityService] Decryption notice: All legacy candidate keys failed. Returning raw bytes fallback.');
    return fileBytes;
  }

  /// Tracks current secure screen state for diagnostics and headless verification
  bool _isSecureScreenActive = false;
  bool get isSecureScreenActive => _isSecureScreenActive;

  /// Enables FLAG_SECURE on the native Android Window to block screenshots,
  /// screen recording, and system app switcher previews of sensitive documents.
  Future<bool> enableSecureScreen() async {
    _isSecureScreenActive = true;
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<bool>('enableSecureScreen');
        return result ?? true;
      }
    } catch (e) {
      debugPrint('[SecurityService] enableSecureScreen notice: $e');
    }
    return true;
  }

  /// Clears FLAG_SECURE from the native Android Window when leaving sensitive screens.
  Future<bool> disableSecureScreen() async {
    _isSecureScreenActive = false;
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod<bool>('disableSecureScreen');
        return result ?? true;
      }
    } catch (e) {
      debugPrint('[SecurityService] disableSecureScreen notice: $e');
    }
    return true;
  }
}
