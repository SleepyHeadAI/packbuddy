import 'package:intl/intl.dart';

/// Utility class to format multi-currency values cleanly across the application
class CurrencyFormatter {
  static final Map<String, String> currencySymbols = {
    'AED': 'د.إ',
    'ARS': r'ARS$',
    'AUD': r'A$',
    'BGN': 'лв',
    'BHD': 'BD',
    'BRL': r'R$',
    'CAD': r'CA$',
    'CHF': 'CHF',
    'CLP': r'CLP$',
    'CNY': '¥',
    'COP': r'COL$',
    'CZK': 'Kč',
    'DKK': 'kr',
    'EGP': 'E£',
    'EUR': '€',
    'GBP': '£',
    'GEL': '₾',
    'HKD': r'HK$',
    'HUF': 'Ft',
    'IDR': 'Rp',
    'ILS': '₪',
    'INR': '₹',
    'ISK': 'kr',
    'JOD': 'JD',
    'JPY': '¥',
    'KRW': '₩',
    'KWD': 'KD',
    'KZT': '₸',
    'MAD': 'MAD',
    'MXN': r'MX$',
    'MYR': 'RM',
    'NOK': 'kr',
    'NZD': r'NZ$',
    'OMR': 'OMR',
    'PEN': 'S/.',
    'PHP': '₱',
    'PKR': 'PKR',
    'PLN': 'zł',
    'QAR': 'QR',
    'RON': 'lei',
    'RSD': 'din',
    'SAR': '﷼',
    'SEK': 'kr',
    'SGD': r'S$',
    'THB': '฿',
    'TRY': '₺',
    'TWD': r'NT$',
    'USD': r'$',
    'VND': '₫',
    'ZAR': 'R',
  };

  static final Map<String, String> currencyNames = {
    'AED': 'UAE Dirham (AED)',
    'ARS': 'Argentine Peso (ARS)',
    'AUD': 'Australian Dollar (AUD)',
    'BGN': 'Bulgarian Lev (BGN)',
    'BHD': 'Bahraini Dinar (BHD)',
    'BRL': 'Brazilian Real (BRL)',
    'CAD': 'Canadian Dollar (CAD)',
    'CHF': 'Swiss Franc (CHF)',
    'CLP': 'Chilean Peso (CLP)',
    'CNY': 'Chinese Yuan (CNY)',
    'COP': 'Colombian Peso (COP)',
    'CZK': 'Czech Koruna (CZK)',
    'DKK': 'Danish Krone (DKK)',
    'EGP': 'Egyptian Pound (EGP)',
    'EUR': 'Euro (EUR)',
    'GBP': 'British Pound (GBP)',
    'GEL': 'Georgian Lari (GEL)',
    'HKD': 'Hong Kong Dollar (HKD)',
    'HUF': 'Hungarian Forint (HUF)',
    'IDR': 'Indonesian Rupiah (IDR)',
    'ILS': 'Israeli Shekel (ILS)',
    'INR': 'Indian Rupee (INR)',
    'ISK': 'Icelandic Krona (ISK)',
    'JOD': 'Jordanian Dinar (JOD)',
    'JPY': 'Japanese Yen (JPY)',
    'KRW': 'South Korean Won (KRW)',
    'KWD': 'Kuwaiti Dinar (KWD)',
    'KZT': 'Kazakhstani Tenge (KZT)',
    'MAD': 'Moroccan Dirham (MAD)',
    'MXN': 'Mexican Peso (MXN)',
    'MYR': 'Malaysian Ringgit (MYR)',
    'NOK': 'Norwegian Krone (NOK)',
    'NZD': 'New Zealand Dollar (NZD)',
    'OMR': 'Omani Rial (OMR)',
    'PEN': 'Peruvian Sol (PEN)',
    'PHP': 'Philippine Peso (PHP)',
    'PKR': 'Pakistani Rupee (PKR)',
    'PLN': 'Polish Zloty (PLN)',
    'QAR': 'Qatari Riyal (QAR)',
    'RON': 'Romanian Leu (RON)',
    'RSD': 'Serbian Dinar (RSD)',
    'SAR': 'Saudi Riyal (SAR)',
    'SEK': 'Swedish Krona (SEK)',
    'SGD': 'Singapore Dollar (SGD)',
    'THB': 'Thai Baht (THB)',
    'TRY': 'Türk Lirası (TRY)',
    'TWD': 'New Taiwan Dollar (TWD)',
    'USD': 'US Dollar (USD)',
    'VND': 'Vietnamese Dong (VND)',
    'ZAR': 'South African Rand (ZAR)',
  };

