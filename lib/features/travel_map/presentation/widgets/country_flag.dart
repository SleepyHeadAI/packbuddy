import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';

/// Accurate, high-fidelity Country Flag renderer.
/// Renders authentic vector flags for regions lacking official Unicode ISO flag emojis
/// (such as Northern Cyprus / KKTC) and native emoji flags for all other countries.
class CountryFlag extends StatelessWidget {
  final String code;
  final String fallbackEmoji;
  final double size;

  const CountryFlag({
    super.key,
    required this.code,
    required this.fallbackEmoji,
    this.size = 20,
  });

  factory CountryFlag.fromCountry(TravelCountry country, {double size = 20}) {
    return CountryFlag(
      code: country.code,
      fallbackEmoji: country.flag,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedCode = code.toUpperCase().trim();
    if (normalizedCode == 'NC') {
      return NorthernCyprusFlag(size: size);
    }

    return Text(
      fallbackEmoji,
      style: TextStyle(
        fontSize: size,
        height: 1.1,
      ),
    );
  }
}

/// Official Flag of the Turkish Republic of Northern Cyprus (TRNC / KKTC)
/// Accurately rendered via CustomPainter with white field, two horizontal red stripes,
/// and red crescent & 5-point star in the center.
class NorthernCyprusFlag extends StatelessWidget {
  final double size;

  const NorthernCyprusFlag({
    super.key,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    // 3:2 standard flag aspect ratio
    final width = size * 1.35;
    final height = size * 0.90;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(math.max(1.5, size * 0.10)),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(math.max(1.0, size * 0.08)),
        child: CustomPaint(
          size: Size(width, height),
          painter: _NorthernCyprusFlagPainter(),
        ),
      ),
    );
  }
}

class _NorthernCyprusFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // TRNC Official Red: #E30A17
    final redPaint = Paint()
      ..color = const Color(0xFFE30A17)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Top and Bottom Horizontal Stripes
    final stripeHeight = h * 0.12;
    final stripeMargin = h * 0.12;

    // Top Stripe
    canvas.drawRect(
      Rect.fromLTWH(0, stripeMargin, w, stripeHeight),
      redPaint,
    );

    // Bottom Stripe
    canvas.drawRect(
      Rect.fromLTWH(0, h - stripeMargin - stripeHeight, w, stripeHeight),
      redPaint,
    );

    // 2. Crescent Moon (Hilal)
    final outerRadius = h * 0.22;
    final outerCenter = Offset(w * 0.44, h * 0.50);

    final innerRadius = h * 0.175;
    final innerCenter = Offset(w * 0.485, h * 0.50);

    final outerPath = Path()
      ..addOval(Rect.fromCircle(center: outerCenter, radius: outerRadius));
    final innerPath = Path()
      ..addOval(Rect.fromCircle(center: innerCenter, radius: innerRadius));

    final crescentPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(crescentPath, redPaint);

    // 3. 5-Pointed Star (Yıldız)
    final starCenter = Offset(w * 0.59, h * 0.50);
    final rStarOut = h * 0.09;
    final rStarIn = h * 0.042;

    final starPath = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? rStarOut : rStarIn;
      // Angle offset so one point faces towards the crescent opening (leftwards)
      final angle = (i * 36 - 180) * (math.pi / 180);
      final x = starCenter.dx + r * math.cos(angle);
      final y = starCenter.dy + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

