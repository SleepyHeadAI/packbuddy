import '../../data/sync_engine/sync_engine.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database_helper.dart';
import '../../core/services/telemetry_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/currency_service.dart';
import 'auth_service.dart';
import '../settings/data/mock_revenuecat_service.dart';
import '../budget/presentation/controllers/trip_controller.dart';
import '../checklist/presentation/controllers/checklist_controller.dart';
import '../vault/presentation/controllers/vault_controller.dart';
import '../admin/user_moderation_provider.dart';

/// State representation for Authentication operations
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;
  final bool wasAccountRestoredFromDeletion;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
    this.wasAccountRestoredFromDeletion = false,
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
    bool? wasAccountRestoredFromDeletion,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized,
      wasAccountRestoredFromDeletion: wasAccountRestoredFromDeletion ?? this.wasAccountRestoredFromDeletion,
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
  final Ref? _ref;
  StreamSubscription<User?>? _authSubscription;

  bool get wasAccountRestoredFromDeletion => state.wasAccountRestoredFromDeletion;

  void acknowledgeAccountRestored() {
    state = state.copyWith(wasAccountRestoredFromDeletion: false);
  }

  AuthController(this._authService, [this._ref])
      : super(AuthState(
          user: _authService.currentUser,
          isInitialized: true,
        )) {
    _init();
  }

  Future<void> _syncProfileAndNotify(User user) async {
    try {
      final isPro = await _authService.syncUserProfile(user);
      _ref?.read(proSubscriptionProvider.notifier).updateProStatus(isPro, uid: user.uid);
      _ref?.read(currencyProvider.notifier).loadForUser(uid: user.uid);

      int? totalStorage;
      try {
        totalStorage = await DatabaseHelper.instance.getTotalVaultStorageBytes(userId: user.uid);
      } catch (_) {}

      unawaited(TelemetryService.instance.identifyUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        isPro: isPro,
        totalStorageBytes: totalStorage,
      ));
    } catch (_) {}
  }

  void _init() {
    _authService.onAccountRestoredFromDeletion = (uid) {
      state = state.copyWith(wasAccountRestoredFromDeletion: true);
      try {
        _ref?.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}
    };
    _authSubscription = _authService.authStateChanges.listen(
      (user) {
        final r = _ref;
        if (user != null) {
          _syncProfileAndNotify(user);
          if (r != null) {
            try {
              r.read(tripControllerProvider.notifier).loadTrips(userId: user.uid);
              r.read(checklistControllerProvider.notifier).loadItems(userId: user.uid);
              r.read(vaultControllerProvider.notifier).loadDocuments(userId: user.uid);
              r.read(currencyProvider.notifier).loadForUser(uid: user.uid);
              r.read(proSubscriptionProvider.notifier).reloadForUser(uid: user.uid);
            } catch (_) {}
          }
        } else {
          // Zero leak on null user
          if (r != null) {
            try {
              r.read(tripControllerProvider.notifier).resetState();
              r.read(checklistControllerProvider.notifier).resetState();
              r.read(vaultControllerProvider.notifier).resetState();
              r.read(proSubscriptionProvider.notifier).resetProStatus();
              r.read(currencyProvider.notifier).resetToDefault();
              r.read(userModerationProvider.notifier).reset();
            } catch (_) {}
          }
        }
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
      if (credential.user != null) {
        _syncProfileAndNotify(credential.user!);
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
      if (credential.user != null) {
        _syncProfileAndNotify(credential.user!);
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
      if (credential.user != null) {
        _syncProfileAndNotify(credential.user!);
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

  /// Interactive Apple Sign In (Feature F-15)
  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await _authService.signInWithApple();
      if (credential == null) {
        // User dismissed Apple ID authorization
        state = state.copyWith(isLoading: false);
        return false;
      }
      if (credential.user != null) {
        _syncProfileAndNotify(credential.user!);
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
      if (updatedUser != null) {
        _syncProfileAndNotify(updatedUser);
      }
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

  /// Requests 15-day grace period account deletion
  Future<bool> requestAccountDeletion() async {
    final user = state.user;
    if (user == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      final r = _ref;
      if (r != null) {
        try {
          await r.read(syncEngineProvider.notifier).performSync();
        } catch (_) {}
      }

      await _authService.requestAccountDeletion(user.uid);

      try {
        await DatabaseHelper.instance.clearAllData();
      } catch (_) {}
      try {
        await PreferencesService.instance.clearDeviceProStatus();
        await PreferencesService.instance.setProUser(false);
      } catch (_) {}

      if (r != null) {
        try {
          r.read(tripControllerProvider.notifier).resetState();
          r.read(checklistControllerProvider.notifier).resetState();
          r.read(vaultControllerProvider.notifier).resetState();
          r.read(proSubscriptionProvider.notifier).resetProStatus();
          r.read(currencyProvider.notifier).resetToDefault();
          r.read(userModerationProvider.notifier).reset();
        } catch (_) {}
      }

      await _authService.signOut();
      state = state.copyWith(
        clearUser: true,
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

  /// Sign out current user
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      unawaited(TelemetryService.instance.resetUser());
      // Ensure previous user's local SQLite data is completely wiped from device before signing out
      try {
        await DatabaseHelper.instance.clearAllData();
      } catch (dbErr) {
        debugPrint('[AuthController] clearAllData notice: $dbErr');
      }

      // Clear device-level Pro status flag
      try {
        await PreferencesService.instance.clearDeviceProStatus();
        await PreferencesService.instance.setProUser(false);
      } catch (_) {}

      // Immediately reset all domain controllers so zero data leaks to the next account
      final r = _ref;
      if (r != null) {
        try {
          r.read(tripControllerProvider.notifier).resetState();
          r.read(checklistControllerProvider.notifier).resetState();
          r.read(vaultControllerProvider.notifier).resetState();
          r.read(proSubscriptionProvider.notifier).resetProStatus();
          r.read(currencyProvider.notifier).resetToDefault();
          r.read(userModerationProvider.notifier).reset();
        } catch (_) {}
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
  return AuthController(service, ref);
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