  static final Map<String, String> currencyFlags = {
    'AED': '🇦🇪',
    'ARS': '🇦🇷',
    'AUD': '🇦🇺',
    'BGN': '🇧🇬',
    'BHD': '🇧🇭',
    'BRL': '🇧🇷',
    'CAD': '🇨🇦',
    'CHF': '🇨🇭',
    'CLP': '🇨🇱',
    'CNY': '🇨🇳',
    'COP': '🇨🇴',
    'CZK': '🇨🇿',
    'DKK': '🇩🇰',
    'EGP': '🇪🇬',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'GEL': '🇬🇪',
    'HKD': '🇭🇰',
    'HUF': '🇭🇺',
    'IDR': '🇮🇩',
    'ILS': '🇮🇱',
    'INR': '🇮🇳',
    'ISK': '🇮🇸',
    'JOD': '🇯🇴',
    'JPY': '🇯🇵',
    'KRW': '🇰🇷',
    'KWD': '🇰🇼',
    'KZT': '🇰🇿',
    'MAD': '🇲🇦',
    'MXN': '🇲🇽',
    'MYR': '🇲🇾',
    'NOK': '🇳🇴',
    'NZD': '🇳🇿',
    'OMR': '🇴🇲',
    'PEN': '🇵🇪',
    'PHP': '🇵🇭',
    'PKR': '🇵🇰',
    'PLN': '🇵🇱',
    'QAR': '🇶🇦',
    'RON': '🇷🇴',
    'RSD': '🇷🇸',
    'SAR': '🇸🇦',
    'SEK': '🇸🇪',
    'SGD': '🇸🇬',
    'THB': '🇹🇭',
    'TRY': '🇹🇷',
    'TWD': '🇹🇼',
    'USD': '🇺🇸',
    'VND': '🇻🇳',
    'ZAR': '🇿🇦',
  };

  static final Map<String, String> cleanCurrencyNames = {
    'AED': 'UAE Dirham',
    'ARS': 'Argentine Peso',
    'AUD': 'Australian Dollar',
    'BGN': 'Bulgarian Lev',
    'BHD': 'Bahraini Dinar',
    'BRL': 'Brazilian Real',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CLP': 'Chilean Peso',
    'CNY': 'Chinese Yuan',
    'COP': 'Colombian Peso',
    'CZK': 'Czech Koruna',
    'DKK': 'Danish Krone',
    'EGP': 'Egyptian Pound',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'GEL': 'Georgian Lari',
    'HKD': 'Hong Kong Dollar',
    'HUF': 'Hungarian Forint',
    'IDR': 'Indonesian Rupiah',
    'ILS': 'Israeli Shekel',
    'INR': 'Indian Rupee',
    'ISK': 'Icelandic Krona',
    'JOD': 'Jordanian Dinar',
    'JPY': 'Japanese Yen',
    'KRW': 'South Korean Won',
    'KWD': 'Kuwaiti Dinar',
    'KZT': 'Kazakhstani Tenge',
    'MAD': 'Moroccan Dirham',
    'MXN': 'Mexican Peso',
    'MYR': 'Malaysian Ringgit',
    'NOK': 'Norwegian Krone',
    'NZD': 'New Zealand Dollar',
    'OMR': 'Omani Rial',
    'PEN': 'Peruvian Sol',
    'PHP': 'Philippine Peso',
    'PKR': 'Pakistani Rupee',
    'PLN': 'Polish Zloty',
    'QAR': 'Qatari Riyal',
    'RON': 'Romanian Leu',
    'RSD': 'Serbian Dinar',
    'SAR': 'Saudi Riyal',
    'SEK': 'Swedish Krona',
    'SGD': 'Singapore Dollar',
    'THB': 'Thai Baht',
    'TRY': 'Turkish Lira',
    'TWD': 'New Taiwan Dollar',
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
