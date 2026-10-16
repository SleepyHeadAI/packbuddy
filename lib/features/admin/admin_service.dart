import '../../core/services/telemetry_service.dart';
import '../vault/domain/document.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';

/// Designated Executive Super Admin Email
const String kAdminEmail = 'sleepyheadaitr@gmail.com';

/// Global platform metrics for the Executive Admin Dashboard
class AdminPlatformMetrics {
  final int totalUsers;
  final int verifiedUsers;
  final int proUsers;
  final int totalTrips;
  final int totalExpenses;
  final int totalDocuments;
  final int totalChecklistItems;
  final int totalStorageBytes;

  const AdminPlatformMetrics({
    this.totalUsers = 0,
    this.verifiedUsers = 0,
    this.proUsers = 0,
    this.totalTrips = 0,
    this.totalExpenses = 0,
    this.totalDocuments = 0,
    this.totalChecklistItems = 0,
    this.totalStorageBytes = 0,
  });

  AdminPlatformMetrics copyWith({
    int? totalUsers,
    int? verifiedUsers,
    int? proUsers,
    int? totalTrips,
    int? totalExpenses,
    int? totalDocuments,
    int? totalChecklistItems,
    int? totalStorageBytes,
  }) {
    return AdminPlatformMetrics(
      totalUsers: totalUsers ?? this.totalUsers,
      verifiedUsers: verifiedUsers ?? this.verifiedUsers,
      proUsers: proUsers ?? this.proUsers,
      totalTrips: totalTrips ?? this.totalTrips,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalDocuments: totalDocuments ?? this.totalDocuments,
      totalChecklistItems: totalChecklistItems ?? this.totalChecklistItems,
      totalStorageBytes: totalStorageBytes ?? this.totalStorageBytes,
    );
  }
}

/// User profile model for Admin Management
class AdminUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String provider;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final DateTime? lastActiveAt;
  final bool isPremium;
  final int totalVaultStorageBytes;
  final String banStatus; // 'none' | 'temporary' | 'permanent'
  final String? banExpiresAt;
  final String? banReason;
  final List<String> restrictedFeatures;
  final String countryCode;
  final String countryName;
  final String currencyCode;
  final String deletionStatus; // 'none' | 'pending_deletion'
  final String? deletionRequestedAt;
  final String? scheduledPermanentDeletionAt;

  const AdminUserModel({
    required this.uid,
    this.email = '',
    this.displayName = '',
    this.photoUrl = '',
    this.provider = 'password',
    this.emailVerified = false,
    this.createdAt,
    this.lastLoginAt,
    this.lastActiveAt,
    this.isPremium = false,
    this.totalVaultStorageBytes = 0,
    this.banStatus = 'none',
    this.banExpiresAt,
    this.banReason,
    this.restrictedFeatures = const [],
    this.countryCode = 'US',
    this.countryName = 'United States',
    this.currencyCode = 'USD',
    this.deletionStatus = 'none',
    this.deletionRequestedAt,
    this.scheduledPermanentDeletionAt,
  });

  bool get isCurrentlyBanned {
    if (banStatus == 'permanent') return true;
    if (banStatus == 'temporary' && banExpiresAt != null) {
      try {
        final expiry = DateTime.parse(banExpiresAt!);
        return expiry.isAfter(DateTime.now());
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  bool get isRestricted => restrictedFeatures.isNotEmpty;

  int? get daysUntilPermanentDeletion {
    if (deletionStatus != 'pending_deletion' || scheduledPermanentDeletionAt == null) return null;
    try {
      final scheduled = DateTime.parse(scheduledPermanentDeletionAt!);
      final diff = scheduled.difference(DateTime.now()).inDays;
      return diff < 0 ? 0 : diff;
    } catch (_) {
      return null;
    }
  }

  DateTime get effectiveLastActiveAt =>
      lastActiveAt ?? lastLoginAt ?? createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  factory AdminUserModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return AdminUserModel(
      uid: id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      provider: data['provider'] as String? ?? 'password',
      emailVerified: data['emailVerified'] as bool? ?? false,
      createdAt: parseDate(data['createdAt']),
      lastLoginAt: parseDate(data['lastLoginAt']),
      lastActiveAt: parseDate(data['lastActiveAt']),
      isPremium: data['isPremium'] as bool? ?? false,
      totalVaultStorageBytes: (data['totalVaultStorageBytes'] as num?)?.toInt() ?? 0,
      banStatus: data['banStatus'] as String? ?? 'none',
      banExpiresAt: data['banExpiresAt'] as String?,
      banReason: data['banReason'] as String?,
      restrictedFeatures: (data['restrictedFeatures'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      countryCode: data['countryCode'] as String? ?? 'US',
      countryName: data['countryName'] as String? ?? 'United States',
      currencyCode: data['currencyCode'] as String? ?? 'USD',
      deletionStatus: data['deletionStatus'] as String? ?? 'none',
      deletionRequestedAt: data['deletionRequestedAt'] as String?,
      scheduledPermanentDeletionAt: data['scheduledPermanentDeletionAt'] as String?,
    );
  }

  AdminUserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? provider,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? lastActiveAt,
    bool? isPremium,
    int? totalVaultStorageBytes,
    String? banStatus,
    String? banExpiresAt,
    String? banReason,
    List<String>? restrictedFeatures,
    String? countryCode,
    String? countryName,
    String? currencyCode,
    String? deletionStatus,
    String? deletionRequestedAt,
    String? scheduledPermanentDeletionAt,
    bool clearBanExpiresAt = false,
    bool clearBanReason = false,
  }) {
    return AdminUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isPremium: isPremium ?? this.isPremium,
      totalVaultStorageBytes: totalVaultStorageBytes ?? this.totalVaultStorageBytes,
      banStatus: banStatus ?? this.banStatus,
      banExpiresAt: clearBanExpiresAt ? null : (banExpiresAt ?? this.banExpiresAt),
      banReason: clearBanReason ? null : (banReason ?? this.banReason),
      restrictedFeatures: restrictedFeatures ?? this.restrictedFeatures,
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      currencyCode: currencyCode ?? this.currencyCode,
      deletionStatus: deletionStatus ?? this.deletionStatus,
      deletionRequestedAt: deletionRequestedAt ?? this.deletionRequestedAt,
      scheduledPermanentDeletionAt: scheduledPermanentDeletionAt ?? this.scheduledPermanentDeletionAt,
    );
  }
}

