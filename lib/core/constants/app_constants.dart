/// Application-wide constants for PackBuddy
class AppConstants {
  static const String appName = 'PackBuddy';
  static const String appPackage = 'com.sleepyhead.packbuddy';
  static const String appVersion = '1.0.0';

  // Database Constants
  static const String databaseName = 'packbuddy.db';
  static const int databaseVersion = 1;

  // SQLite Table Names
  static const String tableTrips = 'trips';
  static const String tableExpenses = 'expenses';
  static const String tableDocuments = 'documents';
  static const String tableSyncMetadata = 'sync_metadata';

  // Shared Preferences Keys
  static const String prefKeyLocale = 'packbuddy_locale';
  static const String prefKeyThemeMode = 'packbuddy_theme_mode';
  static const String prefKeyDefaultCurrency = 'packbuddy_default_currency';
  static const String prefKeyLastSyncTime = 'packbuddy_last_sync_time';

  // Default Values
  static const String defaultCurrency = 'USD';
  static const String defaultLocale = 'tr';
}
