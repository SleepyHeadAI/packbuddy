import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../features/budget/domain/country.dart';
import 'currency_service.dart';

/// Represents live geographic location detected from network / IP or system locale
class LiveLocationResult {
  final String countryCode;
  final String countryName;
  final String city;
  final String source; // 'live_ip' | 'system_locale'

  const LiveLocationResult({
    required this.countryCode,
    required this.countryName,
    this.city = '',
    this.source = 'system_locale',
  });

  @override
  String toString() =>
      'LiveLocationResult(country: $countryName [$countryCode], city: $city, source: $source)';
}

/// Service to detect the user's real live location using lightweight IP geolocation with resilient fallbacks
class LiveLocationService {
  LiveLocationService._();
  static final LiveLocationService instance = LiveLocationService._();

  static LiveLocationResult? _cachedLocation;

  /// Returns cached live location or resolves fresh location
  Future<LiveLocationResult> detectLiveLocation({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedLocation != null) {
      return _cachedLocation!;
    }

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final detected = CountryDetector.detectCountry();
      _cachedLocation = LiveLocationResult(
        countryCode: detected.code,
        countryName: detected.name,
        city: 'Test City',
        source: 'system_locale',
      );
      return _cachedLocation!;
    }

    // 1. Try IP Geolocation with strict 3-second timeout
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);

      final uri = Uri.parse('http://ip-api.com/json/?fields=status,country,countryCode,city');
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        if (data is Map && data['status'] == 'success') {
          final code = (data['countryCode'] as String? ?? '').toUpperCase().trim();
          final name = data['country'] as String? ?? '';
          final city = data['city'] as String? ?? '';

          if (code.isNotEmpty) {
            final result = LiveLocationResult(
              countryCode: code,
              countryName: name.isNotEmpty ? name : (Country.findByCode(code)?.name ?? code),
              city: city,
              source: 'live_ip',
            );
            _cachedLocation = result;
            client.close();
            return result;
          }
        }
      }
      client.close();
    } catch (e) {
      debugPrint('[LiveLocationService] IP geolocation note: $e');
    }

    // 2. Second fallback endpoint: api.country.is
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 2);
      final uri = Uri.parse('https://api.country.is');
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 2));
      final response = await request.close().timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        if (data is Map && data.containsKey('country')) {
          final code = (data['country'] as String? ?? '').toUpperCase().trim();
          if (code.isNotEmpty) {
            final country = Country.findByCode(code);
            final result = LiveLocationResult(
              countryCode: code,
              countryName: country?.name ?? code,
              city: '',
              source: 'live_ip',
            );
            _cachedLocation = result;
            client.close();
            return result;
          }
        }
      }
      client.close();
    } catch (_) {}

    // 3. Fallback to device system locale via CountryDetector
    final fallback = CountryDetector.detectCountry();
    final result = LiveLocationResult(
      countryCode: fallback.code,
      countryName: fallback.name,
      city: '',
      source: 'system_locale',
    );
    _cachedLocation = result;
    return result;
  }
}

