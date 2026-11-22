import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/features/profile/domain/animal_avatar.dart';

/// Serene Voyage Animated Animal Avatar Widget
/// Renders an exquisitely detailed, cute animated vector face for all 20 animals
/// with expressive blinking, playful winking, sweet smiling, and blushing micro-animations.
class AnimalAvatarWidget extends StatefulWidget {
  final AnimalAvatar avatar;
  final double size;
  final bool isAnimated;
  final VoidCallback? onTap;

  const AnimalAvatarWidget({
    super.key,
    required this.avatar,
    this.size = 80,
    this.isAnimated = true,
    this.onTap,
  });

  @override
  State<AnimalAvatarWidget> createState() => _AnimalAvatarWidgetState();
}

class _AnimalAvatarWidgetState extends State<AnimalAvatarWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  double _scale = 1.0;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = AppMotion.reduceMotionOf(context);
    _syncController();
  }

  @override
  void didUpdateWidget(covariant AnimalAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated != oldWidget.isAnimated) {
      _syncController();
    }
  }

  /// Single controller for the State's lifetime (SingleTickerProviderStateMixin):
  /// created lazily, stopped — never recreated — when animation is off.
  void _syncController() {
    if (widget.isAnimated && !_reduceMotion) {
      _controller ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3600),
      );
      if (!_controller!.isAnimating) {
        _controller!.repeat();
      }
    } else {
      _controller?.stop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: widget.avatar.bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.avatar.accentColor.withValues(alpha: 0.22),
            blurRadius: size * 0.18,
            offset: Offset(0, size * 0.06),
          ),
        ],
      ),
      child: ClipOval(
        // Isolate the continuously repainting face so the 3.6 s loop never
        // invalidates surrounding layout/paint (profile header, lists, cards).
        child: _controller != null
            ? RepaintBoundary(child: AnimatedBuilder(
                animation: _controller!,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(size, size),
                    painter: AnimalFacePainter(
                      avatarId: widget.avatar.id,
                      accentColor: widget.avatar.accentColor,
                      progress: _controller!.value,
                    ),
                  );
                },
              ))
            : CustomPaint(
                size: Size(size, size),
                painter: AnimalFacePainter(
                  avatarId: widget.avatar.id,
                  accentColor: widget.avatar.accentColor,
                  progress: 0.0,
                ),
              ),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.94),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          widget.onTap!();
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// CustomPainter rendering distinctive, cute facial features for all 20 animals
class AnimalFacePainter extends CustomPainter {
  final String avatarId;
  final Color accentColor;
  final double progress; // 0.0 to 1.0

