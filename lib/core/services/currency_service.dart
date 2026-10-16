import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/budget/domain/country.dart';
import 'preferences_service.dart';
import '../utils/currency_formatter.dart';

/// Comprehensive Currency Service providing offline-first foreign exchange conversions,
/// formatting, and automatic background online synchronization for travel budgets.
class CurrencyService {
  CurrencyService._();

  static const String _prefKeyRates = 'packbuddy_cached_currency_rates';
  static const String _prefKeyLastUpdated = 'packbuddy_currency_rates_last_updated';

  /// Free, open exchange rate API endpoint (no key required, supports 160+ currencies)
  static const String liveApiEndpoint = 'https://open.er-api.com/v6/latest/USD';

  /// Offline default exchange rates against USD base (1.0 USD = X Currency)
  /// Serves as the guaranteed resilient offline fallback for all 30 supported currencies.
  static const Map<String, double> defaultRatesAgainstUsd = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.77,
    'TRY': 34.25,
    'JPY': 152.5,
    'CHF': 0.87,
    'CAD': 1.38,
    'AUD': 1.51,
    'AED': 3.6725,
    'SAR': 3.75,
    'THB': 33.8,
    'SGD': 1.32,
    'KRW': 1385.0,
    'CNY': 7.15,
    'INR': 84.1,
    'BRL': 5.72,
    'MXN': 19.85,
    'SEK': 10.6,
    'NOK': 10.8,
    'DKK': 6.88,
    'PLN': 4.02,
    'IDR': 15650.0,
    'VND': 25300.0,
    'EGP': 49.0,
    'NZD': 1.66,
    'CZK': 23.4,
    'HUF': 371.0,
    'ILS': 3.75,
    'ZAR': 17.65,
    'QAR': 3.64,
  };

  /// Current active rates in memory (initialized with offline defaults)
  static final Map<String, double> _currentRates =
      Map<String, double>.from(defaultRatesAgainstUsd);

  /// Timestamp of the last successful live rates update (null if using offline defaults)
  static DateTime? _lastUpdatedAt;

  /// Exposes current rates against USD
  static Map<String, double> get ratesAgainstUsd => Map.unmodifiable(_currentRates);

  /// Timestamp of the last successful live rates update
  static DateTime? get lastUpdatedAt => _lastUpdatedAt;

  /// Returns true if live rates have been loaded or synchronized
  static bool get isUsingLiveRates => _lastUpdatedAt != null;

  /// Supported currency codes (all 30 canonical travel currencies)
  static List<String> get supportedCurrencies => defaultRatesAgainstUsd.keys.toList();

  /// Initializes the service by loading locally cached rates from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_prefKeyRates);
      final timestampMs = prefs.getInt(_prefKeyLastUpdated);

      if (cachedJson != null && cachedJson.isNotEmpty) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          if (entry.value is num && defaultRatesAgainstUsd.containsKey(entry.key)) {
            final rate = (entry.value as num).toDouble();
            if (rate > 0) {
              _currentRates[entry.key] = rate;
            }
          }
        }
      }

      if (timestampMs != null && timestampMs > 0) {
        _lastUpdatedAt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      }
    } catch (_) {
      // Graceful offline fallback: keep defaults untouched
    }
  }

  /// Automatically synchronizes latest exchange rates if internet is reachable.
  /// Throttled to [maxAge] (default 12 hours) unless [force] is true.
  /// Never throws: fails quietly and leaves existing rates intact on error or timeout.
  static Future<bool> syncRates({
    bool force = false,
    Duration maxAge = const Duration(hours: 12),
    String? overrideUrl,
  }) async {
    // 1. Throttling check
    if (!force && _lastUpdatedAt != null) {
      final elapsed = DateTime.now().difference(_lastUpdatedAt!);
      if (elapsed < maxAge) {
        return false; // Cached rates are fresh enough
      }
    }

    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
      final uri = Uri.parse(overrideUrl ?? liveApiEndpoint);
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 7));

      if (response.statusCode != 200) {
        return false;
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final data = jsonDecode(responseBody);

      if (data is Map<String, dynamic> && data['rates'] is Map) {
        final dynamicRates = data['rates'] as Map;
        bool anyUpdated = false;

        for (final code in supportedCurrencies) {
          final val = dynamicRates[code];
          if (val is num && val > 0) {
            _currentRates[code] = val.toDouble();
            anyUpdated = true;
          }
        }

        if (anyUpdated) {
          final now = DateTime.now();
          _lastUpdatedAt = now;
          await _persistRates(_currentRates, now);
          return true;
        }
      }
      return false;
    } catch (_) {
      // Network unreachable, DNS resolution failed, or timeout.
      // Silently return false to preserve offline resiliency.
      return false;
    } finally {
      client?.close();
    }
  }

  /// Persists current active rates to SharedPreferences
  static Future<void> _persistRates(Map<String, double> rates, DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyRates, jsonEncode(rates));
      await prefs.setInt(_prefKeyLastUpdated, timestamp.millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Manually applies custom rates (useful for testing or manual user overrides)
  static void applyRates(Map<String, double> rates, {DateTime? updatedAt}) {
    for (final entry in rates.entries) {
      if (defaultRatesAgainstUsd.containsKey(entry.key) && entry.value > 0) {
        _currentRates[entry.key] = entry.value;
      }
    }
    _lastUpdatedAt = updatedAt ?? DateTime.now();
  }

  /// Resets in-memory rates to default baseline
  static void resetToDefaults() {
    _currentRates
      ..clear()
      ..addAll(defaultRatesAgainstUsd);
    _lastUpdatedAt = null;
  }

  /// Converts an amount from one currency to another using normalized rates.
  /// If an unknown currency is supplied, it falls back gracefully to a 1:1 conversion.
  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    final from = fromCurrency.toUpperCase().trim();
    final to = toCurrency.toUpperCase().trim();

    if (from == to) return amount;

    final fromRate = ratesAgainstUsd[from];
    final toRate = ratesAgainstUsd[to];

    if (fromRate == null || toRate == null || fromRate <= 0) {
      return amount; // Fallback gracefully
    }

    // Amount in USD = amount / fromRate
    final amountInUsd = amount / fromRate;
    // Amount in target = amountInUsd * toRate
    final converted = amountInUsd * toRate;

    return converted;
  }

  /// Currency symbol helper delegating to canonical CurrencyFormatter
  static String getCurrencySymbol(String currencyCode) {
    return CurrencyFormatter.getSymbol(currencyCode.toUpperCase().trim());
  }

  /// Formats amount with proper symbol and decimal places
  static String format(double amount, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    final isWhole = (amount % 1) == 0;
    final formattedNumber = isWhole ? amount.toInt().toString() : amount.toStringAsFixed(2);
    return '$symbol$formattedNumber';
  }
}

