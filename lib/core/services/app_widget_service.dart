import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/local_db/database_helper.dart';
import '../../features/budget/domain/trip.dart';
import '../../features/budget/domain/expense.dart';
import '../../features/checklist/domain/packing_item.dart';
import '../../features/travel_map/data/travel_map_service.dart';
import '../../features/travel_map/domain/travel_country.dart';
import '../utils/currency_formatter.dart';
import 'app_widget_localization.dart';
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
  final String widgetMode; // 'auto', 'trip', 'world_map'
  final bool hasUpcomingTrip;
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
    this.widgetMode = 'auto',
    this.hasUpcomingTrip = false,
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
        widgetMode: json['widgetMode'] as String? ?? 'auto',
        hasUpcomingTrip: json['hasUpcomingTrip'] as bool? ?? false,
        updatedAt: json['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
            : DateTime.now(),
      );
}

/// Service managing glanceable widget state synchronization (Feature F-9)
class AppWidgetService {
  AppWidgetService._();

  static const String keyWidgetPayload = 'packbuddy_widget_payload_data';

  /// Serializes and stores latest upcoming trip, checklist, and travel map metrics
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

        final totalSpent = (expenses ?? const [])
            .where((e) => e.tripId == upcomingTrip.id && !e.isDeleted)
            .fold<double>(0.0, (sum, e) => sum + e.amount);

