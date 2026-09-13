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
  String get architecturePhase => 'Phase 2: Local DB & Two-Way Sync Ready';
}
