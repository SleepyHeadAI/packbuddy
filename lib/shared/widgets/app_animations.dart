import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
export 'bouncy_pressable.dart';

/// Standard smooth cubic page route transition with subtle slide and fade
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  AppPageRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
        );
}

/// Staggered Fade & Slide-up entrance animation for cards and list items
class AppFadeSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideOffset;
  final Curve curve;

  const AppFadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 360),
    this.slideOffset = 18.0,
    this.curve = Curves.easeOutCubic,
  });

  /// Factory for staggered list or grid items: automatically calculates delay
  factory AppFadeSlide.staggered({
    Key? key,
    required int index,
    required Widget child,
    Duration baseDelay = const Duration(milliseconds: 40),
    Duration duration = const Duration(milliseconds: 360),
    double slideOffset = 18.0,
    Curve curve = Curves.easeOutCubic,
  }) {
    return AppFadeSlide(
      key: key,
      delay: baseDelay * index,
      duration: duration,
      slideOffset: slideOffset,
      curve: curve,
      child: child,
    );
  }

  @override
  State<AppFadeSlide> createState() => _AppFadeSlideState();
}

class _AppFadeSlideState extends State<AppFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  var _isAnimationCompleted = false;
  var _hasStarted = false;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_isAnimationCompleted) {
        setState(() {
          _isAnimationCompleted = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;

    if (AppMotion.reduceMotionOf(context)) {
      // Reduced motion: show the final frame immediately, no ticker, no timer.
      _isAnimationCompleted = true;
      _controller.value = 1.0;
    } else if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 120 FPS Optimization: Once the entrance transition completes, eliminate all Layer & Transition overhead
    if (_isAnimationCompleted) {
      return widget.child;
    }

    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: _slideAnimation.value,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Subtle pulse animation for highlighted badges, live sync or PRO tags
class AppPulse extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;
  final bool autoRepeat;

  const AppPulse({
    super.key,
    required this.child,
    this.minScale = 0.96,
    this.maxScale = 1.04,
    this.duration = const Duration(milliseconds: 1400),
    this.autoRepeat = true,
  });

  @override
  State<AppPulse> createState() => _AppPulseState();
}

class _AppPulseState extends State<AppPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduceMotionOf(context)) {
      // Reduced motion: rest at neutral scale (midpoint of the symmetric curve).
      _controller.stop();
      _controller.value = 0.5;
    } else if (widget.autoRepeat) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Smooth Animated Progress Bar with gradient and cubic transition
class AppAnimatedProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;
  final Gradient? gradient;
  final BorderRadius borderRadius;
  final Duration duration;

  const AppAnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 7.0,
    required this.backgroundColor,
    required this.foregroundColor,
    this.gradient,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final targetWidth = constraints.maxWidth * clamped;
          return Stack(
            children: [
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                width: targetWidth,
                height: height,
                decoration: BoxDecoration(
                  color: gradient == null ? foregroundColor : null,
                  gradient: gradient,
                  borderRadius: borderRadius,
                  boxShadow: clamped > 0.05
                      ? [
                          BoxShadow(
                            color: foregroundColor.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Smooth animated strikethrough text supporting multi-line, RTL/LTR,
/// dark/light themes, and custom line styles.
class AnimatedStrikethroughText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isCrossed;
  final int maxLines;
  final TextOverflow overflow;
  final Duration duration;
  final Color? strikethroughColor;
  final double strokeWidth;
  final double crossedOpacity;

  const AnimatedStrikethroughText({
    super.key,
    required this.text,
    this.style,
    required this.isCrossed,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
    this.duration = const Duration(milliseconds: 280),
    this.strikethroughColor,
    this.strokeWidth = 1.8,
    this.crossedOpacity = 0.45,
  });

  @override
  State<AnimatedStrikethroughText> createState() => _AnimatedStrikethroughTextState();
}

class _AnimatedStrikethroughTextState extends State<AnimatedStrikethroughText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.isCrossed ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedStrikethroughText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCrossed != oldWidget.isCrossed) {
      final reduceMotion = AppMotion.reduceMotionOf(context);
      if (reduceMotion) {
        _controller.value = widget.isCrossed ? 1.0 : 0.0;
      } else {
        if (widget.isCrossed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      }
    }
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
    final defaultLineColor = widget.strikethroughColor ??
        (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
    final effectiveStyle = widget.style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final direction = Directionality.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final currentOpacity = 1.0 - (progress * (1.0 - widget.crossedOpacity));

        return Opacity(
          opacity: currentOpacity.clamp(0.0, 1.0),
          child: CustomPaint(
            foregroundPainter: _StrikethroughCustomPainter(
              progress: progress,
              text: widget.text,
              style: effectiveStyle,
              direction: direction,
              maxLines: widget.maxLines,
              lineColor: defaultLineColor,
              strokeWidth: widget.strokeWidth,
            ),
            child: Text(
              widget.text,
              maxLines: widget.maxLines,
              overflow: widget.overflow,
              style: effectiveStyle.copyWith(
                decoration: TextDecoration.none,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StrikethroughCustomPainter extends CustomPainter {
  final double progress;
  final String text;
  final TextStyle style;
  final TextDirection direction;
  final int maxLines;
  final Color lineColor;
  final double strokeWidth;

  _StrikethroughCustomPainter({
    required this.progress,
    required this.text,
    required this.style,
    required this.direction,
    required this.maxLines,
    required this.lineColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001 || size.width <= 0 || size.height <= 0) return;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      maxLines: maxLines,
    )..layout(maxWidth: size.width);

    final lineMetrics = textPainter.computeLineMetrics();
    if (lineMetrics.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final isRtl = direction == TextDirection.rtl;
    final totalLines = lineMetrics.length;

    for (int i = 0; i < totalLines; i++) {
      final metric = lineMetrics[i];
      final lineStart = i / totalLines;
      final lineEnd = (i + 1) / totalLines;
      if (progress < lineStart) continue;

      final lineFraction = ((progress - lineStart) / (lineEnd - lineStart)).clamp(0.0, 1.0);
      if (lineFraction <= 0.0) continue;

      final y = metric.baseline - (metric.ascent * 0.32);
      final drawWidth = metric.width * lineFraction;

      if (!isRtl) {
        canvas.drawLine(
          Offset(metric.left, y),
          Offset(metric.left + drawWidth, y),
          paint,
        );
      } else {
        final startX = size.width - metric.left;
        canvas.drawLine(
          Offset(startX, y),
          Offset(startX - drawWidth, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StrikethroughCustomPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.text != text ||
        oldDelegate.style != style;
  }
}

/// Smooth animated number and currency counter with easing curves.
/// Respects all currencies, locale formatting, RTL/LTR, and text styles.
class AnimatedCurrencyCounter extends StatelessWidget {
  final double value;
  final String currency;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String? prefix;
  final String? suffix;

  const AnimatedCurrencyCounter({
    super.key,
    required this.value,
    required this.currency,
    this.style,
    this.duration = const Duration(milliseconds: 650),
    this.curve = Curves.easeOutCubic,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reduceMotionOf(context);

    return TweenAnimationBuilder<double>(
      key: ValueKey('currency_anim_${currency}_$value'),
      tween: Tween<double>(begin: reduceMotion ? value : 0.0, end: value),
      duration: reduceMotion ? Duration.zero : duration,
      curve: curve,
      builder: (context, animatedVal, _) {
        final formatted = CurrencyFormatter.format(animatedVal, currency: currency);
        final fullText = '${prefix ?? ''}$formatted${suffix ?? ''}';
        return Text(
          fullText,
          style: style,
        );
      },
    );
  }
}

/// Tactile shake animation with physics-damped oscillation.
/// Perfect for PIN validation errors, locked content access, or form error alerts.
class AppShakeTransition extends StatefulWidget {
  final Widget child;
  final bool shake;
  final double offset;
  final Duration duration;
  final VoidCallback? onAnimationComplete;

  const AppShakeTransition({
    super.key,
    required this.child,
    required this.shake,
    this.offset = 10.0,
    this.duration = const Duration(milliseconds: 420),
    this.onAnimationComplete,
  });

  @override
  State<AppShakeTransition> createState() => _AppShakeTransitionState();
}

class _AppShakeTransitionState extends State<AppShakeTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        widget.onAnimationComplete?.call();
      }
    });

    if (widget.shake) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant AppShakeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        if (progress == 0.0) return child!;
        // Damped sine wave oscillation: 3 gentle cycles decaying to 0
        final translation = widget.offset *
            math.sin(progress * math.pi * 6) *
            (1.0 - progress);
        return Transform.translate(
          offset: Offset(translation, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Elegant floating/bobbing ambient animation with subtle breathing scale.
/// Transforms empty states and hero icons into premium, living components.
class AppFloatingIllustration extends StatefulWidget {
  final Widget child;
  final double floatDistance;
  final Duration duration;
  final bool enableScale;

  const AppFloatingIllustration({
    super.key,
    required this.child,
    this.floatDistance = 6.0,
    this.duration = const Duration(milliseconds: 2400),
    this.enableScale = true,
  });

  @override
  State<AppFloatingIllustration> createState() => _AppFloatingIllustrationState();
}

class _AppFloatingIllustrationState extends State<AppFloatingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _translateAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _translateAnimation = Tween<double>(
      begin: -widget.floatDistance,
      end: widget.floatDistance,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduceMotionOf(context)) {
      // Reduced motion: hold the illustration at its neutral resting pose.
      _controller.stop();
      _controller.value = 0.5;
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final dy = _translateAnimation.value;
          final scale = widget.enableScale ? _scaleAnimation.value : 1.0;
          return Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
