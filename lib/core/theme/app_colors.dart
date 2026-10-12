import 'package:flutter/material.dart';

/// Sophisticated, cinematic color palette for PackBuddy
/// Featuring deep obsidian slate, rich electric indigo, warm sunset terracotta, and crisp silk backgrounds.
class AppColors {
  // Light Palette - Modern Cinematic Travel (Indigo & Warm Terracotta)
  static const Color primaryLight = Color(0xFF2563EB); // Vibrant Travel Cobalt / Indigo
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFEFF6FF); // Soft Ice Azure
  static const Color onPrimaryContainerLight = Color(0xFF1E3A8A); // Deep Royal Navy

  static const Color secondaryLight = Color(0xFF475569); // Modern Slate
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFF1F5F9); // Light Slate
  static const Color onSecondaryContainerLight = Color(0xFF0F172A);

  static const Color tertiaryLight = Color(0xFFEA580C); // Warm Sunset Terracotta
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFFFF7ED); // Warm Amber Silk
  static const Color onTertiaryContainerLight = Color(0xFF7C2D12);

  static const Color backgroundLight = Color(0xFFF8FAFC); // Silk Alabaster
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color onSurfaceLight = Color(0xFF0F172A); // Deep Obsidian
  static const Color onSurfaceVariantLight = Color(0xFF64748B); // Refined Slate

  static const Color outlineLight = Color(0xFFE2E8F0); // Subtle Border
  static const Color outlineVariantLight = Color(0xFFEDF2F7);

  // Dark Palette - Obsidian Midnight with Radiant Accents
  static const Color primaryDark = Color(0xFF60A5FA); // Radiant Indigo
  static const Color onPrimaryDark = Color(0xFF0B1220);
  static const Color primaryContainerDark = Color(0xFF1E3A8A);
  static const Color onPrimaryContainerDark = Color(0xFFDBEAFE);

  static const Color secondaryDark = Color(0xFF94A3B8); // Cool Slate
  static const Color onSecondaryDark = Color(0xFF0B1220);
  static const Color secondaryContainerDark = Color(0xFF1E293B);
  static const Color onSecondaryContainerDark = Color(0xFFE2E8F0);

  static const Color tertiaryDark = Color(0xFFFB923C); // Warm Terracotta Glow
  static const Color onTertiaryDark = Color(0xFF431407);
  static const Color tertiaryContainerDark = Color(0xFF7C2D12);
  static const Color onTertiaryContainerDark = Color(0xFFFFEDD5);

  static const Color backgroundDark = Color(0xFF090D16); // Midnight Obsidian
  static const Color surfaceDark = Color(0xFF111827); // Dark Slate Card
  static const Color surfaceVariantDark = Color(0xFF1F2937); // Elevated Card Surface
  static const Color onSurfaceDark = Color(0xFFF8FAFC); // Crisp Light
  static const Color onSurfaceVariantDark = Color(0xFF94A3B8);

  static const Color outlineDark = Color(0xFF374151);
  static const Color outlineVariantDark = Color(0xFF1F2937);

  // Rich Semantic & Travel Status Colors
  static const Color successPastel = Color(0xFF10B981); // Emerald Green
  static const Color warningPastel = Color(0xFFF59E0B); // Amber Sunset
  static const Color errorPastel = Color(0xFFEF4444); // Vivid Coral
  static const Color infoPastel = Color(0xFF0EA5E9); // Sky Cyan

  // Special Luxury Travel Accents
  static const Color passportNavy = Color(0xFF1E3A8A); // Royal Navy
  static const Color goldAccent = Color(0xFFF59E0B); // Gold Foil
  static const Color terracotta = Color(0xFFEA580C);
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
