import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import '../../features/travel_map/domain/travel_country.dart';
import 'preferences_service.dart';

/// Predefined theme configurations for Home Screen Widgets and Miniature World Map
class WidgetThemeConfig {
  final String key;
  final Color cardBgColor;
  final Color cardBorderColor;
  final Color oceanColor;
  final Color unvisitedLandColor;
  final Color countryBorderColor;
  final Color mapBorderColor;
  final Color accentColor;
  final Color legendBgColor;
  final Color legendBorderColor;
  final Color legendTextColor;
  final Color titleTextColor;
  final Color subtitleTextColor;
  final Color badgeBgColor;
  final Color statBgColor;
  final Color livedColor;
  final Color visitedColor;
  final Color wishlistColor;
  final String emoji;
  final bool isLight;

  const WidgetThemeConfig({
    required this.key,
    required this.cardBgColor,
    required this.cardBorderColor,
    required this.oceanColor,
    required this.unvisitedLandColor,
    required this.countryBorderColor,
    required this.mapBorderColor,
    required this.accentColor,
    required this.legendBgColor,
    required this.legendBorderColor,
    required this.legendTextColor,
    required this.titleTextColor,
    required this.subtitleTextColor,
    required this.badgeBgColor,
    required this.statBgColor,
    this.livedColor = const Color(0xFF10B981),
    this.visitedColor = const Color(0xFFE7B623),
    this.wishlistColor = const Color(0xFFEF4444),
    this.emoji = '🌌',
    this.isLight = false,
  });

