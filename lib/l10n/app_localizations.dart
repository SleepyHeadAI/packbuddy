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

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning, Traveler ☀️'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, Traveler ✈️'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening, Traveler 🌙'**
  String get goodEvening;

  /// All category filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// Clothing category
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get categoryClothing;

  /// Electronics category
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// Toiletries category
  ///
  /// In en, this message translates to:
  /// **'Toiletries'**
  String get categoryToiletries;

  /// Documents category
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get categoryDocuments;

  /// Accessories category
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get categoryAccessories;

  /// Item deleted snackbar label
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get deleted;

  /// Undo action label
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// Luggage checklist screen title
  ///
  /// In en, this message translates to:
  /// **'Luggage & Checklist'**
  String get luggageAndChecklist;

  /// Packing templates label
  ///
  /// In en, this message translates to:
  /// **'Smart Packing Templates'**
  String get smartPackingTemplates;

  /// Airline baggage guide title
  ///
  /// In en, this message translates to:
  /// **'Airline Baggage Guide'**
  String get airlineBaggageGuide;

  /// Vault locked status
  ///
  /// In en, this message translates to:
  /// **'Vault is Locked'**
  String get vaultLocked;

  /// Unlock vault action
  ///
  /// In en, this message translates to:
  /// **'Unlock Vault'**
  String get unlockVault;

  /// Security settings section
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Upcoming trip badge
  ///
  /// In en, this message translates to:
  /// **'Upcoming Route'**
  String get upcomingRoute;

  /// Ongoing trip badge
  ///
  /// In en, this message translates to:
  /// **'Ongoing Trip'**
  String get ongoingTrip;

  /// Offline vault stat label
  ///
  /// In en, this message translates to:
  /// **'Offline Vault'**
  String get offlineVault;

  /// Empty items state
  ///
  /// In en, this message translates to:
  /// **'No items added yet'**
  String get noItemsYet;

  /// Items packed status
  ///
  /// In en, this message translates to:
  /// **'items ready'**
  String get itemsReady;

  /// Empty list badge
  ///
  /// In en, this message translates to:
  /// **'EMPTY LIST'**
  String get listEmpty;

  /// Quick actions section header
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get quickActions;

  /// Add packing item button
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// Recent items section header
  ///
  /// In en, this message translates to:
  /// **'RECENTLY ADDED ITEMS'**
  String get recentlyAdded;

  /// Travel assistant section header
  ///
  /// In en, this message translates to:
  /// **'TRAVEL ASSISTANT'**
  String get travelAssistant;

  /// View all items link
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Notification snackbar
  ///
  /// In en, this message translates to:
  /// **'All travel notifications are up to date!'**
  String get allNotificationsUpToDate;

  /// Empty trips banner subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your first route and budget now.'**
  String get createFirstTrip;

  /// Edit trip sheet title
  ///
  /// In en, this message translates to:
  /// **'Edit Trip'**
  String get editTrip;

  /// Edit expense sheet title
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// Expense title input label
  ///
  /// In en, this message translates to:
  /// **'Expense / Transaction Title'**
  String get expenseTitle;

  /// Expense title input hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Dinner, Metro Ticket, Coffee...'**
  String get expenseTitleHint;

  /// Expense title validator error
  ///
  /// In en, this message translates to:
  /// **'Please enter an expense or transaction title'**
  String get pleaseEnterExpenseTitle;

  /// Custom category input label
  ///
  /// In en, this message translates to:
  /// **'Custom Category Name'**
  String get customCategoryName;

  /// Custom category input hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Souvenir, Tip, Museum, Visa, Gas...'**
  String get customCategoryHint;

  /// Custom category validator error
  ///
  /// In en, this message translates to:
  /// **'Please enter custom category name'**
  String get pleaseEnterCustomCategory;

  /// Payment method header
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Cash payment option
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// Credit card payment option
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// Debit card payment option
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get debitCard;

  /// Online payment option
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get onlinePayment;

  /// Custom transport option
  ///
  /// In en, this message translates to:
  /// **'Custom Transport'**
  String get customTransport;

  /// Add custom transport button
  ///
  /// In en, this message translates to:
  /// **'+ Custom Transport'**
  String get addCustomTransport;

  /// Itinerary stops label
  ///
  /// In en, this message translates to:
  /// **'Itinerary Stops'**
  String get itineraryStops;

  /// Destination field hint
  ///
  /// In en, this message translates to:
  /// **'Destination city or country'**
  String get destinationHint;

  /// Luggage & checklist tooltip
  ///
  /// In en, this message translates to:
  /// **'Luggage & Checklist'**
  String get baggageAndChecklist;

  /// Travel documents tooltip
  ///
  /// In en, this message translates to:
  /// **'Travel Documents'**
  String get travelDocuments;

  /// Currency sync banner
  ///
  /// In en, this message translates to:
  /// **'Exchange rates automatically synchronized'**
  String get currencySynced;

  /// Offline rates banner
  ///
  /// In en, this message translates to:
  /// **'Offline reference rates active (Auto-syncs online)'**
  String get offlineRatesActive;

  /// Vault pin setup description
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN code to keep your documents secure.'**
  String get createPinToProtect;

  /// Vault pin setup button
  ///
  /// In en, this message translates to:
  /// **'Create PIN & Protect'**
  String get createPinAndProtect;

  /// Skip pin button
  ///
  /// In en, this message translates to:
  /// **'Continue Unlocked for Now'**
  String get continueUnlocked;

  /// Vault settings pin change title
  ///
  /// In en, this message translates to:
  /// **'Change or Remove PIN Code'**
  String get changeOrRemovePin;

  /// Vault settings pin set title
  ///
  /// In en, this message translates to:
  /// **'Set Vault PIN Code'**
  String get setVaultPin;

  /// Boarding pass category
  ///
  /// In en, this message translates to:
  /// **'Boarding Pass & Travel Pass'**
  String get boardingPassAndPass;

  /// Vault encryption badge
  ///
  /// In en, this message translates to:
  /// **'Offline & Encrypted'**
  String get offlineAndEncrypted;

  /// Search items button
  ///
  /// In en, this message translates to:
  /// **'Search items'**
  String get searchItems;

  /// Close search button
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// Templates button
  ///
  /// In en, this message translates to:
  /// **'Ready Templates'**
  String get readyTemplates;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search item name or tag (e.g. carry-on, headphones)...'**
  String get searchItemsHint;

  /// Empty search results message
  ///
  /// In en, this message translates to:
  /// **'No matching items found'**
  String get noMatchingItems;

  /// Empty checklist message
  ///
  /// In en, this message translates to:
  /// **'Checklist is empty'**
  String get checklistEmpty;

  /// Empty checklist subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first item for your trip'**
  String get addFirstItem;

  /// Checklist completion status
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completed;

  /// Budget limit field label
  ///
  /// In en, this message translates to:
  /// **'Budget Limit'**
  String get budgetLimit;

  /// Change action label
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Set action label
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// Notifications button tooltip
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Plan trip button
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// Checklist preparing status
  ///
  /// In en, this message translates to:
  /// **'PREPARING'**
  String get preparing;

  /// Trips planned counter label
  ///
  /// In en, this message translates to:
  /// **'trips planned'**
  String get tripsPlanned;

  /// Documents saved counter label
  ///
  /// In en, this message translates to:
  /// **'saved documents & tickets'**
  String get documentsSaved;

  /// Standard luggage limit note
  ///
  /// In en, this message translates to:
  /// **'Standard Limit: Cabin 8 kg • Checked 20-23 kg'**
  String get standardBaggageLimitNote;

  /// Airline baggage limits button
  ///
  /// In en, this message translates to:
  /// **'Airline Limits'**
  String get airlineBaggageLimits;

  /// Compartment breakdown title
  ///
  /// In en, this message translates to:
  /// **'Compartment Breakdown'**
  String get compartmentBreakdown;

  /// Smart packing tip banner
  ///
  /// In en, this message translates to:
  /// **'Tip: Rolling clothes instead of folding them saves 30% space.'**
  String get packingTip;

  /// Empty search subtitle
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or category'**
  String get tryDifferentKeyword;

  /// Luggage guide title
  ///
  /// In en, this message translates to:
  /// **'Luggage Preparation & Baggage Guide'**
  String get luggagePreparationGuide;

  /// Luggage weight disclaimer
  ///
  /// In en, this message translates to:
  /// **'⚖️ Weighing responsibility belongs to traveler. Weight calculation is not active.'**
  String get weighingResponsibilityNote;

  /// Digital wallet payment method
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet'**
  String get digitalWallet;

  /// Flight transport mode
  ///
  /// In en, this message translates to:
  /// **'Flight'**
  String get flight;

  /// High-speed train transport mode
  ///
  /// In en, this message translates to:
  /// **'High-Speed Train'**
  String get bulletTrain;

  /// Train transport mode
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get train;

  /// Car transport mode
  ///
  /// In en, this message translates to:
  /// **'Car / Rental'**
  String get car;

  /// Bus transport mode
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get bus;

  /// Ferry transport mode
  ///
  /// In en, this message translates to:
  /// **'Ferry / Ship'**
  String get ferry;

  /// Motorcycle transport mode
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// Camper transport mode
  ///
  /// In en, this message translates to:
  /// **'Camper / RV'**
  String get camper;

  /// Bicycle transport mode
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get bicycle;

  /// Subway transport mode
  ///
  /// In en, this message translates to:
  /// **'Subway / Tram'**
  String get subway;

  /// Hiking transport mode
  ///
  /// In en, this message translates to:
  /// **'Hiking / Trekking'**
  String get hiking;

  /// Transport mode label
  ///
  /// In en, this message translates to:
  /// **'Transport Mode'**
  String get transportMode;

  /// Custom transport dialog title
  ///
  /// In en, this message translates to:
  /// **'Custom Transport Type'**
  String get customTransportType;

  /// Custom transport field label
  ///
  /// In en, this message translates to:
  /// **'Vehicle / Transport Mode'**
  String get customTransportVehicle;

  /// Custom transport field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Helicopter, Yacht, Cable Car, Safari...'**
  String get customTransportHint;

  /// Itinerary stop input hint
  ///
  /// In en, this message translates to:
  /// **'Enter city or stop (e.g. Paris, Rome, Tokyo)...'**
  String get cityOrStopHint;

  /// Itinerary stops header
  ///
  /// In en, this message translates to:
  /// **'Travel Route / Stops'**
  String get travelRouteOrStops;

  /// Add country button
  ///
  /// In en, this message translates to:
  /// **'Add Country'**
  String get addCountry;

  /// Trip name input hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Italy Tour, Summer Vacation...'**
  String get tripNameHint;

  /// Trip notes field label
  ///
  /// In en, this message translates to:
  /// **'Trip Notes (Hotel, Reservation, Route...)'**
  String get tripNotesLabel;

  /// Trip notes field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Hotel check-in 14:00, don\'t forget passports...'**
  String get tripNotesHint;

  /// Change currency tooltip
  ///
  /// In en, this message translates to:
  /// **'Change Currency'**
  String get changeCurrency;

  /// Expense note field label
  ///
  /// In en, this message translates to:
  /// **'Expense Note (Details, Receipt No...)'**
  String get expenseNotesLabel;

  /// Expense note field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Dinner including tip...'**
  String get expenseNotesHint;

  /// Wrong PIN snackbar error
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN! Please try again.'**
  String get wrongPinTryAgain;

  /// 4-digit PIN input label
  ///
  /// In en, this message translates to:
  /// **'4-Digit PIN'**
  String get fourDigitPin;

  /// Save PIN and open vault button
  ///
  /// In en, this message translates to:
  /// **'Save & Unlock'**
  String get saveAndOpen;

  /// Vault lock subtitle when PIN is set
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN code to access your passports and travel documents'**
  String get enterPinToUnlockVault;

  /// Vault lock subtitle when no PIN
  ///
  /// In en, this message translates to:
  /// **'Your vault is not yet protected with a PIN code'**
  String get vaultNotProtectedWithPin;

  /// Last completed trip badge
  ///
  /// In en, this message translates to:
  /// **'Last Trip'**
  String get lastTrip;

  /// OK dialog button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Custom prefix label
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Generic add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Generic close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Generic delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Generic edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Tickets category label
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// ID & Passport category label
  ///
  /// In en, this message translates to:
  /// **'ID & Passport'**
  String get idAndPassport;

  /// Health & Insurance category label
  ///
  /// In en, this message translates to:
  /// **'Health & Insurance'**
  String get healthAndInsurance;

  /// Other Documents category label
  ///
  /// In en, this message translates to:
  /// **'Other Documents'**
  String get otherDocuments;

  /// All Documents filter label
  ///
  /// In en, this message translates to:
  /// **'All Documents'**
  String get allDocuments;

  /// All Tickets filter label
  ///
  /// In en, this message translates to:
  /// **'All Tickets'**
  String get allTickets;

  /// Flight Tickets filter label
  ///
  /// In en, this message translates to:
  /// **'Flight Tickets'**
  String get flightTickets;

  /// Bus Tickets filter label
  ///
  /// In en, this message translates to:
  /// **'Bus Tickets'**
  String get busTickets;

  /// Ferry / Boat filter label
  ///
  /// In en, this message translates to:
  /// **'Ferry / Boat'**
  String get ferryBoat;

  /// Train Tickets filter label
  ///
  /// In en, this message translates to:
  /// **'Train Tickets'**
  String get trainTickets;

  /// All Trips filter label
  ///
  /// In en, this message translates to:
  /// **'All Trips'**
  String get allTrips;

  /// General scope filter label
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// General Document dropdown option
  ///
  /// In en, this message translates to:
  /// **'🌐 General Document (All Trips)'**
  String get generalDocumentAllTrips;

  /// Document Scope field label
  ///
  /// In en, this message translates to:
  /// **'Document Scope / Trip'**
  String get documentScope;

  /// Document note field label
  ///
  /// In en, this message translates to:
  /// **'Document Note (PNR, Seat, Expiry...)'**
  String get documentNotesLabel;

  /// Document note field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. PNR: TK7890, Seat: 12A, Terminal 2'**
  String get documentNotesHint;

  /// Upload document section header
  ///
  /// In en, this message translates to:
  /// **'Upload Document (Photo or PDF)'**
  String get uploadDocumentPrompt;

  /// PDF or file picker button
  ///
  /// In en, this message translates to:
  /// **'PDF / File'**
  String get pdfOrFile;

  /// Ticket sub-category header
  ///
  /// In en, this message translates to:
  /// **'Ticket Type / Sub-Category'**
  String get ticketTypeSubCategory;

  /// Document name input hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Airline Ticket, Hotel Booking...'**
  String get documentNameHint;

  /// Flight ticket sub-category
  ///
  /// In en, this message translates to:
  /// **'Flight Ticket'**
  String get flightTicket;

  /// Bus ticket sub-category
  ///
  /// In en, this message translates to:
  /// **'Bus Ticket'**
  String get busTicket;

  /// Ferry ticket sub-category
  ///
  /// In en, this message translates to:
  /// **'Ferry / Boat Ticket'**
  String get ferryTicket;

  /// Train ticket sub-category
  ///
  /// In en, this message translates to:
  /// **'Train Ticket'**
  String get trainTicket;

  /// Other transport sub-category
  ///
  /// In en, this message translates to:
  /// **'Other Transport'**
  String get otherTransport;

  /// Default passport document title
  ///
  /// In en, this message translates to:
  /// **'My Passport'**
  String get myPassport;

  /// Default hotel reservation title
  ///
  /// In en, this message translates to:
  /// **'Hotel Reservation'**
  String get hotelBooking;

  /// Main category label
  ///
  /// In en, this message translates to:
  /// **'Main Category'**
  String get mainCategory;

  /// Boarding pass preview title
  ///
  /// In en, this message translates to:
  /// **'Boarding Pass & Transit Pass'**
  String get boardingPassAndTransit;

  /// Boarding pass preview subtitle
  ///
  /// In en, this message translates to:
  /// **'View document or open in device app'**
  String get boardingPassSubtitle;

  /// View document action button
  ///
  /// In en, this message translates to:
  /// **'View Document'**
  String get viewDocumentAction;

  /// File not found snackbar message
  ///
  /// In en, this message translates to:
  /// **'File not found in local storage yet.'**
  String get fileNotFoundLocally;

  /// Open in device app action button
  ///
  /// In en, this message translates to:
  /// **'Open in Device App'**
  String get openInExternalApp;

  /// Secure badge text
  ///
  /// In en, this message translates to:
  /// **'SECURE'**
  String get secureBadge;

  /// Saved document counter label
  ///
  /// In en, this message translates to:
  /// **'Saved Document'**
  String get savedDocument;

  /// Ready badge text
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get readyBadge;

  /// Pinned badge text
  ///
  /// In en, this message translates to:
  /// **'PINNED'**
  String get pinnedBadge;

  /// Passport slot title
  ///
  /// In en, this message translates to:
  /// **'Passport Slot'**
  String get passportSlot;

  /// Save passport prompt
  ///
  /// In en, this message translates to:
  /// **'+ Save Your Passport'**
  String get saveYourPassport;

  /// Tap to view hint
  ///
  /// In en, this message translates to:
  /// **'Tap to view'**
  String get tapToView;

  /// Quick upload hint
  ///
  /// In en, this message translates to:
  /// **'Quick upload'**
  String get quickUpload;

  /// Empty state for vault filter
  ///
  /// In en, this message translates to:
  /// **'No documents found matching this filter'**
  String get noDocumentsForFilter;

  /// PDF file indicator badge
  ///
  /// In en, this message translates to:
  /// **'PDF FILE'**
  String get pdfFileBadge;

  /// PDF badge text
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfBadge;

  /// Image badge text
  ///
  /// In en, this message translates to:
  /// **'IMAGE'**
  String get imageBadge;

  /// Add to wallet button
  ///
  /// In en, this message translates to:
  /// **'+ Wallet'**
  String get addToWallet;

  /// Boarding pass options tooltip
  ///
  /// In en, this message translates to:
  /// **'Boarding Pass Options'**
  String get boardingPassOptions;

  /// Open PDF tooltip
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get openPdf;

  /// Vault PIN protection title
  ///
  /// In en, this message translates to:
  /// **'Vault PIN Protection'**
  String get vaultPinProtection;

  /// PIN protection active subtitle
  ///
  /// In en, this message translates to:
  /// **'PIN protection active'**
  String get pinProtectionActive;

  /// Unprotected subtitle
  ///
  /// In en, this message translates to:
  /// **'Unprotected (Set a PIN)'**
  String get unprotectedSetPin;

  /// Set up button text
  ///
  /// In en, this message translates to:
  /// **'Set Up'**
  String get setup;

  /// Change PIN dialog description
  ///
  /// In en, this message translates to:
  /// **'Enter a new 4-digit PIN or remove the existing PIN code.'**
  String get changePinDescription;

  /// Set PIN dialog description
  ///
  /// In en, this message translates to:
  /// **'Enter a 4-digit PIN to protect your passports and documents in the vault.'**
  String get setPinDescription;

  /// Remove PIN button label
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get removePin;

  /// PackBuddy Pro active status
  ///
  /// In en, this message translates to:
  /// **'PackBuddy Pro Active'**
  String get proActive;

  /// Annual plan label
  ///
  /// In en, this message translates to:
  /// **'Annual Plan (\$39.99/yr)'**
  String get annualPlan;

  /// Monthly plan label
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan (\$4.99/mo)'**
  String get monthlyPlan;

  /// Active subscription plan label
  ///
  /// In en, this message translates to:
  /// **'Subscription Plan'**
  String get activePlanLabel;

  /// Edit item sheet title
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// Add new item sheet title
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// Item name field label
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// Item name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Waterproof Jacket, Headphones...'**
  String get itemNameHint;

  /// Item name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter an item name'**
  String get pleaseEnterItemName;

  /// Carry type field label
  ///
  /// In en, this message translates to:
  /// **'Carry Type'**
  String get carryType;

  /// Compartment field label
  ///
  /// In en, this message translates to:
  /// **'Compartment / Location'**
  String get compartment;

  /// Pieces / units suffix
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get pieces;

  /// Add to baggage button
  ///
  /// In en, this message translates to:
  /// **'Add to Baggage'**
  String get addToBaggage;

  /// Item updated snackbar text
  ///
  /// In en, this message translates to:
  /// **'updated.'**
  String get itemUpdated;

  /// Item added to baggage snackbar text
  ///
  /// In en, this message translates to:
  /// **'added to baggage.'**
  String get itemAddedToBaggage;

  /// Marked as packed accessibility label
  ///
  /// In en, this message translates to:
  /// **'Marked as packed'**
  String get markedAsPacked;

  /// Not packed accessibility label
  ///
  /// In en, this message translates to:
  /// **'Not packed'**
  String get notPacked;

  /// Packed swipe label
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get packed;

  /// Smart templates subtitle
  ///
  /// In en, this message translates to:
  /// **'Transfer curated travel packing lists to your baggage in one tap'**
  String get smartTemplatesSubtitle;

  /// Items count label
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsCount;

  /// Curated travel package tag
  ///
  /// In en, this message translates to:
  /// **'Curated Travel Package'**
  String get readyTravelPackage;

  /// Contents list header
  ///
  /// In en, this message translates to:
  /// **'Contents List:'**
  String get contentList;

  /// Template import success message
  ///
  /// In en, this message translates to:
  /// **'items added from template! 🎉'**
  String get templateImportSuccess;

  /// Add template to baggage button
  ///
  /// In en, this message translates to:
  /// **'Add to Baggage'**
  String get addTemplateToBaggage;

  /// Current baggage limit label
  ///
  /// In en, this message translates to:
  /// **'Current Limit'**
  String get currentLimit;

  /// Search airline input hint
  ///
  /// In en, this message translates to:
  /// **'Search airline or code (e.g. THY, PC, LH)...'**
  String get searchAirlineOrCode;

  /// Active limit badge
  ///
  /// In en, this message translates to:
  /// **'Active Limit'**
  String get activeLimit;

  /// Cabin baggage label
  ///
  /// In en, this message translates to:
  /// **'Cabin Baggage'**
  String get cabinBaggage;

  /// Checked baggage label
  ///
  /// In en, this message translates to:
  /// **'Checked Baggage'**
  String get checkedBaggage;

  /// Standard economy baggage note
  ///
  /// In en, this message translates to:
  /// **'Standard Economy'**
  String get standardEconomy;

  /// Limit selected button text
  ///
  /// In en, this message translates to:
  /// **'This Limit Selected'**
  String get limitSelected;

  /// Apply cabin limit button text
  ///
  /// In en, this message translates to:
  /// **'Apply Cabin Limit'**
  String get applyCabinLimit;

  /// Baggage limit set snackbar message
  ///
  /// In en, this message translates to:
  /// **'Baggage limit set to'**
  String get baggageLimitSet;

  /// Lock vault button tooltip
  ///
  /// In en, this message translates to:
  /// **'Lock Vault'**
  String get lockVault;

  /// Bottom nav home label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav trips label
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get navTrips;

  /// Bottom nav baggage label
  ///
  /// In en, this message translates to:
  /// **'Luggage'**
  String get navBaggage;

  /// Bottom nav vault label
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get navVault;

  /// Bottom nav settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Prompt to select an airline and customize limits
  ///
  /// In en, this message translates to:
  /// **'Tap to customize limits for your airline'**
  String get selectAirlineToCustomize;

  /// Button to change current airline limit
  ///
  /// In en, this message translates to:
  /// **'Change Airline'**
  String get changeAirlineLimit;

  /// Header title for country and route selection sheet
  ///
  /// In en, this message translates to:
  /// **'Select Country & Route'**
  String get selectCountryAndRoute;

  /// Label for count of countries
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countriesLabel;

  /// Hint text for country search field
  ///
  /// In en, this message translates to:
  /// **'Search country or city (e.g. Italy, Tokyo, Paris)...'**
  String get searchCountryOrCity;

  /// Empty state text when no country matches search
  ///
  /// In en, this message translates to:
  /// **'No matching country found'**
  String get noMatchingCountry;

  /// Active subscription status badge
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeStatus;

  /// Subtitle on Auth screen during sign in
  ///
  /// In en, this message translates to:
  /// **'Your Luxury Travel Companion • Sign In'**
  String get authSubtitleSignIn;

  /// Subtitle on Auth screen during sign up
  ///
  /// In en, this message translates to:
  /// **'Begin a New Journey • Create Account'**
  String get authSubtitleSignUp;

  /// Tab/button label for sign in
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// Tab/button label for sign up
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmail;

  /// Hint for email field
  ///
  /// In en, this message translates to:
  /// **'traveler@packbuddy.com'**
  String get authEmailHint;

  /// Validation message when email is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get authEmailRequired;

  /// Validation message when email is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authEmailInvalid;

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Button to trigger forgot password dialog
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// Validation message when password is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get authPasswordRequired;

  /// Validation message when password fails rules
  ///
  /// In en, this message translates to:
  /// **'Password does not meet requirements.'**
  String get authPasswordRulesInvalid;

  /// Validation message for sign in password length
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authPasswordMinChars;

  /// Header for password requirements checklist
  ///
  /// In en, this message translates to:
  /// **'Password Requirements:'**
  String get authPasswordRulesTitle;

  /// Rule requirement: min 8 characters
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authRuleMinChars;

  /// Rule requirement: at least 1 uppercase letter
  ///
  /// In en, this message translates to:
  /// **'At least 1 uppercase letter'**
  String get authRuleUppercase;

  /// Rule requirement: at least 1 lowercase letter
  ///
  /// In en, this message translates to:
  /// **'At least 1 lowercase letter'**
  String get authRuleLowercase;

  /// Rule requirement: at least 1 digit
  ///
  /// In en, this message translates to:
  /// **'At least 1 number'**
  String get authRuleDigit;

  /// Label for password confirmation field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// Validation message when confirm password is empty
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get authConfirmPasswordRequired;

  /// Validation message when passwords do not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordsDoNotMatch;

  /// Primary action button to create account
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// Divider text between email and social login
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// Button to sign in with Google
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// Terms of service and privacy policy disclaimer
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our Terms of Service & Privacy Policy.'**
  String get authTermsNotice;

  /// Dialog title for password reset
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPasswordTitle;

  /// Dialog description for password reset
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address to receive a password reset link.'**
  String get authResetPasswordDescription;

  /// Button to send password reset link
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get authSendLink;

  /// Snackbar notification after sending password reset link
  ///
  /// In en, this message translates to:
  /// **'Password reset link has been sent to your email.'**
  String get authResetLinkSent;

  /// Placeholder notification for Apple sign in
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple will be available in the upcoming update!'**
  String get authAppleComingSoon;

  /// Title on email verification screen
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get emailVerifyTitle;

  /// Subtitle on email verification screen
  ///
  /// In en, this message translates to:
  /// **'To protect your travel vault and sync your trips, please verify your email address.'**
  String get emailVerifySubtitle;

  /// Header for email verification steps
  ///
  /// In en, this message translates to:
  /// **'What should you do?'**
  String get emailVerifyInstructionsTitle;

  /// Step 1 of email verification
  ///
  /// In en, this message translates to:
  /// **'Check your inbox and spam folder.'**
  String get emailVerifyStep1;

  /// Step 2 of email verification
  ///
  /// In en, this message translates to:
  /// **'Click the verification link in the email.'**
  String get emailVerifyStep2;

  /// Step 3 of email verification
  ///
  /// In en, this message translates to:
  /// **'Wait a few seconds; this screen will proceed automatically.'**
  String get emailVerifyStep3;

  /// Indicator text while waiting for email verification
  ///
  /// In en, this message translates to:
  /// **'Waiting for verification...'**
  String get emailVerifyWaiting;

  /// Manual check button on email verification screen
  ///
  /// In en, this message translates to:
  /// **'I Verified, Continue'**
  String get emailVerifyCheckNow;

  /// Button to resend email verification link
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get emailVerifyResendLink;

  /// Cooldown timer text for resending verification email
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String emailVerifyResendCooldown(int seconds);

  /// Button to sign out and return to sign in
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get emailVerifyBackToSignIn;

  /// Snackbar message when email is still unverified
  ///
  /// In en, this message translates to:
  /// **'Email is not verified yet. Please check your inbox and click the link.'**
  String get emailVerifyNotVerifiedYet;

  /// Snackbar message when verification email is resent
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Please check your inbox.'**
  String get emailVerifyLinkSentSuccess;

  /// Fallback name for signed in traveler
  ///
  /// In en, this message translates to:
  /// **'Signed In Traveler'**
  String get signedInTraveler;

  /// Status badge indicating active cloud session
  ///
  /// In en, this message translates to:
  /// **'Cloud Session Active'**
  String get cloudSessionActive;

  /// Dialog title for sign out confirmation
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// Dialog content for sign out confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out? Your travel data remains safely stored on your device.'**
  String get signOutConfirmMessage;

  /// Header for notifications section in settings
  ///
  /// In en, this message translates to:
  /// **'Notifications & Reminders'**
  String get notificationsAndReminders;

  /// Title for packing reminders setting
  ///
  /// In en, this message translates to:
  /// **'Packing Reminders'**
  String get packingReminders;

  /// Subtitle for packing reminders setting
  ///
  /// In en, this message translates to:
  /// **'Get smart reminders 48h and 24h before departure'**
  String get packingRemindersSubtitle;

  /// Expense category shopping
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// Error message when account does not exist
  ///
  /// In en, this message translates to:
  /// **'No account found with this email address.'**
  String get authErrorUserNotFound;

  /// Error message when password is wrong
  ///
  /// In en, this message translates to:
  /// **'Incorrect password entered. Please try again.'**
  String get authErrorWrongPassword;

  /// Error message when credentials are invalid
  ///
  /// In en, this message translates to:
  /// **'Email or password incorrect. Please check your credentials.'**
  String get authErrorInvalidCredential;

  /// Error message when email is already registered
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email address.'**
  String get authErrorEmailInUse;

  /// Error message when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authErrorInvalidEmail;

  /// Error message when password is too weak
  ///
  /// In en, this message translates to:
  /// **'Password does not meet requirements.'**
  String get authErrorWeakPassword;

  /// Error message when account is disabled
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// Error message when rate limited
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get authErrorTooManyRequests;

  /// Error message on network failure
  ///
  /// In en, this message translates to:
  /// **'Network connection error. Please check your internet.'**
  String get authErrorNetworkFailed;

  /// Error message on Google sign in failure
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Google. Please try again.'**
  String get authErrorGoogleFailed;

  /// Error message on email verification send failure
  ///
  /// In en, this message translates to:
  /// **'Could not send verification email. Please try again later.'**
  String get authErrorVerificationFailed;

  /// Generic authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authErrorGeneric;

  /// Button to continue with Apple ID
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// Prompt asking if traveler needs to register
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccount;

  /// Prompt asking if traveler already has an account
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authAlreadyHaveAccount;

  /// Header for account and session section in settings
  ///
  /// In en, this message translates to:
  /// **'Account & Session'**
  String get accountAndSession;

  /// Title for category expense breakdown analytics card
  ///
  /// In en, this message translates to:
  /// **'Category Spending Breakdown'**
  String get categorySpendingAnalysis;

  /// Highlight showing highest spending category and percentage
  ///
  /// In en, this message translates to:
  /// **'Top: {category} ({percentage}%)'**
  String topSpendingCategory(String category, String percentage);

  /// Badge showing total count of expenses
  ///
  /// In en, this message translates to:
  /// **'{count} Expenses'**
  String expenseCount(int count);

  /// Passenger label on boarding pass simulation
  ///
  /// In en, this message translates to:
  /// **'PASSENGER'**
  String get boardingPassPassenger;

  /// Gate label on boarding pass simulation
  ///
  /// In en, this message translates to:
  /// **'GATE'**
  String get boardingPassGate;

  /// Sample traveler name on boarding pass simulation
  ///
  /// In en, this message translates to:
  /// **'PACKBUDDY TRAVELER'**
  String get boardingPassSampleTraveler;

  /// Notification title sent 48 hours before trip departure
  ///
  /// In en, this message translates to:
  /// **'PackBuddy: Trip to {destination} in 2 days! 🧳'**
  String notification48hTitle(String destination);

  /// Notification body sent 48 hours before trip departure
  ///
  /// In en, this message translates to:
  /// **'Only 48 hours left until your trip to {destination}! Have you started packing your travel essentials?'**
  String notification48hBody(String destination);

  /// Notification title sent 24 hours before trip departure
  ///
  /// In en, this message translates to:
  /// **'PackBuddy: You\'re Leaving Tomorrow! ✈️'**
  String get notification24hTitle;

  /// Notification body sent 24 hours before trip departure
  ///
  /// In en, this message translates to:
  /// **'Final packing check! Double-check your passport, tickets, and travel essentials for {destination}.'**
  String notification24hBody(String destination);
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
