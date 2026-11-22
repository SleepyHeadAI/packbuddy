import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Motion, physics curves, durations, and haptic feedback standards for PackBuddy.
class AppMotion {
  AppMotion._();

  // --- Duration Tokens ---

  /// 100 ms - Instant tap highlights, checkbox toggles
  static const Duration instant = Duration(milliseconds: 100);

  /// 160 ms - Press scaling, quick micro-interactions
  static const Duration fast = Duration(milliseconds: 160);

  /// 240 ms - Card expansion, sheet slide in, smooth fade
  static const Duration normal = Duration(milliseconds: 240);

  /// 360 ms - Modal presentation, screen crossfades
  static const Duration smooth = Duration(milliseconds: 360);

  /// 500 ms - Complex route choreography, progress fills
  static const Duration relaxed = Duration(milliseconds: 500);

  // --- Physics & Easing Curves ---

  /// Spring curve for tactile button press feedback
  static const Curve spring = Curves.easeOutBack;

  /// Deceleration curve for entering elements
  static const Curve enter = Curves.easeOutCubic;

  /// Acceleration curve for exiting elements
  static const Curve exit = Curves.easeInCubic;

  /// Smooth bidirectional cubic curve
  static const Curve smoothCurve = Curves.easeInOutCubic;

  /// Standard gentle curve
  static const Curve gentle = Curves.easeInOut;

  /// Standard UI transition curve
  static const Curve curveStandard = enter;

  // --- Reduced Motion ---

  /// Global reduced-motion override.
  ///
  /// `test/flutter_test_config.dart` enables this so infinitely repeating
  /// ambient animations (pulse, floating illustrations, avatar, skeletons)
  /// never block `pumpAndSettle`. Tests that need real motion can reset it.
  static bool debugForceReducedMotion = false;

  /// Whether ambient / decorative motion should be suppressed: the platform
  /// requests it (Android "Remove animations" →
  /// [MediaQuery.disableAnimationsOf]) or [debugForceReducedMotion] is set.
  static bool reduceMotionOf(BuildContext context) =>
      debugForceReducedMotion ||
      (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  /// [duration] normally, [Duration.zero] when motion should be reduced.
  static Duration durationOf(BuildContext context, Duration duration) =>
      reduceMotionOf(context) ? Duration.zero : duration;
}

/// Tactile haptic feedback triggers tailored for Apple / modern Android feel.
class AppHaptics {
  AppHaptics._();

  /// Subtle click for chips, checkboxes, tab selection
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Alias for selection haptic click
  static void selectionClick() => selection();

  /// Light tactile feedback for standard button tap
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Alias for light haptic feedback
  static void lightImpact() => light();

  /// Medium tactile feedback for swipe completion, archive, bookmark
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Strong impact for deletion, warnings, security unlock
  static void heavy() {
    HapticFeedback.heavyImpact();
  }
}
