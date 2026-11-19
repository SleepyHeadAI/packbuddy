import 'package:flutter/material.dart';

/// Badge achievement tiers with distinct metallic styling
enum BadgeTier {
  bronze,
  silver,
  gold,
  diamond;

  Color get primaryColor {
    switch (this) {
      case BadgeTier.bronze:
        return const Color(0xFFCD7F32);
      case BadgeTier.silver:
        return const Color(0xFF9E9E9E);
      case BadgeTier.gold:
        return const Color(0xFFFFB300);
      case BadgeTier.diamond:
        return const Color(0xFF00BCD4);
    }
  }

  Color get secondaryColor {
    switch (this) {
      case BadgeTier.bronze:
        return const Color(0xFF8D5524);
      case BadgeTier.silver:
        return const Color(0xFF757575);
      case BadgeTier.gold:
        return const Color(0xFFFF8F00);
      case BadgeTier.diamond:
        return const Color(0xFF0097A7);
    }
  }

  String getLocalizedLabel(String lang) {
    final clean = lang.toLowerCase().split('_').first.split('-').first;
    switch (this) {
      case BadgeTier.bronze:
        switch (clean) {
          case 'tr': return 'Bronz';
          case 'de': return 'Bronze';
          case 'es': return 'Bronce';
          case 'fr': return 'Bronze';
          case 'it': return 'Bronzo';
          case 'pt': return 'Bronze';
          case 'ru': return 'Бронза';
          case 'zh': return '青铜';
          case 'ja': return 'ブロンズ';
          case 'ko': return '브론즈';
          case 'ar': return 'برونزي';
          default: return 'Bronze';
        }
      case BadgeTier.silver:
        switch (clean) {
          case 'tr': return 'Gümüş';
          case 'de': return 'Silber';
          case 'es': return 'Plata';
          case 'fr': return 'Argent';
          case 'it': return 'Argento';
          case 'pt': return 'Prata';
          case 'ru': return 'Серебро';
          case 'zh': return '白银';
          case 'ja': return 'シルバー';
          case 'ko': return '실버';
          case 'ar': return 'فضي';
          default: return 'Silver';
        }
      case BadgeTier.gold:
        switch (clean) {
          case 'tr': return 'Altın';
          case 'de': return 'Gold';
          case 'es': return 'Oro';
          case 'fr': return 'Or';
          case 'it': return 'Oro';
          case 'pt': return 'Ouro';
          case 'ru': return 'Золото';
          case 'zh': return '黄金';
          case 'ja': return 'ゴールド';
          case 'ko': return '골드';
          case 'ar': return 'ذهبي';
          default: return 'Gold';
        }
      case BadgeTier.diamond:
        switch (clean) {
          case 'tr': return 'Elmas';
          case 'de': return 'Diamant';
          case 'es': return 'Diamante';
          case 'fr': return 'Diamant';
          case 'it': return 'Diamante';
          case 'pt': return 'Diamante';
          case 'ru': return 'Алмаз';
          case 'zh': return '钻石';
          case 'ja': return 'ダイヤモンド';
          case 'ko': return '다이아몬드';
          case 'ar': return 'ماسي';
          default: return 'Diamond';
        }
    }
  }
}

/// Domain model representing an automatically earned or progressive travel achievement badge
class TravelBadge {
  final String id;
  final String category;
  final IconData iconData;
  final BadgeTier tier;
  final int currentProgress;
  final int targetProgress;
  final bool isUnlocked;

  const TravelBadge({
    required this.id,
    required this.category,
    required this.iconData,
    required this.tier,
    required this.currentProgress,
    required this.targetProgress,
    required this.isUnlocked,
  });

  double get progressRatio => targetProgress > 0
      ? (currentProgress / targetProgress).clamp(0.0, 1.0)
      : (isUnlocked ? 1.0 : 0.0);

