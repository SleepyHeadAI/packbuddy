import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database_helper.dart';
import 'auth_service.dart';

/// State representation for Authentication operations
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  bool get isAuthenticated => user != null;

  /// Whether current authenticated user has completed email verification
  bool get isEmailVerified => user?.emailVerified ?? false;

  /// Whether the user signed in using email & password
  bool get isPasswordProvider {
    if (user == null) return false;
    if (user!.providerData.isEmpty) return true;
    return user!.providerData.any((p) => p.providerId == 'password');
  }

  /// Whether the user is gated by the Email Verification Wall
  bool get requiresEmailVerification {
    if (user == null) return false;
    return !isEmailVerified && isPasswordProvider;
  }

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          user?.uid == other.user?.uid &&
          user?.emailVerified == other.user?.emailVerified &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage &&
          isInitialized == other.isInitialized;

  @override
  int get hashCode => Object.hash(
        user?.uid,
        user?.emailVerified,
        isLoading,
        errorMessage,
        isInitialized,
      );
}

/// Riverpod StateNotifier controlling authentication lifecycle
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AuthController(this._authService)
      : super(AuthState(
          user: _authService.currentUser,
          isInitialized: true,
        )) {
    _init();
  }

  void _init() {
    _authSubscription = _authService.authStateChanges.listen(
      (user) {
        state = state.copyWith(
          user: user,
          clearUser: user == null,
          isLoading: false,
          clearError: true,
          isInitialized: true,
        );
      },
      onError: (err) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _formatAuthError(err),
          isInitialized: true,
        );
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(
        user: credential.user,
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatAuthError(e),
      );
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(
        user: credential.user,
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatAuthError(e),
      );
      return false;
    }
  }

  /// Interactive Google Sign In
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        // User dismissed the account picker
        state = state.copyWith(isLoading: false);
        return false;
      }
      state = state.copyWith(
        user: credential.user,
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatAuthError(e),
      );
      return false;
    }
  }

  /// Reload current user from Firebase to check if email was verified
  Future<bool> reloadUser() async {
    try {
      final updatedUser = await _authService.reloadUser();
      state = state.copyWith(
        user: updatedUser,
        clearUser: updatedUser == null,
        clearError: true,
      );
      return updatedUser?.emailVerified ?? false;
    } catch (e) {
      debugPrint('[AuthController] reloadUser error: $e');
      return false;
    }
  }

  /// Send or resend email verification link
  Future<bool> sendEmailVerification() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.sendEmailVerification();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatAuthError(e),
      );
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      // Ensure previous user's local SQLite data is completely wiped from device before signing out
      try {
        await DatabaseHelper.instance.clearAllData();
      } catch (dbErr) {
        debugPrint('[AuthController] clearAllData notice: $dbErr');
      }
      await _authService.signOut();
      state = state.copyWith(
        clearUser: true,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatAuthError(e),
      );
    }
  }

  /// Clear any active error banner
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Formats technical authentication errors to standardized error code keys
  /// for decoupled UI-level localization via AppLocalizations.
  static String _formatAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      return error.code;
    }
    if (error is String) {
      return error;
    }
    return 'generic';
  }
}

/// Global Riverpod controller provider for Auth
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthController(service);
});

/// Direct reactive user provider
final authUserProvider = Provider<User?>((ref) {
  return ref.watch(authControllerProvider.select((state) => state.user));
});

/// Direct reactive email verification status provider
final isEmailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider.select((state) => state.isEmailVerified));
});

/// Convenience provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authUserProvider) != null;
});

/// Convenience provider for email verification requirement gate
final requiresEmailVerificationProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider.select((state) => state.requiresEmailVerification));
});
