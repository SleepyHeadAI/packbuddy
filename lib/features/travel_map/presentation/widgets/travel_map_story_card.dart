import 'package:flutter/material.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/country_flag.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Available story layout templates
enum StoryCardLayout {
  classic,   // 🌟 Klasik (Balanced Map + Stats + Flag Strip)
  passport,  // 🛂 Pasaport (Official Travel Passport & Visa Stamps Edition)
  minimal,   // 🧊 Minimal (Editorial Typography & Clean Outline)
  showcase,  // 🖼️ Vitrin (Immersive Large Map & Glassmorphism HUD)
}

extension StoryCardLayoutX on StoryCardLayout {
  String getLocalizedName(AppLocalizations? l10n, {String? locale}) {
    final isTr = locale == 'tr';
    switch (this) {
      case StoryCardLayout.classic:
        return l10n?.storyLayoutClassic ?? (isTr ? 'Klasik' : 'Classic');
      case StoryCardLayout.passport:
        return l10n?.storyLayoutPassport ?? (isTr ? 'Pasaport' : 'Passport');
      case StoryCardLayout.minimal:
        return l10n?.storyLayoutMinimal ?? (isTr ? 'Minimal' : 'Minimal');
      case StoryCardLayout.showcase:
        return l10n?.storyLayoutShowcase ?? (isTr ? 'Vitrin' : 'Showcase');
    }
  }

  String get emoji {
    switch (this) {
      case StoryCardLayout.classic:
        return '🌟';
      case StoryCardLayout.passport:
        return '🛂';
      case StoryCardLayout.minimal:
        return '🧊';
      case StoryCardLayout.showcase:
        return '🖼️';
    }
  }
}

/// Available elevated design styles and color palettes for social media stories (3 Dark, 3 Light)
enum StoryCardTheme {
  // 3 Dark Themes
  midnight,    // 🌌 Gece Kaşifi (Midnight Obsidian & Neon Glow)
  sunset,      // 🌅 Gün Batımı (Twilight Velvet Violet & Sunset Flame)
  emerald,     // 🌲 Aurora (Nordic Emerald & Warm Gold)

  // 3 Light Themes
  minimalLight,// ❄️ İskandinav (Pure Porcelain White & Slate)
  sandLight,   // 🏖️ Sahra (Warm Sahara Linen & Terracotta Gold)
  oceanLight,  // 🌊 Akdeniz (Mediterranean Azure & Coastal Sky)
}

/// Color and styling definition for a StoryCardTheme
class StoryCardPalette {
  final String label;
  final String emoji;
  final LinearGradient backgroundGradient;
  final Color mapBackground;
  final Color unvisitedLandColor;
  final Color mapBorderColor;
  final Color livedColor;
  final Color visitedColor;
  final Color wishlistColor;
  final Color textColor;
  final Color subtextColor;
  final Color cardBorder;
  final Color tileBackground;
  final Color tileBorder;
  final LinearGradient heroGradient;
  final Color heroBorder;
  final LinearGradient logoGradient;
  final Color accentColor;
  final bool isLight;
  final List<Color> previewColors;

  const StoryCardPalette({
    required this.label,
    required this.emoji,
    required this.backgroundGradient,
    required this.mapBackground,
    required this.unvisitedLandColor,
    required this.mapBorderColor,
    required this.livedColor,
    required this.visitedColor,
    required this.wishlistColor,
    required this.textColor,
    required this.subtextColor,
    required this.cardBorder,
    required this.tileBackground,
    required this.tileBorder,
    required this.heroGradient,
    required this.heroBorder,
    required this.logoGradient,
    required this.accentColor,
    required this.isLight,
    required this.previewColors,
  });