/// Helper function to format storage byte measurements cleanly (e.g. 0 B, 450 KB, 3.2 MB)
String formatStorageBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  var i = 0;
  var d = bytes.toDouble();
  while (d >= 1024 && i < suffixes.length - 1) {
    d /= 1024;
    i++;
  }
  if (i == 0) return '$bytes B';
  final formatted = d.toStringAsFixed(1);
  return formatted.endsWith('.0')
      ? '${formatted.substring(0, formatted.length - 2)} ${suffixes[i]}'
      : '$formatted ${suffixes[i]}';
}

/// Contract for Admin Data Service
abstract class AdminService {
  Future<AdminPlatformMetrics> fetchMetrics();
  Future<List<AdminUserModel>> fetchUsers();
  Future<void> toggleUserProStatus(String uid, bool isPremium);
  Future<void> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  });
  Future<List<VaultDocument>> fetchUserDocuments(String uid);
  Future<void> deleteUserDocumentAsAdmin({required String uid, required String documentId});
  Future<void> cancelAccountDeletionAsAdmin(String uid);
  Future<void> purgeUserDataAsAdmin(String uid);
  bool isCurrentUserAdmin();
}

/// Firebase implementation of [AdminService]
class FirebaseAdminService implements AdminService {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  FirebaseAdminService({
    this.firestore,
    this.auth,
  });

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore? get _effectiveFirestore {
    if (firestore != null) return firestore;
    if (_isFirebaseReady) return FirebaseFirestore.instance;
    return null;
  }

  @override
  bool isCurrentUserAdmin() {
    try {
      final user = auth?.currentUser ??
          (_isFirebaseReady ? FirebaseAuth.instance.currentUser : null);
      if (user == null) return false;
      return user.email?.trim().toLowerCase() == kAdminEmail;
    } catch (_) {
      return false;
    }
  }

