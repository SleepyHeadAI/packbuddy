import 'package:flutter/material.dart';

/// Tactile, bouncy spring feedback wrapper inspired by modern Apple and Linear interfaces.
/// When pressed, gently scales down with smooth cubic damping and springs back dynamically.
class BouncyPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final Duration duration;
  final BorderRadius? borderRadius;
  final HitTestBehavior behavior;

  const BouncyPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.97,
    this.duration = const Duration(milliseconds: 140),
    this.borderRadius,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BouncyPressable> createState() => _BouncyPressableState();
}

class _BouncyPressableState extends State<BouncyPressable>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;

  bool get _hasCallback => widget.onTap != null || widget.onLongPress != null;

  @override
  void initState() {
    super.initState();
    if (_hasCallback) {
      _initController();
    }
  }

  void _initController() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void didUpdateWidget(BouncyPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasCallback && _controller == null) {
      _initController();
    } else if (!_hasCallback && _controller != null) {
      _controller?.dispose();
      _controller = null;
      _scaleAnimation = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_hasCallback) {
      _controller?.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_hasCallback) {
      _controller?.reverse();
    }
  }

  void _onTapCancel() {
    if (_hasCallback) {
      _controller?.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCallback || _scaleAnimation == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation!.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
