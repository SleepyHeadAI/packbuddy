import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/features/connectivity/domain/sync_log_entry.dart';

/// Single log tile representing a historical sync attempt
class SyncHistoryTile extends StatelessWidget {
  final SyncLogEntry entry;
  final String languageCode;

  const SyncHistoryTile({
    super.key,
    required this.entry,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('dd.MM.yyyy HH:mm:ss').format(entry.timestamp);

    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    switch (entry.status) {
      case 'upToDate':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_outline_rounded;
        statusTitle = languageCode == 'tr' ? 'Eşleme Başarılı' : 'Sync Succeeded';
        break;
      case 'noInternet':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.wifi_off_rounded;
        statusTitle = languageCode == 'tr' ? 'İnternet Yok' : 'No Internet';
        break;
      case 'failed':
      default:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.error_outline_rounded;
        statusTitle = languageCode == 'tr' ? 'Eşleme Hatası' : 'Sync Error';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, size: 16, color: statusColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          statusTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (entry.itemsSynced > 0)
                    Text(
                      languageCode == 'tr'
                          ? '${entry.itemsSynced} kayıt bulutla eşitlendi'
                          : '${entry.itemsSynced} items synchronized with cloud',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  if (entry.errorMessage != null && entry.errorMessage!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        entry.errorMessage!,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.error,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
