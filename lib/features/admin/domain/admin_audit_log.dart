import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a persistent administrative action / audit log record
class AdminAuditLog {
  final String id;
  final String action;
  final String actionTitle;
  final String adminEmail;
  final String targetUid;
  final String? targetUserEmail;
  final String? targetUserName;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  const AdminAuditLog({
    required this.id,
    required this.action,
    required this.actionTitle,
    required this.adminEmail,
    required this.targetUid,
    this.targetUserEmail,
    this.targetUserName,
    this.details = const {},
    required this.timestamp,
  });

  factory AdminAuditLog.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseTime() {
      final raw = map['createdAt'];
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      final ts = map['timestamp'];
      if (ts is num) return DateTime.fromMillisecondsSinceEpoch(ts.toInt());
      return DateTime.now();
    }

    return AdminAuditLog(
      id: docId,
      action: map['action']?.toString() ?? 'unknown',
      actionTitle: map['actionTitle']?.toString() ?? 'Yönetici Aksiyonu',
      adminEmail: map['adminEmail']?.toString() ?? 'sleepyheadaitr@gmail.com',
      targetUid: map['targetUid']?.toString() ?? '',
      targetUserEmail: map['targetUserEmail']?.toString(),
      targetUserName: map['targetUserName']?.toString(),
      details: (map['details'] is Map)
          ? Map<String, dynamic>.from(map['details'] as Map)
          : const {},
      timestamp: parseTime(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'actionTitle': actionTitle,
      'adminEmail': adminEmail,
      'targetUid': targetUid,
      if (targetUserEmail != null) 'targetUserEmail': targetUserEmail,
      if (targetUserName != null) 'targetUserName': targetUserName,
      'details': details,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'createdAt': Timestamp.fromDate(timestamp),
    };
  }

  /// Categorizes action for filtering in the dashboard
  String get category {
    if (action.contains('purge') || action.contains('delete')) return 'deletion';
    if (action.contains('ban') || action.contains('restrict')) return 'ban';
    if (action.contains('warning')) return 'warning';
    if (action.contains('pro')) return 'pro';
    if (action.contains('broadcast')) return 'broadcast';
    return 'system';
  }

  /// Icon representing this action
  IconData get icon {
    switch (category) {
      case 'deletion':
        return Icons.delete_forever_rounded;
      case 'ban':
        return Icons.gpp_bad_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'pro':
        return Icons.workspace_premium_rounded;
      case 'broadcast':
        return Icons.campaign_rounded;
      default:
        return Icons.admin_panel_settings_rounded;
    }
  }

  /// Theme color representing this action
  Color get color {
    switch (category) {
      case 'deletion':
        return const Color(0xFFEF4444); // Red
      case 'ban':
        return const Color(0xFFEA580C); // Deep Orange
      case 'warning':
        return const Color(0xFFF59E0B); // Amber
      case 'pro':
        return const Color(0xFF8B5CF6); // Purple
      case 'broadcast':
        return const Color(0xFF3B82F6); // Blue
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }
}

