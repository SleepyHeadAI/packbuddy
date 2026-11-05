import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';

/// Helper and metadata resolver for baggage / luggage tags
class PackingTagHelper {
  static const String tagCarryOn = 'CARRY-ON';
  static const String tagCabinOnly = 'CABIN ONLY';
  static const String tagCheckIn = 'CHECK-IN';
  static const String tagEssential = 'ESSENTIAL';

  static const List<String> standardTags = [
    tagCarryOn,
    tagCabinOnly,
    tagCheckIn,
    tagEssential,
  ];

  /// Full localized label for dropdown menus and item dialogs
  static String getLocalizedTag(String rawTag, String langCode) {
    final code = langCode.toLowerCase();
    final isTr = code.startsWith('tr');
    final isDe = code.startsWith('de');
    final isFr = code.startsWith('fr');
    final isEs = code.startsWith('es');
    final isRu = code.startsWith('ru');
    final isIt = code.startsWith('it');

    final normalized = rawTag.trim().toUpperCase();

    if (normalized == tagCarryOn || normalized == 'CABIN' || normalized == 'KABIN') {
      if (isTr) return 'Kabin Bagajı';
      if (isDe) return 'Handgepäck';
      if (isFr) return 'Bagage Cabine';
      if (isEs) return 'Equipaje de Mano';
      if (isIt) return 'Bagaglio a Mano';
      if (isRu) return 'Ручная кладь';
      return 'Carry-On (Cabin)';
    }

    if (normalized == tagCabinOnly || normalized == 'PERSONAL' || normalized == 'KIŞISEL' || normalized == 'KISISEL') {
      if (isTr) return 'Kişisel Eşya (Sırt Çantası)';
      if (isDe) return 'Persönlicher Gegenstand';
      if (isFr) return 'Accessoire Personnel';
      if (isEs) return 'Artículo Personal';
      if (isIt) return 'Oggetto Personale';
      if (isRu) return 'Личная вещь (Рюкзак)';
      return 'Personal Item (Backpack)';
    }

    if (normalized == tagCheckIn || normalized == 'CHECKED' || normalized == 'CARGO' || normalized == 'UÇAK ALTI') {
      if (isTr) return 'Uçak Altı (Kargo Bagajı)';
      if (isDe) return 'Aufgabegepäck (Kargo)';
      if (isFr) return 'Bagage en Soute';
      if (isEs) return 'Equipaje Facturado';
      if (isIt) return 'Bagaglio da Stiva';
      if (isRu) return 'Регистрируемый багаж';
      return 'Checked Baggage (Cargo)';
    }

    if (normalized == tagEssential || normalized == 'ÖNEMLI' || normalized == 'ONEMLI') {
      if (isTr) return 'Önemli / Yanına Al';
      if (isDe) return 'Wichtig / Immer dabei';
      if (isFr) return 'Essentiel / Sur soi';
      if (isEs) return 'Esencial / Conmigo';
      if (isIt) return 'Essenziale';
      if (isRu) return 'Важное / С собой';
      return 'Essential / Always With Me';
    }

    return rawTag;
  }

  /// Compact short label for mini badges inside packing list item tiles
  static String getShortTag(String rawTag, String langCode) {
    final code = langCode.toLowerCase();
    final isTr = code.startsWith('tr');
    final isDe = code.startsWith('de');
    final isFr = code.startsWith('fr');
    final isEs = code.startsWith('es');
    final isRu = code.startsWith('ru');

    final normalized = rawTag.trim().toUpperCase();

    if (normalized == tagCarryOn || normalized == 'CABIN' || normalized == 'KABIN') {
      if (isTr) return 'Kabin';
      if (isDe) return 'Kabine';
      if (isFr) return 'Cabine';
      if (isEs) return 'Cabina';
      if (isRu) return 'Кабина';
      return 'Cabin';
    }

    if (normalized == tagCabinOnly || normalized == 'PERSONAL' || normalized == 'KIŞISEL' || normalized == 'KISISEL') {
      if (isTr) return 'Kişisel';
      if (isDe) return 'Persönlich';
      if (isFr) return 'Personnel';
      if (isEs) return 'Personal';
      if (isRu) return 'Личное';
      return 'Personal';
    }

    if (normalized == tagCheckIn || normalized == 'CHECKED' || normalized == 'CARGO' || normalized == 'UÇAK ALTI') {
      if (isTr) return 'Uçak Altı';
      if (isDe) return 'Aufgabe';
      if (isFr) return 'En Soute';
      if (isEs) return 'Facturado';
      if (isRu) return 'Багаж';
      return 'Checked';
    }

    if (normalized == tagEssential || normalized == 'ÖNEMLI' || normalized == 'ONEMLI') {
      if (isTr) return 'Önemli';
      if (isDe) return 'Wichtig';
      if (isFr) return 'Essentiel';
      if (isEs) return 'Esencial';
      if (isRu) return 'Важно';
      return 'Essential';
    }

    return rawTag;
  }

