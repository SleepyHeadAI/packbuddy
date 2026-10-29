import 'dart:convert';
import 'dart:math' as math;
import 'package:countries_world_map/data/maps/world_map.dart';

/// Representation of a single country polygon projected in spherical spherical radians (lat, lng)
class GlobePolygon {
  final String code;
  final List<double> lats;
  final List<double> lngs;
  final double centerLat;
  final double centerLng;

  const GlobePolygon({
    required this.code,
    required this.lats,
    required this.lngs,
    required this.centerLat,
    required this.centerLng,
  });
}

/// Cached repository of 3D globe world landmass geometry parsed from SMapWorld.instructions
class GlobeWorldData {
  GlobeWorldData._();

  static List<GlobePolygon>? _cached;

  static List<GlobePolygon> getPolygons() {
    if (_cached != null) return _cached!;

    final List<GlobePolygon> list = [];
    try {
      final Map<String, dynamic> data = jsonDecode(SMapWorld.instructions) as Map<String, dynamic>;
      final List items = data['i'] as List;

      for (final item in items) {
        if (item is! Map) continue;
        final rawCode = item['u'] as String? ?? '';
        final code = rawCode.toUpperCase().trim();
        final cmds = item['i'] as List?;
        if (cmds == null || cmds.isEmpty) continue;

        final lats = <double>[];
        final lngs = <double>[];

        for (final cmd in cmds) {
          if (cmd is String && (cmd.startsWith('m') || cmd.startsWith('l'))) {
            final parts = cmd.substring(1).split(',');
            if (parts.length == 2) {
              final x = double.tryParse(parts[0]);
              final y = double.tryParse(parts[1]);
              if (x != null && y != null) {
                // Transform normalized equirectangular map coords to spherical radians
                final lngRad = ((x - 0.4862) * 360.0) * math.pi / 180.0;
                final latRad = ((0.58 - y) * 137.3) * math.pi / 180.0;
                lats.add(latRad);
                lngs.add(lngRad);
              }
            }
          }
        }

        if (lats.isNotEmpty) {
          double sumLat = 0.0;
          double sumLng = 0.0;
          for (int i = 0; i < lats.length; i++) {
            sumLat += lats[i];
            sumLng += lngs[i];
          }
          final centerLat = sumLat / lats.length;
          final centerLng = sumLng / lngs.length;

          list.add(GlobePolygon(
            code: code,
            lats: lats,
            lngs: lngs,
            centerLat: centerLat,
            centerLng: centerLng,
          ));
        }
      }
    } catch (_) {}

    _cached = list;
    return list;
  }
}

