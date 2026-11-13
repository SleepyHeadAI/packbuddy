import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/edit_profile_sheet.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/profile_header_card.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/travel_stats_card.dart';

/// Serene Voyage primary Profile screen with editable traveler details,
/// live travel analytics, and account metadata.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

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
    final authUser = ref.watch(authUserProvider);
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final isTr = langCode == 'tr';

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
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: theme.colorScheme.primary,
                size: 18,
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
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Profile Header & Bio Card
            ProfileHeaderCard(
              profile: effectiveProfile,
              languageCode: langCode,
              onEditTap: () => _openEditSheet(effectiveProfile, langCode),
            ),
            const SizedBox(height: 20),

            // 2. Bento Travel Statistics Card
            TravelStatsCard(
              totalTrips: profileState.totalTrips,
              totalCountries: profileState.totalCountriesVisited,
              totalItems: profileState.totalPackingItems,
              totalDocuments: profileState.totalDocuments,
              languageCode: langCode,
            ),
            const SizedBox(height: 20),

            // 3. Account Metadata Card
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
              borderRadius: 18,
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
                    label: isTr ? 'E-posta Durumu' : 'Email Status',
                    value: isEmailVerified
                        ? (isTr ? 'Doğrulandı' : 'Verified')
                        : (isTr ? 'Doğrulanmadı' : 'Unverified'),
                    theme: theme,
                  ),
                  const Divider(height: 20),
                  _buildAccountRow(
                    icon: Icons.lock_outline_rounded,
                    label: isTr ? 'Giriş Yöntemi' : 'Sign-in Method',
                    value: authUser?.providerData.isNotEmpty == true &&
                            authUser!.providerData.any((p) => p.providerId.contains('google'))
                        ? 'Google OAuth'
                        : 'Email & Password',
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
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
