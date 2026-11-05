import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/add_packing_item_sheet.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/packing_item_tile.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/smart_templates_sheet.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/airline_guide_sheet.dart';
import 'package:packbuddy/features/checklist/domain/canonical_packing_catalog.dart';
import 'package:packbuddy/core/services/share_service.dart';

/// Principal Flutter UI/UX Checklist & Item Completion Tracking Screen
class ChecklistScreen extends ConsumerStatefulWidget {
  final String? tripId;
  final String? tripTitle;

  const ChecklistScreen({
    super.key,
    this.tripId,
    this.tripTitle,
  });

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isPackingTipDismissed = false;

  final List<String> _categories = [
    'Tümü',
    'Kıyafet',
    'Elektronik',
    'Kişisel Bakım',
    'Belgeler',
    'Aksesuar',
  ];

  @override
  void initState() {
    super.initState();
    // Load checklist items for active context (reloads if switched between trips or global)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentActiveTripId = ref.read(checklistControllerProvider).activeTripId;
      if (currentActiveTripId != widget.tripId || ref.read(checklistControllerProvider).items.isEmpty) {
        ref.read(checklistControllerProvider.notifier).loadItems(tripId: widget.tripId);
      }
    });
  }

  @override
  void deactivate() {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    super.deactivate();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showUndoDeleteSnackBar(PackingItem item) {
    final l10n = AppLocalizations.of(context)!;
    final localizedName = CanonicalPackingCatalog.getLocalizedItemName(
      item.name,
      Localizations.localeOf(context).languageCode,
    );
    final deletedText = '$localizedName ${l10n.deleted}';
    final undoLabel = l10n.undo;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                deletedText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: undoLabel,
          textColor: const Color(0xFFFDE047),
          onPressed: () {
            ref.read(checklistControllerProvider.notifier).restoreItem(item);
          },
        ),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(milliseconds: 2500),
        persist: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final checklistState = ref.watch(checklistControllerProvider);
    final controller = ref.read(checklistControllerProvider.notifier);

    final completionRatio = checklistState.completionRatio;
    final statusColor = completionRatio >= 1.0 && checklistState.totalCount > 0
        ? AppColors.successPastel
        : theme.colorScheme.primary;
    final progressRatio = completionRatio;

    final filteredItems = checklistState.filteredItems;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.tripTitle == null) ...[
                  Hero(
                    tag: 'checklist-hero-badge',
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.luggage_rounded,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
                Hero(
                  tag: widget.tripTitle != null
                      ? 'trip-checklist-title-${widget.tripId}'
                      : 'checklist-hero-title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      widget.tripTitle != null
                          ? '${widget.tripTitle} - ${l10n.luggageAndChecklist}'
                          : l10n.baggageAndChecklist,
                      style: theme.appBarTheme.titleTextStyle ??
                          AppTheme.headlineFont(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            // Collapsible Search Toggle Icon
            IconButton(
              icon: Icon(
                checklistState.isSearchExpanded ? Icons.search_off_rounded : Icons.search_rounded,
                color: checklistState.isSearchExpanded ? theme.colorScheme.primary : null,
              ),
              tooltip: checklistState.isSearchExpanded
                  ? l10n.closeSearch
                  : l10n.searchItems,
              onPressed: () {
                controller.toggleSearchExpanded();
                if (checklistState.isSearchExpanded) {
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                } else {
                  Future.delayed(const Duration(milliseconds: 150), () {
                    _searchFocusNode.requestFocus();
                  });
                }
              },
            ),
            // Smart Packing Templates
            IconButton(
              icon: const Icon(Icons.auto_awesome_rounded),
              tooltip: l10n.readyTemplates,
              onPressed: () => SmartTemplatesSheet.show(context, tripId: widget.tripId),
            ),
            // Social Checklist Share (Feature F-8)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: l10n.shareChecklist,
              onPressed: () {
                ShareService.shareChecklist(
                  tripTitle: widget.tripTitle ?? 'PackBuddy',
                  items: checklistState.items,
                  l10n: l10n,
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => AddPackingItemSheet.show(context, tripId: widget.tripId),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 3,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(l10n.addItem, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          child: CustomScrollView(
            scrollCacheExtent: const ScrollCacheExtent.pixels(600.0),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // 1. Collapsible Instant Search Bar (Animated expansion/collapse)
              SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  child: checklistState.isSearchExpanded
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
                                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (query) => controller.setSearchQuery(query),
                              decoration: InputDecoration(
                                hintText: l10n.searchItemsHint,
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                ),
                                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 20),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          controller.setSearchQuery('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              // 2. Item Completion Progress & Overview Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                        width: 1,
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        final langCode = Localizations.localeOf(context).languageCode;
                        final isTr = langCode.toLowerCase().startsWith('tr');

                        final cardTitle = widget.tripTitle != null
                            ? (isTr ? '${widget.tripTitle} Bavulu' : '${widget.tripTitle} Luggage')
                            : (isTr ? 'Hazırlık Durumu' : 'Packing Status');

                        String airlineTitle;
                        String airlineSubtitle;

                        if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.none) {
                          airlineTitle = isTr ? 'Bagaj Limiti: Belirlenmedi' : 'Baggage Limit: None';
                          airlineSubtitle = isTr ? 'Limitsiz veya sadece kişisel çanta' : 'No limit / personal item only';
                        } else if (checklistState.selectedAirline != null) {
                          final air = checklistState.selectedAirline!;
                          if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.cabinOnly) {
                            airlineTitle = '${air.airlineName} (Kabin)';
                            airlineSubtitle = '${air.countryFlag} Sadece Kabin: ${air.cabinLimitKg.toInt()} kg (${air.cabinDimensions})';
                          } else if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.checkedOnly) {
                            airlineTitle = '${air.airlineName} (Uçak Altı)';
                            airlineSubtitle = '${air.countryFlag} Sadece Uçak Altı: ${air.checkedLimitKg.toInt()} kg';
                          } else {
                            airlineTitle = air.airlineName;
                            airlineSubtitle = '${air.countryFlag} Kabin ${air.cabinLimitKg.toInt()} kg • Kargo ${air.checkedLimitKg.toInt()} kg';
                          }
                        } else {
                          if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.cabinOnly) {
                            airlineTitle = isTr ? 'Standart Kabin Limiti' : 'Standard Cabin Limit';
                            airlineSubtitle = '✈️ Kabin: 8 kg (55x40x20 cm)';
                          } else if (checklistState.baggageAllowanceMode == BaggageAllowanceMode.checkedOnly) {
                            airlineTitle = isTr ? 'Standart Uçak Altı Limiti' : 'Standard Checked Limit';
                            airlineSubtitle = '✈️ Kargo: 20-23 kg';
                          } else {
                            airlineTitle = isTr ? 'Standart Havayolu Limiti' : l10n.airlineBaggageLimits;
                            airlineSubtitle = l10n.standardBaggageLimitNote;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Baggage status icon, title, and Dynamic Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.luggage_rounded, color: statusColor, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cardTitle,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        checklistState.totalCount == 0
                                            ? l10n.noItemsYet
                                            : '${checklistState.packedCount}/${checklistState.totalCount} ${l10n.itemsReady} • %${(completionRatio * 100).toInt()}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Status badge
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        checklistState.totalCount == 0
                                            ? l10n.listEmpty.toUpperCase()
                                            : (completionRatio >= 1.0
                                                ? l10n.completed.toUpperCase()
                                                : l10n.preparing.toUpperCase()),
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Real-time animated progress bar with visible neutral track
                            Stack(
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF232D3B) : const Color(0xFFE2E6EC),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeOutCubic,
                                      width: constraints.maxWidth * progressRatio,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Full-width Airline Baggage Limits & Quick Actions Banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceVariantDark
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.primaryContainerDark
                                              : AppColors.primaryContainerLight.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.flight_takeoff_rounded,
                                          size: 15,
                                          color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              airlineTitle,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.1,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              airlineSubtitle,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w500,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        InkWell(
                                          onTap: () => AirlineGuideSheet.show(context),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.primaryContainerDark
                                                  : AppColors.primaryContainerLight.withValues(alpha: 0.45),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              _getSetActionLabel(langCode),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => SmartTemplatesSheet.show(context, tripId: widget.tripId),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.secondaryContainerDark
                                                  : AppColors.secondaryContainerLight,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: AppColors.secondaryLight,
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.auto_awesome_rounded,
                                                  size: 11,
                                                  color: AppColors.secondaryLight,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _getTemplatesActionLabel(langCode),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.secondaryLight,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),



              // - Dismissible Inline Smart Packing Tip Banner (Space optimized)
              if (!_isPackingTipDismissed)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.tips_and_updates_rounded,
                            color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.packingTip,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _isPackingTipDismissed = true),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close_rounded, size: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 4. Smooth Category Filter Bar with Edge Fading ShaderMask
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 6),
                  child: SizedBox(
                    height: 38,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                            Colors.white,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.04, 0.96, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final categoryLabels = {
                            'Tümü': l10n.allCategories,
                            'Kıyafet': l10n.categoryClothing,
                            'Elektronik': l10n.categoryElectronics,
                            'Kişisel Bakım': l10n.categoryToiletries,
                            'Belgeler': l10n.categoryDocuments,
                            'Aksesuar': l10n.categoryAccessories,
                          };
                          final displayLabel = categoryLabels[category] ?? category;
                          final isSelected = (category == 'Tümü' && checklistState.selectedCategory == null) ||
                              (checklistState.selectedCategory == category);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: ChoiceChip(
                                label: Text(displayLabel),
                                selected: isSelected,
                                selectedColor: theme.colorScheme.primary,
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                backgroundColor: isDark
                                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                                side: BorderSide(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                onSelected: (_) {
                                  controller.setCategoryFilter(category == 'Tümü' ? null : category);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Divider(height: 1),
                ),
              ),

              // 5. Checklist Items List with Dismissible Swipe Gestures
              if (checklistState.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.checklist_rtl_rounded,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            checklistState.searchQuery.isNotEmpty
                                ? l10n.noMatchingItems
                                : l10n.checklistEmpty,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            checklistState.searchQuery.isNotEmpty
                                ? l10n.tryDifferentKeyword
                                : l10n.addFirstItem,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => AddPackingItemSheet.show(context, tripId: widget.tripId),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(l10n.addItem),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(top: 4, bottom: 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredItems[index];
                        return PackingItemTile(
                          item: item,
                          onTap: () => AddPackingItemSheet.show(context, tripId: widget.tripId, itemToEdit: item),
                          onTogglePacked: () => controller.togglePacked(item.id),
                          onUpdateQuantity: (delta) => controller.updateQuantity(item.id, delta),
                          onDelete: () async {
                            final deleted = await controller.deleteItem(item.id);
                            if (deleted != null && mounted) {
                              _showUndoDeleteSnackBar(deleted);
                            }
                          },
                        );
                      },
                      childCount: filteredItems.length,
                      addRepaintBoundaries: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _getSetActionLabel(String lang) {
    if (lang == 'tr') return 'Ayarla';
    if (lang == 'de') return 'Einstellen';
    if (lang == 'fr') return 'Régler';
    if (lang == 'es') return 'Ajustar';
    if (lang == 'it') return 'Imposta';
    if (lang == 'ru') return 'Настроить';
    if (lang == 'ar') return 'ضبط';
    if (lang == 'pt') return 'Ajustar';
    if (lang == 'nl') return 'Instellen';
    return 'Set';
  }

  static String _getTemplatesActionLabel(String lang) {
    if (lang == 'tr') return 'Şablon';
    if (lang == 'de') return 'Vorlagen';
    if (lang == 'fr') return 'Modèles';
    if (lang == 'es') return 'Plantillas';
    if (lang == 'it') return 'Modelli';
    if (lang == 'ru') return 'Шаблоны';
    if (lang == 'ar') return 'قوالب';
    if (lang == 'pt') return 'Modelos';
    if (lang == 'nl') return 'Sjablonen';
    return 'Templates';
  }
}
