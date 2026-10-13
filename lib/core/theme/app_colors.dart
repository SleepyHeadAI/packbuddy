import 'package:flutter/material.dart';

/// Sophisticated, executive color palette for PackBuddy
/// Featuring deep Slate Navy / Midnight Blue, soft pearl off-white, OLED-friendly dark slate,
/// calming muted sage green for success, and warm terracotta/coral accents.
class AppColors {
  // Light Palette - Eye-Friendly Luxury Travel (Soft Alabaster & Cool Slate)
  static const Color primaryLight = Color(0xFF1E3A8A); // Royal Slate / Executive Indigo
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFE2E8F0); // Porcelain Slate
  static const Color onPrimaryContainerLight = Color(0xFF0F172A); // Deepest Slate

  static const Color secondaryLight = Color(0xFF475569); // Balanced Slate
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFE9EEF5); // Muted Cool Alabaster
  static const Color onSecondaryContainerLight = Color(0xFF0F172A);

  static const Color tertiaryLight = Color(0xFFD96B43); // Soft Sunset Terracotta
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFFBEBE6); // Warm Silk Terracotta
  static const Color onTertiaryContainerLight = Color(0xFF7A2B14);

  // Soothing, low-glare surface architecture (Zero harsh #FFFFFF backgrounds)
  static const Color backgroundLight = Color(0xFFF2F4F8); // Soft Slate Mist (Zero eye strain scaffold)
  static const Color surfaceLight = Color(0xFFFAFBFD); // Warm Pearl / Off-White (Primary card & sheet surface)
  static const Color surfaceVariantLight = Color(0xFFE9EEF5); // Muted Cool Alabaster (Inputs, chips, nested containers)
  static const Color onSurfaceLight = Color(0xFF0F172A); // Deep Slate for titles
  static const Color onSurfaceVariantLight = Color(0xFF475569); // Balanced Slate for body/subtitles
  static const Color textMutedLight = Color(0xFF64748B); // Muted Slate for captions

  static const Color outlineLight = Color(0xFFDDE3ED); // 1px crisp hairline border
  static const Color outlineVariantLight = Color(0xFFE2E8F0);

  // Dark Palette - OLED & Eye-Comfort Dark Slate Architecture
  static const Color primaryDark = Color(0xFF93C5FD); // Radiant Soft Indigo / Sky Slate
  static const Color onPrimaryDark = Color(0xFF0B132B);
  static const Color primaryContainerDark = Color(0xFF1E293B);
  static const Color onPrimaryContainerDark = Color(0xFFE2E8F0);

  static const Color secondaryDark = Color(0xFF94A3B8); // Cool Slate
  static const Color onSecondaryDark = Color(0xFF0B0F17);
  static const Color secondaryContainerDark = Color(0xFF1E293B);
  static const Color onSecondaryContainerDark = Color(0xFFE2E8F0);

  static const Color tertiaryDark = Color(0xFFF28F6C); // Soft Terracotta Glow
  static const Color onTertiaryDark = Color(0xFF3E1205);
  static const Color tertiaryContainerDark = Color(0xFF6E2612);
  static const Color onTertiaryContainerDark = Color(0xFFFFDFD6);

  static const Color backgroundDark = Color(0xFF0B0F17); // Refined Dark Scaffold
  static const Color surfaceDark = Color(0xFF151C28); // Refined Dark Card Surface
  static const Color surfaceVariantDark = Color(0xFF1E293B); // Inputs, borders, nested containers
  static const Color onSurfaceDark = Color(0xFFF8FAFC); // Crisp Light for titles
  static const Color onSurfaceVariantDark = Color(0xFFCBD5E1); // Balanced Slate for body
  static const Color textMutedDark = Color(0xFF94A3B8); // Muted Slate for captions

  static const Color outlineDark = Color(0xFF1E293B); // Crisp dark hairline border
  static const Color outlineVariantDark = Color(0xFF26334D);

  // Rich Semantic & Travel Status Colors
  static const Color successPastel = Color(0xFF10B981); // Emerald / Sage Green
  static const Color successContainerLight = Color(0xFFECFDF5);
  static const Color successContainerDark = Color(0xFF064E3B);
  static const Color warningPastel = Color(0xFFF59E0B); // Warm Amber / Coral
  static const Color warningContainerLight = Color(0xFFFFFBEB);
  static const Color warningContainerDark = Color(0xFF78350F);
  static const Color errorPastel = Color(0xFFEF4444); // Refined Soft Coral Red
  static const Color errorContainerLight = Color(0xFFFEF2F2);
  static const Color errorContainerDark = Color(0xFF7F1D1D);
  static const Color infoPastel = Color(0xFF3B82F6); // Calm Indigo Blue
  static const Color infoContainerLight = Color(0xFFEFF6FF);
  static const Color infoContainerDark = Color(0xFF1E3A8A);

  // Special Luxury Travel Accents
  static const Color passportNavy = Color(0xFF132238); // Royal Midnight Navy
  static const Color goldAccent = Color(0xFFD4A054); // Champagne Gold Foil
  static const Color terracotta = Color(0xFFD96B43);
}

/// Global smooth animation standards for PackBuddy
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration smooth = Duration(milliseconds: 500);
  static const Duration relaxed = Duration(milliseconds: 750);

  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve gentleCurve = Curves.easeInOutCubic;
  static const Curve springCurve = Curves.easeOutBack;
}
