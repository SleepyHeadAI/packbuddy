import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/preferences_service.dart';
import '../auth/auth_controller.dart';

/// Moderation state of current authenticated user
class UserModerationState {
  final String banStatus; // 'none' | 'temporary' | 'permanent'
  final String? banExpiresAt; // ISO-8601 string
  final String? banReason;
  final List<String> restrictedFeatures;

  const UserModerationState({
    this.banStatus = 'none',
    this.banExpiresAt,
    this.banReason,
    this.restrictedFeatures = const [],
  });

  bool get isCurrentlyBanned {
    if (banStatus == 'permanent') return true;
    if (banStatus == 'temporary' && banExpiresAt != null) {
      try {
        final expiry = DateTime.parse(banExpiresAt!);
        return expiry.isAfter(DateTime.now());
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  bool isFeatureRestricted(String featureKey) {
    return restrictedFeatures.contains(featureKey);
  }

  UserModerationState copyWith({
    String? banStatus,
    String? banExpiresAt,
    String? banReason,
    List<String>? restrictedFeatures,
    bool clearBanExpiresAt = false,
    bool clearBanReason = false,
  }) {
    return UserModerationState(
      banStatus: banStatus ?? this.banStatus,
      banExpiresAt: clearBanExpiresAt ? null : (banExpiresAt ?? this.banExpiresAt),
      banReason: clearBanReason ? null : (banReason ?? this.banReason),
      restrictedFeatures: restrictedFeatures ?? this.restrictedFeatures,
    );
  }
}

class UserModerationNotifier extends StateNotifier<UserModerationState> {
  final PreferencesService _prefs;
  final FirebaseFirestore? firestore;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  UserModerationNotifier({
    PreferencesService? prefs,
    this.firestore,
  })  : _prefs = prefs ?? PreferencesService.instance,
        super(UserModerationState(
          banStatus: (prefs ?? PreferencesService.instance).getBanStatus(),
          banExpiresAt: (prefs ?? PreferencesService.instance).getBanExpiresAt(),
          banReason: (prefs ?? PreferencesService.instance).getBanReason(),
          restrictedFeatures: (prefs ?? PreferencesService.instance).getRestrictedFeatures(),
        ));

  void listenToUser(String uid) {
    _sub?.cancel();
    state = UserModerationState(
      banStatus: _prefs.getBanStatus(uid: uid),
      banExpiresAt: _prefs.getBanExpiresAt(uid: uid),
      banReason: _prefs.getBanReason(uid: uid),
      restrictedFeatures: _prefs.getRestrictedFeatures(uid: uid),
    );

    bool isFirebaseReady = false;
    try {
      isFirebaseReady = Firebase.apps.isNotEmpty;
    } catch (_) {}
    if (!isFirebaseReady && firestore == null) return;
    final effectiveDb = firestore ?? FirebaseFirestore.instance;

    _sub = effectiveDb.collection('users').doc(uid).snapshots().listen(
      (snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return;
        final data = snapshot.data()!;

        final banStatus = (data['banStatus'] as String?) ?? 'none';
        final banExpiresAt = data['banExpiresAt'] as String?;
        final banReason = data['banReason'] as String?;
        final features = (data['restrictedFeatures'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[];

        _prefs.setBanStatus(banStatus, uid: uid);
        _prefs.setBanExpiresAt(banExpiresAt, uid: uid);
        _prefs.setBanReason(banReason, uid: uid);
        _prefs.setRestrictedFeatures(features, uid: uid);

        state = UserModerationState(
          banStatus: banStatus,
          banExpiresAt: banExpiresAt,
          banReason: banReason,
          restrictedFeatures: features,
        );
      },
      onError: (err) {
        debugPrint('[UserModerationNotifier] snapshot error: $err');
      },
    );
  }

  void reset() {
    _sub?.cancel();
    _sub = null;
    state = const UserModerationState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final userModerationProvider =
    StateNotifierProvider<UserModerationNotifier, UserModerationState>((ref) {
  final notifier = UserModerationNotifier();
  ref.listen<User?>(authUserProvider, (prev, next) {
    if (next != null) {
      notifier.listenToUser(next.uid);
    } else {
      notifier.reset();
    }
  });
  final currentUser = ref.read(authUserProvider);
  if (currentUser != null) {
    notifier.listenToUser(currentUser.uid);
  }
  return notifier;
});