  String getLocalizedTitle(String lang) {
    final clean = lang.toLowerCase().split('_').first.split('-').first;
    switch (id) {
      case 'explorer_bronze':
        return clean == 'tr' ? 'İlk Sınır Ötesi' : 'Border Hopper';
      case 'explorer_silver':
        return clean == 'tr' ? 'Kıta Gezgini' : 'Continental Wanderer';
      case 'explorer_gold':
        return clean == 'tr' ? 'Dünya Kaşifi' : 'Globe Trotter';
      case 'explorer_diamond':
        return clean == 'tr' ? 'Evrensel Kaşif' : 'Universal Explorer';

      case 'trips_bronze':
        return clean == 'tr' ? 'İlk Yolculuk' : 'First Journey';
      case 'trips_silver':
        return clean == 'tr' ? 'Yol Tutkunu' : 'Road Enthusiast';
      case 'trips_gold':
        return clean == 'tr' ? 'Seyahat Ustası' : 'Master Traveler';
      case 'trips_diamond':
        return clean == 'tr' ? 'Efsanevi Seyyah' : 'Legendary Nomad';

      case 'packing_bronze':
        return clean == 'tr' ? 'Hazırlıklı Bavul' : 'Ready Luggage';
      case 'packing_silver':
        return clean == 'tr' ? 'Kompakt Paketleyici' : 'Compact Packer';
      case 'packing_gold':
        return clean == 'tr' ? 'Bavul Virtüözü' : 'Packing Virtuoso';
      case 'packing_diamond':
        return clean == 'tr' ? 'Kusursuz Lojistik' : 'Flawless Logistics';

      case 'vault_bronze':
        return clean == 'tr' ? 'Güvenli Yolcu' : 'Protected Traveler';
      case 'vault_silver':
        return clean == 'tr' ? 'Evrak Muhafızı' : 'Vault Sentinel';
      case 'vault_gold':
        return clean == 'tr' ? 'Eksiksiz Arşiv' : 'Flawless Archive';

      default:
        return 'Traveler Badge';
    }
  }

  String getLocalizedDescription(String lang) {
    final clean = lang.toLowerCase().split('_').first.split('-').first;
    switch (id) {
      case 'explorer_bronze':
        return clean == 'tr' ? '1 ülke ziyaret edildi' : '1 country visited';
      case 'explorer_silver':
        return clean == 'tr' ? '5 ülke ziyaret edildi' : '5 countries visited';
      case 'explorer_gold':
        return clean == 'tr' ? '10 ülke ziyaret edildi' : '10 countries visited';
      case 'explorer_diamond':
        return clean == 'tr' ? '25 ülke ziyaret edildi' : '25 countries visited';

      case 'trips_bronze':
        return clean == 'tr' ? '1 seyahat planlandı' : '1 trip planned';
      case 'trips_silver':
        return clean == 'tr' ? '5 seyahat tamamlandı' : '5 trips completed';
      case 'trips_gold':
        return clean == 'tr' ? '15 seyahat tamamlandı' : '15 trips completed';
      case 'trips_diamond':
        return clean == 'tr' ? '30 seyahat tamamlandı' : '30 trips completed';

      case 'packing_bronze':
        return clean == 'tr' ? '25 bavul eşyası eklendi' : '25 items packed';
      case 'packing_silver':
        return clean == 'tr' ? '100 bavul eşyası hazırlandı' : '100 items packed';
      case 'packing_gold':
        return clean == 'tr' ? '250 bavul eşyası organize edildi' : '250 items packed';
      case 'packing_diamond':
        return clean == 'tr' ? '500 bavul eşyası organize edildi' : '500 items packed';

      case 'vault_bronze':
        return clean == 'tr' ? '1 seyahat belgesi kasada korundu' : '1 travel doc secured in vault';
      case 'vault_silver':
        return clean == 'tr' ? '5 seyahat belgesi kasada korundu' : '5 travel docs secured in vault';
      case 'vault_gold':
        return clean == 'tr' ? '15 seyahat belgesi kasada korundu' : '15 travel docs secured in vault';

      default:
        return '';
    }
  }

