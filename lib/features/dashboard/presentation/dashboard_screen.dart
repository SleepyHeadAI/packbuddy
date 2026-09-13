import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/sync_engine/sync_engine.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

/// Minimalist, elegant Dashboard home screen for PackBuddy
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final syncState = ref.watch(syncEngineProvider);
    final theme = Theme.of(context);

    // Dynamic Sync Badge UI attributes based on Riverpod SyncState
    String syncLabel;
    IconData syncIcon;
    Color syncBgColor;
    Color syncTextColor;

    switch (syncState.status) {
      case SyncStatus.syncing:
        syncLabel = l10n.syncInProgress;
        syncIcon = Icons.sync_rounded;
        syncBgColor = AppColors.infoPastel.withValues(alpha: 0.2);
        syncTextColor = AppColors.infoPastel;
        break;
      case SyncStatus.upToDate:
        syncLabel = l10n.syncUpToDate;
        syncIcon = Icons.cloud_done_outlined;
        syncBgColor = AppColors.primaryContainerLight;
        syncTextColor = AppColors.primaryLight;
        break;
      case SyncStatus.failed:
        syncLabel = l10n.syncFailed;
        syncIcon = Icons.cloud_off_outlined;
        syncBgColor = AppColors.errorPastel.withValues(alpha: 0.2);
        syncTextColor = AppColors.errorPastel;
        break;
      case SyncStatus.noInternet:
        syncLabel = l10n.offlineReady;
        syncIcon = Icons.wifi_off_rounded;
        syncBgColor = AppColors.secondaryContainerLight;
        syncTextColor = AppColors.secondaryLight;
        break;
      case SyncStatus.idle:
        syncLabel = l10n.syncReady;
        syncIcon = Icons.cloud_sync_outlined;
        syncBgColor = AppColors.secondaryContainerLight;
        syncTextColor = AppColors.secondaryLight;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          // Language toggle button for seamless testing
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: const Icon(Icons.language_rounded, size: 16),
              label: Text(
                currentLocale.languageCode.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () {
                ref.read(localeProvider.notifier).toggleLocale();
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Soft Pastel App Icon Container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainerLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.luggage_outlined,
                    size: 38,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 24),

                // Main Greeting
                Text(
                  l10n.welcome,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  l10n.welcomeSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Status Badges (Offline Ready, Dynamic Two-Way Sync, Multi-Currency)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(
                      label: l10n.offlineReady,
                      icon: Icons.offline_pin_outlined,
                      backgroundColor: AppColors.primaryContainerLight,
                      textColor: AppColors.primaryLight,
                    ),
                    // Tap-to-sync dynamic badge bound to Riverpod SyncEngine
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        ref.read(syncEngineProvider.notifier).performSync();
                      },
                      child: StatusBadge(
                        label: syncLabel,
                        icon: syncIcon,
                        backgroundColor: syncBgColor,
                        textColor: syncTextColor,
                      ),
                    ),
                    StatusBadge(
                      label: l10n.multiCurrency,
                      icon: Icons.payments_outlined,
                      backgroundColor: AppColors.tertiaryContainerLight,
                      textColor: AppColors.tertiaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Feature Overview Cards (Budget, Vault, Settings)
                _FeatureRowItem(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.primaryLight,
                  iconBg: AppColors.primaryContainerLight,
                  title: l10n.budget,
                  subtitle: l10n.budgetDescription,
                ),
                const SizedBox(height: 12),

                _FeatureRowItem(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.secondaryLight,
                  iconBg: AppColors.secondaryContainerLight,
                  title: l10n.vault,
                  subtitle: l10n.vaultDescription,
                ),
                const SizedBox(height: 12),

                _FeatureRowItem(
                  icon: Icons.tune_rounded,
                  iconColor: AppColors.tertiaryLight,
                  iconBg: AppColors.tertiaryContainerLight,
                  title: l10n.settings,
                  subtitle: l10n.settingsDescription,
                ),
                const SizedBox(height: 28),

                // Phase 2 Footer Indicator
                Text(
                  l10n.architecturePhase,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    letterSpacing: 0.2,
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

class _FeatureRowItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _FeatureRowItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }
}
