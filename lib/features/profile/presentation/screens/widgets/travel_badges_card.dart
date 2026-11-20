import 'package:flutter/material.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/travel_badge.dart';
import 'package:packbuddy/features/profile/domain/travel_style.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Bento card showcasing the user's chosen travel personality styles
/// and automatically computed gamified travel achievement badges.
class TravelBadgesCard extends StatelessWidget {
  final UserProfile profile;
  final int totalTrips;
  final int totalCountries;
  final int totalItems;
  final int totalDocuments;
  final String languageCode;
  final VoidCallback? onPickStylesTap;

  const TravelBadgesCard({
    super.key,
    required this.profile,
    required this.totalTrips,
    required this.totalCountries,
    required this.totalItems,
    required this.totalDocuments,
    required this.languageCode,
    this.onPickStylesTap,
  });

  void _showBadgeDetails(BuildContext context, TravelBadge badge) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [badge.tier.primaryColor, badge.tier.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badge.tier.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  badge.iconData,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge.getLocalizedTitle(languageCode),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badge.tier.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge.tier.getLocalizedLabel(languageCode).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badge.tier.primaryColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ProfileLocalization.getRequirement(languageCode),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        badge.getLocalizedDescription(languageCode),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: badge.progressRatio,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(badge.tier.primaryColor),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badge.isUnlocked
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge.isUnlocked
                          ? ProfileLocalization.getUnlocked(languageCode)
                          : ProfileLocalization.getLocked(languageCode),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: badge.isUnlocked ? const Color(0xFF10B981) : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    '${badge.currentProgress} / ${badge.targetProgress}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllBadgesModal(BuildContext context, List<TravelBadge> badges, int unlockedCount) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String filter = 'all'; // 'all', 'unlocked', 'locked'

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredBadges = badges.where((b) {
              if (filter == 'unlocked') return b.isUnlocked;
              if (filter == 'locked') return !b.isUnlocked;
              return true;
            }).toList();

            final progressPercentage = badges.isNotEmpty
                ? ((unlockedCount / badges.length) * 100).toInt()
                : 0;

            final screenWidth = mediaQuery.size.width;
            final crossAxisCount = screenWidth > 600
                ? 4
                : (screenWidth < 360 ? 2 : 3);

            return Container(
              height: mediaQuery.size.height * 0.88,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Handle Bar
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Header Row: Title & Close Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.military_tech_rounded,
                              size: 20,
                              color: Color(0xFFFFB300),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ProfileLocalization.getAllBadges(languageCode),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ProfileLocalization.getBadgesUnlockedSummary(
                                    languageCode,
                                    unlockedCount,
                                    badges.length,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Overall Progress Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ProfileLocalization.getProgress(languageCode),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '%$progressPercentage',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: badges.isNotEmpty ? unlockedCount / badges.length : 0,
                                minHeight: 6,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips: All, Unlocked, Locked
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: '${ProfileLocalization.getAllTab(languageCode)} (${badges.length})',
                            isSelected: filter == 'all',
                            onTap: () => setModalState(() => filter = 'all'),
                            theme: theme,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: '${ProfileLocalization.getEarnedTab(languageCode)} ($unlockedCount)',
                            isSelected: filter == 'unlocked',
                            onTap: () => setModalState(() => filter = 'unlocked'),
                            theme: theme,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: '${ProfileLocalization.getLockedTab(languageCode)} (${badges.length - unlockedCount})',
                            isSelected: filter == 'locked',
                            onTap: () => setModalState(() => filter = 'locked'),
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Hint line
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 2),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          ProfileLocalization.getTapBadgeHint(languageCode),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Badges Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.84,
                        ),
                        itemCount: filteredBadges.length,
                        itemBuilder: (context, index) {
                          final badge = filteredBadges[index];
                          return _buildModalBadgeCard(context, badge, theme);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildModalBadgeCard(BuildContext context, TravelBadge badge, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isUnlocked = badge.isUnlocked;

    return InkWell(
      onTap: () => _showBadgeDetails(context, badge),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isUnlocked ? 1.0 : 0.65,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnlocked
                ? badge.tier.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked
                  ? badge.tier.primaryColor.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.18),
              width: isUnlocked ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isUnlocked
                          ? LinearGradient(
                              colors: [badge.tier.primaryColor, badge.tier.secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isUnlocked ? null : theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(
                      badge.iconData,
                      size: 22,
                      color: isUnlocked ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xFF10B981) : theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isUnlocked ? Icons.check_rounded : Icons.lock_rounded,
                        size: 9,
                        color: isUnlocked ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                badge.getLocalizedTitle(languageCode),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? badge.tier.primaryColor.withValues(alpha: 0.15)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge.tier.getLocalizedLabel(languageCode).toUpperCase(),
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: isUnlocked ? badge.tier.primaryColor : theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${badge.currentProgress}/${badge.targetProgress}',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? badge.tier.primaryColor : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badges = TravelBadge.calculateBadges(
      totalTrips: totalTrips,
      totalCountries: totalCountries,
      totalItems: totalItems,
      totalDocuments: totalDocuments,
    );

    final unlockedCount = badges.where((b) => b.isUnlocked).length;
    final styles = profile.travelStyles
        .map((id) => TravelStyle.findById(id))
        .whereType<TravelStyle>()
        .toList();

    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Travel Personality Styles
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.style_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ProfileLocalization.getTravelStyles(languageCode),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onPickStylesTap != null)
                TextButton(
                  onPressed: onPickStylesTap,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    ProfileLocalization.getEditProfile(languageCode),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Chips display
          if (styles.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: styles.map((style) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(style.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        style.getLocalizedName(languageCode),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            InkWell(
              onTap: onPickStylesTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.25),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        ProfileLocalization.getTravelStylesSubtitle(languageCode),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          // 2. Achievements & Badges Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 16,
                  color: Color(0xFFFFB300),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ProfileLocalization.getBadgesAndAchievements(languageCode),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _showAllBadgesModal(context, badges, unlockedCount),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: unlockedCount > 0
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$unlockedCount/${badges.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: unlockedCount > 0 ? const Color(0xFF10B981) : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              InkWell(
                onTap: () => _showAllBadgesModal(context, badges, unlockedCount),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ProfileLocalization.getViewAll(languageCode),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Badges Showcase (Cleanly clipped inside card, never overflowing)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 106,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.antiAlias,
                itemCount: badges.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  return _buildBadgeItem(context, badge, theme);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, TravelBadge badge, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isUnlocked = badge.isUnlocked;

    return InkWell(
      onTap: () => _showBadgeDetails(context, badge),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isUnlocked ? 1.0 : 0.55,
        child: Container(
          width: 86,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnlocked
                ? badge.tier.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isUnlocked
                  ? badge.tier.primaryColor.withValues(alpha: 0.5)
                  : theme.colorScheme.outline.withValues(alpha: 0.15),
              width: isUnlocked ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isUnlocked
                          ? LinearGradient(
                              colors: [badge.tier.primaryColor, badge.tier.secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isUnlocked ? null : theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(
                      badge.iconData,
                      size: 20,
                      color: isUnlocked ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xFF10B981) : theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isUnlocked ? Icons.check_rounded : Icons.lock_rounded,
                        size: 9,
                        color: isUnlocked ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                badge.getLocalizedTitle(languageCode),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                '${badge.currentProgress}/${badge.targetProgress}',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? badge.tier.primaryColor : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