  Future<int> _getCollectionCount(String collectionName) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return 0;
    try {
      final aggregate = await firestore.collection(collectionName).count().get();
      return aggregate.count ?? 0;
    } catch (_) {
      try {
        final snapshot = await firestore.collection(collectionName).get();
        return snapshot.size;
      } catch (_) {
        return 0;
      }
    }
  }

  @override
  Future<AdminPlatformMetrics> fetchMetrics() async {
    final firestore = _effectiveFirestore;
    if (firestore == null) {
      return const AdminPlatformMetrics();
    }

    try {
      final usersSnapshot = await firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      int verifiedUsers = 0;
      int proUsers = 0;
      int totalStorageBytes = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        if (data['emailVerified'] == true) {
          verifiedUsers++;
        }
        if (data['isPremium'] == true) {
          proUsers++;
        }
        final storage = (data['totalVaultStorageBytes'] as num?)?.toInt() ?? 0;
        totalStorageBytes += storage;
      }

      final totalTrips = await _getCollectionCount('trips');
      final totalExpenses = await _getCollectionCount('expenses');
      final totalDocs = await _getCollectionCount('documents');
      final totalItems = await _getCollectionCount('checklist_items');

      return AdminPlatformMetrics(
        totalUsers: totalUsers,
        verifiedUsers: verifiedUsers,
        proUsers: proUsers,
        totalTrips: totalTrips,
        totalExpenses: totalExpenses,
        totalDocuments: totalDocs,
        totalChecklistItems: totalItems,
        totalStorageBytes: totalStorageBytes,
      );
    } catch (e) {
      debugPrint('[AdminService] fetchMetrics error: $e');
      return const AdminPlatformMetrics();
    }
  }

  @override
  Future<List<AdminUserModel>> fetchUsers() async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await firestore
            .collection('users')
            .orderBy('lastLoginAt', descending: true)
            .get();
      } catch (_) {
        // Fallback without server-side ordering if composite index is pending
        snapshot = await firestore.collection('users').get();
      }

      final users = snapshot.docs
          .map((doc) => AdminUserModel.fromMap(doc.id, doc.data()))
          .toList();

      // Ensure stable client-side sorting by lastLoginAt descending
      users.sort((a, b) {
        final aTime = a.lastLoginAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastLoginAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      return users;
    } catch (e) {
      debugPrint('[AdminService] fetchUsers error: $e');
      return [];
    }
  }

  @override
  Future<void> toggleUserProStatus(String uid, bool isPremium) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;

    try {
      await firestore.collection('users').doc(uid).set({
        'isPremium': isPremium,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[AdminService] toggleUserProStatus error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserModeration({
    required String uid,
    required bool isPremium,
    required String banStatus,
    String? banExpiresAt,
    String? banReason,
    required List<String> restrictedFeatures,
  }) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;

    try {
      final updates = <String, dynamic>{
        'isPremium': isPremium,
        'banStatus': banStatus,
        'banExpiresAt': banExpiresAt,
        'banReason': banReason,
        'restrictedFeatures': restrictedFeatures,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await firestore
          .collection('users')
          .doc(uid)
          .set(updates, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[AdminService] updateUserModeration error: $e');
      rethrow;
    }
  }

  @override
  Future<List<VaultDocument>> fetchUserDocuments(String uid) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return [];
    try {
      final snapshot = await firestore
          .collection('documents')
          .where('user_id', isEqualTo: uid)
          .get();
      final docs = <VaultDocument>[];
      for (final d in snapshot.docs) {
        try {
          final doc = VaultDocument.fromJson(d.data());
          if (!doc.isDeleted) {
            docs.add(doc);
          }
        } catch (_) {}
      }
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    } catch (e) {
      debugPrint('[AdminService] fetchUserDocuments error: $e');
      return [];
    }
  }

  @override
  Future<void> deleteUserDocumentAsAdmin({
    required String uid,
    required String documentId,
  }) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;
    try {
      await firestore.collection('documents').doc(documentId).set({
        'is_deleted': true,
        'isDeleted': true,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      TelemetryService.instance.logAdminAction(
        action: 'delete_user_document',
        targetUid: uid,
        details: {'documentId': documentId},
      );
    } catch (e) {
      debugPrint('[AdminService] deleteUserDocumentAsAdmin error: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelAccountDeletionAsAdmin(String uid) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;
    try {
      await firestore.collection('users').doc(uid).set({
        'deletionStatus': 'none',
        'deletionRequestedAt': null,
        'scheduledPermanentDeletionAt': null,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      TelemetryService.instance.logAdminAction(
        action: 'cancel_account_deletion',
        targetUid: uid,
      );
    } catch (e) {
      debugPrint('[AdminService] cancelAccountDeletionAsAdmin error: $e');
      rethrow;
    }
  }

  @override
  Future<void> purgeUserDataAsAdmin(String uid) async {
    final firestore = _effectiveFirestore;
    if (firestore == null) return;
    try {
      final collections = ['trips', 'expenses', 'checklist_items', 'documents'];
      for (final coll in collections) {
        try {
          final snap = await firestore.collection(coll).where('user_id', isEqualTo: uid).get();
          for (final doc in snap.docs) {
            await doc.reference.delete();
          }
        } catch (_) {}
      }
      await firestore.collection('users').doc(uid).set({
        'deletionStatus': 'none',
        'deletionRequestedAt': null,
        'scheduledPermanentDeletionAt': null,
        'isPremium': false,
        'totalVaultStorageBytes': 0,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      TelemetryService.instance.logAdminAction(
        action: 'purge_user_data',
        targetUid: uid,
      );
    } catch (e) {
      debugPrint('[AdminService] purgeUserDataAsAdmin error: $e');
      rethrow;
    }
  }
}

/// Global provider for [AdminService]
final adminServiceProvider = Provider<AdminService>((ref) {
  return FirebaseAdminService();
});

/// Reactive guard checking if current logged-in user is the Executive Admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(authUserProvider);
  if (user == null) return false;
  final email = user.email?.trim().toLowerCase();
  return email == kAdminEmail;
});
