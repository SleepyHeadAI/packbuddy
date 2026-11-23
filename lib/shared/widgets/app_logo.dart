import 'package:flutter/material.dart';

/// PackBuddy brand mark (P + compass needle) on a transparent background.
///
/// The variant follows the ambient theme brightness: the off-white mark on
/// dark surfaces, the terracotta mark on light ones.
class AppLogo extends StatelessWidget {
  /// Off-white P + amber needle, for dark surfaces.
  static const String forDarkAsset = 'assets/images/logo_transparent_for_dark.png';

  /// Terracotta P + amber needle, for light surfaces.
  static const String forLightAsset = 'assets/images/logo_transparent_for_light.png';

  /// Explicit width & height if square
  final double? size;

  /// Custom width
  final double? width;

  /// Custom height
  final double? height;

  /// Image box fit (defaults to [BoxFit.contain])
  final BoxFit fit;

  /// Optional Hero tag for fluid page transitions
  final String? heroTag;

  const AppLogo({
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.heroTag,
  });

  /// Same as [AppLogo]; every brand mark is transparent now. Kept so existing
  /// call sites stay unchanged.
  const AppLogo.transparent({
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget imageWidget = Image.asset(
      theme.brightness == Brightness.dark ? forDarkAsset : forLightAsset,
      width: width ?? size,
      height: height ?? size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Safe fallback in headless test environments
        final iconSize = (size ?? width ?? height ?? 40) * 0.65;
        return Icon(
          Icons.luggage_rounded,
          size: iconSize,
          color: theme.colorScheme.primary,
        );
      },
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: imageWidget);
    }
    return imageWidget;
  }
}