  static StoryCardPalette forTheme(StoryCardTheme theme, {String? locale, AppLocalizations? l10n}) {
    final isTr = locale == 'tr';
    switch (theme) {
      case StoryCardTheme.midnight:
        return StoryCardPalette(
          label: l10n?.storyThemeMidnight ?? (isTr ? 'Gece' : 'Midnight'),
          emoji: '🌌',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFF070A12), Color(0xFF0F172A), Color(0xFF030712)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF080D1A),
          unvisitedLandColor: const Color(0xFF1E293B),
          mapBorderColor: const Color(0xFF0F172A),
          livedColor: const Color(0xFF10B981), // Vivid Emerald
          visitedColor: const Color(0xFFF97316), // Neon Sunset Orange
          wishlistColor: const Color(0xFFF43F5E), // Rose Coral
          textColor: Colors.white,
          subtextColor: const Color(0xFF94A3B8),
          cardBorder: Colors.white.withValues(alpha: 0.14),
          tileBackground: Colors.white.withValues(alpha: 0.05),
          tileBorder: Colors.white.withValues(alpha: 0.10),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFF97316).withValues(alpha: 0.22),
              const Color(0xFF0284C7).withValues(alpha: 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFF97316).withValues(alpha: 0.35),
          logoGradient: const LinearGradient(
            colors: [Color(0xFFEA580C), Color(0xFFF97316)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFF97316),
          isLight: false,
          previewColors: const [Color(0xFF080D1A), Color(0xFFF97316), Color(0xFF10B981)],
        );

      case StoryCardTheme.sunset:
        return StoryCardPalette(
          label: l10n?.storyThemeSunset ?? (isTr ? 'Gün Batımı' : 'Sunset'),
          emoji: '🌅',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFF1C082E), Color(0xFF2E0F45), Color(0xFF13041F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF150622),
          unvisitedLandColor: const Color(0xFF38184C),
          mapBorderColor: const Color(0xFF1D0A30),
          livedColor: const Color(0xFFF59E0B), // Golden Sun
          visitedColor: const Color(0xFFFF5722), // Sunset Flame
          wishlistColor: const Color(0xFFEC4899), // Neon Fuchsia
          textColor: Colors.white,
          subtextColor: const Color(0xFFF3E8FF).withValues(alpha: 0.75),
          cardBorder: const Color(0xFFFF5722).withValues(alpha: 0.28),
          tileBackground: const Color(0xFFFF5722).withValues(alpha: 0.09),
          tileBorder: const Color(0xFFFF5722).withValues(alpha: 0.18),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFFF5722).withValues(alpha: 0.30),
              const Color(0xFFEC4899).withValues(alpha: 0.20),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFFF5722).withValues(alpha: 0.45),
          logoGradient: const LinearGradient(
            colors: [Color(0xFFFF5722), Color(0xFFEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFFF5722),
          isLight: false,
          previewColors: const [Color(0xFF2E0F45), Color(0xFFFF5722), Color(0xFFF59E0B)],
        );

      case StoryCardTheme.emerald:
        return StoryCardPalette(
          label: l10n?.storyThemeAtlas ?? (isTr ? 'Aurora' : 'Aurora'),
          emoji: '🌲',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFF041913), Color(0xFF0A2D22), Color(0xFF02120D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF03140F),
          unvisitedLandColor: const Color(0xFF13382D),
          mapBorderColor: const Color(0xFF09251D),
          livedColor: const Color(0xFF34D399), // Mint Green
          visitedColor: const Color(0xFF10B981), // Emerald
          wishlistColor: const Color(0xFFFBBF24), // Champagne Gold
          textColor: Colors.white,
          subtextColor: const Color(0xFFD1FAE5).withValues(alpha: 0.78),
          cardBorder: const Color(0xFF10B981).withValues(alpha: 0.28),
          tileBackground: const Color(0xFF10B981).withValues(alpha: 0.09),
          tileBorder: const Color(0xFF10B981).withValues(alpha: 0.18),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.28),
              const Color(0xFFFBBF24).withValues(alpha: 0.16),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFF10B981).withValues(alpha: 0.42),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFF10B981),
          isLight: false,
          previewColors: const [Color(0xFF0A2D22), Color(0xFF10B981), Color(0xFFFBBF24)],
        );

      case StoryCardTheme.minimalLight:
        return StoryCardPalette(
          label: l10n?.storyThemeMinimal ?? (isTr ? 'İskandinav' : 'Nordic'),
          emoji: '❄️',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFFE0F2FE),
          unvisitedLandColor: const Color(0xFFCBD5E1),
          mapBorderColor: const Color(0xFF94A3B8),
          livedColor: const Color(0xFF059669),
          visitedColor: const Color(0xFFEA580C),
          wishlistColor: const Color(0xFFE11D48),
          textColor: const Color(0xFF0F172A),
          subtextColor: const Color(0xFF475569),
          cardBorder: const Color(0xFFCBD5E1),
          tileBackground: Colors.white,
          tileBorder: const Color(0xFFE2E8F0),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFEA580C).withValues(alpha: 0.12),
              const Color(0xFF0284C7).withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFEA580C).withValues(alpha: 0.32),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFEA580C),
          isLight: true,
          previewColors: const [Color(0xFFFFFFFF), Color(0xFFEA580C), Color(0xFF0F172A)],
        );

      case StoryCardTheme.sandLight:
        return StoryCardPalette(
          label: l10n?.storyThemeDune ?? (isTr ? 'Sahra' : 'Sahara'),
          emoji: '🏖️',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFFFFFDF9), Color(0xFFFAF5ED), Color(0xFFF2ECE1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFFEAF5F2),
          unvisitedLandColor: const Color(0xFFDFD5C4),
          mapBorderColor: const Color(0xFFC7BBAA),
          livedColor: const Color(0xFF059669),
          visitedColor: const Color(0xFFD97706),
          wishlistColor: const Color(0xFFDC2626),
          textColor: const Color(0xFF292524),
          subtextColor: const Color(0xFF78716C),
          cardBorder: const Color(0xFFD8CCB8),
          tileBackground: Colors.white.withValues(alpha: 0.94),
          tileBorder: const Color(0xFFE7DEC8),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFD97706).withValues(alpha: 0.16),
              const Color(0xFF059669).withValues(alpha: 0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFD97706).withValues(alpha: 0.36),
          logoGradient: const LinearGradient(
            colors: [Color(0xFFB45309), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFD97706),
          isLight: true,
          previewColors: const [Color(0xFFFAF5ED), Color(0xFFD97706), Color(0xFF059669)],
        );

      case StoryCardTheme.oceanLight:
        return StoryCardPalette(
          label: l10n?.storyThemeOcean ?? (isTr ? 'Akdeniz' : 'Mediterranean'),
          emoji: '🌊',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF7DD3FC),
          unvisitedLandColor: Colors.white,
          mapBorderColor: const Color(0xFF38BDF8),
          livedColor: const Color(0xFF0D9488),
          visitedColor: const Color(0xFF0284C7),
          wishlistColor: const Color(0xFFF43F5E),
          textColor: const Color(0xFF0C4A6E),
          subtextColor: const Color(0xFF0369A1),
          cardBorder: const Color(0xFF7DD3FC),
          tileBackground: Colors.white.withValues(alpha: 0.94),
          tileBorder: const Color(0xFFBAE6FD),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFF0284C7).withValues(alpha: 0.16),
              const Color(0xFF38BDF8).withValues(alpha: 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFF0284C7).withValues(alpha: 0.38),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFF0284C7),
          isLight: true,
          previewColors: const [Color(0xFFE0F2FE), Color(0xFF0284C7), Color(0xFFF43F5E)],
        );
    }
  }
}

