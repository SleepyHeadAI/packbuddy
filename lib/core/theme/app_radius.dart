import 'package:flutter/material.dart';

/// Concentric geometric corner radius tokens for PackBuddy.
/// Prevents optical corner distortion when nesting containers:
/// Rule: R_inner = R_outer - Padding.
class AppRadius {
  AppRadius._();

  /// 6.0 pt - Inner tags, micro badges, progress indicators
  static const double xs = 6.0;

  /// 10.0 pt - Chips, nested interactive buttons, inner container slots
  static const double sm = 10.0;

  /// 14.0 pt - Input fields, search bars, nested card panels
  static const double md = 14.0;

  /// 18.0 pt - List tiles, selectable cards, secondary dialogs
  static const double lg = 18.0;

  /// 22.0 pt - Primary app cards, hero containers, floating action buttons
  static const double card = 22.0;

  /// 26.0 pt - Floating navigation bar outer radius
  static const double navBar = 26.0;

  /// 28.0 pt - Bottom sheets, primary modal dialogs
  static const double sheet = 28.0;

  /// 999.0 pt - Fully circular / pill buttons, avatar capsules
  static const double full = 999.0;

  // --- Pre-composed BorderRadius Tokens ---

  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius navBarRadius = BorderRadius.all(Radius.circular(navBar));
  static const BorderRadius sheetRadius = BorderRadius.vertical(top: Radius.circular(sheet));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));
}
