import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/core/l10n/l10n.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/theme_provider.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/home_widget_preview_card.dart';
import 'package:packbuddy/features/onboarding/presentation/screens/onboarding_screen.dart';

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
    final vaultState = ref.watch(vaultControllerProvider);
    final packingRemindersEnabled = ref.watch(packingRemindersProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 0. Executive Admin Dashboard Entry (Strictly visible for authorized admin)
          if (isAdmin) ...[
            _AdminDashboardBanner(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],

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
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
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
          ),
          const SizedBox(height: 24),

          // 3. Theme Selection Card
          _SectionHeader(title: l10n.theme),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _ThemeModeCard(
                      mode: ThemeMode.system,
                      selectedMode: themeMode,
                      icon: Icons.brightness_auto_rounded,
                      label: l10n.themeSystem,
                      onTap: () {
                        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ThemeModeCard(
                      mode: ThemeMode.light,
                      selectedMode: themeMode,
                      icon: Icons.light_mode_rounded,
                      label: l10n.themeLight,
                      onTap: () {
                        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ThemeModeCard(
                      mode: ThemeMode.dark,
                      selectedMode: themeMode,
                      icon: Icons.dark_mode_rounded,
                      label: l10n.themeDark,
                      onTap: () {
                        ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                      },
                    ),
                  ),
                ],
              ),
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
                        color: _getSyncIconBg(syncState.status, theme),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSyncIcon(syncState.status),
                        color: _getSyncIconColor(syncState.status, theme),
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
                                ? '${l10n.lastSync}: ${AppDateFormatter.formatDateTime(syncState.lastSyncTime!)}'
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
          const SizedBox(height: 24),

          // 5. Notifications & Smart Packing Reminders
          _SectionHeader(
            title: l10n.notificationsAndReminders,
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: packingRemindersEnabled
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    packingRemindersEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_outlined,
                    color: packingRemindersEnabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(
                  l10n.packingReminders,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  l10n.packingRemindersSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                value: packingRemindersEnabled,
                onChanged: (value) {
                  ref.read(packingRemindersProvider.notifier).toggle(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 6. Security & Vault Protection
          _SectionHeader(title: l10n.security),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: vaultState.hasPin
                      ? AppColors.successPastel.withValues(alpha: 0.15)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  vaultState.hasPin ? Icons.lock_rounded : Icons.lock_open_rounded,
                  color: vaultState.hasPin ? AppColors.successPastel : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              title: Text(
                l10n.vaultPinProtection,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                vaultState.hasPin ? l10n.pinProtectionActive : l10n.unprotectedSetPin,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: TextButton(
                onPressed: () => _showPinDialog(context, ref, vaultState.hasPin),
                child: Text(vaultState.hasPin ? l10n.change : l10n.setup),
              ),
            ),
          ),
          ),
          const SizedBox(height: 24),

          // 6. Account & Authentication Session
          _SectionHeader(
            title: l10n.accountAndSession,
          ),
          const SizedBox(height: 8),
          _AccountSessionCard(
            isDark: theme.brightness == Brightness.dark,
          ),
          const SizedBox(height: 24),

          // 7. Home Screen Widget Preview & Customization (Feature F-9)
          _SectionHeader(title: l10n.widgetSettings),
          const SizedBox(height: 8),
          const HomeWidgetPreviewCard(),
          const SizedBox(height: 24),

          // 8. Interactive App Tour (Feature F-13)
          _SectionHeader(title: l10n.replayTour),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  l10n.replayTour,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  l10n.onboardingTitle1,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OnboardingScreen(isReplay: true),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 7. App Footer
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
    ),
  );
}

  void _showPinDialog(BuildContext context, WidgetRef ref, bool hasPin) {
    final l10n = AppLocalizations.of(context)!;
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(hasPin ? l10n.changeOrRemovePin : l10n.setVaultPin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasPin ? l10n.changePinDescription : l10n.setPinDescription,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.fourDigitPin,
                prefixIcon: const Icon(Icons.pin_rounded),
              ),
            ),
          ],
        ),
        actions: [
          if (hasPin)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.errorPastel),
              onPressed: () {
                ref.read(vaultControllerProvider.notifier).removePin();
                Navigator.of(ctx).pop();
              },
              child: Text(l10n.removePin),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                ref.read(vaultControllerProvider.notifier).setPin(pin);
                Navigator.of(ctx).pop();
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref, Locale currentLocale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final l10n = AppLocalizations.of(ctx)!;

        return RepaintBoundary(
          child: Container(
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

  Color _getSyncIconBg(SyncStatus status, ThemeData theme) {
    switch (status) {
      case SyncStatus.syncing:
        return AppColors.infoPastel.withValues(alpha: 0.2);
      case SyncStatus.upToDate:
        return AppColors.successPastel.withValues(alpha: 0.2);
      case SyncStatus.failed:
        return AppColors.errorPastel.withValues(alpha: 0.2);
      case SyncStatus.noInternet:
      case SyncStatus.idle:
        return theme.colorScheme.secondaryContainer;
    }
  }

  Color _getSyncIconColor(SyncStatus status, ThemeData theme) {
    switch (status) {
      case SyncStatus.syncing:
        return AppColors.infoPastel;
      case SyncStatus.upToDate:
        return AppColors.successPastel;
      case SyncStatus.failed:
        return AppColors.errorPastel;
      case SyncStatus.noInternet:
      case SyncStatus.idle:
        return theme.colorScheme.secondary;
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
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  ]
                : [
                    theme.colorScheme.tertiaryContainer.withValues(alpha: 0.8),
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
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
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
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
                      Flexible(
                        child: Text(
                          l10n.proTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPro ? AppColors.successPastel : AppColors.tertiaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isPro ? l10n.activeStatus : l10n.proBadge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

/// Luxury Account and Authentication Session Card with Sign Out integration
class _AccountSessionCard extends ConsumerWidget {
  final bool isDark;

  const _AccountSessionCard({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final email = user?.email ?? '';
    final initialLetter = email.isNotEmpty ? email[0].toUpperCase() : 'P';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [AppColors.primaryDark, Color(0xFF1E3A5F)]
                        : const [AppColors.primaryLight, AppColors.passportNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                          .withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initialLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email.isNotEmpty
                          ? email
                          : l10n.signedInTraveler,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.successPastel,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.cloudSessionActive,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.successPastel,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorPastel,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                side: BorderSide(
                  color: AppColors.errorPastel.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _confirmSignOut(context, ref, l10n),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout_rounded, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.signOutConfirmTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.errorPastel.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _confirmAccountDeletion(context, ref, l10n),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delete_forever_rounded, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.deleteAccountTitle,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
    );
  }

  void _confirmAccountDeletion(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorPastel, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.deleteAccountConfirmationTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountConfirmationMessage,
                style: const TextStyle(fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
        actionsOverflowDirection: VerticalDirection.down,
        actionsOverflowButtonSpacing: 8,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorPastel,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref.read(authControllerProvider.notifier).requestAccountDeletion();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.deleteAccountScheduledNotice),
                    backgroundColor: AppColors.errorPastel,
                    duration: const Duration(seconds: 6),
                  ),
                );
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(l10n.deleteAccountButton),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(l10n.signOutConfirmTitle),
        content: Text(
          l10n.signOutConfirmMessage,
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorPastel,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: Text(l10n.signOutConfirmTitle),
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _AdminDashboardBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      borderRadius: 22,
      onTap: onTap,
      backgroundColor: isDark
          ? const Color(0xFF1E2638)
          : const Color(0xFFF1F5FD),
      border: BorderSide(
        color: theme.colorScheme.primary.withValues(alpha: 0.35),
        width: 1.5,
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
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
                    Flexible(
                      child: Text(
                        l10n.adminDashboard,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'EXECUTIVE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.adminDashboardDesc,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  final ThemeMode mode;
  final ThemeMode selectedMode;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ThemeModeCard({
    required this.mode,
    required this.selectedMode,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = mode == selectedMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



