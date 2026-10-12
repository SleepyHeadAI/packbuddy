import 'package:flutter/material.dart';

/// Sophisticated, cinematic card container with soft diffusion shadow and smooth tactile feedback
class AppCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardRadius = BorderRadius.circular(borderRadius);

    final cardBorder = border != null
        ? Border.fromBorderSide(border!)
        : Border.all(
            color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.6 : 0.7),
            width: 1,
          );

    final shadows = customShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ];

    Widget body = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? theme.cardTheme.color) : null,
        gradient: gradient,
        borderRadius: cardRadius,
        border: cardBorder,
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: cardRadius,
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: cardRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
            highlightColor: theme.colorScheme.primary.withValues(alpha: 0.04),
            child: body,
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
