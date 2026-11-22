import 'package:flutter/material.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';

/// Serene Voyage travel status badge with subtle border, optional rotation, and crisp typography
class StatusBadge extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final BorderSide? border;
  final double? maxWidth;
  final bool isSpinning;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final bool useMono;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.border,
    this.maxWidth = 160,
    this.isSpinning = false,
    this.padding,
    this.fontSize,
    this.useMono = true,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge> with SingleTickerProviderStateMixin {
  AnimationController? _rotationController;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = AppMotion.reduceMotionOf(context);
    _syncRotation();
  }

  @override
  void didUpdateWidget(StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning != oldWidget.isSpinning) {
      _syncRotation();
    }
  }

  /// [SingleTickerProviderStateMixin] allows only one ticker per State, so the
  /// controller is created once and only stopped (never disposed/recreated)
  /// when spinning ends.
  void _syncRotation() {
    final shouldSpin = widget.isSpinning && !_reduceMotion;
    if (shouldSpin) {
      _rotationController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      );
      if (!_rotationController!.isAnimating) {
        _rotationController!.repeat();
      }
    } else {
      _rotationController?.stop();
    }
  }

  @override
  void dispose() {
    _rotationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? iconWidget;
    if (widget.icon != null) {
      final baseIcon = Icon(widget.icon, size: 13, color: widget.textColor);
      if (widget.isSpinning && !_reduceMotion && _rotationController != null) {
        iconWidget = RotationTransition(
          turns: _rotationController!,
          child: baseIcon,
        );
      } else {
        iconWidget = baseIcon;
      }
    }

    return Container(
      constraints: widget.maxWidth != null ? BoxConstraints(maxWidth: widget.maxWidth!) : null,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: widget.border != null
            ? Border.fromBorderSide(widget.border!)
            : Border.all(
                color: widget.textColor.withValues(alpha: 0.18),
                width: 0.8,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconWidget != null) ...[
            iconWidget,
            const SizedBox(width: 4),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: widget.useMono
                    ? AppTheme.labelFont(
                        fontSize: widget.fontSize ?? 10.5,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                        letterSpacing: 0.0,
                      )
                    : AppTheme.bodyFont(
                        fontSize: widget.fontSize ?? 10.5,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                        letterSpacing: 0.1,
                        height: 1.15,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
