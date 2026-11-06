import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import '../../data/globe_world_data.dart';
import '../../data/world_countries_data.dart';
import '../../domain/travel_country.dart';

/// Clean, natural 3D World Globe visualization for PackBuddy
/// Real world landmasses and countries projected onto a 3D sphere,
/// manual 360° orbital rotation, pinch-to-zoom, and country status coloring.
class Globe3DViewer extends StatefulWidget {
  final List<TravelCountry> countries;
  final ValueChanged<TravelCountry> onCountryTap;
  final ValueChanged<bool>? onInteracting;
  final bool isDark;

  const Globe3DViewer({
    super.key,
    required this.countries,
    required this.onCountryTap,
    this.onInteracting,
    required this.isDark,
  });

  @override
  State<Globe3DViewer> createState() => _Globe3DViewerState();
}

class _Globe3DViewerState extends State<Globe3DViewer> {
  // Sphere rotation angles in radians - Initial perspective centered around Turkey / Europe / Mediterranean
  double _rotLat = 0.35; // ~20 degrees North
  double _rotLng = 0.55; // ~31 degrees East
  double _scale = 1.0;
  double _baseScale = 1.0;
  bool _isDragging = false;

  void _resetRotation() {
    setState(() {
      _rotLat = 0.35;
      _rotLng = 0.55;
      _scale = 1.0;
    });
  }

  void _handleTapUp(TapUpDetails details, Size size, double radius) {
    final center = Offset(size.width / 2, size.height / 2);
    final touchOffset = details.localPosition;

    final dx = touchOffset.dx - center.dx;
    final dy = touchOffset.dy - center.dy;
    final distFromCenter = math.sqrt(dx * dx + dy * dy);

    // If tap is clearly outside the sphere, ignore
    if (distFromCenter > radius + 10.0) return;

    // 1. Raycast touch coordinates to spherical surface coordinates (latRad, lngRad)
    final sX = (dx / radius).clamp(-1.0, 1.0);
    final sY = (dy / radius).clamp(-1.0, 1.0);
    final r2 = sX * sX + sY * sY;
    final sZ = math.sqrt(math.max(0.0, 1.0 - math.min(1.0, r2)));

    final cosRotLat = math.cos(_rotLat);
    final sinRotLat = math.sin(_rotLat);

    final uX = sX;
    final uZ = sinRotLat * sZ - cosRotLat * sY;
    final uY = cosRotLat * sZ + sinRotLat * sY;

    final touchLatRad = math.asin(uZ.clamp(-1.0, 1.0));
    final dLng = math.atan2(uX, uY);
    var touchLngRad = dLng + _rotLng;
    while (touchLngRad > math.pi) {
      touchLngRad -= 2 * math.pi;
    }
    while (touchLngRad < -math.pi) {
      touchLngRad += 2 * math.pi;
    }

    final polygons = GlobeWorldData.getPolygons();
    String? matchedCode;

    // 2. Exact test: Check if (touchLatRad, touchLngRad) is inside any visible polygon
    for (final poly in polygons) {
      final pDLng = poly.centerLng - _rotLng;
      final zFront = sinRotLat * math.sin(poly.centerLat) +
          cosRotLat * math.cos(poly.centerLat) * math.cos(pDLng);
      if (zFront <= -0.15) continue;

      if (_isPointInPoly(touchLatRad, touchLngRad, poly.lats, poly.lngs)) {
        matchedCode = poly.code;
        break;
      }
    }

    // 3. Proximity fallback: If tapped near border or on small island/country
    if (matchedCode == null) {
      double minAngDistSq = 0.08; // ~16 degrees angular distance threshold

      for (final poly in polygons) {
        final pDLng = poly.centerLng - _rotLng;
        final zFront = sinRotLat * math.sin(poly.centerLat) +
            cosRotLat * math.cos(poly.centerLat) * math.cos(pDLng);
        if (zFront <= 0.05) continue;

        final dLat = poly.centerLat - touchLatRad;
        var dLngDiff = poly.centerLng - touchLngRad;
        while (dLngDiff > math.pi) {
          dLngDiff -= 2 * math.pi;
        }
        while (dLngDiff < -math.pi) {
          dLngDiff += 2 * math.pi;
        }
        final angDistSq = dLat * dLat +
            (math.cos(touchLatRad) * dLngDiff) *
                (math.cos(touchLatRad) * dLngDiff);

        if (angDistSq < minAngDistSq) {
          minAngDistSq = angDistSq;
          matchedCode = poly.code;
        }
      }
    }

    // 4. Resolve matched country from widget.countries or WorldCountriesData
    if (matchedCode != null && matchedCode.isNotEmpty) {
      final cleanCode = matchedCode.toUpperCase().trim();
      TravelCountry? match = widget.countries
          .where((c) => c.code.toUpperCase() == cleanCode)
          .firstOrNull;
      match ??= WorldCountriesData.allCountries
          .where((c) => c.code.toUpperCase() == cleanCode)
          .firstOrNull;
      match ??= WorldCountriesData.matchCountry(cleanCode);

      if (match != null) {
        final userSaved = widget.countries
            .where((c) => c.code.toUpperCase() == match!.code.toUpperCase())
            .firstOrNull;
        if (userSaved != null) {
          match = userSaved;
        }
        widget.onCountryTap(match);
      }
    }
  }

