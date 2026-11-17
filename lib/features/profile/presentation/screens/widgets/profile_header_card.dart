import 'package:flutter/material.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
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

  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.languageCode,
    required this.onEditTap,
    this.onAvatarTap,
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
      borderRadius: 24,
      child: Column(
        children: [
          // Avatar + Pro Badge + Camera Badge
          Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              UserAvatar(
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

          // Bio
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
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Edit Profile Action
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEditTap,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text(
                ProfileLocalization.getEditProfile(languageCode),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
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
    );
  }
}
