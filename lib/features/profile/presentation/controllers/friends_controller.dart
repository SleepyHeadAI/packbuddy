import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/profile/data/friend_service.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';

/// State representation of the user's travel buddy network and pending requests
class FriendsState {
  final List<FriendUserSummary> friends;
  final List<FriendRequestItem> incomingRequests;
  final List<FriendRequestItem> outgoingRequests;
  final FriendUserSummary? searchResult;
  final bool isSearching;
  final bool isLoading;
  final String? errorMessage;

  const FriendsState({
    this.friends = const [],
    this.incomingRequests = const [],
    this.outgoingRequests = const [],
    this.searchResult,
    this.isSearching = false,
    this.isLoading = false,
    this.errorMessage,
  });

  FriendsState copyWith({
    List<FriendUserSummary>? friends,
    List<FriendRequestItem>? incomingRequests,
    List<FriendRequestItem>? outgoingRequests,
    FriendUserSummary? searchResult,
    bool clearSearchResult = false,
    bool? isSearching,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      outgoingRequests: outgoingRequests ?? this.outgoingRequests,
      searchResult: clearSearchResult ? null : (searchResult ?? this.searchResult),
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controller managing friends list, incoming/outgoing requests and handle discovery
class FriendsController extends StateNotifier<FriendsState> {
  final Ref _ref;
  final FriendService _friendService;

  FriendsController(this._ref, {FriendService? service})
      : _friendService = service ?? FriendService(),
        super(const FriendsState()) {
    loadData();
  }

  String? get _currentUid => _ref.read(authUserProvider)?.uid;

  Future<void> loadData() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final friends = await _friendService.fetchFriends(uid);
      final requests = await _friendService.fetchRequests(uid);

      state = state.copyWith(
        friends: friends,
        incomingRequests: requests.incoming,
        outgoingRequests: requests.outgoing,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> searchByUsername(String query) async {
    final clean = query.trim().toLowerCase().replaceAll('@', '');
    if (clean.isEmpty) {
      state = state.copyWith(clearSearchResult: true, isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true, clearSearchResult: true, errorMessage: null);
    try {
      final result = await _friendService.searchUserByUsername(clean);
      state = state.copyWith(
        searchResult: result,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(clearSearchResult: true, isSearching: false);
  }

  Future<bool> sendRequest(String targetUid) async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return false;

    final success = await _friendService.sendFriendRequest(
      currentUid: uid,
      targetUid: targetUid,
    );

    if (success) {
      await loadData();
    }
    return success;
  }

  Future<bool> acceptRequest(String friendshipId) async {
    final success = await _friendService.acceptFriendRequest(friendshipId);
    if (success) {
      await loadData();
    }
    return success;
  }

  Future<bool> declineOrCancelRequest(String friendshipId) async {
    final success = await _friendService.declineOrCancelFriendRequest(friendshipId);
    if (success) {
      await loadData();
    }
    return success;
  }

  Future<bool> removeFriend(String targetUid) async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return false;

    final success = await _friendService.removeFriend(
      currentUid: uid,
      targetUid: targetUid,
    );

    if (success) {
      await loadData();
    }
    return success;
  }
}

/// Global Riverpod provider for Friends network
final friendsControllerProvider =
    StateNotifierProvider<FriendsController, FriendsState>((ref) {
  return FriendsController(ref);
});