        budgetSpentStr = CurrencyFormatter.format(totalSpent, currency: upcomingTrip.defaultCurrency);
        if (upcomingTrip.budgetLimit != null) {
          budgetTotalStr = CurrencyFormatter.format(upcomingTrip.budgetLimit!, currency: upcomingTrip.defaultCurrency);
        }
      }

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
        updatedAt: DateTime.now(),
      );

      await prefs.setString(keyWidgetPayload, jsonEncode(payload.toJson()));

      // 3. Synchronize with Native Home Screen Widget (Android AppWidget & iOS WidgetKit)
      try {
        await HomeWidget.saveWidgetData<String>('widget_mode', mode);
        await HomeWidget.saveWidgetData<bool>('has_upcoming_trip', hasUpcomingTrip);

        // Trip Fields
        await HomeWidget.saveWidgetData<String>('trip_title', payload.tripTitle ?? 'PackBuddy');
        await HomeWidget.saveWidgetData<String>('trip_destination', payload.destination ?? '');
        await HomeWidget.saveWidgetData<int>('trip_days', payload.daysUntil);
        await HomeWidget.saveWidgetData<String>('trip_packing', '${payload.packedItems}/${payload.totalItems}');
        await HomeWidget.saveWidgetData<String>('trip_budget', payload.budgetSpent ?? '');

        // World Map Fields
        await HomeWidget.saveWidgetData<int>('map_visited_count', visitedCount);
        await HomeWidget.saveWidgetData<String>('map_world_percent', worldPercentStr);
        await HomeWidget.saveWidgetData<int>('map_wishlist_count', wishlistCount);
        await HomeWidget.saveWidgetData<int>('map_continents_count', continentsCount);

        // Pre-formatted localized texts for native Android AppWidget
        final lang = PreferencesService.instance.getLocale()?.languageCode ?? 'en';
        final theme = widgetTheme ?? PreferencesService.instance.getWidgetTheme();
        await HomeWidget.saveWidgetData<String>('widget_theme', theme);

        final showWorldMap = mode == 'world_map' ||
            (mode == 'auto' && !hasUpcomingTrip && (visitedCount > 0 || wishlistCount > 0));

        if (showWorldMap) {
          final customAppName = AppWidgetLocalization.getWorldHeader(lang);
          final customTitle = AppWidgetLocalization.getVisitedTitle(lang, visitedCount);
          const customSubtitle = '';
          final customStat1 = AppWidgetLocalization.getVisitedStatLabel(lang, visitedCount);
          final customStat2 = AppWidgetLocalization.getWishlistStatLabel(lang, wishlistCount);
          final customStat3 = AppWidgetLocalization.getContinentsStatLabel(lang, continentsCount);

          await HomeWidget.saveWidgetData<String>('custom_app_name', customAppName);
          await HomeWidget.saveWidgetData<String>('custom_days', worldPercentStr);
          await HomeWidget.saveWidgetData<String>('custom_title', customTitle);
          await HomeWidget.saveWidgetData<String>('custom_subtitle', customSubtitle);
          await HomeWidget.saveWidgetData<String>('custom_stat1', customStat1);
          await HomeWidget.saveWidgetData<String>('custom_stat2', customStat2);
          await HomeWidget.saveWidgetData<String>('custom_stat3', customStat3);

          // Render high-resolution vector world map image for medium and large home screen widgets
          await WidgetMapRenderer.renderAndSaveMapImages(mapCountries, theme: theme, continentsCount: continentsCount);
        } else if (hasUpcomingTrip && (payload.tripTitle?.isNotEmpty ?? false)) {
          final customAppName = AppWidgetLocalization.getTripHeader(lang);
          final customDays = daysUntil > 0
              ? '$daysUntil${AppWidgetLocalization.getDaysSuffix(lang)}'
              : (daysUntil == 0
                  ? AppWidgetLocalization.formatDaysUntil(lang, 0)
                  : AppWidgetLocalization.formatDaysUntil(lang, -1));
          final customTitle = payload.tripTitle ?? 'PackBuddy';
          final customSubtitle = (payload.destination?.isNotEmpty ?? false)
              ? payload.destination!
              : AppWidgetLocalization.getCountdownActive(lang);
          final customStat1 = '🎒 ${payload.packedItems}/${payload.totalItems} ${AppWidgetLocalization.getPackingLabel(lang).toLowerCase()}';
          final customStat2 = payload.budgetSpent ?? '';
          final customStat3 = payload.budgetTotal != null ? '${AppWidgetLocalization.getBudgetLabel(lang)}: ${payload.budgetTotal}' : '';

          await HomeWidget.saveWidgetData<String>('custom_app_name', customAppName);
          await HomeWidget.saveWidgetData<String>('custom_days', customDays);
          await HomeWidget.saveWidgetData<String>('custom_title', customTitle);
          await HomeWidget.saveWidgetData<String>('custom_subtitle', customSubtitle);
          await HomeWidget.saveWidgetData<String>('custom_stat1', customStat1);
          await HomeWidget.saveWidgetData<String>('custom_stat2', customStat2);
          await HomeWidget.saveWidgetData<String>('custom_stat3', customStat3);
        } else {
          final customAppName = 'PackBuddy';
          final customDays = '✈️';
          final customTitle = AppWidgetLocalization.getTripHeader(lang);
          final customSubtitle = AppWidgetLocalization.getDefaultDestination(lang);
          final customStat1 = '🎒 ${AppWidgetLocalization.getPackingLabel(lang)}';
          final customStat2 = AppWidgetLocalization.getWorldMapModeLabel(lang);
          final customStat3 = AppWidgetLocalization.getWorldHeader(lang);

          await HomeWidget.saveWidgetData<String>('custom_app_name', customAppName);
          await HomeWidget.saveWidgetData<String>('custom_days', customDays);
          await HomeWidget.saveWidgetData<String>('custom_title', customTitle);
          await HomeWidget.saveWidgetData<String>('custom_subtitle', customSubtitle);
          await HomeWidget.saveWidgetData<String>('custom_stat1', customStat1);
          await HomeWidget.saveWidgetData<String>('custom_stat2', customStat2);
          await HomeWidget.saveWidgetData<String>('custom_stat3', customStat3);
        }

        for (final provider in const [
          'PackBuddyWidgetProvider',
          'PackBuddyMediumWidgetProvider',
          'PackBuddyLargeWidgetProvider',
        ]) {
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
