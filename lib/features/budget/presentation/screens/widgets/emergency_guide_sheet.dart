import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:flutter/services.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/domain/emergency_guide.dart';
import 'package:packbuddy/features/budget/domain/budget_localization.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/core/widgets/legal_disclaimer_card.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class EmergencyGuideSheet extends StatefulWidget {
  final Trip trip;

  const EmergencyGuideSheet({super.key, required this.trip});

  static Future<void> show(BuildContext context, Trip trip) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EmergencyGuideSheet(trip: trip),
    );
  }

  @override
  State<EmergencyGuideSheet> createState() => _EmergencyGuideSheetState();
}

class _EmergencyGuideSheetState extends State<EmergencyGuideSheet> {
  int _selectedCountryIndex = 0;

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label: $text • ${l10n.emergencyCopied}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getCountryDisplayName(EmergencyGuide guide, BuildContext context, AppLocalizations l10n) {
    final c = Country.findByCode(guide.countryCode);
    if (c != null) {
      final lang = Localizations.localeOf(context).languageCode;
      return c.getLocalizedName(lang);
    }
    return guide.countryName;
  }

  String _getCountryFlag(EmergencyGuide guide) {
    final c = Country.findByCode(guide.countryCode);
    return c?.flag ?? '🌐';
  }

  String _getPhraseLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'phraseHello':
        return l10n.phraseHello;
      case 'phraseThankYou':
        return l10n.phraseThankYou;
      case 'phraseHowMuch':
        return l10n.phraseHowMuch;
      case 'phraseHelp':
        return l10n.phraseHelp;
      case 'phraseHospital':
        return l10n.phraseHospital;
      case 'phraseEnglish':
        return l10n.phraseEnglish;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final allGuides = EmergencyGuide.forTrip(widget.trip);
    final selectedIndex = _selectedCountryIndex < allGuides.length ? _selectedCountryIndex : 0;
    final guide = allGuides[selectedIndex];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.sheetRadius,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorPastel.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sos_rounded, color: AppColors.errorPastel, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.emergencyGuideTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        allGuides.length > 1
                            ? '${_getCountryFlag(guide)} ${_getCountryDisplayName(guide, context, l10n)} (${guide.countryCode}) · ${BudgetLocalization.countriesCovered(l10n.localeName, allGuides.length)}'
                            : '${_getCountryFlag(guide)} ${_getCountryDisplayName(guide, context, l10n)} (${guide.countryCode})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Multi-country selector tabs if trip spans multiple countries
          if (allGuides.length > 1) ...[
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allGuides.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                itemBuilder: (ctx, idx) {
                  final g = allGuides[idx];
                  final isSelected = idx == selectedIndex;
                  final flag = _getCountryFlag(g);
                  final name = _getCountryDisplayName(g, context, l10n);
                  return ChoiceChip(
                    avatar: Text(flag, style: const TextStyle(fontSize: 14)),
                    label: Text(
                      '$name (${g.countryCode})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.errorPastel,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCountryIndex = idx);
                    },
                  );
                },
              ),
            ),
          ],

          const Divider(height: 1),

          // Content
          Flexible(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Legal Liability Disclaimer Banner
                const LegalDisclaimerBanner.emergency(
                  margin: EdgeInsets.only(bottom: 16),
                ),

                // Emergency Numbers Section
                Text(
                  l10n.emergencyGeneralSos,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // 2x2 Grid for emergency numbers
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberTile(
                        context,
                        label: l10n.emergencyGeneralSos,
                        number: guide.generalSos,
                        icon: Icons.emergency_rounded,
                        color: AppColors.errorPastel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildNumberTile(
                        context,
                        label: l10n.emergencyPolice,
                        number: guide.police,
                        icon: Icons.local_police_rounded,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberTile(
                        context,
                        label: l10n.emergencyAmbulance,
                        number: guide.ambulance,
                        icon: Icons.medical_services_rounded,
                        color: const Color(0xFF388E3C),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildNumberTile(
                        context,
                        label: l10n.emergencyFire,
                        number: guide.fire,
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFFF57C00),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Power Plugs & Electricity Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.power_rounded, color: theme.colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.emergencyPowerPlugs,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              guide.powerPlugs,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Essential Phrases Section
                Row(
                  children: [
                    Icon(Icons.record_voice_over_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.emergencyPhrases,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...guide.phrases.map((phrase) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getPhraseLabel(phrase.key, l10n),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                phrase.phrase,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (phrase.pronunciation.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '/${phrase.pronunciation}/',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          tooltip: l10n.emergencyCopyTooltip,
                          onPressed: () => _copyToClipboard(context, phrase.phrase, _getPhraseLabel(phrase.key, l10n)),
                        ),
                      ],
                    ),
                  );
                }),
                if (allGuides.length > 1) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.public_rounded, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        BudgetLocalization.allTripDestinations(l10n.localeName, allGuides.length),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...allGuides.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final g = entry.value;
                    final isCurrent = idx == selectedIndex;
                    final flag = _getCountryFlag(g);
                    final name = _getCountryDisplayName(g, context, l10n);

                    return InkWell(
                      onTap: () {
                        setState(() => _selectedCountryIndex = idx);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.errorPastel.withValues(alpha: 0.12)
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.errorPastel.withValues(alpha: 0.5)
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            width: isCurrent ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(flag, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$name (${g.countryCode})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: isCurrent ? AppColors.errorPastel : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorPastel,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      l10n.activeStatus,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildQuickSosChip(context, l10n.emergencyGeneralSos, g.generalSos, AppColors.errorPastel),
                                _buildQuickSosChip(context, l10n.emergencyPolice, g.police, const Color(0xFF1976D2)),
                                _buildQuickSosChip(context, l10n.emergencyAmbulance, g.ambulance, const Color(0xFF388E3C)),
                                _buildQuickSosChip(context, l10n.emergencyFire, g.fire, const Color(0xFFF57C00)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSosChip(BuildContext context, String label, String number, Color color) {
    return InkWell(
      onTap: () => _copyToClipboard(context, number, label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: color),
            ),
            Text(
              number,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberTile(
    BuildContext context, {
    required String label,
    required String number,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _copyToClipboard(context, number, label),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.copy_rounded, size: 14, color: color.withValues(alpha: 0.7)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              number,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
