import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../budget/domain/trip.dart';
import '../domain/travel_country.dart';
import 'world_countries_data.dart';

/// Service managing persistence, statistics, and bidirectional Cloud Firestore backup
/// for the Been & Skratch World Travel Map.
class TravelMapService {
  static const String _keyCountries = 'packbuddy_travel_map_countries_v1';
  static const List<String> _fallbackKeys = [
    'packbuddy_travel_map_countries',
    'travel_map_countries_v1',
    'travel_map_countries',
    'travel_countries',
    'visited_countries',
  ];

  TravelMapService._();
  static final TravelMapService instance = TravelMapService._();

  bool get _isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String? _resolveUid(String? uid) {
    if (uid != null && uid.isNotEmpty) return uid;
    if (_isFirebaseReady) {
      try {
        return FirebaseAuth.instance.currentUser?.uid;
      } catch (_) {}
    }
    return null;
  }

  String _scopedKey(String? uid) {
    final effective = _resolveUid(uid);
    if (effective != null && effective.isNotEmpty) {
      return '${_keyCountries}_$effective';
    }
    return _keyCountries;
  }

  /// Loads all saved country entries from storage across current and legacy keys with normalized uppercase keys
  Future<Map<String, Map<String, dynamic>>> _loadSavedMap(
    SharedPreferences prefs, {
    String? uid,
  }) async {
    final Map<String, Map<String, dynamic>> normalizedMap = {};

    void mergeRaw(String? raw) {
      if (raw == null || raw.isEmpty) return;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final keyUpper = entry.key.toString().toUpperCase().trim();
            if (entry.value is Map) {
              final valMap = Map<String, dynamic>.from(entry.value as Map);
              normalizedMap[keyUpper] = valMap;
            }
          }
        }
      } catch (_) {}
    }

    // 1. Read legacy fallback keys first
    for (final k in _fallbackKeys) {
      mergeRaw(prefs.getString(k));
    }

    // 2. Read global primary key
    mergeRaw(prefs.getString(_keyCountries));

    // 3. Read user-scoped key (authoritative for logged-in user)
    final scoped = _scopedKey(uid);
    if (scoped != _keyCountries) {
      mergeRaw(prefs.getString(scoped));
    }

    return normalizedMap;
  }

  /// Returns the raw map of saved country data
  Future<Map<String, Map<String, dynamic>>> getRawSavedMap({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    return _loadSavedMap(prefs, uid: uid);
  }

  /// Loads all countries with user's persisted status.
  /// If local storage is empty and user is logged in, automatically queries Firestore for cloud backup.
  Future<List<TravelCountry>> getCountries({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    var savedMap = await _loadSavedMap(prefs, uid: uid);

    final effectiveUid = _resolveUid(uid);

    // Self-healing cloud fallback: If user is logged in, restore and merge any remote countries from Firestore
    if (effectiveUid != null && _isFirebaseReady) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(effectiveUid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data.containsKey('travelMapCountries')) {
            final remote = data['travelMapCountries'];
            if (remote is Map && remote.isNotEmpty) {
              await restoreFromCloud(Map<String, dynamic>.from(remote), uid: effectiveUid);
              savedMap = await _loadSavedMap(prefs, uid: effectiveUid);
            }
          }
        }
      } catch (e) {
        debugPrint('[TravelMapService] Cloud fallback notice: $e');
      }
    }

    return WorldCountriesData.allCountries.map((base) {
      final keyUpper = base.code.toUpperCase().trim();
      final data = savedMap[keyUpper];
      if (data != null) {
        try {
          return TravelCountry.fromJson(data, base);
        } catch (_) {
          return base;
        }
      }
      return base;
    }).toList();
  }

  /// Sets country status (visited, wishlist, lived, or none), persists locally AND syncs to Cloud Firestore
  Future<List<TravelCountry>> setStatus({
    required String code,
    required CountryStatus status,
    DateTime? visitedDate,
    String? notes,
    String? uid,
  }) async {
    final effectiveUid = _resolveUid(uid);
    final prefs = await SharedPreferences.getInstance();
    final savedMap = await _loadSavedMap(prefs, uid: effectiveUid);
    final keyUpper = code.toUpperCase().trim();

    if (status == CountryStatus.none) {
      savedMap.remove(keyUpper);
      savedMap.remove(code.toLowerCase().trim());
    } else {
      savedMap[keyUpper] = {
        'code': keyUpper,
        'status': status.name,
        'visitedDate': (visitedDate ?? DateTime.now()).millisecondsSinceEpoch,
        'notes': notes,
      };
    }

    final encoded = jsonEncode(savedMap);
    // 1. Persist to local storage
    await prefs.setString(_keyCountries, encoded);
    await prefs.setString('packbuddy_travel_map_countries', encoded);
    if (effectiveUid != null) {
      await prefs.setString(_scopedKey(effectiveUid), encoded);
    }

    // 2. Immediately backup to Firestore under users/{uid}
    if (effectiveUid != null && _isFirebaseReady) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(effectiveUid).set({
          'travelMapCountries': savedMap,
          'travelMapUpdatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[TravelMapService] Error backing up travel map to Firestore: $e');
      }
    }

    return getCountries(uid: effectiveUid);
  }

  /// Restores travel map countries from Cloud Firestore into local SharedPreferences
  Future<void> restoreFromCloud(
    Map<String, dynamic> remoteCountries, {
    String? uid,
  }) async {
    final effectiveUid = _resolveUid(uid);
    final prefs = await SharedPreferences.getInstance();
    final savedMap = await _loadSavedMap(prefs, uid: effectiveUid);

    for (final entry in remoteCountries.entries) {
      final keyUpper = entry.key.toUpperCase().trim();
      if (entry.value is Map) {
        final valMap = Map<String, dynamic>.from(entry.value as Map);
        // If country already exists locally, keep the most recently updated one
        if (savedMap.containsKey(keyUpper)) {
          final localDate = savedMap[keyUpper]?['visitedDate'] as int? ?? 0;
          final remoteDate = valMap['visitedDate'] as int? ?? 0;
          if (remoteDate >= localDate) {
            savedMap[keyUpper] = valMap;
          }
        } else {
          savedMap[keyUpper] = valMap;
        }
      }
    }

    final encoded = jsonEncode(savedMap);
    await prefs.setString(_keyCountries, encoded);
    await prefs.setString('packbuddy_travel_map_countries', encoded);
    if (effectiveUid != null) {
      await prefs.setString(_scopedKey(effectiveUid), encoded);
    }
  }

  /// Performs full two-way synchronization of travel map countries with Cloud Firestore
  Future<List<TravelCountry>> syncWithCloud({String? uid}) async {
    final effectiveUid = _resolveUid(uid);
    if (effectiveUid == null || !_isFirebaseReady) {
      return getCountries(uid: effectiveUid);
    }

    final prefs = await SharedPreferences.getInstance();
    final localMap = await _loadSavedMap(prefs, uid: effectiveUid);

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(effectiveUid);
      final doc = await userDocRef.get();

      Map<String, dynamic> remoteMap = {};
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('travelMapCountries') && data['travelMapCountries'] is Map) {
          remoteMap = Map<String, dynamic>.from(data['travelMapCountries'] as Map);
        }
      }

      // Two-Way Merge: Union of local and remote countries
      final mergedMap = Map<String, Map<String, dynamic>>.from(localMap);
      bool remoteNeedsUpdate = false;

      for (final entry in remoteMap.entries) {
        final keyUpper = entry.key.toUpperCase().trim();
        if (entry.value is Map) {
          final remoteVal = Map<String, dynamic>.from(entry.value as Map);
          if (!mergedMap.containsKey(keyUpper)) {
            mergedMap[keyUpper] = remoteVal;
          } else {
            final localDate = mergedMap[keyUpper]?['visitedDate'] as int? ?? 0;
            final remoteDate = remoteVal['visitedDate'] as int? ?? 0;
            if (remoteDate > localDate) {
              mergedMap[keyUpper] = remoteVal;
            } else if (localDate > remoteDate) {
              remoteNeedsUpdate = true;
            }
          }
        }
      }

      // Check if local has entries that remote doesn't
      if (localMap.length > remoteMap.length) {
        remoteNeedsUpdate = true;
      }

      // Save merged to local SharedPreferences
      final encoded = jsonEncode(mergedMap);
      await prefs.setString(_keyCountries, encoded);
      await prefs.setString('packbuddy_travel_map_countries', encoded);
      await prefs.setString(_scopedKey(effectiveUid), encoded);

      // Push merged to Firestore if remote needs update
      if (remoteNeedsUpdate || remoteMap.isEmpty) {
        await userDocRef.set({
          'travelMapCountries': mergedMap,
          'travelMapUpdatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('[TravelMapService] syncWithCloud notice: $e');
    }

    return getCountries(uid: effectiveUid);
  }

  /// Automatically matches completed trips to countries and marks them as visited if not already set
  Future<List<TravelCountry>> syncFromTrips(List<Trip> trips, {String? uid}) async {
    final now = DateTime.now();
    final completedTrips = trips.where((t) => !t.isDeleted && t.endDate.isBefore(now)).toList();
    if (completedTrips.isEmpty) return getCountries(uid: uid);

    final effectiveUid = _resolveUid(uid);
    final prefs = await SharedPreferences.getInstance();
    final savedMap = await _loadSavedMap(prefs, uid: effectiveUid);

    bool modified = false;
    for (final trip in completedTrips) {
      final match = WorldCountriesData.matchCountry(trip.destination);
      if (match != null) {
        final keyUpper = match.code.toUpperCase().trim();
        if (!savedMap.containsKey(keyUpper)) {
          savedMap[keyUpper] = {
            'code': keyUpper,
            'status': CountryStatus.visited.name,
            'visitedDate': trip.endDate.millisecondsSinceEpoch,
            'notes': trip.title,
          };
          modified = true;
        }
      }
    }

    if (modified) {
      final encoded = jsonEncode(savedMap);
      await prefs.setString(_keyCountries, encoded);
      await prefs.setString('packbuddy_travel_map_countries', encoded);
      if (effectiveUid != null) {
        await prefs.setString(_scopedKey(effectiveUid), encoded);
      }

      if (effectiveUid != null && _isFirebaseReady) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(effectiveUid).set({
            'travelMapCountries': savedMap,
            'travelMapUpdatedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        } catch (_) {}
      }
    }
    return getCountries(uid: effectiveUid);
  }
}
