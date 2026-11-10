import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import '../domain/user_feedback.dart';

/// Service managing user feedback submission, persistence, and admin retrieval
class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  final _uuid = const Uuid();

  /// In-memory cache fallback to ensure offline-first safety even before storage init
  final List<UserFeedback> _memoryFallback = [];

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;
  FirebaseFirestore? get _firestore => _isFirebaseReady ? FirebaseFirestore.instance : null;

  /// Submits user feedback (max 1000 chars, optional image)
  Future<bool> submitFeedback({
    required String message,
    File? imageFile,
    String? userEmail,
    String? userId,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || trimmed.length > 1000) {
      return false;
    }

    String? imageBase64;
    String? localPath;

    if (imageFile != null && await imageFile.exists()) {
      localPath = imageFile.path;
      try {
        final bytes = await imageFile.readAsBytes();
        // Keep base64 lightweight (limit to ~1MB)
        if (bytes.length <= 1024 * 1024) {
          imageBase64 = base64Encode(bytes);
        }
      } catch (e) {
        debugPrint('[FeedbackService] Error encoding image: $e');
      }
    }

    final currentUser = _isFirebaseReady ? FirebaseAuth.instance.currentUser : null;
    final effectiveUid = userId ?? currentUser?.uid ?? 'guest';
    final effectiveEmail = userEmail ?? currentUser?.email ?? 'Anonim';
    final feedbackId = 'fb_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}';

    final feedback = UserFeedback(
      id: feedbackId,
      userId: effectiveUid,
      userEmail: effectiveEmail,
      message: trimmed,
      imageBase64: imageBase64,
      localImagePath: localPath,
      createdAt: DateTime.now(),
      status: 'new',
    );

    // 1. Save locally in device storage (Offline-first guarantee)
    await _saveLocalFeedback(feedback);

    // 2. Sync to cloud Firestore if available
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs.collection('user_feedback').doc(feedbackId).set(feedback.toMap());
      }
    } catch (e) {
      debugPrint('[FeedbackService] Error syncing feedback to Firestore: $e');
    }

    return true;
  }

  /// Retrieves all feedback items for the Executive Admin Panel
  Future<List<UserFeedback>> getAllFeedback() async {
    final localList = _getLocalFeedback();

    try {
      final fs = _firestore;
      if (fs != null) {
        final snapshot = await fs
            .collection('user_feedback')
            .orderBy('created_at', descending: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final cloudList = snapshot.docs
              .map((doc) => UserFeedback.fromMap(doc.data(), docId: doc.id))
              .toList();

          // Merge cloud items with any local items
          final idSet = cloudList.map((f) => f.id).toSet();
          for (final local in localList) {
            if (!idSet.contains(local.id)) {
              cloudList.add(local);
            }
          }
          cloudList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return cloudList;
        }
      }
    } catch (e) {
      debugPrint('[FeedbackService] Error fetching cloud feedback: $e');
    }

    localList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return localList;
  }

  /// Deletes a feedback item
  Future<bool> deleteFeedback(String id) async {
    // 1. Remove from local storage
    final localList = _getLocalFeedback().where((f) => f.id != id).toList();
    await _saveAllLocal(localList);

    // 2. Remove from cloud Firestore
    try {
      final fs = _firestore;
      if (fs != null) {
        await fs.collection('user_feedback').doc(id).delete();
      }
      return true;
    } catch (e) {
      debugPrint('[FeedbackService] Error deleting cloud feedback: $e');
      return true; // Still removed locally
    }
  }

  /// Marks feedback status as reviewed
  Future<bool> markAsReviewed(String id) async {
    final localList = _getLocalFeedback();
    final updated = localList.map((f) {
      return f.id == id ? f.copyWith(status: 'reviewed') : f;
    }).toList();
    await _saveAllLocal(updated);

    try {
      final fs = _firestore;
      if (fs != null) {
        await fs.collection('user_feedback').doc(id).update({'status': 'reviewed'});
      }
      return true;
    } catch (e) {
      debugPrint('[FeedbackService] Error updating status in cloud: $e');
      return true;
    }
  }

  List<UserFeedback> _getLocalFeedback() {
    try {
      final raw = PreferencesService.instance.getFeedbackCache();
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((item) => UserFeedback.fromMap(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return List.from(_memoryFallback);
  }

  Future<void> _saveLocalFeedback(UserFeedback item) async {
    _memoryFallback.removeWhere((f) => f.id == item.id);
    _memoryFallback.insert(0, item);

    final current = _getLocalFeedback();
    current.removeWhere((f) => f.id == item.id);
    current.insert(0, item);
    await _saveAllLocal(current);
  }

  Future<void> _saveAllLocal(List<UserFeedback> items) async {
    try {
      final encoded = jsonEncode(items.map((i) => i.toMap()).toList());
      await PreferencesService.instance.saveFeedbackCache(encoded);
    } catch (e) {
      debugPrint('[FeedbackService] Error saving local feedback: $e');
    }
  }
}
