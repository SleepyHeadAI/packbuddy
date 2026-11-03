import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/currency_service.dart';
import '../../data/local_db/database_helper.dart';
import '../admin/admin_service.dart';
import '../travel_map/data/travel_map_service.dart';

/// Contract defining authentication operations for PackBuddy
abstract class AuthService {
  /// Stream emitting user authentication changes (sign in, sign out, token refresh)
  Stream<User?> get authStateChanges;

  /// Currently signed in user or null
  User? get currentUser;

  /// Authenticate with email & password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  });

  /// Create new user account with email & password and trigger verification email
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Authenticate using Google OAuth
  Future<UserCredential?> signInWithGoogle();

  /// Sign out current user from all providers
  Future<void> signOut();

  /// Send or resend email verification to current user
  Future<void> sendEmailVerification();

  /// Reload current user profile from Firebase to refresh claims and emailVerified status
  Future<User?> reloadUser();

  /// Upsert user profile document in Firestore at `users/{uid}` for admin dashboard & reporting
  /// Returns the effective `isPremium` status.
  Future<bool> syncUserProfile(User user);

  /// Callback invoked when an account with pending deletion is recovered upon login
  void Function(String uid)? get onAccountRestoredFromDeletion;
  set onAccountRestoredFromDeletion(void Function(String uid)? callback);

  /// Schedules account for deletion in 15 days
  Future<void> requestAccountDeletion(String uid);

  /// Updates lastActiveAt timestamp for current user in Firestore
  Future<void> updateLastActive(String uid);

  /// Records active session duration (in seconds) for a user in Firestore
  Future<void> recordSessionDuration(String uid, int seconds);

  /// Send password reset link to user's email address
  Future<void> sendPasswordResetEmail({required String email});
}

/// Firebase implementation of [AuthService]
class FirebaseAuthService implements AuthService {
  FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore? _firestore;

  @override
  void Function(String uid)? onAccountRestoredFromDeletion;

