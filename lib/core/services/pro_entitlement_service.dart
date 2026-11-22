import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/telemetry_service.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/travel_map_story_card.dart';

/// Single source of truth for PackBuddy Pro limits & feature gates
class ProFeatureGate {
  ProFeatureGate._();

  static const int kFreeMaxTrips = 2;
  static const int kFreeMaxActiveTrips = 1;
  static const int kFreeMaxVaultDocs = 5;
  static const int kMaxSingleFileBytes = 10 * 1024 * 1024; // 10 MB strict limit
  static const int kFreeMaxCloudBytes = 50 * 1024 * 1024; // 50 MB
  static const int kProMaxCloudBytes = 5 * 1024 * 1024 * 1024; // 5 GB
  static const int kFreeMaxItineraryActivitiesPerDay = 3;

  static const Set<StoryCardTheme> kFreeStoryCardThemes = {
    StoryCardTheme.midnight,
    StoryCardTheme.sunset,
    StoryCardTheme.minimalLight,
    StoryCardTheme.sandLight,
  };

  static const Set<StoryCardLayout> kFreeStoryCardLayouts = {
    StoryCardLayout.classic,
    StoryCardLayout.minimal,
    StoryCardLayout.journey,
  };

  static const Set<String> kFreeWidgetThemeKeys = {
    'midnight',
    'sunset',
    'minimalLight',
    'sandLight',
    'classic_dark',
    'classic_light',
  };

  static bool canCreateTrip({
    required bool isPro,
    required int totalTrips,
    required int activeTrips,
  }) {
    if (isPro) return true;
    if (activeTrips >= kFreeMaxActiveTrips) return false;
    if (totalTrips >= kFreeMaxTrips) return false;
    return true;
  }

  static bool canAddVaultDocument({
    required bool isPro,
    required int currentDocCount,
    required int fileSizeBytes,
    required int totalVaultBytes,
  }) {
    // Single file limit applies to both Free and Pro (10 MB RAM / OOM protection)
    if (fileSizeBytes > kMaxSingleFileBytes) return false;

    if (isPro) {
      return (totalVaultBytes + fileSizeBytes) <= kProMaxCloudBytes;
    }

    if (currentDocCount >= kFreeMaxVaultDocs) return false;
    if ((totalVaultBytes + fileSizeBytes) > kFreeMaxCloudBytes) return false;
    return true;
  }

  static bool canAddItineraryActivity({
    required bool isPro,
    required int currentActivitiesInDay,
  }) {
    if (isPro) return true;
    return currentActivitiesInDay < kFreeMaxItineraryActivitiesPerDay;
  }

  static bool canUseStoryTheme({
    required bool isPro,
    required StoryCardTheme theme,
  }) {
    if (isPro) return true;
    return kFreeStoryCardThemes.contains(theme);
  }

  static bool canUseStoryLayout({
    required bool isPro,
    required StoryCardLayout layout,
  }) {
    if (isPro) return true;
    return kFreeStoryCardLayouts.contains(layout);
  }

  static bool canUseWidgetTheme({
    required bool isPro,
    required String themeKey,
  }) {
    if (isPro) return true;
    return kFreeWidgetThemeKeys.contains(themeKey);
  }

  static bool canExportBudget({required bool isPro}) {
    return isPro;
  }

  static bool canSyncToCloud({
    required bool isPro,
    required int totalCloudBytes,
  }) {
    final limit = isPro ? kProMaxCloudBytes : kFreeMaxCloudBytes;
    return totalCloudBytes <= limit;
  }
}

/// Secure Entitlement Service backed by Android Keystore (flutter_secure_storage)
/// with High-Water Mark clock rollback detection. Offline, Pro stays valid until the stored
/// `proExpiresAt`; online refunds/cancellations are caught by [recordStoreNoActiveSubscription].
class ProEntitlementService {
  ProEntitlementService._();
  static final ProEntitlementService instance = ProEntitlementService._();

