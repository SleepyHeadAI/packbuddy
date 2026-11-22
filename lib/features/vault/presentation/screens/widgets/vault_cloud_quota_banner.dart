import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Minimal warning band shown at the top of the Vault when the cloud storage
/// quota is exceeded ([SyncState.isCloudQuotaExceeded]). Documents skipped by
/// the backup ([SyncState.quotaSkippedFiles]) remain on the device only.
///
/// Collapses to nothing (with a soft size/fade transition) when the quota is OK.
class VaultCloudQuotaBanner extends ConsumerWidget {
  const VaultCloudQuotaBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExceeded = ref.watch(syncEngineProvider.select((s) => s.isCloudQuotaExceeded));
    final skipped = ref.watch(syncEngineProvider.select((s) => s.quotaSkippedFiles));
    final band = isExceeded
        ? _QuotaCard(key: const ValueKey('vault_cloud_quota_banner'), skipped: skipped)
        : const SizedBox(width: double.infinity);

    // Reduced motion: swap instantly. (AnimatedSize must never get a zero
    // duration — it asserts "mutated in its own performLayout".)
    if (AppMotion.reduceMotionOf(context)) return band;

    const duration = AppMotion.normal;
    return AnimatedSize(
      duration: duration,
      curve: AppMotion.smoothCurve,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        child: band,
      ),
    );
  }
}

class _QuotaCard extends StatelessWidget {
  const _QuotaCard({super.key, required this.skipped});

  final int skipped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final accent = isDark ? AppColors.brandAccentDark : AppColors.warningPastel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.warningContainerDark : AppColors.warningContainerLight,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(color: accent.withValues(alpha: 0.35), width: 0.8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(Icons.cloud_off_rounded, size: 20, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.vaultCloudQuotaTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.vaultCloudQuotaBody(skipped),
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.35,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
