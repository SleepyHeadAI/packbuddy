import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/services/telemetry_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Modal bottom sheet showcasing PackBuddy Pro features and mock subscription plans
class PaywallSheet extends ConsumerWidget {
  const PaywallSheet({super.key});

  static Future<void> show(BuildContext context, {String triggerSource = 'settings'}) {
    TelemetryService.instance.logPaywallViewed(triggerSource: triggerSource);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => const RepaintBoundary(child: PaywallSheet()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final proState = ref.watch(proSubscriptionProvider);
    final currentCurrency = ref.watch(currencyProvider);

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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.tertiaryContainer,
                  theme.colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // Title & Subtitle
          Text(
            l10n.proTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.proSubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Features List
          _ProFeatureRow(
            icon: Icons.luggage_outlined,
            title: l10n.proFeature1,
          ),
          const SizedBox(height: 12),
          _ProFeatureRow(
            icon: Icons.lock_outline_rounded,
            title: l10n.proFeature2,
          ),
          const SizedBox(height: 12),
          _ProFeatureRow(
            icon: Icons.cloud_sync_outlined,
            title: l10n.proFeature3,
          ),
          const SizedBox(height: 24),

          if (proState.isPro) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successPastel.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.successPastel.withValues(alpha: 0.4)),
              ),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${l10n.activePlanLabel}: ${proState.activePlan == SubscriptionPlan.annual ? l10n.annualPlan : l10n.monthlyPlan}',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.ok, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
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
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: proState.isLoading
                    ? null
                    : () async {
                        final authState = ref.read(authControllerProvider);
                        final userEmail = authState.user?.email?.trim().toLowerCase();
                        final isSuperAdmin = userEmail == kAdminEmail.toLowerCase();

                        if (isSuperAdmin) {
                          // Dedicated Admin / Sandbox Test Purchase Confirmation Dialog
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              icon: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: AppColors.primaryLight,
                                size: 36,
                              ),
                              title: Text(l10n.adminTestPurchaseTitle),
                              content: Text(
                                userEmail != null
                                    ? '${l10n.adminTestPurchaseMessage}\n\n($userEmail)'
                                    : l10n.adminTestPurchaseMessage,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(l10n.activateTestPro),
                                ),
                              ],
                            ),
                          );

                          if (confirmed != true) return;

                          final success = await ref
                              .read(proSubscriptionProvider.notifier)
                              .purchaseActivePlan(isTestOrAdminConfirmation: true);
                          if (context.mounted && success) {
                            Navigator.of(context).pop();
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
                          // Normal user: Production store billing required, zero free bypass!
                          final targetProductId = proState.activePlan == SubscriptionPlan.monthly
                              ? MockRevenueCatNotifier.productMonthly
                              : MockRevenueCatNotifier.productAnnual;

                          if (proState.products.containsKey(targetProductId)) {
                            final success = await ref
                                .read(proSubscriptionProvider.notifier)
                                .purchasePlan(targetProductId);
                            if (context.mounted && success) {
                              Navigator.of(context).pop();
                            }
                          } else {
                            if (!context.mounted) return;
                            await showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                icon: const Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.primaryLight,
                                  size: 36,
                                ),
                                title: Text(l10n.storeBillingRequiredTitle),
                                content: Text(l10n.storeBillingRequiredMessage),
                                actions: [
                                  FilledButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text(l10n.ok),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                child: proState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.subscribeNow,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
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

  const _ProFeatureRow({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.star_rounded, color: theme.colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.successPastel,
          size: 18,
        ),
      ],
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
                  style: theme.textTheme.bodySmall?.copyWith(
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
