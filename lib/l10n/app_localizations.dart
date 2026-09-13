import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'PackBuddy'**
  String get appName;

  /// Welcome message shown on the dashboard
  ///
  /// In en, this message translates to:
  /// **'Welcome to PackBuddy'**
  String get welcome;

  /// Subtitle underneath the welcome message
  ///
  /// In en, this message translates to:
  /// **'Minimalist, offline-first travel assistant & budget manager'**
  String get welcomeSubtitle;

  /// Label for budget feature
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Description of budget feature
  ///
  /// In en, this message translates to:
  /// **'Multi-currency travel expense tracking'**
  String get budgetDescription;

  /// Label for document vault feature
  ///
  /// In en, this message translates to:
  /// **'Document Vault'**
  String get vault;

  /// Description of vault feature
  ///
  /// In en, this message translates to:
  /// **'Passports, tickets and booking vouchers'**
  String get vaultDescription;

  /// Label for settings feature
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Description of settings feature
  ///
  /// In en, this message translates to:
  /// **'Preferences, backup and sync configuration'**
  String get settingsDescription;

  /// Badge showing offline-first readiness
  ///
  /// In en, this message translates to:
  /// **'Offline Ready'**
  String get offlineReady;

  /// Badge showing two-way sync readiness
  ///
  /// In en, this message translates to:
  /// **'Two-Way Cloud Sync'**
  String get syncReady;

  /// Status text while synchronizing
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncInProgress;

  /// Status text when synchronization is up to date
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get syncUpToDate;

  /// Status text when synchronization failed
  ///
  /// In en, this message translates to:
  /// **'Sync Failed'**
  String get syncFailed;

  /// Badge showing multi-currency feature
  ///
  /// In en, this message translates to:
  /// **'Multi-Currency'**
  String get multiCurrency;

  /// Header for trips screen
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// Button to add a new trip
  ///
  /// In en, this message translates to:
  /// **'Add Trip'**
  String get addTrip;

  /// Input field label for trip title
  ///
  /// In en, this message translates to:
  /// **'Trip Name'**
  String get tripName;

  /// Input field label for destination
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// Remaining budget label
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// Total spent amount label
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// Button to add an expense
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Expense amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Expense category dropdown label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Food category label
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get food;

  /// Transportation category label
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transport;

  /// Accommodation category label
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get accommodation;

  /// Entertainment category label
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// Other category label
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Start date label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// End date label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// Message when trips list is empty
  ///
  /// In en, this message translates to:
  /// **'No trips planned yet'**
  String get noTripsYet;

  /// Subtitle when trips list is empty
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add your first journey'**
  String get noTripsSubtitle;

  /// Message when expenses list is empty
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded yet'**
  String get noExpensesYet;

  /// Subtitle when expenses list is empty
  ///
  /// In en, this message translates to:
  /// **'Track your spendings by adding an expense'**
  String get noExpensesSubtitle;

  /// Delete trip action
  ///
  /// In en, this message translates to:
  /// **'Delete Trip'**
  String get deleteTrip;

  /// Confirmation message when deleting trip
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this trip?'**
  String get deleteTripConfirm;

  /// Delete expense action
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// Phase status indicator
  ///
  /// In en, this message translates to:
  /// **'Phase 3: Budget, Trips & Expenses Ready'**
  String get architecturePhase;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