  static const String _defaultServerClientId =
      '719651073535-34t98obhv0kcpifa6f29tme61s04o2jm.apps.googleusercontent.com';

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: _defaultServerClientId,
            ),
        // ignore: prefer_initializing_formals
        _firestore = firestore;

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _firebaseAuth {
    try {
      return _auth ??= FirebaseAuth.instance;
    } catch (e) {
      debugPrint('[FirebaseAuthService] FirebaseAuth instance resolution error: $e');
      rethrow;
    }
  }

  @override
  Stream<User?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges();
    } catch (e) {
      debugPrint('[FirebaseAuthService] authStateChanges stream error: $e');
      return const Stream.empty();
    }
  }

  @override
  User? get currentUser {
    try {
      return _firebaseAuth.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        unawaited(syncUserProfile(credential.user!));
      }
      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      );
    }
  }

  @override
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Automatically dispatch email verification with localized language code
      try {
        final activeLocale = PreferencesService.instance.getLocale();
        final langCode = activeLocale?.languageCode ?? 'en';
        try {
          await _firebaseAuth.setLanguageCode(langCode);
        } catch (_) {}
        await credential.user?.sendEmailVerification();
      } catch (verificationError) {
        debugPrint('[FirebaseAuthService] sendEmailVerification warning: $verificationError');
      }

      if (credential.user != null) {
        unawaited(syncUserProfile(credential.user!));
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      );
    }
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the interactive sign-in flow
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        unawaited(syncUserProfile(userCredential.user!));
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('[FirebaseAuthService] Firebase Auth error during Google Sign-In: [${e.code}] ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[FirebaseAuthService] Google Sign-In exception: $e\n$stackTrace');
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.toString(),
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('[FirebaseAuthService] Error during signOut: $e');
      try {
        await _firebaseAuth.signOut();
      } catch (_) {}
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        final activeLocale = PreferencesService.instance.getLocale();
        final langCode = activeLocale?.languageCode ?? 'en';
        try {
          await _firebaseAuth.setLanguageCode(langCode);
        } catch (_) {}
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'email-verification-failed',
        message: e.toString(),
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      final activeLocale = PreferencesService.instance.getLocale();
      final langCode = activeLocale?.languageCode ?? 'en';
      try {
        await _firebaseAuth.setLanguageCode(langCode);
      } catch (_) {}
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'reset-password-failed',
        message: e.toString(),
      );
    }
  }

  @override
  Future<User?> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        final refreshed = _firebaseAuth.currentUser;
        if (refreshed != null) {
          unawaited(syncUserProfile(refreshed));
        }
        return refreshed;
      }
      return _firebaseAuth.currentUser;
    } catch (e) {
      debugPrint('[FirebaseAuthService] reloadUser notice: $e');
      return _firebaseAuth.currentUser;
    }
  }

  @override
  Future<bool> syncUserProfile(User user) async {
    try {
      if (!_isFirebaseReady && _firestore == null) {
        return PreferencesService.instance.isProUser(uid: user.uid);
      }
      final firestore = _firestore ?? FirebaseFirestore.instance;

      String provider = 'password';
      try {
        if (user.providerData.isNotEmpty) {
          provider = user.providerData.first.providerId;
        }
      } catch (_) {}

      final now = DateTime.now().toIso8601String();
      String createdAt = now;
      try {
        if (user.metadata.creationTime != null) {
          createdAt = user.metadata.creationTime!.toIso8601String();
        }
      } catch (_) {}

      String? email;
      try {
        email = user.email;
      } catch (_) {}

      String? displayName;
      try {
        displayName = user.displayName;
      } catch (_) {}

      String? photoUrl;
      try {
        photoUrl = user.photoURL;
      } catch (_) {}

      bool emailVerified = false;
      try {
        emailVerified = user.emailVerified;
      } catch (_) {}

      // 1. Fetch remote user document to prevent overwriting admin-granted Pro status
      final userDocRef = firestore.collection('users').doc(user.uid);
      DocumentSnapshot<Map<String, dynamic>>? existingDoc;
      try {
        existingDoc = await userDocRef.get();
      } catch (e) {
        debugPrint('[FirebaseAuthService] fetch existing user doc notice: $e');
      }

      final bool remoteExists = existingDoc?.exists ?? false;
      final remoteData = existingDoc?.data();

      // PRO ENTITLEMENT PERSISTENCE & CONTAGION PREVENTION:
      // If remote user document exists and specifies Pro (checking isPremium, is_premium, isPro, pro), it is the authoritative source of truth.
      // Super admin accounts automatically retain Pro entitlement.
      // If it's a new registration or converting guest, inherit local device pro status.
      final bool remoteHasIsPremium = remoteExists &&
          remoteData != null &&
          (remoteData.containsKey('isPremium') ||
              remoteData.containsKey('is_premium') ||
              remoteData.containsKey('isPro') ||
              remoteData.containsKey('pro'));
      final bool remoteIsPremium = remoteHasIsPremium &&
          ((remoteData['isPremium'] == true) ||
              (remoteData['is_premium'] == true) ||
              (remoteData['isPro'] == true) ||
              (remoteData['pro'] == true));
      final bool localScopedPro = PreferencesService.instance.isProUser(uid: user.uid);
      final bool localDevicePro = PreferencesService.instance.isProUser();
      final bool isSuperAdmin = user.email?.trim().toLowerCase() == kAdminEmail;

      final bool effectiveIsPremium = isSuperAdmin ||
          remoteIsPremium ||
          localScopedPro ||
          (!remoteHasIsPremium && localDevicePro);

      await PreferencesService.instance.setProUser(effectiveIsPremium, uid: user.uid);

      // If user has effective Pro but remote was not marked Pro, persist to Firestore
      if (effectiveIsPremium && !remoteIsPremium) {
        try {
          await userDocRef.set({
            'isPremium': true,
            'is_premium': true,
            'isPro': true,
            'pro': true,
            'proSyncedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('[FirebaseAuthService] Error syncing effective pro to Firestore: $e');
        }
      }

      // ADOPT GUEST DATA:
      // Automatically migrate offline/guest trips, expenses, and documents to the logged-in user
      try {
        await DatabaseHelper.instance.migrateGuestDataToUser(user.uid);
      } catch (e) {
        debugPrint('[FirebaseAuthService] migrateGuestDataToUser notice: $e');
      }

      // AUTO-DETECT COUNTRY & DEFAULT CURRENCY (Phase 2):
      final remoteCountryCode = remoteData?['countryCode'] as String?;
      final remoteCountryName = remoteData?['countryName'] as String?;
      final remoteCurrencyCode = remoteData?['currencyCode'] as String?;
      final hasManualCurrency = PreferencesService.instance.hasUserSelectedCurrency(uid: user.uid);

      String countryCode = remoteCountryCode ?? '';
      String countryName = remoteCountryName ?? '';
      String currencyCode = remoteCurrencyCode ?? '';

      if (hasManualCurrency) {
        currencyCode = PreferencesService.instance.getDefaultCurrency(uid: user.uid) ??
            (currencyCode.isNotEmpty ? currencyCode : 'USD');
      } else if (currencyCode.isEmpty) {
        final detected = CountryDetector.detectCountry();
        countryCode = detected.code;
        countryName = detected.name;
        currencyCode = detected.defaultCurrency;
        await PreferencesService.instance.setDefaultCurrency(currencyCode, uid: user.uid);
        await PreferencesService.instance.setCountryCode(countryCode, uid: user.uid);
        await PreferencesService.instance.setCountryName(countryName, uid: user.uid);
      } else {
        await PreferencesService.instance.setDefaultCurrency(currencyCode, uid: user.uid);
        if (countryCode.isNotEmpty) {
          await PreferencesService.instance.setCountryCode(countryCode, uid: user.uid);
        }
        if (countryName.isNotEmpty) {
          await PreferencesService.instance.setCountryName(countryName, uid: user.uid);
        }
      }

      if (countryCode.isEmpty) {
        final detected = CountryDetector.detectCountry();
        countryCode = detected.code;
        countryName = detected.name;
      }

      // 15-DAY GRACE PERIOD DELETION & AUTO-RECOVERY CHECK
      final remoteDeletionStatus = remoteData?['deletionStatus'] as String? ?? 'none';
      final remoteScheduledDeletion = remoteData?['scheduledPermanentDeletionAt'] as String?;
      if (remoteDeletionStatus == 'pending_deletion') {
        DateTime? scheduledAt;
        if (remoteScheduledDeletion != null) {
          scheduledAt = DateTime.tryParse(remoteScheduledDeletion);
        }
        final nowUtc = DateTime.now().toUtc();
        if (scheduledAt != null && nowUtc.isAfter(scheduledAt)) {
          // 15 Days Expired: Permanently purge all user collections in Firestore
          try {
            final collections = ['trips', 'expenses', 'checklist_items', 'documents'];
            for (final coll in collections) {
              final snap = await firestore.collection(coll).where('user_id', isEqualTo: user.uid).get();
              for (final doc in snap.docs) {
                await doc.reference.delete();
              }
            }
          } catch (e) {
            debugPrint('[FirebaseAuthService] Error purging expired user data: $e');
          }
          await userDocRef.set({
            'deletionStatus': 'none',
            'deletionRequestedAt': null,
            'scheduledPermanentDeletionAt': null,
            'isPremium': false,
            'totalVaultStorageBytes': 0,
            'updatedAt': nowUtc.toIso8601String(),
          }, SetOptions(merge: true));
        } else {
          // Within 15 Days: Auto-recovery
          await userDocRef.set({
            'deletionStatus': 'none',
            'deletionRequestedAt': null,
            'scheduledPermanentDeletionAt': null,
            'updatedAt': nowUtc.toIso8601String(),
          }, SetOptions(merge: true));
          onAccountRestoredFromDeletion?.call(user.uid);
        }
      }

      // MODERATION & BAN STATUS (Phase 3):
      final banStatus = (remoteData?['banStatus'] as String?) ?? 'none';
      final banExpiresAt = remoteData?['banExpiresAt'] as String?;
      final banReason = remoteData?['banReason'] as String?;
      final restrictedFeatures = (remoteData?['restrictedFeatures'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];

      await PreferencesService.instance.setBanStatus(banStatus, uid: user.uid);
      await PreferencesService.instance.setBanExpiresAt(banExpiresAt, uid: user.uid);
      await PreferencesService.instance.setBanReason(banReason, uid: user.uid);
      await PreferencesService.instance.setRestrictedFeatures(restrictedFeatures, uid: user.uid);

      // VAULT SECURITY (PIN & BIOMETRICS) CLOUD SYNCHRONIZATION:
      // Link security credentials directly to the logged-in user's account in Firestore
      final remoteVaultPin = remoteData?['vaultPin'] as String?;
      final remoteVaultBiometric = remoteData?['vaultBiometricEnabled'] as bool?;

      if (remoteVaultPin != null && remoteVaultPin.isNotEmpty) {
        await PreferencesService.instance.setVaultPin(remoteVaultPin, uid: user.uid);
      } else if (remoteData != null && remoteData.containsKey('vaultPin') && remoteVaultPin == null) {
        // Explicitly removed in cloud
        await PreferencesService.instance.setVaultPin(null, uid: user.uid);
      } else {
        // Adopt local/device PIN into account and sync to cloud if user had set one offline
        final localPin = PreferencesService.instance.getVaultPin(uid: user.uid) ??
            PreferencesService.instance.getVaultPin();
        if (localPin != null && localPin.isNotEmpty) {
          await PreferencesService.instance.setVaultPin(localPin, uid: user.uid);
          await userDocRef.set({
            'vaultPin': localPin,
            'vaultPinUpdatedAt': now,
          }, SetOptions(merge: true));
        }
      }

      if (remoteVaultBiometric != null) {
        await PreferencesService.instance.setVaultBiometricEnabled(remoteVaultBiometric, uid: user.uid);
      } else {
        final localBio = PreferencesService.instance.isVaultBiometricEnabled(uid: user.uid) ||
            PreferencesService.instance.isVaultBiometricEnabled();
        if (localBio) {
          await PreferencesService.instance.setVaultBiometricEnabled(true, uid: user.uid);
          await userDocRef.set({
            'vaultBiometricEnabled': true,
            'vaultBiometricUpdatedAt': now,
          }, SetOptions(merge: true));
        }
      }

      // CHECKLIST SEEDING & CLEARING CLOUD SYNCHRONIZATION:
      final remoteHasSeededChecklist = remoteData?['hasSeededChecklist'] as bool?;
      final remoteHasClearedChecklist = remoteData?['hasClearedChecklist'] as bool?;
      if (remoteHasSeededChecklist != null) {
        await PreferencesService.instance.setSeededChecklist(remoteHasSeededChecklist, uid: user.uid);
      }
      if (remoteHasClearedChecklist != null) {
        await PreferencesService.instance.setClearedChecklist(remoteHasClearedChecklist, uid: user.uid);
      }

      // WORLD TRAVEL MAP PERSISTENCE & RESTORE:
      // Perform bidirectional cloud sync and merge between local storage and Firestore users/{uid}
      try {
        await TravelMapService.instance.syncWithCloud(uid: user.uid);
      } catch (e) {
        debugPrint('[FirebaseAuthService] Travel map sync in syncUserProfile notice: $e');
      }

      final remoteCreatedAt =
          remoteExists && remoteData != null ? remoteData['createdAt'] : null;
      final effectiveCreatedAt =
          (remoteCreatedAt is String && remoteCreatedAt.isNotEmpty)
              ? remoteCreatedAt
              : createdAt;

      final updateFields = <String, dynamic>{
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'provider': provider,
        'emailVerified': emailVerified,
        'createdAt': effectiveCreatedAt,
        'lastLoginAt': now,
        'lastActiveAt': now,
        'lastInactivityWarningAt': null,
        'inactivityWarningCount': 0,
        'countryCode': countryCode,
        'countryName': countryName,
        'currencyCode': currencyCode,
        'banStatus': banStatus,
        'banExpiresAt': banExpiresAt,
        'banReason': banReason,
        'restrictedFeatures': restrictedFeatures,
      };

      // Only update Pro fields if we successfully verified the remote document (existing or new), or if effective is true.
      // This prevents transient fetch failures on reinstall from wiping out remote Pro entitlement.
      if (existingDoc != null || effectiveIsPremium) {
        updateFields['isPremium'] = effectiveIsPremium;
        updateFields['is_premium'] = effectiveIsPremium;
        updateFields['isPro'] = effectiveIsPremium;
        updateFields['pro'] = effectiveIsPremium;
      }

      await userDocRef.set(updateFields, SetOptions(merge: true));

      return effectiveIsPremium;
    } catch (e) {
      debugPrint('[FirebaseAuthService] syncUserProfile notice: $e');
      return PreferencesService.instance.isProUser(uid: user.uid);
    }
  }

  @override
  Future<void> requestAccountDeletion(String uid) async {
    try {
      final firestore = _firestore ?? (_isFirebaseReady ? FirebaseFirestore.instance : null);
      if (firestore != null) {
        final nowUtc = DateTime.now().toUtc();
        final scheduledAt = nowUtc.add(const Duration(days: 15));
        await firestore.collection('users').doc(uid).set({
          'deletionStatus': 'pending_deletion',
          'deletionRequestedAt': nowUtc.toIso8601String(),
          'scheduledPermanentDeletionAt': scheduledAt.toIso8601String(),
          'updatedAt': nowUtc.toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[FirebaseAuthService] requestAccountDeletion error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateLastActive(String uid) async {
    try {
      if (!_isFirebaseReady && _firestore == null) return;
      final firestore = _firestore ?? FirebaseFirestore.instance;
      await firestore.collection('users').doc(uid).set({
        'lastActiveAt': DateTime.now().toIso8601String(),
        'lastInactivityWarningAt': null,
        'inactivityWarningCount': 0,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> recordSessionDuration(String uid, int seconds) async {
    try {
      if (!_isFirebaseReady && _firestore == null) return;
      final firestore = _firestore ?? FirebaseFirestore.instance;
      await firestore.collection('users').doc(uid).set({
        'totalSessionSeconds': FieldValue.increment(seconds),
        'sessionCount': FieldValue.increment(1),
        'lastSessionSeconds': seconds,
        'lastActiveAt': DateTime.now().toIso8601String(),
        'lastInactivityWarningAt': null,
        'inactivityWarningCount': 0,
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}

/// Global provider for [AuthService]
final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService();
});
