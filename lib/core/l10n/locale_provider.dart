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

