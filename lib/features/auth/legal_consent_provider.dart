import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/preferences_service.dart';
import 'auth_controller.dart';
import 'auth_service.dart';

/// StateNotifier managing the user's acceptance of mandatory legal consent & data terms.
class LegalConsentNotifier extends StateNotifier<bool> {
  final Ref _ref;

  LegalConsentNotifier(this._ref) : super(false) {
    _init();
    // Listen to auth changes so consent state is re-evaluated for the active user
    _ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.user?.uid != next.user?.uid) {
        refresh();
      }
    });
  }

  void _init() {
    final user = _ref.read(authUserProvider);
    state = PreferencesService.instance.hasAcceptedLegalConsent(uid: user?.uid);
  }

  /// Refreshes consent state when the active user changes
  void refresh() {
    final user = _ref.read(authUserProvider);
    state = PreferencesService.instance.hasAcceptedLegalConsent(uid: user?.uid);
  }

  /// Records legal acceptance locally and syncs to Firestore
  Future<void> acceptConsent({
    String version = PreferencesService.currentLegalConsentVersion,
    bool analyticsConsent = true,
  }) async {
    final user = _ref.read(authUserProvider);
    await PreferencesService.instance.setLegalConsentAccepted(
      true,
      uid: user?.uid,
      version: version,
      analyticsConsent: analyticsConsent,
    );

    if (user != null) {
      try {
        await _ref.read(authServiceProvider).recordLegalConsent(
          uid: user.uid,
          version: version,
          analyticsConsent: analyticsConsent,
        );
      } catch (_) {}
    }

    state = true;
  }

  /// Revokes consent (e.g., when declining or resetting)
  Future<void> revokeConsent() async {
    final user = _ref.read(authUserProvider);
    await PreferencesService.instance.setLegalConsentAccepted(
      false,
      uid: user?.uid,
    );
    state = false;
  }
}

/// Global provider exposing whether mandatory legal consent has been accepted
final StateNotifierProvider<LegalConsentNotifier, bool> legalConsentProvider =
    StateNotifierProvider<LegalConsentNotifier, bool>((ref) {
  return LegalConsentNotifier(ref);
});
