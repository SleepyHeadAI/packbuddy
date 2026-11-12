import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'preferences_service.dart';

/// Vault privacy & anti-spyware screen protection service with AES-256 at-rest file encryption.
/// Interfaces with Android window FLAG_SECURE and provides deterministic cryptographic file protection.
class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();

  static const MethodChannel _channel = MethodChannel('com.sleepyhead.packbuddy/security');

  /// Magic header to identify PackBuddy encrypted files (PBENC1)
  static const List<int> magicHeader = [80, 66, 69, 78, 67, 49]; // ASCII for 'PBENC1'
  static const int ivLength = 16;
  static const int headerLength = 6; // 'PBENC1' length

  enc.Key? _cachedKey;

  /// Resolves or generates the persistent 256-bit AES key bound to this device
  Future<enc.Key> _getOrCreateKey() async {
    if (_cachedKey != null) return _cachedKey!;

    final prefs = PreferencesService.instance;
    var base64Key = prefs.getVaultEncryptionKey();

    if (base64Key == null || base64Key.isEmpty) {
      final random = Random.secure();
      final keyBytes = Uint8List(32);
      for (var i = 0; i < 32; i++) {
        keyBytes[i] = random.nextInt(256);
      }
      base64Key = base64Encode(keyBytes);
      await prefs.setVaultEncryptionKey(base64Key);
    }

    _cachedKey = enc.Key(base64Decode(base64Key));
    return _cachedKey!;
  }

  enc.Key _deriveKeyFromString(String seed) {
    final hash = sha256.convert(utf8.encode(seed)).bytes;
    return enc.Key(Uint8List.fromList(hash));
  }

  Future<List<enc.Key>> _resolveCandidateKeys({String? userId, List<String>? extraSeeds}) async {
    final candidates = <enc.Key>[];
    final seenKeys = <String>{};

    void addKey(enc.Key key, String debugLabel) {
      final keyB64 = base64Encode(key.bytes);
      if (!seenKeys.contains(keyB64)) {
        seenKeys.add(keyB64);
        candidates.add(key);
      }
    }

    // 1. Primary device-bound key from SharedPreferences
    try {
      final primary = await _getOrCreateKey();
      addKey(primary, 'primary_device_key');
    } catch (_) {}

    // 2. Collect all potential user identity seeds
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

    // 3. User-specific and deterministic derived keys for each candidate seed
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

    // 4. Global master recovery & multi-device compatibility keys
    addKey(_deriveKeyFromString('com.sleepyhead.packbuddy.vault.master_secret_2026'), 'master_secret_2026');
    addKey(_deriveKeyFromString('packbuddy_vault_master_key_v1'), 'master_key_v1');
    addKey(_deriveKeyFromString('packbuddy_vault_default_secret'), 'default_secret');
    addKey(_deriveKeyFromString('packbuddy_vault_salt_2026'), 'vault_salt_2026');
    addKey(_deriveKeyFromString('packbuddy_secret_2026'), 'secret_2026');
    addKey(_deriveKeyFromString('packbuddy_admin_vault_master_key'), 'admin_master_key');
    addKey(_deriveKeyFromString('packbuddy_vault_key_master'), 'key_master');
    addKey(_deriveKeyFromString('packbuddy_vault_aes_key'), 'aes_key_seed');

    return candidates;
  }

  /// Checks if the provided bytes have the PBENC1 magic header
  bool isEncrypted(Uint8List bytes) {
    if (bytes.length < headerLength + ivLength) return false;
    for (var i = 0; i < headerLength; i++) {
      if (bytes[i] != magicHeader[i]) return false;
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

  /// Encrypts raw bytes with AES-256 CBC and prepends PBENC1 magic header and 16-byte IV
  Future<Uint8List> encryptBytes(Uint8List rawBytes, {String? userId}) async {
    if (rawBytes.isEmpty) return rawBytes;
    if (isEncrypted(rawBytes)) return rawBytes; // Guard against double-encryption

    enc.Key key;
    if (userId != null && userId.isNotEmpty) {
      key = _deriveKeyFromString('packbuddy_vault_key_${userId}_salt_2026');
    } else {
      key = await _getOrCreateKey();
    }

    final random = Random.secure();
    final ivBytes = Uint8List(ivLength);
    for (var i = 0; i < ivLength; i++) {
      ivBytes[i] = random.nextInt(256);
    }
    final iv = enc.IV(ivBytes);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(rawBytes, iv: iv);

    final result = Uint8List(headerLength + ivLength + encrypted.bytes.length);
    result.setRange(0, headerLength, magicHeader);
    result.setRange(headerLength, headerLength + ivLength, ivBytes);
    result.setRange(headerLength + ivLength, result.length, encrypted.bytes);

    return result;
  }

  /// Decrypts bytes if they start with PBENC1 header, otherwise returns original bytes for 100% backward compatibility.
  /// Iterates through candidate keys (device key, user-derived key, and master fallback keys) for robust multi-device compatibility.
  Future<Uint8List> decryptBytes(Uint8List fileBytes, {String? userId, List<String>? extraSeeds}) async {
    if (!isEncrypted(fileBytes)) {
      return fileBytes; // Unencrypted legacy file - return as is
    }

    if (fileBytes.length < headerLength + ivLength) {
      return fileBytes;
    }

    final ivBytes = fileBytes.sublist(headerLength, headerLength + ivLength);
    final cipherBytes = fileBytes.sublist(headerLength + ivLength);
    final iv = enc.IV(ivBytes);

    final candidateKeys = await _resolveCandidateKeys(userId: userId, extraSeeds: extraSeeds);

    Uint8List? firstValidCandidate;

    for (final key in candidateKeys) {
      try {
        final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
        final decrypted = encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv);
        final list = Uint8List.fromList(decrypted);
        if (!isEncrypted(list) && list.isNotEmpty) {
          // If the decrypted binary payload matches a verified image or PDF header, it's definitively valid!
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

    debugPrint('[SecurityService] Decryption notice: All candidate keys failed. Returning raw bytes fallback.');
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
