import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';

/// Service responsible for remote Firestore persistence and local caching of UserProfile
class ProfileService {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  ProfileService({this.firestore, this.auth});

  FirebaseFirestore? get _firestore => firestore;
  FirebaseAuth? get _auth => auth;

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Fetches profile from cache first, then syncs with remote Firestore
  Future<UserProfile?> fetchProfile(String uid) async {
    if (uid.isEmpty) return null;

    UserProfile? cachedProfile;
    final cachedJson = PreferencesService.instance.getCachedUserProfile(uid);
    if (cachedJson != null && cachedJson.isNotEmpty) {
      try {
        cachedProfile = UserProfile.fromJson(cachedJson, fallbackUid: uid);
      } catch (_) {}
    }

    // Safety net: Check dedicated avatar storage if cached profile lacks photoUrl
    final dedicatedAvatar = PreferencesService.instance.getUserAvatar(uid: uid);
    if (cachedProfile != null &&
        (cachedProfile.photoUrl == null || cachedProfile.photoUrl!.trim().isEmpty) &&
        dedicatedAvatar != null &&
        dedicatedAvatar.trim().isNotEmpty) {
      cachedProfile = cachedProfile.copyWith(photoUrl: dedicatedAvatar.trim());
    }

    if (!_isFirebaseReady && _firestore == null) {
      return cachedProfile ?? _createDefaultProfile(uid);
    }

    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final doc = await firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        var profile = UserProfile.fromMap(data, fallbackUid: uid);

        // AVATAR PRESERVATION & SELF-HEALING:
        // If Firestore doc has null/empty photoUrl (e.g. wiped by previous bug or offline set),
        // but local cache or dedicated preference has a valid avatar, preserve and heal Firestore!
        final localPhoto = (cachedProfile?.photoUrl != null && cachedProfile!.photoUrl!.trim().isNotEmpty)
            ? cachedProfile.photoUrl!.trim()
            : (dedicatedAvatar != null && dedicatedAvatar.trim().isNotEmpty ? dedicatedAvatar.trim() : null);

        if ((profile.photoUrl == null || profile.photoUrl!.trim().isEmpty) &&
            localPhoto != null &&
            localPhoto.isNotEmpty) {
          profile = profile.copyWith(photoUrl: localPhoto);
          try {
            unawaited(firestore.collection('users').doc(uid).set({
              'photoUrl': localPhoto,
            }, SetOptions(merge: true)));
          } catch (_) {}
        } else if (profile.photoUrl != null && profile.photoUrl!.trim().isNotEmpty) {
          // Mirror Firestore's valid avatar to dedicated local storage
          unawaited(PreferencesService.instance.setUserAvatar(profile.photoUrl!.trim(), uid: uid));
        }

        await PreferencesService.instance.setCachedUserProfile(uid, profile.toJson());
        unawaited(updateLastActive(uid));
        return profile;
      } else if (cachedProfile != null) {
        return cachedProfile;
      } else {
        final fallback = _createDefaultProfile(uid);
        await PreferencesService.instance.setCachedUserProfile(uid, fallback.toJson());
        return fallback;
      }
    } catch (e) {
      debugPrint('[ProfileService] fetchProfile error: $e');
      return cachedProfile ?? _createDefaultProfile(uid);
    }
  }

  /// Records real-time user presence heartbeat to Firestore and local cache
  Future<void> updateLastActive(String uid) async {
    if (uid.isEmpty) return;
    final now = DateTime.now();
    try {
      if (_isFirebaseReady || _firestore != null) {
        final fs = _firestore ?? FirebaseFirestore.instance;
        unawaited(fs.collection('users').doc(uid).set({
          'lastActiveAt': now.toIso8601String(),
        }, SetOptions(merge: true)).catchError((_) {}));
      }
    } catch (_) {}
  }

  /// Format validation for unique username handles (@handle)
  static bool isValidUsername(String username) {
    final clean = username.trim().toLowerCase();
    final regex = RegExp(r'^[a-z0-9_]{3,20}$');
    return regex.hasMatch(clean);
  }

  /// Checks whether a given username is available or belongs to currentUid
  Future<bool> isUsernameAvailable(String username, {String? currentUid}) async {
    final clean = username.trim().toLowerCase();
    if (!isValidUsername(clean)) return false;
    if (!_isFirebaseReady && _firestore == null) return true;

    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final doc = await firestore.collection('usernames').doc(clean).get();
      if (!doc.exists) return true;
      final data = doc.data();
      if (data != null && currentUid != null && data['uid'] == currentUid) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ProfileService] isUsernameAvailable notice: $e');
      return true;
    }
  }

  /// Updates profile metadata in Firestore and local cache
  Future<UserProfile> updateProfile(
    String uid, {
    String? displayName,
    String? bio,
    String? homeCountryCode,
    String? homeCity,
    String? photoUrl,
    bool clearPhoto = false,
    String? username,
    bool clearUsername = false,
    String? travelStatus,
    bool clearTravelStatus = false,
    List<String>? travelStyles,
  }) async {
    final existing = await fetchProfile(uid) ?? _createDefaultProfile(uid);

    final resolvedPhotoUrl = clearPhoto ? null : (photoUrl ?? existing.photoUrl);
    final resolvedUsername = clearUsername
        ? null
        : (username != null ? username.trim().toLowerCase() : existing.username);
    final resolvedTravelStatus = clearTravelStatus
        ? null
        : (travelStatus != null ? travelStatus.trim() : existing.travelStatus);
    final resolvedTravelStyles = travelStyles ?? existing.travelStyles;

    final updated = existing.copyWith(
      displayName: displayName ?? existing.displayName,
      bio: bio ?? existing.bio,
      homeCountryCode: homeCountryCode ?? existing.homeCountryCode,
      homeCity: homeCity ?? existing.homeCity,
      photoUrl: resolvedPhotoUrl,
      clearPhoto: clearPhoto,
      username: resolvedUsername,
      clearUsername: clearUsername,
      travelStatus: resolvedTravelStatus,
      clearTravelStatus: clearTravelStatus,
      travelStyles: resolvedTravelStyles,
      lastActiveAt: DateTime.now(),
    );

    // Save to offline cache and dedicated avatar storage immediately
    await PreferencesService.instance.setCachedUserProfile(uid, updated.toJson());
    await PreferencesService.instance.setUserAvatar(resolvedPhotoUrl, uid: uid);

    // Update Firebase Auth user display name and photoURL if changed
    try {
      final user = _auth?.currentUser ??
          (_isFirebaseReady ? FirebaseAuth.instance.currentUser : null);
      if (user != null) {
        if (displayName != null && displayName.isNotEmpty && user.displayName != displayName) {
          await user.updateDisplayName(displayName);
        }
        if (photoUrl != null || clearPhoto) {
          if (resolvedPhotoUrl == null || resolvedPhotoUrl.startsWith('http')) {
            await user.updatePhotoURL(resolvedPhotoUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('[ProfileService] auth update notice: $e');
    }

    // Persist to Cloud Firestore
    if (_isFirebaseReady || _firestore != null) {
      try {
        final firestore = _firestore ?? FirebaseFirestore.instance;
        final countryObj = (updated.homeCountryCode != null && updated.homeCountryCode!.isNotEmpty)
            ? Country.findByCode(updated.homeCountryCode!)
            : null;

        // Manage unique username handle registry
        if (resolvedUsername != null &&
            resolvedUsername.isNotEmpty &&
            resolvedUsername != existing.username) {
          if (existing.username != null && existing.username!.isNotEmpty) {
            unawaited(firestore.collection('usernames').doc(existing.username!).delete().catchError((_) {}));
          }
          unawaited(firestore.collection('usernames').doc(resolvedUsername).set({
            'uid': uid,
            'updatedAt': DateTime.now().toIso8601String(),
          }).catchError((_) {}));
        } else if (clearUsername && existing.username != null && existing.username!.isNotEmpty) {
          unawaited(firestore.collection('usernames').doc(existing.username!).delete().catchError((_) {}));
        }

        await firestore.collection('users').doc(uid).set({
          'displayName': updated.displayName,
          'bio': updated.bio,
          'homeCountryCode': updated.homeCountryCode,
          'homeCity': updated.homeCity,
          'countryCode': updated.homeCountryCode,
          'countryName': countryObj?.name,
          'photoUrl': updated.photoUrl,
          'username': updated.username,
          'travelStatus': updated.travelStatus,
          'travelStyles': updated.travelStyles,
          'lastActiveAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[ProfileService] firestore update notice: $e');
      }
    }

    return updated;
  }

  UserProfile _createDefaultProfile(String uid) {
    final user = _auth?.currentUser ??
        (_isFirebaseReady ? FirebaseAuth.instance.currentUser : null);
    final isPro = PreferencesService.instance.isProUser(uid: uid);
    final dedicatedAvatar = PreferencesService.instance.getUserAvatar(uid: uid);

    return UserProfile(
      uid: uid,
      displayName: user?.displayName,
      email: user?.email,
      photoUrl: (dedicatedAvatar != null && dedicatedAvatar.isNotEmpty)
          ? dedicatedAvatar
          : user?.photoURL,
      createdAt: user?.metadata.creationTime ?? DateTime.now(),
      lastActiveAt: DateTime.now(),
      isPro: isPro,
    );
  }
}