  static WidgetThemeConfig fromKey(String? key) {
    switch (key) {
      case 'sunset':
        return const WidgetThemeConfig(
          key: 'sunset',
          cardBgColor: Color(0xFF1F1612),
          cardBorderColor: Color(0xFF7C2D12),
          oceanColor: Color(0xFF150622),
          unvisitedLandColor: Color(0xFF38184C),
          countryBorderColor: Color(0xFF1D0A30),
          mapBorderColor: Color(0xFF7C2D12),
          accentColor: Color(0xFFFF5722),
          legendBgColor: Color(0xDD1F1612),
          legendBorderColor: Color(0x407C2D12),
          legendTextColor: Colors.white,
          titleTextColor: Colors.white,
          subtitleTextColor: Color(0xFFFED7AA),
          badgeBgColor: Color(0xFFFF5722),
          statBgColor: Color(0xFF2E1C15),
          livedColor: Color(0xFFF59E0B),
          visitedColor: Color(0xFFFF5722),
          wishlistColor: Color(0xFFEC4899),
          emoji: '🌅',
          isLight: false,
        );

      case 'emerald':
        return const WidgetThemeConfig(
          key: 'emerald',
          cardBgColor: Color(0xFF062C22),
          cardBorderColor: Color(0xFF065F46),
          oceanColor: Color(0xFF03140F),
          unvisitedLandColor: Color(0xFF13382D),
          countryBorderColor: Color(0xFF09251D),
          mapBorderColor: Color(0xFF065F46),
          accentColor: Color(0xFF10B981),
          legendBgColor: Color(0xDD062C22),
          legendBorderColor: Color(0x40065F46),
          legendTextColor: Colors.white,
          titleTextColor: Colors.white,
          subtitleTextColor: Color(0xFFA7F3D0),
          badgeBgColor: Color(0xFF059669),
          statBgColor: Color(0xFF0A3A2F),
          livedColor: Color(0xFF34D399),
          visitedColor: Color(0xFF10B981),
          wishlistColor: Color(0xFFFBBF24),
          emoji: '🌲',
          isLight: false,
        );

      case 'cyberpunk':
        return const WidgetThemeConfig(
          key: 'cyberpunk',
          cardBgColor: Color(0xFF0E0927),
          cardBorderColor: Color(0xFF06B6D4),
          oceanColor: Color(0xFF0D0A26),
          unvisitedLandColor: Color(0xFF22164F),
          countryBorderColor: Color(0xFF191140),
          mapBorderColor: Color(0xFF06B6D4),
          accentColor: Color(0xFF06B6D4),
          legendBgColor: Color(0xDD0E0927),
          legendBorderColor: Color(0x4006B6D4),
          legendTextColor: Colors.white,
          titleTextColor: Colors.white,
          subtitleTextColor: Color(0xFF94A3B8),
          badgeBgColor: Color(0xFF06B6D4),
          statBgColor: Color(0xFF1E124A),
          livedColor: Color(0xFFFACC15),
          visitedColor: Color(0xFF06B6D4),
          wishlistColor: Color(0xFFF43F5E),
          emoji: '⚡',
          isLight: false,
        );

      case 'volcano':
        return const WidgetThemeConfig(
          key: 'volcano',
          cardBgColor: Color(0xFF1A0C0E),
          cardBorderColor: Color(0xFFFF3D00),
          oceanColor: Color(0xFF180E10),
          unvisitedLandColor: Color(0xFF331D21),
          countryBorderColor: Color(0xFF1F1013),
          mapBorderColor: Color(0xFFFF3D00),
          accentColor: Color(0xFFFF3D00),
          legendBgColor: Color(0xDD1A0C0E),
          legendBorderColor: Color(0x40FF3D00),
          legendTextColor: Colors.white,
          titleTextColor: Colors.white,
          subtitleTextColor: Color(0xFFFFCCBC),
          badgeBgColor: Color(0xFFDD2C00),
          statBgColor: Color(0xFF2D1216),
          livedColor: Color(0xFFF59E0B),
          visitedColor: Color(0xFFFF3D00),
          wishlistColor: Color(0xFFD50000),
          emoji: '🌋',
          isLight: false,
        );

      case 'nordicForest':
        return const WidgetThemeConfig(
          key: 'nordicForest',
          cardBgColor: Color(0xFF0B1921),
          cardBorderColor: Color(0xFF38BDF8),
          oceanColor: Color(0xFF071016),
          unvisitedLandColor: Color(0xFF1A3342),
          countryBorderColor: Color(0xFF102532),
          mapBorderColor: Color(0xFF38BDF8),
          accentColor: Color(0xFF38BDF8),
          legendBgColor: Color(0xDD0B1921),
          legendBorderColor: Color(0x4038BDF8),
          legendTextColor: Colors.white,
          titleTextColor: Colors.white,
          subtitleTextColor: Color(0xFFBAE6FD),
          badgeBgColor: Color(0xFF0284C7),
          statBgColor: Color(0xFF132B39),
          livedColor: Color(0xFF2DD4BF),
          visitedColor: Color(0xFF38BDF8),
          wishlistColor: Color(0xFFF472B6),
          emoji: '🏔️',
          isLight: false,
        );

      case 'goldenHour':
        return const WidgetThemeConfig(
          key: 'goldenHour',
          cardBgColor: Color(0xFF1F1607),
          cardBorderColor: Color(0xFFF59E0B),
          oceanColor: Color(0xFF1A1307),
          unvisitedLandColor: Color(0xFF382910),
          countryBorderColor: Color(0xFF211707),
          mapBorderColor: Color(0xFFF59E0B),
          accentColor: Color(0xFFF59E0B),
          legendBgColor: Color(0xDD1F1607),
          legendBorderColor: Color(0x40F59E0B),
          legendTextColor: Colors.white,
          titleTextColor: Colors.white,
          subtitleTextColor: Color(0xFFFEF3C7),
          badgeBgColor: Color(0xFFD97706),
          statBgColor: Color(0xFF2E210A),
          livedColor: Color(0xFF10B981),
          visitedColor: Color(0xFFF59E0B),
          wishlistColor: Color(0xFFEF4444),
          emoji: '✨',
          isLight: false,
        );

      case 'galaxy':
        return const WidgetThemeConfig(
          key: 'galaxy',
          cardBgColor: Color(0xFF16082B),
          cardBorderColor: Color(0xFFA855F7),
          oceanColor: Color(0xFF13092A),
          unvisitedLandColor: Color(0xFF291452),
          countryBorderColor: Color(0xFF1B0C39),
          mapBorderColor: Color(0xFFA855F7),
          accentColor: Color(0xFFA855F7),
          legendBgColor: Color(0xDD16082B),
          legendBorderColor: Color(0x40A855F7),
          legendTextColor: Colors.white,
          titleTextColor: Colors.white,
          subtitleTextColor: Color(0xFFE9D5FF),
          badgeBgColor: Color(0xFF9333EA),
          statBgColor: Color(0xFF250F47),
          livedColor: Color(0xFF06B6D4),
          visitedColor: Color(0xFFA855F7),
          wishlistColor: Color(0xFFEC4899),
          emoji: '🌌',
          isLight: false,
        );

      case 'monochromeDark':
        return const WidgetThemeConfig(
          key: 'monochromeDark',
          cardBgColor: Color(0xFF14171A),
          cardBorderColor: Color(0xFF475569),
          oceanColor: Color(0xFF101214),
          unvisitedLandColor: Color(0xFF23272D),
          countryBorderColor: Color(0xFF1B1E23),
          mapBorderColor: Color(0xFF475569),
          accentColor: Color(0xFFE2E8F0),
          legendBgColor: Color(0xDD14171A),
          legendBorderColor: Color(0x40475569),
          legendTextColor: Colors.white,
          titleTextColor: Colors.white,
          subtitleTextColor: Color(0xFF94A3B8),
          badgeBgColor: Color(0xFF475569),
          statBgColor: Color(0xFF22262C),
          livedColor: Color(0xFF10B981),
          visitedColor: Color(0xFFE2E8F0),
          wishlistColor: Color(0xFFF59E0B),
          emoji: '⬛',
          isLight: false,
        );

      case 'minimalLight':
      case 'light':
        return const WidgetThemeConfig(
          key: 'minimalLight',
          cardBgColor: Color(0xFFFFFFFF),
          cardBorderColor: Color(0xFFCBD5E1),
          oceanColor: Color(0xFFF1F5F9),
          unvisitedLandColor: Color(0xFFCBD5E1),
          countryBorderColor: Color(0xFF94A3B8),
          mapBorderColor: Color(0xFFCBD5E1),
          accentColor: Color(0xFF856404),
          legendBgColor: Color(0xEEFFFFFF),
          legendBorderColor: Color(0x40CBD5E1),
          legendTextColor: Color(0xFF0F172A),
          titleTextColor: Color(0xFF0F172A),
          subtitleTextColor: Color(0xFF475569),
          badgeBgColor: Color(0xFF856404),
          statBgColor: Color(0xFFF1F5F9),
          livedColor: Color(0xFF059669),
          visitedColor: Color(0xFFE7B623),
          wishlistColor: Color(0xFFE11D48),
          emoji: '❄️',
          isLight: true,
        );

      case 'sandLight':
        return const WidgetThemeConfig(
          key: 'sandLight',
          cardBgColor: Color(0xFFFAF5ED),
          cardBorderColor: Color(0xFFD8CCB8),
          oceanColor: Color(0xFFF2ECE1),
          unvisitedLandColor: Color(0xFFDFD5C4),
          countryBorderColor: Color(0xFFC7BBAA),
          mapBorderColor: Color(0xFFD8CCB8),
          accentColor: Color(0xFFD97706),
          legendBgColor: Color(0xEEFAF5ED),
          legendBorderColor: Color(0x40D8CCB8),
          legendTextColor: Color(0xFF292524),
          titleTextColor: Color(0xFF292524),
          subtitleTextColor: Color(0xFF78716C),
          badgeBgColor: Color(0xFFD97706),
          statBgColor: Color(0xFFF0E7D8),
          livedColor: Color(0xFF059669),
          visitedColor: Color(0xFFD97706),
          wishlistColor: Color(0xFFDC2626),
          emoji: '🏖️',
          isLight: true,
        );

      case 'oceanLight':
      case 'ocean':
        return const WidgetThemeConfig(
          key: 'oceanLight',
          cardBgColor: Color(0xFFF0F9FF),
          cardBorderColor: Color(0xFF7DD3FC),
          oceanColor: Color(0xFFE0F2FE),
          unvisitedLandColor: Color(0xFFFFFFFF),
          countryBorderColor: Color(0xFF38BDF8),
          mapBorderColor: Color(0xFF7DD3FC),
          accentColor: Color(0xFF0284C7),
          legendBgColor: Color(0xEEF0F9FF),
          legendBorderColor: Color(0x407DD3FC),
          legendTextColor: Color(0xFF0C4A6E),
          titleTextColor: Color(0xFF0C4A6E),
          subtitleTextColor: Color(0xFF0369A1),
          badgeBgColor: Color(0xFF0284C7),
          statBgColor: Color(0xFFE0F2FE),
          livedColor: Color(0xFF0D9488),
          visitedColor: Color(0xFF0284C7),
          wishlistColor: Color(0xFFF43F5E),
          emoji: '🌊',
          isLight: true,
        );

      case 'cherryBlossom':
        return const WidgetThemeConfig(
          key: 'cherryBlossom',
          cardBgColor: Color(0xFFFFF5F7),
          cardBorderColor: Color(0xFFFDA4AF),
          oceanColor: Color(0xFFFFF0F5),
          unvisitedLandColor: Color(0xFFFFDDE6),
          countryBorderColor: Color(0xFFFFCCD9),
          mapBorderColor: Color(0xFFFDA4AF),
          accentColor: Color(0xFFE11D48),
          legendBgColor: Color(0xEEFFF5F7),
          legendBorderColor: Color(0x40FDA4AF),
          legendTextColor: Color(0xFF4C0519),
          titleTextColor: Color(0xFF4C0519),
          subtitleTextColor: Color(0xFF9F1239),
          badgeBgColor: Color(0xFFE11D48),
          statBgColor: Color(0xFFFFE4EC),
          livedColor: Color(0xFF059669),
          visitedColor: Color(0xFFE11D48),
          wishlistColor: Color(0xFF9333EA),
          emoji: '🌸',
          isLight: true,
        );

      case 'vintageSepia':
        return const WidgetThemeConfig(
          key: 'vintageSepia',
          cardBgColor: Color(0xFFF6F1E5),
          cardBorderColor: Color(0xFFD4B996),
          oceanColor: Color(0xFFEBE3D3),
          unvisitedLandColor: Color(0xFFDCCFBC),
          countryBorderColor: Color(0xFFC7B69F),
          mapBorderColor: Color(0xFFD4B996),
          accentColor: Color(0xFF854D0E),
          legendBgColor: Color(0xEEF6F1E5),
          legendBorderColor: Color(0x40D4B996),
          legendTextColor: Color(0xFF422006),
          titleTextColor: Color(0xFF422006),
          subtitleTextColor: Color(0xFF713F12),
          badgeBgColor: Color(0xFF854D0E),
          statBgColor: Color(0xFFE8DEC8),
          livedColor: Color(0xFF15803D),
          visitedColor: Color(0xFF854D0E),
          wishlistColor: Color(0xFFB91C1C),
          emoji: '📜',
          isLight: true,
        );

      case 'matcha':
        return const WidgetThemeConfig(
          key: 'matcha',
          cardBgColor: Color(0xFFF2F7EF),
          cardBorderColor: Color(0xFFA3E635),
          oceanColor: Color(0xFFE4EEDF),
          unvisitedLandColor: Color(0xFFCFDFC6),
          countryBorderColor: Color(0xFFB6CEAA),
          mapBorderColor: Color(0xFFA3E635),
          accentColor: Color(0xFF4D7C0F),
          legendBgColor: Color(0xEEF2F7EF),
          legendBorderColor: Color(0x40A3E635),
          legendTextColor: Color(0xFF14532D),
          titleTextColor: Color(0xFF14532D),
          subtitleTextColor: Color(0xFF166534),
          badgeBgColor: Color(0xFF4D7C0F),
          statBgColor: Color(0xFFE1EDDA),
          livedColor: Color(0xFF0284C7),
          visitedColor: Color(0xFF4D7C0F),
          wishlistColor: Color(0xFFDC2626),
          emoji: '🍵',
          isLight: true,
        );

      case 'pastelDream':
        return const WidgetThemeConfig(
          key: 'pastelDream',
          cardBgColor: Color(0xFFF7F2FF),
          cardBorderColor: Color(0xFFC4B5FD),
          oceanColor: Color(0xFFEFE6FF),
          unvisitedLandColor: Color(0xFFDED2F9),
          countryBorderColor: Color(0xFFC7B5F0),
          mapBorderColor: Color(0xFFC4B5FD),
          accentColor: Color(0xFF8B5CF6),
          legendBgColor: Color(0xEEF7F2FF),
          legendBorderColor: Color(0x40C4B5FD),
          legendTextColor: Color(0xFF4C1D95),
          titleTextColor: Color(0xFF4C1D95),
          subtitleTextColor: Color(0xFF6D28D9),
          badgeBgColor: Color(0xFF8B5CF6),
          statBgColor: Color(0xFFE9DCFF),
          livedColor: Color(0xFF0D9488),
          visitedColor: Color(0xFF8B5CF6),
          wishlistColor: Color(0xFFF43F5E),
          emoji: '🦄',
          isLight: true,
        );

      case 'midnight':
      default:
        return const WidgetThemeConfig(
          key: 'midnight',
          cardBgColor: Color(0xFF111827),
          cardBorderColor: Color(0xFF1F2937),
          oceanColor: Color(0xFF080D1A),
          unvisitedLandColor: Color(0xFF1E293B),
          countryBorderColor: Color(0xFF1E293B),
          mapBorderColor: Color(0xFF1F2937),
          accentColor: Color(0xFF3B82F6),
          legendBgColor: Color(0xDD111827),
          legendBorderColor: Color(0x4038BDF8),
          legendTextColor: Colors.white,
          titleTextColor: Colors.white,
          subtitleTextColor: Color(0xFF94A3B8),
          badgeBgColor: Color(0xFF2563EB),
          statBgColor: Color(0xFF1F2937),
          livedColor: Color(0xFF10B981),
          visitedColor: Color(0xFFE7B623),
          wishlistColor: Color(0xFFF43F5E),
          emoji: '🌌',
          isLight: false,
        );
    }
  }
}

