import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/core/services/push_notification_service.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// In-app notification history record
class InAppNotificationRecord {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'reminder', 'test', 'system', 'admin_warning', 'discount', 'campaign'
  final String? targetAction;
  final int? discountPercent;

  InAppNotificationRecord({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = 'reminder',
    this.targetAction,
    this.discountPercent,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'type': type,
        if (targetAction != null) 'targetAction': targetAction,
        if (discountPercent != null) 'discountPercent': discountPercent,
      };

  factory InAppNotificationRecord.fromJson(Map<String, dynamic> json) => InAppNotificationRecord(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            (json['timestamp'] as num?)?.toInt() ?? 0),
        type: json['type'] as String? ?? 'reminder',
        targetAction: json['targetAction'] as String?,
        discountPercent: (json['discountPercent'] as num?)?.toInt(),
      );
}

/// Modal bottom sheet displaying active smart reminders, notification history, and controls
class NotificationsCenterSheet extends ConsumerStatefulWidget {
  const NotificationsCenterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (context) => const RepaintBoundary(child: NotificationsCenterSheet()),
    );
  }

  @override
  ConsumerState<NotificationsCenterSheet> createState() => _NotificationsCenterSheetState();
}

class _NotificationsCenterSheetState extends ConsumerState<NotificationsCenterSheet> {
  int _selectedTab = 0; // 0: Upcoming Reminders, 1: Notification History
  List<InAppNotificationRecord> _history = [];

