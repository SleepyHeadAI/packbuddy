import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_localization.dart';
import 'package:packbuddy/features/itinerary/presentation/controllers/itinerary_controller.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/widgets/add_activity_sheet.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/widgets/day_timeline_card.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Serene Voyage Day-by-Day Itinerary Screen for a specific trip
class ItineraryScreen extends ConsumerStatefulWidget {
  final Trip trip;

  const ItineraryScreen({super.key, required this.trip});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    final itineraryState = ref.watch(itineraryControllerFamily(widget.trip.id));
    final itineraryNotifier = ref.read(itineraryControllerFamily(widget.trip.id).notifier);

    final trips = ref.watch(tripControllerProvider).trips;
    final liveTrip = trips.firstWhere((t) => t.id == widget.trip.id, orElse: () => widget.trip);
    final isCollaborative = liveTrip.isCollaborative;
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final currentUserId = authState.user?.uid;
    final currentUserName = profileState.profile?.displayName ??
        authState.user?.displayName ??
        (authState.user?.email != null ? authState.user!.email!.split('@').first : null);

    final selectedDay = itineraryState.selectedDay;
    final totalDays = itineraryState.totalDays;
    final dayItems = itineraryState.itemsForSelectedDay;

    final dayCompletedCount = dayItems.where((i) => i.isCompleted).length;
    final dayTotalCount = dayItems.length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ItineraryLocalization.getItineraryTitle(langCode),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 1),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 13,
                  color: Color(0xFFE53935),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    liveTrip.title,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: ItineraryLocalization.getAddActivity(langCode),
            onPressed: () {
              AddActivitySheet.show(
                context,
                tripId: widget.trip.id,
                initialDay: selectedDay,
                totalDays: totalDays,
                tripStartDate: widget.trip.startDate.toIso8601String().split('T').first,
                languageCode: langCode,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddActivitySheet.show(
            context,
            tripId: widget.trip.id,
            initialDay: selectedDay,
            totalDays: totalDays,
            tripStartDate: widget.trip.startDate.toIso8601String().split('T').first,
            languageCode: langCode,
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(
          ItineraryLocalization.getAddActivity(langCode),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // 1. Horizontal Day Selector Tabs Bar
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: totalDays,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final dayNum = index + 1;
                final isSelected = dayNum == selectedDay;

                return InkWell(
                  onTap: () => itineraryNotifier.selectDay(dayNum),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark
                              ? theme.colorScheme.surfaceContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        ItineraryLocalization.getDay(langCode, dayNum),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 2. Day Summary & Progress Pill Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  ItineraryLocalization.getDay(langCode, selectedDay),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (dayTotalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: dayCompletedCount == dayTotalCount
                          ? const Color(0xFF10B981).withValues(alpha: 0.14)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ItineraryLocalization.completedBadge(langCode, dayCompletedCount, dayTotalCount),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: dayCompletedCount == dayTotalCount
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Activities Timeline List
          Expanded(
            child: itineraryState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : dayItems.isEmpty
                    ? _buildEmptyState(
                        context: context,
                        theme: theme,
                        langCode: langCode,
                        selectedDay: selectedDay,
                        totalDays: totalDays,
                      )
                    : Theme(
                        data: theme.copyWith(
                          canvasColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          padding: const EdgeInsets.only(top: 4, bottom: 96),
                          itemCount: dayItems.length,
                          onReorder: (oldIndex, newIndex) {
                            itineraryNotifier.reorderActivities(
                              selectedDay,
                              oldIndex,
                              newIndex,
                            );
                          },
                          proxyDecorator: (child, index, animation) {
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                final double elevation =
                                    Tween<double>(begin: 0, end: 6).animate(animation).value;
                                return Material(
                                  elevation: elevation,
                                  color: Colors.transparent,
                                  shadowColor: Colors.black26,
                                  borderRadius: BorderRadius.circular(16),
                                  child: child,
                                );
                              },
                              child: child,
                            );
                          },
                          itemBuilder: (context, index) {
                            final item = dayItems[index];
                            return DayTimelineCard(
                              key: ValueKey(item.id),
                              item: item,
                              languageCode: langCode,
                              isCollaborative: isCollaborative,
                              currentUserId: currentUserId,
                              currentUserName: currentUserName,
                              dragHandle: ReorderableDragStartListener(
                                index: index,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                                  child: Icon(
                                    Icons.drag_indicator_rounded,
                                    size: 19,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              onToggleCompleted: () =>
                                  itineraryNotifier.toggleCompleted(item.id),
                              onEdit: () {
                                AddActivitySheet.show(
                                  context,
                                  tripId: widget.trip.id,
                                  initialDay: item.dayNumber,
                                  totalDays: totalDays,
                                  tripStartDate: widget.trip.startDate.toIso8601String().split('T').first,
                                  languageCode: langCode,
                                  itemToEdit: item,
                                );
                              },
                              onDelete: () => _confirmDelete(
                                context,
                                item.id,
                                langCode,
                                itineraryNotifier,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String itemId,
    String langCode,
    ItineraryController notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ItineraryLocalization.getDeleteConfirmTitle(langCode)),
        content: Text(ItineraryLocalization.getDeleteConfirmMessage(langCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ItineraryLocalization.getCancel(langCode)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ItineraryLocalization.getDelete(langCode)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await notifier.deleteActivity(itemId);
    }
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required ThemeData theme,
    required String langCode,
    required int selectedDay,
    required int totalDays,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: AppCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.map_rounded,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                ItineraryLocalization.getNoActivities(langCode),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                ItineraryLocalization.getNoActivitiesHint(langCode),
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
