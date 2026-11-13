import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/connectivity/presentation/controllers/connectivity_controller.dart';
import 'package:packbuddy/features/connectivity/domain/connectivity_localization.dart';
import 'package:packbuddy/features/connectivity/presentation/screens/sync_status_screen.dart';

/// Serene Voyage persistent connectivity & sync banner displaying network status,
/// active synchronizations, and quick access to diagnostic sync logs.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncEngineProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    final status = syncState.status;

    // Silent & Clean mode: Do NOT show top banner during regular syncing.
    // Banner only shows when truly offline (no internet) or if sync failed.
    final bool isVisible = status == SyncStatus.noInternet ||
        status == SyncStatus.failed;

    if (!isVisible) {
      return const SizedBox.shrink();
    }

    Color bannerBg;
    Color bannerFg;
    IconData icon;
    String message;
    Widget? trailingAction;

    switch (status) {
      case SyncStatus.noInternet:
        bannerBg = isDark ? const Color(0xFF422006) : const Color(0xFFFEF3C7);
        bannerFg = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
        icon = Icons.wifi_off_rounded;
        message = ConnectivityLocalization.getOfflineBanner(langCode);
        break;

      case SyncStatus.failed:
        bannerBg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
        bannerFg = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
        icon = Icons.cloud_off_rounded;
        message = ConnectivityLocalization.getSyncFailedBanner(langCode);
        trailingAction = InkWell(
          onTap: () {
            ref.read(connectivityControllerProvider.notifier).triggerManualSync();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bannerFg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ConnectivityLocalization.getRetry(langCode),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: bannerFg,
              ),
            ),
          ),
        );
        break;

      default:
        return const SizedBox.shrink();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      child: Material(
        color: bannerBg,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SyncStatusScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: bannerFg.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: true,
              bottom: false,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: bannerFg),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: bannerFg,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailingAction != null) ...[
                    const SizedBox(width: 8),
                    trailingAction,
                  ] else ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: bannerFg.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