  static IconData getTagIcon(String rawTag) {
    final normalized = rawTag.trim().toUpperCase();
    if (normalized == tagCarryOn || normalized == 'CABIN' || normalized == 'KABIN') {
      return Icons.luggage_rounded;
    }
    if (normalized == tagCabinOnly || normalized == 'PERSONAL' || normalized == 'KIŞISEL' || normalized == 'KISISEL') {
      return Icons.backpack_outlined;
    }
    if (normalized == tagCheckIn || normalized == 'CHECKED' || normalized == 'CARGO' || normalized == 'UÇAK ALTI') {
      return Icons.work_outline_rounded;
    }
    if (normalized == tagEssential || normalized == 'ÖNEMLI' || normalized == 'ONEMLI') {
      return Icons.star_rounded;
    }
    return Icons.sell_outlined;
  }

  static Color getTagColor(String rawTag, bool isDark) {
    final normalized = rawTag.trim().toUpperCase();
    if (normalized == tagCarryOn || normalized == 'CABIN' || normalized == 'KABIN') {
      return isDark ? AppColors.primaryAmber : AppColors.primaryLight;
    }
    if (normalized == tagCabinOnly || normalized == 'PERSONAL' || normalized == 'KIŞISEL' || normalized == 'KISISEL') {
      return isDark ? const Color(0xFF94A3B8) : AppColors.tertiaryLight;
    }
    if (normalized == tagCheckIn || normalized == 'CHECKED' || normalized == 'CARGO' || normalized == 'UÇAK ALTI') {
      return isDark ? const Color(0xFF2DD4BF) : AppColors.secondaryLight;
    }
    if (normalized == tagEssential || normalized == 'ÖNEMLI' || normalized == 'ONEMLI') {
      return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    }
    return isDark ? AppColors.primaryAmber : AppColors.primaryLight;
  }

  static Color getTagBgColor(String rawTag, bool isDark) {
    final normalized = rawTag.trim().toUpperCase();
    if (normalized == tagCarryOn || normalized == 'CABIN' || normalized == 'KABIN') {
      return isDark
          ? AppColors.primaryContainerDark.withValues(alpha: 0.35)
          : AppColors.primaryContainerLight.withValues(alpha: 0.35);
    }
    if (normalized == tagCabinOnly || normalized == 'PERSONAL' || normalized == 'KIŞISEL' || normalized == 'KISISEL') {
      return isDark
          ? Colors.white.withValues(alpha: 0.05)
          : const Color(0xFFF1F5F9);
    }
    if (normalized == tagCheckIn || normalized == 'CHECKED' || normalized == 'CARGO' || normalized == 'UÇAK ALTI') {
      return isDark
          ? const Color(0xFF0F766E).withValues(alpha: 0.2)
          : const Color(0xFFCCFBF1);
    }
    if (normalized == tagEssential || normalized == 'ÖNEMLI' || normalized == 'ONEMLI') {
      return isDark
          ? const Color(0xFFDC2626).withValues(alpha: 0.15)
          : const Color(0xFFFEE2E2);
    }
    return isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
  }

  static Color getTagBorderColor(String rawTag, bool isDark) {
    final normalized = rawTag.trim().toUpperCase();
    if (normalized == tagCarryOn || normalized == 'CABIN' || normalized == 'KABIN') {
      return isDark
          ? AppColors.primaryDark.withValues(alpha: 0.5)
          : AppColors.primaryLight.withValues(alpha: 0.35);
    }
    if (normalized == tagCabinOnly || normalized == 'PERSONAL' || normalized == 'KIŞISEL' || normalized == 'KISISEL') {
      return isDark
          ? AppColors.outlineDark
          : AppColors.outlineLight;
    }
    if (normalized == tagCheckIn || normalized == 'CHECKED' || normalized == 'CARGO' || normalized == 'UÇAK ALTI') {
      return isDark
          ? const Color(0xFF0F766E).withValues(alpha: 0.6)
          : AppColors.secondaryLight.withValues(alpha: 0.45);
    }
    if (normalized == tagEssential || normalized == 'ÖNEMLI' || normalized == 'ONEMLI') {
      return isDark
          ? const Color(0xFFDC2626).withValues(alpha: 0.5)
          : const Color(0xFFDC2626).withValues(alpha: 0.35);
    }
    return isDark ? AppColors.outlineDark : AppColors.outlineLight;
  }
}

