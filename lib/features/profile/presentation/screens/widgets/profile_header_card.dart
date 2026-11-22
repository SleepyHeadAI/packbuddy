import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/widgets/avatar_picker_sheet.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';

/// Serene Voyage header card displaying user avatar, name, bio, and country
class ProfileHeaderCard extends StatelessWidget {
  final UserProfile profile;
  final String languageCode;
  final VoidCallback onEditTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onFriendsTap;
  final String? avatarHeroTag;

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.languageCode,
    required this.onEditTap,
    this.onAvatarTap,
    this.onFriendsTap,
    this.avatarHeroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String? countryDisplay;
    if (profile.homeCountryCode != null && profile.homeCountryCode!.isNotEmpty) {
      final c = Country.findByCode(profile.homeCountryCode!);
      if (c != null) {
        countryDisplay = '${c.flag} ${c.getLocalizedName(languageCode)}';
        if (profile.homeCity != null && profile.homeCity!.isNotEmpty) {
          countryDisplay = '$countryDisplay, ${profile.homeCity}';
        }
      }
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: AppRadius.card,
      child: Column(
        children: [
          // Avatar + Pro Badge + Camera Badge
          Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              avatarHeroTag != null
                  ? Hero(
                      tag: avatarHeroTag!,
                      child: UserAvatar(
                        photoUrl: profile.photoUrl,
                        displayName: profile.displayName,
                        email: profile.email,
                        size: 84,
                        isAnimated: true,
                        showEditBadge: true,
                        onTap: () {
                          if (onAvatarTap != null) {
                            onAvatarTap!();
                          } else {
                            AvatarPickerSheet.show(
                              context,
                              profile: profile,
                              languageCode: languageCode,
                            );
                          }
                        },
                      ),
                    )
                  : UserAvatar(
                      photoUrl: profile.photoUrl,
                      displayName: profile.displayName,
                      email: profile.email,
                      size: 84,
                      isAnimated: true,
                      showEditBadge: true,
                      onTap: () {
                        if (onAvatarTap != null) {
                          onAvatarTap!();
                        } else {
                          AvatarPickerSheet.show(
                            context,
                            profile: profile,
                            languageCode: languageCode,
                          );
                        }
                      },
                    ),
              if (profile.isPro)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? theme.colorScheme.surface : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // User Display Name
          Text(
            profile.displayName?.isNotEmpty == true
                ? profile.displayName!
                : ProfileLocalization.getDefaultTravelerName(languageCode),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Username Handle (@buddy_id)
          if (profile.username != null && profile.username!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '@${profile.username!}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),

          // Email
          if (profile.email != null && profile.email!.isNotEmpty)
            Text(
              profile.email!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12.5,
              ),
            ),

          // Travel Status Badge
          if (profile.travelStatus != null && profile.travelStatus!.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: onEditTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        profile.travelStatus!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_outlined,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Home Country Pill
          if (countryDisplay != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      countryDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Bio / Hakkımda
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '"${profile.bio!}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  height: 1.4,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Action Buttons: Travel Buddies & Edit Profile
          Row(
            children: [
              if (onFriendsTap != null) ...[
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onFriendsTap,
                    icon: const Icon(Icons.people_alt_rounded, size: 16),
                    label: Text(
                      FriendLocalization.getFriends(languageCode),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEditTap,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text(
                    ProfileLocalization.getEditProfile(languageCode),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
