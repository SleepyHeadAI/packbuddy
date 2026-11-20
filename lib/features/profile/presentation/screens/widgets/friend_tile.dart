import 'package:flutter/material.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';

/// Serene Voyage friend list tile displaying user info, status chip, and management actions
class FriendTile extends StatelessWidget {
  final FriendUserSummary friend;
  final String languageCode;
  final VoidCallback? onTap;
  final VoidCallback? onRemoveTap;

  const FriendTile({
    super.key,
    required this.friend,
    required this.languageCode,
    this.onTap,
    this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String? countryFlag;
    if (friend.homeCountryCode != null && friend.homeCountryCode!.isNotEmpty) {
      final c = Country.findByCode(friend.homeCountryCode!);
      countryFlag = c?.flag;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            // Avatar
            UserAvatar(
              photoUrl: friend.photoUrl,
              displayName: friend.displayName,
              size: 48,
              fallbackToDeviceUserAvatar: false,
            ),
            const SizedBox(width: 12),

            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          friend.displayName?.isNotEmpty == true ? friend.displayName! : 'Traveler',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (countryFlag != null) ...[
                        const SizedBox(width: 6),
                        Text(countryFlag, style: const TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      if (friend.username != null && friend.username!.isNotEmpty)
                        Flexible(
                          child: Text(
                            '@${friend.username!}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        PresenceFormatter.format(friend.lastActiveAt, languageCode),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (friend.travelStatus != null && friend.travelStatus!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        friend.travelStatus!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions Menu
            if (onRemoveTap != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (val) {
                  if (val == 'remove') {
                    onRemoveTap!();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(Icons.person_remove_rounded, size: 18, color: Colors.red),
                        const SizedBox(width: 10),
                        Text(
                          FriendLocalization.getRemoveFriend(languageCode),
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
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
