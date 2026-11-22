import 'package:flutter/material.dart';
import 'package:packbuddy/shared/widgets/app_skeleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/friends_controller.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/friend_profile_screen.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/add_friend_sheet.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/friend_tile.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/my_buddy_qr_sheet.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';

/// Serene Voyage primary Travel Buddies screen with friends list,
/// pending requests management, and instant handle discovery
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendsControllerProvider.notifier).loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddSheet(UserProfile profile, String lang) {
    AddFriendSheet.show(
      context,
      currentProfile: profile,
      languageCode: lang,
    );
  }

  void _openQrSheet(UserProfile profile, String lang) {
    MyBuddyQrSheet.show(
      context,
      profile: profile,
      languageCode: lang,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final friendsState = ref.watch(friendsControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final authUser = ref.watch(authUserProvider);

    final effectiveProfile = profileState.profile ??
        UserProfile(
          uid: authUser?.uid ?? '',
          displayName: authUser?.displayName,
          email: authUser?.email,
          createdAt: DateTime.now(),
        );

    final friendsCount = friendsState.friends.length;
    final incomingCount = friendsState.incomingRequests.length;

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
              margin: const EdgeInsetsDirectional.only(end: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_alt_rounded,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ),
            Flexible(
              child: Text(
                FriendLocalization.getFriends(lang),
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded),
            tooltip: FriendLocalization.getMyQrCode(lang),
            onPressed: () => _openQrSheet(effectiveProfile, lang),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: FriendLocalization.getAddFriend(lang),
            onPressed: () => _openAddSheet(effectiveProfile, lang),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      FriendLocalization.getFriends(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (friendsCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$friendsCount',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      FriendLocalization.getFriendRequests(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (incomingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$incomingCount',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(friendsControllerProvider.notifier).loadData(),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Confirmed Friends List
            _buildFriendsTab(context, friendsState, effectiveProfile, lang),

            // Tab 2: Requests (Incoming & Outgoing)
            _buildRequestsTab(context, friendsState, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab(
    BuildContext context,
    FriendsState state,
    UserProfile profile,
    String lang,
  ) {
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const AppSkeletonList(showHeader: false, itemCount: 5);
    }

    if (state.friends.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.group_add_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                FriendLocalization.getNoFriendsTitle(lang),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                FriendLocalization.getNoFriendsSubtitle(lang),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _openAddSheet(profile, lang),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text(
                  FriendLocalization.getAddFriend(lang),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: state.friends.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final friend = state.friends[index];
        return FriendTile(
          friend: friend,
          languageCode: lang,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FriendProfileScreen(
                  friendUid: friend.uid,
                  fallbackSummary: friend,
                ),
              ),
            );
          },
          onRemoveTap: () {
            _confirmRemoveFriend(context, friend, lang);
          },
        );
      },
    );
  }

  void _confirmRemoveFriend(BuildContext context, FriendUserSummary friend, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(FriendLocalization.getRemoveFriend(lang)),
        content: Text(
          FriendLocalization.getRemoveFriendConfirm(lang, friend.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(FriendLocalization.getCancel(lang)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(friendsControllerProvider.notifier).removeFriend(friend.uid);
            },
            child: Text(FriendLocalization.getRemoveFriend(lang)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(BuildContext context, FriendsState state, String lang) {
    final theme = Theme.of(context);

    if (state.incomingRequests.isEmpty && state.outgoingRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_rounded,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 14),
              Text(
                FriendLocalization.getNoRequests(lang),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // 1. Incoming Requests
        if (state.incomingRequests.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              FriendLocalization.getIncomingRequests(lang),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          ...state.incomingRequests.map((req) {
            return _buildRequestCard(
              context,
              req: req,
              lang: lang,
              isIncoming: true,
            );
          }),
          const SizedBox(height: 20),
        ],

        // 2. Outgoing Requests
        if (state.outgoingRequests.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              FriendLocalization.getOutgoingRequests(lang),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          ...state.outgoingRequests.map((req) {
            return _buildRequestCard(
              context,
              req: req,
              lang: lang,
              isIncoming: false,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildRequestCard(
    BuildContext context, {
    required FriendRequestItem req,
    required String lang,
    required bool isIncoming,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          UserAvatar(
            photoUrl: req.user.photoUrl,
            displayName: req.user.displayName,
            size: 46,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.user.displayName?.isNotEmpty == true ? req.user.displayName! : 'Traveler',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (req.user.username != null && req.user.username!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@${req.user.username!}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isIncoming) ...[
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.red, size: 20),
              tooltip: FriendLocalization.getDecline(lang),
              onPressed: () {
                ref.read(friendsControllerProvider.notifier).declineOrCancelRequest(req.friendshipId);
              },
            ),
            FilledButton.tonal(
              onPressed: () {
                ref.read(friendsControllerProvider.notifier).acceptRequest(req.friendshipId);
              },
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(FriendLocalization.getAccept(lang)),
            ),
          ] else ...[
            OutlinedButton(
              onPressed: () {
                ref.read(friendsControllerProvider.notifier).declineOrCancelRequest(req.friendshipId);
              },
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              child: Text(
                FriendLocalization.getCancelRequest(lang),
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