  FlutterSecureStorage? _customStorage;
  FlutterSecureStorage get _storage => _customStorage ?? const FlutterSecureStorage(
        aOptions: AndroidOptions(storageNamespace: 'packbuddy_pro_vault'),
      );

  @visibleForTesting
  void setMockStorage(FlutterSecureStorage? storage) {
    _customStorage = storage;
  }

  static const String _keyIsPro = 'secure_is_pro_member';
  static const String _keyProExpiresAt = 'secure_pro_expires_at';
  static const String _keyLastVerifiedAt = 'secure_last_verified_at';
  static const String _keyMaxMonotonicTs = 'secure_max_monotonic_ts';
  static const String _keyProSource = 'secure_pro_source';
  static const String _keyStoreMisses = 'secure_store_no_sub_count';

  /// Consecutive clean "no active subscription" store answers that revoke store-sourced Pro.
  static const int storeRevokeThreshold = 2;

  /// Scope used only when no Firebase user exists (unit tests / signed-out).
  /// It is never consulted for a signed-in uid, so Pro can't leak across accounts.
  static const String _guestScope = 'guest';

  /// Store-originated entitlement sources. Remote (Firestore) sync may never
  /// revoke these; only the store (expiry / restore) governs them.
  static bool isStoreSource(String? source) {
    if (source == null) return false;
    return source.startsWith('google_play') ||
        source == 'unit_test_purchase' ||
        source == 'debug_sandbox_purchase';
  }

  /// Billing period lengths used to compute a local `expiresAt` for store purchases.
  /// A small grace window covers Play's renewal processing delay.
  static const Duration monthlyPeriod = Duration(days: 30);
  static const Duration annualPeriod = Duration(days: 365);
  static const Duration renewalGrace = Duration(days: 3);

  static DateTime expiryForProduct(String productId, {DateTime? from}) {
    final base = from ?? DateTime.now();
    final period = productId.contains('monthly') ? monthlyPeriod : annualPeriod;
    return base.add(period).add(renewalGrace);
  }

