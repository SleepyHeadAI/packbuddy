import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a broadcast announcement, marketing campaign, or discount notification
/// sent by the Super Admin to all or segmented users across PackBuddy.
class BroadcastAnnouncement {
  final String id;
  final String title;
  final String message;
  final String type; // 'discount', 'campaign', 'announcement', 'feature'
  final String targetAction; // 'paywall', 'travel_map', 'vault', 'checklist', 'none'
  final String targetAudience; // 'all', 'free_only', 'pro_only'
  final int? discountPercent; // e.g. 50 (for %50 OFF)
  final String? actionLabel; // e.g. "İndirimi İncele", "Hemen Keşfet"
  final DateTime createdAt;
  final bool active;
  final String sentBy;

  const BroadcastAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'discount',
    this.targetAction = 'paywall',
    this.targetAudience = 'all',
    this.discountPercent,
    this.actionLabel,
    required this.createdAt,
    this.active = true,
    this.sentBy = '',
  });

  factory BroadcastAnnouncement.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseCreated() {
      final raw = map['createdAt'];
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      final ts = map['timestamp'];
      if (ts is num) return DateTime.fromMillisecondsSinceEpoch(ts.toInt());
      return DateTime.now();
    }

    return BroadcastAnnouncement(
      id: docId,
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? map['body']?.toString() ?? '',
      type: map['type']?.toString() ?? 'discount',
      targetAction: map['targetAction']?.toString() ?? 'paywall',
      targetAudience: map['targetAudience']?.toString() ?? 'all',
      discountPercent: (map['discountPercent'] as num?)?.toInt(),
      actionLabel: map['actionLabel']?.toString(),
      createdAt: parseCreated(),
      active: map['active'] == null ? true : (map['active'] == true),
      sentBy: map['sentBy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'targetAction': targetAction,
      'targetAudience': targetAudience,
      'discountPercent': discountPercent,
      'actionLabel': actionLabel,
      'createdAt': Timestamp.fromDate(createdAt),
      'timestamp': createdAt.millisecondsSinceEpoch,
      'active': active,
      'sentBy': sentBy,
    };
  }

  BroadcastAnnouncement copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? targetAction,
    String? targetAudience,
    int? discountPercent,
    String? actionLabel,
    DateTime? createdAt,
    bool? active,
    String? sentBy,
  }) {
    return BroadcastAnnouncement(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      targetAction: targetAction ?? this.targetAction,
      targetAudience: targetAudience ?? this.targetAudience,
      discountPercent: discountPercent ?? this.discountPercent,
      actionLabel: actionLabel ?? this.actionLabel,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      sentBy: sentBy ?? this.sentBy,
    );
  }
}

