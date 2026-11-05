import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local_db/database_helper.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/domain/expense.dart';
import '../../features/budget/presentation/screens/trip_detail_screen.dart';
import '../../features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import '../../features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import '../../features/budget/presentation/widgets/currency_converter_card.dart';
import '../../features/checklist/domain/packing_item.dart';
import '../../features/travel_map/data/travel_map_service.dart';
import '../../features/travel_map/domain/travel_country.dart';
import '../../features/travel_map/presentation/screens/travel_map_screen.dart';
import '../utils/currency_formatter.dart';
import 'app_widget_localization.dart';
import 'currency_service.dart';
import 'preferences_service.dart';
import 'widget_map_renderer.dart';

/// App Widget Payload model for iOS WidgetKit / Android AppWidgets (Feature F-9)
class AppWidgetData {
  final String? tripTitle;
  final String? destination;
  final int daysUntil;
  final int totalItems;
  final int packedItems;
  final int packingPercent;
  final String? budgetSpent;
  final String? budgetTotal;
  final int visitedCountriesCount;
  final String worldPercentage;
  final int wishlistCountriesCount;
  final int continentsCount;
  final String widgetMode; // 'trip', 'world_map', 'currency_converter', 'quick_expense'
  final bool hasUpcomingTrip;
  final String? currencyRateUSD;
  final String? currencyRateEUR;
  final String? remainingBudget;
  final String? lastExpenseText;
  final String? userCurrency;
  final DateTime updatedAt;

