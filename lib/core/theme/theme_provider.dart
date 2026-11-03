import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';
import '../services/telemetry_service.dart';

/// Notifier managing the current ThemeMode (system, light, dark) with SharedPreferences persistence
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final PreferencesService _prefs;

  ThemeModeNotifier([PreferencesService? prefs])
      : _prefs = prefs ?? PreferencesService.instance,
        super(prefs?.getThemeMode() ?? PreferencesService.instance.getThemeMode());

  void setThemeMode(ThemeMode mode) {
    if (state != mode) {
      state = mode;
      _prefs.setThemeMode(mode);
      TelemetryService.instance.logPreferenceChanged(
        setting: 'theme_mode',
        value: mode.name,
      );
      try {
        if (Firebase.apps.isNotEmpty) {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            FirebaseFirestore.instance.collection('users').doc(uid).set({
              'appThemeMode': mode.name,
              'preferencesUpdatedAt': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          }
        }
      } catch (_) {}
    }
  }
}

/// Provider exposing current ThemeMode for dynamic UI switching
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