/// 9:16 Social Story Card designed for Instagram & Snapchat stories with selectable layouts & themes
class TravelMapStoryCard extends StatelessWidget {
  final List<TravelCountry> countries;
  final int totalVisited;
  final int totalLived;
  final int totalWishlist;
  final double worldPercentage;
  final int continentsCount;
  final StoryCardTheme theme;
  final StoryCardLayout layout;

  const TravelMapStoryCard({
    super.key,
    required this.countries,
    required this.totalVisited,
    required this.totalLived,
    required this.totalWishlist,
    required this.worldPercentage,
    required this.continentsCount,
    this.theme = StoryCardTheme.midnight,
    this.layout = StoryCardLayout.classic,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context).languageCode;
    final palette = StoryCardPalette.forTheme(theme, locale: currentLocale, l10n: l10n);

    // Build the dynamic country polygon color mapping
    final colorMap = <String, Color>{};
    for (final country in countries) {
      final code = country.code.toLowerCase().trim();
      if (country.isLived) {
        colorMap[code] = palette.livedColor;
      } else if (country.isVisited) {
        colorMap[code] = palette.visitedColor;
      } else if (country.isWishlist) {
        colorMap[code] = palette.wishlistColor;
      }
    }

    final nc = countries.where((c) => c.code == 'NC').firstOrNull;
    if (nc != null && (colorMap['cy'] == null || nc.isLived || nc.isVisited)) {
      if (nc.isLived) {
        colorMap['cy'] = palette.livedColor;
      } else if (nc.isVisited) {
        colorMap['cy'] = palette.visitedColor;
      } else if (nc.isWishlist && colorMap['cy'] == null) {
        colorMap['cy'] = palette.wishlistColor;
      }
    }

    final visitedCountries = countries.where((c) => c.isVisited || c.isLived).toList();

    return Container(
      width: 360,
      height: 640,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        gradient: palette.backgroundGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: palette.cardBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.isLight ? Colors.black12 : Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildLayoutContent(context, l10n, palette, colorMap, visitedCountries),
    );
  }

