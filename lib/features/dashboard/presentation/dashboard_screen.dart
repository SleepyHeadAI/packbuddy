import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/sync_engine/sync_engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
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
import '../../vault/presentation/screens/vault_screen.dart';
import '../../checklist/presentation/controllers/checklist_controller.dart';
import '../../checklist/presentation/screens/checklist_screen.dart';
import '../../auth/auth_controller.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../core/services/app_widget_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../travel_map/presentation/controllers/travel_map_controller.dart';
import '../../travel_map/presentation/screens/travel_map_screen.dart';
import '../../../core/l10n/language_selector_sheet.dart';
import 'widgets/notifications_center_sheet.dart';
import 'dashboard_localization.dart';
import 'widgets/horizontal_currency_converter_card.dart';
import 'widgets/dashboard_customize_sheet.dart';
import 'widgets/dashboard_mini_cards.dart';
import '../../../shared/widgets/quick_actions_sheet.dart';
import '../../../shared/widgets/floating_action_button_location.dart';
import '../../profile/presentation/screens/profile_screen.dart';
import '../../profile/presentation/controllers/profile_controller.dart';
import '../../profile/presentation/widgets/user_avatar.dart';
import '../../profile/presentation/screens/widgets/collaborator_avatar_stack.dart';
import 'package:packbuddy/features/search/presentation/screens/global_search_screen.dart';

