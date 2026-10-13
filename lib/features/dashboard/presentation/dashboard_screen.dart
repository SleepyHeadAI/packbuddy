import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/sync_engine/sync_engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../budget/domain/country.dart';
import '../../budget/domain/trip.dart';
import '../../budget/presentation/controllers/trip_controller.dart';
import '../../budget/presentation/screens/trips_screen.dart';
import '../../budget/presentation/screens/trip_detail_screen.dart';
import '../../budget/presentation/screens/widgets/add_trip_sheet.dart';
import '../../settings/data/mock_revenuecat_service.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../vault/presentation/controllers/vault_controller.dart';
import '../../vault/presentation/screens/vault_screen.dart';
import '../../checklist/presentation/controllers/checklist_controller.dart';
import '../../checklist/presentation/screens/checklist_screen.dart';

/// Sophisticated, cinematic Dashboard for PackBuddy with live Riverpod state integration
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Automatic Cloud Sync & Local DB Refresh on Dashboard launch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(syncEngineProvider.notifier).performSync();
      if (mounted) {
        ref.read(tripControllerProvider.notifier).loadTrips();
        ref.read(vaultControllerProvider.notifier).loadDocuments();
        ref.read(checklistControllerProvider.notifier).loadItems();
      }
    });
  }

  String _getTimeBasedGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.goodMorning;
    } else if (hour < 18) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  static Route<T> _createSmoothRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final syncState = ref.watch(syncEngineProvider);
    final tripState = ref.watch(tripControllerProvider);
    final vaultState = ref.watch(vaultControllerProvider);
    final checklistState = ref.watch(checklistControllerProvider);
    final proState = ref.watch(proSubscriptionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat.MMMd(currentLocale.languageCode);

    // Dynamic Sync Badge UI attributes based on Riverpod SyncState
    String syncLabel;
    IconData syncIcon;
    Color syncBgColor;
    Color syncTextColor;

    switch (syncState.status) {
      case SyncStatus.syncing:
        syncLabel = l10n.syncInProgress;
        syncIcon = Icons.sync_rounded;
        syncBgColor = AppColors.infoPastel.withValues(alpha: 0.15);
        syncTextColor = AppColors.infoPastel;
        break;
      case SyncStatus.upToDate:
        syncLabel = l10n.syncUpToDate;
        syncIcon = Icons.cloud_done_rounded;
        syncBgColor = AppColors.successPastel.withValues(alpha: 0.15);
        syncTextColor = AppColors.successPastel;
        break;
      case SyncStatus.failed:
        syncLabel = l10n.syncFailed;
        syncIcon = Icons.cloud_off_rounded;
        syncBgColor = AppColors.errorPastel.withValues(alpha: 0.15);
        syncTextColor = AppColors.errorPastel;
        break;
      case SyncStatus.noInternet:
        syncLabel = l10n.offlineReady;
        syncIcon = Icons.wifi_off_rounded;
        syncBgColor = theme.colorScheme.secondaryContainer.withValues(alpha: 0.7);
        syncTextColor = theme.colorScheme.secondary;
        break;
      case SyncStatus.idle:
        syncLabel = l10n.syncReady;
        syncIcon = Icons.cloud_sync_rounded;
        syncBgColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.7);
        syncTextColor = theme.colorScheme.primary;
        break;
    }

    final tripCount = tripState.trips.length;
    final docCount = vaultState.documents.length;

    // Smart trip categorization for Dashboard banner
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Trip? featuredTrip;
    String featuredTripBadge = l10n.upcomingRoute.toUpperCase();

    if (tripState.trips.isNotEmpty) {
      // 1. Ongoing trip (today is between startDate and endDate inclusive)
      final ongoingTrips = tripState.trips.where((t) {
        final start = DateTime(t.startDate.year, t.startDate.month, t.startDate.day);
        final end = DateTime(t.endDate.year, t.endDate.month, t.endDate.day, 23, 59, 59);
        return now.isAfter(start) && now.isBefore(end);
      }).toList();

      if (ongoingTrips.isNotEmpty) {
        featuredTrip = ongoingTrips.first;
        featuredTripBadge = l10n.ongoingTrip.toUpperCase();
      } else {
        // 2. Upcoming trips in future (startDate >= today), sorted nearest first (ASC)
        final futureTrips = tripState.trips.where((t) {
          final start = DateTime(t.startDate.year, t.startDate.month, t.startDate.day);
          return start.isAfter(today) || start.isAtSameMomentAs(today);
        }).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

        if (futureTrips.isNotEmpty) {
          featuredTrip = futureTrips.first;
          featuredTripBadge = l10n.upcomingRoute.toUpperCase();
        } else {
          // 3. All trips are in the past: show the most recently completed trip
          final pastTrips = List<Trip>.from(tripState.trips)
            ..sort((a, b) => b.endDate.compareTo(a.endDate));
          featuredTrip = pastTrips.first;
          featuredTripBadge = l10n.lastTrip.toUpperCase();
        }
      }
    }

    final upcomingTrip = featuredTrip;
    final checklistCompletionRatio = checklistState.completionRatio;
    final checklistStatusColor = checklistCompletionRatio >= 1.0 && checklistState.totalCount > 0
        ? AppColors.successPastel
        : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Avatar with Status Dot
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.successPastel,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5, fontSize: 17),
              ),
            ),
            if (proState.isPro) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          // Aligned Notification Bell
          IconButton(
            icon: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 21),
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 1, right: 1),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: l10n.notifications,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.allNotificationsUpToDate),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          // Language Switcher Compact Pill
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showLanguageSelector(context, ref, currentLocale),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    L10n.getLanguageFlag(currentLocale.languageCode),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentLocale.languageCode.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Settings Shortcut
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 21),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: l10n.settings,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => AddTripSheet.show(context),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(l10n.addTrip),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          children: [
            // 1. Inspiring Hero Greeting Banner
            _HeroGreetingCard(
              greeting: _getTimeBasedGreeting(l10n),
              title: l10n.welcome,
              subtitle: l10n.welcomeSubtitle,
              syncLabel: syncLabel,
              syncIcon: syncIcon,
              syncBgColor: syncBgColor,
              syncTextColor: syncTextColor,
              onSyncTap: () {
                ref.read(syncEngineProvider.notifier).performSync();
              },
            ),
            const SizedBox(height: 20),

            // 2. Active / Upcoming Trip Card (or Quick Start Card)
            if (upcomingTrip != null) ...[
              _UpcomingTripHighlightCard(
                trip: upcomingTrip,
                badgeText: featuredTripBadge,
                dateFormat: dateFormat,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TripDetailScreen(trip: upcomingTrip),
                    ),
                  );
                },
              ),
            ] else ...[
              _EmptyTripsPromptCard(
                onPlanTrip: () => AddTripSheet.show(context),
              ),
            ],
            const SizedBox(height: 20),

            // 3. Bento Summary Grid (Trips Counter & Vault Counter)
            Row(
              children: [
                // Trips Bento Item
                Expanded(
                  child: _BentoStatCard(
                    title: l10n.trips,
                    count: '$tripCount',
                    description: l10n.multiCurrency,
                    icon: Icons.flight_takeoff_rounded,
                    accentColor: theme.colorScheme.primary,
                    gradientStart: theme.colorScheme.primary.withValues(alpha: 0.12),
                    onTap: () {
                      Navigator.of(context).push(
                        _createSmoothRoute(const TripsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),

                // Vault Bento Item
                Expanded(
                  child: _BentoStatCard(
                    title: l10n.vault,
                    count: '$docCount',
                    description: '🔒 ${l10n.offlineVault}',
                    icon: Icons.shield_outlined,
                    accentColor: theme.colorScheme.tertiary,
                    gradientStart: theme.colorScheme.tertiary.withValues(alpha: 0.12),
                    onTap: () {
                      Navigator.of(context).push(
                        _createSmoothRoute(const VaultScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3b. Luggage & Packing Bento Card (Progress & Airline Guide)
            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () {
                Navigator.of(context).push(
                  _createSmoothRoute(const ChecklistScreen()),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'checklist-hero-badge',
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: checklistStatusColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.luggage_rounded,
                            color: checklistStatusColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Hero(
                                tag: 'checklist-hero-title',
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Text(
                                    l10n.baggageAndChecklist,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              checklistState.totalCount == 0
                                  ? l10n.noItemsYet
                                  : '${checklistState.packedCount}/${checklistState.totalCount} ${l10n.itemsReady} (%${(checklistCompletionRatio * 100).toInt()})',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: checklistStatusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: checklistStatusColor.withValues(alpha: 0.4), width: 1),
                        ),
                        child: Text(
                          checklistState.totalCount == 0
                              ? l10n.listEmpty.toUpperCase()
                              : (checklistCompletionRatio >= 1.0 ? l10n.completed.toUpperCase() : l10n.preparing.toUpperCase()),
                          style: TextStyle(
                            color: checklistStatusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            width: constraints.maxWidth * checklistCompletionRatio.clamp(0.0, 1.0),
                            height: 7,
                            decoration: BoxDecoration(
                              color: checklistStatusColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Airline Limits & Responsibility Note (Completely overflow safe)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.flight_takeoff_rounded, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            checklistState.selectedAirline != null
                                ? '${checklistState.selectedAirline!.countryFlag} ${checklistState.selectedAirline!.airlineName} • Kabin ${checklistState.selectedAirline!.cabinLimitKg.toInt()} kg'
                                : l10n.standardBaggageLimitNote,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 12),

            // Features Hub
            Text(
              l10n.travelAssistant,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            _HubFeatureCard(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: theme.colorScheme.primary,
              iconContainerColor: theme.colorScheme.primaryContainer,
              title: l10n.budget,
              subtitle: tripCount == 0 ? l10n.budgetDescription : '$tripCount ${l10n.tripsPlanned}',
              badgeText: tripCount > 0 ? '$tripCount' : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TripsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _HubFeatureCard(
              icon: Icons.checklist_rtl_rounded,
              iconColor: checklistStatusColor,
              iconContainerColor: checklistStatusColor.withValues(alpha: 0.15),
              title: l10n.baggageAndChecklist,
              subtitle: checklistState.totalCount == 0
                  ? l10n.noItemsYet
                  : '${checklistState.packedCount}/${checklistState.totalCount} ${l10n.itemsReady} • %${(checklistCompletionRatio * 100).toInt()} ${l10n.completed}',
              badgeText: checklistState.totalCount > 0 ? '${checklistState.packedCount}/${checklistState.totalCount}' : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChecklistScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _HubFeatureCard(
              icon: Icons.folder_shared_rounded,
              iconColor: const Color(0xFF10B981),
              iconContainerColor: const Color(0xFF10B981).withValues(alpha: 0.15),
              title: l10n.vault,
              subtitle: docCount == 0 ? l10n.vaultDescription : '$docCount ${l10n.documentsSaved}',
              badgeText: docCount > 0 ? '$docCount' : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VaultScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _HubFeatureCard(
              icon: Icons.tune_rounded,
              iconColor: theme.colorScheme.secondary,
              iconContainerColor: theme.colorScheme.secondaryContainer,
              title: l10n.settings,
              subtitle: l10n.settingsDescription,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 28),

            // Footer Architecture Phase
            Center(
              child: Text(
                l10n.architecturePhase,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? theme.colorScheme.outlineVariant.withValues(alpha: 0.15)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 64,
            elevation: 0,
            backgroundColor: Colors.transparent,
            indicatorColor: theme.colorScheme.primaryContainer,
            selectedIndex: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              if (index == 0) {
                // Already on Dashboard
              } else if (index == 1) {
                Navigator.of(context).push(
                  _createSmoothRoute(const TripsScreen()),
                );
              } else if (index == 2) {
                Navigator.of(context).push(
                  _createSmoothRoute(const ChecklistScreen()),
                );
              } else if (index == 3) {
                Navigator.of(context).push(
                  _createSmoothRoute(const VaultScreen()),
                );
              } else if (index == 4) {
                Navigator.of(context).push(
                  _createSmoothRoute(const SettingsScreen()),
                );
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined, size: 22),
                selectedIcon: Icon(Icons.dashboard_rounded, size: 22, color: theme.colorScheme.primary),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.flight_takeoff_outlined, size: 22),
                selectedIcon: Icon(Icons.flight_takeoff_rounded, size: 22, color: theme.colorScheme.primary),
                label: l10n.navTrips,
              ),
              NavigationDestination(
                icon: const Icon(Icons.checklist_rounded, size: 22),
                selectedIcon: Icon(Icons.checklist_rtl_rounded, size: 22, color: theme.colorScheme.primary),
                label: l10n.navBaggage,
              ),
              NavigationDestination(
                icon: const Icon(Icons.folder_shared_outlined, size: 22),
                selectedIcon: Icon(Icons.folder_shared_rounded, size: 22, color: theme.colorScheme.primary),
                label: l10n.navVault,
              ),
              NavigationDestination(
                icon: const Icon(Icons.tune_outlined, size: 22),
                selectedIcon: Icon(Icons.tune_rounded, size: 22, color: theme.colorScheme.primary),
                label: l10n.navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref, Locale currentLocale) {
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
        final theme = Theme.of(ctx);
        final l10n = AppLocalizations.of(ctx)!;

        return RepaintBoundary(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.translate_rounded, size: 20, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.language,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '20 ${l10n.language}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: L10n.all.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                  itemBuilder: (context, index) {
                    final locale = L10n.all[index];
                    final isSelected = locale.languageCode == currentLocale.languageCode;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                      leading: Text(
                        L10n.getLanguageFlag(locale.languageCode),
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        L10n.getLanguageName(locale.languageCode),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                          : null,
                      onTap: () {
                        ref.read(localeProvider.notifier).setLocale(locale);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }
}

/// Cinematic Hero Greeting Banner
class _HeroGreetingCard extends StatelessWidget {
  final String greeting;
  final String title;
  final String subtitle;
  final String syncLabel;
  final IconData syncIcon;
  final Color syncBgColor;
  final Color syncTextColor;
  final VoidCallback onSyncTap;

  const _HeroGreetingCard({
    required this.greeting,
    required this.title,
    required this.subtitle,
    required this.syncLabel,
    required this.syncIcon,
    required this.syncBgColor,
    required this.syncTextColor,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(22),
      gradient: LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF131B2E),
                const Color(0xFF0F172A),
              ]
            : [
                const Color(0xFFFFFFFF),
                const Color(0xFFF1F5F9),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  greeting,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onSyncTap,
                borderRadius: BorderRadius.circular(14),
                child: StatusBadge(
                  label: syncLabel,
                  icon: syncIcon,
                  backgroundColor: syncBgColor,
                  textColor: syncTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Highlight Card for the Next/Active Trip
class _UpcomingTripHighlightCard extends StatelessWidget {
  final dynamic trip;
  final String badgeText;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const _UpcomingTripHighlightCard({
    required this.trip,
    required this.badgeText,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final country = Country.findByCode(trip.countryCode);
    final transportIcon = TripsScreen.getTransportIcon(trip.transportMode);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF1E293B),
                const Color(0xFF0F172A),
              ]
            : [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                Colors.white,
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'trip-transport-icon-${trip.id}',
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(transportIcon, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          badgeText,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (country != null) ...[
                          const SizedBox(width: 6),
                          Text(country.flag, style: const TextStyle(fontSize: 12)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Hero(
                      tag: 'trip-title-${trip.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          trip.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trip.destination,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppDateFormatter.formatDateRange(
                        trip.startDate,
                        trip.endDate,
                        locale: Localizations.localeOf(context).languageCode,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Prompt card when no trips are scheduled yet
class _EmptyTripsPromptCard extends StatelessWidget {
  final VoidCallback onPlanTrip;

  const _EmptyTripsPromptCard({required this.onPlanTrip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flight_takeoff_rounded,
              size: 24,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.noTripsYet,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.createFirstTrip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onPlanTrip,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(l10n.plan, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// Bento-Grid Stat Card
class _BentoStatCard extends StatelessWidget {
  final String title;
  final String count;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color gradientStart;
  final VoidCallback onTap;

  const _BentoStatCard({
    required this.title,
    required this.count,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.gradientStart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gradientStart,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              Flexible(
                child: Text(
                  count,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}



/// Modern Feature Hub Row Card
class _HubFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconContainerColor;
  final String title;
  final String subtitle;
  final String? badgeText;
  final VoidCallback onTap;

  const _HubFeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconContainerColor,
    required this.title,
    required this.subtitle,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconContainerColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconContainerColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText!,
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