  const AppWidgetData({
    this.tripTitle,
    this.destination,
    this.daysUntil = 0,
    this.totalItems = 0,
    this.packedItems = 0,
    this.packingPercent = 0,
    this.budgetSpent,
    this.budgetTotal,
    this.visitedCountriesCount = 0,
    this.worldPercentage = '%0.0',
    this.wishlistCountriesCount = 0,
    this.continentsCount = 0,
    this.widgetMode = 'trip',
    this.hasUpcomingTrip = false,
    this.currencyRateUSD,
    this.currencyRateEUR,
    this.remainingBudget,
    this.lastExpenseText,
    this.userCurrency,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'tripTitle': tripTitle,
        'destination': destination,
        'daysUntil': daysUntil,
        'totalItems': totalItems,
        'packedItems': packedItems,
        'packingPercent': packingPercent,
        'budgetSpent': budgetSpent,
        'budgetTotal': budgetTotal,
        'visitedCountriesCount': visitedCountriesCount,
        'worldPercentage': worldPercentage,
        'wishlistCountriesCount': wishlistCountriesCount,
        'continentsCount': continentsCount,
        'widgetMode': widgetMode,
        'hasUpcomingTrip': hasUpcomingTrip,
        'currencyRateUSD': currencyRateUSD,
        'currencyRateEUR': currencyRateEUR,
        'remainingBudget': remainingBudget,
        'lastExpenseText': lastExpenseText,
        'userCurrency': userCurrency,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory AppWidgetData.fromJson(Map<String, dynamic> json) => AppWidgetData(
        tripTitle: json['tripTitle'] as String?,
        destination: json['destination'] as String?,
        daysUntil: (json['daysUntil'] as num?)?.toInt() ?? 0,
        totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
        packedItems: (json['packedItems'] as num?)?.toInt() ?? 0,
        packingPercent: (json['packingPercent'] as num?)?.toInt() ?? 0,
        budgetSpent: json['budgetSpent'] as String?,
        budgetTotal: json['budgetTotal'] as String?,
        visitedCountriesCount: (json['visitedCountriesCount'] as num?)?.toInt() ?? 0,
        worldPercentage: json['worldPercentage'] as String? ?? '%0.0',
        wishlistCountriesCount: (json['wishlistCountriesCount'] as num?)?.toInt() ?? 0,
        continentsCount: (json['continentsCount'] as num?)?.toInt() ?? 0,
        widgetMode: json['widgetMode'] as String? ?? 'trip',
        hasUpcomingTrip: json['hasUpcomingTrip'] as bool? ?? false,
        currencyRateUSD: json['currencyRateUSD'] as String?,
        currencyRateEUR: json['currencyRateEUR'] as String?,
        remainingBudget: json['remainingBudget'] as String?,
        lastExpenseText: json['lastExpenseText'] as String?,
        userCurrency: json['userCurrency'] as String?,
        updatedAt: json['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
            : DateTime.now(),
      );
}

/// Service managing glanceable widget state synchronization (Feature F-9)
class AppWidgetService {
  AppWidgetService._();

  static const String keyWidgetPayload = 'packbuddy_widget_payload_data';

  /// Global navigator key allowing widget deep links to navigate without context dependency
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Uri? _pendingUri;
  static bool _isHandlingUri = false;

  /// Handles deep links originating from Android Home Screen widgets
  static Future<void> handleWidgetUri(Uri uri, [WidgetRef? ref]) async {
    debugPrint('[AppWidgetService] Received widget deep link: $uri');
    _pendingUri = uri;
    await _processPendingUri();
  }

  static Future<void> _processPendingUri() async {
    if (_isHandlingUri || _pendingUri == null) return;
    _isHandlingUri = true;
    try {
      final uri = _pendingUri!;

      // Wait for navigatorKey.currentContext to become available and stable (up to 3 seconds)
      for (int i = 0; i < 30; i++) {
        if (navigatorKey.currentContext != null) break;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      var context = navigatorKey.currentContext;
      if (context == null) {
        _isHandlingUri = false;
        return;
      }

      // Small delay to allow any initial route / auth transition to settle
      await Future.delayed(const Duration(milliseconds: 300));
      context = navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        _isHandlingUri = false;
        return;
      }

      final host = uri.host.isNotEmpty ? uri.host : uri.path.replaceAll('/', '');

      if (host == 'add_expense' || uri.toString().contains('add_expense')) {
        final trips = await DatabaseHelper.instance.getTrips(includeDeleted: false);
        final activeTrips = trips.where((t) => !t.isDeleted).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
        final curCtx = navigatorKey.currentContext;
        if (curCtx != null && curCtx.mounted) {
          if (activeTrips.isNotEmpty) {
            final trip = activeTrips.first;
            AddExpenseSheet.show(
              curCtx,
              tripId: trip.id,
              defaultCurrency: trip.defaultCurrency,
            );
          } else {
            AddTripSheet.show(curCtx);
          }
        }
      } else if (host == 'currency' || uri.toString().contains('currency')) {
        final curCtx = navigatorKey.currentContext;
        if (curCtx != null && curCtx.mounted) {
          CurrencyConverterCard.showAsModal(curCtx);
        }
      } else if (host == 'map' || uri.toString().contains('map')) {
        final curCtx = navigatorKey.currentContext;
        if (curCtx != null && curCtx.mounted) {
          Navigator.of(curCtx).push(
            MaterialPageRoute(builder: (_) => const TravelMapScreen()),
          );
        }
      } else if (host == 'trip' || uri.toString().contains('trip')) {
        final trips = await DatabaseHelper.instance.getTrips(includeDeleted: false);
        final activeTrips = trips.where((t) => !t.isDeleted).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
        final curCtx = navigatorKey.currentContext;
        if (curCtx != null && curCtx.mounted) {
          if (activeTrips.isNotEmpty) {
            Navigator.of(curCtx).push(
              MaterialPageRoute(builder: (_) => TripDetailScreen(trip: activeTrips.first)),
            );
          } else {
            AddTripSheet.show(curCtx);
          }
        }
      }
      _pendingUri = null;
    } finally {
      _isHandlingUri = false;
    }
  }

  /// Serializes and stores latest upcoming trip, checklist, travel map, and currency metrics
  static Future<void> updateWidgetPayload({
    Trip? upcomingTrip,
    List<PackingItem>? items,
    List<Expense>? expenses,
    List<TravelCountry>? countries,
    String? widgetMode,
    String? widgetTheme,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = widgetMode ?? PreferencesService.instance.getWidgetMode();

      // 1. Resolve World Map Metrics
      List<TravelCountry> mapCountries = countries ?? const [];
      if (mapCountries.isEmpty) {
        try {
          mapCountries = await TravelMapService.instance.getCountries();
        } catch (_) {}
      }

      final visitedCountries = mapCountries.where((c) => c.isVisited || c.isLived).toList();
      final visitedCount = visitedCountries.length;
      final wishlistCount = mapCountries.where((c) => c.isWishlist).length;
      final continentsCount = visitedCountries.map((c) => c.continent).where((c) => c.isNotEmpty).toSet().length;
      final totalCountries = mapCountries.isNotEmpty ? mapCountries.length : 229;
      final worldPct = (visitedCount / totalCountries) * 100;
      final worldPercentStr = '%${worldPct.toStringAsFixed(1)}';

      // 2. Resolve Trip Metrics
      final hasUpcomingTrip = upcomingTrip != null;
      int daysUntil = 0;
      int totalItems = 0;
      int packedItems = 0;
      int packingPercent = 0;
      String? budgetSpentStr;
      String? budgetTotalStr;
      String? remainingBudgetStr;
      String? lastExpenseText;
      double totalSpent = 0.0;

      final userCurrency = upcomingTrip?.defaultCurrency ??
          PreferencesService.instance.getDefaultCurrency() ??
          'TRY';

      if (upcomingTrip != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tripStart = DateTime(
          upcomingTrip.startDate.year,
          upcomingTrip.startDate.month,
          upcomingTrip.startDate.day,
        );
        daysUntil = tripStart.difference(today).inDays;
        if (daysUntil < 0) daysUntil = 0;

        final tripItems = (items ?? const [])
            .where((i) => (i.tripId == upcomingTrip.id || i.tripId == null) && !i.isDeleted)
            .toList();
        totalItems = tripItems.length;
        packedItems = tripItems.where((i) => i.isPacked).length;
        packingPercent = totalItems > 0 ? ((packedItems / totalItems) * 100).toInt() : 0;

        final tripExpenses = (expenses ?? const [])
            .where((e) => e.tripId == upcomingTrip.id && !e.isDeleted)
            .toList();

        totalSpent = tripExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

        budgetSpentStr = CurrencyFormatter.format(totalSpent, currency: userCurrency);
        if (upcomingTrip.budgetLimit != null) {
          budgetTotalStr = CurrencyFormatter.format(upcomingTrip.budgetLimit!, currency: userCurrency);
          final remaining = (upcomingTrip.budgetLimit! - totalSpent).clamp(0.0, double.infinity);
          remainingBudgetStr = CurrencyFormatter.format(remaining, currency: userCurrency);
        }

        if (tripExpenses.isNotEmpty) {
          final sortedExpenses = List<Expense>.from(tripExpenses)
            ..sort((a, b) => b.date.compareTo(a.date));
          final last = sortedExpenses.first;
          lastExpenseText = '${last.title}: ${CurrencyFormatter.format(last.amount, currency: last.currency)}';
        }
      }

      // 3. Resolve Currency Conversion Rates
      final double rateUsd = CurrencyService.convert(amount: 1.0, fromCurrency: 'USD', toCurrency: userCurrency);
      final double rateEur = CurrencyService.convert(amount: 1.0, fromCurrency: 'EUR', toCurrency: userCurrency);
      final String rateUsdStr = CurrencyFormatter.format(rateUsd, currency: userCurrency);
      final String rateEurStr = CurrencyFormatter.format(rateEur, currency: userCurrency);

      final payload = AppWidgetData(
        tripTitle: upcomingTrip != null
            ? (upcomingTrip.title.isNotEmpty ? upcomingTrip.title : upcomingTrip.destination)
            : 'PackBuddy',
        destination: upcomingTrip?.destination ?? '',
        daysUntil: daysUntil,
        totalItems: totalItems,
        packedItems: packedItems,
        packingPercent: packingPercent,
        budgetSpent: budgetSpentStr,
        budgetTotal: budgetTotalStr,
        visitedCountriesCount: visitedCount,
        worldPercentage: worldPercentStr,
        wishlistCountriesCount: wishlistCount,
        continentsCount: continentsCount,
        widgetMode: mode,
        hasUpcomingTrip: hasUpcomingTrip,
        currencyRateUSD: rateUsdStr,
        currencyRateEUR: rateEurStr,
        remainingBudget: remainingBudgetStr,
        lastExpenseText: lastExpenseText,
        userCurrency: userCurrency,
        updatedAt: DateTime.now(),
      );

      await prefs.setString(keyWidgetPayload, jsonEncode(payload.toJson()));

      // 4. Synchronize with Native Home Screen Widget (Android AppWidget & iOS WidgetKit)
      try {
        final lang = PreferencesService.instance.getLocale()?.languageCode ?? 'tr';
        final theme = widgetTheme ?? PreferencesService.instance.getWidgetTheme();

        await HomeWidget.saveWidgetData<String>('widget_mode', mode);
        await HomeWidget.saveWidgetData<String>('widget_theme', theme);
        await HomeWidget.saveWidgetData<String>('${mode}_theme', theme);
        await HomeWidget.saveWidgetData<String>('pending_pin_theme', theme);
        await HomeWidget.saveWidgetData<String>('app_language', lang);
        await HomeWidget.saveWidgetData<bool>('has_upcoming_trip', hasUpcomingTrip);

        // Core fields
        await HomeWidget.saveWidgetData<String>('trip_title', payload.tripTitle ?? 'PackBuddy');
        await HomeWidget.saveWidgetData<String>('trip_destination', payload.destination ?? '');
        await HomeWidget.saveWidgetData<int>('trip_days', payload.daysUntil);
        await HomeWidget.saveWidgetData<String>('trip_packing', '${payload.packedItems}/${payload.totalItems}');
        final defaultZeroCurrency = CurrencyFormatter.format(0, currency: userCurrency);
        await HomeWidget.saveWidgetData<String>('trip_budget', (payload.budgetSpent != null && payload.budgetSpent!.isNotEmpty) ? payload.budgetSpent! : defaultZeroCurrency);

        await HomeWidget.saveWidgetData<int>('map_visited_count', visitedCount);
        await HomeWidget.saveWidgetData<String>('map_world_percent', worldPercentStr);
        await HomeWidget.saveWidgetData<int>('map_wishlist_count', wishlistCount);
        await HomeWidget.saveWidgetData<int>('map_continents_count', continentsCount);

        await HomeWidget.saveWidgetData<String>('currency_rate_usd', rateUsdStr);
        await HomeWidget.saveWidgetData<String>('currency_rate_eur', rateEurStr);
        await HomeWidget.saveWidgetData<String>('remaining_budget', remainingBudgetStr ?? '');
        await HomeWidget.saveWidgetData<String>('last_expense_text', lastExpenseText ?? '');
        await HomeWidget.saveWidgetData<String>('user_currency', userCurrency);
        await HomeWidget.saveWidgetData<String>('currency_rates_json', jsonEncode(CurrencyService.ratesAgainstUsd));
        await HomeWidget.saveWidgetData<String>('active_trip_id', upcomingTrip?.id ?? '');
        await HomeWidget.saveWidgetData<String>('active_trip_currency', upcomingTrip?.defaultCurrency ?? userCurrency);
        await HomeWidget.saveWidgetData<double>('trip_budget_spent_num', totalSpent);
        await HomeWidget.saveWidgetData<double>('trip_budget_limit_num', upcomingTrip?.budgetLimit ?? 0.0);

        // Pre-formatted localized texts for native Android AppWidget based on ALL modes simultaneously
        // 1. World Map
        final worldAppName = AppWidgetLocalization.getWorldHeader(lang);
        final worldDays = worldPercentStr;
        final worldTitle = AppWidgetLocalization.getVisitedTitle(lang, visitedCount);
        final worldSubtitle = AppWidgetLocalization.getExplorationRateLabel(lang);
        final worldStat1 = AppWidgetLocalization.getVisitedStatLabel(lang, visitedCount);
        final worldStat2 = PreferencesService.instance.isWidgetShowWishlist()
            ? AppWidgetLocalization.getWishlistStatLabel(lang, wishlistCount)
            : '';
        final worldStat3 = PreferencesService.instance.isWidgetShowContinents()
            ? AppWidgetLocalization.getContinentsStatLabel(lang, continentsCount)
            : '';
        final worldTheme = PreferencesService.instance.getWidgetThemeForMode('world_map');

        await HomeWidget.saveWidgetData<String>('world_map_app_name', worldAppName);
        await HomeWidget.saveWidgetData<String>('world_map_days', worldDays);
        await HomeWidget.saveWidgetData<String>('world_map_title', worldTitle);
        await HomeWidget.saveWidgetData<String>('world_map_subtitle', worldSubtitle);
        await HomeWidget.saveWidgetData<String>('world_map_stat1', worldStat1);
        await HomeWidget.saveWidgetData<String>('world_map_stat2', worldStat2);
        await HomeWidget.saveWidgetData<String>('world_map_stat3', worldStat3);
        await HomeWidget.saveWidgetData<String>('world_map_theme', worldTheme);

        // Render high-resolution vector world map image for any world map widgets
        await WidgetMapRenderer.renderAndSaveMapImages(
          mapCountries,
          theme: worldTheme,
          continentsCount: continentsCount,
        );

        // 2. Currency Converter
        final currencyAppName = AppWidgetLocalization.getCurrencyHeader(lang);
        final currencyDays = userCurrency;
        final currencyTitle = '1 USD = $rateUsdStr';
        final currencySubtitle = '1 EUR = $rateEurStr';
        final currencyStat1 = '💵 $rateUsdStr';
        final currencyStat2 = '💶 $rateEurStr';
        final reverseRate = rateUsd > 0 ? (1.0 / rateUsd) : 0.0;
        final currencyStat3 = '1 $userCurrency ≈ \$${reverseRate.toStringAsFixed(2)}';
        final currencyTheme = PreferencesService.instance.getWidgetThemeForMode('currency_converter');

        final conv1 = '\$10 ≈ ${(10 * rateUsd).toStringAsFixed(1)} $userCurrency';
        final conv2 = '\$50 ≈ ${(50 * rateUsd).toStringAsFixed(1)} $userCurrency';
        final conv3 = '\$100 ≈ ${(100 * rateUsd).toStringAsFixed(0)} $userCurrency';

        await HomeWidget.saveWidgetData<String>('currency_converter_app_name', currencyAppName);
        await HomeWidget.saveWidgetData<String>('currency_converter_days', currencyDays);
        await HomeWidget.saveWidgetData<String>('currency_converter_title', currencyTitle);
        await HomeWidget.saveWidgetData<String>('currency_converter_subtitle', currencySubtitle);
        await HomeWidget.saveWidgetData<String>('currency_converter_stat1', currencyStat1);
        await HomeWidget.saveWidgetData<String>('currency_converter_stat2', currencyStat2);
        await HomeWidget.saveWidgetData<String>('currency_converter_stat3', currencyStat3);
        await HomeWidget.saveWidgetData<String>('currency_converter_theme', currencyTheme);
        await HomeWidget.saveWidgetData<String>('currency_converter_conversions_title', AppWidgetLocalization.getQuickConversionsLabel(lang));
        await HomeWidget.saveWidgetData<String>('currency_converter_live_status', AppWidgetLocalization.getLiveRatesLabel(lang));
        await HomeWidget.saveWidgetData<String>('currency_converter_sync_status', AppWidgetLocalization.getAutoSyncLabel(lang));
        await HomeWidget.saveWidgetData<String>('currency_converter_offline_status', AppWidgetLocalization.getOfflineReadyLabel(lang));
        await HomeWidget.saveWidgetData<String>('currency_conv_1', conv1);
        await HomeWidget.saveWidgetData<String>('currency_conv_2', conv2);
        await HomeWidget.saveWidgetData<String>('currency_conv_3', conv3);
        await HomeWidget.saveWidgetData<String>('currency_usd_label', '1 USD');
        await HomeWidget.saveWidgetData<String>('currency_eur_label', '1 EUR');

        // 3. Quick Expense
        final expenseAppName = AppWidgetLocalization.getExpenseHeader(lang);
        const expenseDays = '+';
        final expenseTitle = payload.budgetSpent ?? CurrencyFormatter.format(0, currency: userCurrency);
        final expenseSubtitle = remainingBudgetStr != null
            ? '${AppWidgetLocalization.getShowRemainingBudgetLabel(lang)}: $remainingBudgetStr'
            : (upcomingTrip?.title ?? 'PackBuddy');
        final expenseStat1 = '💳 ${payload.budgetSpent ?? CurrencyFormatter.format(0, currency: userCurrency)}';
        final expenseStat2 = remainingBudgetStr != null ? '💰 $remainingBudgetStr' : (lang == 'tr' ? '+ Ekle' : '+ Add');
        final expenseStat3 = lastExpenseText ?? '';
        final expenseTheme = PreferencesService.instance.getWidgetThemeForMode('quick_expense');

        final spentLabel = AppWidgetLocalization.getSpentLabel(lang);
        final spentBudgetLabel = AppWidgetLocalization.getSpentBudgetLabel(lang);
        final remainingBudgetTitle = AppWidgetLocalization.getRemainingBudgetTitle(lang);
        final lastExpenseLabel = AppWidgetLocalization.getLastExpenseLabel(lang);
        final noLastExpenseText = AppWidgetLocalization.getNoExpensesLoggedLabel(lang);
        final addExpenseLabel = AppWidgetLocalization.getAddExpenseActionLabel(lang);
        final quickLogBadge = AppWidgetLocalization.getQuickLogBadge(lang);
        final showRemaining = PreferencesService.instance.isWidgetShowRemainingBudget();
        final showLast = PreferencesService.instance.isWidgetShowLastExpense();

        await HomeWidget.saveWidgetData<String>('quick_expense_app_name', expenseAppName);
        await HomeWidget.saveWidgetData<String>('quick_expense_days', expenseDays);
        await HomeWidget.saveWidgetData<String>('quick_expense_title', expenseTitle);
        await HomeWidget.saveWidgetData<String>('quick_expense_subtitle', expenseSubtitle);
        await HomeWidget.saveWidgetData<String>('quick_expense_stat1', expenseStat1);
        await HomeWidget.saveWidgetData<String>('quick_expense_stat2', expenseStat2);
        await HomeWidget.saveWidgetData<String>('quick_expense_stat3', expenseStat3);
        await HomeWidget.saveWidgetData<String>('quick_expense_theme', expenseTheme);
        await HomeWidget.saveWidgetData<String>('quick_expense_spent_label', spentLabel);
        await HomeWidget.saveWidgetData<String>('quick_expense_spent_card_label', spentBudgetLabel);
        await HomeWidget.saveWidgetData<String>('quick_expense_remaining_label', remainingBudgetTitle);
        await HomeWidget.saveWidgetData<String>('quick_expense_last_label', lastExpenseLabel);
        await HomeWidget.saveWidgetData<String>('quick_expense_no_last', noLastExpenseText);
        await HomeWidget.saveWidgetData<String>('quick_expense_add_action', addExpenseLabel);
        await HomeWidget.saveWidgetData<String>('quick_expense_quick_log', quickLogBadge);
        await HomeWidget.saveWidgetData<bool>('quick_expense_show_remaining', showRemaining);
        await HomeWidget.saveWidgetData<bool>('quick_expense_show_last', showLast);

        // 4. Trip
        String tripAppName;
        String tripDays;
        String tripTitle;
        String tripSubtitle;
        String tripStat1;
        String tripStat2;
        String tripStat3;

        if (hasUpcomingTrip && (payload.tripTitle?.isNotEmpty ?? false)) {
          tripAppName = AppWidgetLocalization.getTripHeader(lang);
          tripDays = daysUntil > 0
              ? '$daysUntil${AppWidgetLocalization.getDaysSuffix(lang)}'
              : (daysUntil == 0
                  ? AppWidgetLocalization.formatDaysUntil(lang, 0)
                  : AppWidgetLocalization.formatDaysUntil(lang, -1));
          tripTitle = payload.tripTitle ?? 'PackBuddy';
          tripSubtitle = (payload.destination?.isNotEmpty ?? false)
              ? payload.destination!
              : AppWidgetLocalization.getCountdownActive(lang);
          tripStat1 = PreferencesService.instance.isWidgetShowPacking()
              ? '🎒 ${payload.packedItems}/${payload.totalItems} ${AppWidgetLocalization.getPackingLabel(lang).toLowerCase()}'
              : '';
          tripStat2 = PreferencesService.instance.isWidgetShowBudget()
              ? (payload.budgetSpent ?? '')
              : '';
          tripStat3 = payload.budgetTotal != null
              ? '${AppWidgetLocalization.getBudgetLabel(lang)}: ${payload.budgetTotal}'
              : '';
        } else {
          tripAppName = 'PackBuddy';
          tripDays = '✈️';
          tripTitle = AppWidgetLocalization.getTripHeader(lang);
          tripSubtitle = AppWidgetLocalization.getDefaultDestination(lang);
          tripStat1 = '🎒 ${AppWidgetLocalization.getPackingLabel(lang)}';
          tripStat2 = AppWidgetLocalization.getWorldMapModeLabel(lang);
          tripStat3 = AppWidgetLocalization.getWorldHeader(lang);
        }
        final tripTheme = PreferencesService.instance.getWidgetThemeForMode('trip');

        await HomeWidget.saveWidgetData<String>('trip_app_name', tripAppName);
        await HomeWidget.saveWidgetData<String>('trip_days', tripDays);
        await HomeWidget.saveWidgetData<String>('trip_title', tripTitle);
        await HomeWidget.saveWidgetData<String>('trip_subtitle', tripSubtitle);
        await HomeWidget.saveWidgetData<String>('trip_stat1', tripStat1);
        await HomeWidget.saveWidgetData<String>('trip_stat2', tripStat2);
        await HomeWidget.saveWidgetData<String>('trip_stat3', tripStat3);
        await HomeWidget.saveWidgetData<String>('trip_theme', tripTheme);

        // Legacy/Active mode fallback keys
        String customAppName;
        String customDays;
        String customTitle;
        String customSubtitle;
        String customStat1;
        String customStat2;
        String customStat3;

        switch (mode) {
          case 'world_map':
            customAppName = worldAppName;
            customDays = worldDays;
            customTitle = worldTitle;
            customSubtitle = worldSubtitle;
            customStat1 = worldStat1;
            customStat2 = worldStat2;
            customStat3 = worldStat3;
            break;

          case 'currency_converter':
            customAppName = currencyAppName;
            customDays = currencyDays;
            customTitle = currencyTitle;
            customSubtitle = currencySubtitle;
            customStat1 = currencyStat1;
            customStat2 = currencyStat2;
            customStat3 = currencyStat3;
            break;

          case 'quick_expense':
            customAppName = expenseAppName;
            customDays = expenseDays;
            customTitle = expenseTitle;
            customSubtitle = expenseSubtitle;
            customStat1 = expenseStat1;
            customStat2 = expenseStat2;
            customStat3 = expenseStat3;
            break;

          case 'trip':
          default:
            customAppName = tripAppName;
            customDays = tripDays;
            customTitle = tripTitle;
            customSubtitle = tripSubtitle;
            customStat1 = tripStat1;
            customStat2 = tripStat2;
            customStat3 = tripStat3;
            break;
        }

        await HomeWidget.saveWidgetData<String>('custom_app_name', customAppName);
        await HomeWidget.saveWidgetData<String>('custom_days', customDays);
        await HomeWidget.saveWidgetData<String>('custom_title', customTitle);
        await HomeWidget.saveWidgetData<String>('custom_subtitle', customSubtitle);
        await HomeWidget.saveWidgetData<String>('custom_stat1', customStat1);
        await HomeWidget.saveWidgetData<String>('custom_stat2', customStat2);
        await HomeWidget.saveWidgetData<String>('custom_stat3', customStat3);

        const allProviders = [
          'PackBuddyWidgetProvider',
          'PackBuddyMediumWidgetProvider',
          'PackBuddyLargeWidgetProvider',
          'PackBuddyMapWidgetProvider',
          'PackBuddyMapMediumWidgetProvider',
          'PackBuddyMapLargeWidgetProvider',
          'PackBuddyExpenseWidgetProvider',
          'PackBuddyExpenseMediumWidgetProvider',
          'PackBuddyExpenseLargeWidgetProvider',
          'PackBuddyCurrencyWidgetProvider',
          'PackBuddyCurrencyMediumWidgetProvider',
          'PackBuddyCurrencyLargeWidgetProvider',
        ];

        for (final provider in allProviders) {
          try {
            await HomeWidget.updateWidget(
              name: provider,
              androidName: provider,
              qualifiedAndroidName: 'com.sleepyhead.packbuddy.$provider',
              iOSName: 'PackBuddyWidget',
            );
          } catch (_) {}
        }
      } catch (_) {}
    } catch (_) {}
  }

  /// Self-contained automatic widget refresh from database and local preferences
  static Future<void> syncCurrentState({
    Trip? upcomingTrip,
    List<PackingItem>? items,
    List<Expense>? expenses,
    List<TravelCountry>? countries,
    String? widgetMode,
    String? widgetTheme,
  }) async {
    try {
      Trip? nextTrip = upcomingTrip;
      if (nextTrip == null) {
        final now = DateTime.now();
        final trips = await DatabaseHelper.instance.getTrips(includeDeleted: false);
        final futureTrips = trips
            .where((t) => !t.isDeleted && t.startDate.isAfter(now.subtract(const Duration(days: 1))))
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
        if (futureTrips.isNotEmpty) {
          nextTrip = futureTrips.first;
        } else if (trips.isNotEmpty) {
          nextTrip = trips.first;
        }
      }

      List<PackingItem>? resolvedItems = items;
      if (resolvedItems == null && nextTrip != null) {
        resolvedItems = await DatabaseHelper.instance.getChecklistItems(
          tripId: nextTrip.id,
          includeDeleted: false,
        );
      }

      List<Expense>? resolvedExpenses = expenses;
      if (resolvedExpenses == null && nextTrip != null) {
        resolvedExpenses = await DatabaseHelper.instance.getExpenses(
          tripId: nextTrip.id,
          includeDeleted: false,
        );
      }

      await updateWidgetPayload(
        upcomingTrip: nextTrip,
        items: resolvedItems,
        expenses: resolvedExpenses,
        countries: countries,
        widgetMode: widgetMode,
        widgetTheme: widgetTheme,
      );
    } catch (_) {}
  }

  /// Retrieves cached widget payload
  static Future<AppWidgetData?> getWidgetPayload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(keyWidgetPayload);
      if (raw != null && raw.isNotEmpty) {
        return AppWidgetData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }
}
