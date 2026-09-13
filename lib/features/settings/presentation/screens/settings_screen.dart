import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/core/l10n/l10n.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/theme_provider.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Complete Settings screen handling Language, Theme, Sync, and PackBuddy Pro
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final syncState = ref.watch(syncEngineProvider);
    final proState = ref.watch(proSubscriptionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 1. PackBuddy Pro Banner
          _ProBanner(
            isPro: proState.isPro,
            onTap: () => PaywallSheet.show(context),
          ),
          const SizedBox(height: 24),

          // 2. Language Selection Card
          _SectionHeader(title: l10n.language),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainerLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  L10n.getLanguageFlag(currentLocale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              title: Text(
                L10n.getLanguageName(currentLocale.languageCode),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${currentLocale.languageCode.toUpperCase()} • 20 ${l10n.language}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showLanguageSelector(context, ref, currentLocale),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Theme Selection Card
          _SectionHeader(title: l10n.theme),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                      icon: const Icon(Icons.brightness_auto_rounded, size: 18),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                      icon: const Icon(Icons.light_mode_rounded, size: 18),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                      icon: const Icon(Icons.dark_mode_rounded, size: 18),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Synchronization Status & Manual Sync
          _SectionHeader(title: l10n.syncReady),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getSyncIconBg(syncState.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSyncIcon(syncState.status),
                        color: _getSyncIconColor(syncState.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSyncTitle(syncState.status, l10n),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            syncState.lastSyncTime != null
                                ? '${l10n.lastSync}: ${DateFormat('dd.MM.yyyy HH:mm').format(syncState.lastSyncTime!)}'
                                : '${l10n.lastSync}: --',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    onPressed: syncState.status == SyncStatus.syncing
                        ? null
                        : () {
                            ref.read(syncEngineProvider.notifier).performSync();
                          },
                    icon: syncState.status == SyncStatus.syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded, size: 18),
                    label: Text(l10n.syncNow),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 5. App Footer
          Center(
            child: Column(
              children: [
                Text(
                  'PackBuddy v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SleepyHead INC. CO. • Offline-First Travel Companion',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
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

  IconData _getSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return Icons.sync_rounded;
      case SyncStatus.upToDate:
        return Icons.cloud_done_rounded;
      case SyncStatus.failed:
        return Icons.cloud_off_rounded;
      case SyncStatus.noInternet:
        return Icons.wifi_off_rounded;
      case SyncStatus.idle:
        return Icons.cloud_outlined;
    }
  }

  Color _getSyncIconBg(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return AppColors.infoPastel.withValues(alpha: 0.2);
      case SyncStatus.upToDate:
        return AppColors.successPastel.withValues(alpha: 0.2);
      case SyncStatus.failed:
        return AppColors.errorPastel.withValues(alpha: 0.2);
      case SyncStatus.noInternet:
      case SyncStatus.idle:
        return AppColors.secondaryContainerLight;
    }
  }

  Color _getSyncIconColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return AppColors.infoPastel;
      case SyncStatus.upToDate:
        return AppColors.successPastel;
      case SyncStatus.failed:
        return AppColors.errorPastel;
      case SyncStatus.noInternet:
      case SyncStatus.idle:
        return AppColors.secondaryLight;
    }
  }

  String _getSyncTitle(SyncStatus status, AppLocalizations l10n) {
    switch (status) {
      case SyncStatus.syncing:
        return l10n.syncInProgress;
      case SyncStatus.upToDate:
        return l10n.syncUpToDate;
      case SyncStatus.failed:
        return l10n.syncFailed;
      case SyncStatus.noInternet:
        return l10n.offlineReady;
      case SyncStatus.idle:
        return l10n.syncReady;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _ProBanner extends StatelessWidget {
  final bool isPro;
  final VoidCallback onTap;

  const _ProBanner({
    required this.isPro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPro
                ? [
                    AppColors.successPastel.withValues(alpha: 0.2),
                    AppColors.primaryContainerLight.withValues(alpha: 0.3),
                  ]
                : [
                    AppColors.tertiaryContainerLight,
                    AppColors.primaryContainerLight,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiaryLight.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPro ? Icons.verified_rounded : Icons.auto_awesome_rounded,
                color: isPro ? AppColors.successPastel : AppColors.tertiaryLight,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.proTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPro ? AppColors.successPastel : AppColors.tertiaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPro ? 'ACTIVE' : l10n.proBadge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPro ? l10n.purchaseSuccess : l10n.upgradeToPro,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