/// Offscreen renderer generating high-resolution vector World Map images for Home Screen Widgets
class WidgetMapRenderer {
  WidgetMapRenderer._();

  static Future<void> renderAndSaveMapImages(
    List<TravelCountry> countries, {
    String? theme,
    int? continentsCount,
  }) async {
    try {
      if (ui.PlatformDispatcher.instance.implicitView == null) {
        return;
      }

      final currentTheme = theme ?? PreferencesService.instance.getWidgetTheme();
      final themeConfig = WidgetThemeConfig.fromKey(currentTheme);

      final colorMapWithWishlist = <String, Color>{};
      final colorMapNoWishlist = <String, Color>{};
      for (final country in countries) {
        final code = country.code.toLowerCase().trim();
        if (country.isLived) {
          colorMapWithWishlist[code] = themeConfig.livedColor;
          colorMapNoWishlist[code] = themeConfig.livedColor;
        } else if (country.isVisited) {
          colorMapWithWishlist[code] = themeConfig.visitedColor;
          colorMapNoWishlist[code] = themeConfig.visitedColor;
        } else if (country.isWishlist) {
          colorMapWithWishlist[code] = themeConfig.wishlistColor;
        }
      }

      final nc = countries.where((c) => c.code == 'NC').firstOrNull;
      if (nc != null) {
        if (nc.isLived) {
          colorMapWithWishlist['cy'] = themeConfig.livedColor;
          colorMapNoWishlist['cy'] = themeConfig.livedColor;
        } else if (nc.isVisited) {
          colorMapWithWishlist['cy'] = themeConfig.visitedColor;
          colorMapNoWishlist['cy'] = themeConfig.visitedColor;
        } else if (nc.isWishlist) {
          if (colorMapWithWishlist['cy'] == null) {
            colorMapWithWishlist['cy'] = themeConfig.wishlistColor;
          }
        }
      }

      // Attractive preview fallback if user hasn't marked countries yet, matching in-app preview
      if (colorMapWithWishlist.isEmpty) {
        colorMapWithWishlist['tr'] = themeConfig.livedColor;
        colorMapNoWishlist['tr'] = themeConfig.livedColor;
        for (final c in ['de', 'it', 'fr', 'es', 'us', 'br']) {
          colorMapWithWishlist[c] = themeConfig.visitedColor;
          colorMapNoWishlist[c] = themeConfig.visitedColor;
        }
        for (final c in ['jp', 'ca', 'au']) {
          colorMapWithWishlist[c] = themeConfig.wishlistColor;
        }
      }

      // 1. Large Map with Centered Projection (360x220 dp) - With Wishlist
      final largeWidget = _buildMapCanvas(
        colorMap: colorMapWithWishlist,
        themeKey: currentTheme,
        width: 360,
        height: 220,
      );
      final largePath = await HomeWidget.renderFlutterWidget(
        largeWidget,
        key: 'map_image_large',
        logicalSize: const Size(360, 220),
        pixelRatio: 2.5,
      );
      await HomeWidget.saveWidgetData<String>('map_image_large', largePath);

      // 1b. Large Map without Wishlist (for widgets where showWishlist is false)
      final largeNoWishlistWidget = _buildMapCanvas(
        colorMap: colorMapNoWishlist,
        themeKey: currentTheme,
        width: 360,
        height: 220,
      );
      final largeNoWishlistPath = await HomeWidget.renderFlutterWidget(
        largeNoWishlistWidget,
        key: 'map_image_large_nowishlist',
        logicalSize: const Size(360, 220),
        pixelRatio: 2.5,
      );
      await HomeWidget.saveWidgetData<String>('map_image_large_nowishlist', largeNoWishlistPath);

      // 2. Medium Map with Centered Projection (200x120 dp) - With Wishlist
      final mediumWidget = _buildMapCanvas(
        colorMap: colorMapWithWishlist,
        themeKey: currentTheme,
        width: 200,
        height: 120,
      );
      final mediumPath = await HomeWidget.renderFlutterWidget(
        mediumWidget,
        key: 'map_image_medium',
        logicalSize: const Size(200, 120),
        pixelRatio: 2.5,
      );
      await HomeWidget.saveWidgetData<String>('map_image_medium', mediumPath);

      // 2b. Medium Map without Wishlist
      final mediumNoWishlistWidget = _buildMapCanvas(
        colorMap: colorMapNoWishlist,
        themeKey: currentTheme,
        width: 200,
        height: 120,
      );
      final mediumNoWishlistPath = await HomeWidget.renderFlutterWidget(
        mediumNoWishlistWidget,
        key: 'map_image_medium_nowishlist',
        logicalSize: const Size(200, 120),
        pixelRatio: 2.5,
      );
      await HomeWidget.saveWidgetData<String>('map_image_medium_nowishlist', mediumNoWishlistPath);
    } catch (e) {
      debugPrint('[WidgetMapRenderer] Error rendering map image: $e');
    }
  }

  static Widget _buildMapCanvas({
    required Map<String, Color> colorMap,
    required String themeKey,
    required double width,
    required double height,
  }) {
    final themeConfig = WidgetThemeConfig.fromKey(themeKey);

    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: AspectRatio(
          aspectRatio: 2000 / 857,
          child: SimpleMap(
            instructions: SMapWorld.instructions,
            defaultColor: themeConfig.unvisitedLandColor,
            colors: colorMap,
            countryBorder: CountryBorder(
              color: themeConfig.countryBorderColor,
              width: 0.45,
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
