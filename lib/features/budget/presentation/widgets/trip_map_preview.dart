import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/domain/geocoding_helper.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/trip_waypoint.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// CustomPainter drawing a stylized route map with connected waypoints
class RouteMapPainter extends CustomPainter {
  final int waypointCount;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  RouteMapPainter({
    required this.waypointCount,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      bgPaint,
    );

    // Subtle grid lines to simulate a map grid
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double x = 20; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 20; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Points along the route curve
    final points = <Offset>[
      Offset(size.width * 0.15, size.height * 0.70),
      if (waypointCount > 0) Offset(size.width * 0.40, size.height * 0.35),
      if (waypointCount > 1) Offset(size.width * 0.65, size.height * 0.65),
      Offset(size.width * 0.85, size.height * 0.25),
    ];

    // Draw route path
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2 - 15);
      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, p2.dx, p2.dy);
    }

    final pathPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, pathPaint);

    // Draw pins at points
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isStart = i == 0;
      final isEnd = i == points.length - 1;

      final pinPaint = Paint()
        ..color = isStart
            ? secondaryColor
            : (isEnd ? primaryColor : AppColors.warningPastel)
        ..style = PaintingStyle.fill;

      // Glow halo
      canvas.drawCircle(
        pt,
        8,
        Paint()..color = pinPaint.color.withValues(alpha: 0.25),
      );
      // Pin circle
      canvas.drawCircle(pt, 5, pinPaint);
      canvas.drawCircle(
        pt,
        2,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RouteMapPainter oldDelegate) {
    return oldDelegate.waypointCount != waypointCount ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.isDark != isDark;
  }
}

/// Destination visualization and Map Preview Card (Feature F-2)
class TripMapPreviewCard extends StatelessWidget {
  final Trip trip;
  final List<TripWaypoint> waypoints;
  final VoidCallback? onManageRoute;

  const TripMapPreviewCard({
    super.key,
    required this.trip,
    this.waypoints = const [],
    this.onManageRoute,
  });

