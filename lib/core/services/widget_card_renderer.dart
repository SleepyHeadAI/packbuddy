import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import '../../features/travel_map/domain/travel_country.dart';
import '../../l10n/app_localizations.dart';
import 'app_widget_localization.dart';
import 'app_widget_service.dart';
import 'preferences_service.dart';
import 'widget_map_renderer.dart';
import '../theme/app_theme.dart';

/// Single-Source-Of-Truth 1:1 Rendering Engine for PackBuddy Home Screen Widgets
/// Eliminates any visual discrepancy between the in-app preview and Android/iOS home screen widgets.
class WidgetCardRenderer {
  WidgetCardRenderer._();

  static const double smallSize = 156.0;
  static const double mediumWidth = 310.0;
  static const double mediumHeight = 140.0;
  static const double largeWidth = 310.0;
  static const double largeHeight = 300.0;

  /// Builds the complete decorated card widget (Identical in-app and on home screen)
  static Widget buildWidgetCard({
    required String mode,
    required int sizeIndex, // 0: Small, 1: Medium, 2: Large
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required List<TravelCountry> countries,
    required String lang,
    AppLocalizations? l10n,
    bool showContinents = true,
    bool showWishlist = true,
    bool showCountdown = true,
    bool showPacking = true,
    bool showBudget = true,
    bool showLiveRate = true,
    bool showReverseRate = true,
    bool showRemainingBudget = true,
    bool showLastExpense = true,
  }) {
    final double width = switch (sizeIndex) {
      0 => smallSize,
      1 => mediumWidth,
      2 => largeWidth,
      _ => mediumWidth,
    };
    final double height = switch (sizeIndex) {
      0 => smallSize,
      1 => mediumHeight,
      2 => largeHeight,
      _ => mediumHeight,
    };

    final isDark = !themeConfig.isLight;

    // Build the country color map for our miniature vector World Map
    final colorMap = <String, Color>{};
    for (final country in countries) {
      final code = country.code.toLowerCase().trim();
      if (country.isLived) {
        colorMap[code] = themeConfig.livedColor;
      } else if (country.isVisited) {
        colorMap[code] = themeConfig.visitedColor;
      } else if (country.isWishlist && showWishlist) {
        colorMap[code] = themeConfig.wishlistColor;
      }
    }
    // Also map Northern Cyprus color onto Cyprus polygon if set
    final nc = countries.where((c) => c.code == 'NC').firstOrNull;
    if (nc != null && (colorMap['cy'] == null || nc.isLived || nc.isVisited)) {
      if (nc.isLived) {
        colorMap['cy'] = themeConfig.livedColor;
      } else if (nc.isVisited) {
        colorMap['cy'] = themeConfig.visitedColor;
      } else if (nc.isWishlist && showWishlist && colorMap['cy'] == null) {
        colorMap['cy'] = themeConfig.wishlistColor;
      }
    }

    int livedCount = countries.where((c) => c.isLived).length;
    int visitedCount = countries.isNotEmpty
        ? countries.where((c) => c.isVisited || c.isLived).length
        : (widgetData?.visitedCountriesCount ?? 0);
    int wishlistCount = countries.isNotEmpty
        ? countries.where((c) => c.isWishlist).length
        : (widgetData?.wishlistCountriesCount ?? 0);
    int continentsCount = countries.isNotEmpty
        ? countries
            .where((c) => c.isVisited || c.isLived)
            .map((c) => c.continent)
            .where((c) => c.isNotEmpty)
            .toSet()
            .length
        : (widgetData?.continentsCount ?? 0);

    // Provide attractive preview fallback if user hasn't marked countries yet
    if (visitedCount == 0 && livedCount == 0 && wishlistCount == 0) {
      visitedCount = 28;
      livedCount = 3;
      wishlistCount = 2;
      continentsCount = 2;
      colorMap['tr'] = themeConfig.livedColor;
      colorMap['de'] = themeConfig.visitedColor;
      colorMap['it'] = themeConfig.visitedColor;
      colorMap['fr'] = themeConfig.visitedColor;
      colorMap['es'] = themeConfig.visitedColor;
      colorMap['us'] = themeConfig.visitedColor;
      colorMap['br'] = themeConfig.visitedColor;
      if (showWishlist) {
        colorMap['jp'] = themeConfig.wishlistColor;
        colorMap['ca'] = themeConfig.wishlistColor;
      }
    }

    final String rawPct = (widgetData?.worldPercentage ?? '0.0').replaceAll('%', '').trim();
    final double worldPercent = double.tryParse(rawPct) ??
        (visitedCount > 0 ? (visitedCount / 229.0 * 100.0) : 12.3);

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeConfig.cardBgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: themeConfig.cardBorderColor,
          width: 1.5,
        ),
      ),
      child: switch (mode) {
        'world_map' => _buildWorldMapContent(
            sizeIndex: sizeIndex,
            isDark: isDark,
            lang: lang,
            themeConfig: themeConfig,
            visitedCount: visitedCount,
            livedCount: livedCount,
            wishlistCount: wishlistCount,
            continentsCount: continentsCount,
            worldPercent: worldPercent,
            colorMap: colorMap,
            showContinents: showContinents,
            showWishlist: showWishlist,
          ),
        'currency_converter' => _buildCurrencyContent(
            sizeIndex: sizeIndex,
            isDark: isDark,
            lang: lang,
            themeConfig: themeConfig,
            widgetData: widgetData,
            showLiveRate: showLiveRate,
            showReverseRate: showReverseRate,
          ),
        'quick_expense' => _buildQuickExpenseContent(
            sizeIndex: sizeIndex,
            isDark: isDark,
            lang: lang,
            themeConfig: themeConfig,
            widgetData: widgetData,
            showRemainingBudget: showRemainingBudget,
            showLastExpense: showLastExpense,
          ),
        _ => _buildTripContent(
            sizeIndex: sizeIndex,
            isDark: isDark,
            lang: lang,
            l10n: l10n,
            themeConfig: themeConfig,
            widgetData: widgetData,
            showCountdown: showCountdown,
            showPacking: showPacking,
            showBudget: showBudget,
          ),
      },
    );
  }

  // ===========================================================================
  // 1. WORLD MAP CONTENT BUILDERS
  // ===========================================================================

  static Widget _buildWorldMapContent({
    required int sizeIndex,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required int visitedCount,
    required int livedCount,
    required int wishlistCount,
    required int continentsCount,
    required double worldPercent,
    required Map<String, Color> colorMap,
    required bool showContinents,
    required bool showWishlist,
  }) {
    switch (sizeIndex) {
      case 0:
        return _buildSmallWorldMap(
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          visitedCount: visitedCount,
          wishlistCount: wishlistCount,
          continentsCount: continentsCount,
          worldPercent: worldPercent,
          showContinents: showContinents,
          showWishlist: showWishlist,
        );
      case 1:
        return _buildMediumWorldMap(
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          visitedCount: visitedCount,
          wishlistCount: wishlistCount,
          continentsCount: continentsCount,
          worldPercent: worldPercent,
          colorMap: colorMap,
          showContinents: showContinents,
          showWishlist: showWishlist,
        );
      case 2:
      default:
        return _buildLargeWorldMap(
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          visitedCount: visitedCount,
          livedCount: livedCount,
          wishlistCount: wishlistCount,
          continentsCount: continentsCount,
          worldPercent: worldPercent,
          colorMap: colorMap,
          showContinents: showContinents,
          showWishlist: showWishlist,
        );
    }
  }

  static Widget _buildSmallWorldMap({
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required int visitedCount,
    required int wishlistCount,
    required int continentsCount,
    required double worldPercent,
    required bool showContinents,
    required bool showWishlist,
  }) {
    final visitedTitle = AppWidgetLocalization.getVisitedTitle(lang, visitedCount);
    final continentsSub = AppWidgetLocalization.getContinentsSubtitle(lang, continentsCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.public_rounded, size: 13, color: themeConfig.accentColor),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                'PackBuddy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '%${worldPercent.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Big Prominent Stat
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$visitedCount',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: themeConfig.accentColor,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              visitedTitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: themeConfig.titleTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (showContinents)
              Text(
                continentsSub,
                style: TextStyle(
                  fontSize: 9.5,
                  color: themeConfig.subtitleTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),

        // Bottom progress & stats
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (worldPercent / 100.0).clamp(0.0, 1.0),
                minHeight: 3.5,
                backgroundColor: themeConfig.unvisitedLandColor.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(themeConfig.accentColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '✈️ $visitedCount',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
                ),
                if (showWishlist)
                  Text(
                    '🌟 $wishlistCount',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildMediumWorldMap({
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required int visitedCount,
    required int wishlistCount,
    required int continentsCount,
    required double worldPercent,
    required Map<String, Color> colorMap,
    required bool showContinents,
    required bool showWishlist,
  }) {
    final worldHeader = AppWidgetLocalization.getWorldHeader(lang);
    final visitedTitle = AppWidgetLocalization.getVisitedTitle(lang, visitedCount);
    final explorationRateLabel = AppWidgetLocalization.getExplorationRateLabel(lang);
    final visitedStatLabel = AppWidgetLocalization.getVisitedStatLabel(lang, visitedCount);
    final wishlistStatLabel = AppWidgetLocalization.getWishlistStatLabel(lang, wishlistCount);
    final continentsStatLabel = AppWidgetLocalization.getContinentsStatLabel(lang, continentsCount);

    final unvisitedLandColor = themeConfig.unvisitedLandColor;
    final countryBorderColor = themeConfig.countryBorderColor;
    final oceanColor = themeConfig.oceanColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Stats & Progress
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.public_rounded, size: 14, color: themeConfig.accentColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            worldHeader,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: themeConfig.accentColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeConfig.badgeBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '%${worldPercent.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Title
              Text(
                visitedTitle,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: themeConfig.titleTextColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    explorationRateLabel,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: themeConfig.subtitleTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (worldPercent / 100.0).clamp(0.0, 1.0),
                      minHeight: 3.5,
                      backgroundColor: themeConfig.unvisitedLandColor.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(themeConfig.accentColor),
                    ),
                  ),
                ],
              ),

              // Bottom row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      visitedStatLabel,
                      style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showWishlist) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        wishlistStatLabel,
                        style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Right Column: Miniature Painted World Map Card
        SizedBox(
          width: 110,
          child: Container(
            decoration: BoxDecoration(
              color: oceanColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: themeConfig.mapBorderColor,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 2000 / 857,
                        child: SimpleMap(
                          instructions: SMapWorld.instructions,
                          defaultColor: unvisitedLandColor,
                          colors: colorMap,
                          countryBorder: CountryBorder(
                            color: countryBorderColor,
                            width: 0.35,
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                if (showContinents) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: themeConfig.statBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      continentsStatLabel,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: themeConfig.accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildLargeWorldMap({
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required int visitedCount,
    required int livedCount,
    required int wishlistCount,
    required int continentsCount,
    required double worldPercent,
    required Map<String, Color> colorMap,
    required bool showContinents,
    required bool showWishlist,
  }) {
    final worldHeader = AppWidgetLocalization.getWorldHeader(lang);
    final continentsStatLabel = AppWidgetLocalization.getContinentsStatLabel(lang, continentsCount);

    final legendLived = AppWidgetLocalization.getLegendLived(lang);
    final legendVisited = AppWidgetLocalization.getLegendVisited(lang);
    final legendWishlist = AppWidgetLocalization.getLegendWishlist(lang);

    final unvisitedLandColor = themeConfig.unvisitedLandColor;
    final countryBorderColor = themeConfig.countryBorderColor;
    final oceanColor = themeConfig.oceanColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Row(
          children: [
            Icon(Icons.public_rounded, size: 16, color: themeConfig.accentColor),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                worldHeader,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '%${worldPercent.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Hero: Large Vector World Map with Floating Pill Legend
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: oceanColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeConfig.mapBorderColor,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 2000 / 857,
                      child: SimpleMap(
                        instructions: SMapWorld.instructions,
                        defaultColor: unvisitedLandColor,
                        colors: colorMap,
                        countryBorder: CountryBorder(
                          color: countryBorderColor,
                          width: 0.45,
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Floating Legend Pill Bar positioned at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeConfig.legendBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: themeConfig.legendBorderColor,
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLegendIndicator(themeConfig.livedColor, '$legendLived ($livedCount)', themeConfig.legendTextColor),
                            const SizedBox(width: 8),
                            _buildLegendIndicator(themeConfig.visitedColor, '$legendVisited ($visitedCount)', themeConfig.legendTextColor),
                            if (showWishlist) ...[
                              const SizedBox(width: 8),
                              _buildLegendIndicator(themeConfig.wishlistColor, '$legendWishlist ($wishlistCount)', themeConfig.legendTextColor),
                            ],
                            if (showContinents && continentsCount > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                continentsStatLabel,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: themeConfig.legendTextColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildLegendIndicator(Color color, String text, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3.5),
        Text(
          text,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. TRIP CONTENT BUILDERS
  // ===========================================================================

  static Widget _buildTripContent({
    required int sizeIndex,
    required bool isDark,
    required String lang,
    AppLocalizations? l10n,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showCountdown,
    required bool showPacking,
    required bool showBudget,
  }) {
    switch (sizeIndex) {
      case 0:
        return _buildSmallTrip(
          isDark: isDark,
          lang: lang,
          l10n: l10n,
          themeConfig: themeConfig,
          widgetData: widgetData,
          showCountdown: showCountdown,
          showPacking: showPacking,
          showBudget: showBudget,
        );
      case 1:
        return _buildMediumTrip(
          isDark: isDark,
          lang: lang,
          l10n: l10n,
          themeConfig: themeConfig,
          widgetData: widgetData,
          showCountdown: showCountdown,
          showPacking: showPacking,
          showBudget: showBudget,
        );
      case 2:
      default:
        return _buildLargeTrip(
          isDark: isDark,
          lang: lang,
          l10n: l10n,
          themeConfig: themeConfig,
          widgetData: widgetData,
          showCountdown: showCountdown,
          showPacking: showPacking,
          showBudget: showBudget,
        );
    }
  }

  static Widget _buildSmallTrip({
    required bool isDark,
    required String lang,
    AppLocalizations? l10n,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showCountdown,
    required bool showPacking,
    required bool showBudget,
  }) {
    final hasTrip = widgetData?.hasUpcomingTrip ?? false;
    final defaultDestination = AppWidgetLocalization.getDefaultDestination(lang);
    final tripTitle = widgetData?.tripTitle ?? (lang == 'tr' ? 'Roma Tatili' : 'Rome Trip');
    final destination = (widgetData?.destination != null && widgetData!.destination!.isNotEmpty)
        ? widgetData.destination!
        : defaultDestination;
    final int days = hasTrip ? (widgetData?.daysUntil ?? 0) : 14;
    final String daysText = AppWidgetLocalization.formatDaysUntil(lang, days);
    final int totalItems = hasTrip ? (widgetData?.totalItems ?? 0) : 24;
    final int packedItems = hasTrip ? (widgetData?.packedItems ?? 0) : 18;
    final double packingProgress = totalItems > 0 ? (packedItems / totalItems).clamp(0.0, 1.0) : 0.75;
    final userCurrency = widgetData?.userCurrency ?? 'TRY';
    final String budgetSpent = (widgetData?.budgetSpent != null && widgetData!.budgetSpent!.isNotEmpty)
        ? widgetData.budgetSpent!
        : (userCurrency == 'TRY' ? '₺3,450.00' : '\$450.00');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.flight_takeoff_rounded, size: 13, color: themeConfig.accentColor),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                'PackBuddy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
              ),
            ),
            if (showCountdown) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: themeConfig.badgeBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    daysText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        // Destination / Trip Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tripTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: themeConfig.titleTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (destination.isNotEmpty)
              Text(
                destination,
                style: TextStyle(
                  fontSize: 9.5,
                  color: themeConfig.subtitleTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),

        // Bottom Stats
        if (showPacking || showBudget)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: themeConfig.statBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showPacking) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${AppWidgetLocalization.getPackingLabel(lang)}: $packedItems/$totalItems',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: themeConfig.accentColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '%${(packingProgress * 100).toInt()}',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: themeConfig.subtitleTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: packingProgress,
                      minHeight: 3.5,
                      backgroundColor: themeConfig.unvisitedLandColor.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(themeConfig.accentColor),
                    ),
                  ),
                ],
                if (showBudget && !showPacking)
                  Text(
                    '${AppWidgetLocalization.getSpentLabel(lang)}: $budgetSpent',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: themeConfig.accentColor,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static Widget _buildMediumTrip({
    required bool isDark,
    required String lang,
    AppLocalizations? l10n,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showCountdown,
    required bool showPacking,
    required bool showBudget,
  }) {
    final hasTrip = widgetData?.hasUpcomingTrip ?? false;
    final tripTitle = widgetData?.tripTitle ?? (lang == 'tr' ? 'Roma Tatili' : 'Rome Trip');
    final defaultDestination = AppWidgetLocalization.getDefaultDestination(lang);
    final destination = (widgetData?.destination != null && widgetData!.destination!.isNotEmpty)
        ? widgetData.destination!
        : defaultDestination;
    final int days = hasTrip ? (widgetData?.daysUntil ?? 0) : 14;
    final String daysText = AppWidgetLocalization.formatDaysUntil(lang, days);
    final int totalItems = hasTrip ? (widgetData?.totalItems ?? 0) : 24;
    final int packedItems = hasTrip ? (widgetData?.packedItems ?? 0) : 18;
    final double packingProgress = totalItems > 0 ? (packedItems / totalItems).clamp(0.0, 1.0) : 0.75;
    final userCurrency = widgetData?.userCurrency ?? 'TRY';
    final String budgetSpent = (widgetData?.budgetSpent != null && widgetData!.budgetSpent!.isNotEmpty)
        ? widgetData.budgetSpent!
        : (userCurrency == 'TRY' ? '₺3,450.00' : '\$450.00');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Trip Info
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.flight_takeoff_rounded, size: 14, color: themeConfig.accentColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      AppWidgetLocalization.getTripHeader(lang),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: themeConfig.accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Title & Destination
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tripTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: themeConfig.titleTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (destination.isNotEmpty)
                    Text(
                      destination,
                      style: TextStyle(
                        fontSize: 10,
                        color: themeConfig.subtitleTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),

              if (showCountdown)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: themeConfig.badgeBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    daysText,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Right Column: Packing & Budget Cards
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showPacking)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: themeConfig.statBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              AppWidgetLocalization.getPackingLabel(lang),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: themeConfig.subtitleTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '%${(packingProgress * 100).toInt()}',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: themeConfig.titleTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: packingProgress,
                          minHeight: 3.5,
                          backgroundColor: themeConfig.unvisitedLandColor.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(themeConfig.accentColor),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$packedItems/$totalItems',
                        style: TextStyle(
                          fontSize: 9,
                          color: themeConfig.subtitleTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

              if (showBudget) ...[
                if (showPacking) const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: themeConfig.statBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppWidgetLocalization.getSpentLabel(lang),
                        style: TextStyle(
                          fontSize: 8.5,
                          color: themeConfig.subtitleTextColor,
                        ),
                      ),
                      Text(
                        budgetSpent,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: themeConfig.accentColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildLargeTrip({
    required bool isDark,
    required String lang,
    AppLocalizations? l10n,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showCountdown,
    required bool showPacking,
    required bool showBudget,
  }) {
    final hasTrip = widgetData?.hasUpcomingTrip ?? false;
    final tripTitle = widgetData?.tripTitle ?? (lang == 'tr' ? 'Roma Tatili' : 'Rome Trip');
    final defaultDestination = AppWidgetLocalization.getDefaultDestination(lang);
    final destination = (widgetData?.destination != null && widgetData!.destination!.isNotEmpty)
        ? widgetData.destination!
        : defaultDestination;
    final int days = hasTrip ? (widgetData?.daysUntil ?? 0) : 14;
    final String daysText = AppWidgetLocalization.formatDaysUntil(lang, days);
    final int totalItems = hasTrip ? (widgetData?.totalItems ?? 0) : 24;
    final int packedItems = hasTrip ? (widgetData?.packedItems ?? 0) : 18;
    final double packingProgress = totalItems > 0 ? (packedItems / totalItems).clamp(0.0, 1.0) : 0.75;
    final userCurrency = widgetData?.userCurrency ?? 'TRY';
    final String budgetSpent = (widgetData?.budgetSpent != null && widgetData!.budgetSpent!.isNotEmpty)
        ? widgetData.budgetSpent!
        : (userCurrency == 'TRY' ? '₺3,450.00' : '\$450.00');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Row(
          children: [
            Icon(Icons.flight_takeoff_rounded, size: 16, color: themeConfig.accentColor),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                AppWidgetLocalization.getTripHeader(lang),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showCountdown) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: themeConfig.badgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  daysText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        // Destination Showcase Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tripTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: themeConfig.titleTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (destination.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  destination,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: themeConfig.subtitleTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Packing Card
        if (showPacking)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeConfig.statBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${AppWidgetLocalization.getPackingLabel(lang)}: $packedItems/$totalItems',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: themeConfig.titleTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '%${(packingProgress * 100).toInt()}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: themeConfig.titleTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: packingProgress,
                    minHeight: 4.5,
                    backgroundColor: themeConfig.unvisitedLandColor.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(themeConfig.accentColor),
                  ),
                ),
              ],
            ),
          ),

        if (showBudget) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeConfig.statBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${AppWidgetLocalization.getSpentLabel(lang)}: $budgetSpent',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: themeConfig.accentColor,
              ),
            ),
          ),
        ],

        const Spacer(),

        // Footer: Status
        Center(
          child: Text(
            AppWidgetLocalization.getCountdownActive(lang),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: themeConfig.subtitleTextColor,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. CURRENCY CONVERTER CONTENT BUILDERS
  // ===========================================================================

  static Widget _buildCurrencyContent({
    required int sizeIndex,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showLiveRate,
    required bool showReverseRate,
  }) {
    switch (sizeIndex) {
      case 0:
        return _buildSmallCurrency(
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          widgetData: widgetData,
          showLiveRate: showLiveRate,
        );
      case 1:
        return _buildMediumCurrency(
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          widgetData: widgetData,
          showLiveRate: showLiveRate,
          showReverseRate: showReverseRate,
        );
      case 2:
      default:
        return _buildLargeCurrency(
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          widgetData: widgetData,
          showLiveRate: showLiveRate,
          showReverseRate: showReverseRate,
        );
    }
  }

  static Widget _buildSmallCurrency({
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showLiveRate,
  }) {
    final currencyHeader = AppWidgetLocalization.getCurrencyHeader(lang);
    final userCurrency = widgetData?.userCurrency ?? 'TRY';
    final usdRate = widgetData?.currencyRateUSD ?? '34.25';
    final eurRate = widgetData?.currencyRateEUR ?? '37.10';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top header
        Row(
          children: [
            Icon(Icons.currency_exchange_rounded, size: 13, color: themeConfig.accentColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                currencyHeader,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
              ),
            ),
            if (showLiveRate) ...[
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 5),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                userCurrency,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Primary USD Rate Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1 USD',
                style: TextStyle(fontSize: 10, color: themeConfig.subtitleTextColor),
              ),
              Text(
                usdRate,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: themeConfig.titleTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Secondary EUR Rate Row
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 EUR',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: themeConfig.subtitleTextColor),
              ),
              Text(
                eurRate,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.titleTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildMediumCurrency({
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showLiveRate,
    required bool showReverseRate,
  }) {
    final currencyHeader = AppWidgetLocalization.getCurrencyHeader(lang);
    final userCurrency = widgetData?.userCurrency ?? 'TRY';
    final usdRate = widgetData?.currencyRateUSD ?? '34.25';
    final eurRate = widgetData?.currencyRateEUR ?? '37.10';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Rates
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currencyHeader,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Rates Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: themeConfig.statBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1 USD', style: TextStyle(fontSize: 9, color: themeConfig.subtitleTextColor)),
                          const SizedBox(height: 2),
                          Text(
                            usdRate,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: themeConfig.titleTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: themeConfig.statBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1 EUR', style: TextStyle(fontSize: 9, color: themeConfig.subtitleTextColor)),
                          const SizedBox(height: 2),
                          Text(
                            eurRate,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: themeConfig.titleTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom status
              Row(
                children: [
                  if (showLiveRate) ...[
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppWidgetLocalization.getLiveRatesLabel(lang),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Right Column: Badge Card
        SizedBox(
          width: 85,
          child: Container(
            decoration: BoxDecoration(
              color: themeConfig.statBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: themeConfig.accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.currency_exchange_rounded, size: 18, color: themeConfig.accentColor),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  userCurrency,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: themeConfig.titleTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildLargeCurrency({
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showLiveRate,
    required bool showReverseRate,
  }) {
    final currencyHeader = AppWidgetLocalization.getCurrencyHeader(lang);
    final userCurrency = widgetData?.userCurrency ?? 'TRY';
    final usdRate = widgetData?.currencyRateUSD ?? '34.25';
    final eurRate = widgetData?.currencyRateEUR ?? '37.10';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Row(
          children: [
            Icon(Icons.currency_exchange_rounded, size: 16, color: themeConfig.accentColor),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                currencyHeader,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                userCurrency,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Hero Rates Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeConfig.statBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1 USD', style: TextStyle(fontSize: 10.5, color: themeConfig.subtitleTextColor)),
                    const SizedBox(height: 3),
                    Text(
                      usdRate,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: themeConfig.titleTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeConfig.statBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1 EUR', style: TextStyle(fontSize: 10.5, color: themeConfig.subtitleTextColor)),
                    const SizedBox(height: 3),
                    Text(
                      eurRate,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: themeConfig.titleTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Quick Conversions Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppWidgetLocalization.getQuickConversionsLabel(lang),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.titleTextColor,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$10 ≈ 342.5', style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor)),
                  Text('\$50 ≈ 1,712.5', style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor)),
                  Text('\$100 ≈ 3,425.0', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: themeConfig.accentColor)),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Bottom Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppWidgetLocalization.getAutoSyncLabel(lang),
              style: TextStyle(fontSize: 9, color: themeConfig.subtitleTextColor),
            ),
            Text(
              AppWidgetLocalization.getOfflineReadyLabel(lang),
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. QUICK EXPENSE CONTENT BUILDERS
  // ===========================================================================

  static Widget _buildQuickExpenseContent({
    required int sizeIndex,
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showRemainingBudget,
    required bool showLastExpense,
  }) {
    switch (sizeIndex) {
      case 0:
        return _buildSmallQuickExpense(
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          widgetData: widgetData,
        );
      case 1:
        return _buildMediumQuickExpense(
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          widgetData: widgetData,
          showRemainingBudget: showRemainingBudget,
          showLastExpense: showLastExpense,
        );
      case 2:
      default:
        return _buildLargeQuickExpense(
          isDark: isDark,
          lang: lang,
          themeConfig: themeConfig,
          widgetData: widgetData,
          showRemainingBudget: showRemainingBudget,
          showLastExpense: showLastExpense,
        );
    }
  }

  static Widget _buildSmallQuickExpense({
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
  }) {
    final expenseHeader = AppWidgetLocalization.getExpenseHeader(lang);
    final userCurrency = widgetData?.userCurrency ?? 'TRY';
    final spentStr = (widgetData?.budgetSpent != null && widgetData!.budgetSpent!.isNotEmpty)
        ? widgetData.budgetSpent!
        : (userCurrency == 'TRY' ? '₺0.00' : '\$0.00');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, size: 13, color: themeConfig.accentColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                expenseHeader,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '+',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // Spent Label & Value
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppWidgetLocalization.getSpentLabel(lang),
              style: TextStyle(fontSize: 10, color: themeConfig.subtitleTextColor),
            ),
            const SizedBox(height: 1),
            Text(
              spentStr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: themeConfig.titleTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // Action Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: themeConfig.statBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppWidgetLocalization.getAddExpenseActionLabel(lang),
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: themeConfig.accentColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.add_circle_outline_rounded, size: 14, color: themeConfig.accentColor),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildMediumQuickExpense({
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showRemainingBudget,
    required bool showLastExpense,
  }) {
    final expenseHeader = AppWidgetLocalization.getExpenseHeader(lang);
    final userCurrency = widgetData?.userCurrency ?? 'TRY';
    final spentStr = (widgetData?.budgetSpent != null && widgetData!.budgetSpent!.isNotEmpty)
        ? widgetData.budgetSpent!
        : (userCurrency == 'TRY' ? '₺0.00' : '\$0.00');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Metrics
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      expenseHeader,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: themeConfig.accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeConfig.badgeBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppWidgetLocalization.getQuickLogBadge(lang),
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Spent Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeConfig.statBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppWidgetLocalization.getSpentBudgetLabel(lang),
                      style: TextStyle(fontSize: 9, color: themeConfig.subtitleTextColor),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      spentStr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: themeConfig.titleTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              if (showRemainingBudget && widgetData?.remainingBudget != null)
                Text(
                  '${AppWidgetLocalization.getRemainingBudgetTitle(lang)}: ${widgetData!.remainingBudget}',
                  style: TextStyle(fontSize: 9.5, color: themeConfig.subtitleTextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              if (showLastExpense && widgetData?.lastExpenseText != null)
                Text(
                  '${AppWidgetLocalization.getLastExpenseLabel(lang)}: ${widgetData!.lastExpenseText}',
                  style: TextStyle(fontSize: 9, color: themeConfig.subtitleTextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Right Column: Add Button
        SizedBox(
          width: 95,
          child: Container(
            decoration: BoxDecoration(
              color: themeConfig.badgeBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.add_rounded, size: 20, color: themeConfig.badgeBgColor),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppWidgetLocalization.getAddExpenseActionLabel(lang),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildLargeQuickExpense({
    required bool isDark,
    required String lang,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required bool showRemainingBudget,
    required bool showLastExpense,
  }) {
    final expenseHeader = AppWidgetLocalization.getExpenseHeader(lang);
    final userCurrency = widgetData?.userCurrency ?? 'TRY';
    final spentStr = (widgetData?.budgetSpent != null && widgetData!.budgetSpent!.isNotEmpty)
        ? widgetData.budgetSpent!
        : (userCurrency == 'TRY' ? '₺0.00' : '\$0.00');
    final remainingStr = widgetData?.remainingBudget ?? (userCurrency == 'TRY' ? '₺12,500.00' : '\$1,500.00');
    final lastExpenseStr = widgetData?.lastExpenseText ?? AppWidgetLocalization.getNoExpensesLoggedLabel(lang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, size: 16, color: themeConfig.accentColor),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                expenseHeader,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: themeConfig.accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: themeConfig.badgeBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppWidgetLocalization.getQuickLogBadge(lang),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Cards Row: Spent & Remaining
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeConfig.statBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppWidgetLocalization.getSpentBudgetLabel(lang),
                      style: TextStyle(fontSize: 10, color: themeConfig.subtitleTextColor),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      spentStr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: themeConfig.titleTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (showRemainingBudget) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeConfig.statBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppWidgetLocalization.getRemainingBudgetTitle(lang),
                        style: TextStyle(fontSize: 10, color: themeConfig.subtitleTextColor),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        remainingStr,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10B981),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        // Last Logged Expense Card
        if (showLastExpense)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeConfig.statBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppWidgetLocalization.getLastExpenseLabel(lang),
                  style: TextStyle(fontSize: 10, color: themeConfig.subtitleTextColor),
                ),
                const SizedBox(height: 2),
                Text(
                  lastExpenseStr,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: themeConfig.titleTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

        const Spacer(),

        // Full-Width Add Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: themeConfig.badgeBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  AppWidgetLocalization.getAddExpenseActionLabel(lang),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 5. MASTER FLUTTER RENDERER FOR NATIVE WIDGET IMAGES
  // ===========================================================================

  /// Renders a single widget card to bitmap image file via HomeWidget.renderFlutterWidget
  static Future<String?> renderCardToDisk({
    required String mode,
    required int sizeIndex,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required List<TravelCountry> countries,
    required String lang,
    bool showContinents = true,
    bool showWishlist = true,
    bool showCountdown = true,
    bool showPacking = true,
    bool showBudget = true,
    bool showLiveRate = true,
    bool showReverseRate = true,
    bool showRemainingBudget = true,
    bool showLastExpense = true,
  }) async {
    try {
      final size = switch (sizeIndex) {
        0 => const Size(smallSize, smallSize),
        1 => const Size(mediumWidth, mediumHeight),
        2 => const Size(largeWidth, largeHeight),
        _ => const Size(mediumWidth, mediumHeight),
      };

      final sizeName = switch (sizeIndex) {
        0 => 'small',
        1 => 'medium',
        2 => 'large',
        _ => 'medium',
      };

      final cardWidget = buildWidgetCard(
        mode: mode,
        sizeIndex: sizeIndex,
        themeConfig: themeConfig,
        widgetData: widgetData,
        countries: countries,
        lang: lang,
        showContinents: showContinents,
        showWishlist: showWishlist,
        showCountdown: showCountdown,
        showPacking: showPacking,
        showBudget: showBudget,
        showLiveRate: showLiveRate,
        showReverseRate: showReverseRate,
        showRemainingBudget: showRemainingBudget,
        showLastExpense: showLastExpense,
      );

      final appThemeData = themeConfig.isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
      final renderRoot = Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: appThemeData,
          child: Material(
            color: Colors.transparent,
            child: cardWidget,
          ),
        ),
      );

      final key = 'widget_card_${mode}_$sizeName';
      final path = await HomeWidget.renderFlutterWidget(
        renderRoot,
        key: key,
        logicalSize: size,
        pixelRatio: 3.0,
      );

      if (path.isNotEmpty) {
        await HomeWidget.saveWidgetData<String>(key, path);
        final activeMode = PreferencesService.instance.getWidgetMode();
        if (mode == activeMode) {
          await HomeWidget.saveWidgetData<String>('widget_card_$sizeName', path);
        }
      }

      return path;
    } catch (e) {
      debugPrint('[WidgetCardRenderer] Error rendering $mode size $sizeIndex: $e');
      return null;
    }
  }

  /// Renders all 3 sizes for the specified mode
  static Future<void> renderCardsForMode({
    required String mode,
    required WidgetThemeConfig themeConfig,
    required AppWidgetData? widgetData,
    required List<TravelCountry> countries,
    required String lang,
    bool showContinents = true,
    bool showWishlist = true,
    bool showCountdown = true,
    bool showPacking = true,
    bool showBudget = true,
    bool showLiveRate = true,
    bool showReverseRate = true,
    bool showRemainingBudget = true,
    bool showLastExpense = true,
  }) async {
    for (int sizeIndex = 0; sizeIndex < 3; sizeIndex++) {
      await renderCardToDisk(
        mode: mode,
        sizeIndex: sizeIndex,
        themeConfig: themeConfig,
        widgetData: widgetData,
        countries: countries,
        lang: lang,
        showContinents: showContinents,
        showWishlist: showWishlist,
        showCountdown: showCountdown,
        showPacking: showPacking,
        showBudget: showBudget,
        showLiveRate: showLiveRate,
        showReverseRate: showReverseRate,
        showRemainingBudget: showRemainingBudget,
        showLastExpense: showLastExpense,
      );
    }
  }

  /// Renders cards across all 4 modes so any placed widget displays a 1:1 identical preview
  static Future<void> renderAllModes({
    required AppWidgetData? payload,
    required List<TravelCountry> countries,
    required String lang,
  }) async {
    final prefs = PreferencesService.instance;
    final showContinents = prefs.isWidgetShowContinents();
    final showWishlist = prefs.isWidgetShowWishlist();
    final showCountdown = prefs.isWidgetShowCountdown();
    final showPacking = prefs.isWidgetShowPacking();
    final showBudget = prefs.isWidgetShowBudget();
    final showLiveRate = prefs.isWidgetShowLiveRate();
    final showReverseRate = prefs.isWidgetShowReverseRate();
    final showRemainingBudget = prefs.isWidgetShowRemainingBudget();
    final showLastExpense = prefs.isWidgetShowLastExpense();

    const modes = ['world_map', 'trip', 'currency_converter', 'quick_expense'];
    for (final mode in modes) {
      final themeKey = prefs.getWidgetThemeForMode(mode);
      final themeConfig = WidgetThemeConfig.fromKey(themeKey);

      await renderCardsForMode(
        mode: mode,
        themeConfig: themeConfig,
        widgetData: payload,
        countries: countries,
        lang: lang,
        showContinents: showContinents,
        showWishlist: showWishlist,
        showCountdown: showCountdown,
        showPacking: showPacking,
        showBudget: showBudget,
        showLiveRate: showLiveRate,
        showReverseRate: showReverseRate,
        showRemainingBudget: showRemainingBudget,
        showLastExpense: showLastExpense,
      );
    }
  }
}

