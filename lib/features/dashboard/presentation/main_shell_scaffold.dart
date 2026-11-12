import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../checklist/presentation/screens/checklist_screen.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../travel_map/presentation/screens/travel_map_screen.dart';
import '../../vault/presentation/screens/vault_screen.dart';
import '../../vault/presentation/controllers/vault_controller.dart';
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
        body: FadeIndexedStack(
          index: selectedIndex.clamp(0, _screens.length - 1),
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15)
                    : AppColors.outlineLight,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              height: 66,
              elevation: 0,
              backgroundColor: Colors.transparent,
              indicatorColor: isDark
                  ? theme.colorScheme.primary.withValues(alpha: 0.28)
                  : theme.colorScheme.primaryContainer,
              selectedIndex: selectedIndex.clamp(0, 4),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined, size: 22),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  label: navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.public_outlined, size: 22),
                  selectedIcon: Icon(
                    Icons.public_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  label: navMap,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.checklist_rounded, size: 22),
                  selectedIcon: Icon(
                    Icons.checklist_rtl_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  label: navBaggage,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.folder_shared_outlined, size: 22),
                  selectedIcon: Icon(
                    Icons.folder_shared_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  label: navVault,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.tune_outlined, size: 22),
                  selectedIcon: Icon(
                    Icons.tune_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  label: navSettings,
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

