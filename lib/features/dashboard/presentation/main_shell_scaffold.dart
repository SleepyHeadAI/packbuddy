import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/bouncy_pressable.dart';
import '../../checklist/presentation/screens/checklist_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../travel_map/presentation/screens/travel_map_screen.dart';
import '../../vault/presentation/screens/vault_screen.dart';
import '../../vault/presentation/controllers/vault_controller.dart';
import '../../connectivity/presentation/widgets/connectivity_banner.dart';
import 'dashboard_screen.dart';
import 'navigation_provider.dart';

/// Permanent Shell Scaffold hosting the persistent bottom navigation bar.
///
/// Keeps tab states alive across tab transitions via [IndexedStack] and
/// ensures the bottom navigation bar is always visible and interactive across
/// the primary application tabs (Home, Map, Baggage, Vault, Settings).
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
      TravelMapScreen(),
      ChecklistScreen(),
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

    // Default localized strings fallback if l10n is initializing
    final navHome = l10n?.navHome ?? 'Home';
    final navMap = l10n?.navMap ?? 'Map';
    final navBaggage = l10n?.navBaggage ?? 'Baggage';
    final navVault = l10n?.navVault ?? 'Vault';
    final navSettings = l10n?.navSettings ?? 'Settings';

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
        extendBody: true,
        body: Column(
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
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                ),
                _FloatingNavItemData(
                  label: navMap,
                  icon: Icons.public_outlined,
                  selectedIcon: Icons.public_rounded,
                ),
                _FloatingNavItemData(
                  label: navBaggage,
                  icon: Icons.checklist_rounded,
                  selectedIcon: Icons.checklist_rtl_rounded,
                ),
                _FloatingNavItemData(
                  label: navVault,
                  icon: Icons.folder_shared_outlined,
                  selectedIcon: Icons.folder_shared_rounded,
                ),
                _FloatingNavItemData(
                  label: navSettings,
                  icon: Icons.tune_outlined,
                  selectedIcon: Icons.tune_rounded,
                ),
              ],
            ),
          ),
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

  const _FloatingGlassNavigationBar({
    required this.selectedIndex,
    required this.isDark,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.50)
                : const Color(0xFF0F172A).withValues(alpha: 0.12),
            blurRadius: 26,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.30)
                : const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1E2632).withValues(alpha: 0.88),
                        const Color(0xFF141A22).withValues(alpha: 0.82),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.90),
                        Colors.white.withValues(alpha: 0.76),
                      ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.13)
                    : Colors.white.withValues(alpha: 0.90),
                width: 1.2,
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
                      HapticFeedback.selectionClick();
                      onDestinationSelected(index);
                    },
                  ),
                );
              }),
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
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Semantics(
      selected: isSelected,
      label: item.label,
      button: true,
      child: BouncyPressable(
        scaleFactor: 0.92,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: isDark ? 0.22 : 0.13)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: isSelected
                  ? Border.all(
                      color: activeColor.withValues(alpha: 0.30),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    size: 21,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? activeColor : inactiveColor,
                      letterSpacing: -0.15,
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
    this.duration = const Duration(milliseconds: 220),
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
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0.0);
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

