import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/domain/city_localization.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_comparison_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/share_trip_sheet.dart';
import 'package:packbuddy/features/travel_map/presentation/screens/travel_map_screen.dart';
import 'package:packbuddy/shared/widgets/app_animations.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';

/// Modern, intuitive Trips Overview Screen listing upcoming, active, and past trips
class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});

  static IconData getTransportIcon(String? mode) {
    if (mode == null || mode.isEmpty) return Icons.luggage_outlined;
    final lower = mode.toLowerCase();
    if (lower.contains('uçak') || lower.contains('flight') || lower.contains('plane')) {
      return Icons.flight_rounded;
    } else if (lower.contains('hızlı tren') || lower.contains('yht') || lower.contains('bullet')) {
      return Icons.directions_railway_rounded;
    } else if (lower.contains('tren') || lower.contains('train')) {
      return Icons.train_rounded;
    } else if (lower.contains('araba') || lower.contains('car') || lower.contains('kiralık')) {
      return Icons.directions_car_rounded;
    } else if (lower.contains('gemi') || lower.contains('ship') || lower.contains('feribot') || lower.contains('ferry') || lower.contains('boat')) {
      return Icons.directions_boat_rounded;
    } else if (lower.contains('otobüs') || lower.contains('bus')) {
      return Icons.directions_bus_rounded;
    } else if (lower.contains('moto') || lower.contains('motor')) {
      return Icons.two_wheeler_rounded;
    } else if (lower.contains('karavan') || lower.contains('camper') || lower.contains('rv')) {
      return Icons.airport_shuttle_rounded;
    } else if (lower.contains('bisiklet') || lower.contains('bike') || lower.contains('bicycle')) {
      return Icons.pedal_bike_rounded;
    } else if (lower.contains('metro') || lower.contains('tram') || lower.contains('subway')) {
      return Icons.tram_rounded;
    } else if (lower.contains('yürüyüş') || lower.contains('trekking') || lower.contains('hike') || lower.contains('walk')) {
      return Icons.hiking_rounded;
    } else if (lower.contains('heli') || lower.contains('helikopter')) {
      return Icons.flight_takeoff_rounded;
    } else if (lower == 'other' || lower == 'diğer') {
      return Icons.luggage_outlined;
    }
    return Icons.commute_rounded;
  }

  static String formatTransportMode(String? mode, AppLocalizations l10n) {
    if (mode == null || mode.isEmpty) return '';
    final lower = mode.toLowerCase();
    if (lower.contains('uçak') || lower.contains('flight') || lower.contains('plane')) {
      return l10n.flight;
    } else if (lower.contains('hızlı tren') || lower.contains('yht') || lower.contains('bullet')) {
      return l10n.bulletTrain;
    } else if (lower.contains('tren') || lower.contains('train')) {
      return l10n.train;
    } else if (lower.contains('araba') || lower.contains('car') || lower.contains('kiralık')) {
      return l10n.car;
    } else if (lower.contains('gemi') || lower.contains('ship') || lower.contains('feribot') || lower.contains('ferry') || lower.contains('boat')) {
      return l10n.ferry;
    } else if (lower.contains('otobüs') || lower.contains('bus')) {
      return l10n.bus;
    } else if (lower.contains('moto') || lower.contains('motor')) {
      return l10n.motorcycle;
    } else if (lower.contains('karavan') || lower.contains('camper') || lower.contains('rv')) {
      return l10n.camper;
    } else if (lower.contains('bisiklet') || lower.contains('bike') || lower.contains('bicycle')) {
      return l10n.bicycle;
    } else if (lower.contains('metro') || lower.contains('tram') || lower.contains('subway')) {
      return l10n.subway;
    } else if (lower.contains('yürüyüş') || lower.contains('trekking') || lower.contains('hike') || lower.contains('walk')) {
      return l10n.hiking;
    }
    return mode;
  }

  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  // Filter tab: 'all' | 'active' | 'past'
  String _selectedFilter = 'all';

  void _showDeleteDialog(BuildContext context, Trip trip) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTrip),
        content: Text(l10n.deleteTripConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorPastel),
            onPressed: () {
              ref.read(tripControllerProvider.notifier).deleteTrip(trip.id);
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.deleteTrip),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tripState = ref.watch(tripControllerProvider);

    // Listen for database or network errors and notify user cleanly
    ref.listen<TripState>(tripControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: AppColors.errorPastel,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    final allTrips = tripState.trips;
    final activeCount = allTrips.where((t) => t.isOngoing || t.isUpcoming).length;
    final pastCount = allTrips.where((t) => t.isPast).length;

    // Filter and sort trips intelligently
    final filteredTrips = allTrips.where((t) {
      if (_selectedFilter == 'active') {
        return t.isOngoing || t.isUpcoming;
      } else if (_selectedFilter == 'past') {
        return t.isPast;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        // Priority 1: Ongoing trips first
        if (a.isOngoing && !b.isOngoing) return -1;
        if (!a.isOngoing && b.isOngoing) return 1;

        // Priority 2: Upcoming trips in chronological order
        if (a.isUpcoming && b.isUpcoming) {
          return a.startDate.compareTo(b.startDate);
        }
        if (a.isUpcoming && !b.isUpcoming) return -1;
        if (!a.isUpcoming && b.isUpcoming) return 1;

        // Priority 3: Past trips in reverse chronological order (most recent first)
        return b.endDate.compareTo(a.endDate);
      });

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
                Hero(
                  tag: 'trips-hero-badge',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flight_takeoff_rounded,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ),
                Hero(
                  tag: 'trips-hero-title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      l10n.trips,
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
            IconButton(
              icon: const Icon(Icons.public_rounded),
              tooltip: l10n.tripMap,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TravelMapScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.compare_arrows_rounded),
              tooltip: l10n.compareTrips,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TripComparisonScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.group_add_rounded),
              tooltip: l10n.joinSharedTrip,
              onPressed: () => JoinTripDialog.show(context),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () => QuickActionsSheet.showForTrips(context),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 3,
          child: const Icon(Icons.add_rounded, size: 26),
        ),
        body: tripState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : allTrips.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.flight_takeoff_rounded,
                              size: 44,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.noTripsYet,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noTripsSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Modern Segmented Filter Bar: Tümü • Aktif • Tamamlandı
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(
                              alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.55,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildSegmentItem(
                                key: 'all',
                                label: l10n.allTrips,
                                count: allTrips.length,
                                isSelected: _selectedFilter == 'all',
                                theme: theme,
                              ),
                              const SizedBox(width: 4),
                              _buildSegmentItem(
                                key: 'active',
                                label: l10n.ongoingTrip,
                                count: activeCount,
                                isSelected: _selectedFilter == 'active',
                                theme: theme,
                              ),
                              const SizedBox(width: 4),
                              _buildSegmentItem(
                                key: 'past',
                                label: l10n.completed,
                                count: pastCount,
                                isSelected: _selectedFilter == 'past',
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Trips List
                      Expanded(
                        child: filteredTrips.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.filter_list_off_rounded,
                                        size: 40,
                                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.noTripsSubtitle,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton(
                                        onPressed: () => setState(() => _selectedFilter = 'all'),
                                        child: Text(l10n.allTrips),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollCacheExtent: const ScrollCacheExtent.pixels(600.0),
                                padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 90),
                                itemCount: filteredTrips.length,
                                itemBuilder: (context, index) {
                                  final trip = filteredTrips[index];
                                  return RepaintBoundary(
                                    child: AppFadeSlide(
                                      delay: Duration(milliseconds: (30 * index).clamp(0, 200)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 14),
                                        child: _ModernTripCard(
                                          trip: trip,
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => TripDetailScreen(trip: trip),
                                              ),
                                            );
                                          },
                                          onEdit: () => AddTripSheet.show(context, tripToEdit: trip),
                                          onShare: () => ShareTripSheet.show(context, trip),
                                          onDelete: () => _showDeleteDialog(context, trip),
                                        ),
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

  Widget _buildSegmentItem({
    required String key,
    required String label,
    required int count,
    required bool isSelected,
    required ThemeData theme,
  }) {
    return Expanded(
      child: BouncyPressable(
        scaleFactor: 0.95,
        onTap: () => setState(() => _selectedFilter = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.28),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.22)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aesthetic, informative, modern Trip Card
class _ModernTripCard extends ConsumerWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _ModernTripCard({
    required this.trip,
    required this.onTap,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final country = Country.findByCode(trip.countryCode);
    final transportIcon = TripsScreen.getTransportIcon(trip.transportMode);
    final expenseState = ref.watch(expenseControllerProvider(trip.id));

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar: Destination & Live Status Badge
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
                  width: 1,
                ),
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                if (country != null) ...[
                  Text(country.flag, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                ] else ...[
                  Icon(Icons.place_outlined, size: 15, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    CityLocalization.localizeDestination(
                      trip.destination,
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(trip, l10n, theme),
              ],
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Transport Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryContainerDark
                            : AppColors.primaryContainerLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          transportIcon,
                          color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
                          size: 21,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'trip-title-${trip.id}',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                trip.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (trip.transportMode != null && trip.transportMode!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                TripsScreen.formatTransportMode(trip.transportMode, l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${AppDateFormatter.formatDateRange(trip.startDate, trip.endDate, locale: Localizations.localeOf(context).languageCode)} • ${trip.totalDays} ${l10n.daysUnit}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Mini Budget Progress Indicator (if budget set)
                if (trip.budgetLimit != null && trip.budgetLimit! > 0) ...[
                  const SizedBox(height: 12),
                  Builder(builder: (context) {
                    final spent = expenseState.totalSpent;
                    final limit = trip.budgetLimit!;
                    final ratio = (spent / limit).clamp(0.0, 1.0);
                    final isOverBudget = spent > limit;

                    Color progressColor = theme.colorScheme.primary;
                    if (isOverBudget) {
                      progressColor = AppColors.errorPastel;
                    } else if (ratio > 0.85) {
                      progressColor = const Color(0xFFF59E0B);
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${CurrencyFormatter.format(spent, currency: trip.defaultCurrency)} / ${CurrencyFormatter.format(limit, currency: trip.defaultCurrency)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isOverBudget ? AppColors.errorPastel : theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(spent / limit * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: progressColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 4.5,
                              backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Trip Notes preview snippet (if available)
                if (trip.notes != null && trip.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          trip.notes!,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 6),

                // Card Footer: Collaboration badge & action icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (trip.isShared) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_alt_rounded, size: 12, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              l10n.sharedTrip,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      const SizedBox.shrink(),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 17),
                          tooltip: l10n.shareTrip,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: onShare,
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz_rounded, size: 19),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onSelected: (val) {
                            if (val == 'edit') onEdit();
                            if (val == 'delete') onDelete();
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l10n.editTrip),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline_rounded, color: AppColors.errorPastel, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l10n.deleteTrip, style: const TextStyle(color: AppColors.errorPastel)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ],
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

  Widget _buildStatusBadge(Trip trip, AppLocalizations l10n, ThemeData theme) {
    if (trip.isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.successPastel.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.successPastel.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppPulse(
              minScale: 0.85,
              maxScale: 1.15,
              duration: const Duration(milliseconds: 1400),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.successPastel,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              l10n.ongoingTrip.toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColors.successPastel,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
    } else if (trip.isUpcoming) {
      final days = trip.daysUntilStart;
      final label = days == 0 ? l10n.today.toUpperCase() : l10n.daysRemaining(days).toUpperCase();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 10, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 10, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              l10n.completed.toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }
  }
}
