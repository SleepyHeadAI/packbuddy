import 'package:flutter/material.dart';

/// Localization helper and supported 20 languages for PackBuddy
class L10n {
  static const List<Locale> all = [
    Locale('tr'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('hi'),
    Locale('ar'),
    Locale('nl'),
    Locale('el'),
    Locale('sv'),
    Locale('pl'),
    Locale('id'),
    Locale('th'),
    Locale('vi'),
  ];

  /// Human-readable native language name for UI pickers
  static String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文 (Chinese)';
      case 'ja':
        return '日本語 (Japanese)';
      case 'ko':
        return '한국어 (Korean)';
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'ar':
        return 'العربية (Arabic)';
      case 'nl':
        return 'Nederlands';
      case 'el':
        return 'Ελληνικά (Greek)';
      case 'sv':
        return 'Svenska';
      case 'pl':
        return 'Polski';
      case 'id':
        return 'Bahasa Indonesia';
      case 'th':
        return 'ไทย (Thai)';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return code.toUpperCase();
    }
  }

  /// Flag emoji or badge label for each language
  static String getLanguageFlag(String code) {
    switch (code) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇬🇧';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇵🇹';
      case 'ru':
        return '🇷🇺';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'hi':
        return '🇮🇳';
      case 'ar':
        return '🇸🇦';
      case 'nl':
        return '🇳🇱';
      case 'el':
        return '🇬🇷';
      case 'sv':
        return '🇸🇪';
      case 'pl':
        return '🇵🇱';
      case 'id':
        return '🇮🇩';
      case 'th':
        return '🇹🇭';
      case 'vi':
        return '🇻🇳';
      default:
        return '🌐';
    }
  }
}
