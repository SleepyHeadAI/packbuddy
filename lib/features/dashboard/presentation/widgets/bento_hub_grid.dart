import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_animations.dart';
import '../../../../shared/widgets/app_card.dart';

/// Modern asymmetrical Bento Grid showcasing the essential travel companion tools.
/// Replaces the legacy repetitive vertical feature list with a visually hierarchical,
/// responsive, and tactile grid layout.
class BentoHubGrid extends StatelessWidget {
  final int tripCount;
  final int docCount;
  final int visitedCountriesCount;
  final int wishlistCount;
  final double worldPercentage;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenTrips;
  final VoidCallback onOpenCurrency;
  final VoidCallback onOpenComparison;
  final VoidCallback onOpenVault;

  const BentoHubGrid({
    super.key,
    required this.tripCount,
    required this.docCount,
    required this.visitedCountriesCount,
    required this.wishlistCount,
    required this.worldPercentage,
    required this.onOpenMap,
    required this.onOpenTrips,
    required this.onOpenCurrency,
    required this.onOpenComparison,
    required this.onOpenVault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with subtle icon accent
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.travelAssistant.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 1. Hero Bento Card: World Travel Map (Full-width showcase)
        AppFadeSlide(
          delay: const Duration(milliseconds: 60),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            onTap: onOpenMap,
            child: Row(
              children: [
                // Glowing Globe Icon Badge
                Hero(
                  tag: 'travel-map-hero-badge',
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0D9488), const Color(0xFF065F46)]
                            : [const Color(0xFF10B981), const Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.public_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info & Live Exploration Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'travel-map-hero-title',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Text(
                                  l10n.worldTravelMapTitle,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '%${worldPercentage.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.worldTravelMapStats(
                          visitedCountriesCount,
                          wishlistCount,
                          worldPercentage.toStringAsFixed(1),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Exploration Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (worldPercentage / 100.0).clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Bento Pair: Budget & Currency Converter
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Budget / Trips Tile
              Expanded(
                child: AppFadeSlide(
                  delay: const Duration(milliseconds: 100),
                  child: _BentoCompanionTile(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: theme.colorScheme.primary,
                    iconBgColor: theme.colorScheme.primary.withValues(alpha: 0.14),
                    title: l10n.budget,
                    subtitle: tripCount == 0
                        ? l10n.budgetDescription
                        : '$tripCount ${l10n.tripsPlanned}',
                    badgeText: tripCount > 0 ? '$tripCount' : null,
                    onTap: onOpenTrips,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Currency Converter Tile
              Expanded(
                child: AppFadeSlide(
                  delay: const Duration(milliseconds: 140),
                  child: _BentoCompanionTile(
                    icon: Icons.currency_exchange_rounded,
                    iconColor: const Color(0xFFD97706),
                    iconBgColor: const Color(0xFFD97706).withValues(alpha: 0.14),
                    title: l10n.currencyConverter,
                    subtitle: l10n.quickConvert,
                    badgeText: 'LIVE',
                    badgeColor: const Color(0xFFD97706),
                    onTap: onOpenCurrency,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Bento Pair: Vault & Trip Comparison
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Document Vault Tile
              Expanded(
                child: AppFadeSlide(
                  delay: const Duration(milliseconds: 180),
                  child: _BentoCompanionTile(
                    icon: Icons.shield_rounded,
                    iconColor: AppColors.secondaryLight,
                    iconBgColor: AppColors.secondaryLight.withValues(alpha: 0.14),
                    title: l10n.vault,
                    subtitle: docCount == 0
                        ? l10n.offlineVault
                        : '$docCount ${l10n.documentsSaved}',
                    badgeText: docCount > 0 ? '$docCount' : null,
                    badgeColor: AppColors.secondaryLight,
                    heroTagBadge: 'vault-hero-badge',
                    heroTagTitle: 'vault-hero-title',
                    onTap: onOpenVault,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Trip Comparison Tile
              Expanded(
                child: AppFadeSlide(
                  delay: const Duration(milliseconds: 220),
                  child: _BentoCompanionTile(
                    icon: Icons.compare_arrows_rounded,
                    iconColor: const Color(0xFF6366F1),
                    iconBgColor: const Color(0xFF6366F1).withValues(alpha: 0.14),
                    title: l10n.compareTrips,
                    subtitle: l10n.comparisonSummary,
                    heroTagBadge: 'compare-trips-hero-badge',
                    heroTagTitle: 'compare-trips-hero-title',
                    onTap: onOpenComparison,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact companion tile inside the Bento Grid
class _BentoCompanionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final String? heroTagBadge;
  final String? heroTagTitle;
  final VoidCallback onTap;

  const _BentoCompanionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.heroTagBadge,
    this.heroTagTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget iconWidget = Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: iconBgColor,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );

    if (heroTagBadge != null) {
      iconWidget = Hero(tag: heroTagBadge!, child: iconWidget);
    }

    Widget titleWidget = Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        letterSpacing: -0.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (heroTagTitle != null) {
      titleWidget = Hero(
        tag: heroTagTitle!,
        child: Material(type: MaterialType.transparency, child: titleWidget),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconWidget,
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? iconColor).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: badgeColor ?? iconColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

