import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/checklist/domain/airline_baggage_guide.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Modal bottom sheet displaying airline baggage allowances and enabling quick limit sync
class AirlineGuideSheet extends ConsumerStatefulWidget {
  const AirlineGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
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
      builder: (context) => const RepaintBoundary(child: AirlineGuideSheet()),
    );
  }

  @override
  ConsumerState<AirlineGuideSheet> createState() => _AirlineGuideSheetState();
}

class _AirlineGuideSheetState extends ConsumerState<AirlineGuideSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customLimitController = TextEditingController();
  String _searchQuery = '';
  List<AirlineBaggageRule> _filteredAirlines = AirlineBaggageRepository.airlines;
  BaggageAllowanceMode _selectedMode = BaggageAllowanceMode.all;

  @override
  void initState() {
    super.initState();
    final current = ref.read(checklistControllerProvider).baggageAllowanceMode;
    _selectedMode = current == BaggageAllowanceMode.none ? BaggageAllowanceMode.all : current;
  }

  void _filterAirlines(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _searchQuery = query;
      if (q.isEmpty) {
        _filteredAirlines = AirlineBaggageRepository.airlines;
      } else {
        _filteredAirlines = AirlineBaggageRepository.airlines.where((airline) {
          return airline.airlineName.toLowerCase().contains(q) ||
              airline.iataCode.toLowerCase().contains(q) ||
              airline.notes.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final checklistState = ref.watch(checklistControllerProvider);
    final selectedAirline = checklistState.selectedAirline;

    final filteredAirlines = _filteredAirlines;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.flight_takeoff_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.airlineBaggageLimits,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.standardBaggageLimitNote,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: TextField(
              controller: _searchController,
              onChanged: _filterAirlines,
              decoration: InputDecoration(
                hintText: l10n.searchAirlineOrCode,
                hintStyle: TextStyle(
                  fontSize: 12.5,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _filterAirlines('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Custom Baggage Limit Quick Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _customLimitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 12.5),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: l10n.customBaggageLimitPrompt,
                        hintStyle: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant),
                        suffixText: 'kg',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilledButton.tonal(
                    onPressed: () {
                      final val = double.tryParse(_customLimitController.text.trim());
                      if (val != null && val > 0 && val <= 100) {
                        final customRule = AirlineBaggageRule(
                          airlineName: '${l10n.customBaggageLimitPrompt} (${val.toStringAsFixed(0)} kg)',
                          iataCode: 'CUSTOM',
                          countryFlag: '✈️',
                          cabinLimitKg: 8.0,
                          cabinDimensions: '55x40x20 cm',
                          checkedLimitKg: val,
                          notes: '${l10n.baggageLimitSet} ${val.toStringAsFixed(0)} kg',
                        );
                        ref.read(checklistControllerProvider.notifier).selectAirline(customRule);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${l10n.baggageLimitSet} ${val.toStringAsFixed(0)} kg'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(l10n.save, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),

          // Allowance Mode Selector: All, Cabin Only, Checked Only, None
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildAllowanceChip(
                    mode: BaggageAllowanceMode.all,
                    label: _getModeChipLabel(BaggageAllowanceMode.all, langCode),
                    icon: Icons.all_inclusive_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildAllowanceChip(
                    mode: BaggageAllowanceMode.cabinOnly,
                    label: _getModeChipLabel(BaggageAllowanceMode.cabinOnly, langCode),
                    icon: Icons.backpack_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildAllowanceChip(
                    mode: BaggageAllowanceMode.checkedOnly,
                    label: _getModeChipLabel(BaggageAllowanceMode.checkedOnly, langCode),
                    icon: Icons.luggage_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.block_rounded, size: 14, color: AppColors.errorPastel),
                    label: Text(
                      _getModeChipLabel(BaggageAllowanceMode.none, langCode),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.errorPastel,
                      ),
                    ),
                    backgroundColor: isDark
                        ? AppColors.errorPastel.withValues(alpha: 0.12)
                        : const Color(0xFFFEE2E2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      side: BorderSide(
                        color: AppColors.errorPastel.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    onPressed: () {
                      ref.read(checklistControllerProvider.notifier).selectAirline(
                        null,
                        mode: BaggageAllowanceMode.none,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_getLimitRemovedNotice(langCode)),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),

          // Airline rules list
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredAirlines.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final airline = filteredAirlines[index];
                final isCurrent = selectedAirline != null &&
                    selectedAirline.iataCode == airline.iataCode;

                return InkWell(
                  onTap: () {
                    ref.read(checklistControllerProvider.notifier).selectAirline(
                      airline,
                      mode: _selectedMode,
                    );
                    Navigator.pop(context);
                    String msg;
                    if (_selectedMode == BaggageAllowanceMode.cabinOnly) {
                      msg = l10n.airlineSelectedMessage('${airline.airlineName} • ${l10n.cabinBaggage}', '${airline.cabinLimitKg.toInt()}');
                    } else if (_selectedMode == BaggageAllowanceMode.checkedOnly) {
                      msg = l10n.airlineSelectedMessage('${airline.airlineName} • ${l10n.checkedBaggage}', '${airline.checkedLimitKg.toInt()}');
                    } else {
                      msg = l10n.airlineSelectedMessage(airline.airlineName, '${airline.checkedLimitKg.toInt()}');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCurrent
                            ? theme.colorScheme.primary
                            : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                        width: isCurrent ? 2 : 1,
                      ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Text(airline.countryFlag, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    airline.airlineName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    airline.iataCode,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l10n.activeLimit,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Allowances Row with equal height
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Cabin Limit Box
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  ref.read(checklistControllerProvider.notifier).selectAirline(
                                    airline,
                                    mode: BaggageAllowanceMode.cabinOnly,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.airlineSelectedMessage('${airline.airlineName} • ${l10n.cabinBaggage}', '${airline.cabinLimitKg.toInt()}'),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isCurrent && checklistState.baggageAllowanceMode == BaggageAllowanceMode.cabinOnly)
                                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                        : (isDark
                                            ? AppColors.surfaceVariantDark
                                            : AppColors.surfaceVariantLight),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (isCurrent && checklistState.baggageAllowanceMode == BaggageAllowanceMode.cabinOnly)
                                          ? theme.colorScheme.primary
                                          : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                                      width: (isCurrent && checklistState.baggageAllowanceMode == BaggageAllowanceMode.cabinOnly) ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.backpack_rounded, size: 14, color: theme.colorScheme.primary),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              l10n.cabinBaggage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${airline.cabinLimitKg.toStringAsFixed(0)} kg',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        airline.cabinDimensions,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Checked Limit Box
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  ref.read(checklistControllerProvider.notifier).selectAirline(
                                    airline,
                                    mode: BaggageAllowanceMode.checkedOnly,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.airlineSelectedMessage('${airline.airlineName} • ${l10n.checkedBaggage}', '${airline.checkedLimitKg.toInt()}'),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isCurrent && checklistState.baggageAllowanceMode == BaggageAllowanceMode.checkedOnly)
                                        ? theme.colorScheme.secondary.withValues(alpha: 0.15)
                                        : (isDark
                                            ? AppColors.surfaceVariantDark
                                            : AppColors.surfaceVariantLight),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (isCurrent && checklistState.baggageAllowanceMode == BaggageAllowanceMode.checkedOnly)
                                          ? theme.colorScheme.secondary
                                          : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                                      width: (isCurrent && checklistState.baggageAllowanceMode == BaggageAllowanceMode.checkedOnly) ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.luggage_rounded, size: 14, color: theme.colorScheme.secondary),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              l10n.checkedBaggage,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${airline.checkedLimitKg.toStringAsFixed(0)} kg',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        l10n.standardEconomy,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Notes text
                      Text(
                        airline.getLocalizedNotes(Localizations.localeOf(context).languageCode),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            ),
          ),
        ],
      ),
    ),
  );
}

  static String _getModeChipLabel(BaggageAllowanceMode mode, String lang) {
    switch (mode) {
      case BaggageAllowanceMode.all:
        if (lang == 'tr') return 'Hepsi (Kabin + Uçak Altı)';
        if (lang == 'de') return 'Alle (Kabine + Aufgabe)';
        if (lang == 'fr') return 'Tous (Cabine + Soute)';
        if (lang == 'es') return 'Todos (Cabina + Bodega)';
        if (lang == 'it') return 'Tutti (Cabina + Stiva)';
        if (lang == 'ru') return 'Все (Ручная кладь + Багаж)';
        if (lang == 'ar') return 'الكل (يدوية + مسجلة)';
        if (lang == 'pt') return 'Todos (Cabine + Porão)';
        if (lang == 'nl') return 'Alles (Handbagage + Ruim)';
        return 'All (Cabin + Checked)';
      case BaggageAllowanceMode.cabinOnly:
        if (lang == 'tr') return 'Sadece Kabin';
        if (lang == 'de') return 'Nur Kabine';
        if (lang == 'fr') return 'Cabine uniquement';
        if (lang == 'es') return 'Solo cabina';
        if (lang == 'it') return 'Solo cabina';
        if (lang == 'ru') return 'Только ручная кладь';
        if (lang == 'ar') return 'حقيبة اليد فقط';
        if (lang == 'pt') return 'Apenas cabine';
        if (lang == 'nl') return 'Alleen handbagage';
        return 'Cabin Only';
      case BaggageAllowanceMode.checkedOnly:
        if (lang == 'tr') return 'Sadece Uçak Altı';
        if (lang == 'de') return 'Nur Aufgabegepäck';
        if (lang == 'fr') return 'Soute uniquement';
        if (lang == 'es') return 'Solo bodega';
        if (lang == 'it') return 'Solo stiva';
        if (lang == 'ru') return 'Только багаж';
        if (lang == 'ar') return 'الأمتعة المسجلة فقط';
        if (lang == 'pt') return 'Apenas porão';
        if (lang == 'nl') return 'Alleen ruimbagage';
        return 'Checked Only';
      case BaggageAllowanceMode.none:
        if (lang == 'tr') return 'Hiçbiri (Limitsiz)';
        if (lang == 'de') return 'Keine (Unbegrenzt)';
        if (lang == 'fr') return 'Aucune (Sans limite)';
        if (lang == 'es') return 'Ninguno (Sin límite)';
        if (lang == 'it') return 'Nessuno (Illimitato)';
        if (lang == 'ru') return 'Нет (Без ограничений)';
        if (lang == 'ar') return 'بدون قيود';
        if (lang == 'pt') return 'Nenhum (Sem limite)';
        if (lang == 'nl') return 'Geen (Onbeperkt)';
        return 'None (No Limit)';
    }
  }

  static String _getLimitRemovedNotice(String lang) {
    if (lang == 'tr') return 'Bagaj limiti kaldırıldı (Limitsiz)';
    if (lang == 'de') return 'Gepäcklimit entfernt (Unbegrenzt)';
    if (lang == 'fr') return 'Limite de bagages supprimée (Illimité)';
    if (lang == 'es') return 'Límite de equipaje eliminado (Sin límite)';
    if (lang == 'it') return 'Limite bagaglio rimosso (Illimitato)';
    if (lang == 'ru') return 'Ограничение веса снято (Без ограничений)';
    if (lang == 'ar') return 'تمت إزالة قيود الأمتعة (غير محدود)';
    if (lang == 'pt') return 'Limite de bagagem removido (Sem limite)';
    if (lang == 'nl') return 'Bagagelimiet verwijderd (Onbeperkt)';
    return 'Baggage limit removed (No limit)';
  }

  Widget _buildAllowanceChip({
    required BaggageAllowanceMode mode,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedMode == mode;
    final selectedBg = isDark ? AppColors.primaryAmber : AppColors.primaryLight;
    final selectedFg = isDark ? const Color(0xFF281C00) : Colors.white;
    final unselectedBg = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    final unselectedFg = isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
    final unselectedIcon = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isSelected
        ? (isDark ? AppColors.primaryAmber : AppColors.primaryLight)
        : (isDark ? AppColors.outlineDark : AppColors.outlineLight);

    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.primaryAmber : AppColors.primaryLight).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? selectedFg : unselectedIcon,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? selectedFg : unselectedFg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
