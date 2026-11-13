import 'package:flutter/material.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';

/// Bento-grid presentation of aggregated travel metrics
class TravelStatsCard extends StatelessWidget {
  final int totalTrips;
  final int totalCountries;
  final int totalItems;
  final int totalDocuments;
  final String languageCode;

  const TravelStatsCard({
    super.key,
    required this.totalTrips,
    required this.totalCountries,
    required this.totalItems,
    required this.totalDocuments,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final worldPercent = ((totalCountries / 195) * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            ProfileLocalization.getTravelStats(languageCode),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildBentoItem(
                context: context,
                icon: Icons.flight_takeoff_rounded,
                iconColor: const Color(0xFF0284C7),
                value: '$totalTrips',
                label: ProfileLocalization.getTotalTrips(languageCode),
                subtitle: languageCode == 'tr' ? 'planlanan rota' : 'planned routes',
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoItem(
                context: context,
                icon: Icons.public_rounded,
                iconColor: const Color(0xFF10B981),
                value: '$totalCountries',
                label: ProfileLocalization.getCountriesVisited(languageCode),
                subtitle: '%$worldPercent (${languageCode == 'tr' ? 'dünya' : 'world'})',
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildBentoItem(
                context: context,
                icon: Icons.checklist_rtl_rounded,
                iconColor: const Color(0xFF8B5CF6),
                value: '$totalItems',
                label: ProfileLocalization.getPackingItems(languageCode),
                subtitle: languageCode == 'tr' ? 'bavul eşyası' : 'luggage items',
                theme: theme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBentoItem(
                context: context,
                icon: Icons.folder_shared_rounded,
                iconColor: const Color(0xFFF59E0B),
                value: '$totalDocuments',
                label: ProfileLocalization.getVaultDocuments(languageCode),
                subtitle: languageCode == 'tr' ? 'şifreli belge' : 'encrypted files',
                theme: theme,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String subtitle,
    required ThemeData theme,
    required bool isDark,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
