// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PackBuddy';

  @override
  String get welcome => 'Welcome to PackBuddy';

  @override
  String get welcomeSubtitle =>
      'Minimalist, offline-first travel assistant & budget manager';

  @override
  String get budget => 'Budget';

  @override
  String get budgetDescription => 'Multi-currency travel expense tracking';

  @override
  String get vault => 'Document Vault';

  @override
  String get vaultDescription => 'Passports, tickets and booking vouchers';

  @override
  String get settings => 'Settings';

  @override
  String get settingsDescription =>
      'Preferences, backup and sync configuration';

  @override
  String get offlineReady => 'Offline Ready';

  @override
  String get syncReady => 'Two-Way Cloud Sync';

  @override
  String get syncInProgress => 'Syncing...';

  @override
  String get syncUpToDate => 'Up to date';

  @override
  String get syncFailed => 'Sync Failed';

  @override
  String get multiCurrency => 'Multi-Currency';

  @override
  String get trips => 'Trips';

  @override
  String get addTrip => 'Add Trip';

  @override
  String get tripName => 'Trip Name';

  @override
  String get destination => 'Destination';

  @override
  String get remaining => 'Remaining';

  @override
  String get spent => 'Spent';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get food => 'Food & Dining';

  @override
  String get transport => 'Transportation';

  @override
  String get accommodation => 'Accommodation';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get other => 'Other';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get date => 'Date';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get noTripsYet => 'No trips planned yet';

  @override
  String get noTripsSubtitle =>
      'Tap the button below to add your first journey';

  @override
  String get noExpensesYet => 'No expenses recorded yet';

  @override
  String get noExpensesSubtitle => 'Track your spendings by adding an expense';

  @override
  String get deleteTrip => 'Delete Trip';

  @override
  String get deleteTripConfirm => 'Are you sure you want to delete this trip?';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get architecturePhase => 'Phase 3: Budget, Trips & Expenses Ready';
}
