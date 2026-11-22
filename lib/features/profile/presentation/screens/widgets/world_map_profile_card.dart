import 'package:countries_world_map/countries_world_map.dart';
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/data/world_map_instructions.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Serene Voyage World Travel Map profile card showing live vector map visualization,
/// precise coverage statistics (percentage of the world explored vs. total painted),
/// proportional progress breakdown, and interactive inspection.
class WorldMapProfileCard extends StatelessWidget {
  final List<TravelCountry> countries;
  final bool isOwnProfile;
  final String? friendName;
  final List<String> mutualVisitedCodes;
  final VoidCallback? onOpenMap;

  const WorldMapProfileCard({
    super.key,
    required this.countries,
    this.isOwnProfile = true,
    this.friendName,
    this.mutualVisitedCodes = const [],
    this.onOpenMap,
  });

  /// Robust helper to parse raw Firestore / JSON map structures into typed [TravelCountry] list
  static List<TravelCountry> parseCountriesFromRaw(dynamic raw) {
    if (raw == null) return WorldCountriesData.allCountries;
    if (raw is List<TravelCountry>) return raw;

    final Map<String, dynamic> mapped = {};
    if (raw is Map) {
      for (final entry in raw.entries) {
        final code = entry.key.toString().toUpperCase().trim();
        final val = entry.value;
        if (val is Map) {
          mapped[code] = Map<String, dynamic>.from(val);
        } else if (val is String) {
          mapped[code] = {'code': code, 'status': val};
        }
      }
    } else if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final code = (item['code'] ?? item['id'])?.toString().toUpperCase().trim();
          if (code != null && code.isNotEmpty) {
            mapped[code] = Map<String, dynamic>.from(item);
          }
        } else if (item is String) {
          final code = item.toUpperCase().trim();
          mapped[code] = {'code': code, 'status': 'visited'};
        }
      }
    }

    return WorldCountriesData.allCountries.map((base) {
      final key = base.code.toUpperCase().trim();
      if (mapped.containsKey(key)) {
        try {
          return TravelCountry.fromJson(mapped[key]!, base);
        } catch (_) {
          return base;
        }
      }
      return base;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final friendLabel = friendName ?? l10n.worldMapFriendFallbackName;

    // 1. Calculate statistics
    final effectiveCountries = countries.isNotEmpty ? countries : WorldCountriesData.allCountries;
    final totalCountries = effectiveCountries.isNotEmpty ? effectiveCountries.length : 197;

    final livedCountries = effectiveCountries.where((c) => c.isLived).toList();
    final visitedOnlyCountries = effectiveCountries.where((c) => c.isVisited).toList();
    final wishlistCountries = effectiveCountries.where((c) => c.isWishlist).toList();

    final livedCount = livedCountries.length;
    final visitedOnlyCount = visitedOnlyCountries.length;
    final visitedAndLivedCount = livedCount + visitedOnlyCount;
    final wishlistCount = wishlistCountries.length;
    final totalPaintedCount = visitedAndLivedCount + wishlistCount;
    final remainingCount = (totalCountries - totalPaintedCount).clamp(0, totalCountries);

    final exploredPct = totalCountries > 0 ? (visitedAndLivedCount / totalCountries) * 100 : 0.0;

    const allContinents = ['Europe', 'Asia', 'Americas', 'Africa', 'Oceania'];
    final visitedOrLived = effectiveCountries.where((c) => c.isVisited || c.isLived);
    final continentsExplored = allContinents.where((cont) => visitedOrLived.any((c) => c.isInContinent(cont))).length;

    // 2. Build map polygon colors
    final colorMap = <String, Color>{};
    for (final c in effectiveCountries) {
      final code = c.code.toLowerCase().trim();
      if (c.isLived) {
        colorMap[code] = const Color(0xFF10B981); // Emerald Green
      } else if (c.isVisited) {
        colorMap[code] = AppColors.primaryAmber; // Golden Amber
      } else if (c.isWishlist) {
        colorMap[code] = const Color(0xFFEF4444); // Coral Red
      }
    }

    // Map Northern Cyprus status onto Cyprus polygon if set
    final nc = effectiveCountries.where((c) => c.code == 'NC').firstOrNull;
    if (nc != null && (colorMap['cy'] == null || nc.isLived || nc.isVisited)) {
      if (nc.isLived) {
        colorMap['cy'] = const Color(0xFF10B981);
      } else if (nc.isVisited) {
        colorMap['cy'] = AppColors.primaryAmber;
      } else if (nc.isWishlist && colorMap['cy'] == null) {
        colorMap['cy'] = const Color(0xFFEF4444);
      }
    }

    final unvisitedLandColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFD6DEE7);
    final oceanColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF3F8);

    void handleCardTap() {
      if (isOwnProfile) {
        if (onOpenMap != null) {
          onOpenMap!();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TravelMapScreen()),
          );
        }
      } else {
        _showZoomableMapDialog(context, effectiveCountries, colorMap, isDark, l10n, friendLabel);
      }
    }

    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Title & Action Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.public_rounded,
                  color: AppColors.primaryAmber,
                  size: 19,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.worldMapCardTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isOwnProfile
                          ? l10n.worldMapLiveCoverage
                          : l10n.worldMapFriendMap(friendLabel),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: handleCardTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isOwnProfile
                        ? '${l10n.worldMapOpenMap} ↗'
                        : '${l10n.worldMapInspect} 🔍',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Vector Map Canvas Preview
          InkWell(
            onTap: handleCardTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: oceanColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    RepaintBoundary(child: AspectRatio(
                      aspectRatio: 2000 / 857,
                      child: SimpleMap(
                        instructions: WorldMapInstructions.instructions,
                        defaultColor: unvisitedLandColor,
                        colors: colorMap,
                        countryBorder: CountryBorder(
                          color: borderColor,
                          width: 0.45,
                        ),
                        fit: BoxFit.contain,
                      ),
                    )),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOwnProfile ? Icons.touch_app_rounded : Icons.zoom_in_rounded,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOwnProfile
                                  ? l10n.worldMapGoToMap
                                  : l10n.worldMapZoomInspect,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Highlight Metric Card: Dünya Keşfi / World Explored
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryAmber.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryAmber.withValues(alpha: isDark ? 0.35 : 0.22),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.explore_rounded, size: 16, color: AppColors.primaryAmber),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.worldMapExplored,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.worldMapVisitedOfTotal(visitedAndLivedCount, totalCountries),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '%${exploredPct.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryAmber,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Proportional Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 7,
              child: Row(
                children: [
                  if (livedCount > 0)
                    Expanded(
                      flex: livedCount,
                      child: Container(color: const Color(0xFF10B981)),
                    ),
                  if (visitedOnlyCount > 0)
                    Expanded(
                      flex: visitedOnlyCount,
                      child: Container(color: AppColors.primaryAmber),
                    ),
                  if (wishlistCount > 0)
                    Expanded(
                      flex: wishlistCount,
                      child: Container(color: const Color(0xFFEF4444)),
                    ),
                  if (remainingCount > 0)
                    Expanded(
                      flex: remainingCount,
                      child: Container(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 5. Breakdown Chips Row (1 satıra sığdırıldı)
          Row(
            children: [
              Expanded(
                child: _buildMetricChip(
                  dotColor: const Color(0xFF10B981),
                  label: l10n.worldMapChipLived,
                  count: livedCount,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildMetricChip(
                  dotColor: AppColors.primaryAmber,
                  label: l10n.mapLegendBeen,
                  count: visitedOnlyCount,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildMetricChip(
                  dotColor: const Color(0xFFEF4444),
                  label: l10n.mapLegendWant,
                  count: wishlistCount,
                  theme: theme,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _buildMetricChip(
                  dotColor: const Color(0xFF3B82F6),
                  label: l10n.worldMapContinentsChip,
                  count: continentsExplored,
                  suffix: '/5',
                  theme: theme,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // 6. Mutual Countries Highlights (For Friend's Profile)
          if (!isOwnProfile && mutualVisitedCodes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Text('🤝', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.worldMapMutualCountries(mutualVisitedCodes.length, _formatMutualCodes(mutualVisitedCodes)),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatMutualCodes(List<String> codes) {
    return codes.take(6).map((c) {
      final country = Country.findByCode(c);
      if (country != null) {
        return '${country.flag} $c';
      }
      return c;
    }).join(' • ') + (codes.length > 6 ? ' (+${codes.length - 6})' : '');
  }

  Widget _buildMetricChip({
    required Color dotColor,
    required String label,
    required int count,
    String? suffix,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 0.7,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6.5,
              height: 6.5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 3.5),
            Text(
              suffix != null ? '$count$suffix' : '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays an interactive zoomable modal preview of the friend's world map
  void _showZoomableMapDialog(
    BuildContext context,
    List<TravelCountry> effectiveCountries,
    Map<String, Color> colorMap,
    bool isDark,
    AppLocalizations l10n,
    String friendLabel,
  ) {
    final unvisitedLandColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFD6DEE7);
    final oceanColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF3F8);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.worldMapFriendWorldMap(friendLabel),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.worldMapPinchToExplore,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Interactive Zoomable Canvas
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: oceanColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 25.0,
                      boundaryMargin: const EdgeInsets.all(80),
                      child: Center(
                        child: RepaintBoundary(child: SimpleMap(
                          instructions: WorldMapInstructions.instructions,
                          defaultColor: unvisitedLandColor,
                          colors: colorMap,
                          countryBorder: CountryBorder(
                            color: borderColor,
                            width: 0.5,
                          ),
                          fit: BoxFit.contain,
                        )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Legend row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(const Color(0xFF10B981), l10n.worldMapChipLived, isDark),
                    _buildLegendItem(AppColors.primaryAmber, l10n.mapLegendBeen, isDark),
                    _buildLegendItem(const Color(0xFFEF4444), l10n.mapLegendWant, isDark),
                    _buildLegendItem(
                      isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      l10n.mapLegendUnvisited,
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
