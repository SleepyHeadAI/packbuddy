import '../../travel_map/data/world_countries_data.dart';

/// Offline-first geocoding resolver for travel destinations and route waypoints
class GeocodingHelper {
  GeocodingHelper._();

  static const Map<String, List<double>> _cityCoordinates = {
    // Top European Cities
    'istanbul': [41.0082, 28.9784],
    'ankara': [39.9334, 32.8597],
    'izmir': [38.4237, 27.1428],
    'antalya': [36.8969, 30.7133],
    'paris': [48.8566, 2.3522],
    'london': [51.5074, -0.1278],
    'londra': [51.5074, -0.1278],
    'rome': [41.9028, 12.4964],
    'roma': [41.9028, 12.4964],
    'berlin': [52.5200, 13.4050],
    'madrid': [40.4168, -3.7038],
    'barcelona': [41.3879, 2.1699],
    'amsterdam': [52.3676, 4.9041],
    'vienna': [48.2082, 16.3738],
    'viyana': [48.2082, 16.3738],
    'prague': [50.0755, 14.4378],
    'prag': [50.0755, 14.4378],
    'athens': [37.9838, 23.7275],
    'atina': [37.9838, 23.7275],
    'lisbon': [38.7223, -9.1393],
    'lizbon': [38.7223, -9.1393],
    'budapest': [47.4979, 19.0402],
    'budapeşte': [47.4979, 19.0402],
    'stockholm': [59.3293, 18.0686],
    'oslo': [59.9139, 10.7522],
    'copenhagen': [55.6761, 12.5683],
    'kopenhag': [55.6761, 12.5683],
    'helsinki': [60.1699, 24.9384],
    'dublin': [53.3498, -6.2603],
    'zurich': [47.3769, 8.5417],
    'zürich': [47.3769, 8.5417],
    'geneva': [46.2044, 6.1432],
    'cenevre': [46.2044, 6.1432],
    'milan': [45.4642, 9.1900],
    'milano': [45.4642, 9.1900],
    'venice': [45.4408, 12.3155],
    'venedik': [45.4408, 12.3155],

    // Top Asian Cities
    'tokyo': [35.6762, 139.6503],
    'kyoto': [35.0116, 135.7681],
    'osaka': [34.6937, 135.5023],
    'seoul': [37.5665, 126.9780],
    'seul': [37.5665, 126.9780],
    'bangkok': [13.7563, 100.5018],
    'singapore': [1.3521, 103.8198],
    'singapur': [1.3521, 103.8198],
    'kuala lumpur': [3.1390, 101.6869],
    'dubai': [25.2048, 55.2708],
    'abu dhabi': [24.4539, 54.3773],
    'abu dabi': [24.4539, 54.3773],
    'doha': [25.2854, 51.5310],
    'riyadh': [24.7136, 46.6753],
    'riyad': [24.7136, 46.6753],
    'beijing': [39.9042, 116.4074],
    'pekin': [39.9042, 116.4074],
    'shanghai': [31.2304, 121.4737],
    'hong kong': [22.3193, 114.1694],
    'mumbai': [19.0760, 72.8777],
    'delhi': [28.7041, 77.1025],
    'bali': [-8.3405, 115.0920],

    // Top American Cities
    'new york': [40.7128, -74.0060],
    'los angeles': [34.0522, -118.2437],
    'san francisco': [37.7749, -122.4194],
    'chicago': [41.8781, -87.6298],
    'miami': [25.7617, -80.1918],
    'toronto': [43.6532, -79.3832],
    'vancouver': [49.2827, -123.1207],
    'montreal': [45.5017, -73.5673],
    'mexico city': [19.4326, -99.1332],
    'buenos aires': [-34.6037, -58.3816],
    'rio de janeiro': [-22.9068, -43.1729],
    'sao paulo': [-23.5505, -46.6333],

    // Africa & Oceania
    'cairo': [30.0444, 31.2357],
    'kahire': [30.0444, 31.2357],
    'marrakech': [31.6295, -7.9811],
    'marakeş': [31.6295, -7.9811],
    'cape town': [-33.9249, 18.4241],
    'sydney': [-33.8688, 151.2093],
    'melbourne': [-37.8136, 144.9631],
    'auckland': [-36.8485, 174.7633],
  };

  /// Resolves latitude and longitude coordinates for a destination or waypoint name
  static Map<String, double>? resolveCoordinates(String text) {
    if (text.trim().isEmpty) return null;
    final clean = text.toLowerCase().trim();

    // Direct city lookup
    for (final entry in _cityCoordinates.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return {'latitude': entry.value[0], 'longitude': entry.value[1]};
      }
    }

    // Country match lookup
    final country = WorldCountriesData.matchCountry(text);
    if (country != null) {
      return {'latitude': country.latitude, 'longitude': country.longitude};
    }

    return null;
  }
}
