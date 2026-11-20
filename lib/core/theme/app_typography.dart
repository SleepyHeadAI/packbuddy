import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Typographic Architecture for PackBuddy.
///
/// Hierarchy Rules:
/// - Headlines, Displays & Section Titles: Figtree (Geometric, warm, contemporary)
/// - Interface, Body Text, Subtitles, Buttons: Noto Sans (Exhaustive 20-language Unicode coverage)
/// - Numbers, Currency, Codes, Badges, Metrics: JetBrains Mono with [FontFeature.tabularFigures()]
///
/// Offline-First Safety:
/// In offline scenarios or automated tests, system fonts in [kFontFallbacks] gracefully render
/// all 20 supported languages (Arabic, CJK, Cyrillic, Greek, Hindi, Thai, Vietnamese, etc.)
/// without network loader crashes or layout shifts.
class AppTypography {
  AppTypography._();

  static bool get _isTesting {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// System fallback chain covering all 20 supported locales
  static const List<String> kFontFallbacks = [
    'Roboto',
    'Noto Sans',
    'Noto Sans Arabic',
    'Noto Sans SC',
    'Noto Sans JP',
    'Noto Sans KR',
    'Noto Sans Thai',
    'Noto Sans Devanagari',
    'PingFang SC',
    'Hiragino Sans',
    'Geeza Pro',
    'Thonburi',
    'Kohinoor Devanagari',
    'Segoe UI',
    'Apple Color Emoji',
  ];

  /// Headline & Display Font (Figtree)
  static TextStyle title({
    required double fontSize,
    required FontWeight fontWeight,
    double letterSpacing = 0.0,
    double? height,
    Color? color,
  }) {
    if (_isTesting) {
      return TextStyle(
        fontFamily: 'Figtree',
        fontFamilyFallback: kFontFallbacks,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
    return GoogleFonts.figtree(
      textStyle: const TextStyle(fontFamilyFallback: kFontFallbacks),
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  /// Body & Interface Font (Noto Sans)
  static TextStyle body({
    required double fontSize,
    required FontWeight fontWeight,
    double letterSpacing = 0.0,
    double? height,
    Color? color,
  }) {
    if (_isTesting) {
      return TextStyle(
        fontFamily: 'Noto Sans',
        fontFamilyFallback: kFontFallbacks,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
    return GoogleFonts.notoSans(
      textStyle: const TextStyle(fontFamilyFallback: kFontFallbacks),
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  /// Technical, Badge & Numeric Tabular Font (JetBrains Mono)
  static TextStyle mono({
    required double fontSize,
    required FontWeight fontWeight,
    double letterSpacing = 0.0,
    double? height,
    Color? color,
    bool tabularFigures = true,
  }) {
    final features = tabularFigures ? [const FontFeature.tabularFigures()] : <FontFeature>[];
    if (_isTesting) {
      return TextStyle(
        fontFamily: 'JetBrains Mono',
        fontFamilyFallback: kFontFallbacks,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
        fontFeatures: features,
      );
    }
    return GoogleFonts.jetBrainsMono(
      textStyle: TextStyle(
        fontFamilyFallback: kFontFallbacks,
        fontFeatures: features,
      ),
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }

  // --- Standard Semantic Presets ---

  /// Headline medium for section headers, card titles
  static TextStyle get titleLarge => title(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3);

  /// Title medium for bottom sheets, modal headers, list headers
  static TextStyle get titleMedium => title(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2);

  /// Title small for subtitles, card subheaders
  static TextStyle get titleSmall => title(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: -0.1);

  /// Body large for long-form reading
  static TextStyle get bodyLarge => body(fontSize: 16, fontWeight: FontWeight.w400);

  /// Body medium for standard interface text
  static TextStyle get bodyMedium => body(fontSize: 14, fontWeight: FontWeight.w400);

  /// Body small for secondary text, metadata
  static TextStyle get bodySmall => body(fontSize: 12, fontWeight: FontWeight.w400);

  /// Caption for micro labels, timestamps, tags
  static TextStyle get caption => body(fontSize: 11, fontWeight: FontWeight.w400);

  /// Label large for action buttons, sheet rows
  static TextStyle get labelLarge => body(fontSize: 14, fontWeight: FontWeight.w600);

  /// Label small for navigation items, micro badges
  static TextStyle get labelSmall => body(fontSize: 10, fontWeight: FontWeight.w500);
}
