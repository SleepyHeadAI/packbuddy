import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('sv'),
    Locale('th'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh'),
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

  /// Add document button label
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get addDocument;

  /// Document name input label
  ///
  /// In en, this message translates to:
  /// **'Document Name'**
  String get documentName;

  /// Passport category label
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// Ticket category label
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticket;

  /// Booking voucher category label
  ///
  /// In en, this message translates to:
  /// **'Booking Voucher'**
  String get booking;

  /// Camera picker button
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get camera;

  /// Gallery picker button
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get gallery;

  /// View document title
  ///
  /// In en, this message translates to:
  /// **'View Document'**
  String get viewDocument;

  /// Message when vault is empty
  ///
  /// In en, this message translates to:
  /// **'No documents saved yet'**
  String get noDocumentsYet;

  /// Subtitle when vault is empty
  ///
  /// In en, this message translates to:
  /// **'Securely store your passports, tickets and reservations'**
  String get noDocumentsSubtitle;

  /// Delete document action
  ///
  /// In en, this message translates to:
  /// **'Delete Document'**
  String get deleteDocument;

  /// Confirmation message when deleting document
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this document?'**
  String get deleteDocumentConfirm;

  /// Theme settings label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// System default theme option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Manual sync button label
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Last sync time label
  ///
  /// In en, this message translates to:
  /// **'Last Sync'**
  String get lastSync;

  /// Upgrade to Pro banner text
  ///
  /// In en, this message translates to:
  /// **'Upgrade to PackBuddy Pro'**
  String get upgradeToPro;

  /// Pro badge label
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// Paywall title
  ///
  /// In en, this message translates to:
  /// **'PackBuddy Pro'**
  String get proTitle;

  /// Paywall subtitle
  ///
  /// In en, this message translates to:
  /// **'Unlock limitless travel and ultimate peace of mind'**
  String get proSubtitle;

  /// Pro feature 1 description
  ///
  /// In en, this message translates to:
  /// **'Unlimited Trips & Expense Tracking'**
  String get proFeature1;

  /// Pro feature 2 description
  ///
  /// In en, this message translates to:
  /// **'Unlimited Document Vault Storage'**
  String get proFeature2;

  /// Pro feature 3 description
  ///
  /// In en, this message translates to:
  /// **'Automatic Two-Way Cloud Sync'**
  String get proFeature3;

  /// Monthly subscription label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Annual subscription label
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// Annual discount badge
  ///
  /// In en, this message translates to:
  /// **'Save 33%'**
  String get annualSave;

  /// Subscription button label
  ///
  /// In en, this message translates to:
  /// **'Continue with Pro'**
  String get subscribeNow;

  /// Purchase success message
  ///
  /// In en, this message translates to:
  /// **'Welcome to PackBuddy Pro!'**
  String get purchaseSuccess;

  /// Phase status indicator
  ///
  /// In en, this message translates to:
  /// **'Phase 5: Full Product & 20 Languages Ready'**
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
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'el',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'ru',
    'sv',
    'th',
    'tr',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
