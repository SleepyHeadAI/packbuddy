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

  /// List of all supported ISO currency codes
  static List<String> get supportedCurrencies => currencySymbols.keys.toList();

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

  /// Returns descriptive label with symbol and name
  static String getCurrencyLabel(String code) {
    final symbol = getSymbol(code);
    final name = currencyNames[code] ?? code;
    return '$symbol  $name';
  }
}
