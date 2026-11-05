import 'package:flutter/material.dart';

/// Serene Voyage color palette for PackBuddy
/// Inspired by the Serene Voyage executive design system:
/// - Primary: Warm Sun Gold / Ochre (#E7B623 / #856404)
/// - Secondary: Deep Pine Teal / Sea Emerald (#0F766E)
/// - Tertiary: Slate Grey-Blue (#64748B)
/// - Neutral: Soft Pearl Alabaster (#F3F5F7)
class AppColors {
  // Serene Voyage Light Palette
  static const Color primaryLight = Color(0xFF856404); // Warm Golden Ochre (a touch lighter, richer & friendlier)
  static const Color primaryAmber = Color(0xFFE7B623); // Core Serene Voyage Gold
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFF2DC9D); // Rich Warm Golden Cream (distinct from white)
  static const Color onPrimaryContainerLight = Color(0xFF543C00); // Deep Amber Ochre Text

  static const Color secondaryLight = Color(0xFF0F766E); // Core Serene Voyage Teal
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFE0F2F1); // Soft Marine Mint Container
  static const Color onSecondaryContainerLight = Color(0xFF042F2E);

  static const Color tertiaryLight = Color(0xFF64748B); // Core Serene Voyage Slate
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFF1F5F9); // Soft Cool Cloud Container
  static const Color onTertiaryContainerLight = Color(0xFF0F172A);

  // Soothing, low-glare surface architecture (Neutral #F3F5F7)
  static const Color backgroundLight = Color(0xFFF3F5F7); // Core Serene Voyage Neutral Scaffold
  static const Color surfaceLight = Color(0xFFFFFFFF); // Clean Crisp Card & Sheet Surface
  static const Color surfaceVariantLight = Color(0xFFEAECEF); // Muted Cool Alabaster (Inputs, chips, search)
  static const Color onSurfaceLight = Color(0xFF0F172A); // Deep Slate for titles
  static const Color onSurfaceVariantLight = Color(0xFF475569); // Balanced Slate for body/subtitles
  static const Color textMutedLight = Color(0xFF64748B); // Muted Slate for captions

  static const Color outlineLight = Color(0xFFE2E6EC); // 1px crisp hairline border
  static const Color outlineVariantLight = Color(0xFFEAEFF5);

  // Serene Voyage Dark Palette - OLED & Night Slate
  static const Color primaryDark = Color(0xFFF3C644); // Radiant Warm Gold
  static const Color onPrimaryDark = Color(0xFF281C00);
  static const Color primaryContainerDark = Color(0xFF3E2D00);
  static const Color onPrimaryContainerDark = Color(0xFFFDE8A0);

  static const Color secondaryDark = Color(0xFF2DD4BF); // Radiant Soft Teal / Mint
  static const Color onSecondaryDark = Color(0xFF042F2E);
  static const Color secondaryContainerDark = Color(0xFF0D4B46);
  static const Color onSecondaryContainerDark = Color(0xFFCCFBF1);

  static const Color tertiaryDark = Color(0xFF94A3B8); // Soft Slate Blue
  static const Color onTertiaryDark = Color(0xFF0B0F17);
  static const Color tertiaryContainerDark = Color(0xFF1E293B);
  static const Color onTertiaryContainerDark = Color(0xFFE2E8F0);

  static const Color backgroundDark = Color(0xFF0F1318); // Serene Dark Night Scaffold
  static const Color surfaceDark = Color(0xFF161C24); // Serene Dark Card Surface
  static const Color surfaceVariantDark = Color(0xFF1E2632); // Inputs, borders, nested containers
  static const Color onSurfaceDark = Color(0xFFF8FAFC); // Crisp Light for titles
  static const Color onSurfaceVariantDark = Color(0xFFCBD5E1); // Balanced Slate for body
  static const Color textMutedDark = Color(0xFF8B9BB0); // Muted Slate for captions

  static const Color outlineDark = Color(0xFF263242); // Crisp dark hairline border
  static const Color outlineVariantDark = Color(0xFF334155);

  // Circular Action Button Palette (Serene Voyage)
  static const Color actionGold = Color(0xFF856404);
  static const Color actionTeal = Color(0xFF0F766E);
  static const Color actionSlate = Color(0xFF50607A);
  static const Color actionRed = Color(0xFFB91C1C);
  static const Color actionPeriwinkle = Color(0xFFA4B8D1);

  // Semantic & Travel Status Colors
  static const Color successPastel = Color(0xFF0F766E); // Serene Teal / Emerald
  static const Color successContainerLight = Color(0xFFE0F2F1);
  static const Color successContainerDark = Color(0xFF042F2E);
  static const Color warningPastel = Color(0xFFE7B623); // Serene Amber Gold
  static const Color warningContainerLight = Color(0xFFF2DC9D);
  static const Color warningContainerDark = Color(0xFF422E00);
  static const Color errorPastel = Color(0xFFB91C1C); // Serene Crimson Red
  static const Color errorContainerLight = Color(0xFFFEE2E2);
  static const Color errorContainerDark = Color(0xFF450A0A);
  static const Color infoPastel = Color(0xFF64748B); // Serene Slate
  static const Color infoContainerLight = Color(0xFFF1F5F9);
  static const Color infoContainerDark = Color(0xFF1E293B);

  // Special Accents & backwards compatibility
  static const Color goldAccent = Color(0xFFE7B623); // Serene Gold Foil
  static const Color tealAccent = Color(0xFF0F766E); // Serene Teal
  static const Color slateAccent = Color(0xFF64748B); // Serene Slate
  static const Color passportNavy = Color(0xFF0F172A); // Deep Night Slate
  static const Color terracotta = Color(0xFFE7B623); // Amber-Gold accent
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
