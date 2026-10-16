import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/bouncy_pressable.dart';
import '../../../admin/user_moderation_provider.dart';
import '../../auth_controller.dart';

/// Full-screen styled Security Lock Screen displayed when an account is temporarily or permanently suspended
class BannedScreen extends ConsumerWidget {
  final UserModerationState moderation;

  const BannedScreen({
    super.key,
    required this.moderation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isPermanent = moderation.banStatus == 'permanent';
    DateTime? expiryDate;
    if (moderation.banExpiresAt != null) {
      expiryDate = DateTime.tryParse(moderation.banExpiresAt!);
    }

    final reasonText = moderation.banReason != null && moderation.banReason!.trim().isNotEmpty
        ? moderation.banReason!.trim()
        : l10n.adminDefaultBanReason;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Glowing Warning Shield Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.errorPastel.withValues(alpha: isDark ? 0.2 : 0.12),
                    border: Border.all(
                      color: AppColors.errorPastel.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.gpp_bad_rounded,
                      size: 52,
                      color: AppColors.errorPastel,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Main Title
                Text(
                  isPermanent ? l10n.adminPermanentBanTitle : l10n.adminTemporaryBanTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  l10n.adminAccountSuspendedNotice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Details Card
                AppCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ban Type Row
                      Row(
                        children: [
                          Icon(
                            isPermanent ? Icons.block_rounded : Icons.timer_outlined,
                            size: 20,
                            color: isPermanent ? AppColors.errorPastel : AppColors.warningPastel,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isPermanent ? l10n.adminPermanentBan : l10n.adminTemporaryBan,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isPermanent ? AppColors.errorPastel : AppColors.warningPastel,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Reason
                      Text(
                        l10n.adminBanReasonLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reasonText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Expiry Date (if temporary)
                      if (!isPermanent && expiryDate != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.adminBanExpiresAtLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateFormatter.formatDateTime(expiryDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Sign Out Action Button
                BouncyPressable(
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              l10n.adminSignOut,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
