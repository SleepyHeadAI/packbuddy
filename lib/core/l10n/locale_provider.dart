import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';
import '../services/telemetry_service.dart';

/// Notifier to switch between languages dynamically across PackBuddy with persistence
class LocaleNotifier extends StateNotifier<Locale> {
  final PreferencesService _prefs;

  LocaleNotifier([PreferencesService? prefs])
      : _prefs = prefs ?? PreferencesService.instance,
        super(prefs?.getLocale() ?? PreferencesService.instance.getLocale() ?? const Locale('tr'));

  void setLocale(Locale locale) {
    if (state != locale) {
      state = locale;
      _prefs.setLocale(locale);
      TelemetryService.instance.logPreferenceChanged(
        setting: 'locale',
        value: locale.languageCode,
      );
      try {
        if (Firebase.apps.isNotEmpty) {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            FirebaseFirestore.instance.collection('users').doc(uid).set({
              'appLanguage': locale.languageCode,
              'preferencesUpdatedAt': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          }
        }
      } catch (_) {}
    }
  }

  void toggleLocale() {
    if (state.languageCode == 'tr') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('tr'));
    }
  }
}

/// Provider exposing the current application locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
