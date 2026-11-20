import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_typography.dart';
import 'package:packbuddy/shared/widgets/app_button.dart';
import 'package:packbuddy/shared/widgets/app_divider.dart';
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
import 'package:packbuddy/core/services/biometric_service.dart';
import 'package:packbuddy/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:packbuddy/core/l10n/language_selector_sheet.dart';
import 'package:packbuddy/features/feedback/domain/feedback_localization.dart';
import 'package:packbuddy/features/feedback/presentation/widgets/feedback_sheet.dart';
import 'package:packbuddy/shared/widgets/app_logo.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/legal_consent_localization.dart';
import 'package:packbuddy/features/auth/presentation/screens/legal_consent_screen.dart';
import 'package:packbuddy/features/help/presentation/screens/help_screen.dart';
import 'package:packbuddy/features/help/domain/help_localization.dart';
import 'package:packbuddy/features/connectivity/presentation/screens/sync_status_screen.dart';
import 'package:packbuddy/features/connectivity/domain/connectivity_localization.dart';
import 'package:packbuddy/features/profile/presentation/screens/profile_screen.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';

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
    final authUser = ref.watch(authUserProvider);
    final profileState = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'settings-hero-badge',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: theme.colorScheme.secondary,
                      size: 18,
                    ),
                  ),
                ),
                Hero(
                  tag: 'settings-hero-title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      l10n.settings,
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, math.max(120.0, MediaQuery.paddingOf(context).bottom + 100.0)),
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

          // 0.1 User Profile Card
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: AppRadius.card,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen(avatarHeroTag: 'settings-profile-avatar')),
              );
            },
            child: Row(
              children: [
                Hero(
                  tag: 'settings-profile-avatar',
                  child: UserAvatar(
                    photoUrl: profileState.profile?.photoUrl,
                    displayName: profileState.profile?.displayName,
                    email: authUser?.email,
                    size: 48,
                    isAnimated: true,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileState.profile?.displayName?.isNotEmpty == true
                            ? profileState.profile!.displayName!
                            : (authUser?.displayName?.isNotEmpty == true
                                ? authUser!.displayName!
                                : ProfileLocalization.getTitle(currentLocale.languageCode)),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authUser?.email ?? '',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
            borderRadius: AppRadius.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    L10n.getLanguageFlag(currentLocale.languageCode),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(
                  L10n.getLanguageName(currentLocale.languageCode),
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${currentLocale.languageCode.toUpperCase()} • 20 ${l10n.language}',
                  style: AppTypography.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => showLanguageSelectorSheet(context, ref, currentLocale),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Theme Selection Card
          _SectionHeader(title: l10n.theme),
          const SizedBox(height: 8),
          AppCard(
            borderRadius: AppRadius.card,
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
            borderRadius: AppRadius.card,
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
                        borderRadius: BorderRadius.circular(AppRadius.xs),
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
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            syncState.lastSyncTime != null
                                ? '${l10n.lastSync}: ${AppDateFormatter.formatDateTime(syncState.lastSyncTime!)}'
                                : '${l10n.lastSync}: --',
                            style: AppTypography.mono(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              tabularFigures: true,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton.outline(
                  onPressed: syncState.status == SyncStatus.syncing
                      ? null
                      : () {
                          ref.read(syncEngineProvider.notifier).performSync();
                        },
                  isLoading: syncState.status == SyncStatus.syncing,
                  leadingIcon: Icons.sync_rounded,
                  label: l10n.syncNow,
                  isExpanded: true,
                  size: AppButtonSize.medium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SyncStatusScreen()),
                      );
                    },
                    icon: const Icon(Icons.history_rounded, size: 16),
                    label: Text(
                      ConnectivityLocalization.getSyncStatusTitle(Localizations.localeOf(context).languageCode),
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
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
            borderRadius: AppRadius.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile.adaptive(
                key: const Key('packing_reminders_switch_tile'),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: theme.colorScheme.primary,
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Icon(Icons.check, size: 14, color: Colors.white);
                  }
                  return const Icon(Icons.close, size: 14, color: Colors.grey);
                }),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: packingRemindersEnabled
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
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
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  l10n.packingRemindersSubtitle,
                  style: AppTypography.caption.copyWith(
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
            borderRadius: AppRadius.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: vaultState.hasPin
                            ? AppColors.successPastel.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(
                        vaultState.hasPin ? Icons.lock_rounded : Icons.lock_open_rounded,
                        color: vaultState.hasPin ? AppColors.successPastel : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      l10n.vaultPinProtection,
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      vaultState.hasPin ? l10n.pinProtectionActive : l10n.unprotectedSetPin,
                      style: AppTypography.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () => _showPinDialog(context, ref, vaultState.hasPin),
                      child: Text(vaultState.hasPin ? l10n.change : l10n.setup),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  SwitchListTile.adaptive(
                    key: const Key('biometric_unlock_switch_tile'),
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primaryLight,
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Icon(Icons.check, size: 14, color: Colors.white);
                      }
                      return const Icon(Icons.close, size: 14, color: Colors.grey);
                    }),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (vaultState.isBiometricEnabled && vaultState.hasPin)
                            ? AppColors.primaryLight.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(
                        Icons.fingerprint_rounded,
                        color: (vaultState.isBiometricEnabled && vaultState.hasPin)
                            ? AppColors.primaryLight
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      l10n.biometricUnlock,
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      !vaultState.hasPin
                          ? l10n.setPinFirstToEnableBiometrics
                          : l10n.biometricUnlockSubtitle,
                      style: AppTypography.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: vaultState.isBiometricEnabled && vaultState.hasPin,
                    onChanged: (enabled) async {
                      if (!vaultState.hasPin) {
                        _showPinDialog(context, ref, false);
                        return;
                      }
                      if (enabled) {
                        final available = await BiometricService.instance.isBiometricsAvailable();
                        if (!available && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.biometricsFailed),
                              backgroundColor: AppColors.errorPastel,
                            ),
                          );
                          return;
                        }
                        final authSuccess = await BiometricService.instance.authenticate(
                          localizedReason: l10n.vaultBiometricReason,
                        );
                        if (authSuccess) {
                          await ref.read(vaultControllerProvider.notifier).setBiometricEnabled(true);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.biometricUnlock),
                                backgroundColor: AppColors.successPastel,
                              ),
                            );
                          }
                        }
                      } else {
                        await ref.read(vaultControllerProvider.notifier).setBiometricEnabled(false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 7. Account & Authentication Session
          _SectionHeader(
            title: l10n.accountAndSession,
          ),
          const SizedBox(height: 8),
          _AccountSessionCard(
            isDark: theme.brightness == Brightness.dark,
          ),
          const SizedBox(height: 24),

          // 8. Home Screen Widget Preview & Customization (Feature F-9)
          _SectionHeader(title: l10n.widgetSettings),
          const SizedBox(height: 8),
          HomeWidgetPreviewCard(key: ValueKey(currentLocale.languageCode)),
          const SizedBox(height: 24),

          // 9. Interactive App Tour (Feature F-13)
          _SectionHeader(title: l10n.replayTour),
          const SizedBox(height: 8),
          AppCard(
            borderRadius: AppRadius.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  l10n.replayTour,
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  l10n.onboardingTitle1,
                  style: AppTypography.caption.copyWith(
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
          const SizedBox(height: 16),

          // 10. Feedback & Suggestions Section
          AppCard(
            padding: const EdgeInsets.all(16),
            borderRadius: AppRadius.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryAmber : AppColors.primaryLight)
                            .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        size: 18,
                        color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FeedbackL10n.getTitle(Localizations.localeOf(context).languageCode),
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                          Text(
                            FeedbackL10n.getSubtitle(Localizations.localeOf(context).languageCode),
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppButton.outline(
                  onPressed: () => FeedbackSheet.show(context),
                  leadingIcon: Icons.edit_note_rounded,
                  label: FeedbackL10n.getTitle(Localizations.localeOf(context).languageCode),
                  isExpanded: true,
                  size: AppButtonSize.medium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 11. Help & FAQ Section
          AppCard(
            padding: const EdgeInsets.all(16),
            borderRadius: AppRadius.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(
                        Icons.help_center_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            HelpLocalization.getTitle(Localizations.localeOf(context).languageCode),
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                          Text(
                            HelpLocalization.getSubtitle(Localizations.localeOf(context).languageCode),
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppButton.outline(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    );
                  },
                  leadingIcon: Icons.menu_book_rounded,
                  label: HelpLocalization.getTitle(Localizations.localeOf(context).languageCode),
                  isExpanded: true,
                  size: AppButtonSize.medium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 12. Legal, User Agreement & Privacy Policy Section
          _SectionHeader(title: LegalConsentLocalization.getTitle(currentLocale.languageCode)),
          const SizedBox(height: 8),
          AppCard(
            borderRadius: AppRadius.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  ),
                ),
                title: Text(
                  LegalConsentLocalization.getTitle(currentLocale.languageCode),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  LegalConsentLocalization.getAcceptedStatus(
                    currentLocale.languageCode,
                    PreferencesService.instance.getLegalConsentVersion(),
                    PreferencesService.instance.getLegalConsentDate(),
                  ),
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
                      builder: (_) => const LegalConsentScreen(
                        isMandatoryGate: false,
                        isReviewMode: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 9. Clean App Version Footer with Logo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'PackBuddy v1.0.0',
                  style: AppTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    tabularFigures: true,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        backgroundColor: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
        title: Text(
          hasPin ? l10n.changeOrRemovePin : l10n.setVaultPin,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasPin ? l10n.changePinDescription : l10n.setPinDescription,
              style: AppTypography.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              style: AppTypography.mono(fontSize: 18, fontWeight: FontWeight.bold, tabularFigures: true),
              decoration: InputDecoration(
                labelText: l10n.fourDigitPin,
                prefixIcon: const Icon(Icons.pin_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            ),
          ],
        ),
        actions: [
          if (hasPin)
            AppButton.destructive(
              size: AppButtonSize.medium,
              onPressed: () {
                ref.read(vaultControllerProvider.notifier).removePin();
                Navigator.of(ctx).pop();
              },
              label: l10n.removePin,
            ),
          AppButton.outline(
            size: AppButtonSize.medium,
            onPressed: () => Navigator.of(ctx).pop(),
            label: l10n.cancel,
          ),
          AppButton.primary(
            size: AppButtonSize.medium,
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                ref.read(vaultControllerProvider.notifier).setPin(pin);
                Navigator.of(ctx).pop();
              }
            },
            label: l10n.save,
          ),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 2),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      borderRadius: AppRadius.card,
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      backgroundColor: theme.colorScheme.surface,
      border: BorderSide(
        color: isPro
            ? AppColors.successPastel.withValues(alpha: 0.35)
            : (isDark ? AppColors.borderSubtle(true) : AppColors.borderSubtle(false)),
        width: 1,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPro
                  ? AppColors.successContainerLight
                  : AppColors.primaryContainerLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPro ? Icons.verified_rounded : Icons.auto_awesome_rounded,
              color: isPro ? AppColors.successPastel : AppColors.primaryLight,
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.proTitle,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isPro ? AppColors.successPastel : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPro ? l10n.activeStatus : l10n.proBadge,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isPro ? l10n.purchaseSuccess : l10n.upgradeToPro,
                  style: AppTypography.caption.copyWith(
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
    final l10n = AppLocalizations.of(context)!;
    final email = user?.email ?? '';
    final initialLetter = email.isNotEmpty ? email[0].toUpperCase() : 'P';

    return AppCard(
      borderRadius: AppRadius.card,
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
                        ? const [AppColors.primaryDark, Color(0xFF3E2D00)]
                        : const [AppColors.primaryLight, Color(0xFF422E00)],
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
                      style: AppTypography.titleSmall.copyWith(
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
                            style: AppTypography.caption.copyWith(
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
          const AppDivider(),
          const SizedBox(height: 12),
          AppButton.outline(
            onPressed: () => _confirmSignOut(context, ref, l10n),
            leadingIcon: Icons.logout_rounded,
            label: l10n.signOutConfirmTitle,
            isExpanded: true,
            size: AppButtonSize.medium,
          ),
          const SizedBox(height: 8),
          AppButton.destructive(
            onPressed: () => _confirmAccountDeletion(context, ref, l10n),
            leadingIcon: Icons.delete_forever_rounded,
            label: l10n.deleteAccountTitle,
            isExpanded: true,
            size: AppButtonSize.medium,
          ),
        ],
      ),
    );
  }

  void _confirmAccountDeletion(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        backgroundColor: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorPastel, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.deleteAccountConfirmationTitle,
                style: AppTypography.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                style: AppTypography.bodyMedium.copyWith(fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
        actionsOverflowDirection: VerticalDirection.down,
        actionsOverflowButtonSpacing: 8,
        actions: [
          AppButton.outline(
            size: AppButtonSize.medium,
            onPressed: () => Navigator.of(ctx).pop(),
            label: l10n.cancel,
          ),
          AppButton.destructive(
            size: AppButtonSize.medium,
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
            label: l10n.deleteAccountButton,
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        backgroundColor: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
        title: Text(
          l10n.signOutConfirmTitle,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.signOutConfirmMessage,
          style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          AppButton.outline(
            size: AppButtonSize.medium,
            onPressed: () => Navigator.of(ctx).pop(),
            label: l10n.cancel,
          ),
          AppButton.destructive(
            size: AppButtonSize.medium,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            label: l10n.signOutConfirmTitle,
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
      borderRadius: AppRadius.card,
      onTap: onTap,
      backgroundColor: theme.colorScheme.surface,
      border: BorderSide(
        color: isDark ? AppColors.borderSubtle(true) : AppColors.borderSubtle(false),
        width: 1,
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryContainerDark
                  : AppColors.primaryContainerLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.adminDashboard,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                        ),
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
                  style: AppTypography.caption.copyWith(
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
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = mode == selectedMode;

    return InkWell(
      onTap: () {
        AppHaptics.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primaryContainerDark
                  : AppColors.primaryContainerLight.withValues(alpha: 0.45))
              : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                : (isDark ? AppColors.borderSubtle(true) : AppColors.borderSubtle(false)),
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



