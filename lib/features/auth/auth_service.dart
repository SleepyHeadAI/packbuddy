import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/currency_service.dart';

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

  /// Authenticate using Apple Sign-In (Feature F-15)
  Future<UserCredential?> signInWithApple();

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
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        unawaited(syncUserProfile(userCredential.user!));
      }
      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      debugPrint('[FirebaseAuthService] Apple Sign-In authorization error: $e');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[FirebaseAuthService] Apple Sign-In exception: $e\n$stackTrace');
      throw FirebaseAuthException(
        code: 'apple-sign-in-failed',
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

      // STRICT MULTI-ACCOUNT ISOLATION (Phase 1):
      // Remote Firestore document is the single source of truth for authenticated users.
      // Brand-new users MUST ALWAYS initialize with isPremium: false.
      // NEVER promote a new or different account from a stale local device flag!
      bool effectiveIsPremium = false;
      if (remoteExists && remoteData != null && remoteData.containsKey('isPremium')) {
        effectiveIsPremium = remoteData['isPremium'] == true;
      } else {
        effectiveIsPremium = false;
      }
      await PreferencesService.instance.setProUser(effectiveIsPremium, uid: user.uid);

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

      final remoteCreatedAt =
          remoteExists && remoteData != null ? remoteData['createdAt'] : null;
      final effectiveCreatedAt =
          (remoteCreatedAt is String && remoteCreatedAt.isNotEmpty)
              ? remoteCreatedAt
              : createdAt;

      await userDocRef.set({
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'provider': provider,
        'emailVerified': emailVerified,
        'createdAt': effectiveCreatedAt,
        'lastLoginAt': now,
        'lastActiveAt': now,
        'isPremium': effectiveIsPremium,
        'countryCode': countryCode,
        'countryName': countryName,
        'currencyCode': currencyCode,
        'banStatus': banStatus,
        'banExpiresAt': banExpiresAt,
        'banReason': banReason,
        'restrictedFeatures': restrictedFeatures,
      }, SetOptions(merge: true));

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
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}

/// Global provider for [AuthService]
final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService();
});