  /// Extracts individual stops from raw multi-destination strings
  static List<String> parseRouteStops(String raw) {
    if (raw.trim().isEmpty) return [];
    final parts = raw.split(RegExp(r'\s*(?:➔|->|•|\||,)\s*'));
    final stops = <String>[];
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && !stops.contains(trimmed)) {
        stops.add(trimmed);
      }
    }
    return stops.isNotEmpty ? stops : [raw.trim()];
  }

  /// Strips emojis and flag characters so Google Maps search can geocode cleanly
  static String cleanStopForMaps(String stop) {
    return stop
        .replaceAll(RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}', unicode: true), '')
        .replaceAll(RegExp(r'[^\w\s\u00C0-\u017F\u0400-\u04FF\u0600-\u06FF\u3040-\u30FF\u4E00-\u9FFF\uAC00-\uD7AF\.,\-]'), '')
        .trim();
  }

  /// Launches Google Maps with multi-stop directions or single destination search
  static Future<void> launchMaps(String query) async {
    final stops = parseRouteStops(query);
    Uri targetUri;

    if (stops.length >= 2) {
      final origin = cleanStopForMaps(stops.first);
      final dest = cleanStopForMaps(stops.last);
      final intermediate = stops
          .sublist(1, stops.length - 1)
          .map(cleanStopForMaps)
          .where((s) => s.isNotEmpty)
          .toList();

      var url = 'https://www.google.com/maps/dir/?api=1&origin=${Uri.encodeComponent(origin)}&destination=${Uri.encodeComponent(dest)}';
      if (intermediate.isNotEmpty) {
        url += '&waypoints=${intermediate.map(Uri.encodeComponent).join('|')}';
      }
      targetUri = Uri.parse(url);
    } else {
      final clean = stops.isNotEmpty ? cleanStopForMaps(stops.first) : cleanStopForMaps(query);
      targetUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(clean)}');
    }

    try {
      final launched = await launchUrl(targetUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(targetUri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(targetUri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  /// Opens turn-by-turn directions to a specific stop or waypoint
  static Future<void> launchDirections(String destination) async {
    final clean = cleanStopForMaps(destination);
    final directionsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(clean)}');
    try {
      final launched = await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(directionsUrl, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(directionsUrl, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final destination = trip.destination;
    final stops = parseRouteStops(destination);
    final matchedCountry = WorldCountriesData.matchCountry(destination);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Map Canvas with Route Highlights
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: RouteMapPainter(
                        waypointCount: stops.length > 2 ? stops.length - 2 : waypoints.length,
                        primaryColor: theme.colorScheme.primary,
                        secondaryColor: theme.colorScheme.secondary,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.place_rounded, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                destination,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (stops.length >= 2)
                    Positioned(
                      bottom: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${stops.length} ${l10n?.itineraryStops ?? 'Stops'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Multi-Stop Interactive Horizontal Chips
          if (stops.length >= 2) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: stops.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final stop = entry.value;
                    final isLast = idx == stops.length - 1;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => launchDirections(stop),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Text(
                                    '${idx + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  stop,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: theme.colorScheme.primary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          // Map Details & Action Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width > 360 ? 180 : 130,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.tripMap ?? 'Travel Map & Route',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stops.length >= 2
                                ? '${stops.first} ➔ ${stops.last}'
                                : (waypoints.isEmpty
                                    ? (l10n?.noWaypoints ?? 'No waypoints added yet')
                                    : '${waypoints.length} • ${l10n?.waypoints ?? 'Route Waypoints'}'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: Text(
                        l10n?.openInMaps ?? 'Open in Maps',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => launchMaps(destination),
                    ),
                  ],
                ),
                if (onManageRoute != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                      label: Text(
                        l10n?.waypoints ?? 'Manage Route Waypoints',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: onManageRoute,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.public_rounded, size: 16),
                    label: Text(
                      matchedCountry != null
                          ? '${matchedCountry.flag} ${matchedCountry.nameTr} • Dünya Haritasında Gör'
                          : 'Dünya Seyahat Haritam (Been & Skratch)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TravelMapScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet for Managing Travel Route & Waypoints (Feature F-2)
class TripMapSheet extends StatefulWidget {
  final Trip trip;
  final List<TripWaypoint> initialWaypoints;
  final ValueChanged<List<TripWaypoint>>? onWaypointsChanged;

  const TripMapSheet({
    super.key,
    required this.trip,
    this.initialWaypoints = const [],
    this.onWaypointsChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required Trip trip,
    List<TripWaypoint> initialWaypoints = const [],
    ValueChanged<List<TripWaypoint>>? onWaypointsChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: TripMapSheet(
          trip: trip,
          initialWaypoints: initialWaypoints,
          onWaypointsChanged: onWaypointsChanged,
        ),
      ),
    );
  }

  @override
  State<TripMapSheet> createState() => _TripMapSheetState();
}

class _TripMapSheetState extends State<TripMapSheet> {
  late List<TripWaypoint> _waypoints;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedCategory = 'hotel';

  @override
  void initState() {
    super.initState();
    _waypoints = List.from(widget.initialWaypoints);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _addWaypoint() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final coords = GeocodingHelper.resolveCoordinates(name) ??
        GeocodingHelper.resolveCoordinates(widget.trip.destination);

    final newWaypoint = TripWaypoint(
      id: 'wp_${DateTime.now().millisecondsSinceEpoch}',
      tripId: widget.trip.id,
      name: name,
      category: _selectedCategory,
      latitude: coords?['latitude'],
      longitude: coords?['longitude'],
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      orderIndex: _waypoints.length,
    );

    setState(() {
      _waypoints.add(newWaypoint);
    });

    widget.onWaypointsChanged?.call(_waypoints);
    _nameController.clear();
    _addressController.clear();
  }

  void _removeWaypoint(String id) {
    setState(() {
      _waypoints.removeWhere((w) => w.id == id);
    });
    widget.onWaypointsChanged?.call(_waypoints);
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'hotel':
        return Icons.hotel_rounded;
      case 'airport':
        return Icons.flight_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'station':
        return Icons.train_rounded;
      case 'attraction':
      default:
        return Icons.attractions_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(Icons.route_rounded, color: theme.colorScheme.primary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.waypoints ?? 'Route Waypoints',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.trip.destination,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add Waypoint Inputs
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: l10n?.waypointName ?? 'Place / Hotel / Landmark',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'hotel', child: Icon(Icons.hotel_rounded, size: 20)),
                      DropdownMenuItem(value: 'airport', child: Icon(Icons.flight_rounded, size: 20)),
                      DropdownMenuItem(value: 'attraction', child: Icon(Icons.attractions_rounded, size: 20)),
                      DropdownMenuItem(value: 'restaurant', child: Icon(Icons.restaurant_rounded, size: 20)),
                      DropdownMenuItem(value: 'station', child: Icon(Icons.train_rounded, size: 20)),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _addWaypoint,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Icon(Icons.add_rounded, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Waypoints list
              if (_waypoints.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      l10n?.noWaypoints ?? 'No waypoints added yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                ..._waypoints.map((wp) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(wp.category), size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wp.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              if (wp.latitude != null && wp.longitude != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    children: [
                                      Icon(Icons.gps_fixed_rounded, size: 11, color: theme.colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${wp.latitude!.toStringAsFixed(2)}° N, ${wp.longitude!.toStringAsFixed(2)}° E',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.directions_rounded, size: 18),
                          onPressed: () => TripMapPreviewCard.launchDirections(wp.name),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          onPressed: () => _removeWaypoint(wp.id),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
