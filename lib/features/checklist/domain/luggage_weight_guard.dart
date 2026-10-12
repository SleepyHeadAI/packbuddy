import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Weight threshold states for luggage guard
enum LuggageWeightStatus {
  normal, // Safe weight (< 90% of limit)
  warning, // Warning: within 10% of limit (>= 90% and <= 100%)
  exceeded, // Over limit (> 100%)
}

/// Luggage Weight Guard computation and dynamic threshold engine
class LuggageWeightGuard {
  /// Computes status based on current weight and baggage limit
  static LuggageWeightStatus computeStatus({
    required double currentWeightKg,
    required double limitWeightKg,
  }) {
    if (limitWeightKg <= 0) return LuggageWeightStatus.normal;
    final ratio = currentWeightKg / limitWeightKg;

    if (ratio > 1.0) {
      return LuggageWeightStatus.exceeded;
    } else if (ratio >= 0.90) {
      return LuggageWeightStatus.warning;
    } else {
      return LuggageWeightStatus.normal;
    }
  }

  /// Resolves the semantic color based on status
  static Color getStatusColor(LuggageWeightStatus status) {
    switch (status) {
      case LuggageWeightStatus.normal:
        return AppColors.successPastel; // Emerald Green (Safe)
      case LuggageWeightStatus.warning:
        return AppColors.warningPastel; // Amber Sunset (Within 10%)
      case LuggageWeightStatus.exceeded:
        return AppColors.errorPastel; // Crimson Red (Over Limit)
    }
  }

  /// Resolves soft container background color
  static Color getStatusContainerColor(LuggageWeightStatus status, {bool isDark = false}) {
    switch (status) {
      case LuggageWeightStatus.normal:
        return isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.35)
            : const Color(0xFFECFDF5);
      case LuggageWeightStatus.warning:
        return isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.35)
            : const Color(0xFFFFFBEB);
      case LuggageWeightStatus.exceeded:
        return isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
            : const Color(0xFFFEF2F2);
    }
  }

  /// Resolves user-friendly status badge text
  static String getStatusBadgeText(LuggageWeightStatus status) {
    switch (status) {
      case LuggageWeightStatus.normal:
        return 'GÜVENLİ LİMİT';
      case LuggageWeightStatus.warning:
        return 'DİKKAT: %90+ DOLU';
      case LuggageWeightStatus.exceeded:
        return 'LİMİT AŞILDI!';
    }
  }

  /// Resolves human-readable weight status details
  static String getStatusDetailText({
    required double currentWeightKg,
    required double limitWeightKg,
  }) {
    final status = computeStatus(
      currentWeightKg: currentWeightKg,
      limitWeightKg: limitWeightKg,
    );
    final ratio = limitWeightKg > 0 ? (currentWeightKg / limitWeightKg) * 100 : 0.0;

    switch (status) {
      case LuggageWeightStatus.normal:
        final remaining = (limitWeightKg - currentWeightKg).clamp(0.0, limitWeightKg);
        return 'Kalan Güvenli Kapasite: ${remaining.toStringAsFixed(1)} kg (${ratio.toStringAsFixed(0)}%)';
      case LuggageWeightStatus.warning:
        final remaining = (limitWeightKg - currentWeightKg).clamp(0.0, limitWeightKg);
        return 'Bavul limitine yaklaşıldı! Kalan: ${remaining.toStringAsFixed(1)} kg (${ratio.toStringAsFixed(0)}%)';
      case LuggageWeightStatus.exceeded:
        final over = (currentWeightKg - limitWeightKg).abs();
        return 'Ağırlık sınırı ${over.toStringAsFixed(1)} kg aşıldı! Bagaj ücreti doğabilir.';
    }
  }

  /// Ratio clamped between 0.0 and 1.0 for standard linear progress bars
  static double getProgressRatio({
    required double currentWeightKg,
    required double limitWeightKg,
  }) {
    if (limitWeightKg <= 0) return 0.0;
    return (currentWeightKg / limitWeightKg).clamp(0.0, 1.0);
  }
}
