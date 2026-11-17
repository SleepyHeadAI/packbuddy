import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';

/// High-performance canvas-based confetti celebration particle system
/// for 100% checklist completion and travel milestones.
class ChecklistConfettiCelebration extends StatefulWidget {
  final Widget child;
  final ChecklistConfettiController? controller;

  const ChecklistConfettiCelebration({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<ChecklistConfettiCelebration> createState() =>
      _ChecklistConfettiCelebrationState();
}

class ChecklistConfettiController extends ChangeNotifier {
  void burst() {
    notifyListeners();
  }
}

class _ChecklistConfettiCelebrationState
    extends State<ChecklistConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  static const List<Color> _confettiColors = [
    AppColors.primaryAmber,
    AppColors.secondaryLight,
    AppColors.actionTeal,
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Warm Amber
    Color(0xFFF97316), // Sunset Orange
    Color(0xFF38BDF8), // Sky Blue
    Color(0xFFA855F7), // Royal Purple
    Color(0xFFEC4899), // Coral Rose
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _animController.addListener(() {
      if (_particles.isNotEmpty) {
        setState(() {
          for (final p in _particles) {
            p.update();
          }
        });
      }
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _particles.clear();
        });
      }
    });

    widget.controller?.addListener(_triggerBurst);
  }

  @override
  void didUpdateWidget(ChecklistConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_triggerBurst);
      widget.controller?.addListener(_triggerBurst);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_triggerBurst);
    _animController.dispose();
    super.dispose();
  }

  void _triggerBurst() {
    if (!mounted) return;
    _particles.clear();
    final size = MediaQuery.sizeOf(context);
    final originY = size.height * 0.42;
    final originX = size.width * 0.5;

    // Generate 50 festive confetti particles with varying velocities & shapes
    for (int i = 0; i < 50; i++) {
      final angle = -math.pi / 2 + (_random.nextDouble() - 0.5) * 1.6;
      final speed = 8.0 + _random.nextDouble() * 11.0;
      final color = _confettiColors[_random.nextInt(_confettiColors.length)];

      _particles.add(
        _ConfettiParticle(
          x: originX + (_random.nextDouble() - 0.5) * 80,
          y: originY + (_random.nextDouble() - 0.5) * 40,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: color,
          width: 7.0 + _random.nextDouble() * 6.0,
          height: 5.0 + _random.nextDouble() * 5.0,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.28,
          wobbleSpeed: 0.08 + _random.nextDouble() * 0.12,
          wobbleOffset: _random.nextDouble() * 2 * math.pi,
          isCircle: _random.nextBool(),
        ),
      );
    }

    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (_particles.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _animController.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  final Color color;
  final double width;
  final double height;
  double rotation;
  final double rotationSpeed;
  final double wobbleSpeed;
  final double wobbleOffset;
  final bool isCircle;
  double wobble = 0.0;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.width,
    required this.height,
    required this.rotation,
    required this.rotationSpeed,
    required this.wobbleSpeed,
    required this.wobbleOffset,
    required this.isCircle,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.32; // Gravity
    vx *= 0.985; // Air drag
    vy *= 0.985;
    rotation += rotationSpeed;
    wobble += wobbleSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final particleOpacity = (opacity * 1.3).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: particleOpacity);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      // 3D paper flutter effect using cosine scaling
      final scaleX = math.cos(p.wobble + p.wobbleOffset);
      canvas.scale(scaleX, 1.0);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.width * 0.45, paint);
      } else {
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.width,
          height: p.height,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
