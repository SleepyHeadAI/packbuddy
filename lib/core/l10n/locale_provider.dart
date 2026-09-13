import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier to switch between languages dynamically across PackBuddy
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('tr'));

  void setLocale(Locale locale) {
    if (state != locale) {
      state = locale;
    }
  }

  void toggleLocale() {
    if (state.languageCode == 'tr') {
      state = const Locale('en');
    } else {
      state = const Locale('tr');
    }
  }
}

/// Provider exposing the current application locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
