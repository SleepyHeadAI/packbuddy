import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/friends_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/my_buddy_qr_sheet.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';

/// Interactive modal sheet allowing users to search by @username and dispatch friend requests
class AddFriendSheet extends ConsumerStatefulWidget {
  final UserProfile currentProfile;
  final String languageCode;

  const AddFriendSheet({
    super.key,
    required this.currentProfile,
    required this.languageCode,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfile currentProfile,
    required String languageCode,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFriendSheet(
        currentProfile: currentProfile,
        languageCode: languageCode,
      ),
    );
  }

  @override
  ConsumerState<AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends ConsumerState<AddFriendSheet> {
  late final TextEditingController _searchController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    ref.read(friendsControllerProvider.notifier).searchByUsername(val);
  }

  Future<void> _sendRequest(String targetUid) async {
    setState(() => _isSending = true);
    final success = await ref.read(friendsControllerProvider.notifier).sendRequest(targetUid);
    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FriendLocalization.getRequestSent(widget.languageCode)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final friendsState = ref.watch(friendsControllerProvider);
    final currentUid = ref.watch(authUserProvider)?.uid ?? widget.currentProfile.uid;
    final lang = widget.languageCode;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: AppRadius.sheetRadius,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FriendLocalization.getAddFriend(lang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search by username
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: FriendLocalization.getSearchHint(lang),
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(friendsControllerProvider.notifier).clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainer
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search Loading
            if (friendsState.isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            // Search Result Card
            else if (friendsState.searchResult != null)
              _buildSearchResultCard(context, friendsState.searchResult!, currentUid, friendsState)
            // No result found message
            else if (_searchController.text.trim().isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.person_search_rounded, size: 40, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 10),
                      Text(
                        FriendLocalization.getUserNotFound(lang),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Shortcut to personal QR Code
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                MyBuddyQrSheet.show(
                  context,
                  profile: widget.currentProfile,
                  languageCode: lang,
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FriendLocalization.getMyQrCode(lang),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            FriendLocalization.getShareInviteLink(lang),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(
    BuildContext context,
    FriendUserSummary target,
    String currentUid,
    FriendsState state,
  ) {
    final theme = Theme.of(context);
    final lang = widget.languageCode;

    final isSelf = target.uid == currentUid;
    final isAlreadyFriend = state.friends.any((f) => f.uid == target.uid);
    final isPendingOutgoing = state.outgoingRequests.any((r) => r.user.uid == target.uid);
    final isPendingIncoming = state.incomingRequests.any((r) => r.user.uid == target.uid);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          UserAvatar(
            photoUrl: target.photoUrl,
            displayName: target.displayName,
            size: 52,
            fallbackToDeviceUserAvatar: false,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.displayName?.isNotEmpty == true ? target.displayName! : 'Traveler',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (target.username != null && target.username!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@${target.username!}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
                if (target.travelStatus != null && target.travelStatus!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    target.travelStatus!,
                    style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action Button depending on friendship state
          if (isSelf)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  FriendLocalization.getYou(lang),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else if (isAlreadyFriend)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        FriendLocalization.getBuddy(lang),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (isPendingOutgoing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  '${FriendLocalization.getRequestSent(lang)} ⏳',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B)),
                ),
              ),
            )
          else if (isPendingIncoming)
            FilledButton.tonal(
              onPressed: () {
                final req = state.incomingRequests.firstWhere((r) => r.user.uid == target.uid);
                ref.read(friendsControllerProvider.notifier).acceptRequest(req.friendshipId);
              },
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(FriendLocalization.getAccept(lang)),
              ),
            )
          else
            FilledButton.icon(
              onPressed: _isSending ? null : () => _sendRequest(target.uid),
              icon: _isSending
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.person_add_rounded, size: 15),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  FriendLocalization.getSendRequest(lang),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }
}
