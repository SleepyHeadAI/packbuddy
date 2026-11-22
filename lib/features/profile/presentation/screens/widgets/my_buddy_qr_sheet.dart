import 'package:flutter/material.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:packbuddy/core/services/share_service.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';

/// Interactive modal sheet displaying a traveler's personal QR code and shareable invite link
class MyBuddyQrSheet extends StatelessWidget {
  final UserProfile profile;
  final String languageCode;

  const MyBuddyQrSheet({
    super.key,
    required this.profile,
    required this.languageCode,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfile profile,
    required String languageCode,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MyBuddyQrSheet(
        profile: profile,
        languageCode: languageCode,
      ),
    );
  }

  String get _inviteUrl {
    final handle = (profile.username?.isNotEmpty == true)
        ? profile.username!
        : (profile.displayName ?? 'traveler');
    return 'https://packbuddy.app/buddy/@$handle';
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _inviteUrl));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(FriendLocalization.getCopiedToClipboard(languageCode)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareLink(BuildContext context) {
    final name = profile.displayName ?? AppLocalizations.of(context)!.emailDefaultName;
    ShareService.shareText(
      text: FriendLocalization.getShareInviteText(languageCode, name, _inviteUrl),
      subject: FriendLocalization.getShareInviteSubject(languageCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                FriendLocalization.getMyQrCode(languageCode),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // User Info
            UserAvatar(
              photoUrl: profile.photoUrl,
              displayName: profile.displayName,
              size: 64,
            ),
            const SizedBox(height: 10),
            Text(
              profile.displayName?.isNotEmpty == true ? profile.displayName! : AppLocalizations.of(context)!.emailDefaultName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            if (profile.username != null && profile.username!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                '@${profile.username!}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Artistic QR Visual Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CustomPaint(
                size: const Size(180, 180),
                painter: _TravelBuddyQrPainter(seed: profile.uid),
              ),
            ),
            const SizedBox(height: 18),

            // Share & Copy Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyLink(context),
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        FriendLocalization.getCopy(languageCode),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _shareLink(context),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        FriendLocalization.getShare(languageCode),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
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

/// Custom painter rendering a clean, stylized high-contrast QR code pattern
class _TravelBuddyQrPainter extends CustomPainter {
  final String seed;

  const _TravelBuddyQrPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFF1E293B);
    final paintPrimary = Paint()..color = const Color(0xFF0284C7);

    final matrixSize = 21;
    final cellSize = size.width / matrixSize;

    // Corner Finder Patterns
    void drawFinderPattern(double left, double top) {
      // Outer 7x7
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, 7 * cellSize, 7 * cellSize),
          const Radius.circular(8),
        ),
        paintDark,
      );
      // Inner White 5x5
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + cellSize, top + cellSize, 5 * cellSize, 5 * cellSize),
          const Radius.circular(6),
        ),
        Paint()..color = Colors.white,
      );
      // Core 3x3
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + 2 * cellSize, top + 2 * cellSize, 3 * cellSize, 3 * cellSize),
          const Radius.circular(4),
        ),
        paintPrimary,
      );
    }

    drawFinderPattern(0, 0);
    drawFinderPattern((matrixSize - 7) * cellSize, 0);
    drawFinderPattern(0, (matrixSize - 7) * cellSize);

    // Decorative data cells based on seed
    final hash = seed.hashCode.abs();
    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        // Skip finder areas
        if ((r < 8 && c < 8) ||
            (r < 8 && c >= matrixSize - 8) ||
            (r >= matrixSize - 8 && c < 8)) {
          continue;
        }

        // Center logo area
        if (r >= 8 && r <= 12 && c >= 8 && c <= 12) {
          continue;
        }

        final bit = (hash + (r * 31) ^ (c * 17)) % 7 < 3;
        if (bit) {
          final cellPaint = (r + c) % 5 == 0 ? paintPrimary : paintDark;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cellSize + 0.5, r * cellSize + 0.5, cellSize - 1, cellSize - 1),
              const Radius.circular(2),
            ),
            cellPaint,
          );
        }
      }
    }

    // Center Airplane / Buddy Icon Badge
    final centerOffset = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(centerOffset, 16, Paint()..color = Colors.white);
    canvas.drawCircle(centerOffset, 14, paintPrimary);
  }

  @override
  bool shouldRepaint(covariant _TravelBuddyQrPainter oldDelegate) => oldDelegate.seed != seed;
}
