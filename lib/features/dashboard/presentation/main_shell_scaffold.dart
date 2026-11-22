import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/bouncy_pressable.dart';
import '../../checklist/presentation/screens/checklist_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../travel_map/presentation/screens/travel_map_screen.dart';
import '../../vault/presentation/screens/vault_screen.dart';
import '../../vault/presentation/controllers/vault_controller.dart';
import '../../connectivity/presentation/widgets/connectivity_banner.dart';
import 'dashboard_screen.dart';
import '../../../shared/widgets/floating_action_button_location.dart';
import 'navigation_provider.dart';
export '../../../shared/widgets/floating_action_button_location.dart';

/// Permanent Shell Scaffold hosting the persistent bottom navigation bar.
///
/// Keeps tab states alive across tab transitions via [FadeIndexedStack] and
/// displays a true floating frosted-glass island capsule navigation bar.
class MainShellScaffold extends ConsumerStatefulWidget {
  const MainShellScaffold({super.key});

  @override
  ConsumerState<MainShellScaffold> createState() => _MainShellScaffoldState();
}

class _MainShellScaffoldState extends ConsumerState<MainShellScaffold> {
  // Ordered primary top-level screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      DashboardScreen(),
      TravelMapScreen(isTabMode: true),
      ChecklistScreen(isTabMode: true),
      VaultScreen(isTabMode: true),
      SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainNavigationIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Default localized strings fallback if l10n is initializing
    final navHome = l10n?.navHome ?? 'Home';
    final navMap = l10n?.navMap ?? 'Map';
    final navBaggage = l10n?.navBaggage ?? 'Baggage';
    final navVault = l10n?.navVault ?? 'Vault';
    final navSettings = l10n?.navSettings ?? 'Settings';

