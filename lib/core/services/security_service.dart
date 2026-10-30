import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as enc;
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

  /// Checks if the provided bytes have the PBENC1 magic header
  bool isEncrypted(Uint8List bytes) {
    if (bytes.length < headerLength + ivLength) return false;
    for (var i = 0; i < headerLength; i++) {
      if (bytes[i] != magicHeader[i]) return false;
    }
    return true;
  }

  /// Encrypts raw bytes with AES-256 CBC and prepends PBENC1 magic header and 16-byte IV
  Future<Uint8List> encryptBytes(Uint8List rawBytes) async {
    if (rawBytes.isEmpty) return rawBytes;

    final key = await _getOrCreateKey();
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

  /// Decrypts bytes if they start with PBENC1 header, otherwise returns original bytes for 100% backward compatibility
  Future<Uint8List> decryptBytes(Uint8List fileBytes) async {
    if (!isEncrypted(fileBytes)) {
      return fileBytes; // Unencrypted legacy file - return as is
    }

    try {
      final key = await _getOrCreateKey();
      final ivBytes = fileBytes.sublist(headerLength, headerLength + ivLength);
      final cipherBytes = fileBytes.sublist(headerLength + ivLength);

      final iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final decrypted = encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (e) {
      debugPrint('[SecurityService] Decryption error: $e. Returning raw bytes fallback.');
      return fileBytes;
    }
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
