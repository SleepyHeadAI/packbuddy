import 'package:flutter/material.dart';

/// PackBuddy official branded logo widget.
///
/// Features two variants:
/// - [AppLogo.normal]: The vintage brand logo with the warm cream background (#F8F0DF),
///   ideal for standalone display, app launcher representation, and clean cards.
/// - [AppLogo.transparent]: The transparent logo without background color,
///   essential when overlaid on colored surfaces, dark mode scaffolds, or headers.
class AppLogo extends StatelessWidget {
  /// Asset path to the normal vintage-styled logo with cream background
  static const String normalAsset = 'assets/images/logo_normal.png';

  /// Asset path to the transparent emblem logo
  static const String transparentAsset = 'assets/images/logo_transparent.png';

  /// Explicit width & height if square
  final double? size;

  /// Custom width
  final double? width;

  /// Custom height
  final double? height;

  /// Explicitly choose transparent variant if true, normal if false.
  /// If null, automatically resolves to transparent on dark themes or colored contexts.
  final bool? isTransparent;

  /// Image box fit (defaults to [BoxFit.contain])
  final BoxFit fit;

  /// Optional Hero tag for fluid page transitions
  final String? heroTag;

  const AppLogo({
    super.key,
    this.size,
    this.width,
    this.height,
    this.isTransparent,
    this.fit = BoxFit.contain,
    this.heroTag,
  });

  /// Explicitly use the normal logo (cream background)
  const AppLogo.normal({
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.heroTag,
  }) : isTransparent = false;

  /// Explicitly use the transparent logo (blends into any background color)
  const AppLogo.transparent({
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.heroTag,
  }) : isTransparent = true;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    // If transparent is not explicitly specified, use transparent on dark mode
    // or when background color is present.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useTransparent = isTransparent ?? isDark;

    final assetPath = useTransparent ? transparentAsset : normalAsset;

    Widget imageWidget = Image.asset(
      assetPath,
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Safe fallback in headless test environments
        final iconSize = (size ?? width ?? height ?? 40) * 0.65;
        return Icon(
          Icons.luggage_rounded,
          size: iconSize,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

