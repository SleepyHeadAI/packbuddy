/// Application-wide constants for PackBuddy
class AppConstants {
  static const String appName = 'PackBuddy';
  static const String appPackage = 'com.sleepyhead.packbuddy';
  static const String appVersion = '1.0.0';

  // Database Constants
  static const String databaseName = 'packbuddy.db';
  static const int databaseVersion = 9;

  // SQLite Table Names
  static const String tableTrips = 'trips';
  static const String tableExpenses = 'expenses';
  static const String tableDocuments = 'documents';
  static const String tableChecklistItems = 'checklist_items';
  static const String tableSyncMetadata = 'sync_metadata';


  // Default Values
  static const String defaultCurrency = 'USD';
  static const String defaultLocale = 'tr';
}
