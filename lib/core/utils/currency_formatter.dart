import 'package:intl/intl.dart';

/// Utility class to format multi-currency values cleanly across the application
class CurrencyFormatter {
  static final Map<String, String> currencySymbols = {
    'TRY': '₺',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CHF': 'CHF',
    'CAD': 'CA\$',
    'AUD': 'A\$',
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
    'INR': '₹',
    'BRL': 'R\$',
    'KRW': '₩',
    'CNY': '¥',
    'AED': 'د.إ',
    'SAR': '﷼',
    'THB': '฿',
    'IDR': 'Rp',
    'VND': '₫',
    'MXN': 'MX\$',
    'SGD': 'S\$',
    'NZD': 'NZ\$',
    'CZK': 'Kč',
    'HUF': 'Ft',
    'ILS': '₪',
    'ZAR': 'R',
    'EGP': 'E£',
    'QAR': 'QR',
  };

  static final Map<String, String> currencyNames = {
    'TRY': 'Türk Lirası (TRY)',
    'USD': 'US Dollar (USD)',
    'EUR': 'Euro (EUR)',
    'GBP': 'British Pound (GBP)',
    'JPY': 'Japanese Yen (JPY)',
    'CHF': 'Swiss Franc (CHF)',
    'CAD': 'Canadian Dollar (CAD)',
    'AUD': 'Australian Dollar (AUD)',
    'SEK': 'Swedish Krona (SEK)',
    'NOK': 'Norwegian Krone (NOK)',
    'DKK': 'Danish Krone (DKK)',
    'PLN': 'Polish Zloty (PLN)',
    'INR': 'Indian Rupee (INR)',
    'BRL': 'Brazilian Real (BRL)',
    'KRW': 'South Korean Won (KRW)',
    'CNY': 'Chinese Yuan (CNY)',
    'AED': 'UAE Dirham (AED)',
    'SAR': 'Saudi Riyal (SAR)',
    'THB': 'Thai Baht (THB)',
    'IDR': 'Indonesian Rupiah (IDR)',
    'VND': 'Vietnamese Dong (VND)',
    'MXN': 'Mexican Peso (MXN)',
    'SGD': 'Singapore Dollar (SGD)',
    'NZD': 'New Zealand Dollar (NZD)',
    'CZK': 'Czech Koruna (CZK)',
    'HUF': 'Hungarian Forint (HUF)',
    'ILS': 'Israeli Shekel (ILS)',
    'ZAR': 'South African Rand (ZAR)',
    'EGP': 'Egyptian Pound (EGP)',
    'QAR': 'Qatari Riyal (QAR)',
  };

  static final Map<String, String> currencyFlags = {
    'AED': '🇦🇪',
    'AUD': '🇦🇺',
    'BRL': '🇧🇷',
    'CAD': '🇨🇦',
    'CHF': '🇨🇭',
    'CNY': '🇨🇳',
    'CZK': '🇨🇿',
    'DKK': '🇩🇰',
    'EGP': '🇪🇬',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'HUF': '🇭🇺',
    'IDR': '🇮🇩',
    'ILS': '🇮🇱',
    'INR': '🇮🇳',
    'JPY': '🇯🇵',
    'KRW': '🇰🇷',
    'MXN': '🇲🇽',
    'NOK': '🇳🇴',
    'NZD': '🇳🇿',
    'PLN': '🇵🇱',
    'QAR': '🇶🇦',
    'SAR': '🇸🇦',
    'SEK': '🇸🇪',
    'SGD': '🇸🇬',
    'THB': '🇹🇭',
    'TRY': '🇹🇷',
    'USD': '🇺🇸',
    'VND': '🇻🇳',
    'ZAR': '🇿🇦',
  };

  static final Map<String, String> cleanCurrencyNames = {
    'AED': 'UAE Dirham',
    'AUD': 'Australian Dollar',
    'BRL': 'Brazilian Real',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'CZK': 'Czech Koruna',
    'DKK': 'Danish Krone',
    'EGP': 'Egyptian Pound',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'HUF': 'Hungarian Forint',
    'IDR': 'Indonesian Rupiah',
    'ILS': 'Israeli Shekel',
    'INR': 'Indian Rupee',
    'JPY': 'Japanese Yen',
    'KRW': 'South Korean Won',
    'MXN': 'Mexican Peso',
    'NOK': 'Norwegian Krone',
    'NZD': 'New Zealand Dollar',
    'PLN': 'Polish Zloty',
    'QAR': 'Qatari Riyal',
    'SAR': 'Saudi Riyal',
    'SEK': 'Swedish Krona',
    'SGD': 'Singapore Dollar',
    'THB': 'Thai Baht',
    'TRY': 'Turkish Lira',
    'USD': 'US Dollar',
    'VND': 'Vietnamese Dong',
    'ZAR': 'South African Rand',
  };

  /// List of all supported ISO currency codes sorted alphabetically (A-Z)
  static List<String> get supportedCurrencies =>
      (List<String>.from(currencySymbols.keys)..sort());

  /// Formats an amount with the corresponding currency symbol and locale formatting
  static String format(double amount, {String currency = 'USD', String locale = 'en'}) {
    final symbol = currencySymbols[currency] ?? currency;
    if (amount.isNaN || amount.isInfinite) {
      return '$symbol 0';
    }
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return formatter.format(amount);
  }

  /// Returns symbol for given ISO currency code
  static String getSymbol(String currency) {
    return currencySymbols[currency] ?? currency;
  }

  /// Returns localized or full currency name
  static String getCurrencyName(String code) {
    return currencyNames[code] ?? code;
  }

  /// Returns flag emoji for given ISO currency code
  static String getFlag(String code) {
    return currencyFlags[code.toUpperCase().trim()] ?? '🌐';
  }

  /// Returns clean human-readable currency name without code suffix
  static String getCleanName(String code) {
    return cleanCurrencyNames[code.toUpperCase().trim()] ??
        (currencyNames[code.toUpperCase().trim()] ?? code);
  }

  /// Returns descriptive label with symbol and name
  static String getCurrencyLabel(String code) {
    final flag = getFlag(code);
    final symbol = getSymbol(code);
    final name = cleanCurrencyNames[code.toUpperCase().trim()] ?? (currencyNames[code] ?? code);
    return '$flag $code ($symbol) · $name';
  }
}
