import 'package:flutter/material.dart';

/// Localization helper and supported language configurations for PackBuddy
class L10n {
  static const List<Locale> all = [
    Locale('tr'),
    Locale('en'),
  ];

  /// Human-readable language name for UI pickers
  static String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'zh':
        return '中文';
      case 'ar':
        return 'العربية';
      default:
        return code.toUpperCase();
    }
  }
}
