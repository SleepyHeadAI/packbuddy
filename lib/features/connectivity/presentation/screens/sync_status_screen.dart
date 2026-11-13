import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/connectivity/presentation/controllers/connectivity_controller.dart';
import 'package:packbuddy/features/connectivity/domain/connectivity_localization.dart';
import 'package:packbuddy/features/connectivity/presentation/screens/widgets/pending_changes_card.dart';
import 'package:packbuddy/features/connectivity/presentation/screens/widgets/sync_history_tile.dart';

/// Screen presenting comprehensive two-way cloud sync telemetry,
/// pending local edits breakdown, manual sync trigger, and diagnostic history logs.
class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(connectivityControllerProvider.notifier).refreshPendingChanges();
      ref.read(connectivityControllerProvider.notifier).loadSyncHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final connState = ref.watch(connectivityControllerProvider);
    final syncEngineState = ref.watch(syncEngineProvider);
    final isSyncing = syncEngineState.status == SyncStatus.syncing;
    final theme = Theme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    final isOnline = connState.isOnline;
    final lastSyncTimeStr = connState.lastSyncTime != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(connState.lastSyncTime!)
        : (langCode == 'tr' ? 'Henüz yapılmadı' : 'Never synced');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sync_rounded,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ),
            Flexible(
              child: Text(
                ConnectivityLocalization.getSyncStatusTitle(langCode),
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: isSyncing
                ? null
                : () {
                    ref.read(connectivityControllerProvider.notifier).triggerManualSync();
                  },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            ConnectivityLocalization.getSyncStatusSubtitle(langCode),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Connection & Last Sync Card
          AppCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                        color: isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOnline
                                ? ConnectivityLocalization.getOnlineStatus(langCode)
                                : ConnectivityLocalization.getOfflineStatus(langCode),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ConnectivityLocalization.getLastSync(langCode)}: $lastSyncTimeStr',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isSyncing
                        ? null
                        : () {
                            ref.read(connectivityControllerProvider.notifier).triggerManualSync();
                          },
                    icon: isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_sync_rounded, size: 18),
                    label: Text(
                      isSyncing
                          ? ConnectivityLocalization.getSyncingBanner(langCode)
                          : ConnectivityLocalization.getSyncNow(langCode),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Pending Changes Breakdown Card
          PendingChangesCard(
            totalPending: connState.pendingChangesCount,
            breakdown: connState.pendingBreakdown,
            languageCode: langCode,
          ),
          const SizedBox(height: 20),

          // 3. Sync Diagnostic History Header & Clear Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ConnectivityLocalization.getSyncHistory(langCode),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (connState.syncHistory.isNotEmpty)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    ref.read(connectivityControllerProvider.notifier).clearSyncHistory();
                  },
                  child: Text(
                    ConnectivityLocalization.getClearHistory(langCode),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // 4. Sync History List or Empty state
          if (connState.syncHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 40,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ConnectivityLocalization.getNoHistory(langCode),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...connState.syncHistory.map(
              (entry) => SyncHistoryTile(
                entry: entry,
                languageCode: langCode,
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