  String? _safeCurrentUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  String _prefixFor(String? uid) {
    final scope = (uid != null && uid.isNotEmpty) ? uid : _guestScope;
    return '${scope}_';
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _firestoreLiveSubscription;

  /// Resolves effective Pro status from the stored expiry and clock rollback protection.
  /// There is no offline time limit: a paid user stays Pro offline until `proExpiresAt`.
  /// Reads only the uid-scoped key; there is no device-global fallback.
  Future<bool> resolveEffectivePro({String? uid}) async {
    final effectiveUid = uid ?? _safeCurrentUid();
    final prefix = _prefixFor(effectiveUid);

    try {
      // Remove the legacy device-global flag (pre-v1.0) so it can never be read again.
      await _storage.delete(key: _keyIsPro);

      final rawIsPro = await _storage.read(key: '$prefix$_keyIsPro');
      if (rawIsPro != 'true') {
        return false;
      }

      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. High-water mark clock rollback check
      final rawMaxTs = await _storage.read(key: '$prefix$_keyMaxMonotonicTs');
      if (rawMaxTs != null) {
        final maxTs = int.tryParse(rawMaxTs) ?? 0;
        // If current device time is more than 5 minutes behind highest recorded timestamp,
        // user may have rolled back the device clock!
        if (now < (maxTs - 300000)) {
          debugPrint('[ProEntitlement] Clock rollback detected! Pausing offline Pro entitlement.');
          TelemetryService.instance.logProStatusChanged(isPro: false, source: 'clock_rollback_detected');
          return false;
        }
      }

      // Update high-water mark timestamp
      await _storage.write(key: '$prefix$_keyMaxMonotonicTs', value: now.toString());

      // 2. Check explicit expiration timestamp (if set)
      final rawExpires = await _storage.read(key: '$prefix$_keyProExpiresAt');
      if (rawExpires != null) {
        final expiresAt = int.tryParse(rawExpires);
        if (expiresAt != null && now > expiresAt) {
          debugPrint('[ProEntitlement] Pro subscription expired.');
          await setProEntitlement(isPro: false, source: 'expired', uid: effectiveUid);
          return false;
        }
      }

      return true;
    } catch (e) {
      // Keystore failure: fail closed. Never fall back to plaintext SharedPreferences.
      debugPrint('[ProEntitlement] Error resolving secure Pro status: $e');
      return false;
    }
  }

  /// Returns the source tag of the currently stored entitlement (uid-scoped).
  Future<String?> currentSource({String? uid}) async {
    try {
      return await _storage.read(key: '${_prefixFor(uid ?? _safeCurrentUid())}$_keyProSource');
    } catch (_) {
      return null;
    }
  }

  /// Sets or updates Pro entitlement securely (uid-scoped only).
  /// This counts as an online verification and refreshes `lastVerifiedAt`, so it must
  /// only be called with a verified source (store event or server-side data).
  Future<void> setProEntitlement({
    required bool isPro,
    DateTime? expiresAt,
    required String source,
    String? uid,
  }) async {
    final effectiveUid = uid ?? _safeCurrentUid();
    final prefix = _prefixFor(effectiveUid);
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await _storage.write(key: '$prefix$_keyIsPro', value: isPro ? 'true' : 'false');
      await _storage.write(key: '$prefix$_keyLastVerifiedAt', value: now.toString());
      await _storage.write(key: '$prefix$_keyMaxMonotonicTs', value: now.toString());
      await _storage.write(key: '$prefix$_keyProSource', value: source);
      await _storage.delete(key: '$prefix$_keyStoreMisses');

      if (expiresAt != null) {
        await _storage.write(
          key: '$prefix$_keyProExpiresAt',
          value: expiresAt.millisecondsSinceEpoch.toString(),
        );
      } else {
        await _storage.delete(key: '$prefix$_keyProExpiresAt');
      }
    } catch (e) {
      debugPrint('[ProEntitlement] Error saving secure Pro entitlement: $e');
    }

    // Mirror for synchronous UI reads (uid-scoped only, never device-global).
    if (effectiveUid != null && effectiveUid.isNotEmpty) {
      await PreferencesService.instance.setProUser(isPro, uid: effectiveUid);
    }
  }

  /// Applies Pro state coming from the server (Firestore users/{uid}).
  ///
  /// * `remoteIsPro == true`  → grant (admin grant / server-verified).
  /// * `remoteIsPro == false` → revoke only if the local entitlement did NOT come from the store.
  ///   The client can't write Pro=true to Firestore (rules block self-elevation), so a
  ///   `false` remote flag says nothing about a Google Play purchase.
  ///
  /// Returns the effective Pro status after applying.
  Future<bool> applyRemoteEntitlement({
    required bool remoteIsPro,
    DateTime? expiresAt,
    required String source,
    String? uid,
  }) async {
    final effectiveUid = uid ?? _safeCurrentUid();
    if (remoteIsPro) {
      await setProEntitlement(isPro: true, expiresAt: expiresAt, source: source, uid: effectiveUid);
      return resolveEffectivePro(uid: effectiveUid);
    }
    final existingSource = await currentSource(uid: effectiveUid);
    if (isStoreSource(existingSource)) {
      return resolveEffectivePro(uid: effectiveUid);
    }
    final currentlyPro = await resolveEffectivePro(uid: effectiveUid);
    if (currentlyPro) {
      await setProEntitlement(isPro: false, source: source, uid: effectiveUid);
    }
    return false;
  }

