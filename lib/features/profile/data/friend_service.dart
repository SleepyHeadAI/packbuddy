import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';

/// Service responsible for friendship relations, username queries, and request dispatch
class FriendService {
  final FirebaseFirestore? firestore;

  FriendService({this.firestore});

  FirebaseFirestore? get _firestore => firestore;

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Searches a registered traveler by their unique @username
  Future<FriendUserSummary?> searchUserByUsername(String username) async {
    final clean = username.trim().toLowerCase().replaceAll('@', '');
    if (clean.isEmpty) return null;

    if (!_isFirebaseReady && _firestore == null) {
      return null;
    }

    try {
      final fs = _firestore ?? FirebaseFirestore.instance;
      final usernameDoc = await fs.collection('usernames').doc(clean).get();

      if (!usernameDoc.exists || usernameDoc.data() == null) {
        return null;
      }

      final targetUid = usernameDoc.data()!['uid'] as String?;
      if (targetUid == null || targetUid.isEmpty) return null;

      final userDoc = await fs.collection('users').doc(targetUid).get();
      if (!userDoc.exists || userDoc.data() == null) return null;

      return FriendUserSummary.fromMap(userDoc.data()!, fallbackUid: targetUid);
    } catch (e) {
      debugPrint('[FriendService] searchUserByUsername error: $e');
      return null;
    }
  }

  /// Sends a pending friend request to targetUid
  Future<bool> sendFriendRequest({
    required String currentUid,
    required String targetUid,
  }) async {
    if (currentUid.isEmpty || targetUid.isEmpty || currentUid == targetUid) {
      return false;
    }

    if (!_isFirebaseReady && _firestore == null) {
      return true; // Mock success for test/offline
    }

    try {
      final fs = _firestore ?? FirebaseFirestore.instance;
      final docId = Friendship.generateId(currentUid, targetUid);

      final existing = await fs.collection('friendships').doc(docId).get();
      if (existing.exists && existing.data() != null) {
        final status = existing.data()!['status'] as String?;
        if (status == 'accepted') return true;
      }

      await fs.collection('friendships').doc(docId).set({
        'id': docId,
        'users': [currentUid, targetUid],
        'requesterId': currentUid,
        'receiverId': targetUid,
        'status': FriendshipStatus.pending.toDbString(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('[FriendService] sendFriendRequest error: $e');
      return false;
    }
  }

  /// Accepts a pending friend request
  Future<bool> acceptFriendRequest(String friendshipId) async {
    if (friendshipId.isEmpty) return false;
    if (!_isFirebaseReady && _firestore == null) return true;

    try {
      final fs = _firestore ?? FirebaseFirestore.instance;
      await fs.collection('friendships').doc(friendshipId).update({
        'status': FriendshipStatus.accepted.toDbString(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[FriendService] acceptFriendRequest error: $e');
      return false;
    }
  }

  /// Declines or cancels a friend request
  Future<bool> declineOrCancelFriendRequest(String friendshipId) async {
    if (friendshipId.isEmpty) return false;
    if (!_isFirebaseReady && _firestore == null) return true;

    try {
      final fs = _firestore ?? FirebaseFirestore.instance;
      await fs.collection('friendships').doc(friendshipId).delete();
      return true;
    } catch (e) {
      debugPrint('[FriendService] declineOrCancelFriendRequest error: $e');
      return false;
    }
  }

  /// Removes a confirmed friend from friendship network
  Future<bool> removeFriend({
    required String currentUid,
    required String targetUid,
  }) async {
    if (currentUid.isEmpty || targetUid.isEmpty) return false;
    if (!_isFirebaseReady && _firestore == null) return true;

    try {
      final fs = _firestore ?? FirebaseFirestore.instance;
      final docId = Friendship.generateId(currentUid, targetUid);
      await fs.collection('friendships').doc(docId).delete();
      return true;
    } catch (e) {
      debugPrint('[FriendService] removeFriend error: $e');
      return false;
    }
  }

  /// Fetches confirmed friends for currentUid
  Future<List<FriendUserSummary>> fetchFriends(String currentUid) async {
    if (currentUid.isEmpty) return const [];

    if (!_isFirebaseReady && _firestore == null) {
      return const [];
    }

    try {
      final fs = _firestore ?? FirebaseFirestore.instance;
      final query = await fs
          .collection('friendships')
          .where('users', arrayContains: currentUid)
          .where('status', isEqualTo: FriendshipStatus.accepted.toDbString())
          .get();

      final List<FriendUserSummary> friends = [];
      for (final doc in query.docs) {
        final data = doc.data();
        final users = (data['users'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final otherUid = users.firstWhere((u) => u != currentUid, orElse: () => '');
        if (otherUid.isNotEmpty) {
          final userDoc = await fs.collection('users').doc(otherUid).get();
          if (userDoc.exists && userDoc.data() != null) {
            friends.add(FriendUserSummary.fromMap(userDoc.data()!, fallbackUid: otherUid));
          }
        }
      }

      return friends;
    } catch (e) {
      debugPrint('[FriendService] fetchFriends error: $e');
      return const [];
    }
  }

  /// Fetches pending incoming and outgoing requests
  Future<({List<FriendRequestItem> incoming, List<FriendRequestItem> outgoing})> fetchRequests(
    String currentUid,
  ) async {
    if (currentUid.isEmpty) {
      return (incoming: <FriendRequestItem>[], outgoing: <FriendRequestItem>[]);
    }

    if (!_isFirebaseReady && _firestore == null) {
      return (incoming: <FriendRequestItem>[], outgoing: <FriendRequestItem>[]);
    }

    try {
      final fs = _firestore ?? FirebaseFirestore.instance;
      final query = await fs
          .collection('friendships')
          .where('users', arrayContains: currentUid)
          .where('status', isEqualTo: FriendshipStatus.pending.toDbString())
          .get();

      final List<FriendRequestItem> incoming = [];
      final List<FriendRequestItem> outgoing = [];

      for (final doc in query.docs) {
        final friendship = Friendship.fromMap(doc.data(), docId: doc.id);
        final isIncoming = friendship.receiverId == currentUid;
        final otherUid = isIncoming ? friendship.requesterId : friendship.receiverId;

        if (otherUid.isNotEmpty) {
          final userDoc = await fs.collection('users').doc(otherUid).get();
          if (userDoc.exists && userDoc.data() != null) {
            final summary = FriendUserSummary.fromMap(userDoc.data()!, fallbackUid: otherUid);
            final item = FriendRequestItem(
              friendshipId: friendship.id,
              user: summary,
              isIncoming: isIncoming,
              createdAt: friendship.createdAt,
            );
            if (isIncoming) {
              incoming.add(item);
            } else {
              outgoing.add(item);
            }
          }
        }
      }

      return (incoming: incoming, outgoing: outgoing);
    } catch (e) {
      debugPrint('[FriendService] fetchRequests error: $e');
      return (incoming: <FriendRequestItem>[], outgoing: <FriendRequestItem>[]);
    }
  }
}
