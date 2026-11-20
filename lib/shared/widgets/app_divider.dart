import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Ultra-subtle 0.5px / 1px hairline divider for modern layered surfaces.
/// Eliminates harsh borders and card-inside-card clutter.
class AppDivider extends StatelessWidget {
  final double thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  const AppDivider({
    super.key,
    this.thickness = 0.8,
    this.indent,
    this.endIndent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = color ?? (isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight);

    return Divider(
      height: thickness,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: dividerColor,
    );
  }
}
