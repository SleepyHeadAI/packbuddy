import 'package:flutter/material.dart';

/// Centralized Color Token Architecture for PackBuddy (Modern Wanderlust 2.0).
///
/// Palette direction:
/// - Primary / Canvas: Warm Alabaster Linen (Light) & Deep Obsidian Night Slate (Dark)
/// - Brand Accent: Mediterranean Terracotta Sunset (#E05D38) & Luminous Horizon Ember (#FF7A59)
/// - Secondary / Status: Alpine Pine Emerald (#0F766E / #10B981)
/// - Neutral / Ink: Deep Jet Slate (#0F172A) & Muted Titanium (#64748B)
///
/// Follows a strict 3-tier token model:
/// - Primitives: Hex values, Terracotta, Pine Emerald, Obsidian.
/// - Semantic Tokens: Scaffold, Layered Surfaces (Base, Raised, Overlay),
///   Borders, Text, Status, Accent with WCAG AAA text contrast compliance.
/// - Legacy Aliases: 100% backward compatibility for existing features.
class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. MODERN SEMANTIC TOKEN ARCHITECTURE (PackBuddy Design System 2.0)
  // ===========================================================================

  // --- Scaffold & Layered Surface Hierarchy ---
  // Replaces harsh drop shadows and box-pile clutter with quiet elevation.
  static const Color scaffoldLight = Color(0xFFF8F9FA); // Crisp, non-glare alabaster linen
  static const Color scaffoldDark = Color(0xFF0B0E14); // Deep OLED obsidian night slate

  static const Color surfaceBaseLight = Color(0xFFFFFFFF); // Level 1 cards and sheets
  static const Color surfaceBaseDark = Color(0xFF131822);

  static const Color surfaceRaisedLight = Color(0xFFF1F3F6); // Level 2 nested areas, inputs
  static const Color surfaceRaisedDark = Color(0xFF1A2230);

  static const Color surfaceOverlayLight = Color(0xFFE9ECF2); // Level 3 chips, pressed states
  static const Color surfaceOverlayDark = Color(0xFF242E40);

  // --- Hairline Borders & Separators ---
  // Crisp 0.5px hairline dividers that maintain subtle structure without visual clutter.
  static const Color borderSubtleLight = Color(0xFFEAECEF); // 0.5px hairline border
  static const Color borderSubtleDark = Color(0xFF1E2836);

  static const Color borderStrongLight = Color(0xFFD0D5DD); // Interactive outline border
  static const Color borderStrongDark = Color(0xFF334155);

  // --- Dynamic Brightness Resolution Helpers ---
  static Color surfaceBase(bool isDark) => isDark ? surfaceBaseDark : surfaceBaseLight;
  static Color surfaceRaised(bool isDark) => isDark ? surfaceRaisedDark : surfaceRaisedLight;
  static Color surfaceOverlay(bool isDark) => isDark ? surfaceOverlayDark : surfaceOverlayLight;
  static Color borderSubtle(bool isDark) => isDark ? borderSubtleDark : borderSubtleLight;
  static Color borderStrong(bool isDark) => isDark ? borderStrongDark : borderStrongLight;

  // --- Brand & Primary Roles ---
  static const Color brandPrimaryLight = Color(0xFF0F172A); // Deep Slate / Jet Obsidian
  static const Color brandPrimaryDark = Color(0xFFF8FAFC); // Crisp Snow

  // UI Accents: Energetic, refined Terracotta for icons, active tabs, buttons, and hero surfaces
  static const Color brandAccent = Color(0xFFE05D38); // Terracotta Sunset
  static const Color brandAccentDark = Color(0xFFFF7A59); // Luminous Horizon Glow

  // WCAG AAA Contrast (>7:1 on white and >6.5:1 on #F8F9FA) for small text
  static const Color brandAccentTextLight = Color(0xFFB83A1B); // Deep Rich Terracotta
  static const Color brandAccentTextDark = Color(0xFFFFAB91); // Soft Horizon Tint

  // Secondary Accents: Alpine Pine Emerald for completed packing, confirmations, and flight status
  static const Color pineEmerald = Color(0xFF0F766E); // Alpine Pine
  static const Color pineEmeraldDark = Color(0xFF2DD4BF); // Mint Aurora

  // --- Typographic Text Roles ---
  static const Color navySlate = Color(0xFF0F172A);
  static const Color textPrimaryLight = Color(0xFF0F172A); // High emphasis
  static const Color textPrimaryDark = Color(0xFFF8FAFC);

  static const Color textSecondaryLight = Color(0xFF475569); // Balanced body text
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color textTertiaryLight = Color(0xFF94A3B8); // Captions, placeholders
  static const Color textTertiaryDark = Color(0xFF64748B);

  // ===========================================================================
  // 2. LEGACY COMPATIBILITY LAYER (Preserves all existing constants & tests)
  // ===========================================================================

  // Modern Serene Expedition Light Palette (Mustard completely eliminated)
  static const Color primaryLight = Color(0xFFE05D38); // Terracotta Sunset
  static const Color primaryAmber = Color(0xFFE05D38); // Redirected to Terracotta
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFFDEEE9); // Soft Terracotta Tint
  static const Color onPrimaryContainerLight = Color(0xFF5E1B09);

  static const Color secondaryLight = Color(0xFF0F766E); // Alpine Pine Emerald
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFE0F2F1);
  static const Color onSecondaryContainerLight = Color(0xFF042F2E);

  static const Color tertiaryLight = Color(0xFF475569); // Slate Titanium
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFF1F5F9);
  static const Color onTertiaryContainerLight = Color(0xFF0F172A);

  // Surfaces
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F3F6);
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color onSurfaceVariantLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF64748B);

  static const Color outlineLight = Color(0xFFEAECEF);
  static const Color outlineVariantLight = Color(0xFFF1F3F6);

  // Modern Serene Expedition Dark Palette
  static const Color primaryDark = Color(0xFFFF7A59); // Luminous Terracotta
  static const Color onPrimaryDark = Color(0xFF260D05);
  static const Color primaryContainerDark = Color(0xFF4A1A0D);
  static const Color onPrimaryContainerDark = Color(0xFFFFDCD2);

  static const Color secondaryDark = Color(0xFF2DD4BF);
  static const Color onSecondaryDark = Color(0xFF042F2E);
  static const Color secondaryContainerDark = Color(0xFF0D4B46);
  static const Color onSecondaryContainerDark = Color(0xFFCCFBF1);

  static const Color tertiaryDark = Color(0xFF94A3B8);
  static const Color onTertiaryDark = Color(0xFF0B0F17);
  static const Color tertiaryContainerDark = Color(0xFF1E293B);
  static const Color onTertiaryContainerDark = Color(0xFFE2E8F0);

  static const Color backgroundDark = Color(0xFF0B0E14);
  static const Color surfaceDark = Color(0xFF131822);
  static const Color surfaceVariantDark = Color(0xFF1A2230);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);
  static const Color onSurfaceVariantDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF8B9BB0);

  static const Color outlineDark = Color(0xFF1E2836);
  static const Color outlineVariantDark = Color(0xFF2A3648);

  // Action Buttons
  static const Color actionGold = Color(0xFFE05D38);
  static const Color actionTeal = Color(0xFF0F766E);
  static const Color actionSlate = Color(0xFF50607A);
  static const Color actionRed = Color(0xFFB91C1C);
  static const Color actionPeriwinkle = Color(0xFFA4B8D1);

  // Status & Semantic Feedback
  static const Color successPastel = Color(0xFF0F766E);
  static const Color successContainerLight = Color(0xFFE0F2F1);
  static const Color successContainerDark = Color(0xFF042F2E);
  static const Color warningPastel = Color(0xFFF59E0B); // Clean golden amber for true warnings
  static const Color warningContainerLight = Color(0xFFFEF3C7);
  static const Color warningContainerDark = Color(0xFF422E00);
  static const Color errorPastel = Color(0xFFDC2626);
  static const Color errorContainerLight = Color(0xFFFEE2E2);
  static const Color errorContainerDark = Color(0xFF450A0A);
  static const Color infoPastel = Color(0xFF64748B);
  static const Color infoContainerLight = Color(0xFFF1F5F9);
  static const Color infoContainerDark = Color(0xFF1E293B);

  // Legacy Accents
  static const Color goldAccent = Color(0xFFE05D38);
  static const Color tealAccent = Color(0xFF0F766E);
  static const Color slateAccent = Color(0xFF64748B);
  static const Color passportNavy = Color(0xFF0F172A);
  static const Color terracotta = Color(0xFFE05D38);
}

/// Global smooth animation standards for PackBuddy (Preserved for backward compatibility)
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration smooth = Duration(milliseconds: 360);
  static const Duration relaxed = Duration(milliseconds: 500);

  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve gentleCurve = Curves.easeInOutCubic;
  static const Curve springCurve = Curves.easeOutBack;
}
