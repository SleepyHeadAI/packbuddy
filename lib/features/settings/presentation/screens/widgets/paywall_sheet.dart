import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:packbuddy/core/l10n/app_l10n_lookup.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/services/legal_consent_localization.dart';
import 'package:packbuddy/core/services/telemetry_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_typography.dart';
import 'package:packbuddy/shared/widgets/app_button.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Modal bottom sheet showcasing PackBuddy Pro features and mock subscription plans
class PaywallSheet extends ConsumerWidget {
  final String triggerSource;
  final String? highlightFeature;

  const PaywallSheet({
    super.key,
    this.triggerSource = 'settings',
    this.highlightFeature,
  });

  static Future<void> show(
    BuildContext context, {
    String triggerSource = 'settings',
    String? highlightFeature,
  }) {
    TelemetryService.instance.logPaywallViewed(
      triggerSource: triggerSource,
      highlightFeature: highlightFeature,
    );
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => RepaintBoundary(
        child: PaywallSheet(
          triggerSource: triggerSource,
          highlightFeature: highlightFeature,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final proState = ref.watch(proSubscriptionProvider);
    final currentCurrency = ref.watch(currencyProvider);

    // Contextual Dynamic Headline & Subtitle based on triggered feature gate
    final String sheetTitle;
    final String sheetSubtitle;

    if (highlightFeature == 'trip_limit' || triggerSource == 'trip_limit') {
      sheetTitle = l10n.proTripLimitTitle;
      sheetSubtitle = l10n.proTripLimitSubtitle;
    } else if (highlightFeature == 'vault_limit' || triggerSource == 'vault_limit') {
      sheetTitle = l10n.proVaultLimitTitle;
      sheetSubtitle = l10n.proVaultLimitSubtitle;
    } else if (highlightFeature == 'itinerary_limit' || triggerSource == 'itinerary_limit') {
      sheetTitle = l10n.proItineraryLimitTitle;
      sheetSubtitle = l10n.proItineraryLimitSubtitle;
    } else if (highlightFeature == 'theme_locked' ||
        triggerSource == 'theme_locked' ||
        triggerSource == 'story_theme_locked' ||
        triggerSource == 'story_layout_locked' ||
        triggerSource == 'widget_theme_locked') {
      sheetTitle = l10n.proThemeLockedTitle;
      sheetSubtitle = l10n.proThemeLockedSubtitle;
    } else if (highlightFeature == 'export_locked' || triggerSource == 'export_locked') {
      sheetTitle = l10n.proExportLockedTitle;
      sheetSubtitle = l10n.proExportLockedSubtitle;
    } else {
      sheetTitle = l10n.proTitle;
      sheetSubtitle = l10n.proSubtitle;
    }

    // Affordable, localized micro-subscription tiers adapting cleanly to user currency
    final String fallbackMonthlyPriceText;
    final String fallbackAnnualPriceText;
    final String fallbackAnnualSubPriceText;

    switch (currentCurrency.toUpperCase()) {
      case 'TRY':
        fallbackMonthlyPriceText = '₺29,99 ${l10n.perMonth}';
        fallbackAnnualPriceText = '₺149,99 ${l10n.perYear}';
        fallbackAnnualSubPriceText = '~₺12,50 ${l10n.perMonth}';
        break;
      case 'EUR':
        fallbackMonthlyPriceText = '€0,99 ${l10n.perMonth}';
        fallbackAnnualPriceText = '€4,99 ${l10n.perYear}';
        fallbackAnnualSubPriceText = '~€0,41 ${l10n.perMonth}';
        break;
      case 'GBP':
        fallbackMonthlyPriceText = '£0.89 ${l10n.perMonth}';
        fallbackAnnualPriceText = '£4.49 ${l10n.perYear}';
        fallbackAnnualSubPriceText = '~£0.37 ${l10n.perMonth}';
        break;
      case 'JPY':
        fallbackMonthlyPriceText = '¥150 ${l10n.perMonth}';
        fallbackAnnualPriceText = '¥750 ${l10n.perYear}';
        fallbackAnnualSubPriceText = '~¥62 ${l10n.perMonth}';
        break;
      case 'AUD':
        fallbackMonthlyPriceText = 'A\$1.49 ${l10n.perMonth}';
        fallbackAnnualPriceText = 'A\$7.49 ${l10n.perYear}';
        fallbackAnnualSubPriceText = '~A\$0.62 ${l10n.perMonth}';
        break;
      case 'CAD':
        fallbackMonthlyPriceText = 'CA\$1.39 ${l10n.perMonth}';
        fallbackAnnualPriceText = 'CA\$6.99 ${l10n.perYear}';
        fallbackAnnualSubPriceText = '~CA\$0.58 ${l10n.perMonth}';
        break;
      case 'USD':
      default:
        fallbackMonthlyPriceText = '\$0.99 ${l10n.perMonth}';
        fallbackAnnualPriceText = '\$4.99 ${l10n.perYear}';
        fallbackAnnualSubPriceText = '~\$0.41 ${l10n.perMonth}';
        break;
    }

    final monthlyPriceText = proState.monthlyProduct != null
        ? '${proState.monthlyProduct!.price} ${l10n.perMonth}'
        : fallbackMonthlyPriceText;
    final annualPriceText = proState.annualProduct != null
        ? '${proState.annualProduct!.price} ${l10n.perYear}'
        : fallbackAnnualPriceText;
    final annualSubPriceText = fallbackAnnualSubPriceText;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          top: 12,
          left: 20,
          right: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          // Drag Handle
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),

          // Pro Crown / Star Badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryContainerDark : AppColors.primaryContainerLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // Title & Subtitle (Contextual or default)
          Text(
            sheetTitle,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sheetSubtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Features List (Strict 1:1 Matched to Real Pro Entitlements)
          _ProFeatureRow(
            icon: Icons.luggage_outlined,
            title: l10n.proFeature1,
            isHighlighted: highlightFeature == 'trip_limit' || triggerSource == 'trip_limit',
            highlightBadge: l10n.proFeatureHighlightedBadge,
          ),
          const SizedBox(height: 10),
          _ProFeatureRow(
            icon: Icons.cloud_sync_outlined,
            title: l10n.proFeature2,
            isHighlighted: highlightFeature == 'vault_limit' || triggerSource == 'vault_limit',
            highlightBadge: l10n.proFeatureHighlightedBadge,
          ),
          const SizedBox(height: 10),
          _ProFeatureRow(
            icon: Icons.auto_awesome_rounded,
            title: l10n.proFeature3,
            isHighlighted: highlightFeature == 'theme_locked' ||
                triggerSource == 'theme_locked' ||
                triggerSource == 'story_theme_locked' ||
                triggerSource == 'story_layout_locked',
            highlightBadge: l10n.proFeatureHighlightedBadge,
          ),
          const SizedBox(height: 10),
          _ProFeatureRow(
            icon: Icons.widgets_outlined,
            title: l10n.proFeature4,
            isHighlighted: highlightFeature == 'widget_theme_locked' || triggerSource == 'widget_theme_locked',
            highlightBadge: l10n.proFeatureHighlightedBadge,
          ),
          const SizedBox(height: 10),
          _ProFeatureRow(
            icon: Icons.calendar_today_outlined,
            title: l10n.proFeature5,
            isHighlighted: highlightFeature == 'itinerary_limit' || triggerSource == 'itinerary_limit',
            highlightBadge: l10n.proFeatureHighlightedBadge,
          ),
          const SizedBox(height: 10),
          _ProFeatureRow(
            icon: Icons.file_download_outlined,
            title: l10n.proFeature6,
            isHighlighted: highlightFeature == 'export_locked' || triggerSource == 'export_locked',
            highlightBadge: l10n.proFeatureHighlightedBadge,
          ),
          const SizedBox(height: 24),

          if (proState.isPro) ...[
            AppCard(
              padding: const EdgeInsets.all(16),
              borderRadius: AppRadius.card,
              border: BorderSide(color: AppColors.successPastel.withValues(alpha: 0.4)),
              backgroundColor: AppColors.successPastel.withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.successPastel, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.proActive,
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${l10n.activePlanLabel}: ${proState.activePlan == SubscriptionPlan.annual ? l10n.annualPlan : l10n.monthlyPlan}',
                          style: AppTypography.caption.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              onPressed: () => Navigator.of(context).pop(),
              label: l10n.ok,
              isExpanded: true,
              size: AppButtonSize.large,
            ),
          ] else ...[
            // Subscription Plan Selector (Annual vs Monthly)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _PlanOptionCard(
                      title: l10n.annual,
                      price: annualPriceText,
                      subPrice: annualSubPriceText,
                      badge: l10n.annualSave,
                      isSelected: proState.activePlan == SubscriptionPlan.annual,
                      onTap: () {
                        ref.read(proSubscriptionProvider.notifier).selectPlan(SubscriptionPlan.annual);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PlanOptionCard(
                      title: l10n.monthly,
                      price: monthlyPriceText,
                      subPrice: null,
                      badge: null,
                      isSelected: proState.activePlan == SubscriptionPlan.monthly,
                      onTap: () {
                        ref.read(proSubscriptionProvider.notifier).selectPlan(SubscriptionPlan.monthly);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subscribe / Purchase Action Button
            AppButton.primary(
              onPressed: proState.isLoading
                  ? null
                  : () async {
                      final authState = ref.read(authControllerProvider);
                      final userEmail = authState.user?.email?.trim().toLowerCase();
                      // Sandbox/test purchase dialog only in debug builds (release always uses Google Play).
                      final isSuperAdmin = kDebugMode && userEmail == kAdminEmail.toLowerCase();

                      if (isSuperAdmin) {
                        // Dedicated Admin / Sandbox Test Purchase Confirmation Dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
                            backgroundColor: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
                            icon: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: AppColors.primaryLight,
                              size: 36,
                            ),
                            title: Text(
                              l10n.adminTestPurchaseTitle,
                              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                            ),
                            content: Text(
                              userEmail != null
                                  ? '${l10n.adminTestPurchaseMessage}\n\n($userEmail)'
                                  : l10n.adminTestPurchaseMessage,
                              style: AppTypography.bodyMedium,
                            ),
                            actions: [
                              AppButton.outline(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                label: l10n.cancel,
                              ),
                              AppButton.primary(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                label: l10n.activateTestPro,
                              ),
                            ],
                          ),
                        );

                        if (confirmed != true) return;

                        final success = await ref
                            .read(proSubscriptionProvider.notifier)
                            .purchaseActivePlan(isTestOrAdminConfirmation: true);
                        if (context.mounted && success) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(l10n.purchaseSuccess)),
                                ],
                              ),
                              backgroundColor: AppColors.successPastel,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      } else {
                        // Normal user: Trigger real Google Play / App Store purchase flow directly!
                        final success = await ref
                            .read(proSubscriptionProvider.notifier)
                            .purchaseActivePlan();

                        if (!context.mounted) return;

                        if (success) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(l10n.purchaseSuccess)),
                                ],
                              ),
                              backgroundColor: AppColors.successPastel,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        } else {
                          final errorMsg = ref.read(proSubscriptionProvider).errorMessage;
                          if (errorMsg != null && errorMsg.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      localizeUserError(l10n, errorMsg),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: theme.colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      }
                    }
                  },
              isLoading: proState.isLoading,
              label: l10n.subscribeNow,
              isExpanded: true,
              size: AppButtonSize.large,
            ),
            const SizedBox(height: 10),

            // Pre-purchase subscription disclosure (auto-renewal & cancellation via Google Play)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                l10n.subscriptionAutoRenewNotice,
                key: const Key('paywall_auto_renew_notice'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Restore Purchases Action (Required by Apple App Store & Google Play Store)
            TextButton(
              onPressed: proState.isLoading
                  ? null
                  : () async {
                      final success = await ref
                          .read(proSubscriptionProvider.notifier)
                          .restorePurchases();
                      if (!context.mounted) return;
                      if (success) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 12),
                                Expanded(child: Text(l10n.restorePurchasesSuccess)),
                              ],
                            ),
                            backgroundColor: AppColors.successPastel,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.restoreNoPurchasesFound),
                            backgroundColor: theme.colorScheme.onSurfaceVariant,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
              child: Text(
                l10n.restorePurchases,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Legal links (Terms of Service & Privacy Policy)
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GestureDetector(
                  key: const Key('paywall_terms_link'),
                  onTap: () async {
                    final uri = Uri.parse(LegalConsentLocalization.termsOfServiceUrl);
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {}
                  },
                  child: Text(
                    LegalConsentLocalization.getTermsLink(Localizations.localeOf(context).languageCode),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  ' • ',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  key: const Key('paywall_privacy_link'),
                  onTap: () async {
                    final uri = Uri.parse(LegalConsentLocalization.privacyPolicyUrl);
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {}
                  },
                  child: Text(
                    LegalConsentLocalization.getPrivacyPolicyLink(Localizations.localeOf(context).languageCode),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  ),
);
}
}

