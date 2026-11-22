import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/theme/app_radius.dart';

/// Soft "breathing" skeleton placeholder used instead of full-screen spinners.
///
/// A single, cheap opacity animation (no shader / gradient sweep) drives the
/// whole subtree, isolated behind a [RepaintBoundary]. Honours reduced motion
/// via [AppMotion.reduceMotionOf]: the placeholder is then rendered static.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({super.key, required this.child});

  /// Placeholder layout built from [AppSkeletonBox]es.
  final Widget child;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    value: 1.0,
  );
  late final Animation<double> _opacity = Tween<double>(begin: 0.55, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: AppMotion.gentle));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduceMotionOf(context)) {
      _controller.stop();
      _controller.value = 1.0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: FadeTransition(opacity: _opacity, child: widget.child),
        ),
      ),
    );
  }
}

/// A single rounded placeholder block tinted from the surface tokens.
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadius.mdRadius,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceOverlayDark : AppColors.surfaceOverlayLight,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Ready-made skeleton for list / grid screens: a column of card-shaped rows
/// (leading tile + two text lines). Scroll-free, so it never overflows.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({
    super.key,
    this.itemCount = 6,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
    this.showHeader = true,
  });

  final int itemCount;
  final EdgeInsetsGeometry padding;

  /// Adds a wider hero-card placeholder above the rows.
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceBaseDark : AppColors.surfaceBaseLight;
    final borderColor = isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight;

    Widget row() => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: const Row(
            children: [
              AppSkeletonBox(width: 44, height: 44, borderRadius: AppRadius.lgRadius),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.62,
                      child: AppSkeletonBox(height: 12, borderRadius: AppRadius.xsRadius),
                    ),
                    SizedBox(height: 10),
                    FractionallySizedBox(
                      widthFactor: 0.38,
                      child: AppSkeletonBox(height: 10, borderRadius: AppRadius.xsRadius),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    return AppSkeleton(
      child: ClipRect(
        child: Padding(
          padding: padding,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showHeader) ...[
                  const AppSkeletonBox(height: 120, borderRadius: AppRadius.cardRadius),
                  const SizedBox(height: 16),
                ],
                for (var i = 0; i < itemCount; i++) row(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Smooth cross-fade between mutually exclusive screen states
/// (locked → loading → content, empty → filled, filter results).
///
/// Wraps [AnimatedSwitcher] with the [AppMotion] tokens; [stateKey] must change
/// whenever the logical state changes. Collapses to an instant swap when
/// reduced motion is requested.
class AppStateSwitcher extends StatelessWidget {
  const AppStateSwitcher({
    super.key,
    required this.stateKey,
    required this.child,
  });

  final Object stateKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.durationOf(context, AppMotion.normal),
      reverseDuration: AppMotion.durationOf(context, AppMotion.fast),
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        // passthrough: children receive exactly the constraints the switcher got,
        // so wrapping a Scaffold body never changes its layout.
        fit: StackFit.passthrough,
        children: [
          ...previousChildren,
          ?currentChild,
        ],
      ),
      child: KeyedSubtree(key: ValueKey<Object>(stateKey), child: child),
    );
  }
}