  Widget _buildLayoutContent(
    BuildContext context,
    AppLocalizations l10n,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    switch (layout) {
      case StoryCardLayout.classic:
        return _buildClassicLayout(l10n, palette, colorMap, visitedCountries);
      case StoryCardLayout.passport:
        return _buildPassportLayout(l10n, palette, colorMap, visitedCountries);
      case StoryCardLayout.minimal:
        return _buildMinimalLayout(l10n, palette, colorMap, visitedCountries);
      case StoryCardLayout.showcase:
        return _buildShowcaseLayout(l10n, palette, colorMap, visitedCountries);
    }
  }

  // 1. CLASSIC LAYOUT (Balanced Map, Hero Stats, Flag Strip)
  Widget _buildClassicLayout(
    AppLocalizations l10n,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: palette.logoGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: palette.accentColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PackBuddy',
                      style: TextStyle(
                        color: palette.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'WORLD TRAVELER',
                      style: TextStyle(
                        color: palette.accentColor,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: palette.isLight
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.public_rounded, size: 12, color: palette.accentColor),
                  const SizedBox(width: 5),
                  Text(
                    l10n.storyCardTagline,
                    style: TextStyle(
                      color: palette.textColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // World Map Canvas
        _buildMapBox(palette, colorMap, height: 190),
        const SizedBox(height: 8),

        // Legend Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendPill(palette.livedColor, l10n.mapLegendLived, palette.subtextColor),
            const SizedBox(width: 12),
            _buildLegendPill(palette.visitedColor, l10n.mapLegendBeen, palette.subtextColor),
            const SizedBox(width: 12),
            _buildLegendPill(palette.wishlistColor, l10n.mapLegendWant, palette.subtextColor),
          ],
        ),
        const SizedBox(height: 12),

        // Hero Percentage Banner
        _buildHeroBanner(l10n, palette),
        const SizedBox(height: 10),

        // 4 Key Metric Tiles
        _buildFourStatTiles(l10n, palette),
        const Spacer(),

        // Dynamic All-Visited Flags Showcase
        if (visitedCountries.isNotEmpty)
          _buildFlagsGrid(visitedCountries, palette),
      ],
    );
  }

  // 2. PASSPORT LAYOUT (Luxury Gold Seal & Stamped Visa Edition)
  Widget _buildPassportLayout(
    AppLocalizations l10n,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Official Passport Header
        Center(
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: palette.logoGradient,
                  border: Border.all(color: palette.accentColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: palette.accentColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.public_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                (l10n.passportOfficialDocument).toUpperCase(),
                style: TextStyle(
                  color: palette.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
              Text(
                (l10n.passportWorldCitizen).toUpperCase(),
                style: TextStyle(
                  color: palette.accentColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Map framed like a visa page with passport entry stamp
        Stack(
          children: [
            _buildMapBox(palette, colorMap, height: 180),
            Positioned(
              top: 10,
              right: 10,
              child: Transform.rotate(
                angle: -0.08,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: palette.accentColor, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '%${worldPercentage.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: palette.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        (l10n.passportEntryVisas).toUpperCase(),
                        style: TextStyle(
                          color: palette.accentColor,
                          fontSize: 6.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Passport 3-Column Stamped Records
        Row(
          children: [
            Expanded(
              child: _buildPassportRecordTile(
                title: l10n.mapLegendBeen,
                value: '$totalVisited',
                icon: Icons.flight_takeoff_rounded,
                palette: palette,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPassportRecordTile(
                title: l10n.continentsUnit,
                value: '$continentsCount / 7',
                icon: Icons.explore_rounded,
                palette: palette,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPassportRecordTile(
                title: l10n.mapLegendLived,
                value: '$totalLived',
                icon: Icons.home_rounded,
                palette: palette,
              ),
            ),
          ],
        ),
        const Spacer(),

        // Visa Flag Stamp Collection
        if (visitedCountries.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.military_tech_rounded, size: 14, color: palette.accentColor),
                const SizedBox(width: 6),
                Text(
                  l10n.passportEntryVisas.toUpperCase(),
                  style: TextStyle(
                    color: palette.subtextColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          _buildFlagsGrid(visitedCountries, palette),
        ],
      ],
    );
  }

  // 3. MINIMAL LAYOUT (Editorial Typographic Clean)
  Widget _buildMinimalLayout(
    AppLocalizations l10n,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Massive Editorial Headline
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '%${worldPercentage.toStringAsFixed(1)}',
              style: TextStyle(
                color: palette.textColor,
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ofTheWorld.toUpperCase(),
                    style: TextStyle(
                      color: palette.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '$totalVisited ${l10n.countryUnit} • $continentsCount ${l10n.continentsUnit}',
                    style: TextStyle(
                      color: palette.subtextColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.accentColor, palette.accentColor.withValues(alpha: 0.1)],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Clean Outline Map (Larger Canvas)
        _buildMapBox(palette, colorMap, height: 230),
        const SizedBox(height: 12),

        // Minimalist Stats Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: palette.tileBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.tileBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniTextStat(l10n.mapLegendLived, '$totalLived', palette.livedColor),
              Container(width: 1, height: 22, color: palette.tileBorder),
              _buildMiniTextStat(l10n.mapLegendBeen, '$totalVisited', palette.visitedColor),
              Container(width: 1, height: 22, color: palette.tileBorder),
              _buildMiniTextStat(l10n.mapLegendWant, '$totalWishlist', palette.wishlistColor),
            ],
          ),
        ),
        const Spacer(),

        // Flag strip
        if (visitedCountries.isNotEmpty)
          _buildFlagsGrid(visitedCountries, palette),
      ],
    );
  }

  // 4. SHOWCASE LAYOUT (Grand Map Focal Point & Translucent Floating HUD)
  Widget _buildShowcaseLayout(
    AppLocalizations l10n,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Compact Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.flight_takeoff_rounded, color: palette.accentColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  'PackBuddy',
                  style: TextStyle(
                    color: palette.textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: palette.accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: palette.accentColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                '%${worldPercentage.toStringAsFixed(1)} ${l10n.ofTheWorld.toUpperCase()}',
                style: TextStyle(
                  color: palette.accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Immersive Hero Map (Tallest Dimension)
        Expanded(
          flex: 6,
          child: _buildMapBox(palette, colorMap, height: double.infinity),
        ),
        const SizedBox(height: 10),

        // Translucent Floating Glass HUD
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.tileBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: palette.tileBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: palette.isLight ? 0.06 : 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Quick Summary Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShowcaseStatTile(l10n.mapLegendBeen, '$totalVisited', Icons.flight_takeoff_rounded, palette.visitedColor, palette),
                    _buildShowcaseStatTile(l10n.mapLegendLived, '$totalLived', Icons.home_rounded, palette.livedColor, palette),
                    _buildShowcaseStatTile(l10n.continentsUnit, '$continentsCount', Icons.public_rounded, palette.accentColor, palette),
                  ],
                ),
                // Flags Grid inside HUD
                if (visitedCountries.isNotEmpty)
                  _buildFlagsGrid(visitedCountries, palette),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- REUSABLE SUB-WIDGETS ---

  Widget _buildMapBox(StoryCardPalette palette, Map<String, Color> colorMap, {required double height}) {
    return Container(
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        color: palette.mapBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.cardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Center(
              child: SimpleMap(
                instructions: SMapWorld.instructions,
                defaultColor: palette.unvisitedLandColor,
                colors: colorMap,
                countryBorder: CountryBorder(
                  color: palette.mapBorderColor,
                  width: 0.6,
                ),
                fit: BoxFit.contain,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      Colors.transparent,
                      (palette.isLight ? Colors.white : Colors.black)
                          .withValues(alpha: palette.isLight ? 0.15 : 0.25),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(AppLocalizations l10n, StoryCardPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        gradient: palette.heroGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.heroBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '%${worldPercentage.toStringAsFixed(1)}',
                style: TextStyle(
                  color: palette.textColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                l10n.ofTheWorld.toUpperCase(),
                style: TextStyle(
                  color: palette.accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (worldPercentage / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: palette.isLight ? Colors.black12 : Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(palette.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourStatTiles(AppLocalizations l10n, StoryCardPalette palette) {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            title: l10n.mapLegendLived,
            value: '$totalLived',
            color: palette.livedColor,
            icon: Icons.home_rounded,
            palette: palette,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            title: l10n.mapLegendBeen,
            value: '$totalVisited',
            color: palette.visitedColor,
            icon: Icons.flight_takeoff_rounded,
            palette: palette,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            title: l10n.mapLegendWant,
            value: '$totalWishlist',
            color: palette.wishlistColor,
            icon: Icons.explore_rounded,
            palette: palette,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatTile(
            title: l10n.continentsUnit,
            value: '$continentsCount',
            color: palette.accentColor,
            icon: Icons.public_rounded,
            palette: palette,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required StoryCardPalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: palette.tileBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.tileBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            title,
            style: TextStyle(
              color: palette.subtextColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPassportRecordTile({
    required String title,
    required String value,
    required IconData icon,
    required StoryCardPalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: palette.tileBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.accentColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 15, color: palette.accentColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: palette.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: palette.subtextColor,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTextStat(String title, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 10.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildShowcaseStatTile(
    String label,
    String value,
    IconData icon,
    Color color,
    StoryCardPalette palette,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: palette.textColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: palette.subtextColor,
                fontWeight: FontWeight.w600,
                fontSize: 9.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendPill(Color color, String text, Color textColor) {
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
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFlagsGrid(List<TravelCountry> visitedCountries, StoryCardPalette palette) {
    final count = visitedCountries.length;
    final double flagSize;
    final double spacing;
    final double runSpacing;
    final EdgeInsets pad;

    if (count <= 6) {
      flagSize = 22.0;
      spacing = 8.0;
      runSpacing = 6.0;
      pad = const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
    } else if (count <= 15) {
      flagSize = 18.0;
      spacing = 6.0;
      runSpacing = 5.0;
      pad = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else if (count <= 30) {
      flagSize = 15.0;
      spacing = 4.5;
      runSpacing = 4.0;
      pad = const EdgeInsets.symmetric(horizontal: 10, vertical: 7);
    } else if (count <= 60) {
      flagSize = 12.0;
      spacing = 3.5;
      runSpacing = 3.0;
      pad = const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    } else if (count <= 100) {
      flagSize = 10.0;
      spacing = 2.5;
      runSpacing = 2.0;
      pad = const EdgeInsets.symmetric(horizontal: 6, vertical: 5);
    } else if (count <= 150) {
      flagSize = 8.5;
      spacing = 1.8;
      runSpacing = 1.8;
      pad = const EdgeInsets.symmetric(horizontal: 5, vertical: 4);
    } else {
      flagSize = 7.5;
      spacing = 1.2;
      runSpacing = 1.2;
      pad = const EdgeInsets.symmetric(horizontal: 4, vertical: 4);
    }

    return Container(
      width: double.infinity,
      padding: pad,
      decoration: BoxDecoration(
        color: palette.tileBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.tileBorder),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing,
        runSpacing: runSpacing,
        children: visitedCountries.map((c) {
          return CountryFlag(
            code: c.code,
            fallbackEmoji: c.flag,
            size: flagSize,
          );
        }).toList(),
      ),
    );
  }
}