/// Automatic Country and Native Currency detector based on device locale & language fallback
class CountryDetector {
  CountryDetector._();

  /// Language code to default ISO 3166-1 alpha-2 country fallback mapping
  static const Map<String, String> languageToCountryFallback = {
    'tr': 'TR',
    'en': 'US',
    'de': 'DE',
    'fr': 'FR',
    'ja': 'JP',
    'es': 'ES',
    'it': 'IT',
    'pt': 'BR',
    'ru': 'RU',
    'zh': 'CN',
    'ko': 'KR',
    'ar': 'AE',
    'hi': 'IN',
    'nl': 'NL',
    'pl': 'PL',
    'sv': 'SE',
    'th': 'TH',
    'vi': 'VN',
    'id': 'ID',
    'cs': 'CZ',
    'el': 'GR',
    'he': 'IL',
    'nb': 'NO',
    'nn': 'NO',
    'da': 'DK',
    'uk': 'UA',
    'hu': 'HU',
  };

  /// Detects country code from platformDispatcher.locale or fallback mapping
  static String detectCountryCode() {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final countryCode = locale.countryCode;
      if (countryCode != null && countryCode.trim().isNotEmpty) {
        return countryCode.trim().toUpperCase();
      }
      final lang = locale.languageCode.trim().toLowerCase();
      return languageToCountryFallback[lang] ?? 'US';
    } catch (_) {
      return 'US';
    }
  }

  /// Resolves detected country entity
  static Country detectCountry() {
    final code = detectCountryCode();
    return Country.findByCode(code) ?? Country.findByCode('US')!;
  }

  /// Resolves native currency code from detected country
  static String detectNativeCurrency() {
    return detectCountry().defaultCurrency;
  }

  /// Resolves native currency code for a given ISO country code
  static String getCurrencyForCountry(String countryCode) {
    final country = Country.findByCode(countryCode.trim().toUpperCase());
    return country?.defaultCurrency ?? 'USD';
  }

  /// Resolves ISO country code for a given language code fallback
  static String getCountryForLanguage(String languageCode) {
    return languageToCountryFallback[languageCode.trim().toLowerCase()] ?? 'US';
  }
}

/// StateNotifier controlling active application currency
class CurrencyNotifier extends StateNotifier<String> {
  final PreferencesService _prefs;

  CurrencyNotifier([PreferencesService? prefs])
      : _prefs = prefs ?? PreferencesService.instance,
        super(
          (prefs ?? PreferencesService.instance).getDefaultCurrency() ??
              CountryDetector.detectNativeCurrency(),
        );

  /// Loads currency for active user
  void loadForUser({String? uid}) {
    final saved = _prefs.getDefaultCurrency(uid: uid);
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    } else {
      final detected = CountryDetector.detectNativeCurrency();
      state = detected;
      _prefs.setDefaultCurrency(detected, uid: uid);
    }
  }

  /// Updates active currency
  Future<void> setCurrency(String currencyCode, {String? uid, bool isManual = true}) async {
    final code = currencyCode.toUpperCase().trim();
    state = code;
    await _prefs.setDefaultCurrency(code, uid: uid);
    if (isManual) {
      await _prefs.setUserSelectedCurrency(true, uid: uid);
    }
  }

  /// Resets to default detected currency
  Future<void> resetToDefault({String? uid}) async {
    final detected = CountryDetector.detectNativeCurrency();
    state = detected;
    await _prefs.setDefaultCurrency(detected, uid: uid);
    await _prefs.setUserSelectedCurrency(false, uid: uid);
  }
}

/// Global provider for active app currency
final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier();
});
