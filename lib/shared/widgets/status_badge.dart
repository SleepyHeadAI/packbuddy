import 'package:flutter/material.dart';
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
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge> with SingleTickerProviderStateMixin {
  AnimationController? _rotationController;

  @override
  void initState() {
    super.initState();
    if (widget.isSpinning) {
      _startRotation();
    }
  }

  @override
  void didUpdateWidget(StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      _startRotation();
    } else if (!widget.isSpinning && oldWidget.isSpinning) {
      _stopRotation();
    }
  }

  void _startRotation() {
    _rotationController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _rotationController?.repeat();
  }

  void _stopRotation() {
    _rotationController?.stop();
    _rotationController?.dispose();
    _rotationController = null;
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
      if (widget.isSpinning && _rotationController != null) {
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
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: widget.border != null
            ? Border.fromBorderSide(widget.border!)
            : Border.all(
                color: widget.textColor.withValues(alpha: 0.15),
                width: 1,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (iconWidget != null) ...[
            iconWidget,
            const SizedBox(width: 4.5),
          ],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.labelFont(
                fontSize: widget.fontSize ?? 10.5,
                fontWeight: FontWeight.w700,
                color: widget.textColor,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
