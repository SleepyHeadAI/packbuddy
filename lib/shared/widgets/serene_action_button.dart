import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'bouncy_pressable.dart';

enum SereneActionVariant {
  gold,
  teal,
  slate,
  destructive,
  periwinkle,
}

/// Serene Voyage Circular Action Button
/// Exact replication of the circular action buttons from the Serene Voyage design system:
/// - gold: Deep Olive Ochre (#6B570A)
/// - teal: Deep Pine Teal (#0F766E)
/// - slate: Slate Blue (#50607A)
/// - destructive: Crimson Red (#B91C1C)
/// - periwinkle: Soft Periwinkle Slate (#A4B8D1)
class SereneCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final SereneActionVariant variant;
  final double size;
  final double iconSize;
  final String? tooltip;

  const SereneCircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.variant = SereneActionVariant.gold,
    this.size = 44,
    this.iconSize = 20,
    this.tooltip,
  });

  Color _getBackgroundColor() {
    switch (variant) {
      case SereneActionVariant.gold:
        return AppColors.actionGold;
      case SereneActionVariant.teal:
        return AppColors.actionTeal;
      case SereneActionVariant.slate:
        return AppColors.actionSlate;
      case SereneActionVariant.destructive:
        return AppColors.actionRed;
      case SereneActionVariant.periwinkle:
        return AppColors.actionPeriwinkle;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case SereneActionVariant.periwinkle:
        return const Color(0xFF1E293B);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _getBackgroundColor();
    final fg = _getForegroundColor();

    Widget button = BouncyPressable(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: iconSize,
          color: fg,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    return button;
  }
}

/// Serene Voyage Pill Action Button
/// Exact replication of the warm golden yellow (#E7B623) pill action button with icon and label
class SerenePillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;

  const SerenePillButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primaryAmber;
    final fg = foregroundColor ?? const Color(0xFF281C00);

    return BouncyPressable(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTheme.headlineFont(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

