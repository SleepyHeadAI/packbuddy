import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_typography.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/budget/domain/collaboration_localization.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/profile/presentation/controllers/friends_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/collaborator_avatar_stack.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_button.dart';
import 'share_trip_sheet.dart';

/// Trip crew: owner + collaborators. The owner removes members and invites new ones;
/// a collaborator can leave the trip. Pops with `true` once the current user has left.
class TripMembersSheet extends ConsumerStatefulWidget {
  final Trip trip;

  const TripMembersSheet({super.key, required this.trip});

  static Future<bool?> show(BuildContext context, Trip trip) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TripMembersSheet(trip: trip),
    );
  }

  @override
  ConsumerState<TripMembersSheet> createState() => _TripMembersSheetState();
}

class _TripMembersSheetState extends ConsumerState<TripMembersSheet> {
  bool _leaving = false;

  Future<bool> _confirm({
    required IconData icon,
    required String title,
    required String body,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        backgroundColor: theme.brightness == Brightness.dark ? AppColors.surfaceDark : AppColors.surfaceLight,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.errorPastel.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.errorPastel, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: AppTypography.body(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton.outline(
                      label: l10n.cancel,
                      size: AppButtonSize.medium,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton.destructive(
                      label: title,
                      size: AppButtonSize.medium,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed == true;
  }

  Future<void> _removeMember(String entry) async {
    final l10n = AppLocalizations.of(context)!;
    AppHaptics.light();
    final confirmed = await _confirm(
      icon: Icons.person_remove_rounded,
      title: l10n.removeMember,
      body: l10n.removeMemberConfirm,
    );
    if (!confirmed || !mounted) return;
    AppHaptics.medium();
    final messenger = ScaffoldMessenger.of(context);
    final removed = await ref.read(tripControllerProvider.notifier).removeCollaborator(widget.trip.id, entry);
    if (removed) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.memberRemoved), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _leaveTrip() async {
    final l10n = AppLocalizations.of(context)!;
    AppHaptics.light();
    final confirmed = await _confirm(
      icon: Icons.logout_rounded,
      title: l10n.leaveTrip,
      body: l10n.leaveTripConfirm,
    );
    if (!confirmed || !mounted) return;
    AppHaptics.heavy();
    setState(() => _leaving = true);
    final left = await ref.read(tripControllerProvider.notifier).leaveTrip(widget.trip.id);
    if (!mounted) return;
    setState(() => _leaving = false);
    if (left) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authErrorNetworkFailed), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    final trip = ref.watch(tripControllerProvider).trips.where((t) => t.id == widget.trip.id).firstOrNull ?? widget.trip;
    final me = ref.watch(authUserProvider);
    final friends = ref.watch(friendsControllerProvider).friends;
    final isOwner = trip.isOwnedBy(me?.uid);

    bool isMyEntry(String c) =>
        me != null && (c == me.uid || (me.email != null && c.toLowerCase() == me.email!.toLowerCase()));

    // One tile per collaborator entry; my own uid/e-mail entries collapse into a single "You" tile.
    final members = <({String entry, String label, String? photoUrl, bool isMe})>[];
    for (final c in trip.collaborators) {
      final mine = isMyEntry(c);
      if (mine && members.any((m) => m.isMe)) continue;
      final friend = CollaboratorAvatarStack.matchFriend(c, friends);
      final label = mine
          ? CollaborationLocalization.getYou(lang)
          : (friend == null && CollaboratorAvatarStack.looksLikeUid(c))
              ? CollaborationLocalization.getCollaborator(lang)
              : CollaboratorAvatarStack.labelFor(c, friends);
      members.add((entry: c, label: label, photoUrl: friend?.photoUrl, isMe: mine));
    }

    final ownerFriend = isOwner ? null : friends.where((f) => f.uid == trip.userId).firstOrNull;
    final ownerLabel = isOwner
        ? CollaborationLocalization.getYou(lang)
        : (ownerFriend?.displayName ?? ownerFriend?.username ?? CollaborationLocalization.getOwner(lang));

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.sheetRadius,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.groups_rounded, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tripCrew,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        CollaborationLocalization.getCollaboratorsCount(lang, members.length + 1),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _MemberTile(
                    label: ownerLabel,
                    role: CollaborationLocalization.getOwner(lang),
                    isOwnerRole: true,
                    photoUrl: ownerFriend?.photoUrl,
                    isMe: isOwner,
                  ),
                  for (final m in members)
                    _MemberTile(
                      label: m.label,
                      role: CollaborationLocalization.getCollaborator(lang),
                      isOwnerRole: false,
                      photoUrl: m.photoUrl,
                      isMe: m.isMe,
                      onRemove: isOwner ? () => _removeMember(m.entry) : null,
                      removeTooltip: l10n.removeMember,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isOwner)
              AppButton.secondary(
                label: l10n.shareTrip,
                leadingIcon: Icons.person_add_rounded,
                isExpanded: true,
                onPressed: () {
                  AppHaptics.light();
                  ShareTripSheet.show(context, trip);
                },
              )
            else
              AppButton.destructive(
                label: l10n.leaveTrip,
                leadingIcon: Icons.logout_rounded,
                isExpanded: true,
                isLoading: _leaving,
                onPressed: _leaving ? null : _leaveTrip,
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String label;
  final String role;
  final bool isOwnerRole;
  final String? photoUrl;
  final bool isMe;
  final VoidCallback? onRemove;
  final String? removeTooltip;

  const _MemberTile({
    required this.label,
    required this.role,
    required this.isOwnerRole,
    required this.photoUrl,
    required this.isMe,
    this.onRemove,
    this.removeTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Light theme uses a darker amber: actionGold on a light surface is too low-contrast for 10px text.
    final ownerColor = isDark ? AppColors.actionGold : const Color(0xFFB45309);
    final badgeColor = isOwnerRole ? ownerColor : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Only my own tile may fall back to this device's avatar.
          UserAvatar(photoUrl: photoUrl, displayName: label, size: 38, fallbackToDeviceUserAvatar: isMe),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOwnerRole ? Icons.workspace_premium_rounded : Icons.person_outline_rounded,
                              size: 11,
                              color: badgeColor,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                role,
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: badgeColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.person_remove_rounded, color: AppColors.errorPastel),
              tooltip: removeTooltip,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
