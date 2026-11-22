import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/features/profile/presentation/screens/friends_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/edit_profile_sheet.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/profile_header_card.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/travel_badges_card.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/travel_stats_card.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/world_map_profile_card.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';

/// Serene Voyage primary Profile screen with editable traveler details,
/// live travel analytics, and account metadata.
class ProfileScreen extends ConsumerStatefulWidget {
  final String? avatarHeroTag;

  const ProfileScreen({super.key, this.avatarHeroTag});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authUserProvider);
      if (user != null) {
        ref.read(profileControllerProvider.notifier).loadProfile(user.uid);
      }
      ref.read(travelMapControllerProvider.notifier).loadCountries();
    });
  }

  void _openEditSheet(UserProfile profile, String lang) {
    EditProfileSheet.show(
      context,
      profile: profile,
      languageCode: lang,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final travelMapState = ref.watch(travelMapControllerProvider);
    final authUser = ref.watch(authUserProvider);
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    final effectiveProfile = profileState.profile ??
        UserProfile(
          uid: authUser?.uid ?? '',
          displayName: authUser?.displayName,
          email: authUser?.email,
          photoUrl: authUser?.photoURL,
          createdAt: authUser?.metadata.creationTime ?? DateTime.now(),
        );

    String memberSinceStr;
    try {
      memberSinceStr = DateFormat.yMMMMd(langCode).format(effectiveProfile.createdAt);
    } catch (_) {
      try {
        memberSinceStr = DateFormat.yMMMMd().format(effectiveProfile.createdAt);
      } catch (_) {
        memberSinceStr = '${effectiveProfile.createdAt.year}-${effectiveProfile.createdAt.month.toString().padLeft(2, '0')}-${effectiveProfile.createdAt.day.toString().padLeft(2, '0')}';
      }
    }
    final isEmailVerified = authUser?.emailVerified ?? false;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _openEditSheet(effectiveProfile, langCode),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: UserAvatar(
                  photoUrl: effectiveProfile.photoUrl,
                  displayName: effectiveProfile.displayName,
                  email: effectiveProfile.email,
                  size: 32,
                  isAnimated: false,
                ),
              ),
            ),
            Flexible(
              child: Text(
                ProfileLocalization.getTitle(langCode),
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline_rounded),
            tooltip: FriendLocalization.getFriends(langCode),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FriendsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: ProfileLocalization.getEditProfile(langCode),
            onPressed: () => _openEditSheet(effectiveProfile, langCode),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authUser != null) {
            await ref.read(profileControllerProvider.notifier).loadProfile(authUser.uid);
          }
          await ref.read(travelMapControllerProvider.notifier).loadCountries();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Profile Header & Bio Card
            ProfileHeaderCard(
              profile: effectiveProfile,
              languageCode: langCode,
              avatarHeroTag: widget.avatarHeroTag,
              onEditTap: () => _openEditSheet(effectiveProfile, langCode),
              onFriendsTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FriendsScreen()),
              ),
            ),
            const SizedBox(height: 20),

            // 2. World Travel Map & Live Exploration Coverage Card
            WorldMapProfileCard(
              countries: travelMapState.countries,
              isOwnProfile: true,
              onOpenMap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TravelMapScreen()),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Bento Travel Statistics Card
            TravelStatsCard(
              totalTrips: profileState.totalTrips,
              totalCountries: profileState.totalCountriesVisited,
              totalItems: profileState.totalPackingItems,
              totalDocuments: profileState.totalDocuments,
              languageCode: langCode,
            ),
            const SizedBox(height: 20),

            // 3. Travel Personality Styles & Gamified Badges Card
            TravelBadgesCard(
              profile: effectiveProfile,
              totalTrips: profileState.totalTrips,
              totalCountries: profileState.totalCountriesVisited,
              totalItems: profileState.totalPackingItems,
              totalDocuments: profileState.totalDocuments,
              languageCode: langCode,
              onPickStylesTap: () => _openEditSheet(effectiveProfile, langCode),
            ),
            const SizedBox(height: 20),

            // 4. Account Metadata Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                ProfileLocalization.getAccountSecurity(langCode),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
            ),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              borderRadius: AppRadius.lg,
              child: Column(
                children: [
                  _buildAccountRow(
                    icon: Icons.calendar_today_rounded,
                    label: ProfileLocalization.getMemberSince(langCode),
                    value: memberSinceStr,
                    theme: theme,
                  ),
                  const Divider(height: 20),
                  _buildAccountRow(
                    icon: isEmailVerified ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded,
                    iconColor: isEmailVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    label: ProfileLocalization.getEmailStatus(langCode),
                    value: isEmailVerified
                        ? ProfileLocalization.getVerified(langCode)
                        : ProfileLocalization.getUnverified(langCode),
                    theme: theme,
                  ),
                  const Divider(height: 20),
                  _buildAccountRow(
                    icon: Icons.lock_outline_rounded,
                    label: ProfileLocalization.getSignInMethod(langCode),
                    value: authUser?.providerData.isNotEmpty == true &&
                            authUser!.providerData.any((p) => p.providerId.contains('google'))
                        ? 'Google'
                        : ProfileLocalization.getEmailAndPassword(langCode),
                    theme: theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountRow({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
