import 'package:flutter/material.dart';

/// Sophisticated, executive card container with soft diffusion shadow,
/// subtle 1px border, generous border radius, and bouncy tactile spring feedback on tap.
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderSide? border;
  final double borderRadius;
  final List<BoxShadow>? customShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.borderRadius = 20,
    this.customShadow,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.985).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardRadius = BorderRadius.circular(widget.borderRadius);

    final cardBorder = widget.border != null
        ? Border.fromBorderSide(widget.border!)
        : Border.all(
            color: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFDDE3ED),
            width: 1,
          );

    final shadows = widget.customShadow ??
        [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.30)
                : const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          if (!isDark)
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.015),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
        ];

    Widget body = Container(
      padding: widget.padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.gradient == null
            ? (widget.backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface)
            : null,
        gradient: widget.gradient,
        borderRadius: cardRadius,
        border: cardBorder,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: cardRadius,
            boxShadow: shadows,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: cardRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (highlighted) {
                if (highlighted) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
              splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
              highlightColor: theme.colorScheme.primary.withValues(alpha: 0.04),
              child: body,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        boxShadow: shadows,
      ),
      child: body,
    );
  }
}
