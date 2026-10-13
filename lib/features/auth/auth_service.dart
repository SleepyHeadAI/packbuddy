import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/services/preferences_service.dart';

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
}

/// Firebase implementation of [AuthService]
class FirebaseAuthService implements AuthService {
  FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore? _firestore;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
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

      // Automatically dispatch email verification
      try {
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
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
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
        return PreferencesService.instance.isProUser();
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
      final localIsPro = PreferencesService.instance.isProUser();

      bool effectiveIsPremium = false;
      if (remoteExists && remoteData != null && remoteData['isPremium'] == true) {
        // Remote is true (e.g. granted by Admin): preserve true and unlock locally
        effectiveIsPremium = true;
        await PreferencesService.instance.setProUser(true);
      } else if (localIsPro) {
        // Local has Pro (e.g. user bought subscription locally): write true to remote
        effectiveIsPremium = true;
      } else {
        // Neither remote nor local is Pro (first time creation or non-pro user)
        effectiveIsPremium = false;
      }

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
        'isPremium': effectiveIsPremium,
      }, SetOptions(merge: true));

      return effectiveIsPremium;
    } catch (e) {
      debugPrint('[FirebaseAuthService] syncUserProfile notice: $e');
      return PreferencesService.instance.isProUser();
    }
  }
}

/// Global provider for [AuthService]
final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService();
});
