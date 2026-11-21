import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
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

/// Complete Settings screen organized into modern Inset-Grouped cards.
/// Replaces boxy balloon piles with cohesive Apple-grade grouped preference cards.
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
                      color: AppColors.brandAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      AppIcons.settings,
                      color: AppColors.brandAccent,
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
          padding: EdgeInsets.fromLTRB(16, 12, 16, math.max(120.0, MediaQuery.paddingOf(context).bottom + 100.0)),
          children: [
            // 0. Group: Profile & Membership (Executive Hub)
            AppCard(
              borderRadius: AppRadius.card,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Admin Tile (if authorized)
                  if (isAdmin) ...[
                    _SettingsTile(
                      icon: Icons.admin_panel_settings_rounded,
                      iconColor: AppColors.brandAccent,
                      iconBgColor: AppColors.brandAccent.withValues(alpha: 0.12),
                      title: l10n.adminDashboard,
                      badge: 'EXECUTIVE',
                      badgeColor: AppColors.brandAccent,
                      subtitle: l10n.adminDashboardDesc,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardScreen(),
                          ),
                        );
                      },
                    ),
                    _buildHairlineDivider(isDark),
                  ],

                  // User Profile Tile
                  InkWell(
                    onTap: () {
                      AppHaptics.selectionClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(avatarHeroTag: 'settings-profile-avatar'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'settings-profile-avatar',
                            child: UserAvatar(
                              photoUrl: profileState.profile?.photoUrl,
                              displayName: profileState.profile?.displayName,
                              email: authUser?.email,
                              size: 42,
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
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  authUser?.email ?? '',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            AppIcons.chevronRight,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildHairlineDivider(isDark),

                  // PackBuddy Pro Tile
                  _SettingsTile(
                    icon: proState.isPro ? AppIcons.verified : AppIcons.spark,
                    iconColor: proState.isPro ? const Color(0xFF10B981) : AppColors.brandAccent,
                    iconBgColor: (proState.isPro ? const Color(0xFF10B981) : AppColors.brandAccent)
                        .withValues(alpha: 0.12),
                    title: l10n.proTitle,
                    badge: proState.isPro ? l10n.activeStatus : l10n.proBadge,
                    badgeColor: proState.isPro ? const Color(0xFF10B981) : AppColors.brandAccent,
                    subtitle: proState.isPro ? l10n.purchaseSuccess : l10n.upgradeToPro,
                    onTap: () => PaywallSheet.show(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. Group: Appearance & Preferences (Language, Theme, Notifications)
            _SectionHeader(title: l10n.language),
            const SizedBox(height: 8),
            AppCard(
              borderRadius: AppRadius.card,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Language Selection Tile
                  InkWell(
                    onTap: () {
                      AppHaptics.selectionClick();
                      showLanguageSelectorSheet(context, ref, currentLocale);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              L10n.getLanguageFlag(currentLocale.languageCode),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.language,
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${L10n.getLanguageName(currentLocale.languageCode)} (${currentLocale.languageCode.toUpperCase()}) • 20 ${l10n.language}',
                                  style: AppTypography.caption.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            AppIcons.chevronRight,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildHairlineDivider(isDark),

                  // Theme Segmented Control
                  _ThemeModeSegmentedControl(
                    selectedMode: themeMode,
                    onModeChanged: (mode) {
                      ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    },
                  ),

                  _buildHairlineDivider(isDark),

                  // Notifications & Packing Reminders
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: packingRemindersEnabled
                                ? AppColors.brandAccent.withValues(alpha: 0.12)
                                : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            AppIcons.notification,
                            size: 17,
                            color: packingRemindersEnabled
                                ? AppColors.brandAccent
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.packingReminders,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                l10n.packingRemindersSubtitle,
                                style: AppTypography.caption.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          key: const Key('packing_reminders_switch_tile'),
                          value: packingRemindersEnabled,
                          activeTrackColor: AppColors.brandAccent,
                          onChanged: (value) {
                            ref.read(packingRemindersProvider.notifier).toggle(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Group: Two-Way Cloud Synchronization
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
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _getSyncIconBg(syncState.status, theme),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          _getSyncIcon(syncState.status),
                          color: _getSyncIconColor(syncState.status, theme),
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getSyncTitle(syncState.status, l10n),
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              syncState.lastSyncTime != null
                                  ? '${l10n.lastSync}: ${AppDateFormatter.formatDateTime(syncState.lastSyncTime!)}'
                                  : '${l10n.lastSync}: --',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SyncStatusScreen()),
                        );
                      },
                      icon: const Icon(AppIcons.history, size: 15),
                      label: Text(
                        ConnectivityLocalization.getSyncStatusTitle(Localizations.localeOf(context).languageCode),
                        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Group: Security & Vault Protection
            _SectionHeader(title: l10n.security),
            const SizedBox(height: 8),
            AppCard(
              borderRadius: AppRadius.card,
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: vaultState.hasPin
                              ? const Color(0xFF10B981).withValues(alpha: 0.12)
                              : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          vaultState.hasPin ? AppIcons.lock : AppIcons.lockOpen,
                          color: vaultState.hasPin ? const Color(0xFF10B981) : theme.colorScheme.onSurfaceVariant,
                          size: 17,
                        ),
                      ),
                      title: Text(
                        l10n.vaultPinProtection,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        vaultState.hasPin ? l10n.pinProtectionActive : l10n.unprotectedSetPin,
                        style: AppTypography.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () => _showPinDialog(context, ref, vaultState.hasPin),
                        child: Text(
                          vaultState.hasPin ? l10n.change : l10n.setup,
                          style: const TextStyle(color: AppColors.brandAccent, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    _buildHairlineDivider(isDark),
                    SwitchListTile.adaptive(
                      key: const Key('biometric_unlock_switch_tile'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      activeTrackColor: AppColors.brandAccent,
                      secondary: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: (vaultState.isBiometricEnabled && vaultState.hasPin)
                              ? AppColors.brandAccent.withValues(alpha: 0.12)
                              : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          AppIcons.fingerprint,
                          color: (vaultState.isBiometricEnabled && vaultState.hasPin)
                              ? AppColors.brandAccent
                              : theme.colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        l10n.biometricUnlock,
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        !vaultState.hasPin
                            ? l10n.setPinFirstToEnableBiometrics
                            : l10n.biometricUnlockSubtitle,
                        style: AppTypography.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
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
            const SizedBox(height: 20),

            // 4. Home Screen Widget Preview & Customization (Feature F-9)
            _SectionHeader(title: l10n.widgetSettings),
            const SizedBox(height: 8),
            HomeWidgetPreviewCard(key: ValueKey(currentLocale.languageCode)),
            const SizedBox(height: 20),

            // 5. Group: Support, Feedback & Legal
            _SectionHeader(title: LegalConsentLocalization.getTitle(currentLocale.languageCode)),
            const SizedBox(height: 8),
            AppCard(
              borderRadius: AppRadius.card,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Replay Tour Tile
                  _SettingsTile(
                    icon: AppIcons.tour,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    title: l10n.replayTour,
                    subtitle: l10n.onboardingTitle1,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OnboardingScreen(isReplay: true),
                        ),
                      );
                    },
                  ),
                  _buildHairlineDivider(isDark),

                  // Feedback Tile
                  _SettingsTile(
                    icon: AppIcons.bulb,
                    iconColor: AppColors.brandAccent,
                    iconBgColor: AppColors.brandAccent.withValues(alpha: 0.12),
                    title: FeedbackL10n.getTitle(Localizations.localeOf(context).languageCode),
                    subtitle: FeedbackL10n.getSubtitle(Localizations.localeOf(context).languageCode),
                    onTap: () => FeedbackSheet.show(context),
                  ),
                  _buildHairlineDivider(isDark),

                  // Help & FAQ Tile
                  _SettingsTile(
                    icon: AppIcons.help,
                    iconColor: const Color(0xFF0F766E),
                    iconBgColor: const Color(0xFF0F766E).withValues(alpha: 0.12),
                    title: HelpLocalization.getTitle(Localizations.localeOf(context).languageCode),
                    subtitle: HelpLocalization.getSubtitle(Localizations.localeOf(context).languageCode),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HelpScreen()),
                      );
                    },
                  ),
                  _buildHairlineDivider(isDark),

                  // Legal Consent Tile
                  _SettingsTile(
                    icon: AppIcons.legal,
                    iconColor: const Color(0xFF64748B),
                    iconBgColor: const Color(0xFF64748B).withValues(alpha: 0.12),
                    title: LegalConsentLocalization.getTitle(currentLocale.languageCode),
                    subtitle: LegalConsentLocalization.getAcceptedStatus(
                      currentLocale.languageCode,
                      PreferencesService.instance.getLegalConsentVersion(),
                      PreferencesService.instance.getLegalConsentDate(),
                    ),
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
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 6. Group: Account & Authentication Session
            _SectionHeader(title: l10n.accountAndSession),
            const SizedBox(height: 8),
            _AccountSessionCard(isDark: isDark),
            const SizedBox(height: 28),

            // 7. Clean App Version Footer with Logo
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 44),
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

  static Widget _buildHairlineDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 58, right: 14),
      child: Divider(
        height: 0.5,
        thickness: 0.5,
        color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
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
        return AppIcons.cloudSync;
      case SyncStatus.upToDate:
        return AppIcons.cloudDone;
      case SyncStatus.failed:
      case SyncStatus.noInternet:
      case SyncStatus.idle:
        return AppIcons.cloudOff;
    }
  }

  Color _getSyncIconBg(SyncStatus status, ThemeData theme) {
    switch (status) {
      case SyncStatus.syncing:
        return AppColors.brandAccent.withValues(alpha: 0.15);
      case SyncStatus.upToDate:
        return const Color(0xFF10B981).withValues(alpha: 0.15);
      case SyncStatus.failed:
        return AppColors.errorPastel.withValues(alpha: 0.15);
      case SyncStatus.noInternet:
      case SyncStatus.idle:
        return theme.brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF1F5F9);
    }
  }

  Color _getSyncIconColor(SyncStatus status, ThemeData theme) {
    switch (status) {
      case SyncStatus.syncing:
        return AppColors.brandAccent;
      case SyncStatus.upToDate:
        return const Color(0xFF10B981);
      case SyncStatus.failed:
        return AppColors.errorPastel;
      case SyncStatus.noInternet:
      case SyncStatus.idle:
        return theme.colorScheme.onSurfaceVariant;
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

/// Reusable Inset-Grouped Settings Tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        AppHaptics.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 17,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? iconColor).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: (badgeColor ?? iconColor).withValues(alpha: 0.25),
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: AppTypography.caption.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: badgeColor ?? iconColor,
                              letterSpacing: 0.3,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              AppIcons.chevronRight,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Segmented Control for System / Light / Dark theme selection.
/// Replaces clunky mustard-bordered boxes with sleek, responsive Apple-grade tabs.
class _ThemeModeSegmentedControl extends StatelessWidget {
  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onModeChanged;

  const _ThemeModeSegmentedControl({
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.brandAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  AppIcons.sun,
                  size: 17,
                  color: AppColors.brandAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.theme,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                _buildOption(
                  mode: ThemeMode.system,
                  label: l10n.themeSystem,
                  icon: AppIcons.spark,
                  isSelected: selectedMode == ThemeMode.system,
                  isDark: isDark,
                  flex: math.max(10, l10n.themeSystem.length + 6),
                ),
                _buildOption(
                  mode: ThemeMode.light,
                  label: l10n.themeLight,
                  icon: AppIcons.sun,
                  isSelected: selectedMode == ThemeMode.light,
                  isDark: isDark,
                  flex: math.max(10, l10n.themeLight.length + 6),
                ),
                _buildOption(
                  mode: ThemeMode.dark,
                  label: l10n.themeDark,
                  icon: AppIcons.moon,
                  isSelected: selectedMode == ThemeMode.dark,
                  isDark: isDark,
                  flex: math.max(10, l10n.themeDark.length + 6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required ThemeMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () {
          AppHaptics.selectionClick();
          onModeChanged(mode);
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.surfaceRaisedDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: AppColors.brandAccent.withValues(alpha: 0.4),
                    width: 0.8,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? AppColors.brandAccent
                    : (isDark ? Colors.white60 : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Account & Authentication Session Inset Card
class _AccountSessionCard extends ConsumerWidget {
  final bool isDark;

  const _AccountSessionCard({required this.isDark});

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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [AppColors.brandAccent, Color(0xFF2D1810)]
                        : const [AppColors.brandAccent, Color(0xFF4A1E13)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandAccent.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initialLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
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
                      email.isNotEmpty ? email : l10n.signedInTraveler,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.cloudSessionActive,
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFF10B981),
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
