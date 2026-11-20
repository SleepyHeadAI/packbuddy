import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/profile/presentation/controllers/friends_controller.dart';

/// Compact, overlapping avatar stack representing trip collaborators
/// Matches Serene Voyage design system with subtle contrast rings
class CollaboratorAvatarStack extends ConsumerWidget {
  final List<String> collaborators;
  final double size;
  final int maxDisplay;
  final VoidCallback? onTap;

  const CollaboratorAvatarStack({
    super.key,
    required this.collaborators,
    this.size = 22,
    this.maxDisplay = 3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (collaborators.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final friends = ref.watch(friendsControllerProvider).friends;
    final displayItems = collaborators.take(maxDisplay).toList();
    final remaining = collaborators.length - maxDisplay;

    final overlap = size * 0.72;
    final totalWidth = (displayItems.length - 1) * overlap + size + (remaining > 0 ? overlap : 0);

    Widget content = SizedBox(
      height: size,
      width: totalWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < displayItems.length; i++) ...[
            Positioned(
              left: i * overlap,
              child: _buildAvatar(
                context: context,
                collaborator: displayItems[i],
                friends: friends,
                theme: theme,
              ),
            ),
          ],
          if (remaining > 0) ...[
            Positioned(
              left: displayItems.length * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }

  Widget _buildAvatar({
    required BuildContext context,
    required String collaborator,
    required List<dynamic> friends,
    required ThemeData theme,
  }) {
    // Check if collaborator matches a friend by @username or uid
    final clean = collaborator.startsWith('@') ? collaborator.substring(1).toLowerCase() : collaborator.toLowerCase();
    dynamic matchedFriend;
    for (final f in friends) {
      if ((f.username != null && f.username.toLowerCase() == clean) ||
          (f.displayName != null && f.displayName.toLowerCase() == clean) ||
          f.uid == collaborator) {
        matchedFriend = f;
        break;
      }
    }

    final photoUrl = matchedFriend?.photoUrl as String?;
    final label = (matchedFriend?.displayName as String?) ??
        (matchedFriend?.username as String?) ??
        (collaborator.startsWith('@') ? collaborator.substring(1) : collaborator);

    final initial = label.isNotEmpty ? label[0].toUpperCase() : '?';

    // Consistent pastel hue based on label
    final hash = label.hashCode.abs();
    final colors = [
      const Color(0xFF0284C7),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];
    final color = colors[hash % colors.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: photoUrl != null && photoUrl.isNotEmpty
          ? Image.network(
              photoUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildInitial(initial, color),
            )
          : _buildInitial(initial, color),
    );
  }

  Widget _buildInitial(String initial, Color color) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.44,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
