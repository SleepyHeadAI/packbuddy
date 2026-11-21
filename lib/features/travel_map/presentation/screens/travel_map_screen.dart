import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/theme/app_typography.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/interactive_world_map.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/travel_map_story_card.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/country_flag.dart';
import 'package:packbuddy/core/services/app_widget_localization.dart';
import 'package:packbuddy/core/services/pro_entitlement_service.dart';
import 'package:packbuddy/core/services/telemetry_service.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_animations.dart';
import 'package:packbuddy/shared/widgets/app_button.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Full-screen interactive world travel map and country tracker
class TravelMapScreen extends ConsumerStatefulWidget {
  final bool isTabMode;

  const TravelMapScreen({
    super.key,
    this.isTabMode = false,
  });

  @override
  ConsumerState<TravelMapScreen> createState() => _TravelMapScreenState();
}

class _TravelMapScreenState extends ConsumerState<TravelMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSharingStory = false;
  bool _isMapInteracting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(travelMapControllerProvider.notifier).loadCountries();
      ref.read(travelMapControllerProvider.notifier).setFilter('all');
      ref.read(travelMapControllerProvider.notifier).setSearchQuery('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _sharePassportText(int visitedCount, double percentage, int continentsCount) async {
    final l10n = AppLocalizations.of(context);
    final text = '🌍 PackBuddy ${l10n?.worldTravelMapTitle ?? "World Travel Map"}:\n'
        '• $visitedCount ${l10n?.countryUnit ?? "countries"} ✈️\n'
        '• $continentsCount ${l10n?.continentsUnit ?? "continents"} 🗺️\n'
        '• ${(l10n?.localeName ?? "").startsWith("tr") ? "%${percentage.toStringAsFixed(1)}" : "${percentage.toStringAsFixed(1)}%"} ${l10n?.ofTheWorld ?? "of the world"}!\n\n'
        'PackBuddy';
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'PackBuddy ${l10n?.worldTravelMapTitle ?? "World Travel Map"}',
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.passportSummaryShared ?? 'Passport summary ready to share!')),
        );
      }
    }
  }

  Future<void> _shareStoryImage(GlobalKey boundaryKey, StateSetter setModalState) async {
    final l10n = AppLocalizations.of(context);
    setModalState(() {
      _isSharingStory = true;
    });
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/packbuddy_story_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: '🌍 PackBuddy ${l10n?.worldTravelMapTitle ?? "World Travel Map"}',
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.authErrorGeneric ?? 'Action failed')),
        );
      }
    } finally {
      if (mounted) {
        setModalState(() {
          _isSharingStory = false;
        });
      }
    }
  }

  void _openStoryShareModal(TravelMapState mapState, int visitedContinentsCount) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final isPro = ref.read(proSubscriptionProvider).isPro;
    final storyKey = GlobalKey();
    StoryCardLayout selectedLayout = StoryCardLayout.classic;
    StoryCardTheme selectedTheme = StoryCardTheme.midnight;
    int selectedThemeCategory = selectedTheme.isLight ? 1 : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 220),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.92,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.shareStoryPreview,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.shareStorySubtitle,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // 1. Layout Template Selector Bar (4 Options)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: StoryCardLayout.values.map((l) {
                            final isSelected = l == selectedLayout;
                            final isLocked = !ProFeatureGate.canUseStoryLayout(isPro: isPro, layout: l);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  if (isLocked) {
                                    TelemetryService.instance.logProGateHit(
                                      featureKey: 'story_layout_locked',
                                      context: l.name,
                                    );
                                    PaywallSheet.show(
                                      context,
                                      triggerSource: 'story_layout_locked',
                                      highlightFeature: 'theme_locked',
                                    );
                                    return;
                                  }
                                  setModalState(() {
                                    selectedLayout = l;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6.5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.brandAccent
                                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.brandAccent
                                          : (isDark ? Colors.white12 : Colors.black12),
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.brandAccent.withValues(alpha: 0.35),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        l.icon,
                                        size: 13.5,
                                        color: isSelected
                                            ? const Color(0xFF101010)
                                            : (isDark ? Colors.white70 : Colors.black87),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        l.getLocalizedName(
                                          l10n,
                                          locale: Localizations.localeOf(context).languageCode,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFF101010)
                                              : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                      ),
                                      if (isLocked) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.workspace_premium_rounded,
                                          size: 12,
                                          color: AppColors.primaryAmber,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // 2. Theme Category Tabs: [ 🌙 Dark (9) ]  [ ☀️ Light (7) ]
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setModalState(() {
                                  selectedThemeCategory = 0;
                                  if (selectedTheme.isLight) {
                                    selectedTheme = StoryCardTheme.values.firstWhere((t) => t.isDark);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: selectedThemeCategory == 0
                                      ? (isDark ? Colors.white.withValues(alpha: 0.16) : const Color(0xFF0F172A))
                                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedThemeCategory == 0
                                        ? AppColors.brandAccent
                                        : (isDark ? Colors.white12 : Colors.black12),
                                    width: selectedThemeCategory == 0 ? 1.5 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          AppIcons.moon,
                                          size: 12,
                                          color: selectedThemeCategory == 0
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${AppWidgetLocalization.getDarkThemesCategory(lang)} (9)',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: selectedThemeCategory == 0 ? FontWeight.w800 : FontWeight.w600,
                                            color: selectedThemeCategory == 0
                                                ? Colors.white
                                                : (isDark ? Colors.white70 : Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setModalState(() {
                                  selectedThemeCategory = 1;
                                  if (selectedTheme.isDark) {
                                    selectedTheme = StoryCardTheme.values.firstWhere((t) => t.isLight);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: selectedThemeCategory == 1
                                      ? AppColors.brandAccent
                                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedThemeCategory == 1
                                        ? AppColors.brandAccent
                                        : (isDark ? Colors.white12 : Colors.black12),
                                    width: selectedThemeCategory == 1 ? 1.5 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          AppIcons.sun,
                                          size: 12,
                                          color: selectedThemeCategory == 1
                                              ? const Color(0xFF101010)
                                              : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${AppWidgetLocalization.getLightThemesCategory(lang)} (7)',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: selectedThemeCategory == 1 ? FontWeight.w800 : FontWeight.w600,
                                            color: selectedThemeCategory == 1
                                                ? const Color(0xFF101010)
                                                : (isDark ? Colors.white70 : Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Theme / Palette Selector Bar (Filtered by category)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: StoryCardTheme.values
                              .where((t) => selectedThemeCategory == 0 ? t.isDark : t.isLight)
                              .map((t) {
                            final palette = StoryCardPalette.forTheme(
                              t,
                              locale: lang,
                              l10n: l10n,
                            );
                            final isSelected = t == selectedTheme;
                            final isLocked = !ProFeatureGate.canUseStoryTheme(isPro: isPro, theme: t);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  if (isLocked) {
                                    TelemetryService.instance.logProGateHit(
                                      featureKey: 'story_theme_locked',
                                      context: t.name,
                                    );
                                    PaywallSheet.show(
                                      context,
                                      triggerSource: 'story_theme_locked',
                                      highlightFeature: 'theme_locked',
                                    );
                                    return;
                                  }
                                  setModalState(() {
                                    selectedTheme = t;
                                    selectedThemeCategory = t.isLight ? 1 : 0;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.brandAccent
                                          : (isDark ? Colors.white12 : Colors.black12),
                                      width: isSelected ? 1.8 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.brandAccent.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Palette preview swatch circles
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: palette.previewColors.map((c) {
                                          return Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.only(right: 2.5),
                                            decoration: BoxDecoration(
                                              color: c,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? (isDark ? Colors.black26 : Colors.white)
                                                    : Colors.white30,
                                                width: 0.8,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        palette.label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected
                                              ? (isDark ? Colors.black : Colors.white)
                                              : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                      ),
                                      if (isLocked) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.workspace_premium_rounded,
                                          size: 12,
                                          color: AppColors.primaryAmber,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Story Card Scaled Preview
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: RepaintBoundary(
                              key: storyKey,
                              child: TravelMapStoryCard(
                                countries: mapState.countries,
                                totalVisited: mapState.totalVisited,
                                totalLived: mapState.totalLived,
                                totalWishlist: mapState.totalWishlist,
                                worldPercentage: mapState.worldPercentage,
                                continentsCount: visitedContinentsCount,
                                theme: selectedTheme,
                                layout: selectedLayout,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Story Share Primary Button (Phase 1 Token)
                          AppButton.primary(
                            label: _isSharingStory ? l10n.generatingStoryImage : l10n.shareImageButton,
                            leadingIcon: Icons.camera_alt_rounded,
                            size: AppButtonSize.large,
                            isExpanded: true,
                            isLoading: _isSharingStory,
                            onPressed: _isSharingStory
                                ? null
                                : () => _shareStoryImage(storyKey, setModalState),
                          ),
                          const SizedBox(height: 8),

                          // Text Share Secondary Button
                          AppButton.ghost(
                            label: l10n.shareTextButton,
                            leadingIcon: Icons.text_snippet_outlined,
                            size: AppButtonSize.medium,
                            isExpanded: true,
                            onPressed: () {
                              Navigator.pop(ctx);
                              _sharePassportText(
                                mapState.totalVisited,
                                mapState.worldPercentage,
                                visitedContinentsCount,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCountryDetailSheet(TravelCountry country) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentLang = Localizations.localeOf(context).languageCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, sheetRef, child) {
            final latestCountry = sheetRef
                .watch(travelMapControllerProvider)
                .countries
                .firstWhere((c) => c.code == country.code, orElse: () => country);

            return RepaintBoundary(
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                        width: 1.0,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Country Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: CountryFlag(
                              code: latestCountry.code,
                              fallbackEmoji: latestCountry.flag,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  latestCountry.getLocalizedName(currentLang),
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  latestCountry.capital.isNotEmpty
                                      ? '${_getLocalizedContinentName(latestCountry.continent, l10n)} • ${l10n.mapLegendCapital}: ${latestCountry.capital}'
                                      : _getLocalizedContinentName(latestCountry.continent, l10n),
                                  style: AppTypography.caption.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Status Switcher: Lived vs Visited vs Wishlist vs None
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            // 1. Yaşadığım (Lived - Emerald Green)
                            Expanded(
                              child: BouncyPressable(
                                onTap: () {
                                  AppHaptics.lightImpact();
                                  sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                        code: latestCountry.code,
                                        status: latestCountry.isLived
                                            ? CountryStatus.none
                                            : CountryStatus.lived,
                                      );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: latestCountry.isLived
                                        ? const Color(0xFF10B981)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: latestCountry.isLived
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.home_rounded,
                                        size: 15,
                                        color: latestCountry.isLived
                                            ? Colors.white
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          l10n.mapLegendLived,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: latestCountry.isLived
                                                ? Colors.white
                                                : theme.colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 2. Gezdim (Visited - Orange Been style)
                            Expanded(
                              child: BouncyPressable(
                                onTap: () {
                                  AppHaptics.lightImpact();
                                  sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                        code: latestCountry.code,
                                        status: latestCountry.isVisited
                                            ? CountryStatus.none
                                            : CountryStatus.visited,
                                        visitedDate: latestCountry.visitedDate ?? DateTime.now(),
                                      );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: latestCountry.isVisited
                                        ? AppColors.brandAccent
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: latestCountry.isVisited
                                        ? [
                                            BoxShadow(
                                              color: AppColors.brandAccent.withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 15,
                                        color: latestCountry.isVisited
                                            ? Colors.white
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          l10n.mapLegendBeen,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: latestCountry.isVisited
                                                ? Colors.white
                                                : theme.colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 3. Gezmek İstiyorum (Wishlist - Red Skratch style with explore icon)
                            Expanded(
                              child: BouncyPressable(
                                onTap: () {
                                  AppHaptics.lightImpact();
                                  sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                        code: latestCountry.code,
                                        status: latestCountry.isWishlist
                                            ? CountryStatus.none
                                            : CountryStatus.wishlist,
                                      );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: latestCountry.isWishlist
                                        ? const Color(0xFFEF4444)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: latestCountry.isWishlist
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.explore_rounded,
                                        size: 15,
                                        color: latestCountry.isWishlist
                                            ? Colors.white
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          l10n.mapLegendWant,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: latestCountry.isWishlist
                                                ? Colors.white
                                                : theme.colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // İşareti Kaldır (None)
                            if (latestCountry.status != CountryStatus.none)
                              BouncyPressable(
                                onTap: () {
                                  AppHaptics.lightImpact();
                                  sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                        code: latestCountry.code,
                                        status: CountryStatus.none,
                                      );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (latestCountry.status != CountryStatus.none) ...[
                        const SizedBox(height: 10),
                        AppButton.destructive(
                          label: l10n.delete,
                          leadingIcon: Icons.delete_sweep_rounded,
                          size: AppButtonSize.medium,
                          isExpanded: true,
                          onPressed: () {
                            sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                  code: latestCountry.code,
                                  status: CountryStatus.none,
                                );
                          },
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Action Button: Seyahat Planla
                      AppButton.primary(
                        label: l10n.planTripToCountry(latestCountry.getLocalizedName(currentLang)),
                        leadingIcon: Icons.flight_takeoff_rounded,
                        size: AppButtonSize.large,
                        isExpanded: true,
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TripsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mapState = ref.watch(travelMapControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentLang = Localizations.localeOf(context).languageCode;

    final visitedContinentsCount = [
      'Europe',
      'Asia',
      'Americas',
      'Africa',
      'Oceania',
    ].where((cont) => mapState.countries.any((c) => (c.isVisited || c.isLived) && c.isInContinent(cont))).length;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: !widget.isTabMode,
        titleSpacing: (!widget.isTabMode && Navigator.of(context).canPop()) ? 0 : 16,
        leading: !widget.isTabMode && Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(AppIcons.chevronLeft, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.isTabMode)
                Hero(
                  tag: 'travel-map-hero-badge',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.brandAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      AppIcons.globe,
                      color: AppColors.brandAccent,
                      size: 18,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.brandAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.globe,
                    color: AppColors.brandAccent,
                    size: 18,
                  ),
                ),
              if (!widget.isTabMode)
                Hero(
                  tag: 'travel-map-hero-title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      l10n.worldTravelMapTitle,
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                Material(
                  type: MaterialType.transparency,
                  child: Text(
                    l10n.worldTravelMapTitle,
                    style: theme.appBarTheme.titleTextStyle ??
                        theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.share, size: 20),
            tooltip: l10n.shareStory,
            onPressed: () => _openStoryShareModal(
              mapState,
              visitedContinentsCount,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: mapState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(travelMapControllerProvider.notifier).refreshFromCloud(),
              color: AppColors.brandAccent,
              child: CustomScrollView(
                scrollCacheExtent: const ScrollCacheExtent.pixels(800.0),
                physics: _isMapInteracting
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                // 1. Interactive Vector World Map Canvas (Hero Atlas - Edge-to-edge feel)
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                      child: InteractiveWorldMap(
                        countries: mapState.countries,
                        is3DMode: mapState.is3DMode,
                        onToggle3DMode: (val) {
                          ref.read(travelMapControllerProvider.notifier).set3DMode(val);
                        },
                        onCountryTap: _showCountryDetailSheet,
                        onMapInteracting: (val) {
                          setState(() {
                            _isMapInteracting = val;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                // 2. Executive Passport Summary Card (Ülke, Kıta, % Dünya + Progress + Status Breakdown + Story Share)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: AppCard(
                      borderRadius: AppRadius.card,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 3-Metric Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildBeenStat(
                                  value: '${mapState.totalVisited}',
                                  label: l10n.countryUnit,
                                  isDark: isDark,
                                ),
                              ),
                              Container(
                                width: 0.5,
                                height: 32,
                                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                              ),
                              Expanded(
                                child: _buildBeenStat(
                                  value: '$visitedContinentsCount',
                                  label: l10n.continentsUnit,
                                  isDark: isDark,
                                ),
                              ),
                              Container(
                                width: 0.5,
                                height: 32,
                                color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                              ),
                              Expanded(
                                child: _buildBeenStat(
                                  value: '%${mapState.worldPercentage.toStringAsFixed(1)}',
                                  label: l10n.ofTheWorld,
                                  subLabel: '${mapState.totalVisited}/${mapState.totalCountries}',
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Linear progress indicator
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            child: LinearProgressIndicator(
                              value: (mapState.worldPercentage / 100).clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandAccent),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Status breakdown dots + Inline Story Share Action (Responsive Wrap to guarantee 0 overflow across small screens & languages)
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _buildSummaryDot(
                                    color: const Color(0xFF10B981),
                                    count: mapState.totalLived,
                                    label: l10n.mapLegendLived,
                                    isDark: isDark,
                                  ),
                                  _buildSummaryDot(
                                    color: AppColors.brandAccent,
                                    count: mapState.totalVisited,
                                    label: l10n.mapLegendBeen,
                                    isDark: isDark,
                                  ),
                                  _buildSummaryDot(
                                    color: const Color(0xFFEF4444),
                                    count: mapState.totalWishlist,
                                    label: l10n.mapLegendWant,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                              // Inline Story Share Micro-Button
                              InkWell(
                                onTap: () {
                                  AppHaptics.lightImpact();
                                  _openStoryShareModal(mapState, visitedContinentsCount);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandAccent.withValues(alpha: isDark ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.brandAccent.withValues(alpha: 0.35),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        AppIcons.share,
                                        size: 11,
                                        color: AppColors.brandAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.shareStory,
                                        style: const TextStyle(
                                          color: AppColors.brandAccent,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3.5. Continent Country Count & Percentage Statistics Carousel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: mapState.continentProgressList.map((cp) {
                          final isSelected = mapState.filter == cp.continent;
                          final name = _getLocalizedContinentName(cp.continent, l10n);
                          final accentColor = _getContinentColor(cp.continent);

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                final newFilter = isSelected ? 'all' : cp.continent;
                                ref.read(travelMapControllerProvider.notifier).setFilter(newFilter);
                              },
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 172,
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
                                  borderRadius: BorderRadius.circular(AppRadius.card),
                                  border: Border.all(
                                    color: isSelected
                                        ? accentColor
                                        : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                                    width: isSelected ? 1.5 : 0.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? accentColor.withValues(alpha: isDark ? 0.3 : 0.15)
                                          : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(AppIcons.globe, size: 14, color: accentColor),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: AppTypography.titleSmall.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12.5,
                                              color: isSelected
                                                  ? accentColor
                                                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 7),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${cp.visitedCountries}/${cp.totalCountries} ${l10n.countryUnit}',
                                            style: AppTypography.mono(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                              tabularFigures: true,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '%${cp.percentage.toStringAsFixed(0)}',
                                          style: AppTypography.mono(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: accentColor,
                                            tabularFigures: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.xs),
                                      child: LinearProgressIndicator(
                                        value: (cp.percentage / 100).clamp(0.0, 1.0),
                                        minHeight: 4,
                                        backgroundColor: isDark
                                            ? Colors.white12
                                            : const Color(0xFFF1F5F9),
                                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // 4. Continents & Status Filter Chips (Positioned right above the Country List)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', '${l10n.allFilter} (${mapState.totalCountries})', icon: AppIcons.categoryAll),
                          const SizedBox(width: 8),
                          _buildFilterChip('lived', '${l10n.livedFilter} (${mapState.totalLived})', color: const Color(0xFF10B981), icon: AppIcons.home),
                          const SizedBox(width: 8),
                          _buildFilterChip('visited', '${l10n.visitedFilter} (${mapState.totalVisited})', color: AppColors.brandAccent, icon: AppIcons.flight),
                          const SizedBox(width: 8),
                          _buildFilterChip('wishlist', '${l10n.wishlistFilter} (${mapState.totalWishlist})', color: const Color(0xFFEF4444), icon: AppIcons.heart),
                          const SizedBox(width: 8),
                          _buildFilterChip('Europe', l10n.continentEurope, icon: AppIcons.globe),
                          const SizedBox(width: 8),
                          _buildFilterChip('Asia', l10n.continentAsia, icon: AppIcons.globe),
                          const SizedBox(width: 8),
                          _buildFilterChip('Americas', l10n.continentAmericas, icon: AppIcons.globe),
                          const SizedBox(width: 8),
                          _buildFilterChip('Africa', l10n.continentAfrica, icon: AppIcons.globe),
                          const SizedBox(width: 8),
                          _buildFilterChip('Oceania', l10n.continentOceania, icon: AppIcons.globe),
                        ],
                      ),
                    ),
                  ),
                ),

                // 5. Search Bar (Positioned right above Country List)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(travelMapControllerProvider.notifier).setSearchQuery(val);
                      },
                      decoration: InputDecoration(
                        hintText: l10n.searchCountryOrCapital,
                        hintStyle: AppTheme.bodyFont(
                          fontSize: 14,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          AppIcons.search,
                          size: 18,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(AppIcons.close, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(travelMapControllerProvider.notifier).setSearchQuery('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          borderSide: const BorderSide(
                            color: AppColors.brandAccent,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                ),


                // 7. Country List Items
                Builder(
                  builder: (context) {
                    final displayCountries = mapState.getFilteredCountries(currentLang);
                    final bottomPadding = math.max(120.0, MediaQuery.paddingOf(context).bottom + 100.0);

                    if (displayCountries.isEmpty) {
                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 36),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.travel_explore_rounded,
                                      size: 38,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    l10n.noMatchingCountry,
                                    style: AppTypography.titleLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.searchCountryOrCapital,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  AppButton.outline(
                                    label: l10n.allFilter,
                                    leadingIcon: Icons.filter_alt_off_rounded,
                                    size: AppButtonSize.medium,
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(travelMapControllerProvider.notifier).setSearchQuery('');
                                      ref.read(travelMapControllerProvider.notifier).setFilter('all');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final country = displayCountries[index];
                            return _buildCountryTile(country, l10n, currentLang, theme, isDark);
                          },
                          childCount: displayCountries.length,
                          addRepaintBoundaries: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildBeenStat({
    required String value,
    required String label,
    required bool isDark,
    bool isAccent = false,
    String? subLabel,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isAccent
                  ? AppColors.brandAccent
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        if (subLabel != null) ...[
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              subLabel,
              style: AppTypography.caption.copyWith(
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryDot({
    required Color color,
    required int count,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 10.5,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, {Color? color, IconData? icon}) {
    final current = ref.watch(travelMapControllerProvider).filter;
    final isSelected = current == key;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      showCheckmark: false,
      avatar: icon != null
          ? Icon(
              icon,
              size: 13,
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
            )
          : null,
      label: Text(label),
      selected: isSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
          width: 0.5,
        ),
      ),
      selectedColor: color ?? theme.colorScheme.primary,
      backgroundColor: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
      labelStyle: AppTypography.caption.copyWith(
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        fontSize: 11.5,
        height: 1.15,
      ),
      onSelected: (_) {
        ref.read(travelMapControllerProvider.notifier).setFilter(key);
      },
    );
  }

  Widget _buildCountryTile(
    TravelCountry country,
    AppLocalizations l10n,
    String currentLang,
    ThemeData theme,
    bool isDark,
  ) {
    Color? statusColor;
    String? statusText;
    if (country.isLived) {
      statusColor = const Color(0xFF10B981);
      statusText = l10n.mapLegendLived;
    } else if (country.isVisited) {
      statusColor = AppColors.brandAccent;
      statusText = l10n.mapLegendBeen;
    } else if (country.isWishlist) {
      statusColor = const Color(0xFFEF4444);
      statusText = l10n.mapLegendWant;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: statusColor != null
              ? statusColor.withValues(alpha: 0.35)
              : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
          width: statusColor != null ? 1.0 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          onTap: () => _showCountryDetailSheet(country),
          leading: CountryFlag(
            code: country.code,
            fallbackEmoji: country.flag,
            size: 26,
          ),
          title: Text(
            country.getLocalizedName(currentLang),
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Wrap(
            spacing: 6,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _getLocalizedContinentName(country.continent, l10n),
                style: AppTypography.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              if (statusText != null && statusColor != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    statusText,
                    style: AppTypography.caption.copyWith(
                      color: statusColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick Home (Lived - Emerald Green)
              _buildCountryActionBadge(
                isActive: country.isLived,
                activeColor: const Color(0xFF10B981),
                activeIcon: AppIcons.home,
                inactiveIcon: AppIcons.home,
                tooltip: l10n.markAsLivedTooltip,
                isDark: isDark,
                onTap: () {
                  ref.read(travelMapControllerProvider.notifier).setCountryStatus(
                        code: country.code,
                        status: country.isLived ? CountryStatus.none : CountryStatus.lived,
                      );
                },
              ),
              const SizedBox(width: 4),
              // Quick Check (Visited - Terracotta)
              _buildCountryActionBadge(
                isActive: country.isVisited,
                activeColor: AppColors.brandAccent,
                activeIcon: AppIcons.checkCircle,
                inactiveIcon: AppIcons.checkCircle,
                tooltip: l10n.markAsVisitedTooltip,
                isDark: isDark,
                onTap: () {
                  ref.read(travelMapControllerProvider.notifier).setCountryStatus(
                        code: country.code,
                        status: country.isVisited ? CountryStatus.none : CountryStatus.visited,
                      );
                },
              ),
              const SizedBox(width: 4),
              // Quick Bucket List (Wishlist - Coral red)
              _buildCountryActionBadge(
                isActive: country.isWishlist,
                activeColor: const Color(0xFFEF4444),
                activeIcon: AppIcons.heart,
                inactiveIcon: AppIcons.heart,
                tooltip: l10n.markAsWishlistTooltip,
                isDark: isDark,
                onTap: () {
                  ref.read(travelMapControllerProvider.notifier).setCountryStatus(
                        code: country.code,
                        status: country.isWishlist ? CountryStatus.none : CountryStatus.wishlist,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryActionBadge({
    required bool isActive,
    required Color activeColor,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Center(
          child: InkWell(
            onTap: () {
              AppHaptics.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withValues(alpha: 0.16)
                    : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isActive
                      ? activeColor
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  width: isActive ? 1.2 : 0.5,
                ),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                size: 15,
                color: isActive
                    ? activeColor
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedContinentName(String continent, AppLocalizations l10n) {
    switch (continent) {
      case 'Europe':
        return l10n.continentEurope;
      case 'Asia':
        return l10n.continentAsia;
      case 'Americas':
        return l10n.continentAmericas;
      case 'Africa':
        return l10n.continentAfrica;
      case 'Oceania':
        return l10n.continentOceania;
      default:
        return continent;
    }
  }

  Color _getContinentColor(String continent) {
    switch (continent) {
      case 'Europe':
        return const Color(0xFF3B82F6); // European Blue
      case 'Asia':
        return AppColors.brandAccent; // Terracotta / Warm Obsidian Explorer
      case 'Americas':
        return const Color(0xFF10B981); // Americas Emerald Green
      case 'Africa':
        return const Color(0xFFF59E0B); // African Amber Sun
      case 'Oceania':
        return const Color(0xFF06B6D4); // Oceania Cyan
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}
