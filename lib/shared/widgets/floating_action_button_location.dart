import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A [FloatingActionButtonLocation] that positions the floating action button
/// elevated above the floating glass bottom navigation bar of [MainShellScaffold].
///
/// Automatically accounts for:
/// - Screen height, width, and orientations across phone, foldable, and tablet form factors.
/// - System bottom inset / gesture navigation bar ([minViewPadding.bottom] and [minInsets.bottom]).
/// - Software keyboard appearance via [contentBottom], smoothly elevating the FAB.
/// - Right-To-Left (RTL) vs Left-To-Right (LTR) text direction (mirrors horizontally).
/// - Exact horizontal alignment matching the 16dp horizontal margin of the floating bar.
/// - [minBottomOffset]: Guarantees a minimum clearance above the floating bar on all devices
///   even if the platform reports zero insets due to [extendBody: true].
class FloatingActionButtonAboveFloatingBarLocation extends StandardFabLocation
    with FabEndOffsetX, FabFloatOffsetY {
  const FloatingActionButtonAboveFloatingBarLocation({
    this.bottomBarHeight = 64.0,
    this.gap = 12.0,
    this.minBottomOffset = 96.0,
  });

  /// Height of the floating glass navigation bar plus container padding (66 + 12 = 78, plus buffer for shadows).
  final double bottomBarHeight;

  /// Vertical gap between the bottom edge of the FAB and the top edge of the floating bar.
  final double gap;

  /// Minimum absolute distance from the bottom of the screen to the bottom of the FAB.
  final double minBottomOffset;

  @override
  double getOffsetY(ScaffoldPrelayoutGeometry scaffoldGeometry, double adjustment) {
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;

    // When extendBody is true, the outer Scaffold strips padding.bottom on the body to 0.
    // minViewPadding.bottom retains the true physical system safe area (gesture pill / home indicator).
    final double safeAreaBottom = math.max(
      scaffoldGeometry.minInsets.bottom,
      scaffoldGeometry.minViewPadding.bottom,
    );

    // Resting limit above the floating glass bar
    final double calculatedOffset = bottomBarHeight + safeAreaBottom + gap;
    final double restingOffset = math.max(minBottomOffset, calculatedOffset);

    // Keyboard / content bottom limit (contentBottom automatically shrinks when keyboard appears)
    final double keyboardLimit = scaffoldGeometry.contentBottom - 16.0;
    final double barLimit = scaffoldGeometry.scaffoldSize.height - restingOffset;

    final double bottomLimit = math.min(barLimit, keyboardLimit);

    return bottomLimit - fabHeight + adjustment;
  }
}

/// Constant instance for convenient usage across tab scaffolds
const FloatingActionButtonLocation kFloatingActionButtonAboveFloatingBar =
    FloatingActionButtonAboveFloatingBarLocation();
