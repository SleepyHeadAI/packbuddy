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

  const AdminPlatformMetrics({
    this.totalUsers = 0,
    this.verifiedUsers = 0,
    this.proUsers = 0,
    this.totalTrips = 0,
    this.totalExpenses = 0,
    this.totalDocuments = 0,
    this.totalChecklistItems = 0,
  });

  AdminPlatformMetrics copyWith({
    int? totalUsers,
    int? verifiedUsers,
    int? proUsers,
    int? totalTrips,
    int? totalExpenses,
    int? totalDocuments,
    int? totalChecklistItems,
  }) {
    return AdminPlatformMetrics(
      totalUsers: totalUsers ?? this.totalUsers,
      verifiedUsers: verifiedUsers ?? this.verifiedUsers,
      proUsers: proUsers ?? this.proUsers,
      totalTrips: totalTrips ?? this.totalTrips,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalDocuments: totalDocuments ?? this.totalDocuments,
      totalChecklistItems: totalChecklistItems ?? this.totalChecklistItems,
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
  final bool isPremium;

  const AdminUserModel({
    required this.uid,
    this.email = '',
    this.displayName = '',
    this.photoUrl = '',
    this.provider = 'password',
    this.emailVerified = false,
    this.createdAt,
    this.lastLoginAt,
    this.isPremium = false,
  });

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
      isPremium: data['isPremium'] as bool? ?? false,
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
    bool? isPremium,
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
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

/// Contract for Admin Data Service
abstract class AdminService {
  Future<AdminPlatformMetrics> fetchMetrics();
  Future<List<AdminUserModel>> fetchUsers();
  Future<void> toggleUserProStatus(String uid, bool isPremium);
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

      for (final doc in usersSnapshot.docs) {
        final data = doc.data();
        if (data['emailVerified'] == true) {
          verifiedUsers++;
        }
        if (data['isPremium'] == true) {
          proUsers++;
        }
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