  AnimalFacePainter({
    required this.avatarId,
    required this.accentColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Subtle breathing / vertical bobbing motion + soft joyful head tilt
    final bob = math.sin(progress * 2 * math.pi) * (h * 0.016);
    final adjustedCenter = Offset(center.dx, center.dy + bob);

    // 2. Sweet Smile & Blush Factor (Phase between 0.50 and 0.86)
    double smileFactor = 0.0;
    if (progress >= 0.50 && progress <= 0.86) {
      final p = (progress - 0.50) / 0.36;
      smileFactor = math.sin(p * math.pi).clamp(0.0, 1.0);
    }
    final blushFactor = smileFactor;

    // 3. Eye animations: Natural double-blink and Playful sweet wink!
    // Natural blink between 0.16 and 0.26
    double naturalBlink = 0.0;
    if (progress >= 0.16 && progress <= 0.26) {
      final p = (progress - 0.16) / 0.10;
      naturalBlink = math.sin(p * math.pi).clamp(0.0, 1.0);
    }

    // Playful wink between 0.62 and 0.78 (right eye winks playfully while smiling!)
    double wink = 0.0;
    if (progress >= 0.62 && progress <= 0.78) {
      final p = (progress - 0.62) / 0.16;
      wink = math.sin(p * math.pi).clamp(0.0, 1.0);
    }

    // Left eye closes during natural blink, stays open and bright during wink
    final leftEyeOpen = (1.0 - naturalBlink).clamp(0.0, 1.0);
    // Right eye closes during natural blink AND during playful wink
    final rightEyeOpen = (1.0 - math.max(naturalBlink, wink)).clamp(0.0, 1.0);

    // 4. Ear wiggle (playful alternating twitch between 0.30 and 0.50)
    double leftWiggle = 0.0;
    double rightWiggle = 0.0;
    if (progress >= 0.30 && progress <= 0.40) {
      final p = (progress - 0.30) / 0.10;
      leftWiggle = math.sin(p * math.pi * 3) * 0.09;
    } else if (progress >= 0.40 && progress <= 0.50) {
      final p = (progress - 0.40) / 0.10;
      rightWiggle = math.sin(p * math.pi * 3) * 0.09;
    }

    // Soft ear perk during sweet smile
    leftWiggle += smileFactor * 0.02;
    rightWiggle -= smileFactor * 0.02;

    // 5. Sparkles & Floating Sweet Heart
    final sparkle1Phase = (progress * 2) % 1.0;
    final sparkle1Scale = (math.sin(sparkle1Phase * math.pi)).clamp(0.0, 1.0);
    _drawSparkle(canvas, Offset(w * 0.82, h * 0.18), w * 0.075 * sparkle1Scale);

    final sparkle2Phase = ((progress + 0.5) * 2) % 1.0;
    final sparkle2Scale = (math.sin(sparkle2Phase * math.pi)).clamp(0.0, 1.0);
    _drawSparkle(canvas, Offset(w * 0.18, h * 0.22), w * 0.05 * sparkle2Scale);

    // Floating heart when smiling & winking
    if (progress >= 0.56 && progress <= 0.82) {
      final p = (progress - 0.56) / 0.26;
      final heartAlpha = math.sin(p * math.pi).clamp(0.0, 1.0);
      final floatY = p * (h * 0.16);
      _drawMiniHeart(
        canvas,
        Offset(w * 0.76, h * 0.34 - floatY),
        w * 0.075,
        heartAlpha,
      );
    }

    // Draw the specific animal with all enhanced animation parameters
    switch (avatarId) {
      case 'animal_cat':
        _drawCat(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_dog':
        _drawDog(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_panda':
        _drawPanda(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_fox':
        _drawFox(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_bunny':
        _drawBunny(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_koala':
        _drawKoala(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_bear':
        _drawBear(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_lion':
        _drawLion(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_tiger':
        _drawTiger(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_penguin':
        _drawPenguin(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_hamster':
        _drawHamster(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_frog':
        _drawFrog(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_owl':
        _drawOwl(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_duck':
        _drawDuck(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_monkey':
        _drawMonkey(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_deer':
        _drawDeer(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_hedgehog':
        _drawHedgehog(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_otter':
        _drawOtter(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_sloth':
        _drawSloth(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      case 'animal_dolphin':
        _drawDolphin(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
      default:
        _drawCat(canvas, size, adjustedCenter, leftEyeOpen, rightEyeOpen, smileFactor, blushFactor, leftWiggle, rightWiggle);
        break;
    }
  }

  // =========================================================================
  // HELPER DRAWING PRIMITIVES
  // =========================================================================

  void _drawSparkle(Canvas canvas, Offset pos, double radius) {
    if (radius <= 0.5) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(pos.dx, pos.dy - radius);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx + radius, pos.dy);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy + radius);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx - radius, pos.dy);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy - radius);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawMiniHeart(Canvas canvas, Offset c, double size, double alpha) {
    if (alpha <= 0.05 || size <= 0.5) return;
    final paint = Paint()
      ..color = const Color(0xFFFF4081).withValues(alpha: alpha * 0.88)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(c.dx, c.dy + size * 0.6);
    path.cubicTo(
      c.dx - size * 0.9, c.dy,
      c.dx - size * 0.9, c.dy - size * 0.7,
      c.dx, c.dy - size * 0.3,
    );
    path.cubicTo(
      c.dx + size * 0.9, c.dy - size * 0.7,
      c.dx + size * 0.9, c.dy,
      c.dx, c.dy + size * 0.6,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawBlushingCheeks(
    Canvas canvas,
    Offset left,
    Offset right,
    double r, {
    double blushFactor = 0.0,
  }) {
    final alpha = (0.38 + blushFactor * 0.30).clamp(0.0, 0.78);
    final scale = 1.0 + blushFactor * 0.25;
    final blushPaint = Paint()
      ..color = const Color(0xFFFF4081).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: left, width: r * 2.2 * scale, height: r * 1.3 * scale),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: right, width: r * 2.2 * scale, height: r * 1.3 * scale),
      blushPaint,
    );

    // Cute anime blushing hatch lines (//) when blushing happily
    if (blushFactor > 0.45) {
      final linePaint = Paint()
        ..color = const Color(0xFFFF1744).withValues(alpha: ((blushFactor - 0.45) / 0.55).clamp(0.0, 0.85))
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.16
        ..strokeCap = StrokeCap.round;

      // Left cheek lines
      canvas.drawLine(
        Offset(left.dx - r * 0.4, left.dy + r * 0.32),
        Offset(left.dx - r * 0.15, left.dy - r * 0.32),
        linePaint,
      );
      canvas.drawLine(
        Offset(left.dx + r * 0.1, left.dy + r * 0.32),
        Offset(left.dx + r * 0.35, left.dy - r * 0.32),
        linePaint,
      );

      // Right cheek lines
      canvas.drawLine(
        Offset(right.dx - r * 0.35, right.dy + r * 0.32),
        Offset(right.dx - r * 0.1, right.dy - r * 0.32),
        linePaint,
      );
      canvas.drawLine(
        Offset(right.dx + r * 0.15, right.dy + r * 0.32),
        Offset(right.dx + r * 0.4, right.dy - r * 0.32),
        linePaint,
      );
    }
  }

  void _drawEyes(
    Canvas canvas,
    Offset leftEye,
    Offset rightEye,
    double r,
    double leftOpen,
    double rightOpen, {
    double smileFactor = 0.0,
  }) {
    _drawSingleEye(canvas, leftEye, r, leftOpen, isLeft: true, smileFactor: smileFactor);
    _drawSingleEye(canvas, rightEye, r, rightOpen, isLeft: false, smileFactor: smileFactor);
  }

  void _drawSingleEye(
    Canvas canvas,
    Offset eye,
    double r,
    double openFactor, {
    required bool isLeft,
    double smileFactor = 0.0,
  }) {
    if (openFactor > 0.22) {
      final eyePaint = Paint()..color = const Color(0xFF212121);
      final shinePaint = Paint()..color = Colors.white;

      final h = r * (0.2 + 0.8 * openFactor);
      final w = r * (1.6 + 0.1 * smileFactor);

      canvas.save();
      canvas.translate(eye.dx, eye.dy);
      final eyeRect = Rect.fromCenter(center: Offset.zero, width: w, height: h * 2.0);
      canvas.drawOval(eyeRect, eyePaint);

      // Highlights / Shines
      if (openFactor > 0.55) {
        // Main shine reflection
        canvas.drawCircle(Offset(-r * 0.32, -h * 0.35), r * 0.46, shinePaint);
        // Secondary reflection
        canvas.drawCircle(Offset(r * 0.32, h * 0.25), r * 0.22, shinePaint);

        // Extra twinkle highlight if smiling or enthusiastic!
        if (smileFactor > 0.35) {
          canvas.drawCircle(Offset(-r * 0.1, h * 0.32), r * 0.16, shinePaint);
        }
      }
      canvas.restore();
    } else {
      // Sweet smiling closed/winking eye: ^ curve (arched upwards like ⌒)
      final linePaint = Paint()
        ..color = const Color(0xFF212121)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.36
        ..strokeCap = StrokeCap.round;

      final arcWidth = r * 0.82;
      final arcHeight = r * (0.50 + smileFactor * 0.15);

      final path = Path();
      path.moveTo(eye.dx - arcWidth, eye.dy + arcHeight * 0.25);
      path.quadraticBezierTo(eye.dx, eye.dy - arcHeight, eye.dx + arcWidth, eye.dy + arcHeight * 0.25);
      canvas.drawPath(path, linePaint);

      // Cute little eyelash flick on the outer edge
      final lashPaint = Paint()
        ..color = const Color(0xFF212121)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.26
        ..strokeCap = StrokeCap.round;

      if (isLeft) {
        canvas.drawLine(
          Offset(eye.dx - arcWidth * 0.85, eye.dy + arcHeight * 0.15),
          Offset(eye.dx - arcWidth * 1.25, eye.dy - arcHeight * 0.35),
          lashPaint,
        );
      } else {
        canvas.drawLine(
          Offset(eye.dx + arcWidth * 0.85, eye.dy + arcHeight * 0.15),
          Offset(eye.dx + arcWidth * 1.25, eye.dy - arcHeight * 0.35),
          lashPaint,
        );
      }
    }
  }

  void _drawCuteMouth(
    Canvas canvas,
    Offset center,
    double width, {
    bool open = false,
    double smileFactor = 0.0,
  }) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * (0.12 + smileFactor * 0.02)
      ..strokeCap = StrokeCap.round;

    final cornerLift = width * 0.18 * smileFactor;
    final curveDepth = width * (0.35 + smileFactor * 0.25);
    final spread = width * (0.70 + smileFactor * 0.12);

    final path = Path();
    // Left half curve
    path.moveTo(center.dx - spread, center.dy - cornerLift);
    path.quadraticBezierTo(
      center.dx - spread * 0.48,
      center.dy + curveDepth,
      center.dx,
      center.dy + width * 0.08 * smileFactor,
    );
    // Right half curve
    path.quadraticBezierTo(
      center.dx + spread * 0.48,
      center.dy + curveDepth,
      center.dx + spread,
      center.dy - cornerLift,
    );
    canvas.drawPath(path, mouthPaint);

    // Cute open mouth / peeking tongue when smiling or when open == true
    final shouldShowTongue = open || smileFactor > 0.42;
    if (shouldShowTongue) {
      final tFactor = open ? (0.7 + smileFactor * 0.3) : ((smileFactor - 0.42) / 0.58).clamp(0.0, 1.0);
      final tonguePaint = Paint()
        ..color = const Color(0xFFFF5252)
        ..style = PaintingStyle.fill;

      final tongueW = width * (0.40 + 0.20 * tFactor);
      final tongueH = width * (0.42 + 0.36 * tFactor);

      final tonguePath = Path();
      tonguePath.moveTo(center.dx - tongueW * 0.5, center.dy + curveDepth * 0.38);
      tonguePath.quadraticBezierTo(
        center.dx,
        center.dy + curveDepth * 0.38 + tongueH,
        center.dx + tongueW * 0.5,
        center.dy + curveDepth * 0.38,
      );
      tonguePath.close();
      canvas.drawPath(tonguePath, tonguePaint);
    }
  }

  // =========================================================================
  // 1. CAT (animal_cat)
  // =========================================================================
  void _drawCat(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Ears
    final earPaint = Paint()..color = const Color(0xFFFFF9FA);
    final earInner = Paint()..color = const Color(0xFFFFB2C6);

    // Left Ear
    canvas.save();
    canvas.translate(c.dx - r * 0.65, c.dy - r * 0.65);
    canvas.rotate(-0.15 + leftWiggle);
    final leftEarPath = Path()
      ..moveTo(-r * 0.35, r * 0.3)
      ..lineTo(0, -r * 0.6)
      ..lineTo(r * 0.35, r * 0.3)
      ..close();
    canvas.drawPath(leftEarPath, earPaint);
    final leftEarInner = Path()
      ..moveTo(-r * 0.2, r * 0.25)
      ..lineTo(0, -r * 0.45)
      ..lineTo(r * 0.2, r * 0.25)
      ..close();
    canvas.drawPath(leftEarInner, earInner);
    canvas.restore();

    // Right Ear
    canvas.save();
    canvas.translate(c.dx + r * 0.65, c.dy - r * 0.65);
    canvas.rotate(0.15 + rightWiggle);
    final rightEarPath = Path()
      ..moveTo(-r * 0.35, r * 0.3)
      ..lineTo(0, -r * 0.6)
      ..lineTo(r * 0.35, r * 0.3)
      ..close();
    canvas.drawPath(rightEarPath, earPaint);
    final rightEarInner = Path()
      ..moveTo(-r * 0.2, r * 0.25)
      ..lineTo(0, -r * 0.45)
      ..lineTo(r * 0.2, r * 0.25)
      ..close();
    canvas.drawPath(rightEarInner, earInner);
    canvas.restore();

    // Head
    final headPaint = Paint()..color = const Color(0xFFFFFDFC);
    canvas.drawCircle(c, r, headPaint);

    // Whiskers with subtle animated twitch when smiling
    final whiskerTwitch = smile * (r * 0.05);
    final whiskerPaint = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = r * 0.04
      ..strokeCap = StrokeCap.round;

    // Left whiskers
    canvas.drawLine(
      Offset(c.dx - r * 0.45, c.dy + r * 0.15),
      Offset(c.dx - r * 1.05, c.dy + r * 0.05 - whiskerTwitch),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(c.dx - r * 0.45, c.dy + r * 0.3),
      Offset(c.dx - r * 1.05, c.dy + r * 0.35 + whiskerTwitch * 0.5),
      whiskerPaint,
    );

    // Right whiskers
    canvas.drawLine(
      Offset(c.dx + r * 0.45, c.dy + r * 0.15),
      Offset(c.dx + r * 1.05, c.dy + r * 0.05 - whiskerTwitch),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(c.dx + r * 0.45, c.dy + r * 0.3),
      Offset(c.dx + r * 1.05, c.dy + r * 0.35 + whiskerTwitch * 0.5),
      whiskerPaint,
    );

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.55, c.dy + r * 0.25),
      Offset(c.dx + r * 0.55, c.dy + r * 0.25),
      r * 0.22,
      blushFactor: blush,
    );

    // Eyes with blink and wink
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.38, c.dy - r * 0.05),
      Offset(c.dx + r * 0.38, c.dy - r * 0.05),
      r * 0.18,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Nose
    final nosePaint = Paint()..color = const Color(0xFFFF4081);
    final nosePath = Path()
      ..moveTo(c.dx - r * 0.12, c.dy + r * 0.12)
      ..lineTo(c.dx + r * 0.12, c.dy + r * 0.12)
      ..lineTo(c.dx, c.dy + r * 0.24)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // Sweet animated mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.26), r * 0.28, smileFactor: smile);
  }

  // =========================================================================
  // 2. DOG / PUPPY (animal_dog)
  // =========================================================================
  void _drawDog(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Floppy ears
    final earPaint = Paint()..color = const Color(0xFFC78235);
    // Left floppy ear
    canvas.save();
    canvas.translate(c.dx - r * 0.75, c.dy - r * 0.2);
    canvas.rotate(-0.25 + leftWiggle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.6, height: r * 1.1), earPaint);
    canvas.restore();

    // Right floppy ear
    canvas.save();
    canvas.translate(c.dx + r * 0.75, c.dy - r * 0.2);
    canvas.rotate(0.25 + rightWiggle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.6, height: r * 1.1), earPaint);
    canvas.restore();

    // Head
    final headPaint = Paint()..color = const Color(0xFFF7D199);
    canvas.drawCircle(c, r, headPaint);

    // White Muzzle patch
    final muzzlePaint = Paint()..color = Colors.white;
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.28), width: r * 1.05, height: r * 0.75), muzzlePaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.55, c.dy + r * 0.2),
      Offset(c.dx + r * 0.55, c.dy + r * 0.2),
      r * 0.2,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.38, c.dy - r * 0.08),
      Offset(c.dx + r * 0.38, c.dy - r * 0.08),
      r * 0.18,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Big black nose
    final nosePaint = Paint()..color = const Color(0xFF262626);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.16), width: r * 0.38, height: r * 0.26), nosePaint);

    // Mouth with cheerful pink tongue and smile
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.32), r * 0.32, open: true, smileFactor: smile);
  }

  // =========================================================================
  // 3. PANDA (animal_panda)
  // =========================================================================
  void _drawPanda(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Dark round ears with playful bounce
    final earPaint = Paint()..color = const Color(0xFF2D3136);
    canvas.drawCircle(Offset(c.dx - r * 0.72 + leftWiggle * r * 0.25, c.dy - r * 0.68), r * 0.36, earPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.72 + rightWiggle * r * 0.25, c.dy - r * 0.68), r * 0.36, earPaint);

    // Head
    final headPaint = Paint()..color = Colors.white;
    canvas.drawCircle(c, r, headPaint);

    // Dark tilted eye patches
    canvas.save();
    canvas.translate(c.dx - r * 0.38, c.dy - r * 0.06);
    canvas.rotate(0.25);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.44, height: r * 0.6), earPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(c.dx + r * 0.38, c.dy - r * 0.06);
    canvas.rotate(-0.25);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.44, height: r * 0.6), earPaint);
    canvas.restore();

    // Eyes inside patches
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.36, c.dy - r * 0.06),
      Offset(c.dx + r * 0.36, c.dy - r * 0.06),
      r * 0.16,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.58, c.dy + r * 0.28),
      Offset(c.dx + r * 0.58, c.dy + r * 0.28),
      r * 0.22,
      blushFactor: blush,
    );

    // Nose
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.2), width: r * 0.28, height: r * 0.18), earPaint);

    // Mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.34), r * 0.26, smileFactor: smile);
  }

  // =========================================================================
  // 4. FOX (animal_fox)
  // =========================================================================
  void _drawFox(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Ears
    final earOuter = Paint()..color = const Color(0xFFE65100);
    final earInner = Paint()..color = Colors.white;

    // Left Ear
    canvas.save();
    canvas.translate(c.dx - r * 0.62, c.dy - r * 0.65);
    canvas.rotate(-0.2 + leftWiggle);
    final lPath = Path()
      ..moveTo(-r * 0.35, r * 0.3)
      ..lineTo(0, -r * 0.75)
      ..lineTo(r * 0.35, r * 0.3)
      ..close();
    canvas.drawPath(lPath, earOuter);
    final lIn = Path()
      ..moveTo(-r * 0.18, r * 0.25)
      ..lineTo(0, -r * 0.52)
      ..lineTo(r * 0.18, r * 0.25)
      ..close();
    canvas.drawPath(lIn, earInner);
    canvas.restore();

    // Right Ear
    canvas.save();
    canvas.translate(c.dx + r * 0.62, c.dy - r * 0.65);
    canvas.rotate(0.2 + rightWiggle);
    final rPath = Path()
      ..moveTo(-r * 0.35, r * 0.3)
      ..lineTo(0, -r * 0.75)
      ..lineTo(r * 0.35, r * 0.3)
      ..close();
    canvas.drawPath(rPath, earOuter);
    final rIn = Path()
      ..moveTo(-r * 0.18, r * 0.25)
      ..lineTo(0, -r * 0.52)
      ..lineTo(r * 0.18, r * 0.25)
      ..close();
    canvas.drawPath(rIn, earInner);
    canvas.restore();

    // Orange Head
    final headPaint = Paint()..color = const Color(0xFFFF7043);
    canvas.drawCircle(c, r, headPaint);

    // White Cheek Tufts & muzzle
    final whitePaint = Paint()..color = Colors.white;
    final cheekPath = Path()
      ..moveTo(c.dx, c.dy + r * 0.1)
      ..quadraticBezierTo(c.dx - r * 0.6, c.dy, c.dx - r * 0.95, c.dy + r * 0.35)
      ..quadraticBezierTo(c.dx - r * 0.5, c.dy + r * 0.9, c.dx, c.dy + r * 0.95)
      ..quadraticBezierTo(c.dx + r * 0.5, c.dy + r * 0.9, c.dx + r * 0.95, c.dy + r * 0.35)
      ..quadraticBezierTo(c.dx + r * 0.6, c.dy, c.dx, c.dy + r * 0.1)
      ..close();
    canvas.drawPath(cheekPath, whitePaint);

    // Blushing
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.52, c.dy + r * 0.4),
      Offset(c.dx + r * 0.52, c.dy + r * 0.4),
      r * 0.18,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.36, c.dy),
      Offset(c.dx + r * 0.36, c.dy),
      r * 0.18,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Cute Dark Nose
    final nosePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.38), width: r * 0.26, height: r * 0.18), nosePaint);

    // Mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.52), r * 0.24, smileFactor: smile);
  }

  // =========================================================================
  // 5. BUNNY (animal_bunny)
  // =========================================================================
  void _drawBunny(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Tall Bunny Ears
    final earPaint = Paint()..color = const Color(0xFFFFF9FB);
    final earInner = Paint()..color = const Color(0xFFFFB2C6);

    // Left Ear
    canvas.save();
    canvas.translate(c.dx - r * 0.38, c.dy - r * 0.7);
    canvas.rotate(-0.12 + leftWiggle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.38, height: r * 1.3), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.2, height: r * 0.95), earInner);
    canvas.restore();

    // Right Ear
    canvas.save();
    canvas.translate(c.dx + r * 0.38, c.dy - r * 0.7);
    canvas.rotate(0.12 + rightWiggle);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.38, height: r * 1.3), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.2, height: r * 0.95), earInner);
    canvas.restore();

    // Head
    canvas.drawCircle(c, r, earPaint);

    // Rosy Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.55, c.dy + r * 0.22),
      Offset(c.dx + r * 0.55, c.dy + r * 0.22),
      r * 0.24,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.38, c.dy - r * 0.05),
      Offset(c.dx + r * 0.38, c.dy - r * 0.05),
      r * 0.18,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Tiny pink heart nose
    final nosePaint = Paint()..color = const Color(0xFFFF4081);
    canvas.drawCircle(Offset(c.dx, c.dy + r * 0.16), r * 0.09, nosePaint);

    // Cute mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.28), r * 0.26, smileFactor: smile);
  }

  // =========================================================================
  // 6. KOALA (animal_koala)
  // =========================================================================
  void _drawKoala(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Big fluffy ears
    final earPaint = Paint()..color = const Color(0xFFB0BEC5);
    final earTuft = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(c.dx - r * 0.82 + leftWiggle * r * 0.2, c.dy - r * 0.45), r * 0.45, earPaint);
    canvas.drawCircle(Offset(c.dx - r * 0.82 + leftWiggle * r * 0.2, c.dy - r * 0.45), r * 0.25, earTuft);

    canvas.drawCircle(Offset(c.dx + r * 0.82 + rightWiggle * r * 0.2, c.dy - r * 0.45), r * 0.45, earPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.82 + rightWiggle * r * 0.2, c.dy - r * 0.45), r * 0.25, earTuft);

    // Head
    canvas.drawCircle(c, r, earPaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.55, c.dy + r * 0.25),
      Offset(c.dx + r * 0.55, c.dy + r * 0.25),
      r * 0.2,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.42, c.dy - r * 0.05),
      Offset(c.dx + r * 0.42, c.dy - r * 0.05),
      r * 0.16,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Iconic Big Koala Nose
    final nosePaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.15), width: r * 0.46, height: r * 0.65), nosePaint);

    // Sleepy gentle mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.52), r * 0.22, smileFactor: smile);
  }

  // =========================================================================
  // 7. BEAR (animal_bear)
  // =========================================================================
  void _drawBear(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Round bear ears
    final earPaint = Paint()..color = const Color(0xFF8D6E63);
    final earInner = Paint()..color = const Color(0xFFD7CCC8);
    canvas.drawCircle(Offset(c.dx - r * 0.7 + leftWiggle * r * 0.2, c.dy - r * 0.65), r * 0.32, earPaint);
    canvas.drawCircle(Offset(c.dx - r * 0.7 + leftWiggle * r * 0.2, c.dy - r * 0.65), r * 0.18, earInner);

    canvas.drawCircle(Offset(c.dx + r * 0.7 + rightWiggle * r * 0.2, c.dy - r * 0.65), r * 0.32, earPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.7 + rightWiggle * r * 0.2, c.dy - r * 0.65), r * 0.18, earInner);

    // Head
    canvas.drawCircle(c, r, earPaint);

    // Light Cream Muzzle
    final muzzlePaint = Paint()..color = const Color(0xFFFFF8E1);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.28), width: r * 0.9, height: r * 0.65), muzzlePaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.58, c.dy + r * 0.2),
      Offset(c.dx + r * 0.58, c.dy + r * 0.2),
      r * 0.2,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.38, c.dy - r * 0.08),
      Offset(c.dx + r * 0.38, c.dy - r * 0.08),
      r * 0.17,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Brown nose
    final nosePaint = Paint()..color = const Color(0xFF4E342E);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.18), width: r * 0.32, height: r * 0.2), nosePaint);

    // Mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.34), r * 0.28, smileFactor: smile);
  }

  // =========================================================================
  // 8. LION (animal_lion)
  // =========================================================================
  void _drawLion(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.31;

    // Fluffy Mane Ring
    final manePaint = Paint()..color = const Color(0xFFFFA726);
    for (int i = 0; i < 12; i++) {
      final angle = (i * 2 * math.pi) / 12;
      final maneOffset = Offset(c.dx + math.cos(angle) * (r * 1.05), c.dy + math.sin(angle) * (r * 1.05));
      canvas.drawCircle(maneOffset, r * 0.38, manePaint);
    }

    // Round ears
    final earPaint = Paint()..color = const Color(0xFFFFD54F);
    final earInner = Paint()..color = const Color(0xFFFFB74D);
    canvas.drawCircle(Offset(c.dx - r * 0.68 + leftWiggle * r * 0.2, c.dy - r * 0.6), r * 0.28, earPaint);
    canvas.drawCircle(Offset(c.dx - r * 0.68 + leftWiggle * r * 0.2, c.dy - r * 0.6), r * 0.16, earInner);
    canvas.drawCircle(Offset(c.dx + r * 0.68 + rightWiggle * r * 0.2, c.dy - r * 0.6), r * 0.28, earPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.68 + rightWiggle * r * 0.2, c.dy - r * 0.6), r * 0.16, earInner);

    // Head
    canvas.drawCircle(c, r, earPaint);

    // Muzzle
    final muzzlePaint = Paint()..color = const Color(0xFFFFFDE7);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.3), width: r * 0.85, height: r * 0.6), muzzlePaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.52, c.dy + r * 0.25),
      Offset(c.dx + r * 0.52, c.dy + r * 0.25),
      r * 0.18,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.36, c.dy - r * 0.05),
      Offset(c.dx + r * 0.36, c.dy - r * 0.05),
      r * 0.17,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Brown triangle nose
    final nosePaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.2), width: r * 0.26, height: r * 0.18), nosePaint);

    // Mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.35), r * 0.26, smileFactor: smile);
  }

  // =========================================================================
  // 9. TIGER (animal_tiger)
  // =========================================================================
  void _drawTiger(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Ears
    final earPaint = Paint()..color = const Color(0xFFFF9800);
    final earInner = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(c.dx - r * 0.7 + leftWiggle * r * 0.2, c.dy - r * 0.6), r * 0.3, earPaint);
    canvas.drawCircle(Offset(c.dx - r * 0.7 + leftWiggle * r * 0.2, c.dy - r * 0.6), r * 0.16, earInner);
    canvas.drawCircle(Offset(c.dx + r * 0.7 + rightWiggle * r * 0.2, c.dy - r * 0.6), r * 0.3, earPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.7 + rightWiggle * r * 0.2, c.dy - r * 0.6), r * 0.16, earInner);

    // Head
    canvas.drawCircle(c, r, earPaint);

    // Tiger Stripes
    final stripePaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round;

    // Forehead stripes
    canvas.drawLine(Offset(c.dx, c.dy - r * 0.85), Offset(c.dx, c.dy - r * 0.45), stripePaint);
    canvas.drawLine(Offset(c.dx - r * 0.2, c.dy - r * 0.7), Offset(c.dx - r * 0.08, c.dy - r * 0.5), stripePaint);
    canvas.drawLine(Offset(c.dx + r * 0.2, c.dy - r * 0.7), Offset(c.dx + r * 0.08, c.dy - r * 0.5), stripePaint);

    // Cheek stripes
    canvas.drawLine(Offset(c.dx - r * 0.9, c.dy), Offset(c.dx - r * 0.65, c.dy + r * 0.05), stripePaint);
    canvas.drawLine(Offset(c.dx + r * 0.9, c.dy), Offset(c.dx + r * 0.65, c.dy + r * 0.05), stripePaint);

    // White Muzzle
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.3), width: r * 0.9, height: r * 0.6), whitePaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.52, c.dy + r * 0.25),
      Offset(c.dx + r * 0.52, c.dy + r * 0.25),
      r * 0.18,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.38, c.dy - r * 0.05),
      Offset(c.dx + r * 0.38, c.dy - r * 0.05),
      r * 0.18,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Pink Nose
    final nosePaint = Paint()..color = const Color(0xFFE91E63);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.2), width: r * 0.24, height: r * 0.16), nosePaint);

    // Mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.34), r * 0.26, smileFactor: smile);
  }

  // =========================================================================
  // 10. PENGUIN (animal_penguin)
  // =========================================================================
  void _drawPenguin(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.34;

    // Black Head
    final blackPaint = Paint()..color = const Color(0xFF263238);
    canvas.drawCircle(c, r, blackPaint);

    // White Heart Belly / Face Mask
    final whitePaint = Paint()..color = Colors.white;
    final facePath = Path()
      ..moveTo(c.dx, c.dy - r * 0.3)
      ..quadraticBezierTo(c.dx - r * 0.55, c.dy - r * 0.6, c.dx - r * 0.7, c.dy)
      ..quadraticBezierTo(c.dx - r * 0.75, c.dy + r * 0.7, c.dx, c.dy + r * 0.9)
      ..quadraticBezierTo(c.dx + r * 0.75, c.dy + r * 0.7, c.dx + r * 0.7, c.dy)
      ..quadraticBezierTo(c.dx + r * 0.55, c.dy - r * 0.6, c.dx, c.dy - r * 0.3)
      ..close();
    canvas.drawPath(facePath, whitePaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.48, c.dy + r * 0.2),
      Offset(c.dx + r * 0.48, c.dy + r * 0.2),
      r * 0.2,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.34, c.dy - r * 0.06),
      Offset(c.dx + r * 0.34, c.dy - r * 0.06),
      r * 0.17,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Bright Orange Beak with smile curvature
    final beakPaint = Paint()..color = const Color(0xFFFF9800);
    final beakPath = Path()
      ..moveTo(c.dx - r * 0.2, c.dy + r * 0.08)
      ..lineTo(c.dx + r * 0.2, c.dy + r * 0.08)
      ..lineTo(c.dx, c.dy + r * (0.38 + smile * 0.06))
      ..close();
    canvas.drawPath(beakPath, beakPaint);

    if (smile > 0.2) {
      final smilePaint = Paint()
        ..color = const Color(0xFFE65100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05
        ..strokeCap = StrokeCap.round;
      final smilePath = Path()
        ..moveTo(c.dx - r * 0.18, c.dy + r * 0.12)
        ..quadraticBezierTo(c.dx, c.dy + r * (0.18 + smile * 0.08), c.dx + r * 0.18, c.dy + r * 0.12);
      canvas.drawPath(smilePath, smilePaint);
    }
  }

  // =========================================================================
  // 11. HAMSTER (animal_hamster)
  // =========================================================================
  void _drawHamster(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Tiny round ears
    final earPaint = Paint()..color = const Color(0xFFFFA726);
    final earInner = Paint()..color = const Color(0xFFFFCDD2);
    canvas.drawCircle(Offset(c.dx - r * 0.65 + leftWiggle * r * 0.2, c.dy - r * 0.68), r * 0.28, earPaint);
    canvas.drawCircle(Offset(c.dx - r * 0.65 + leftWiggle * r * 0.2, c.dy - r * 0.68), r * 0.16, earInner);
    canvas.drawCircle(Offset(c.dx + r * 0.65 + rightWiggle * r * 0.2, c.dy - r * 0.68), r * 0.28, earPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.65 + rightWiggle * r * 0.2, c.dy - r * 0.68), r * 0.16, earInner);

    // Head
    canvas.drawCircle(c, r, earPaint);

    // Chubby Puffed White Cheeks that bloom slightly when smiling
    final cheekRadius = r * (0.45 + smile * 0.04);
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(c.dx - r * 0.45, c.dy + r * 0.32), cheekRadius, whitePaint);
    canvas.drawCircle(Offset(c.dx + r * 0.45, c.dy + r * 0.32), cheekRadius, whitePaint);

    // Blushing
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.58, c.dy + r * 0.32),
      Offset(c.dx + r * 0.58, c.dy + r * 0.32),
      r * 0.22,
      blushFactor: blush,
    );

    // Shiny Seed Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.36, c.dy - r * 0.05),
      Offset(c.dx + r * 0.36, c.dy - r * 0.05),
      r * 0.19,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Tiny Pink Nose
    final nosePaint = Paint()..color = const Color(0xFFE91E63);
    canvas.drawCircle(Offset(c.dx, c.dy + r * 0.18), r * 0.09, nosePaint);

    // Mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.28), r * 0.24, smileFactor: smile);
  }

  // =========================================================================
  // 12. FROG (animal_frog)
  // =========================================================================
  void _drawFrog(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;
    final greenPaint = Paint()..color = const Color(0xFF7CB342);

    // Big Popping Frog Eyes on Top
    canvas.drawCircle(Offset(c.dx - r * 0.48, c.dy - r * 0.55), r * 0.36, greenPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.48, c.dy - r * 0.55), r * 0.36, greenPaint);

    // White Eyeballs
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(c.dx - r * 0.48, c.dy - r * 0.55), r * 0.26, whitePaint);
    canvas.drawCircle(Offset(c.dx + r * 0.48, c.dy - r * 0.55), r * 0.26, whitePaint);

    // Frog Pupils
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.48, c.dy - r * 0.55),
      Offset(c.dx + r * 0.48, c.dy - r * 0.55),
      r * 0.18,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Wide Oval Frog Head
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.1), width: r * 2.1, height: r * 1.55), greenPaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.65, c.dy + r * 0.15),
      Offset(c.dx + r * 0.65, c.dy + r * 0.15),
      r * 0.22,
      blushFactor: blush,
    );

    // Wide Happy Frog Smile
    final smilePaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * (0.09 + smile * 0.02)
      ..strokeCap = StrokeCap.round;

    final smilePath = Path()
      ..moveTo(c.dx - r * (0.60 + smile * 0.08), c.dy + r * (0.18 - smile * 0.06))
      ..quadraticBezierTo(
        c.dx,
        c.dy + r * (0.55 + smile * 0.18),
        c.dx + r * (0.60 + smile * 0.08),
        c.dy + r * (0.18 - smile * 0.06),
      );
    canvas.drawPath(smilePath, smilePaint);

    if (smile > 0.4) {
      final tonguePaint = Paint()..color = const Color(0xFFFF5252);
      final tH = r * 0.25 * ((smile - 0.4) / 0.6);
      final tonguePath = Path()
        ..moveTo(c.dx - r * 0.22, c.dy + r * 0.45)
        ..quadraticBezierTo(c.dx, c.dy + r * 0.45 + tH, c.dx + r * 0.22, c.dy + r * 0.45)
        ..close();
      canvas.drawPath(tonguePath, tonguePaint);
    }
  }

  // =========================================================================
  // 13. OWL (animal_owl)
  // =========================================================================
  void _drawOwl(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Feathery Ear Tufts
    final tuftPaint = Paint()..color = const Color(0xFF5E35B1);
    final lTuft = Path()
      ..moveTo(c.dx - r * 0.7, c.dy - r * 0.4)
      ..lineTo(c.dx - r * (0.85 + leftWiggle * 0.4), c.dy - r * 0.9)
      ..lineTo(c.dx - r * 0.35, c.dy - r * 0.7)
      ..close();
    canvas.drawPath(lTuft, tuftPaint);

    final rTuft = Path()
      ..moveTo(c.dx + r * 0.7, c.dy - r * 0.4)
      ..lineTo(c.dx + r * (0.85 + rightWiggle * 0.4), c.dy - r * 0.9)
      ..lineTo(c.dx + r * 0.35, c.dy - r * 0.7)
      ..close();
    canvas.drawPath(rTuft, tuftPaint);

    // Head / Body
    final bodyPaint = Paint()..color = const Color(0xFF7E57C2);
    canvas.drawCircle(c, r, bodyPaint);

    // Big White Eye Disks
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(c.dx - r * 0.4, c.dy - r * 0.1), r * 0.35, whitePaint);
    canvas.drawCircle(Offset(c.dx + r * 0.4, c.dy - r * 0.1), r * 0.35, whitePaint);

    // Big Luminous Owl Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.4, c.dy - r * 0.1),
      Offset(c.dx + r * 0.4, c.dy - r * 0.1),
      r * 0.22,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.6, c.dy + r * 0.25),
      Offset(c.dx + r * 0.6, c.dy + r * 0.25),
      r * 0.18,
      blushFactor: blush,
    );

    // Cute Orange Beak
    final beakPaint = Paint()..color = const Color(0xFFFFB300);
    final beakPath = Path()
      ..moveTo(c.dx - r * 0.12, c.dy)
      ..lineTo(c.dx + r * 0.12, c.dy)
      ..lineTo(c.dx, c.dy + r * (0.25 + smile * 0.05))
      ..close();
    canvas.drawPath(beakPath, beakPaint);
  }

  // =========================================================================
  // 14. DUCK (animal_duck)
  // =========================================================================
  void _drawDuck(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Head Tuft feather
    final tuftPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset(c.dx + leftWiggle * r * 0.2, c.dy - r * 0.95), r * 0.18, tuftPaint);

    // Head
    canvas.drawCircle(c, r, tuftPaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.55, c.dy + r * 0.15),
      Offset(c.dx + r * 0.55, c.dy + r * 0.15),
      r * 0.2,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.35, c.dy - r * 0.1),
      Offset(c.dx + r * 0.35, c.dy - r * 0.1),
      r * 0.18,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Flat Orange Bill
    final billPaint = Paint()..color = const Color(0xFFFF8F00);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.22), width: r * 0.75, height: r * 0.45), billPaint);

    // Smile line across bill
    final linePaint = Paint()
      ..color = const Color(0xFFE65100)
      ..strokeWidth = r * 0.05
      ..strokeCap = StrokeCap.round;
    final billSmile = Path()
      ..moveTo(c.dx - r * 0.25, c.dy + r * (0.22 - smile * 0.04))
      ..quadraticBezierTo(c.dx, c.dy + r * (0.22 + smile * 0.12), c.dx + r * 0.25, c.dy + r * (0.22 - smile * 0.04));
    canvas.drawPath(billSmile, linePaint);
  }

  // =========================================================================
  // 15. MONKEY (animal_monkey)
  // =========================================================================
  void _drawMonkey(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Big Round Ears
    final earPaint = Paint()..color = const Color(0xFF795548);
    final earInner = Paint()..color = const Color(0xFFFFCCBC);
    canvas.drawCircle(Offset(c.dx - r * 0.85 + leftWiggle * r * 0.2, c.dy), r * 0.38, earPaint);
    canvas.drawCircle(Offset(c.dx - r * 0.85 + leftWiggle * r * 0.2, c.dy), r * 0.22, earInner);
    canvas.drawCircle(Offset(c.dx + r * 0.85 + rightWiggle * r * 0.2, c.dy), r * 0.38, earPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.85 + rightWiggle * r * 0.2, c.dy), r * 0.22, earInner);

    // Head
    canvas.drawCircle(c, r, earPaint);

    // Heart-shaped face patch
    final facePaint = Paint()..color = const Color(0xFFFFE0B2);
    canvas.drawCircle(Offset(c.dx - r * 0.32, c.dy - r * 0.12), r * 0.38, facePaint);
    canvas.drawCircle(Offset(c.dx + r * 0.32, c.dy - r * 0.12), r * 0.38, facePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.22), width: r * 1.15, height: r * 0.8), facePaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.48, c.dy + r * 0.25),
      Offset(c.dx + r * 0.48, c.dy + r * 0.25),
      r * 0.18,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.32, c.dy - r * 0.1),
      Offset(c.dx + r * 0.32, c.dy - r * 0.1),
      r * 0.17,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Nostrils
    final nostrilPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawCircle(Offset(c.dx - r * 0.08, c.dy + r * 0.16), r * 0.04, nostrilPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.08, c.dy + r * 0.16), r * 0.04, nostrilPaint);

    // Mischievous Wide Grin
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.35), r * 0.34, open: true, smileFactor: smile);
  }

  // =========================================================================
  // 16. DEER (animal_deer)
  // =========================================================================
  void _drawDeer(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Cute Antler Buds
    final antlerPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = r * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx - r * 0.3, c.dy - r * 0.7), Offset(c.dx - r * 0.45, c.dy - r * 1.05), antlerPaint);
    canvas.drawLine(Offset(c.dx - r * 0.38, c.dy - r * 0.88), Offset(c.dx - r * 0.22, c.dy - r * 0.98), antlerPaint);
    canvas.drawLine(Offset(c.dx + r * 0.3, c.dy - r * 0.7), Offset(c.dx + r * 0.45, c.dy - r * 1.05), antlerPaint);
    canvas.drawLine(Offset(c.dx + r * 0.38, c.dy - r * 0.88), Offset(c.dx + r * 0.22, c.dy - r * 0.98), antlerPaint);

    // Ears
    final earPaint = Paint()..color = const Color(0xFFA1887F);
    final earInner = Paint()..color = Colors.white;
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx - r * 0.7 + leftWiggle * r * 0.2, c.dy - r * 0.4), width: r * 0.45, height: r * 0.8), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx - r * 0.7 + leftWiggle * r * 0.2, c.dy - r * 0.4), width: r * 0.22, height: r * 0.5), earInner);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx + r * 0.7 + rightWiggle * r * 0.2, c.dy - r * 0.4), width: r * 0.45, height: r * 0.8), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx + r * 0.7 + rightWiggle * r * 0.2, c.dy - r * 0.4), width: r * 0.22, height: r * 0.5), earInner);

    // Head
    canvas.drawCircle(c, r, earPaint);

    // White Forehead Spots
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(c.dx, c.dy - r * 0.45), r * 0.07, whitePaint);
    canvas.drawCircle(Offset(c.dx - r * 0.16, c.dy - r * 0.32), r * 0.06, whitePaint);
    canvas.drawCircle(Offset(c.dx + r * 0.16, c.dy - r * 0.32), r * 0.06, whitePaint);

    // White Muzzle
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.3), width: r * 0.8, height: r * 0.55), whitePaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.52, c.dy + r * 0.22),
      Offset(c.dx + r * 0.52, c.dy + r * 0.22),
      r * 0.18,
      blushFactor: blush,
    );

    // Gentle Doe Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.38, c.dy - r * 0.05),
      Offset(c.dx + r * 0.38, c.dy - r * 0.05),
      r * 0.2,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Black Nose
    final nosePaint = Paint()..color = const Color(0xFF212121);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.2), width: r * 0.24, height: r * 0.16), nosePaint);

    // Mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.34), r * 0.22, smileFactor: smile);
  }

  // =========================================================================
  // 17. HEDGEHOG (animal_hedgehog)
  // =========================================================================
  void _drawHedgehog(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Spiky Quill Halo
    final quillPaint = Paint()..color = const Color(0xFF6D4C41);
    for (int i = 0; i < 14; i++) {
      final angle = (i * 2 * math.pi) / 14;
      final qOffset = Offset(c.dx + math.cos(angle) * (r * 0.95), c.dy + math.sin(angle) * (r * 0.95));
      canvas.drawCircle(qOffset, r * 0.28, quillPaint);
    }

    // Beige Face
    final facePaint = Paint()..color = const Color(0xFFFFE0B2);
    canvas.drawCircle(c, r * 0.88, facePaint);

    // Tiny round ears
    final earPaint = Paint()..color = const Color(0xFFBCAAA4);
    canvas.drawCircle(Offset(c.dx - r * 0.62 + leftWiggle * r * 0.15, c.dy - r * 0.4), r * 0.18, earPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.62 + rightWiggle * r * 0.15, c.dy - r * 0.4), r * 0.18, earPaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.5, c.dy + r * 0.2),
      Offset(c.dx + r * 0.5, c.dy + r * 0.2),
      r * 0.2,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.32, c.dy - r * 0.05),
      Offset(c.dx + r * 0.32, c.dy - r * 0.05),
      r * 0.17,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Cute Snout
    final nosePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawCircle(Offset(c.dx, c.dy + r * 0.18), r * 0.12, nosePaint);

    // Mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.32), r * 0.22, smileFactor: smile);
  }

  // =========================================================================
  // 18. OTTER (animal_otter)
  // =========================================================================
  void _drawOtter(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Small Round Ears
    final earPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawCircle(Offset(c.dx - r * 0.72 + leftWiggle * r * 0.2, c.dy - r * 0.5), r * 0.24, earPaint);
    canvas.drawCircle(Offset(c.dx + r * 0.72 + rightWiggle * r * 0.2, c.dy - r * 0.5), r * 0.24, earPaint);

    // Head
    final headPaint = Paint()..color = const Color(0xFF795548);
    canvas.drawCircle(c, r, headPaint);

    // Light Cream Muzzle
    final muzzlePaint = Paint()..color = const Color(0xFFFFF8E1);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.28), width: r * 1.1, height: r * 0.65), muzzlePaint);

    // Whiskers with animated twitch
    final whiskerTwitch = smile * (r * 0.04);
    final whiskerPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = r * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(c.dx - r * 0.35, c.dy + r * 0.26),
      Offset(c.dx - r * 0.85, c.dy + r * 0.22 - whiskerTwitch),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(c.dx + r * 0.35, c.dy + r * 0.26),
      Offset(c.dx + r * 0.85, c.dy + r * 0.22 - whiskerTwitch),
      whiskerPaint,
    );

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.55, c.dy + r * 0.2),
      Offset(c.dx + r * 0.55, c.dy + r * 0.2),
      r * 0.18,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.36, c.dy - r * 0.06),
      Offset(c.dx + r * 0.36, c.dy - r * 0.06),
      r * 0.18,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Black Button Nose
    final nosePaint = Paint()..color = const Color(0xFF212121);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.16), width: r * 0.28, height: r * 0.2), nosePaint);

    // Mouth
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.32), r * 0.28, smileFactor: smile);
  }

  // =========================================================================
  // 19. SLOTH (animal_sloth)
  // =========================================================================
  void _drawSloth(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Head
    final headPaint = Paint()..color = const Color(0xFFBCAAA4);
    canvas.drawCircle(c, r, headPaint);

    // Cream Face
    final facePaint = Paint()..color = const Color(0xFFFFF8E1);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.1), width: r * 1.45, height: r * 1.3), facePaint);

    // Distinctive Brown Eye Bands
    final bandPaint = Paint()..color = const Color(0xFF6D4C41);
    canvas.save();
    canvas.translate(c.dx - r * 0.38, c.dy - r * 0.02);
    canvas.rotate(0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.38, height: r * 0.6), bandPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(c.dx + r * 0.38, c.dy - r * 0.02);
    canvas.rotate(-0.3);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: r * 0.38, height: r * 0.6), bandPaint);
    canvas.restore();

    // Serene Peaceful Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.36, c.dy - r * 0.02),
      Offset(c.dx + r * 0.36, c.dy - r * 0.02),
      r * 0.15,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.55, c.dy + r * 0.25),
      Offset(c.dx + r * 0.55, c.dy + r * 0.25),
      r * 0.18,
      blushFactor: blush,
    );

    // Black Snout
    final nosePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + r * 0.18), width: r * 0.3, height: r * 0.2), nosePaint);

    // Sweet chilled smile
    _drawCuteMouth(canvas, Offset(c.dx, c.dy + r * 0.34), r * 0.26, smileFactor: smile);
  }

  // =========================================================================
  // 20. DOLPHIN (animal_dolphin)
  // =========================================================================
  void _drawDolphin(
    Canvas canvas,
    Size size,
    Offset c,
    double leftEye,
    double rightEye,
    double smile,
    double blush,
    double leftWiggle,
    double rightWiggle,
  ) {
    final r = size.width * 0.33;

    // Water droplet / sparkle floating from blowhole with animation
    final waterPaint = Paint()..color = const Color(0xFF4DD0E1);
    final dropFloat = (progress * 2) % 1.0;
    canvas.drawCircle(Offset(c.dx - r * 0.15, c.dy - r * (0.85 + dropFloat * 0.3)), r * 0.1 * (1.0 - dropFloat * 0.3), waterPaint);
    canvas.drawCircle(Offset(c.dx, c.dy - r * (1.05 + dropFloat * 0.35)), r * 0.08 * (1.0 - dropFloat * 0.3), waterPaint);

    // Dolphin Head curve
    final bodyPaint = Paint()..color = const Color(0xFF26C6DA);
    final dolphinPath = Path()
      ..moveTo(c.dx - r * 0.8, c.dy + r * 0.5)
      ..quadraticBezierTo(c.dx - r * 0.9, c.dy - r * 0.6, c.dx, c.dy - r * 0.7)
      ..quadraticBezierTo(c.dx + r * 0.85, c.dy - r * 0.4, c.dx + r * 0.9, c.dy + r * 0.1)
      ..quadraticBezierTo(c.dx + r * 0.5, c.dy + r * 0.8, c.dx - r * 0.8, c.dy + r * 0.5)
      ..close();
    canvas.drawPath(dolphinPath, bodyPaint);

    // Light belly curve
    final bellyPaint = Paint()..color = const Color(0xFFE0F7FA);
    final bellyPath = Path()
      ..moveTo(c.dx - r * 0.6, c.dy + r * 0.5)
      ..quadraticBezierTo(c.dx, c.dy + r * 0.65, c.dx + r * 0.6, c.dy + r * 0.35)
      ..quadraticBezierTo(c.dx, c.dy + r * 0.35, c.dx - r * 0.6, c.dy + r * 0.5)
      ..close();
    canvas.drawPath(bellyPath, bellyPaint);

    // Cheeks
    _drawBlushingCheeks(
      canvas,
      Offset(c.dx - r * 0.4, c.dy + r * 0.15),
      Offset(c.dx + r * 0.4, c.dy + r * 0.15),
      r * 0.18,
      blushFactor: blush,
    );

    // Eyes
    _drawEyes(
      canvas,
      Offset(c.dx - r * 0.28, c.dy - r * 0.1),
      Offset(c.dx + r * 0.32, c.dy - r * 0.1),
      r * 0.18,
      leftEye,
      rightEye,
      smileFactor: smile,
    );

    // Dolphin Beak / Smiling Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF006064)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * (0.08 + smile * 0.02)
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(c.dx - r * 0.2, c.dy + r * (0.22 - smile * 0.05))
      ..quadraticBezierTo(
        c.dx + r * 0.2,
        c.dy + r * (0.38 + smile * 0.15),
        c.dx + r * 0.65,
        c.dy + r * (0.22 - smile * 0.05),
      );
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant AnimalFacePainter oldDelegate) {
    return oldDelegate.avatarId != avatarId ||
        oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}
