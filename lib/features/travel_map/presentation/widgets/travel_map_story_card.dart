import 'package:flutter/material.dart';
import 'package:countries_world_map/countries_world_map.dart';
import 'package:packbuddy/core/services/story_card_localization.dart';
import 'package:packbuddy/features/travel_map/data/world_map_instructions.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/country_flag.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Available story layout templates
enum StoryCardLayout {
  classic,     // 🌟 Klasik (Balanced Map + Stats + Flag Strip)
  passport,    // 🛂 Pasaport (Official Travel Passport & Visa Stamps Edition)
  minimal,     // 🧊 Minimal (Editorial Typography & Clean Outline)
  showcase,    // 🖼️ Vitrin (Immersive Large Map & Glassmorphism HUD)
  journey,     // ✈️ Yolculuk (Milestones & Route Waypoints)
  polaroid,    // 📸 Kartpostal (Postcard & Travel Scrapbook)
  infographic, // 📊 İnfografik (Continental Progress & Explorer Radar)
}

extension StoryCardLayoutX on StoryCardLayout {
  String getLocalizedName(AppLocalizations? l10n, {String? locale}) {
    if (locale != null && locale.isNotEmpty) {
      return StoryCardLocalization.getLayoutName(this, locale);
    }
    switch (this) {
      case StoryCardLayout.classic:
        return l10n?.storyLayoutClassic ?? 'Classic';
      case StoryCardLayout.passport:
        return l10n?.storyLayoutPassport ?? 'Passport';
      case StoryCardLayout.minimal:
        return l10n?.storyLayoutMinimal ?? 'Minimal';
      case StoryCardLayout.showcase:
        return l10n?.storyLayoutShowcase ?? 'Showcase';
      case StoryCardLayout.journey:
        return l10n?.storyLayoutJourney ?? 'Journey';
      case StoryCardLayout.polaroid:
        return l10n?.storyLayoutPolaroid ?? 'Postcard';
      case StoryCardLayout.infographic:
        return l10n?.storyLayoutInfographic ?? 'Infographic';
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
      case StoryCardLayout.journey:
        return '✈️';
      case StoryCardLayout.polaroid:
        return '📸';
      case StoryCardLayout.infographic:
        return '📊';
    }
  }
}

/// Available elevated design styles and color palettes for social media stories (16 Palettes: 8 Dark, 8 Light)
enum StoryCardTheme {
  // 8 Dark Themes
  midnight,      // 🌌 Gece Kaşifi (Midnight Obsidian & Neon Glow)
  sunset,        // 🌅 Gün Batımı (Twilight Velvet Violet & Sunset Flame)
  emerald,       // 🌲 Aurora (Nordic Emerald & Warm Gold)
  cyberpunk,     // ⚡ Siber (Deep Cyber Navy & Neon Cyan)
  volcano,       // 🌋 Lav (Obsidian Basalt & Molten Orange)
  nordicForest,  // 🏔️ Fiyort (Deep Spruce Slate & Ice Blue)
  goldenHour,    // ✨ Altın Çağ (Imperial Dark Gold & Radiant Amber)
  galaxy,        // 🌌 Galaksi (Deep Cosmic Purple & Starfire Violet)
  monochromeDark,// ⬛ Karbon (Graphite Black & Platinum)

  // 7 Light Themes (Total 16 themes: 9 dark, 7 light)
  minimalLight,  // ❄️ İskandinav (Pure Porcelain White & Slate)
  sandLight,     // 🏖️ Sahra (Warm Sahara Linen & Terracotta Gold)
  oceanLight,    // 🌊 Akdeniz (Mediterranean Azure & Coastal Sky)
  cherryBlossom, // 🌸 Sakura (Blush Paper & Cherry Rose)
  vintageSepia,  // 📜 Parşömen (Antique Parchment & Vintage Walnut)
  matcha,        // 🍵 Matcha (Zen Light Green & Forest Moss)
  pastelDream,   // 🦄 Pastel Rüya (Dreamy Lilac Lavender & Soft Coral)
}

