import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/sync_engine/sync_engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../budget/domain/country.dart';
import '../../budget/domain/city_localization.dart';
import '../../budget/domain/trip.dart';
import '../../budget/presentation/controllers/trip_controller.dart';
import '../../budget/presentation/screens/trips_screen.dart';
import '../../budget/presentation/screens/trip_detail_screen.dart';
import '../../budget/presentation/screens/trip_comparison_screen.dart';
import '../../budget/presentation/screens/widgets/add_trip_sheet.dart';
import '../../settings/data/mock_revenuecat_service.dart';
import '../../vault/presentation/controllers/vault_controller.dart';
import '../../checklist/presentation/controllers/checklist_controller.dart';
import '../../auth/auth_controller.dart';
import '../../budget/presentation/widgets/currency_converter_card.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../core/services/app_widget_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../travel_map/presentation/controllers/travel_map_controller.dart';
import '../../../core/l10n/language_selector_sheet.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../vault/presentation/screens/vault_screen.dart';
import 'navigation_provider.dart';
import 'widgets/notifications_center_sheet.dart';
import 'widgets/bento_hub_grid.dart';

/// Sophisticated, cinematic Dashboard for PackBuddy with live Riverpod state integration
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Automatic Cloud Sync & Local DB Refresh on Dashboard launch (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccountRestored();
      _triggerSyncAndRefresh();
    });
  }

  bool _hasUnreadNotifications(List<Trip> trips) {
    final lastRead = PreferencesService.instance.getLastReadNotificationsAt();
    final now = DateTime.now();
    final hasUpcoming = trips.any((t) =>
        !t.isDeleted &&
        t.startDate.isAfter(now.subtract(const Duration(hours: 12))) &&
        t.startDate.difference(now).inDays <= 7);
    if (hasUpcoming && (now.millisecondsSinceEpoch - lastRead) > 43200000) {
      return true;
    }
    final history = PreferencesService.instance.getNotificationHistory();
    if (history.isNotEmpty) {
      try {
        final latest = jsonDecode(history.first) as Map<String, dynamic>;
        final ts = latest['timestamp'] as int? ?? 0;
        if (ts > lastRead) return true;
      } catch (_) {}
    }
    return false;
  }

  void _checkAccountRestored() {
    final authState = ref.read(authControllerProvider);
    if (authState.wasAccountRestoredFromDeletion) {
      ref.read(authControllerProvider.notifier).acknowledgeAccountRestored();
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountRestoredNotice),
            backgroundColor: AppColors.successPastel,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerSyncAndRefresh();
    }
  }

  void _triggerSyncAndRefresh() {
    // Non-blocking automatic cloud sync
    ref.read(syncEngineProvider.notifier).performSync().then((_) {
      if (mounted) {
        ref.read(tripControllerProvider.notifier).loadTrips().then((_) {
          final trips = ref.read(tripControllerProvider).trips;
          final items = ref.read(checklistControllerProvider).items;
          if (trips.isNotEmpty) {
            AppWidgetService.updateWidgetPayload(
              upcomingTrip: trips.first,
              items: items,
            );
          }
        });
        ref.read(vaultControllerProvider.notifier).loadDocuments();
        ref.read(checklistControllerProvider.notifier).loadItems();
        ref.read(travelMapControllerProvider.notifier).loadCountries();
      }
    }).catchError((_) {});
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
    final travelMapState = ref.watch(travelMapControllerProvider);
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
        titleSpacing: 20,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppLogo.transparent(size: 28),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                l10n.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  fontSize: 22,
                ),
              ),
            ),
            if (proState.isPro) ...[
              const SizedBox(width: 8),
              AppPulse(
                minScale: 0.94,
                maxScale: 1.05,
                duration: const Duration(milliseconds: 1600),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
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
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
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
                if (_hasUnreadNotifications(tripState.trips))
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 1, right: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.errorPastel,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: l10n.notifications,
            onPressed: () async {
              await NotificationsCenterSheet.show(context);
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(width: 4),
          // Language Switcher Compact Pill
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => showLanguageSelectorSheet(context, ref, currentLocale),
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
                _createSmoothRoute(const SettingsScreen()),
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
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          scrollCacheExtent: const ScrollCacheExtent.pixels(800.0),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          children: [
            // 1. My Trips Section (Seyahatler) at the very top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.flight_takeoff_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.trips,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (tripCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$tripCount',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        _createSmoothRoute(const TripsScreen()),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.viewAll,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Active / Upcoming Trip Card (or Quick Start Card)
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
              if (tripState.trips.length > 1) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: tripState.trips.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final t = tripState.trips[index];
                      final isCurrent = t.id == upcomingTrip.id;
                      final tCountry = Country.findByCode(t.countryCode);
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TripDetailScreen(trip: t),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrent
                                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (tCountry != null) ...[
                                Text(tCountry.flag, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                t.destination.isNotEmpty
                                    ? CityLocalization.localizeDestination(
                                        t.destination,
                                        Localizations.localeOf(context).languageCode,
                                      )
                                    : t.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                  color: isCurrent
                                      ? theme.colorScheme.primary
                                      : (isDark ? Colors.white70 : Colors.black87),
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
            ] else ...[
              _EmptyTripsPromptCard(
                onPlanTrip: () => AddTripSheet.show(context),
              ),
            ],
            const SizedBox(height: 18),

            // 2. Inspiring Hero Greeting Banner
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

            // Luggage & Packing Card (Checklist progress for active trip)
            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () {
                ref.read(mainNavigationIndexProvider.notifier).state = 2;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                  // Animated Progress Bar with subtle glow and easeOutCubic curve
                  AppAnimatedProgressBar(
                    progress: checklistCompletionRatio,
                    height: 7,
                    backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    foregroundColor: checklistStatusColor,
                    duration: const Duration(milliseconds: 450),
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
                                ? '${checklistState.selectedAirline!.countryFlag} ${checklistState.selectedAirline!.airlineName} • ${l10n.cabinBaggage} ${checklistState.selectedAirline!.cabinLimitKg.toInt()} kg'
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

            // Bento Grid for Discovery & Travel Features
            BentoHubGrid(
              tripCount: tripCount,
              docCount: docCount,
              visitedCountriesCount: travelMapState.visitedCount,
              wishlistCount: travelMapState.wishlistCount,
              worldPercentage: travelMapState.worldPercentage,
              onOpenMap: () {
                ref.read(mainNavigationIndexProvider.notifier).state = 1;
              },
              onOpenTrips: () {
                Navigator.of(context).push(
                  _createSmoothRoute(const TripsScreen()),
                );
              },
              onOpenCurrency: () => CurrencyConverterCard.showAsModal(context),
              onOpenComparison: () {
                Navigator.of(context).push(
                  _createSmoothRoute(const TripComparisonScreen()),
                );
              },
              onOpenVault: () {
                Navigator.of(context).push(
                  _createSmoothRoute(const VaultScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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

    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'trip-transport-icon-${trip.id}',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(transportIcon, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            badgeText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          CityLocalization.localizeDestination(
                            trip.destination,
                            Localizations.localeOf(context).languageCode,
                          ),
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
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          AppDateFormatter.formatDateRange(
                            trip.startDate,
                            trip.endDate,
                            locale: Localizations.localeOf(context).languageCode,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      onTap: onPlanTrip,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.flight_takeoff_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.noTripsYet.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.createFirstTrip,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onPlanTrip,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(60, 34),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  visualDensity: VisualDensity.compact,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.plan,
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore_outlined,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.noTripsSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}






