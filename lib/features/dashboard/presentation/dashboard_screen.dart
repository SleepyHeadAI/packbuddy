import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/sync_engine/sync_engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../budget/presentation/controllers/trip_controller.dart';
import '../../budget/presentation/screens/trips_screen.dart';
import '../../settings/data/mock_revenuecat_service.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../vault/presentation/controllers/vault_controller.dart';
import '../../vault/presentation/screens/vault_screen.dart';

/// Minimalist, elegant Dashboard home screen for PackBuddy with live Riverpod bindings
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final syncState = ref.watch(syncEngineProvider);
    final tripState = ref.watch(tripControllerProvider);
    final vaultState = ref.watch(vaultControllerProvider);
    final proState = ref.watch(proSubscriptionProvider);
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

    // Dynamic Trip and Vault counts
    final tripCount = tripState.trips.length;
    final tripSubtitle = tripCount == 0
        ? l10n.budgetDescription
        : '$tripCount ${l10n.trips}';

    final docCount = vaultState.documents.length;
    final vaultSubtitle = docCount == 0
        ? l10n.vaultDescription
        : '$docCount ${l10n.vault}';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appName),
            if (proState.isPro) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          // 20-Language Quick Switcher Chip
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: Text(
                L10n.getLanguageFlag(currentLocale.languageCode),
                style: const TextStyle(fontSize: 14),
              ),
              label: Text(
                currentLocale.languageCode.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () => _showLanguageSelector(context, ref, currentLocale),
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
                  subtitle: tripSubtitle,
                  countBadge: tripCount > 0 ? '$tripCount' : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TripsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _FeatureRowItem(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.secondaryLight,
                  iconBg: AppColors.secondaryContainerLight,
                  title: l10n.vault,
                  subtitle: vaultSubtitle,
                  countBadge: docCount > 0 ? '$docCount' : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const VaultScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _FeatureRowItem(
                  icon: Icons.tune_rounded,
                  iconColor: AppColors.tertiaryLight,
                  iconBg: AppColors.tertiaryContainerLight,
                  title: l10n.settings,
                  subtitle: l10n.settingsDescription,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Phase 5 Footer Indicator
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

  void _showLanguageSelector(BuildContext context, WidgetRef ref, Locale currentLocale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final l10n = AppLocalizations.of(ctx)!;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.translate_rounded, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      l10n.language,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '20 ${l10n.language}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: L10n.all.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                  itemBuilder: (context, index) {
                    final locale = L10n.all[index];
                    final isSelected = locale.languageCode == currentLocale.languageCode;

                    return ListTile(
                      leading: Text(
                        L10n.getLanguageFlag(locale.languageCode),
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        L10n.getLanguageName(locale.languageCode),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                          : null,
                      onTap: () {
                        ref.read(localeProvider.notifier).setLocale(locale);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureRowItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? countBadge;
  final VoidCallback? onTap;

  const _FeatureRowItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.countBadge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
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
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (countBadge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          countBadge!,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
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