/// Customizable, clean, and elegant Dashboard for PackBuddy with live Riverpod state integration.
///
/// Top: Fixed horizontal greeting banner (Welcome, time-based greeting, live sync, customize trigger).
/// Body: Reorderable sections (Active Trip, Baggage Checklist, Live Currency Converter, Mini Boxes).
/// Graceful fallback: If an item is missing or empty, the lower sections automatically slide up.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  final GlobalKey _fabKey = GlobalKey();
  late List<String> _sectionOrder;
  late Set<String> _hiddenSections;

  static final Map<String, DateFormat> _mmmDateFormatCache = {};
  static final Map<String, DateFormat> _ymmmDateFormatCache = {};

  static DateFormat _getCachedMMMd(String lang) {
    return _mmmDateFormatCache.putIfAbsent(lang, () => DateFormat.MMMd(lang));
  }

  static DateFormat _getCachedYMMMd(String lang) {
    return _ymmmDateFormatCache.putIfAbsent(lang, () => DateFormat.yMMMMd(lang));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _sectionOrder = PreferencesService.instance.getDashboardSectionOrder();
    _hiddenSections = PreferencesService.instance.getDashboardHiddenSections();

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

  String _getTimeBasedGreeting(AppLocalizations l10n, String lang) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return l10n.goodMorning;
    } else if (hour >= 12 && hour < 18) {
      return l10n.goodAfternoon;
    } else if (hour >= 18 && hour < 23) {
      return l10n.goodEvening;
    } else {
      return DashboardLocalization.goodNight(lang);
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

  void _openCustomizeSheet() {
    DashboardCustomizeSheet.show(
      context,
      currentOrder: _sectionOrder,
      hiddenSections: _hiddenSections,
      onOrderChanged: (newOrder) async {
        setState(() => _sectionOrder = newOrder);
        await PreferencesService.instance.setDashboardSectionOrder(newOrder);
      },
      onHiddenChanged: (newHidden) async {
        setState(() => _hiddenSections = newHidden);
        await PreferencesService.instance.setDashboardHiddenSections(newHidden);
      },
      onResetToDefault: () async {
        await PreferencesService.instance.resetDashboardCustomization();
        setState(() {
          _sectionOrder = PreferencesService.instance.getDashboardSectionOrder();
          _hiddenSections = PreferencesService.instance.getDashboardHiddenSections();
        });
      },
    );
  }

  bool _isMiniCard(String id) {
    return id == 'mini_travel_map' ||
        id == 'mini_vault' ||
        id == 'mini_all_trips' ||
        id == 'mini_trip_comparison';
  }

  Trip? _findFeaturedTrip(List<Trip> trips, DateTime now, DateTime today) {
    if (trips.isEmpty) return null;

    // 1. Ongoing trip
    final ongoingTrips = trips.where((t) {
      final start = DateTime(t.startDate.year, t.startDate.month, t.startDate.day);
      final end = DateTime(t.endDate.year, t.endDate.month, t.endDate.day, 23, 59, 59);
      return now.isAfter(start) && now.isBefore(end);
    }).toList();

    if (ongoingTrips.isNotEmpty) {
      return ongoingTrips.first;
    }

    // 2. Upcoming trips in future (startDate >= today)
    final futureTrips = trips.where((t) {
      final start = DateTime(t.startDate.year, t.startDate.month, t.startDate.day);
      return start.isAfter(today) || start.isAtSameMomentAs(today);
    }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    if (futureTrips.isNotEmpty) {
      return futureTrips.first;
    }

    // 3. Fallback: most recently completed trip
    final pastTrips = List<Trip>.from(trips)
      ..sort((a, b) => b.endDate.compareTo(a.endDate));
    return pastTrips.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;
    final syncState = ref.watch(syncEngineProvider);
    final tripState = ref.watch(tripControllerProvider);
    final vaultState = ref.watch(vaultControllerProvider);
    final checklistState = ref.watch(checklistControllerProvider);
    final proState = ref.watch(proSubscriptionProvider);
    final travelMapState = ref.watch(travelMapControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = _getCachedMMMd(lang);

    // Sync Badge Styling with concise banner labels
    String syncLabel;
    IconData syncIcon;
    Color syncBgColor;
    Color syncTextColor;

    switch (syncState.status) {
      case SyncStatus.syncing:
        syncLabel = DashboardLocalization.syncStatusBanner(lang, 'syncing');
        syncIcon = AppIcons.refresh;
        syncBgColor = AppColors.infoPastel.withValues(alpha: 0.15);
        syncTextColor = AppColors.infoPastel;
        break;
      case SyncStatus.upToDate:
        syncLabel = DashboardLocalization.syncStatusBanner(lang, 'upToDate');
        syncIcon = AppIcons.cloudDone;
        syncBgColor = AppColors.successPastel.withValues(alpha: 0.15);
        syncTextColor = AppColors.successPastel;
        break;
      case SyncStatus.failed:
        syncLabel = DashboardLocalization.syncStatusBanner(lang, 'failed');
        syncIcon = AppIcons.cloudOff;
        syncBgColor = AppColors.errorPastel.withValues(alpha: 0.15);
        syncTextColor = AppColors.errorPastel;
        break;
      case SyncStatus.noInternet:
        syncLabel = DashboardLocalization.syncStatusBanner(lang, 'noInternet');
        syncIcon = AppIcons.cloudOff;
        syncBgColor = theme.colorScheme.secondaryContainer.withValues(alpha: 0.7);
        syncTextColor = theme.colorScheme.secondary;
        break;
      case SyncStatus.idle:
        syncLabel = DashboardLocalization.syncStatusBanner(lang, 'idle');
        syncIcon = AppIcons.cloudSync;
        syncBgColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.7);
        syncTextColor = theme.colorScheme.primary;
        break;
    }

    final tripCount = tripState.trips.length;
    final docCount = vaultState.documents.length;

    // Active / Upcoming Trip Resolution
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcomingTrip = _findFeaturedTrip(tripState.trips, now, today);

    String featuredTripBadge = l10n.upcomingRoute.toUpperCase();
    if (upcomingTrip != null) {
      final start = DateTime(upcomingTrip.startDate.year, upcomingTrip.startDate.month, upcomingTrip.startDate.day);
      final end = DateTime(upcomingTrip.endDate.year, upcomingTrip.endDate.month, upcomingTrip.endDate.day, 23, 59, 59);
      if (now.isAfter(start) && now.isBefore(end)) {
        featuredTripBadge = l10n.ongoingTrip.toUpperCase();
      } else if (today.isAfter(end)) {
        featuredTripBadge = l10n.lastTrip.toUpperCase();
      }
    }

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
          // Notification Bell
          IconButton(
            icon: Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(AppIcons.notification, size: 20),
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
              AppHaptics.light();
              await NotificationsCenterSheet.show(context);
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(width: 4),

          // Language Switcher Pill
          BouncyPressable(
            scaleFactor: 0.95,
            onTap: () {
              AppHaptics.light();
              showLanguageSelectorSheet(context, ref, currentLocale);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceRaisedDark
                    : AppColors.surfaceRaisedLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight,
                  width: 0.8,
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
                    style: AppTypography.mono(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      tabularFigures: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        heroTag: null,
        elevation: 3,
        backgroundColor: AppColors.brandAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        onPressed: () {
          AppHaptics.light();
          QuickActionsSheet.showForDashboard(
            context,
            ref: ref,
            activeTrip: upcomingTrip,
            fabKey: _fabKey,
          );
        },
        child: const Icon(AppIcons.add, size: 24),
      ),
      floatingActionButtonLocation: kFloatingActionButtonAboveFloatingBar,
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            math.max(140.0, MediaQuery.of(context).padding.bottom + 120.0),
          ),
          children: [
            // =========================================================================
            // 1. FIXED TOP: Horizontal Greeting & Live Sync Header Bar
            // =========================================================================
            _HorizontalGreetingBar(
              greeting: _getTimeBasedGreeting(l10n, lang),
              userName: authState.user?.displayName,
              photoUrl: profileState.profile?.photoUrl,
              subtitle: _getCachedYMMMd(lang).format(now),
              onProfileTap: () {
                Navigator.of(context).push(
                  _createSmoothRoute(const ProfileScreen(avatarHeroTag: 'dashboard-profile-avatar')),
                );
              },
              onSearchTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
                );
              },
              syncLabel: syncLabel,
              syncIcon: syncIcon,
              syncBgColor: syncBgColor,
              syncTextColor: syncTextColor,
              isSyncing: syncState.status == SyncStatus.syncing,
              onSyncTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                messenger.clearSnackBars();
                final notifier = ref.read(syncEngineProvider.notifier);
                await notifier.forceSync();
                if (!mounted) return;
                final sync = ref.read(syncEngineProvider);
                if (sync.status == SyncStatus.upToDate) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(AppIcons.checkCircle, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.syncUpToDate),
                        ],
                      ),
                      backgroundColor: AppColors.successPastel,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (sync.status == SyncStatus.failed) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(AppIcons.error, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sync.errorMessage != null && sync.errorMessage!.isNotEmpty
                                  ? '${l10n.syncFailed}: ${sync.errorMessage}'
                                  : l10n.syncFailed,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.errorPastel,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: l10n.syncNow,
                        textColor: Colors.white,
                        onPressed: () => notifier.forceSync(),
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              onCustomizeTap: _openCustomizeSheet,
            ),
            const SizedBox(height: AppSpacing.md),

            // =========================================================================
            // 2+. REORDERABLE SECTIONS (With graceful fallback sliding)
            // =========================================================================
            ..._buildDynamicSections(
              order: _sectionOrder,
              hidden: _hiddenSections,
              upcomingTrip: upcomingTrip,
              featuredTripBadge: featuredTripBadge,
              tripState: tripState,
              checklistState: checklistState,
              checklistCompletionRatio: checklistCompletionRatio,
              checklistStatusColor: checklistStatusColor,
              travelMapState: travelMapState,
              docCount: docCount,
              tripCount: tripCount,
              dateFormat: dateFormat,
              theme: theme,
              isDark: isDark,
              l10n: l10n,
            ),
          ],
        ),
      ),
    );
  }

  /// Evaluates user order, filters hidden/empty sections, and pairs consecutive mini cards
  List<Widget> _buildDynamicSections({
    required List<String> order,
    required Set<String> hidden,
    required Trip? upcomingTrip,
    required String featuredTripBadge,
    required dynamic tripState,
    required dynamic checklistState,
    required double checklistCompletionRatio,
    required Color checklistStatusColor,
    required dynamic travelMapState,
    required int docCount,
    required int tripCount,
    required DateFormat dateFormat,
    required ThemeData theme,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    // 1. Identify which sections are eligible to display
    final List<String> activeIds = [];

    for (final id in order) {
      if (hidden.contains(id)) continue;
      // Retain active_trip so if upcomingTrip == null, the empty state hero card renders
      activeIds.add(id);
    }

    final List<Widget> widgets = [];
    int i = 0;

    while (i < activeIds.length) {
      final currentId = activeIds[i];

      if (_isMiniCard(currentId)) {
        // Check if next is also a mini card -> pair them side by side in a 2-column Row
        if (i + 1 < activeIds.length && _isMiniCard(activeIds[i + 1])) {
          final nextId = activeIds[i + 1];
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _renderSectionById(
                        id: currentId,
                        isMini: true,
                        upcomingTrip: upcomingTrip,
                        featuredTripBadge: featuredTripBadge,
                        tripState: tripState,
                        checklistState: checklistState,
                        checklistCompletionRatio: checklistCompletionRatio,
                        checklistStatusColor: checklistStatusColor,
                        travelMapState: travelMapState,
                        docCount: docCount,
                        tripCount: tripCount,
                        dateFormat: dateFormat,
                        theme: theme,
                        isDark: isDark,
                        l10n: l10n,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _renderSectionById(
                        id: nextId,
                        isMini: true,
                        upcomingTrip: upcomingTrip,
                        featuredTripBadge: featuredTripBadge,
                        tripState: tripState,
                        checklistState: checklistState,
                        checklistCompletionRatio: checklistCompletionRatio,
                        checklistStatusColor: checklistStatusColor,
                        travelMapState: travelMapState,
                        docCount: docCount,
                        tripCount: tripCount,
                        dateFormat: dateFormat,
                        theme: theme,
                        isDark: isDark,
                        l10n: l10n,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          i += 2;
        } else {
          // Single standalone mini card
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _renderSectionById(
                id: currentId,
                isMini: false,
                upcomingTrip: upcomingTrip,
                featuredTripBadge: featuredTripBadge,
                tripState: tripState,
                checklistState: checklistState,
                checklistCompletionRatio: checklistCompletionRatio,
                checklistStatusColor: checklistStatusColor,
                travelMapState: travelMapState,
                docCount: docCount,
                tripCount: tripCount,
                dateFormat: dateFormat,
                theme: theme,
                isDark: isDark,
                l10n: l10n,
              ),
            ),
          );
          i += 1;
        }
      } else {
        // Full width section (Active Trip, Luggage Checklist, Live Currency Converter)
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _renderSectionById(
              id: currentId,
              isMini: false,
              upcomingTrip: upcomingTrip,
              featuredTripBadge: featuredTripBadge,
              tripState: tripState,
              checklistState: checklistState,
              checklistCompletionRatio: checklistCompletionRatio,
              checklistStatusColor: checklistStatusColor,
              travelMapState: travelMapState,
              docCount: docCount,
              tripCount: tripCount,
              dateFormat: dateFormat,
              theme: theme,
              isDark: isDark,
              l10n: l10n,
            ),
          ),
        );
        i += 1;
      }
    }

    return [
      for (int idx = 0; idx < widgets.length; idx++)
        AppFadeSlide.staggered(
          key: ValueKey('dash_staggered_$idx'),
          index: idx,
          baseDelay: const Duration(milliseconds: 35),
          slideOffset: 12.0,
          child: widgets[idx],
        ),
    ];
  }

  Widget _renderSectionById({
    required String id,
    required bool isMini,
    required Trip? upcomingTrip,
    required String featuredTripBadge,
    required dynamic tripState,
    required dynamic checklistState,
    required double checklistCompletionRatio,
    required Color checklistStatusColor,
    required dynamic travelMapState,
    required int docCount,
    required int tripCount,
    required DateFormat dateFormat,
    required ThemeData theme,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    switch (id) {
      case 'active_trip':
        if (upcomingTrip == null) {
          return _EmptyTripHeroCard(
            onAddTrip: () {
              AddTripSheet.show(context);
            },
          );
        }
        return _UpcomingTripHighlightCard(
          trip: upcomingTrip,
          badgeText: featuredTripBadge,
          dateFormat: dateFormat,
          allTrips: tripState.trips,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TripDetailScreen(trip: upcomingTrip),
              ),
            );
          },
        );

      case 'luggage_checklist':
        return _LuggageChecklistCard(
          checklistState: checklistState,
          checklistCompletionRatio: checklistCompletionRatio,
          checklistStatusColor: checklistStatusColor,
          isDark: isDark,
          l10n: l10n,
          onTap: () {
            Navigator.of(context).push(
              _createSmoothRoute(const ChecklistScreen(isTabMode: false)),
            );
          },
        );

      case 'currency_converter':
        return const HorizontalCurrencyConverterCard();

      case 'mini_travel_map':
        return DashboardMiniTravelMap(
          visitedCountriesCount: travelMapState.visitedCount,
          wishlistCount: travelMapState.wishlistCount,
          worldPercentage: travelMapState.worldPercentage,
          isFullWidth: !isMini,
          onTap: () {
            Navigator.of(context).push(
              _createSmoothRoute(const TravelMapScreen(isTabMode: false)),
            );
          },
        );

      case 'mini_vault':
        return DashboardMiniVault(
          docCount: docCount,
          isFullWidth: !isMini,
          onTap: () {
            Navigator.of(context).push(
              _createSmoothRoute(const VaultScreen(isTabMode: false)),
            );
          },
        );

      case 'mini_all_trips':
        return DashboardMiniAllTrips(
          tripCount: tripCount,
          isFullWidth: !isMini,
          onTap: () {
            Navigator.of(context).push(
              _createSmoothRoute(const TripsScreen()),
            );
          },
        );

      case 'mini_trip_comparison':
        return DashboardMiniTripComparison(
          isFullWidth: !isMini,
          onTap: () {
            Navigator.of(context).push(
              _createSmoothRoute(const TripComparisonScreen()),
            );
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Horizontal Greeting and Live Sync Header Bar placed permanently at the top
class _HorizontalGreetingBar extends StatelessWidget {
  final String greeting;
  final String? userName;
  final String? photoUrl;
  final String subtitle;
  final String syncLabel;
  final IconData syncIcon;
  final Color syncBgColor;
  final Color syncTextColor;
  final bool isSyncing;
  final VoidCallback onSyncTap;
  final VoidCallback onCustomizeTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;

  const _HorizontalGreetingBar({
    required this.greeting,
    this.userName,
    this.photoUrl,
    required this.subtitle,
    required this.syncLabel,
    required this.syncIcon,
    required this.syncBgColor,
    required this.syncTextColor,
    this.isSyncing = false,
    required this.onSyncTap,
    required this.onCustomizeTap,
    this.onProfileTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final hour = DateTime.now().hour;
    final isDayTime = hour >= 5 && hour < 18;
    final cleanGreeting = DashboardLocalization.timeGreetingClean(lang, hour);
    final travelerTitle = DashboardLocalization.travelerTitle(lang);

    final displayName = (userName != null && userName!.trim().isNotEmpty)
        ? userName!.trim()
        : travelerTitle;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Time Greeting with Vector Icon (Left) & Sync Status + Search + Customize (Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDayTime ? AppIcons.sun : AppIcons.moon,
                      size: 13.5,
                      color: isDayTime ? const Color(0xFFF59E0B) : const Color(0xFF818CF8),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        cleanGreeting,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          letterSpacing: 0.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Cloud Sync Status Pill (Anchored cleanly to the right cluster)
              InkWell(
                onTap: () {
                  AppHaptics.selectionClick();
                  onSyncTap();
                },
                borderRadius: BorderRadius.circular(14),
                child: StatusBadge(
                  label: syncLabel,
                  icon: syncIcon,
                  backgroundColor: syncBgColor,
                  textColor: syncTextColor,
                  isSpinning: isSyncing,
                  maxWidth: 96,
                  useMono: false,
                ),
              ),
              const SizedBox(width: 6),

              // Global Search Button
              if (onSearchTap != null) ...[
                BouncyPressable(
                  scaleFactor: 0.92,
                  onTap: () {
                    AppHaptics.light();
                    onSearchTap!();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight,
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      AppIcons.search,
                      size: 15,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // Customize Home Layout Button
              BouncyPressable(
                scaleFactor: 0.92,
                onTap: () {
                  AppHaptics.light();
                  onCustomizeTap();
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight,
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    AppIcons.tune,
                    size: 15,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: User Avatar + User Name (Left) + Formatted Date Pill (Right, optically aligned flush to right edge)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: BouncyPressable(
                  scaleFactor: 0.98,
                  onTap: onProfileTap != null
                      ? () {
                          AppHaptics.light();
                          onProfileTap!();
                        }
                      : null,
                  child: Row(
                    children: [
                      Hero(
                        tag: 'dashboard-profile-avatar',
                        child: UserAvatar(
                          photoUrl: photoUrl,
                          displayName: displayName,
                          size: 28,
                          isAnimated: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              AppIcons.chevronRight,
                              size: 16,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Formatted Date Badge (Flush with right edge of card)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      AppIcons.calendar,
                      size: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Elegant empty state hero card displayed when the user has no trips planned yet.
class _EmptyTripHeroCard extends StatelessWidget {
  final VoidCallback onAddTrip;

  const _EmptyTripHeroCard({
    required this.onAddTrip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                AppIcons.flight,
                size: 24,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noTripsYet,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.noTripsSubtitle,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          AppButton.primary(
            label: l10n.addTrip,
            leadingIcon: AppIcons.add,
            onPressed: () {
              AppHaptics.light();
              onAddTrip();
            },
          ),
        ],
      ),
    );
  }
}

/// Highlight Card for the Next/Active Trip with Boarding Pass Aesthetic
class _UpcomingTripHighlightCard extends StatelessWidget {
  final dynamic trip;
  final String badgeText;
  final DateFormat dateFormat;
  final List<Trip> allTrips;
  final VoidCallback onTap;

  const _UpcomingTripHighlightCard({
    required this.trip,
    required this.badgeText,
    required this.dateFormat,
    required this.allTrips,
    required this.onTap,
  });

  /// Strips any leading emoji flags to prevent duplicate flag rendering
  static String stripLeadingFlags(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    final runes = trimmed.runes.toList();
    int i = 0;
    while (i + 1 < runes.length &&
        runes[i] >= 0x1F1E6 && runes[i] <= 0x1F1FF &&
        runes[i + 1] >= 0x1F1E6 && runes[i + 1] <= 0x1F1FF) {
      i += 2;
      while (i < runes.length && (runes[i] == 0x20 || runes[i] == 0x00A0)) {
        i++;
      }
    }
    return String.fromCharCodes(runes.sublist(i)).trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLight = !isDark;
    final country = Country.findByCode(trip.countryCode);
    final tripCountries = (trip is Trip) ? (trip as Trip).countries : <Country>[];
    final rawTransportIcon = TripsScreen.getTransportIcon(trip.transportMode);
    // Distinct Journey/Transport Identity: Route card must never duplicate luggage icon
    final transportIcon = (rawTransportIcon == AppIcons.luggage)
        ? AppIcons.flight
        : rawTransportIcon;
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

    // Remaining Days calculation
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripStart = DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);
    final tripEnd = DateTime(trip.endDate.year, trip.endDate.month, trip.endDate.day, 23, 59, 59);

    String countdownPill;
    if (now.isAfter(tripStart) && now.isBefore(tripEnd)) {
      countdownPill = l10n.ongoingTrip;
    } else {
      final diff = tripStart.difference(today).inDays;
      if (diff <= 0) {
        countdownPill = l10n.today;
      } else {
        countdownPill = l10n.daysRemaining(diff);
      }
    }

    final pillTextColor = isLight ? AppColors.brandAccentTextLight : AppColors.brandAccentTextDark;
    final pillBgColor = isLight
        ? AppColors.brandAccent.withValues(alpha: 0.12)
        : AppColors.brandAccent.withValues(alpha: 0.18);

    final rawDest = CityLocalization.localizeDestination(trip.destination, lang);
    final cleanDest = stripLeadingFlags(rawDest);

    return BouncyPressable(
      scaleFactor: 0.985,
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: AppCard(
        padding: const EdgeInsets.all(16),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.surfaceBaseDark,
                  AppColors.brandAccent.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white,
                  AppColors.brandAccent.withValues(alpha: 0.07),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boarding Pass Header: Transport Badge + Route Status + Countdown Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'trip-transport-icon-${trip.id}',
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(transportIcon, color: theme.colorScheme.onPrimary, size: 20),
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
                              style: AppTypography.labelSmall.copyWith(
                                color: theme.colorScheme.primary,
                                letterSpacing: 0.8,
                                fontSize: 9.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tripCountries.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            Wrap(
                              spacing: 2,
                              children: tripCountries
                                  .map((c) => Text(c.flag, style: const TextStyle(fontSize: 12)))
                                  .toList(),
                            ),
                          ] else if (country != null) ...[
                            const SizedBox(width: 5),
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
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Countdown Pill & View All Link
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: pillBgColor,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: pillTextColor.withValues(alpha: 0.25),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        countdownPill,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: pillTextColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    BouncyPressable(
                      scaleFactor: 0.95,
                      onTap: () {
                        AppHaptics.light();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const TripsScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.viewAll,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              AppIcons.chevronRight,
                              size: 11,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Perforated Ticket Divider (Boarding Pass Aesthetic)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const dashWidth = 4.0;
                  const dashSpace = 4.0;
                  final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(count, (_) {
                      return SizedBox(
                        width: dashWidth,
                        height: 0.8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.borderSubtleDark
                                : AppColors.borderSubtleLight,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // Destination & Date Strip (Clean metadata row with guaranteed NO flag duplication)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        AppIcons.location,
                        size: 13.5,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Hero(
                          tag: 'trip-destination-${trip.id}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              cleanDest.isNotEmpty ? cleanDest : trip.title,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.calendar,
                        size: 12.5,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          AppDateFormatter.formatDateRange(
                            trip.startDate,
                            trip.endDate,
                            locale: lang,
                          ),
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
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

            if (trip.collaborators.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    AppIcons.users,
                    size: 13,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    l10n.sharedTrip,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CollaboratorAvatarStack(
                    collaborators: trip.collaborators,
                    size: 20,
                  ),
                ],
              ),
            ],

            // Secondary Trips horizontal chips (with strict flag deduplication)
            if (allTrips.length > 1) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 30,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.black, Colors.black, Colors.transparent],
                      stops: [0.0, 0.88, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(right: 24),
                    itemCount: allTrips.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final t = allTrips[index];
                      final isCurrent = t.id == trip.id;
                      final tCountry = Country.findByCode(t.countryCode);
                      final rawTDest = t.destination.isNotEmpty
                          ? CityLocalization.localizeDestination(t.destination, lang)
                          : t.title;
                      final cleanTDest = stripLeadingFlags(rawTDest);

                      return BouncyPressable(
                        scaleFactor: 0.95,
                        onTap: () {
                          AppHaptics.light();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TripDetailScreen(trip: t),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                                : (isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent
                                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                                  : (isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight),
                              width: 0.6,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (t.countries.isNotEmpty) ...[
                                Wrap(
                                  spacing: 2,
                                  children: t.countries
                                      .map((c) => Text(c.flag, style: const TextStyle(fontSize: 11)))
                                      .toList(),
                                ),
                                const SizedBox(width: 4),
                              ] else if (tCountry != null) ...[
                                Text(tCountry.flag, style: const TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                cleanTDest.isNotEmpty ? cleanTDest : t.title,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                  color: isCurrent
                                      ? theme.colorScheme.primary
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Luggage and Packing Checklist Status Card
class _LuggageChecklistCard extends StatelessWidget {
  final dynamic checklistState;
  final double checklistCompletionRatio;
  final Color checklistStatusColor;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _LuggageChecklistCard({
    required this.checklistState,
    required this.checklistCompletionRatio,
    required this.checklistStatusColor,
    required this.isDark,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BouncyPressable(
      scaleFactor: 0.985,
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      child: AppCard(
        padding: const EdgeInsets.all(16),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.surfaceBaseDark,
                  AppColors.brandAccent.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white,
                  AppColors.brandAccent.withValues(alpha: 0.07),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                      color: checklistStatusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.luggage,
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
                      Hero(
                        tag: 'checklist-hero-title',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            l10n.baggageAndChecklist,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      if (checklistState.totalCount == 0)
                        Text(
                          l10n.noItemsYet,
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${checklistState.packedCount}/${checklistState.totalCount}',
                                style: AppTypography.mono(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  tabularFigures: true,
                                ),
                              ),
                              TextSpan(
                                text: ' ${l10n.itemsReady} • ',
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                              ),
                              TextSpan(
                                text: Localizations.localeOf(context).languageCode.toLowerCase().startsWith('tr')
                                    ? '%${(checklistCompletionRatio * 100).toInt()}'
                                    : '${(checklistCompletionRatio * 100).toInt()}%',
                                style: AppTypography.mono(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: checklistStatusColor,
                                  tabularFigures: true,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: checklistStatusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: checklistStatusColor.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    checklistState.totalCount == 0
                        ? l10n.listEmpty.toUpperCase()
                        : (checklistCompletionRatio >= 1.0
                            ? l10n.completed.toUpperCase()
                            : l10n.preparing.toUpperCase()),
                    style: AppTypography.caption.copyWith(
                      color: checklistStatusColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  AppIcons.chevronRight,
                  size: 14,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Animated Progress Bar
            AppAnimatedProgressBar(
              progress: checklistCompletionRatio,
              height: 5.0,
              backgroundColor: isDark
                  ? theme.colorScheme.outlineVariant.withValues(alpha: 0.25)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
              foregroundColor: checklistStatusColor,
              duration: const Duration(milliseconds: 450),
            ),
            const SizedBox(height: 10),

            // Airline Baggage Limit / Responsibility Note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isDark ? AppColors.borderSubtleDark : AppColors.borderSubtleLight,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.flightTakeoff, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      checklistState.selectedAirline != null
                          ? '${checklistState.selectedAirline!.countryFlag} ${checklistState.selectedAirline!.airlineName} • ${l10n.cabinBaggage} ${checklistState.selectedAirline!.cabinLimitKg.toInt()} kg'
                          : l10n.standardBaggageLimitNote,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
  }
}
