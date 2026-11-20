import 'package:flutter/material.dart';

/// Centralized 8-point mathematical spacing system for PackBuddy.
/// Standardizes padding, margins, gaps, and content insets across all platforms.
class AppSpacing {
  AppSpacing._();

  /// 2.0 pt - Micro hairline gap, badge inner spacing
  static const double xxs = 2.0;

  /// 4.0 pt - Tight gap between label and sublabel
  static const double xs = 4.0;

  /// 8.0 pt - Standard small gap between icons and text, chip insets
  static const double sm = 8.0;

  /// 12.0 pt - Compact card inner padding, row/column element spacing
  static const double md = 12.0;

  /// 16.0 pt - Primary component padding, standard card padding
  static const double lg = 16.0;

  /// 20.0 pt - Screen horizontal gutters, spacious section separators
  static const double xl = 20.0;

  /// 24.0 pt - Major component gaps, bottom sheet top insets
  static const double xxl = 24.0;

  /// 32.0 pt - Section vertical rhythm, header spacing
  static const double xxxl = 32.0;

  /// 48.0 pt - Empty state hero spacing, major layout breaks
  static const double huge = 48.0;

  // --- Pre-composed Inset Standards ---

  /// Standard screen edge padding (with generous bottom floating clearance for navigation bar)
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(20, 16, 20, 110);

  /// Compact screen edge padding
  static const EdgeInsets screenPaddingCompact = EdgeInsets.fromLTRB(16, 12, 16, 96);

  /// Standard primary card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  /// Dense card inner padding (list tiles, item rows)
  static const EdgeInsets cardPaddingDense = EdgeInsets.symmetric(horizontal: 14, vertical: 12);

  /// Modal bottom sheet standard insets
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(20, 10, 20, 32);

  /// Dialog standard content padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(20);

  /// Primary button internal padding (ensures >=44pt hit box)
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);

  /// Compact / Pill button internal padding
  static const EdgeInsets buttonPaddingCompact = EdgeInsets.symmetric(horizontal: 14, vertical: 9);

  /// Chip & Badge internal padding
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);

  /// Input field content padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 18, vertical: 15);
}