  static bool _isPointInPoly(
    double lat,
    double lng,
    List<double> pLats,
    List<double> pLngs,
  ) {
    final n = pLats.length;
    if (n < 3) return false;
    bool inside = false;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      final yi = pLats[i], xi = pLngs[i];
      final yj = pLats[j], xj = pLngs[j];
      if ((yi > lat) != (yj > lat)) {
        final double intersectX = (xj - xi) * (lat - yi) / (yj - yi) + xi;
        if (lng < intersectX) {
          inside = !inside;
        }
      }
    }
    return inside;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 390);
        final baseRadius = math.min(size.width, size.height) * 0.40;
        final radius = (baseRadius * _scale).clamp(70.0, 260.0);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: (details) {
            setState(() => _isDragging = true);
            widget.onInteracting?.call(true);
            _baseScale = _scale;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scale = (_baseScale * details.scale).clamp(0.75, 1.85);
              // Rotation sensitivity (natural 1:1 finger tracking)
              _rotLng -= details.focalPointDelta.dx * 0.0075;
              _rotLat = (_rotLat + details.focalPointDelta.dy * 0.0075)
                  .clamp(-1.25, 1.25);
            });
          },
          onScaleEnd: (_) {
            setState(() => _isDragging = false);
            widget.onInteracting?.call(false);
          },
          onTapUp: (details) => _handleTapUp(details, size, radius),
          child: Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: size,
                  painter: _GlobePainter(
                    countries: widget.countries,
                    polygons: GlobeWorldData.getPolygons(),
                    rotLat: _rotLat,
                    rotLng: _rotLng,
                    radius: radius,
                    isDark: widget.isDark,
                  ),
                ),
              ),

              // Reset Rotation Button (Top Right)
              Positioned(
                top: 12,
                right: 14,
                child: Container(
                  decoration: BoxDecoration(
                    color: (widget.isDark
                            ? const Color(0xFF0F172A)
                            : Colors.white)
                        .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.isDark ? Colors.white12 : Colors.black12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    tooltip: l10n?.resetZoom ?? 'Reset',
                    padding: const EdgeInsets.all(7),
                    constraints: const BoxConstraints(),
                    onPressed: _resetRotation,
                  ),
                ),
              ),

              // Interactive hint (Positioned cleanly at top-left under the 2D/3D toggle, never overlapping bottom legend)
              Positioned(
                top: 54,
                left: 14,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _isDragging ? 0.0 : 0.85,
                  child: IgnorePointer(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: (widget.isDark ? const Color(0xFF0F172A) : Colors.white)
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.isDark ? Colors.white12 : Colors.black12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 13,
                            color: widget.isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            l10n?.globeRotateHint ?? 'Drag to rotate • Tap',
                            style: TextStyle(
                              color: widget.isDark ? Colors.white : Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlobePainter extends CustomPainter {
  final List<TravelCountry> countries;
  final List<GlobePolygon> polygons;
  final double rotLat;
  final double rotLng;
  final double radius;
  final bool isDark;

  final Map<String, CountryStatus> _statusMap = {};

  _GlobePainter({
    required this.countries,
    required this.polygons,
    required this.rotLat,
    required this.rotLng,
    required this.radius,
    required this.isDark,
  }) {
    for (final c in countries) {
      if (c.status != CountryStatus.none) {
        _statusMap[c.code.toUpperCase().trim()] = c.status;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Natural Ambient Soft Drop Shadow behind the globe
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.45 : 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center + const Offset(0, 6), radius, shadowPaint);

    // 2. Globe Base (Natural Clean Ocean without sci-fi neon or harsh navy)
    final oceanPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        colors: isDark
            ? const [
                Color(0xFF162032), // Soft oceanic dark slate highlight
                Color(0xFF0F172A), // PackBuddy dark surface navy-slate
                Color(0xFF090E17), // Subtle spherical rim depth
              ]
            : const [
                Color(0xFFF1F6FD), // Soft natural water daylight highlight
                Color(0xFFE2ECF8), // Clean natural pastel ocean
                Color(0xFFCBDDF5), // Subtle spherical rim depth
              ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, oceanPaint);

    // 3. Draw World Continents & Country Polygons onto the 3D Sphere (Clipped to the globe circle)
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    final cosRotLat = math.cos(rotLat);
    final sinRotLat = math.sin(rotLat);

    final unvisitedLandColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final unvisitedBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final defaultLandPaint = Paint()
      ..color = unvisitedLandColor
      ..style = PaintingStyle.fill;

    final defaultBorderPaint = Paint()
      ..color = unvisitedBorderColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55;

    final livedLandPaint = Paint()
      ..color = const Color(0xFF10B981) // Emerald Green
      ..style = PaintingStyle.fill;

    final livedBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;

    final visitedLandPaint = Paint()
      ..color = const Color(0xFFE7B623) // Serene Sun Gold
      ..style = PaintingStyle.fill;

    final visitedBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;

    final wishlistLandPaint = Paint()
      ..color = const Color(0xFFEF4444) // Skratch Coral
      ..style = PaintingStyle.fill;

    final wishlistBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;

    for (final poly in polygons) {
      final status = _statusMap[poly.code] ?? CountryStatus.none;

      // Project vertices to 3D sphere
      final path = Path();
      bool hasVisible = false;
      bool isPathStarted = false;

      for (int i = 0; i < poly.lats.length; i++) {
        final lat = poly.lats[i];
        final lng = poly.lngs[i];
        final dLng = lng - rotLng;

        final cosLat = math.cos(lat);
        final sinLat = math.sin(lat);
        final cosDLng = math.cos(dLng);
        final sinDLng = math.sin(dLng);

        final z = sinRotLat * sinLat + cosRotLat * cosLat * cosDLng;

        if (z > -0.05) {
          hasVisible = true;
          final x = radius * cosLat * sinDLng;
          final y = -radius * (cosRotLat * sinLat - sinRotLat * cosLat * cosDLng);
          final pt = Offset(center.dx + x, center.dy + y);

          if (!isPathStarted) {
            path.moveTo(pt.dx, pt.dy);
            isPathStarted = true;
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
        } else {
          isPathStarted = false;
        }
      }

      if (hasVisible) {
        path.close();

        Paint fillPaint;
        Paint strokePaint;

        switch (status) {
          case CountryStatus.lived:
            fillPaint = livedLandPaint;
            strokePaint = livedBorderPaint;
            break;
          case CountryStatus.visited:
            fillPaint = visitedLandPaint;
            strokePaint = visitedBorderPaint;
            break;
          case CountryStatus.wishlist:
            fillPaint = wishlistLandPaint;
            strokePaint = wishlistBorderPaint;
            break;
          case CountryStatus.none:
            fillPaint = defaultLandPaint;
            strokePaint = defaultBorderPaint;
            break;
        }

        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
      }
    }

    canvas.restore();

    // 4. Clean Natural Spherical Rim Outline
    final rimPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.12 : 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, rimPaint);

    // Soft daylight highlight on upper-left to give natural tactile curvature
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.08 : 0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _GlobePainter oldDelegate) {
    return oldDelegate.rotLat != rotLat ||
        oldDelegate.rotLng != rotLng ||
        oldDelegate.radius != radius ||
        oldDelegate.isDark != isDark ||
        oldDelegate.countries != countries;
  }
}
