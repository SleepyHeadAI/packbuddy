import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/interactive_world_map.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/travel_map_story_card.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/country_flag.dart';
import 'package:packbuddy/core/services/app_widget_localization.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Full-screen interactive world travel map and country tracker
class TravelMapScreen extends ConsumerStatefulWidget {
  const TravelMapScreen({super.key});

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
        '• %${percentage.toStringAsFixed(1)} ${l10n?.ofTheWorld ?? "of the world"}!\n\n'
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
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setModalState(() {
                                    selectedLayout = l;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6.5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryAmber
                                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryAmber
                                          : (isDark ? Colors.white12 : Colors.black12),
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryAmber.withValues(alpha: 0.35),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l.emoji,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l.getLocalizedName(
                                          l10n,
                                          locale: Localizations.localeOf(context).languageCode,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : Colors.black87),
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
                                        ? AppColors.primaryAmber
                                        : (isDark ? Colors.white12 : Colors.black12),
                                    width: selectedThemeCategory == 0 ? 1.5 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '🌙 ${AppWidgetLocalization.getDarkThemesCategory(lang)} (9)',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: selectedThemeCategory == 0 ? FontWeight.w800 : FontWeight.w600,
                                        color: selectedThemeCategory == 0
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : Colors.black87),
                                      ),
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
                                      ? AppColors.primaryAmber
                                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedThemeCategory == 1
                                        ? AppColors.primaryAmber
                                        : (isDark ? Colors.white12 : Colors.black12),
                                    width: selectedThemeCategory == 1 ? 1.5 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '☀️ ${AppWidgetLocalization.getLightThemesCategory(lang)} (7)',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: selectedThemeCategory == 1 ? FontWeight.w800 : FontWeight.w600,
                                        color: selectedThemeCategory == 1
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : Colors.black87),
                                      ),
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
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
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
                                          ? AppColors.primaryAmber
                                          : (isDark ? Colors.white12 : Colors.black12),
                                      width: isSelected ? 1.8 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryAmber.withValues(alpha: 0.3),
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
                                        '${palette.emoji} ${palette.label}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected
                                              ? (isDark ? Colors.black : Colors.white)
                                              : (isDark ? Colors.white70 : Colors.black87),
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
                          // Story Share Primary Button (Signature Travel Gradient)
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE7B623), Color(0xFF856404)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF856404).withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _isSharingStory
                                  ? null
                                  : () => _shareStoryImage(storyKey, setModalState),
                              icon: _isSharingStory
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.camera_alt_rounded, size: 20),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _isSharingStory ? l10n.generatingStoryImage : l10n.shareImageButton,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Text Share Secondary Button
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _sharePassportText(
                                mapState.totalVisited,
                                mapState.worldPercentage,
                                visitedContinentsCount,
                              );
                            },
                            icon: const Icon(Icons.text_snippet_outlined, size: 18),
                            label: Text(
                              l10n.shareTextButton,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
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
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                            borderRadius: BorderRadius.circular(3),
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
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  latestCountry.capital.isNotEmpty
                                      ? '${_getLocalizedContinentName(latestCountry.continent, l10n)} • ${l10n.mapLegendCapital}: ${latestCountry.capital}'
                                      : _getLocalizedContinentName(latestCountry.continent, l10n),
                                  style: TextStyle(
                                    fontSize: 12.5,
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
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            // 1. Yaşadığım (Lived - Emerald Green)
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                        code: latestCountry.code,
                                        status: latestCountry.isLived
                                            ? CountryStatus.none
                                            : CountryStatus.lived,
                                      );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
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
                              child: InkWell(
                                onTap: () {
                                  sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                        code: latestCountry.code,
                                        status: latestCountry.isVisited
                                            ? CountryStatus.none
                                            : CountryStatus.visited,
                                        visitedDate: latestCountry.visitedDate ?? DateTime.now(),
                                      );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: latestCountry.isVisited
                                        ? AppColors.primaryAmber
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: latestCountry.isVisited
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryAmber.withValues(alpha: 0.35),
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
                              child: InkWell(
                                onTap: () {
                                  sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                        code: latestCountry.code,
                                        status: latestCountry.isWishlist
                                            ? CountryStatus.none
                                            : CountryStatus.wishlist,
                                      );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
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
                              InkWell(
                                onTap: () {
                                  sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                        code: latestCountry.code,
                                        status: CountryStatus.none,
                                      );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            sheetRef.read(travelMapControllerProvider.notifier).setCountryStatus(
                                  code: latestCountry.code,
                                  status: CountryStatus.none,
                                );
                          },
                          icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                          label: Text(
                            l10n.delete,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Action Button: Seyahat Planla
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TripsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.flight_takeoff_rounded, size: 18),
                        label: Flexible(
                          child: Text(
                            l10n.planTripToCountry(latestCountry.getLocalizedName(currentLang)),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
        titleSpacing: 8,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'travel-map-hero-badge',
                child: Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.public_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                ),
              ),
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
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 22),
            tooltip: l10n.shareStory,
            onPressed: () => _openStoryShareModal(
              mapState,
              visitedContinentsCount,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '%${mapState.worldPercentage.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: mapState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(travelMapControllerProvider.notifier).refreshFromCloud(),
              color: AppColors.primaryAmber,
              child: CustomScrollView(
                scrollCacheExtent: const ScrollCacheExtent.pixels(800.0),
                physics: _isMapInteracting
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                // 1. Overview Progress Bar (Gezilen | Hedef | Dünya Bar)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: _buildMetric(
                                  title: l10n.mapLegendLived,
                                  value: '${mapState.totalLived}',
                                  color: const Color(0xFF10B981),
                                  icon: Icons.home_rounded,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 38,
                                color: theme.colorScheme.outlineVariant,
                              ),
                              Expanded(
                                child: _buildMetric(
                                  title: l10n.mapLegendBeen,
                                  value: '${mapState.totalVisited}',
                                  color: AppColors.primaryAmber,
                                  icon: Icons.flight_takeoff_rounded,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 38,
                                color: theme.colorScheme.outlineVariant,
                              ),
                              Expanded(
                                child: _buildMetric(
                                  title: l10n.mapLegendWant,
                                  value: '${mapState.totalWishlist}',
                                  color: const Color(0xFFEF4444),
                                  icon: Icons.explore_rounded,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 38,
                                color: theme.colorScheme.outlineVariant,
                              ),
                              Expanded(
                                child: _buildMetric(
                                  title: l10n.ofTheWorld,
                                  value: '%${mapState.worldPercentage.toStringAsFixed(1)}',
                                  color: theme.colorScheme.primary,
                                  icon: Icons.public_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (mapState.worldPercentage / 100).clamp(0.0, 1.0),
                              minHeight: 7,
                              backgroundColor: isDark ? Colors.white12 : Colors.black12,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAmber),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 1.5. Instagram & Snapchat Story Share Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openStoryShareModal(mapState, visitedContinentsCount),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE7B623), Color(0xFF856404)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF856404).withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.shareStory,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  Text(
                                    l10n.shareStorySubtitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 13),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Interactive Vector World Map Canvas (Full country polygon coloring - Skratch & Been style)
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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

                // 3. Been Passport 4-Metric Statistics Card (Seyahat, Ülke, Kıta, % Dünya)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildBeenStat(
                              value: '${mapState.totalVisited}',
                              label: l10n.countryUnit,
                              isDark: isDark,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                          ),
                          Expanded(
                            child: _buildBeenStat(
                              value: '$visitedContinentsCount',
                              label: l10n.continentsUnit,
                              isDark: isDark,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                          ),
                          Expanded(
                            child: _buildBeenStat(
                              value: '%${mapState.worldPercentage.toStringAsFixed(1)}',
                              label: l10n.ofTheWorld,
                              isDark: isDark,
                            ),
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
                          final emoji = _getContinentEmoji(cp.continent);
                          final accentColor = _getContinentColor(cp.continent);

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                final newFilter = isSelected ? 'all' : cp.continent;
                                ref.read(travelMapControllerProvider.notifier).setFilter(newFilter);
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 156,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? accentColor
                                        : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                                    width: isSelected ? 1.5 : 1,
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
                                        Text(emoji, style: const TextStyle(fontSize: 14)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: TextStyle(
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
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '%${cp.percentage.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
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
                          _buildFilterChip('all', '${l10n.allFilter} (${mapState.totalCountries})'),
                          const SizedBox(width: 8),
                          _buildFilterChip('lived', '${l10n.livedFilter} (${mapState.totalLived})', color: const Color(0xFF10B981)),
                          const SizedBox(width: 8),
                          _buildFilterChip('visited', '${l10n.visitedFilter} (${mapState.totalVisited})', color: AppColors.primaryAmber),
                          const SizedBox(width: 8),
                          _buildFilterChip('wishlist', '${l10n.wishlistFilter} (${mapState.totalWishlist})', color: const Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          _buildFilterChip('Europe', l10n.continentEurope),
                          const SizedBox(width: 8),
                          _buildFilterChip('Asia', l10n.continentAsia),
                          const SizedBox(width: 8),
                          _buildFilterChip('Americas', l10n.continentAmericas),
                          const SizedBox(width: 8),
                          _buildFilterChip('Africa', l10n.continentAfrica),
                          const SizedBox(width: 8),
                          _buildFilterChip('Oceania', l10n.continentOceania),
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
                          Icons.search_rounded,
                          size: 20,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(travelMapControllerProvider.notifier).setSearchQuery('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                            width: 1.6,
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
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
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
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetric({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label, {Color? color}) {
    final current = ref.watch(travelMapControllerProvider).filter;
    final isSelected = current == key;
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color ?? theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 12,
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
      statusColor = AppColors.primaryAmber;
      statusText = l10n.mapLegendBeen;
    } else if (country.isWishlist) {
      statusColor = const Color(0xFFEF4444);
      statusText = l10n.mapLegendWant;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor != null
              ? statusColor.withValues(alpha: 0.4)
              : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
          width: statusColor != null ? 1.5 : 1.0,
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
        borderRadius: BorderRadius.circular(16),
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  _getLocalizedContinentName(country.continent, l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (statusText != null && statusColor != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick Home (Lived - Emerald Green)
              _buildCountryActionBadge(
                isActive: country.isLived,
                activeColor: const Color(0xFF10B981),
                activeIcon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
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
              // Quick Check (Visited - Been gold)
              _buildCountryActionBadge(
                isActive: country.isVisited,
                activeColor: AppColors.primaryAmber,
                activeIcon: Icons.check_circle_rounded,
                inactiveIcon: Icons.check_rounded,
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
              // Quick Bucket List (Wishlist - Skratch coral red)
              _buildCountryActionBadge(
                isActive: country.isWishlist,
                activeColor: const Color(0xFFEF4444),
                activeIcon: Icons.explore_rounded,
                inactiveIcon: Icons.explore_outlined,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.16)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isActive
                  ? activeColor
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isActive ? 1.5 : 1.0,
            ),
          ),
          child: Icon(
            isActive ? activeIcon : inactiveIcon,
            size: 17,
            color: isActive
                ? activeColor
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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

  String _getContinentEmoji(String continent) {
    switch (continent) {
      case 'Europe':
        return '🇪🇺';
      case 'Asia':
        return '⛩️';
      case 'Americas':
        return '🌎';
      case 'Africa':
        return '🦁';
      case 'Oceania':
        return '🦘';
      default:
        return '🌐';
    }
  }

  Color _getContinentColor(String continent) {
    switch (continent) {
      case 'Europe':
        return const Color(0xFF3B82F6); // European Blue
      case 'Asia':
        return AppColors.actionGold; // Asian Warm Ochre / Serene Gold
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
