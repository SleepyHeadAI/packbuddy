import 'package:flutter/material.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/bouncy_pressable.dart';
import '../dashboard_localization.dart';

/// Mini Companion Card for World Travel Map with Hero animations
class DashboardMiniTravelMap extends StatelessWidget {
  final int visitedCountriesCount;
  final int wishlistCount;
  final double worldPercentage;
  final bool isFullWidth;
  final VoidCallback onTap;

  const DashboardMiniTravelMap({
    super.key,
    required this.visitedCountriesCount,
    required this.wishlistCount,
    required this.worldPercentage,
    this.isFullWidth = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BouncyPressable(
      scaleFactor: 0.96,
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'travel-map-hero-badge',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF0D9488), const Color(0xFF065F46)]
                            : [const Color(0xFF10B981), const Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${worldPercentage.toStringAsFixed(1)}%',
                    style: AppTypography.mono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981),
                      tabularFigures: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'travel-map-hero-title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      l10n.worldTravelMapTitle,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$visitedCountriesCount ${DashboardLocalization.countriesVisited(Localizations.localeOf(context).languageCode)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (worldPercentage / 100.0).clamp(0.0, 1.0),
                    minHeight: 3.5,
                    backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini Companion Card for Document Vault with Hero animations
class DashboardMiniVault extends StatelessWidget {
  final int docCount;
  final bool isFullWidth;
  final VoidCallback onTap;

  const DashboardMiniVault({
    super.key,
    required this.docCount,
    this.isFullWidth = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    return BouncyPressable(
      scaleFactor: 0.96,
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'vault-hero-badge',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 19,
                    ),
                  ),
                ),
                if (docCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$docCount',
                      style: AppTypography.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B5CF6),
                        tabularFigures: true,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'vault-hero-title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      DashboardLocalization.sectionVault(lang),
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  docCount == 0
                      ? DashboardLocalization.offlineAndEncrypted(lang)
                      : '$docCount ${l10n.documentsSaved}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini Companion Card for All Trips & Budget
class DashboardMiniAllTrips extends StatelessWidget {
  final int tripCount;
  final bool isFullWidth;
  final VoidCallback onTap;

  const DashboardMiniAllTrips({
    super.key,
    required this.tripCount,
    this.isFullWidth = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BouncyPressable(
      scaleFactor: 0.96,
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'trips-hero-badge',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: theme.colorScheme.primary,
                      size: 19,
                    ),
                  ),
                ),
                if (tripCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$tripCount',
                      style: AppTypography.mono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                        tabularFigures: true,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'trips-hero-title',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            l10n.trips,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10n.viewAll,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  tripCount == 0
                      ? l10n.noTripsYet
                      : '$tripCount ${l10n.tripsPlanned}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini Companion Card for Trip Comparison with Hero animations
class DashboardMiniTripComparison extends StatelessWidget {
  final bool isFullWidth;
  final VoidCallback onTap;

  const DashboardMiniTripComparison({
    super.key,
    this.isFullWidth = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    return BouncyPressable(
      scaleFactor: 0.96,
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'compare-trips-hero-badge',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.compare_arrows_rounded,
                      color: Color(0xFF6366F1),
                      size: 19,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: Color(0xFF6366F1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'compare-trips-hero-title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      l10n.compareTrips,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DashboardLocalization.compareRoutesAndBudget(lang),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini Companion Card for Travel Buddies on Dashboard
class DashboardMiniBuddies extends StatelessWidget {
  final int friendsCount;
  final int pendingRequestsCount;
  final bool isFullWidth;
  final VoidCallback onTap;

  const DashboardMiniBuddies({
    super.key,
    required this.friendsCount,
    required this.pendingRequestsCount,
    this.isFullWidth = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    return BouncyPressable(
      scaleFactor: 0.96,
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF6366F1), const Color(0xFF4338CA)]
                          : [const Color(0xFF818CF8), const Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                if (pendingRequestsCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+$pendingRequestsCount',
                      style: AppTypography.mono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        tabularFigures: true,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              FriendLocalization.getDashboardBuddiesCardTitle(lang),
              style: AppTypography.titleSmall.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              friendsCount > 0
                  ? '$friendsCount ${FriendLocalization.getFriends(lang).toLowerCase()}'
                  : FriendLocalization.getAddFriend(lang),
              style: TextStyle(
                fontSize: 11.5,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
