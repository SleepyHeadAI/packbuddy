import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/local_db/database_helper.dart';
import '../../budget/domain/trip.dart';
import '../domain/travel_country.dart';
import 'world_countries_data.dart';

/// Service managing persistence, statistics, and bidirectional Cloud Firestore backup
/// for the PackBuddy World Travel Map.
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

    final effective = _resolveUid(uid);

    if (effective == null || effective.isEmpty) {
      // 1. Read legacy fallback keys only for unauthenticated guest user
      for (final k in _fallbackKeys) {
        mergeRaw(prefs.getString(k));
      }

      // 2. Read global primary key only for unauthenticated guest user
      mergeRaw(prefs.getString(_keyCountries));
    } else {
      // 3. Read strictly user-scoped key (authoritative for this specific user)
      final scoped = _scopedKey(effective);
      mergeRaw(prefs.getString(scoped));
    }

    // 4. Read SQLite table (persists even if SharedPreferences gets cleared)
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        final effective = _resolveUid(uid);
        final dbRows = await DatabaseHelper.instance.getTravelMapCountries(userId: effective);
        for (final row in dbRows) {
          final code = (row['code'] as String?)?.toUpperCase().trim();
          if (code != null && code.isNotEmpty) {
            final status = row['status'] as String? ?? 'none';
            if (status != 'none') {
              normalizedMap[code] = {
                'code': code,
                'status': status,
                'visitedDate': row['visited_date'] ?? DateTime.now().millisecondsSinceEpoch,
                'notes': row['notes'],
              };
            }
          }
        }
      } catch (_) {}
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
  Future<List<TravelCountry>> getCountries({String? uid, bool forceRemote = false}) async {
    final prefs = await SharedPreferences.getInstance();
    var savedMap = await _loadSavedMap(prefs, uid: uid);

    final effectiveUid = _resolveUid(uid);

    // Self-healing cloud fallback: If user is logged in, restore and merge any remote countries from Firestore
    if (effectiveUid != null && _isFirebaseReady) {
      try {
        // Query users/{uid}
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(effectiveUid)
            .get(forceRemote ? const GetOptions(source: Source.server) : null);
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

        // Query dedicated travel_map collection (multi-device cloud persistent store)
        final travelMapSnap = await FirebaseFirestore.instance
            .collection('travel_map')
            .where('user_id', isEqualTo: effectiveUid)
            .get(forceRemote ? const GetOptions(source: Source.server) : null);
        if (travelMapSnap.docs.isNotEmpty) {
          final Map<String, dynamic> colCountries = {};
          for (final d in travelMapSnap.docs) {
            final data = d.data();
            final code = (data['code'] as String?)?.toUpperCase().trim();
            final isDeleted = data['is_deleted'] == 1 || data['is_deleted'] == true;
            if (code != null && code.isNotEmpty && !isDeleted) {
              colCountries[code] = {
                'code': code,
                'status': data['status'] ?? 'visited',
                'visitedDate': data['visited_date'] ?? data['visitedDate'] ?? DateTime.now().millisecondsSinceEpoch,
                'notes': data['notes'],
              };
            }
          }
          if (colCountries.isNotEmpty) {
            await restoreFromCloud(colCountries, uid: effectiveUid);
            savedMap = await _loadSavedMap(prefs, uid: effectiveUid);
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
    final effectiveDate = visitedDate ?? DateTime.now();

    if (status == CountryStatus.none) {
      savedMap.remove(keyUpper);
      savedMap.remove(code.toLowerCase().trim());
      // 1. Remove from SQLite
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        try {
          await DatabaseHelper.instance.deleteTravelMapCountry(keyUpper, userId: effectiveUid);
        } catch (_) {}
      }
    } else {
      final countryData = {
        'code': keyUpper,
        'status': status.name,
        'visitedDate': effectiveDate.millisecondsSinceEpoch,
        'notes': notes,
      };
      savedMap[keyUpper] = countryData;
      // 1. Persist to SQLite
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        try {
          await DatabaseHelper.instance.insertOrUpdateTravelMapCountry(
            code: keyUpper,
            status: status.name,
            userId: effectiveUid,
            visitedDate: effectiveDate,
            notes: notes,
          );
        } catch (_) {}
      }
    }

    final encoded = jsonEncode(savedMap);
    // 2. Persist to SharedPreferences
    if (effectiveUid != null && effectiveUid.isNotEmpty) {
      await prefs.setString(_scopedKey(effectiveUid), encoded);
    } else {
      await prefs.setString(_keyCountries, encoded);
      await prefs.setString('packbuddy_travel_map_countries', encoded);
    }

    // 3. Immediately backup to Firestore (both dedicated collection and users/{uid})
    if (effectiveUid != null && _isFirebaseReady) {
      final docId = '${effectiveUid}_$keyUpper';
      if (status == CountryStatus.none) {
        try {
          await FirebaseFirestore.instance.collection('travel_map').doc(docId).delete();
        } catch (_) {}
        try {
          await FirebaseFirestore.instance.collection('users').doc(effectiveUid).update({
            'travelMapCountries.$keyUpper': FieldValue.delete(),
            'travelMapCountries.${keyUpper.toLowerCase()}': FieldValue.delete(),
            'travelMapUpdatedAt': DateTime.now().toIso8601String(),
          });
        } catch (_) {}
      } else {
        try {
          await FirebaseFirestore.instance.collection('travel_map').doc(docId).set({
            'id': docId,
            'user_id': effectiveUid,
            'code': keyUpper,
            'status': status.name,
            'visited_date': effectiveDate.millisecondsSinceEpoch,
            'notes': notes,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
            'is_deleted': 0,
          }, SetOptions(merge: true));
        } catch (_) {}
        try {
          await FirebaseFirestore.instance.collection('users').doc(effectiveUid).update({
            'travelMapCountries.$keyUpper': savedMap[keyUpper],
            'travelMapUpdatedAt': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(effectiveUid).set({
              'travelMapCountries': {keyUpper: savedMap[keyUpper]},
              'travelMapUpdatedAt': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          } catch (_) {}
        }
      }
    }

    return getCountries(uid: effectiveUid);
  }

  /// Restores travel map countries from Cloud Firestore into local SQLite & SharedPreferences
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
        if (savedMap.containsKey(keyUpper)) {
          final localDate = savedMap[keyUpper]?['visitedDate'] as int? ?? 0;
          final remoteDate = valMap['visitedDate'] as int? ?? 0;
          if (remoteDate >= localDate) {
            savedMap[keyUpper] = valMap;
          }
        } else {
          savedMap[keyUpper] = valMap;
        }

        // Persist to local SQLite
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          try {
            final statusStr = valMap['status']?.toString() ?? 'visited';
            final vDateNum = valMap['visitedDate'] ?? valMap['visited_date'];
            final vDate = vDateNum is int
                ? DateTime.fromMillisecondsSinceEpoch(vDateNum)
                : null;
            final notesStr = valMap['notes']?.toString();
            await DatabaseHelper.instance.insertOrUpdateTravelMapCountry(
              code: keyUpper,
              status: statusStr,
              userId: effectiveUid,
              visitedDate: vDate,
              notes: notesStr,
            );
          } catch (_) {}
        }
      }
    }

    final encoded = jsonEncode(savedMap);
    if (effectiveUid != null && effectiveUid.isNotEmpty) {
      await prefs.setString(_scopedKey(effectiveUid), encoded);
    } else {
      await prefs.setString(_keyCountries, encoded);
      await prefs.setString('packbuddy_travel_map_countries', encoded);
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

      // Also query travel_map collection
      final colSnap = await FirebaseFirestore.instance
          .collection('travel_map')
          .where('user_id', isEqualTo: effectiveUid)
          .get();
      for (final cd in colSnap.docs) {
        final data = cd.data();
        final code = (data['code'] as String?)?.toUpperCase().trim();
        final isDeleted = data['is_deleted'] == 1 || data['is_deleted'] == true;
        if (code != null && code.isNotEmpty && !isDeleted) {
          remoteMap[code] = {
            'code': code,
            'status': data['status'] ?? 'visited',
            'visitedDate': data['visited_date'] ?? data['visitedDate'] ?? DateTime.now().millisecondsSinceEpoch,
            'notes': data['notes'],
          };
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
      for (final localKey in localMap.keys) {
        if (!remoteMap.containsKey(localKey)) {
          remoteNeedsUpdate = true;
          break;
        }
      }

      // Save merged to SQLite
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        for (final entry in mergedMap.entries) {
          try {
            final val = entry.value;
            final statusStr = val['status']?.toString() ?? 'visited';
            final vDateNum = val['visitedDate'] ?? val['visited_date'];
            final vDate = vDateNum is int
                ? DateTime.fromMillisecondsSinceEpoch(vDateNum)
                : null;
            final notesStr = val['notes']?.toString();
            await DatabaseHelper.instance.insertOrUpdateTravelMapCountry(
              code: entry.key,
              status: statusStr,
              userId: effectiveUid,
              visitedDate: vDate,
              notes: notesStr,
            );
          } catch (_) {}
        }
      }

      // Save merged to local SharedPreferences
      final encoded = jsonEncode(mergedMap);
      if (effectiveUid.isNotEmpty) {
        await prefs.setString(_scopedKey(effectiveUid), encoded);
      } else {
        await prefs.setString(_keyCountries, encoded);
        await prefs.setString('packbuddy_travel_map_countries', encoded);
      }

      // Push merged to Firestore ONLY if local has newer/added data, or if remote was empty and local has data
      if (remoteNeedsUpdate || (remoteMap.isEmpty && mergedMap.isNotEmpty)) {
        await userDocRef.set({
          'travelMapCountries': mergedMap,
          'travelMapUpdatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        // Sync individual docs in travel_map collection
        for (final entry in mergedMap.entries) {
          final docId = '${effectiveUid}_${entry.key}';
          final val = entry.value;
          await FirebaseFirestore.instance.collection('travel_map').doc(docId).set({
            'id': docId,
            'user_id': effectiveUid,
            'code': entry.key,
            'status': val['status'] ?? 'visited',
            'visited_date': val['visitedDate'] ?? DateTime.now().millisecondsSinceEpoch,
            'notes': val['notes'],
            'updated_at': DateTime.now().millisecondsSinceEpoch,
            'is_deleted': 0,
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint('[TravelMapService] syncWithCloud notice: $e');
    }

    return getCountries(uid: effectiveUid);
  }

  /// Automatically matches completed trips to countries and marks them as visited if not already set.
  /// Returns updated countries if modifications were made, or null if no changes occurred.
  Future<List<TravelCountry>?> syncFromTrips(List<Trip> trips, {String? uid}) async {
    final now = DateTime.now();
    final completedTrips = trips.where((t) => !t.isDeleted && t.endDate.isBefore(now)).toList();
    if (completedTrips.isEmpty) return null;

    final effectiveUid = _resolveUid(uid);
    final prefs = await SharedPreferences.getInstance();
    final savedMap = await _loadSavedMap(prefs, uid: effectiveUid);

    bool modified = false;
    final Map<String, dynamic> newTripCountries = {};
    for (final trip in completedTrips) {
      final match = WorldCountriesData.matchCountry(trip.destination);
      if (match != null) {
        final keyUpper = match.code.toUpperCase().trim();
        if (!savedMap.containsKey(keyUpper)) {
          final countryData = {
            'code': keyUpper,
            'status': CountryStatus.visited.name,
            'visitedDate': trip.endDate.millisecondsSinceEpoch,
            'notes': trip.title,
          };
          savedMap[keyUpper] = countryData;
          newTripCountries[keyUpper] = countryData;
          modified = true;
        }
      }
    }

    if (!modified) return null;

    final encoded = jsonEncode(savedMap);
    if (effectiveUid != null && effectiveUid.isNotEmpty) {
      await prefs.setString(_scopedKey(effectiveUid), encoded);
    } else {
      await prefs.setString(_keyCountries, encoded);
      await prefs.setString('packbuddy_travel_map_countries', encoded);
    }

    if (effectiveUid != null && _isFirebaseReady) {
      try {
        final Map<String, dynamic> updateFields = {
          'travelMapUpdatedAt': DateTime.now().toIso8601String(),
        };
        for (final entry in newTripCountries.entries) {
          updateFields['travelMapCountries.${entry.key}'] = entry.value;
        }
        await FirebaseFirestore.instance.collection('users').doc(effectiveUid).update(updateFields);
      } catch (_) {
        // Fallback: merge with remote map safely without overwriting
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(effectiveUid).get();
          final remoteData = doc.data();
          final remoteCountries = (remoteData != null && remoteData['travelMapCountries'] is Map)
              ? Map<String, dynamic>.from(remoteData['travelMapCountries'] as Map)
              : <String, dynamic>{};
          remoteCountries.addAll(savedMap);
          await FirebaseFirestore.instance.collection('users').doc(effectiveUid).set({
            'travelMapCountries': remoteCountries,
            'travelMapUpdatedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        } catch (_) {}
      }
    }

    return getCountries(uid: effectiveUid);
  }
}