  @override
  void initState() {
    super.initState();
    PreferencesService.instance.setLastReadNotificationsAt(DateTime.now().millisecondsSinceEpoch);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final rawList = PreferencesService.instance.getNotificationHistory();
      final loaded = rawList.map((str) {
        try {
          return InAppNotificationRecord.fromJson(jsonDecode(str) as Map<String, dynamic>);
        } catch (_) {
          return null;
        }
      }).whereType<InAppNotificationRecord>().toList();
      loaded.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (mounted) {
        setState(() => _history = loaded);
      }

      // Fetch remote Firestore cloud notifications (e.g. across fresh app installs)
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null) {
        try {
          final snap = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUid)
              .collection('notifications')
              .orderBy('timestamp', descending: true)
              .limit(40)
              .get();

          final existingIds = loaded.map((e) => e.id).toSet();
          bool hasNew = false;
          for (final doc in snap.docs) {
            final data = doc.data();
            final id = doc.id;
            if (!existingIds.contains(id)) {
              final title = data['title'] as String? ?? 'PackBuddy Bildirimi';
              final message = data['message'] as String? ?? '';
              final ts = (data['timestamp'] as num?)?.toInt() ?? 0;
              final type = data['type'] as String? ?? 'admin_warning';
              final cloudRecord = InAppNotificationRecord(
                id: id,
                title: title,
                body: message,
                timestamp: ts > 0 ? DateTime.fromMillisecondsSinceEpoch(ts) : DateTime.now(),
                type: type == 'reminder' ? 'reminder' : (type == 'test' ? 'test' : 'admin_warning'),
              );
              loaded.add(cloudRecord);
              existingIds.add(id);
              hasNew = true;
            }
          }
          if (hasNew && mounted) {
            loaded.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            setState(() => _history = loaded);
            final rawListToSave = loaded.map((r) => jsonEncode(r.toJson())).toList();
            await PreferencesService.instance.saveNotificationHistory(rawListToSave);
          }
        } catch (e) {
          debugPrint('[_NotificationsCenterSheetState] fetch remote notifications notice: $e');
        }
      }
    } catch (_) {}
  }

  Future<void> _recordNotification(String title, String body, {String type = 'test'}) async {
    final record = InAppNotificationRecord(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
    );
    final updated = [record, ..._history];
    if (updated.length > 50) updated.removeRange(50, updated.length);
    setState(() => _history = updated);
    final rawList = updated.map((r) => jsonEncode(r.toJson())).toList();
    await PreferencesService.instance.saveNotificationHistory(rawList);
  }

  Future<void> _clearHistory() async {
    setState(() => _history.clear());
    await PreferencesService.instance.clearNotificationHistory();
  }

  Future<void> _toggleReminders(bool val) async {
    await ref.read(packingRemindersProvider.notifier).toggle(val);
  }

  Future<void> _triggerTestNotification() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      const androidDetails = AndroidNotificationDetails(
        'packbuddy_trip_reminders',
        'Trip Packing Reminders',
        channelDescription: 'Smart notifications and packing reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(android: androidDetails, iOS: darwinDetails);

      final title = l10n.appName;
      final body = l10n.allNotificationsUpToDate;
      await plugin.show(
        id: 999999,
        title: title,
        body: body,
        notificationDetails: details,
      );

      await _recordNotification(title, body, type: 'test');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.testNotificationSent),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.noticeMessage('$e') ?? 'Notice: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final tripState = ref.watch(tripControllerProvider);
    final remindersEnabled = ref.watch(packingRemindersProvider);
    final upcomingTrips = tripState.trips
        .where((t) => !t.isDeleted && t.startDate.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.notifications,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l10n.scheduledRemindersCount(upcomingTrips.length),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Reminders toggle row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.packingReminders,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l10n.packingRemindersSubtitle,
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: remindersEnabled,
                    onChanged: _toggleReminders,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tab bar: Upcoming Reminders vs Notification History
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedTab = 0),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? (isDark ? theme.colorScheme.surface : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              l10n.upcomingReminders,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _selectedTab == 0
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedTab = 1),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? (isDark ? theme.colorScheme.surface : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.notificationHistory,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedTab == 1
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                if (_history.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_history.length}',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Content
            Flexible(
              child: _selectedTab == 0
                  ? _buildUpcomingRemindersList(upcomingTrips, theme, isDark, l10n)
                  : _buildHistoryList(theme, isDark, l10n),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  if (_selectedTab == 1 && _history.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearHistory,
                        icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                        label: Text(
                          l10n.clearAll,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _triggerTestNotification,
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: Text(
                        l10n.testNotificationAction,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildUpcomingRemindersList(
    List dynamicUpcomingTrips,
    ThemeData theme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (dynamicUpcomingTrips.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_paused_rounded,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.allNotificationsUpToDate,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.noUpcomingRemindersDesc,
                style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      itemCount: dynamicUpcomingTrips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final trip = dynamicUpcomingTrips[index];
        final daysUntil = trip.startDate.difference(DateTime.now()).inDays;
        final tripTitle = trip.title.isNotEmpty ? trip.title : trip.destination;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flight_takeoff_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tripTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      daysUntil > 0 ? l10n.daysRemaining(daysUntil) : l10n.today,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• ${l10n.packingRemindersScheduled48h}\n• ${l10n.packingRemindersScheduled24h}',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(
    ThemeData theme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (_history.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_rounded,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.allNotificationsUpToDate,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.noUpcomingRemindersDesc,
                style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode).add_jm();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _history[index];
        final isTest = item.type == 'test';
        final isAdminWarning = item.type == 'admin_warning';
        final isDiscount = item.type == 'discount' ||
            item.type == 'broadcast_discount' ||
            item.discountPercent != null;
        final isBroadcast = isDiscount ||
            item.type.startsWith('broadcast') ||
            item.type == 'campaign' ||
            item.type == 'feature';

        final iconColor = isAdminWarning
            ? const Color(0xFFEA580C)
            : (isDiscount
                ? const Color(0xFF8B5CF6)
                : (isBroadcast
                    ? const Color(0xFF3B82F6)
                    : (isTest ? const Color(0xFF10B981) : theme.colorScheme.primary)));
        final iconBgColor = iconColor.withValues(alpha: 0.15);
        final borderColor = isAdminWarning
            ? const Color(0xFFEA580C).withValues(alpha: 0.35)
            : (isDiscount
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.35)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3));

        final isTr = Localizations.localeOf(context).languageCode == 'tr';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (item.targetAction == 'paywall' || isDiscount) {
                PaywallSheet.show(context);
              } else if (item.targetAction != null && item.targetAction!.isNotEmpty) {
                PushNotificationService.handlePayloadRoute(
                    'broadcast:${item.targetAction}:${item.id}');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? (isAdminWarning
                        ? const Color(0xFF2A1B12).withValues(alpha: 0.5)
                        : (isDiscount
                            ? const Color(0xFF221638).withValues(alpha: 0.5)
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)))
                    : (isAdminWarning
                        ? const Color(0xFFFFF7ED)
                        : (isDiscount
                            ? const Color(0xFFF5F3FF)
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25))),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAdminWarning
                          ? Icons.warning_amber_rounded
                          : (isDiscount
                              ? Icons.local_offer_rounded
                              : (isBroadcast
                                  ? Icons.campaign_rounded
                                  : (isTest ? Icons.verified_rounded : Icons.notifications_rounded))),
                      size: 16,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: isAdminWarning
                                            ? const Color(0xFFC2410C)
                                            : (isDiscount ? const Color(0xFF7C3AED) : null),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isAdminWarning) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isTr ? 'Yönetici' : 'Admin',
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFEA580C),
                                        ),
                                      ),
                                    ),
                                  ] else if (item.discountPercent != null) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '%${item.discountPercent} ${isTr ? 'İNDİRİM' : 'OFF'}',
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF8B5CF6),
                                        ),
                                      ),
                                    ),
                                  ] else if (isDiscount) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isTr ? 'Fırsat' : 'Deal',
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF8B5CF6),
                                        ),
                                      ),
                                    ),
                                  ] else if (isBroadcast) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isTr ? 'Duyuru' : 'Notice',
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              dateFormat.format(item.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (item.targetAction == 'paywall' || isDiscount) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                isTr ? 'Fırsatı İncele →' : 'View Offer →',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
