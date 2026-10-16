import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_comparison_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/share_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/widgets/trip_map_preview.dart';
import 'package:packbuddy/shared/widgets/app_animations.dart';

/// Trips Overview Screen listing upcoming and past trips
class TripsScreen extends ConsumerWidget {
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Trip trip) {
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
  Widget build(BuildContext context, WidgetRef ref) {
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.trips),
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
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => AddTripSheet.show(context),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 3,
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.addTrip, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      body: tripState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tripState.trips.isEmpty
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
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90),
                  itemCount: tripState.trips.length,
                  itemBuilder: (context, index) {
                    final trip = tripState.trips[index];
                    final country = Country.findByCode(trip.countryCode);
                    final transportIcon = getTransportIcon(trip.transportMode);

                    return AppFadeSlide(
                      delay: Duration(milliseconds: (35 * index).clamp(0, 250)),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AppCard(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TripDetailScreen(trip: trip),
                              ),
                            );
                          },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Transport Mode Icon container
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      transportIcon,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Title & Destination
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trip.title,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          if (country != null) ...[
                                            Text(
                                              country.flag,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(width: 4),
                                          ] else ...[
                                            Icon(
                                              Icons.place_outlined,
                                              size: 14,
                                              color: theme.colorScheme.secondary,
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          Expanded(
                                            child: Text(
                                              trip.destination,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (trip.transportMode != null &&
                                              trip.transportMode!.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.surfaceContainerHighest
                                                      .withValues(alpha: 0.6),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  formatTransportMode(trip.transportMode, l10n),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Options / Delete button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                  onPressed: () => _showDeleteDialog(context, ref, trip),
                                ),
                              ],
                            ),

                            // Trip notes preview if exists
                            if (trip.notes != null && trip.notes!.trim().isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.notes_rounded,
                                      size: 13,
                                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        trip.notes!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 10),

                            // Footer row: Dates & Budget
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 14,
                                        color: theme.colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          AppDateFormatter.formatDateRange(
                                            trip.startDate,
                                            trip.endDate,
                                            locale: Localizations.localeOf(context).languageCode,
                                          ),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (trip.budgetLimit != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 120),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        CurrencyFormatter.format(
                                          trip.budgetLimit!,
                                          currency: trip.defaultCurrency,
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(
                              height: 1,
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (trip.isShared) ...[
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.people_alt_rounded, size: 12, color: theme.colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              l10n.sharedTrip,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ] else
                                  const SizedBox.shrink(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.share_rounded, size: 18),
                                      tooltip: l10n.shareTrip,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => ShareTripSheet.show(context, trip),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.map_rounded, size: 18),
                                      tooltip: l10n.tripMap,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => TripMapSheet.show(context, trip: trip),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  },
                ),
      ),
    );
  }
}