class _ProFeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isHighlighted;
  final String? highlightBadge;

  const _ProFeatureRow({
    required this.icon,
    required this.title,
    this.isHighlighted = false,
    this.highlightBadge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(
        horizontal: isHighlighted ? 10 : 0,
        vertical: isHighlighted ? 8 : 0,
      ),
      decoration: BoxDecoration(
        color: isHighlighted
            ? (isDark
                ? AppColors.primaryAmber.withValues(alpha: 0.12)
                : AppColors.brandAccent.withValues(alpha: 0.12))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: isHighlighted
            ? Border.all(
                color: isDark ? AppColors.primaryAmber : AppColors.brandAccent,
                width: 1.4,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? (isDark ? AppColors.primaryAmber.withValues(alpha: 0.25) : AppColors.brandAccent.withValues(alpha: 0.25))
                  : (isDark ? AppColors.surfaceRaisedDark : AppColors.primaryContainerLight.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(AppRadius.xs),
              border: Border.all(
                color: isHighlighted
                    ? (isDark ? AppColors.primaryAmber : AppColors.brandAccent)
                    : (isDark ? AppColors.borderSubtle(true) : AppColors.borderSubtle(false)),
              ),
            ),
            child: Icon(
              icon,
              color: isHighlighted
                  ? (isDark ? AppColors.primaryAmber : AppColors.brandAccentTextLight)
                  : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
                    color: isHighlighted
                        ? (isDark ? Colors.white : AppColors.brandAccentTextLight)
                        : null,
                  ),
                ),
                if (isHighlighted && highlightBadge != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryAmber.withValues(alpha: 0.2) : AppColors.brandAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      highlightBadge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.primaryAmber : AppColors.brandAccentTextLight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: isHighlighted ? AppColors.primaryAmber : AppColors.successPastel,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _PlanOptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String? subPrice;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanOptionCard({
    required this.title,
    required this.price,
    this.subPrice,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        AppHaptics.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceLight)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceRaisedLight),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                : (isDark ? AppColors.borderSubtle(true) : AppColors.borderSubtle(false)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceRaisedDark : AppColors.brandAccent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: isDark ? AppColors.borderSubtle(true) : AppColors.brandAccent.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          badge!,
                          maxLines: 1,
                          style: TextStyle(
                            color: isDark ? AppColors.brandAccent : AppColors.brandAccentTextLight,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                price,
                style: AppTypography.mono(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  tabularFigures: true,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (subPrice != null) ...[
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subPrice!,
                  style: AppTypography.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    tabularFigures: true,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