  /// Call only for a clean store answer (no network/billing-service error) saying this account
  /// owns no active subscription. The [storeRevokeThreshold]-th consecutive answer revokes
  /// store-sourced Pro at once (refund / cancellation); admin or server grants are never touched.
  /// Any [setProEntitlement] call resets the streak. Returns the effective Pro status.
  Future<bool> recordStoreNoActiveSubscription({String? uid}) async {
    final effectiveUid = uid ?? _safeCurrentUid();
    if (!isStoreSource(await currentSource(uid: effectiveUid))) {
      return resolveEffectivePro(uid: effectiveUid);
    }
    final key = '${_prefixFor(effectiveUid)}$_keyStoreMisses';
    var misses = 0; // stays 0 on a storage failure, so an unrecorded streak never revokes
    try {
      misses = (int.tryParse(await _storage.read(key: key) ?? '') ?? 0) + 1;
      if (misses < storeRevokeThreshold) await _storage.write(key: key, value: '$misses');
    } catch (e) {
      debugPrint('[ProEntitlement] Error recording store answer: $e');
    }
    if (misses < storeRevokeThreshold) return resolveEffectivePro(uid: effectiveUid);
    debugPrint('[ProEntitlement] Store reports no active subscription twice. Revoking store Pro.');
    await setProEntitlement(isPro: false, source: 'store_no_active_subscription', uid: effectiveUid);
    TelemetryService.instance.logProStatusChanged(isPro: false, source: 'store_no_active_subscription');
    return false;
  }

  /// Clears secure entitlement on logout
  Future<void> clearProEntitlement({String? uid}) async {
    final effectiveUid = uid ?? _safeCurrentUid();
    final prefix = _prefixFor(effectiveUid);
    try {
      await _storage.delete(key: '$prefix$_keyIsPro');
      await _storage.delete(key: '$prefix$_keyProExpiresAt');
      await _storage.delete(key: '$prefix$_keyLastVerifiedAt');
      await _storage.delete(key: '$prefix$_keyProSource');
      await _storage.delete(key: '$prefix$_keyStoreMisses');
      await _storage.delete(key: _keyIsPro); // legacy device-global key
    } catch (e) {
      debugPrint('[ProEntitlement] Error clearing secure entitlement: $e');
    }
    await PreferencesService.instance.setProUser(false, uid: effectiveUid);
    await PreferencesService.instance.clearDeviceProStatus();
  }

  /// Fields on users/{uid} that actually carry a Pro entitlement.
  static const List<String> remoteProKeys = ['isPremium', 'is_premium', 'isPro', 'pro', 'adminGrantedPro'];

  static bool hasRemoteProKey(Map<String, dynamic> data) => remoteProKeys.any(data.containsKey);

  static bool remoteProValue(Map<String, dynamic> data) => remoteProKeys.any((k) => data[k] == true);

  static DateTime? remoteExpiresAt(Map<String, dynamic> data) {
    final raw = data['proExpiresAt'];
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  /// Listens to live Firestore user document for real-time Admin Pro grant/revocation
  void startLiveUserEntitlementListener(
    String uid, {
    required void Function(bool isPro) onStatusUpdated,
  }) {
    try {
      _firestoreLiveSubscription?.cancel();
      _firestoreLiveSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen(
        (doc) async {
          if (!doc.exists || doc.data() == null) return;
          final data = doc.data()!;
          // Writes that only touch subscription/sync metadata must not change Pro state.
          if (!hasRemoteProKey(data)) return;

          final source = data['adminGrantedPro'] == true ? 'admin_live_grant' : 'firestore_live_sync';
          final effective = await applyRemoteEntitlement(
            remoteIsPro: remoteProValue(data),
            expiresAt: remoteExpiresAt(data),
            source: source,
            uid: uid,
          );

          onStatusUpdated(effective);
        },
        onError: (err) {
          debugPrint('[ProEntitlement] Firestore live entitlement stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('[ProEntitlement] Firestore not initialized or test environment: $e');
    }
  }

  void cancelLiveListener() {
    _firestoreLiveSubscription?.cancel();
    _firestoreLiveSubscription = null;
  }
}