    // Responsiveness & Floating Geometry:
    // When keyboard is visible, softly hide the floating bottom navigation bar
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
    // Calculate generous floating clearance above physical bottom system insets
    final bottomInset = mediaQuery.padding.bottom;
    final floatingBottomMargin = math.max(kFloatingBarMinBottomMargin, bottomInset + 8.0);
    final screenWidth = mediaQuery.size.width;
    final horizontalMargin = screenWidth > 600 ? 32.0 : 20.0;

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // If not on Home tab, return to Home on back gesture/button
        if (selectedIndex != 0) {
          ref.read(mainNavigationIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 1. Primary Screen Viewport (Scrollable content glides seamlessly beneath the floating bar)
            Positioned.fill(
              child: Column(
                children: [
                  const ConnectivityBanner(),
                  Expanded(
                    child: FadeIndexedStack(
                      index: selectedIndex.clamp(0, _screens.length - 1),
                      children: _screens,
                    ),
                  ),
                ],
              ),
            ),

            // 2. True Floating Frosted Glass Island Capsule Navigation Bar
            AnimatedPositioned(
              duration: AppMotion.durationOf(context, AppMotion.normal),
              curve: AppMotion.enter,
              left: 0,
              right: 0,
              bottom: isKeyboardVisible ? -100.0 : floatingBottomMargin,
              child: AnimatedOpacity(
                duration: AppMotion.durationOf(context, AppMotion.fast),
                opacity: isKeyboardVisible ? 0.0 : 1.0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                      child: _FloatingGlassNavigationBar(
                        selectedIndex: selectedIndex.clamp(0, 4),
                        isDark: isDark,
                        onDestinationSelected: (index) {
                          if (index != selectedIndex) {
                            // If transitioning away from or into Vault tab (index 3),
                            // immediately lock the vault to enforce security verification
                            if (selectedIndex == 3 || index == 3) {
                              ref.read(vaultControllerProvider.notifier).lockVault();
                            }
                            ref.read(mainNavigationIndexProvider.notifier).state = index;
                          }
                        },
                        items: [
                          _FloatingNavItemData(
                            label: navHome,
                            icon: AppIcons.homeOutlined,
                            selectedIcon: AppIcons.home,
                          ),
                          _FloatingNavItemData(
                            label: navMap,
                            icon: AppIcons.mapOutlined,
                            selectedIcon: AppIcons.map,
                          ),
                          _FloatingNavItemData(
                            label: navBaggage,
                            icon: AppIcons.checklistOutlined,
                            selectedIcon: AppIcons.checklist,
                          ),
                          _FloatingNavItemData(
                            label: navVault,
                            icon: AppIcons.vaultOutlined,
                            selectedIcon: AppIcons.vault,
                          ),
                          _FloatingNavItemData(
                            label: navSettings,
                            icon: AppIcons.settingsOutlined,
                            selectedIcon: AppIcons.settings,
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
    );
  }
}

class _FloatingNavItemData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _FloatingNavItemData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class _FloatingGlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final ValueChanged<int> onDestinationSelected;
  final List<_FloatingNavItemData> items;

  // Concentric Geometric Tokens for Mathematically Proportional Curvature:
  // Outer bar corner radius is matched symmetrically with internal padding
  // so that the active selection indicator's outer corner forms an exact parallel concentric arc.
  // R_inner = R_bar - padding_horizontal = 26.0 - 6.0 = 20.0 (Corner tabs).
  // Middle tabs use a disciplined, proportional radius (12.0) that eliminates any bulbous distortion.
  static const double barHeight = 64.0;
  static const double barRadius = AppRadius.navBar; // 26.0
  static const double horizontalPadding = 6.0;
  static const double verticalPadding = 5.0;

  const _FloatingGlassNavigationBar({
    required this.selectedIndex,
    required this.isDark,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(barRadius),
          boxShadow: [
            // 1. Ambient soft omni elevation glow
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.38)
                  : AppColors.navySlate.withValues(alpha: 0.08),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            // 2. Subtle crisp contact shadow
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.22)
                  : AppColors.navySlate.withValues(alpha: 0.03),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(barRadius),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              height: barHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          AppColors.surfaceRaisedDark.withValues(alpha: 0.92),
                          AppColors.surfaceBaseDark.withValues(alpha: 0.88),
                        ]
                      : [
                          AppColors.surfaceBaseLight.withValues(alpha: 0.95),
                          AppColors.surfaceBaseLight.withValues(alpha: 0.90),
                        ],
                ),
                borderRadius: BorderRadius.circular(barRadius),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderSubtleDark
                      : AppColors.borderSubtleLight,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = index == selectedIndex;

                  return Expanded(
                    child: _FloatingNavItem(
                      item: item,
                      isSelected: isSelected,
                      isDark: isDark,
                      theme: theme,
                      onTap: () {
                        AppHaptics.selection();
                        onDestinationSelected(index);
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final _FloatingNavItemData item;
  final bool isSelected;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.brandAccentDark : AppColors.brandAccent;
    final activeTextColor = isDark ? AppColors.brandAccentDark : AppColors.brandAccentTextLight;
    final inactiveColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderRadius = BorderRadius.circular(16.0);

    return Semantics(
      selected: isSelected,
      label: item.label,
      button: true,
      child: BouncyPressable(
        scaleFactor: 0.94,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.curveStandard,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? AppColors.brandAccent.withValues(alpha: 0.16)
                      : AppColors.brandAccent.withValues(alpha: 0.10))
                  : Colors.transparent,
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: AppMotion.fast,
                  curve: AppMotion.spring,
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    size: 20,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        softWrap: false,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? activeTextColor : inactiveColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated IndexedStack providing smooth fade transitions between main navigation tabs
/// while preserving full state, scroll offsets, and active forms across all tabs.
class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = AppMotion.normal,
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: AppMotion.enter);
    _controller.forward();
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      if (AppMotion.reduceMotionOf(context)) {
        _controller.value = 1.0;
      } else {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: IndexedStack(
        index: widget.index,
        children: widget.children,
      ),
    );
  }
}

