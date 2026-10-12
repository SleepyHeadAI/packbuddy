import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';

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
    }
  }
}

/// Provider exposing current ThemeMode for dynamic UI switching
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

