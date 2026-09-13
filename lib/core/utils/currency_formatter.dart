import 'package:intl/intl.dart';

/// Utility class to format multi-currency values cleanly across the application
class CurrencyFormatter {
  static final Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'TRY': '₺',
    'GBP': '£',
    'JPY': '¥',
    'CHF': 'CHF',
    'CAD': 'CA\$',
    'AUD': 'A\$',
  };

  /// Formats an amount with the corresponding currency symbol and locale formatting
  static String format(double amount, {String currency = 'USD', String locale = 'en'}) {
    final symbol = currencySymbols[currency] ?? currency;
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
}
