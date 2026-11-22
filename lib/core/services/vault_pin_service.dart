import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'preferences_service.dart';

/// Salted PBKDF2-HMAC-SHA256 hash of a vault PIN.
class _PinRecord {
  final Uint8List salt;
  final Uint8List hash;
  final int iterations;

  const _PinRecord(this.salt, this.hash, this.iterations);

  Map<String, dynamic> toJson() => {
        'v': 1,
        'salt': base64Encode(salt),
        'hash': base64Encode(hash),
        'iter': iterations,
      };

  static _PinRecord? fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _PinRecord(
        base64Decode(map['salt'] as String),
        base64Decode(map['hash'] as String),
        (map['iter'] as num).toInt(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Vault PIN storage (C3).
///
/// * The PIN never leaves the device and is never stored in plaintext: only a per-uid random
///   salt + PBKDF2-HMAC-SHA256 hash is kept in [FlutterSecureStorage] (Android Keystore).
/// * The failed-attempt counter lives in secure storage as well, scoped per uid.
/// * Values are cached in memory after [ensureLoaded] so the UI can query them synchronously.
class VaultPinService {
  VaultPinService._();
  static final VaultPinService instance = VaultPinService._();

  static const int pbkdf2Iterations = 60000;
  static const int maxFailedAttempts = 5;
  static const int lockoutWindowMs = 10 * 60 * 1000; // 10 minutes

  static const String _hashSuffix = 'vault_pin_hash';
  static const String _attemptsSuffix = 'vault_pin_failed_attempts';

  FlutterSecureStorage? _customStorage;
  FlutterSecureStorage get _storage =>
      _customStorage ??
      const FlutterSecureStorage(aOptions: AndroidOptions(storageNamespace: 'packbuddy_vault_pin'));

  final Map<String, _PinRecord?> _records = {};
  final Map<String, List<int>> _attempts = {};
  final Map<String, Future<void>> _loading = {};

  @visibleForTesting
  void setMockStorage(FlutterSecureStorage? storage) {
    _customStorage = storage;
    resetCacheForTesting();
  }

  @visibleForTesting
  void resetCacheForTesting() {
    _records.clear();
    _attempts.clear();
    _loading.clear();
  }

  String _scope(String? uid) {
    if (uid != null && uid.isNotEmpty) return uid;
    try {
      final current = FirebaseAuth.instance.currentUser?.uid;
      if (current != null && current.isNotEmpty) return current;
    } catch (_) {}
    return 'guest';
  }

  bool isLoaded({String? uid}) => _records.containsKey(_scope(uid));

  /// Loads the PIN hash and attempt history for [uid] into memory and migrates any legacy
  /// plaintext PIN from SharedPreferences (hashing it and wiping the plaintext copies).
  Future<void> ensureLoaded({String? uid}) {
    final scope = _scope(uid);
    if (_records.containsKey(scope)) return Future.value();
    // Note: the callback must not return the removed Future, or whenComplete would await itself.
    return _loading[scope] ??= _load(scope).whenComplete(() {
      _loading.remove(scope);
    });
  }

  Future<void> _load(String scope) async {
    _PinRecord? record;
    var attempts = <int>[];
    try {
      record = _PinRecord.fromJson(await _storage.read(key: '${scope}_$_hashSuffix'));
      final rawAttempts = await _storage.read(key: '${scope}_$_attemptsSuffix');
      if (rawAttempts != null && rawAttempts.isNotEmpty) {
        attempts = (jsonDecode(rawAttempts) as List).map((e) => (e as num).toInt()).toList();
      }
    } catch (e) {
      debugPrint('[VaultPinService] secure storage read notice: $e');
    }

    // Legacy migration: plaintext PIN in SharedPreferences (pre-v1.0).
    final prefs = PreferencesService.instance;
    final legacyPin = scope == 'guest' ? null : prefs.legacyVaultPinForMigration(uid: scope);
    if (record == null && legacyPin != null && legacyPin.isNotEmpty) {
      record = _hash(legacyPin);
      await _writeRecord(scope, record);
    }
    if (scope != 'guest') {
      await prefs.purgeLegacyVaultPinData(uid: scope);
    }

    // Don't clobber state set while loading (e.g. setPin called concurrently).
    if (!_records.containsKey(scope)) _records[scope] = record;
    _attempts.putIfAbsent(scope, () => attempts);
  }

  bool hasPin({String? uid}) => _records[_scope(uid)] != null;

  /// Verifies [pin] against the stored hash (constant-time comparison). Synchronous so the
  /// existing lock UI keeps working; requires [ensureLoaded] to have completed.
  bool verifyPin(String pin, {String? uid}) {
    final record = _records[_scope(uid)];
    if (record == null) return false;
    final candidate = _pbkdf2(utf8.encode(pin), record.salt, record.iterations, record.hash.length);
    return _constantTimeEquals(candidate, record.hash);
  }

  /// Stores a new PIN (salted hash only), or removes it when [pin] is null.
  Future<void> setPin(String? pin, {String? uid}) async {
    final scope = _scope(uid);
    if (pin == null || pin.isEmpty) {
      _records[scope] = null;
      try {
        await _storage.delete(key: '${scope}_$_hashSuffix');
      } catch (e) {
        debugPrint('[VaultPinService] secure storage delete notice: $e');
      }
      return;
    }
    final record = _hash(pin);
    _records[scope] = record;
    await _writeRecord(scope, record);
  }

  Future<void> _writeRecord(String scope, _PinRecord record) async {
    try {
      await _storage.write(key: '${scope}_$_hashSuffix', value: jsonEncode(record.toJson()));
    } catch (e) {
      debugPrint('[VaultPinService] secure storage write notice: $e');
    }
  }

  // --- Failed attempts: 5 within 10 minutes locks PIN entry ---

  List<int> recentFailedAttempts({String? uid}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (_attempts[_scope(uid)] ?? const <int>[])
        .where((ts) => ts <= now && (now - ts) < lockoutWindowMs)
        .toList();
  }

  int failedAttemptsCount({String? uid}) => recentFailedAttempts(uid: uid).length;

  bool isLockedOut({String? uid}) => failedAttemptsCount(uid: uid) >= maxFailedAttempts;

  int lockoutRemainingSeconds({String? uid}) {
    final attempts = recentFailedAttempts(uid: uid)..sort();
    if (attempts.length < maxFailedAttempts) return 0;
    final trigger = attempts[attempts.length - maxFailedAttempts];
    final remainingMs = trigger + lockoutWindowMs - DateTime.now().millisecondsSinceEpoch;
    return remainingMs <= 0 ? 0 : (remainingMs / 1000).ceil();
  }

  Future<void> recordFailedAttempt({String? uid}) async {
    final scope = _scope(uid);
    final attempts = recentFailedAttempts(uid: scope)..add(DateTime.now().millisecondsSinceEpoch);
    _attempts[scope] = attempts;
    await _writeAttempts(scope, attempts);
  }

  Future<void> resetFailedAttempts({String? uid}) async {
    final scope = _scope(uid);
    _attempts[scope] = <int>[];
    try {
      await _storage.delete(key: '${scope}_$_attemptsSuffix');
    } catch (e) {
      debugPrint('[VaultPinService] secure storage delete notice: $e');
    }
  }

  Future<void> _writeAttempts(String scope, List<int> attempts) async {
    try {
      await _storage.write(key: '${scope}_$_attemptsSuffix', value: jsonEncode(attempts));
    } catch (e) {
      debugPrint('[VaultPinService] secure storage write notice: $e');
    }
  }

  /// Removes PIN hash and attempt history for [uid] (account deletion).
  Future<void> clearForUser({String? uid}) async {
    final scope = _scope(uid);
    await setPin(null, uid: scope);
    await resetFailedAttempts(uid: scope);
  }

  // --- Crypto helpers ---

  _PinRecord _hash(String pin) {
    final random = Random.secure();
    final salt = Uint8List.fromList(List<int>.generate(16, (_) => random.nextInt(256)));
    final hash = _pbkdf2(utf8.encode(pin), salt, pbkdf2Iterations, 32);
    return _PinRecord(salt, hash, pbkdf2Iterations);
  }

  /// PBKDF2-HMAC-SHA256 (RFC 8018).
  static Uint8List _pbkdf2(List<int> password, List<int> salt, int iterations, int length) {
    final hmac = Hmac(sha256, password);
    final out = BytesBuilder();
    var block = 1;
    while (out.length < length) {
      final blockIndex = [(block >> 24) & 0xff, (block >> 16) & 0xff, (block >> 8) & 0xff, block & 0xff];
      var u = hmac.convert([...salt, ...blockIndex]).bytes;
      final t = List<int>.from(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      out.add(t);
      block++;
    }
    return Uint8List.fromList(out.toBytes().sublist(0, length));
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
