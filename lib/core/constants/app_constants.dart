/// Application-wide constants for PackBuddy
class AppConstants {
  static const String appName = 'PackBuddy';

  /// v1.0: joining a trip by invite code (self-join) is disabled. Firestore rules (B1) only let
  /// the trip owner change `collaborators`; a secure server-side join needs a Cloud Function.
  /// Owners add collaborators from the share sheet instead.
  static const bool kInviteCodeJoinEnabled = false;
  static const String appPackage = 'com.sleepyhead.packbuddy';
  static const String appVersion = '1.0.0';

  // Database Constants
  static const String databaseName = 'packbuddy.db';
  static const int databaseVersion = 16;

  // SQLite Table Names
  static const String tableTrips = 'trips';
  static const String tableExpenses = 'expenses';
  static const String tableDocuments = 'documents';
  static const String tableChecklistItems = 'checklist_items';
  static const String tableSyncMetadata = 'sync_metadata';
  static const String tableTravelMap = 'travel_map';
  static const String tableItineraryItems = 'itinerary_items';


  // Default Values
  static const String defaultCurrency = 'USD';
  static const String defaultLocale = 'tr';
}
