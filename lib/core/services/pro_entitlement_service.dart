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
  static const int kOfflineGracePeriodHours = 72; // 3 days max offline validity

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
/// with High-Water Mark clock rollback detection & 72-hour offline grace protection.
class ProEntitlementService {
  ProEntitlementService._();
  static final ProEntitlementService instance = ProEntitlementService._();

  FlutterSecureStorage? _customStorage;
  FlutterSecureStorage get _storage => _customStorage ?? const FlutterSecureStorage(
        aOptions: AndroidOptions(storageNamespace: 'packbuddy_pro_vault'),
      );

  @visibleForTesting
  void setMockStorage(FlutterSecureStorage storage) {
    _customStorage = storage;
  }

  static const String _keyIsPro = 'secure_is_pro_member';
  static const String _keyProExpiresAt = 'secure_pro_expires_at';
  static const String _keyLastVerifiedAt = 'secure_last_verified_at';
  static const String _keyMaxMonotonicTs = 'secure_max_monotonic_ts';
  static const String _keyProSource = 'secure_pro_source';

  String? _safeCurrentUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _firestoreLiveSubscription;

  /// Resolves effective Pro status considering offline grace period (72h) and clock rollback protection
  Future<bool> resolveEffectivePro({String? uid}) async {
    final effectiveUid = uid ?? _safeCurrentUid();
    final prefix = effectiveUid != null && effectiveUid.isNotEmpty ? '${effectiveUid}_' : '';

    try {
      final rawIsPro = await _storage.read(key: '$prefix$_keyIsPro');
      if (rawIsPro != 'true') {
        // Fallback check to un-prefixed key or PreferencesService
        final rawGlobal = await _storage.read(key: _keyIsPro);
        if (rawGlobal != 'true') {
          return false;
        }
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

      // 3. Offline Grace Period check: max 72 hours without online verification
      final rawLastVerified = await _storage.read(key: '$prefix$_keyLastVerifiedAt');
      if (rawLastVerified != null) {
        final lastVerified = int.tryParse(rawLastVerified) ?? 0;
        const maxOfflineMs = ProFeatureGate.kOfflineGracePeriodHours * 3600 * 1000;
        if (now - lastVerified > maxOfflineMs) {
          debugPrint('[ProEntitlement] Offline grace period (72h) expired. Online verification required.');
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('[ProEntitlement] Error resolving secure Pro status: $e');
      return PreferencesService.instance.isProUser(uid: effectiveUid);
    }
  }

  /// Sets or updates Pro entitlement securely
  Future<void> setProEntitlement({
    required bool isPro,
    DateTime? expiresAt,
    required String source,
    String? uid,
  }) async {
    final effectiveUid = uid ?? _safeCurrentUid();
    final prefix = effectiveUid != null && effectiveUid.isNotEmpty ? '${effectiveUid}_' : '';
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      await _storage.write(key: '$prefix$_keyIsPro', value: isPro ? 'true' : 'false');
      await _storage.write(key: _keyIsPro, value: isPro ? 'true' : 'false');
      await _storage.write(key: '$prefix$_keyLastVerifiedAt', value: now.toString());
      await _storage.write(key: '$prefix$_keyMaxMonotonicTs', value: now.toString());
      await _storage.write(key: '$prefix$_keyProSource', value: source);

      if (expiresAt != null) {
        await _storage.write(
          key: '$prefix$_keyProExpiresAt',
          value: expiresAt.millisecondsSinceEpoch.toString(),
        );
      } else if (!isPro) {
        await _storage.delete(key: '$prefix$_keyProExpiresAt');
      }

      // Sync to PreferencesService for instant synchronous fallback
      await PreferencesService.instance.setProUser(isPro, uid: effectiveUid);
    } catch (e) {
      debugPrint('[ProEntitlement] Error saving secure Pro entitlement: $e');
      await PreferencesService.instance.setProUser(isPro, uid: effectiveUid);
    }
  }

  /// Clears secure entitlement on logout
  Future<void> clearProEntitlement({String? uid}) async {
    final effectiveUid = uid ?? _safeCurrentUid();
    final prefix = effectiveUid != null && effectiveUid.isNotEmpty ? '${effectiveUid}_' : '';
    try {
      await _storage.delete(key: '$prefix$_keyIsPro');
      await _storage.delete(key: '$prefix$_keyProExpiresAt');
      await _storage.delete(key: '$prefix$_keyLastVerifiedAt');
      await _storage.delete(key: '$prefix$_keyProSource');
      await _storage.delete(key: _keyIsPro);
      await PreferencesService.instance.setProUser(false, uid: effectiveUid);
      await PreferencesService.instance.clearDeviceProStatus();
    } catch (e) {
      debugPrint('[ProEntitlement] Error clearing secure entitlement: $e');
    }
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
          final bool isRemotePro = (data['isPremium'] == true) ||
              (data['is_premium'] == true) ||
              (data['isPro'] == true) ||
              (data['pro'] == true) ||
              (data['adminGrantedPro'] == true);

          DateTime? expiresAt;
          if (data['proExpiresAt'] != null) {
            if (data['proExpiresAt'] is Timestamp) {
              expiresAt = (data['proExpiresAt'] as Timestamp).toDate();
            } else if (data['proExpiresAt'] is String) {
              expiresAt = DateTime.tryParse(data['proExpiresAt']);
            }
          }

          final source = data['adminGrantedPro'] == true ? 'admin_live_grant' : 'firestore_live_sync';
          await setProEntitlement(
            isPro: isRemotePro,
            expiresAt: expiresAt,
            source: source,
            uid: uid,
          );

          onStatusUpdated(isRemotePro);
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
