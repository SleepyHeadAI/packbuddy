import 'package:flutter/material.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/connectivity/domain/connectivity_localization.dart';

/// Card presenting real-time breakdown of local SQLite records waiting to be pushed to cloud
class PendingChangesCard extends StatelessWidget {
  final int totalPending;
  final Map<String, int> breakdown;
  final String languageCode;

  const PendingChangesCard({
    super.key,
    required this.totalPending,
    required this.breakdown,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trips = breakdown['trips'] ?? 0;
    final checklist = breakdown['checklist'] ?? 0;
    final expenses = breakdown['expenses'] ?? 0;
    final documents = breakdown['documents'] ?? 0;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (totalPending > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981))
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  totalPending > 0 ? Icons.pending_actions_rounded : Icons.cloud_done_rounded,
                  size: 20,
                  color: totalPending > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ConnectivityLocalization.getPendingChanges(languageCode),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      ConnectivityLocalization.getPendingChangesSummary(languageCode, totalPending),
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
          if (totalPending > 0) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (trips > 0)
                  _buildChip(
                    icon: Icons.flight_takeoff_rounded,
                    label: ConnectivityLocalization.tripsCountLabel(languageCode, trips),
                    theme: theme,
                    isDark: isDark,
                  ),
                if (checklist > 0)
                  _buildChip(
                    icon: Icons.checklist_rounded,
                    label: ConnectivityLocalization.itemsCountLabel(languageCode, checklist),
                    theme: theme,
                    isDark: isDark,
                  ),
                if (expenses > 0)
                  _buildChip(
                    icon: Icons.receipt_long_rounded,
                    label: ConnectivityLocalization.expensesCountLabel(languageCode, expenses),
                    theme: theme,
                    isDark: isDark,
                  ),
                if (documents > 0)
                  _buildChip(
                    icon: Icons.description_rounded,
                    label: ConnectivityLocalization.documentsCountLabel(languageCode, documents),
                    theme: theme,
                    isDark: isDark,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
