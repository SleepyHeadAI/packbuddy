import 'package:flutter/material.dart';

/// Sophisticated, executive color palette for PackBuddy
/// Featuring deep Slate Navy / Midnight Blue, soft pearl off-white, OLED-friendly dark slate,
/// calming muted sage green for success, and warm terracotta/coral accents.
class AppColors {
  // Light Palette - Modern Executive Travel (Slate Navy, Soft Pearl & Warm Terracotta)
  static const Color primaryLight = Color(0xFF16263D); // Deep, sophisticated Slate Navy
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFE8EEF5); // Soft Porcelain Slate
  static const Color onPrimaryContainerLight = Color(0xFF0F1A2A); // Deepest Midnight Navy

  static const Color secondaryLight = Color(0xFF475569); // Refined Slate
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFF1F5F9); // Crisp Slate Silk
  static const Color onSecondaryContainerLight = Color(0xFF0F172A);

  static const Color tertiaryLight = Color(0xFFD96B43); // Soft Sunset Terracotta
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFFDF0EC); // Warm Silk Terracotta
  static const Color onTertiaryContainerLight = Color(0xFF7A2B14);

  static const Color backgroundLight = Color(0xFFF8F9FA); // Clean Off-White / Soft Pearl
  static const Color surfaceLight = Color(0xFFFFFFFF); // Crisp Pure White
  static const Color surfaceVariantLight = Color(0xFFF1F3F5); // Soft Neutral Container
  static const Color onSurfaceLight = Color(0xFF0F172A); // Deep Obsidian
  static const Color onSurfaceVariantLight = Color(0xFF64748B); // Slightly Muted Readable Slate

  static const Color outlineLight = Color(0xFFE2E8F0); // Subtle 1px Border
  static const Color outlineVariantLight = Color(0xFFEDF2F7);

  // Dark Palette - Deep OLED-friendly Dark Slate with Radiant Soft Slate Accents
  static const Color primaryDark = Color(0xFF8BAECF); // Radiant Soft Slate Blue
  static const Color onPrimaryDark = Color(0xFF09121E);
  static const Color primaryContainerDark = Color(0xFF1B2E47);
  static const Color onPrimaryContainerDark = Color(0xFFD6E4F0);

  static const Color secondaryDark = Color(0xFF94A3B8); // Cool Slate
  static const Color onSecondaryDark = Color(0xFF090D16);
  static const Color secondaryContainerDark = Color(0xFF1E293B);
  static const Color onSecondaryContainerDark = Color(0xFFE2E8F0);

  static const Color tertiaryDark = Color(0xFFF28F6C); // Soft Terracotta Glow
  static const Color onTertiaryDark = Color(0xFF3E1205);
  static const Color tertiaryContainerDark = Color(0xFF6E2612);
  static const Color onTertiaryContainerDark = Color(0xFFFFDFD6);

  static const Color backgroundDark = Color(0xFF090D14); // Deep OLED-friendly Black / Dark Slate
  static const Color surfaceDark = Color(0xFF111722); // Dark Slate Card
  static const Color surfaceVariantDark = Color(0xFF182030); // Elevated Card Surface
  static const Color onSurfaceDark = Color(0xFFF8FAFC); // Crisp Light
  static const Color onSurfaceVariantDark = Color(0xFF8E9BAE); // Muted Secondary Text

  static const Color outlineDark = Color(0xFF263244);
  static const Color outlineVariantDark = Color(0xFF1B2433);

  // Rich Semantic & Travel Status Colors
  static const Color successPastel = Color(0xFF387E69); // Muted Sage Green for completion
  static const Color warningPastel = Color(0xFFDE7357); // Soft Terracotta / Coral for warnings
  static const Color errorPastel = Color(0xFFE05252); // Refined Soft Coral Red
  static const Color infoPastel = Color(0xFF3A7FA8); // Calm Slate Blue

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
