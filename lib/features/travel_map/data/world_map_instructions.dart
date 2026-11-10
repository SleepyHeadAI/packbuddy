import 'dart:convert';
import 'dart:math' as math;
import 'package:countries_world_map/data/maps/world_map.dart';

/// Centralized provider for world map vector instructions.
/// Augments [SMapWorld.instructions] by injecting missing microstates and small
/// territories (Hong Kong, Singapore, Macau, Monaco, Vatican, San Marino,
/// Andorra, Liechtenstein, Gibraltar) so they are rendered with full status colors
/// (Lived, Visited, Wishlist, Unvisited), borders, and interactive tap handlers.
class WorldMapInstructions {
  WorldMapInstructions._();

  static final String instructions = _buildInstructions();

  static String _buildInstructions() {
    try {
      final Map<String, dynamic> data = jsonDecode(SMapWorld.instructions) as Map<String, dynamic>;
      final List items = List.from(data['i'] as List);

      Map<String, dynamic> createMicrostate(
        String code,
        String name,
        double cx,
        double cy,
        double rx,
        double ry, {
        int sides = 8,
      }) {
        final List<String> cmds = [];
        for (int i = 0; i < sides; i++) {
          final angle = i * 2 * math.pi / sides;
          final x = (cx + rx * math.cos(angle)).toStringAsFixed(6);
          final y = (cy + ry * math.sin(angle)).toStringAsFixed(6);
          cmds.add(i == 0 ? 'm$x,$y' : 'l$x,$y');
        }
        cmds.add('c');
        return {
          'n': name,
          'u': code.toLowerCase(),
          'i': cmds,
        };
      }

      final microstates = [
        // Singapore: nestled in Johor Strait south of Peninsular Malaysia
        createMicrostate('sg', 'Singapore', 0.7882, 0.5786, 0.0024, 0.0020),
        // Hong Kong: Victoria Harbour / east Pearl River Estuary
        createMicrostate('hk', 'Hong Kong', 0.8182, 0.4128, 0.0024, 0.0022),
        // Macau: west Pearl River Estuary
        createMicrostate('mo', 'Macau', 0.8128, 0.4158, 0.0018, 0.0018),
        // Monaco: French Riviera / Ligurian Coast
        createMicrostate('mc', 'Monaco', 0.5118, 0.2520, 0.0016, 0.0016),
        // Vatican City: Rome, Italy
        createMicrostate('va', 'Vatican City', 0.5285, 0.2685, 0.0016, 0.0016),
        // San Marino: near Rimini in central Italy
        createMicrostate('sm', 'San Marino', 0.5305, 0.2520, 0.0016, 0.0016),
        // Andorra: Pyrenees between Spain and France
        createMicrostate('ad', 'Andorra', 0.4950, 0.2640, 0.0020, 0.0018),
        // Liechtenstein: between Switzerland and Austria
        createMicrostate('li', 'Liechtenstein', 0.5185, 0.2325, 0.0016, 0.0018),
        // Gibraltar: southern tip of Iberian Peninsula
        createMicrostate('gi', 'Gibraltar', 0.4775, 0.3175, 0.0015, 0.0016),
      ];

      items.addAll(microstates);
      data['i'] = items;

      return jsonEncode(data);
    } catch (_) {
      // Graceful fallback to original instructions if JSON operations fail
      return SMapWorld.instructions;
    }
  }
}