extension StoryCardThemeX on StoryCardTheme {
  bool get isLight => index >= 9;
  bool get isDark => index < 9;
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
    final lang = locale ?? 'en';
    final label = StoryCardLocalization.getThemeName(theme.name, lang);
    switch (theme) {
      case StoryCardTheme.midnight:
        return StoryCardPalette(
          label: label,
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
          visitedColor: const Color(0xFFE7B623), // Serene Voyage Sun Gold
          wishlistColor: const Color(0xFFF43F5E), // Rose Coral
          textColor: Colors.white,
          subtextColor: const Color(0xFF94A3B8),
          cardBorder: Colors.white.withValues(alpha: 0.14),
          tileBackground: Colors.white.withValues(alpha: 0.05),
          tileBorder: Colors.white.withValues(alpha: 0.10),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFE7B623).withValues(alpha: 0.22),
              const Color(0xFF0F766E).withValues(alpha: 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFE7B623).withValues(alpha: 0.35),
          logoGradient: const LinearGradient(
            colors: [Color(0xFFE7B623), Color(0xFF856404)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFE7B623),
          isLight: false,
          previewColors: const [Color(0xFF080D1A), Color(0xFFE7B623), Color(0xFF10B981)],
        );

      case StoryCardTheme.sunset:
        return StoryCardPalette(
          label: label,
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
          label: label,
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
          label: label,
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
          visitedColor: const Color(0xFFE7B623),
          wishlistColor: const Color(0xFFE11D48),
          textColor: const Color(0xFF0F172A),
          subtextColor: const Color(0xFF475569),
          cardBorder: const Color(0xFFCBD5E1),
          tileBackground: Colors.white,
          tileBorder: const Color(0xFFE2E8F0),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFE7B623).withValues(alpha: 0.12),
              const Color(0xFF0284C7).withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFE7B623).withValues(alpha: 0.32),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFE7B623),
          isLight: true,
          previewColors: const [Color(0xFFFFFFFF), Color(0xFFE7B623), Color(0xFF0F172A)],
        );

      case StoryCardTheme.sandLight:
        return StoryCardPalette(
          label: label,
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
          label: label,
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

      case StoryCardTheme.cyberpunk:
        return StoryCardPalette(
          label: label,
          emoji: '⚡',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFF0A071E), Color(0xFF140D36), Color(0xFF060312)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF0D0A26),
          unvisitedLandColor: const Color(0xFF22164F),
          mapBorderColor: const Color(0xFF191140),
          livedColor: const Color(0xFFFACC15), // Cyber Yellow
          visitedColor: const Color(0xFF06B6D4), // Neon Cyan
          wishlistColor: const Color(0xFFF43F5E), // Rose Coral
          textColor: Colors.white,
          subtextColor: const Color(0xFF94A3B8),
          cardBorder: const Color(0xFF06B6D4).withValues(alpha: 0.35),
          tileBackground: const Color(0xFF06B6D4).withValues(alpha: 0.08),
          tileBorder: const Color(0xFF06B6D4).withValues(alpha: 0.20),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFF06B6D4).withValues(alpha: 0.25),
              const Color(0xFF8B5CF6).withValues(alpha: 0.18),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFF06B6D4).withValues(alpha: 0.5),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFF06B6D4),
          isLight: false,
          previewColors: const [Color(0xFF140D36), Color(0xFF06B6D4), Color(0xFFFACC15)],
        );

      case StoryCardTheme.volcano:
        return StoryCardPalette(
          label: label,
          emoji: '🌋',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFF140D0E), Color(0xFF221113), Color(0xFF0C0708)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF180E10),
          unvisitedLandColor: const Color(0xFF331D21),
          mapBorderColor: const Color(0xFF1F1013),
          livedColor: const Color(0xFFF59E0B),
          visitedColor: const Color(0xFFFF3D00), // Molten Orange
          wishlistColor: const Color(0xFFD50000), // Crimson
          textColor: Colors.white,
          subtextColor: const Color(0xFFFFCCBC).withValues(alpha: 0.75),
          cardBorder: const Color(0xFFFF3D00).withValues(alpha: 0.35),
          tileBackground: const Color(0xFFFF3D00).withValues(alpha: 0.08),
          tileBorder: const Color(0xFFFF3D00).withValues(alpha: 0.18),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFFF3D00).withValues(alpha: 0.30),
              const Color(0xFFFF9100).withValues(alpha: 0.18),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFFF3D00).withValues(alpha: 0.5),
          logoGradient: const LinearGradient(
            colors: [Color(0xFFDD2C00), Color(0xFFFF3D00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFFF3D00),
          isLight: false,
          previewColors: const [Color(0xFF221113), Color(0xFFFF3D00), Color(0xFFF59E0B)],
        );

      case StoryCardTheme.nordicForest:
        return StoryCardPalette(
          label: label,
          emoji: '🏔️',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFF09141B), Color(0xFF0F232F), Color(0xFF060D12)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF0B1921),
          unvisitedLandColor: const Color(0xFF1A3342),
          mapBorderColor: const Color(0xFF102532),
          livedColor: const Color(0xFF2DD4BF),
          visitedColor: const Color(0xFF38BDF8), // Ice Blue
          wishlistColor: const Color(0xFFF472B6),
          textColor: Colors.white,
          subtextColor: const Color(0xFFBAE6FD).withValues(alpha: 0.78),
          cardBorder: const Color(0xFF38BDF8).withValues(alpha: 0.3),
          tileBackground: const Color(0xFF38BDF8).withValues(alpha: 0.08),
          tileBorder: const Color(0xFF38BDF8).withValues(alpha: 0.18),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFF38BDF8).withValues(alpha: 0.25),
              const Color(0xFF2DD4BF).withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFF38BDF8).withValues(alpha: 0.45),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFF38BDF8),
          isLight: false,
          previewColors: const [Color(0xFF0F232F), Color(0xFF38BDF8), Color(0xFF2DD4BF)],
        );

      case StoryCardTheme.goldenHour:
        return StoryCardPalette(
          label: label,
          emoji: '✨',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFF151006), Color(0xFF241A0A), Color(0xFF0D0A03)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF1A1307),
          unvisitedLandColor: const Color(0xFF382910),
          mapBorderColor: const Color(0xFF211707),
          livedColor: const Color(0xFF10B981),
          visitedColor: const Color(0xFFF59E0B), // Radiant Amber
          wishlistColor: const Color(0xFFEF4444),
          textColor: Colors.white,
          subtextColor: const Color(0xFFFEF3C7).withValues(alpha: 0.8),
          cardBorder: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          tileBackground: const Color(0xFFF59E0B).withValues(alpha: 0.08),
          tileBorder: const Color(0xFFF59E0B).withValues(alpha: 0.2),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFF59E0B).withValues(alpha: 0.3),
              const Color(0xFFD97706).withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFF59E0B).withValues(alpha: 0.5),
          logoGradient: const LinearGradient(
            colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFF59E0B),
          isLight: false,
          previewColors: const [Color(0xFF241A0A), Color(0xFFF59E0B), Color(0xFFFDE68A)],
        );

      case StoryCardTheme.galaxy:
        return StoryCardPalette(
          label: label,
          emoji: '🌌',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFF0F0721), Color(0xFF1D0B38), Color(0xFF070311)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF13092A),
          unvisitedLandColor: const Color(0xFF291452),
          mapBorderColor: const Color(0xFF1B0C39),
          livedColor: const Color(0xFF06B6D4),
          visitedColor: const Color(0xFFA855F7), // Nebula Purple
          wishlistColor: const Color(0xFFEC4899), // Star Pink
          textColor: Colors.white,
          subtextColor: const Color(0xFFE9D5FF).withValues(alpha: 0.75),
          cardBorder: const Color(0xFFA855F7).withValues(alpha: 0.35),
          tileBackground: const Color(0xFFA855F7).withValues(alpha: 0.09),
          tileBorder: const Color(0xFFA855F7).withValues(alpha: 0.22),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFA855F7).withValues(alpha: 0.28),
              const Color(0xFFEC4899).withValues(alpha: 0.16),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFA855F7).withValues(alpha: 0.5),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF7E22CE), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFA855F7),
          isLight: false,
          previewColors: const [Color(0xFF1D0B38), Color(0xFFA855F7), Color(0xFFEC4899)],
        );

      case StoryCardTheme.monochromeDark:
        return StoryCardPalette(
          label: label,
          emoji: '⬛',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFF0C0D0E), Color(0xFF181A1D), Color(0xFF08090A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFF101214),
          unvisitedLandColor: const Color(0xFF23272D),
          mapBorderColor: const Color(0xFF1B1E23),
          livedColor: const Color(0xFF10B981),
          visitedColor: const Color(0xFFE2E8F0), // Platinum White
          wishlistColor: const Color(0xFFF59E0B),
          textColor: Colors.white,
          subtextColor: const Color(0xFF94A3B8),
          cardBorder: const Color(0xFF475569),
          tileBackground: Colors.white.withValues(alpha: 0.06),
          tileBorder: Colors.white.withValues(alpha: 0.12),
          heroGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: Colors.white.withValues(alpha: 0.35),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF475569), Color(0xFF94A3B8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFE2E8F0),
          isLight: false,
          previewColors: const [Color(0xFF181A1D), Color(0xFFE2E8F0), Color(0xFF10B981)],
        );

      case StoryCardTheme.cherryBlossom:
        return StoryCardPalette(
          label: label,
          emoji: '🌸',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFFFFF7F9), Color(0xFFFFEFF3), Color(0xFFFFF0F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFFFFF5F7),
          unvisitedLandColor: const Color(0xFFFFDDE6),
          mapBorderColor: const Color(0xFFFFCCD9),
          livedColor: const Color(0xFF059669),
          visitedColor: const Color(0xFFE11D48), // Rose Coral
          wishlistColor: const Color(0xFF9333EA),
          textColor: const Color(0xFF4C0519),
          subtextColor: const Color(0xFF9F1239),
          cardBorder: const Color(0xFFFDA4AF),
          tileBackground: Colors.white.withValues(alpha: 0.95),
          tileBorder: const Color(0xFFFECDD3),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFFE11D48).withValues(alpha: 0.12),
              const Color(0xFFFB7185).withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFFFB7185).withValues(alpha: 0.45),
          logoGradient: const LinearGradient(
            colors: [Color(0xFFBE123C), Color(0xFFE11D48)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFFE11D48),
          isLight: true,
          previewColors: const [Color(0xFFFFEFF3), Color(0xFFE11D48), Color(0xFFFDA4AF)],
        );

      case StoryCardTheme.vintageSepia:
        return StoryCardPalette(
          label: label,
          emoji: '📜',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFFF9F5EB), Color(0xFFF2ECE0), Color(0xFFEBE3D3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFFF4EFE6),
          unvisitedLandColor: const Color(0xFFDCCFBC),
          mapBorderColor: const Color(0xFFC7B69F),
          livedColor: const Color(0xFF15803D),
          visitedColor: const Color(0xFF854D0E), // Aged Amber Walnut
          wishlistColor: const Color(0xFFB91C1C),
          textColor: const Color(0xFF422006),
          subtextColor: const Color(0xFF713F12),
          cardBorder: const Color(0xFFD4B996),
          tileBackground: Colors.white.withValues(alpha: 0.85),
          tileBorder: const Color(0xFFDCCFBC),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFF854D0E).withValues(alpha: 0.14),
              const Color(0xFFA16207).withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFF854D0E).withValues(alpha: 0.4),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF713F12), Color(0xFF854D0E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFF854D0E),
          isLight: true,
          previewColors: const [Color(0xFFF2ECE0), Color(0xFF854D0E), Color(0xFFB91C1C)],
        );

      case StoryCardTheme.matcha:
        return StoryCardPalette(
          label: label,
          emoji: '🍵',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFFF4F7F2), Color(0xFFEBF2E7), Color(0xFFE0ECDA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFFEFF5EB),
          unvisitedLandColor: const Color(0xFFCFDFC6),
          mapBorderColor: const Color(0xFFB6CEAA),
          livedColor: const Color(0xFF0284C7),
          visitedColor: const Color(0xFF4D7C0F), // Rich Leaf Green
          wishlistColor: const Color(0xFFDC2626),
          textColor: const Color(0xFF14532D),
          subtextColor: const Color(0xFF166534),
          cardBorder: const Color(0xFFA3E635).withValues(alpha: 0.5),
          tileBackground: Colors.white.withValues(alpha: 0.90),
          tileBorder: const Color(0xFFD9F99D),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFF4D7C0F).withValues(alpha: 0.15),
              const Color(0xFF65A30D).withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFF4D7C0F).withValues(alpha: 0.4),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF3F6212), Color(0xFF4D7C0F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFF4D7C0F),
          isLight: true,
          previewColors: const [Color(0xFFEBF2E7), Color(0xFF4D7C0F), Color(0xFF0284C7)],
        );

      case StoryCardTheme.pastelDream:
        return StoryCardPalette(
          label: label,
          emoji: '🦄',
          backgroundGradient: const LinearGradient(
            colors: [Color(0xFFFBF8FF), Color(0xFFF3EDFF), Color(0xFFEBE1FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          mapBackground: const Color(0xFFF8F4FF),
          unvisitedLandColor: const Color(0xFFDED2F9),
          mapBorderColor: const Color(0xFFC7B5F0),
          livedColor: const Color(0xFF0D9488),
          visitedColor: const Color(0xFF8B5CF6), // Pastel Violet
          wishlistColor: const Color(0xFFF43F5E), // Coral
          textColor: const Color(0xFF4C1D95),
          subtextColor: const Color(0xFF6D28D9),
          cardBorder: const Color(0xFFC4B5FD),
          tileBackground: Colors.white.withValues(alpha: 0.92),
          tileBorder: const Color(0xFFDDD6FE),
          heroGradient: LinearGradient(
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              const Color(0xFF6366F1).withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          heroBorder: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
          logoGradient: const LinearGradient(
            colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: const Color(0xFF8B5CF6),
          isLight: true,
          previewColors: const [Color(0xFFEDE9FE), Color(0xFF8B5CF6), Color(0xFFF43F5E)],
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
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
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
      child: _buildLayoutContent(context, l10n, currentLocale, palette, colorMap, visitedCountries),
    );
  }

  Widget _buildLayoutContent(
    BuildContext context,
    AppLocalizations l10n,
    String currentLocale,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    switch (layout) {
      case StoryCardLayout.classic:
        return _buildClassicLayout(l10n, currentLocale, palette, colorMap, visitedCountries);
      case StoryCardLayout.passport:
        return _buildPassportLayout(l10n, currentLocale, palette, colorMap, visitedCountries);
      case StoryCardLayout.minimal:
        return _buildMinimalLayout(l10n, currentLocale, palette, colorMap, visitedCountries);
      case StoryCardLayout.showcase:
        return _buildShowcaseLayout(l10n, currentLocale, palette, colorMap, visitedCountries);
      case StoryCardLayout.journey:
        return _buildJourneyLayout(l10n, currentLocale, palette, colorMap, visitedCountries);
      case StoryCardLayout.polaroid:
        return _buildPolaroidLayout(l10n, currentLocale, palette, colorMap, visitedCountries);
      case StoryCardLayout.infographic:
        return _buildInfographicLayout(l10n, currentLocale, palette, colorMap, visitedCountries);
    }
  }

  Widget _buildTopHeaderBadge({
    required StoryCardPalette palette,
    required String title,
    IconData? fallbackIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: palette.accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.accentColor.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/logo_transparent.png',
              width: 14,
              height: 14,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                fallbackIcon ?? Icons.public_rounded,
                size: 13,
                color: palette.accentColor,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'PackBuddy',
            style: TextStyle(
              color: palette.textColor,
              fontSize: 9.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          if (title.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '•',
                style: TextStyle(
                  color: palette.accentColor.withValues(alpha: 0.6),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.accentColor,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 1. CLASSIC LAYOUT (Balanced Map, Hero Stats, Flag Strip)
  Widget _buildClassicLayout(
    AppLocalizations l10n,
    String currentLocale,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Bar: Top-left kept 100% EMPTY for Instagram user handle & profile overlay
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: _buildTopHeaderBadge(
                palette: palette,
                title: StoryCardLocalization.getWorldTravelerHeader(currentLocale),
                fallbackIcon: Icons.public_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // World Map Canvas: EXPANDED to fill all remaining vertical space
        Expanded(
          child: _buildMapBox(palette, colorMap),
        ),
        const SizedBox(height: 8),

        // Legend Row
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 4,
          children: [
            _buildLegendPill(palette.livedColor, l10n.mapLegendLived, palette.subtextColor),
            _buildLegendPill(palette.visitedColor, l10n.mapLegendBeen, palette.subtextColor),
            _buildLegendPill(palette.wishlistColor, l10n.mapLegendWant, palette.subtextColor),
          ],
        ),
        const SizedBox(height: 8),

        // Hero Percentage Banner
        _buildHeroBanner(l10n, palette),
        const SizedBox(height: 8),

        // 4 Key Metric Tiles
        _buildFourStatTiles(l10n, palette),
        const SizedBox(height: 8),

        // Dynamic Flags: Intrinsic height (Proportional to flag count, ZERO empty void)
        _buildBottomExplorerSection(visitedCountries, palette, l10n, currentLocale),
      ],
    );
  }

  // 2. PASSPORT LAYOUT (Luxury Gold Seal & Stamped Visa Edition)
  Widget _buildPassportLayout(
    AppLocalizations l10n,
    String currentLocale,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Passport Header: Top-left EMPTY for Instagram
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: _buildTopHeaderBadge(
                palette: palette,
                title: (l10n.passportOfficialDocument).toUpperCase(),
                fallbackIcon: Icons.verified_user_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Map framed like a visa page with passport entry stamp - EXPANDED
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildMapBox(palette, colorMap),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Transform.rotate(
                  angle: -0.06,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (palette.isLight ? Colors.white : Colors.black).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: palette.accentColor, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '%${worldPercentage.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: palette.accentColor,
                            fontSize: 13,
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
        ),
        const SizedBox(height: 8),

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
        const SizedBox(height: 8),

        // Visa Flag Stamp Collection: Intrinsic height (ZERO void)
        _buildPassportLowerSection(visitedCountries, palette, l10n, currentLocale),
      ],
    );
  }

  // 3. MINIMAL LAYOUT (Editorial Typographic Clean & Perfectly Symmetrical)
  Widget _buildMinimalLayout(
    AppLocalizations l10n,
    String currentLocale,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Symmetrical Minimal Header: Top-left EMPTY for Instagram
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: _buildTopHeaderBadge(
                palette: palette,
                title: StoryCardLocalization.getAtlasArchiveHeader(currentLocale, worldPercentage),
                fallbackIcon: Icons.explore_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Perfectly Centered Display Typography
        Center(
          child: Text(
            '%${worldPercentage.toStringAsFixed(1)}',
            style: TextStyle(
              color: palette.textColor,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            '${l10n.ofTheWorld.toUpperCase()}  •  $totalVisited ${l10n.mapLegendBeen.toUpperCase()}  •  $continentsCount ${l10n.continentsUnit.toUpperCase()}',
            style: TextStyle(
              color: palette.subtextColor,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Clean Minimal Outline Map - EXPANDED
        Expanded(
          child: _buildMapBox(palette, colorMap),
        ),
        const SizedBox(height: 8),

        // Minimalist Stats Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: palette.tileBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.tileBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniTextStat(l10n.mapLegendLived, '$totalLived', palette.livedColor),
              Container(width: 1, height: 16, color: palette.tileBorder),
              _buildMiniTextStat(l10n.mapLegendBeen, '$totalVisited', palette.visitedColor),
              Container(width: 1, height: 16, color: palette.tileBorder),
              _buildMiniTextStat(l10n.mapLegendWant, '$totalWishlist', palette.wishlistColor),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Monospaced Country Code Chips: Intrinsic height (ZERO void)
        _buildMinimalCountryPills(visitedCountries, palette, l10n, currentLocale),
      ],
    );
  }

  // 4. SHOWCASE LAYOUT (Cinema Panoramic Hero Map — Map Focal Point)
  Widget _buildShowcaseLayout(
    AppLocalizations l10n,
    String currentLocale,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Showcase Header: Top-left EMPTY for Instagram
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: _buildTopHeaderBadge(
                palette: palette,
                title: '%${worldPercentage.toStringAsFixed(1)} ${l10n.ofTheWorld.toUpperCase()}',
                fallbackIcon: Icons.auto_awesome_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Immersive Hero Map - EXPANDED to dominate the story card
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildMapBox(palette, colorMap),
              ),
              // Floating Glass Coverage Badge on the map (bottom-left)
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: (palette.isLight ? Colors.white : Colors.black).withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: palette.accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.accentColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        StoryCardLocalization.getShowcaseExploredBadge(currentLocale, totalVisited),
                        style: TextStyle(
                          color: palette.textColor,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Translucent Floating Glass HUD: Intrinsic height (ZERO void)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick Summary Row
              Row(
                children: [
                  Expanded(child: _buildShowcaseStatTile(l10n.mapLegendBeen, '$totalVisited', Icons.flight_takeoff_rounded, palette.visitedColor, palette)),
                  Expanded(child: _buildShowcaseStatTile(l10n.mapLegendLived, '$totalLived', Icons.home_rounded, palette.livedColor, palette)),
                  Expanded(child: _buildShowcaseStatTile(l10n.continentsUnit, '$continentsCount/7', Icons.public_rounded, palette.accentColor, palette)),
                ],
              ),
              const SizedBox(height: 8),
              // Flags Grid inside HUD: Intrinsic height
              _buildBottomExplorerSection(visitedCountries, palette, l10n, currentLocale),
            ],
          ),
        ),
      ],
    );
  }

  // 5. JOURNEY LAYOUT (Authentic Travel Route & Expedition Milestones)
  Widget _buildJourneyLayout(
    AppLocalizations l10n,
    String currentLocale,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Symmetrical Journey Header: Top-left EMPTY for Instagram
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: _buildTopHeaderBadge(
                palette: palette,
                title: StoryCardLocalization.getJourneyLogHeader(currentLocale),
                fallbackIcon: Icons.route_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Route Milestone Banner (NO "TR", NO "WRLD" - Clean authentic travel progress)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: palette.tileBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.tileBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '%${worldPercentage.toStringAsFixed(1)}',
                    style: TextStyle(color: palette.textColor, fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    StoryCardLocalization.getExplorationRateHeader(currentLocale),
                    style: TextStyle(color: palette.subtextColor, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(child: Container(height: 1.5, color: palette.accentColor.withValues(alpha: 0.4))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.flight_takeoff_rounded, size: 14, color: palette.accentColor),
                      ),
                      Expanded(child: Container(height: 1.5, color: palette.accentColor.withValues(alpha: 0.4))),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    StoryCardLocalization.getCountriesCountBadge(currentLocale, totalVisited),
                    style: TextStyle(color: palette.textColor, fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    StoryCardLocalization.getContinentsCountBadge(currentLocale, continentsCount),
                    style: TextStyle(color: palette.accentColor, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Journey Map Canvas - EXPANDED to fill remaining vertical space
        Expanded(
          child: _buildMapBox(palette, colorMap),
        ),
        const SizedBox(height: 8),

        // 3 Key Journey Milestone Badges (NO fake boarding pass barcode or seats)
        Row(
          children: [
            Expanded(
              child: _buildJourneyStatPill(
                icon: Icons.flight_takeoff_rounded,
                label: l10n.mapLegendBeen,
                value: '$totalVisited',
                color: palette.visitedColor,
                palette: palette,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildJourneyStatPill(
                icon: Icons.home_rounded,
                label: l10n.mapLegendLived,
                value: '$totalLived',
                color: palette.livedColor,
                palette: palette,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildJourneyStatPill(
                icon: Icons.public_rounded,
                label: l10n.continentsUnit,
                value: '$continentsCount/7',
                color: palette.accentColor,
                palette: palette,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Visited Flags Grid: Intrinsic height (Proportional, ZERO void)
        _buildBottomExplorerSection(visitedCountries, palette, l10n, currentLocale),
      ],
    );
  }

  // 6. POLAROID LAYOUT (Vintage Postcard & Travel Keepsake)
  Widget _buildPolaroidLayout(
    AppLocalizations l10n,
    String currentLocale,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    final polaroidBg = palette.isLight
        ? const Color(0xFFFAF8F5)
        : const Color(0xFF1B2028);
    final polaroidBorder = palette.isLight
        ? const Color(0xFFE5DECE)
        : const Color(0xFF2E3846);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Symmetrical Postcard Header: Top-left EMPTY for Instagram
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: _buildTopHeaderBadge(
                palette: palette,
                title: StoryCardLocalization.getPostcardHeader(currentLocale),
                fallbackIcon: Icons.photo_filter_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Polaroid Photo Frame Card - EXPANDED to fill the card
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: polaroidBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: polaroidBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: palette.isLight ? 0.08 : 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Photo Canvas with subtle washi tape sticker - EXPANDED
                Expanded(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned.fill(
                        child: _buildMapBox(palette, colorMap),
                      ),
                      Positioned(
                        top: -4,
                        child: Container(
                          width: 48,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                // Polaroid Handwritten-style footer caption
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        StoryCardLocalization.getPostcardCaption(currentLocale, totalVisited),
                        style: TextStyle(
                          color: palette.isLight ? const Color(0xFF1E293B) : Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: palette.accentColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '%${worldPercentage.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: palette.accentColor,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Postcard Travel Note (Compact & clean, NO fake postal text)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: palette.tileBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.tileBorder),
          ),
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 16, color: palette.accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  StoryCardLocalization.getPostcardNote(currentLocale, totalVisited, continentsCount),
                  style: TextStyle(
                    color: palette.textColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Memorabilia Flags: Intrinsic height (ZERO void)
        _buildBottomExplorerSection(visitedCountries, palette, l10n, currentLocale),
      ],
    );
  }

  // 7. INFOGRAPHIC LAYOUT (Continental Analytics & Clean Explorer Grid)
  Widget _buildInfographicLayout(
    AppLocalizations l10n,
    String currentLocale,
    StoryCardPalette palette,
    Map<String, Color> colorMap,
    List<TravelCountry> visitedCountries,
  ) {
    // Calculate continents distribution
    final europeCount = visitedCountries.where((c) => c.continents.contains('Europe')).length;
    final asiaCount = visitedCountries.where((c) => c.continents.contains('Asia')).length;
    final americasCount = visitedCountries.where((c) => c.continents.contains('Americas')).length;
    final africaCount = visitedCountries.where((c) => c.continents.contains('Africa')).length;
    final oceaniaCount = visitedCountries.where((c) => c.continents.contains('Oceania')).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Symmetrical Top Header: Top-left EMPTY for Instagram
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: _buildTopHeaderBadge(
                palette: palette,
                title: StoryCardLocalization.getInfographicHeader(currentLocale),
                fallbackIcon: Icons.analytics_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Top Split: Big Radial-Style Stat + 4 Mini Gauges
        Row(
          children: [
            // Left Metric: World Coverage Dial
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: palette.tileBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.accentColor.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '%${worldPercentage.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: palette.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    l10n.ofTheWorld.toUpperCase(),
                    style: TextStyle(
                      color: palette.accentColor,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right Metric: 2x2 Data Grid (prevents horizontal overflow)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.tileBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: palette.tileBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildInfographicMiniCell(l10n.mapLegendBeen.toUpperCase(), '$totalVisited', palette.visitedColor)),
                        Expanded(child: _buildInfographicMiniCell(l10n.mapLegendLived.toUpperCase(), '$totalLived', palette.livedColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _buildInfographicMiniCell(l10n.mapLegendWant.toUpperCase(), '$totalWishlist', palette.wishlistColor)),
                        Expanded(child: _buildInfographicMiniCell(l10n.continentsUnit.toUpperCase(), '$continentsCount/7', palette.accentColor)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Map Canvas - EXPANDED to fill remaining vertical space
        Expanded(
          child: _buildMapBox(palette, colorMap),
        ),
        const SizedBox(height: 8),

        // Continental Coverage Spectrum Matrix
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: palette.tileBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.tileBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildContinentBadge('🇪🇺 EU', europeCount, palette),
              _buildContinentBadge('🌏 AS', asiaCount, palette),
              _buildContinentBadge('🌎 AM', americasCount, palette),
              _buildContinentBadge('🌍 AF', africaCount, palette),
              _buildContinentBadge('🌊 OC', oceaniaCount, palette),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Bottom Flags Section: Intrinsic height (ZERO void)
        _buildBottomExplorerSection(visitedCountries, palette, l10n, currentLocale),
      ],
    );
  }

  // --- REUSABLE SUB-WIDGETS & ADAPTIVE ZERO-GAP SECTIONS ---

  Widget _buildJourneyStatPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required StoryCardPalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: palette.tileBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.tileBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: palette.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: palette.subtextColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalCountryPills(List<TravelCountry> visited, StoryCardPalette palette, AppLocalizations l10n, String currentLocale) {
    if (visited.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            StoryCardLocalization.getMinimalQuote(currentLocale),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.subtextColor,
              fontSize: 10,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.3,
              height: 1.4,
            ),
          ),
        ),
      );
    }
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 5,
        children: visited.take(16).map((c) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: palette.isLight ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: c.isLived ? palette.livedColor : palette.tileBorder,
                width: c.isLived ? 1.2 : 0.8,
              ),
            ),
            child: Text(
              c.code.toUpperCase(),
              style: TextStyle(
                color: c.isLived ? palette.livedColor : palette.textColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                letterSpacing: 0.8,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfographicMiniCell(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContinentBadge(String label, int count, StoryCardPalette palette) {
    final active = count > 0;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? palette.accentColor.withValues(alpha: 0.18)
              : (palette.isLight ? Colors.black.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? palette.accentColor.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? palette.textColor : palette.subtextColor,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              '$count',
              style: TextStyle(
                color: active ? palette.accentColor : palette.subtextColor,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportLowerSection(
    List<TravelCountry> visitedCountries,
    StoryCardPalette palette,
    AppLocalizations l10n,
    String currentLocale,
  ) {
    if (visitedCountries.isEmpty) {
      final wishlistCountries = countries.where((c) => c.isWishlist).take(6).toList();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.tileBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.accentColor.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_outlined, size: 16, color: palette.accentColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    StoryCardLocalization.getVisaPendingBadge(currentLocale),
                    style: TextStyle(
                      color: palette.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (wishlistCountries.isNotEmpty) ...[
              Text(
                StoryCardLocalization.getTargetDestinationsHeader(currentLocale),
                style: TextStyle(
                  color: palette.subtextColor,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: wishlistCountries.map((c) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: palette.accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryFlag(code: c.code, fallbackEmoji: c.flag, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        c.getLocalizedName(l10n.localeName),
                        style: TextStyle(
                          color: palette.textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ] else
              Text(
                StoryCardLocalization.getReadyForTakeoffHint(currentLocale),
                style: TextStyle(
                  color: palette.subtextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.military_tech_rounded, size: 14, color: palette.accentColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.passportEntryVisas.toUpperCase(),
                  style: TextStyle(
                    color: palette.subtextColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        visitedCountries.length <= 4
            ? _buildPassportVisaStamps(visitedCountries, palette, l10n, currentLocale)
            : _buildFlagsGrid(visitedCountries, palette, l10n, currentLocale),
      ],
    );
  }

  Widget _buildBottomExplorerSection(
    List<TravelCountry> visitedCountries,
    StoryCardPalette palette,
    AppLocalizations l10n,
    String currentLocale,
  ) {
    if (visitedCountries.isEmpty) {
      final wishlistCountries = countries.where((c) => c.isWishlist).take(8).toList();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: palette.tileBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.tileBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore_rounded, color: palette.accentColor, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    wishlistCountries.isNotEmpty
                        ? StoryCardLocalization.getNextRadarHeader(currentLocale)
                        : StoryCardLocalization.getHorizonAwaitsHeader(currentLocale),
                    style: TextStyle(
                      color: palette.accentColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (wishlistCountries.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: wishlistCountries.map((c) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: palette.wishlistColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: palette.wishlistColor.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryFlag(code: c.code, fallbackEmoji: c.flag, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        c.getLocalizedName(l10n.localeName),
                        style: TextStyle(
                          color: palette.textColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.bookmark_added_rounded, size: 12, color: palette.wishlistColor),
                    ],
                  ),
                )).toList(),
              )
            else
              Text(
                StoryCardLocalization.getExplorerEmptyPrompt(currentLocale),
                style: TextStyle(
                  color: palette.subtextColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      );
    }

    if (visitedCountries.length <= 4) {
      final wishlistCountries = countries.where((c) => c.isWishlist).toList();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: palette.tileBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.tileBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: visitedCountries.map((c) {
                final isLived = c.isLived;
                final statusColor = isLived ? palette.livedColor : palette.visitedColor;
                final statusText = isLived ? l10n.mapLegendLived : l10n.mapLegendBeen;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: palette.isLight
                        ? Colors.black.withValues(alpha: 0.04)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryFlag(code: c.code, fallbackEmoji: c.flag, size: 18),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 90),
                        child: Text(
                          c.getLocalizedName(l10n.localeName),
                          style: TextStyle(
                            color: palette.textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (wishlistCountries.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.near_me_rounded, size: 11, color: palette.wishlistColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${l10n.mapLegendWant}: ${wishlistCountries.map((c) => c.getLocalizedName(l10n.localeName)).join(', ')}',
                        style: TextStyle(
                          color: palette.subtextColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
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

    return _buildFlagsGrid(visitedCountries, palette, l10n, currentLocale);
  }

  // --- REUSABLE SUB-WIDGETS ---

  Widget _buildMapBox(StoryCardPalette palette, Map<String, Color> colorMap, {double? height}) {
    return Container(
      height: (height == null || height == double.infinity) ? null : height,
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
                instructions: WorldMapInstructions.instructions,
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
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 9.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: palette.textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(
                  color: palette.subtextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 8.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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

  Widget _buildPassportVisaStamps(
    List<TravelCountry> visitedCountries,
    StoryCardPalette palette,
    AppLocalizations l10n,
    String currentLocale,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.tileBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.tileBorder),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: visitedCountries.take(4).map((c) {
          final isEven = c.code.hashCode % 2 == 0;
          final angle = isEven ? -0.04 : 0.04;
          final stampColor = c.isLived ? palette.livedColor : palette.accentColor;

          return Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: stampColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: stampColor.withValues(alpha: 0.65),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryFlag(code: c.code, fallbackEmoji: c.flag, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        c.code.toUpperCase(),
                        style: TextStyle(
                          color: stampColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    StoryCardLocalization.getVisaAdmittedStamp(currentLocale),
                    style: TextStyle(
                      color: stampColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w800,
                      fontSize: 8,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    c.getLocalizedName(l10n.localeName),
                    style: TextStyle(
                      color: palette.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 9.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlagsGrid(
    List<TravelCountry> visitedCountries,
    StoryCardPalette palette,
    AppLocalizations l10n,
    String currentLocale,
  ) {
    final count = visitedCountries.length;

    // Rich Country Cards layout when few countries are visited (prevents empty, boring voids)
    if (count <= 6) {
      if (count == 0) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: palette.tileBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.tileBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_outlined, color: palette.accentColor, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  StoryCardLocalization.getNewAdventuresPrompt(currentLocale),
                  style: TextStyle(
                    color: palette.subtextColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: palette.tileBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.tileBorder),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: visitedCountries.map((c) {
            final isLived = c.isLived;
            final statusColor = isLived ? palette.livedColor : palette.visitedColor;
            final statusText = isLived ? l10n.mapLegendLived : l10n.mapLegendBeen;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: palette.isLight
                    ? Colors.black.withValues(alpha: 0.04)
                    : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryFlag(
                    code: c.code,
                    fallbackEmoji: c.flag,
                    size: 20,
                  ),
                  const SizedBox(width: 7),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 95),
                    child: Text(
                      c.getLocalizedName(l10n.localeName),
                      style: TextStyle(
                        color: palette.textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    final double flagSize;
    final double spacing;
    final double runSpacing;
    final EdgeInsets pad;

    if (count <= 15) {
      flagSize = 20.0;
      spacing = 6.0;
      runSpacing = 5.0;
      pad = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else if (count <= 30) {
      flagSize = 16.0;
      spacing = 4.5;
      runSpacing = 4.0;
      pad = const EdgeInsets.symmetric(horizontal: 10, vertical: 7);
    } else if (count <= 60) {
      flagSize = 13.0;
      spacing = 3.5;
      runSpacing = 3.0;
      pad = const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    } else if (count <= 100) {
      flagSize = 10.5;
      spacing = 2.5;
      runSpacing = 2.0;
      pad = const EdgeInsets.symmetric(horizontal: 6, vertical: 5);
    } else if (count <= 150) {
      flagSize = 9.0;
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