  /// Calculates the complete achievement list from live user statistics
  static List<TravelBadge> calculateBadges({
    required int totalTrips,
    required int totalCountries,
    required int totalItems,
    required int totalDocuments,
  }) {
    return [
      // 1. World Explorer Milestones
      TravelBadge(
        id: 'explorer_bronze',
        category: 'countries',
        iconData: Icons.explore_rounded,
        tier: BadgeTier.bronze,
        currentProgress: totalCountries,
        targetProgress: 1,
        isUnlocked: totalCountries >= 1,
      ),
      TravelBadge(
        id: 'explorer_silver',
        category: 'countries',
        iconData: Icons.public_rounded,
        tier: BadgeTier.silver,
        currentProgress: totalCountries,
        targetProgress: 5,
        isUnlocked: totalCountries >= 5,
      ),
      TravelBadge(
        id: 'explorer_gold',
        category: 'countries',
        iconData: Icons.language_rounded,
        tier: BadgeTier.gold,
        currentProgress: totalCountries,
        targetProgress: 10,
        isUnlocked: totalCountries >= 10,
      ),
      TravelBadge(
        id: 'explorer_diamond',
        category: 'countries',
        iconData: Icons.auto_awesome_rounded,
        tier: BadgeTier.diamond,
        currentProgress: totalCountries,
        targetProgress: 25,
        isUnlocked: totalCountries >= 25,
      ),

      // 2. Trips Milestones
      TravelBadge(
        id: 'trips_bronze',
        category: 'trips',
        iconData: Icons.flight_takeoff_rounded,
        tier: BadgeTier.bronze,
        currentProgress: totalTrips,
        targetProgress: 1,
        isUnlocked: totalTrips >= 1,
      ),
      TravelBadge(
        id: 'trips_silver',
        category: 'trips',
        iconData: Icons.flight_rounded,
        tier: BadgeTier.silver,
        currentProgress: totalTrips,
        targetProgress: 5,
        isUnlocked: totalTrips >= 5,
      ),
      TravelBadge(
        id: 'trips_gold',
        category: 'trips',
        iconData: Icons.connecting_airports_rounded,
        tier: BadgeTier.gold,
        currentProgress: totalTrips,
        targetProgress: 15,
        isUnlocked: totalTrips >= 15,
      ),
      TravelBadge(
        id: 'trips_diamond',
        category: 'trips',
        iconData: Icons.stars_rounded,
        tier: BadgeTier.diamond,
        currentProgress: totalTrips,
        targetProgress: 30,
        isUnlocked: totalTrips >= 30,
      ),

      // 3. Packing Milestones
      TravelBadge(
        id: 'packing_bronze',
        category: 'items',
        iconData: Icons.check_circle_outline_rounded,
        tier: BadgeTier.bronze,
        currentProgress: totalItems,
        targetProgress: 25,
        isUnlocked: totalItems >= 25,
      ),
      TravelBadge(
        id: 'packing_silver',
        category: 'items',
        iconData: Icons.inventory_2_rounded,
        tier: BadgeTier.silver,
        currentProgress: totalItems,
        targetProgress: 100,
        isUnlocked: totalItems >= 100,
      ),
      TravelBadge(
        id: 'packing_gold',
        category: 'items',
        iconData: Icons.task_alt_rounded,
        tier: BadgeTier.gold,
        currentProgress: totalItems,
        targetProgress: 250,
        isUnlocked: totalItems >= 250,
      ),
      TravelBadge(
        id: 'packing_diamond',
        category: 'items',
        iconData: Icons.verified_rounded,
        tier: BadgeTier.diamond,
        currentProgress: totalItems,
        targetProgress: 500,
        isUnlocked: totalItems >= 500,
      ),

      // 4. Vault Documents Milestones
      TravelBadge(
        id: 'vault_bronze',
        category: 'docs',
        iconData: Icons.security_rounded,
        tier: BadgeTier.bronze,
        currentProgress: totalDocuments,
        targetProgress: 1,
        isUnlocked: totalDocuments >= 1,
      ),
      TravelBadge(
        id: 'vault_silver',
        category: 'docs',
        iconData: Icons.lock_clock_rounded,
        tier: BadgeTier.silver,
        currentProgress: totalDocuments,
        targetProgress: 5,
        isUnlocked: totalDocuments >= 5,
      ),
      TravelBadge(
        id: 'vault_gold',
        category: 'docs',
        iconData: Icons.shield_rounded,
        tier: BadgeTier.gold,
        currentProgress: totalDocuments,
        targetProgress: 15,
        isUnlocked: totalDocuments >= 15,
      ),
    ];
  }
}
