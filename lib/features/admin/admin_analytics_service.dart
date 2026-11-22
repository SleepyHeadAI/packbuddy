import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/pro_entitlement_service.dart';
import '../budget/domain/country.dart';
import 'admin_analytics_models.dart';

export 'admin_analytics_models.dart';

/// Comparison operators supported by [AdminAnalyticsDataSource] filters.
enum AnalyticsFilterOp { isEqualTo, isGreaterThan, isGreaterThanOrEqualTo, isLessThan }

/// A single `where` clause. [value] must have the same type as the stored field
/// (ISO-8601 strings for user/trip dates, [DateTime] for Timestamp fields).
class AnalyticsFilter {
  final String field;
  final AnalyticsFilterOp op;
  final Object value;

  const AnalyticsFilter(this.field, this.op, this.value);

  const AnalyticsFilter.eq(this.field, this.value) : op = AnalyticsFilterOp.isEqualTo;
  const AnalyticsFilter.gt(this.field, this.value) : op = AnalyticsFilterOp.isGreaterThan;
  const AnalyticsFilter.gte(this.field, this.value) : op = AnalyticsFilterOp.isGreaterThanOrEqualTo;
  const AnalyticsFilter.lt(this.field, this.value) : op = AnalyticsFilterOp.isLessThan;
}

/// Read-only query surface used by [AdminAnalyticsService].
///
/// Production uses [FirestoreAdminAnalyticsDataSource] (server-side aggregations + bounded
/// sample reads). Tests inject an in-memory implementation.
abstract class AdminAnalyticsDataSource {
  /// Exact document count via a server-side `count()` aggregation.
  Future<int> countDocs(String collection, [List<AnalyticsFilter> filters = const []]);

  /// Server-side `sum()` aggregation of a numeric field.
  Future<double> sumField(String collection, String field);

  /// Bounded document read; never more than [kAdminAnalyticsSampleLimit] documents.
  Future<List<Map<String, dynamic>>> sampleDocs(
    String collection, {
    List<AnalyticsFilter> filters = const [],
    int limit = kAdminAnalyticsSampleLimit,
  });
}

/// Firestore implementation: `count()` / `sum()` aggregations (≈1 read per 1000 index entries)
/// and `limit()`-bounded sample reads (Faz B billing protection).
class FirestoreAdminAnalyticsDataSource implements AdminAnalyticsDataSource {
  final FirebaseFirestore firestore;

  FirestoreAdminAnalyticsDataSource(this.firestore);

  Query<Map<String, dynamic>> _apply(String collection, List<AnalyticsFilter> filters) {
    Query<Map<String, dynamic>> query = firestore.collection(collection);
    for (final f in filters) {
      final value = f.value is DateTime ? Timestamp.fromDate(f.value as DateTime) : f.value;
      switch (f.op) {
        case AnalyticsFilterOp.isEqualTo:
          query = query.where(f.field, isEqualTo: value);
          break;
        case AnalyticsFilterOp.isGreaterThan:
          query = query.where(f.field, isGreaterThan: value);
          break;
        case AnalyticsFilterOp.isGreaterThanOrEqualTo:
          query = query.where(f.field, isGreaterThanOrEqualTo: value);
          break;
        case AnalyticsFilterOp.isLessThan:
          query = query.where(f.field, isLessThan: value);
          break;
      }
    }
    return query;
  }

  @override
  Future<int> countDocs(String collection, [List<AnalyticsFilter> filters = const []]) async {
    final snapshot = await _apply(collection, filters).count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<double> sumField(String collection, String field) async {
    final snapshot = await firestore.collection(collection).aggregate(sum(field)).get();
    return (snapshot.getSum(field) ?? 0).toDouble();
  }

  @override
  Future<List<Map<String, dynamic>>> sampleDocs(
    String collection, {
    List<AnalyticsFilter> filters = const [],
    int limit = kAdminAnalyticsSampleLimit,
  }) async {
    final bounded = math.min(limit, kAdminAnalyticsSampleLimit);
    final snapshot = await _apply(collection, filters).limit(bounded).get();
    return snapshot.docs.map((d) => d.data()).toList();
  }
}

/// Thrown when no analytics query could be answered (Firebase not ready / no permission).
class AdminAnalyticsException implements Exception {
  final String message;
  const AdminAnalyticsException(this.message);

  @override
  String toString() => 'AdminAnalyticsException: $message';
}

/// Builds the detailed [AdminAnalyticsReport] lazily, only when the analytics screen asks
/// for it, and keeps a short in-memory cache per range so leaving and re-entering the screen
/// does not re-read Firestore. Use `forceRefresh: true` for the manual "Yenile" button.
class AdminAnalyticsService {
  AdminAnalyticsService({
    AdminAnalyticsDataSource? dataSource,
    this.cacheTtl = const Duration(minutes: 5),
    DateTime Function()? clock,
  })  : _injectedDataSource = dataSource,
        _clock = clock ?? DateTime.now;

  final AdminAnalyticsDataSource? _injectedDataSource;
  final Duration cacheTtl;
  final DateTime Function() _clock;

  final Map<AdminAnalyticsRange, AdminAnalyticsReport> _cache = {};
  final Map<AdminAnalyticsRange, Future<AdminAnalyticsReport>> _inFlight = {};

  static const int nearQuotaPercent = 80;

  AdminAnalyticsDataSource? _resolveDataSource() {
    if (_injectedDataSource != null) return _injectedDataSource;
    try {
      if (Firebase.apps.isNotEmpty) return FirestoreAdminAnalyticsDataSource(FirebaseFirestore.instance);
    } catch (_) {}
    return null;
  }

  /// Cached report for [range] if it is still fresh, otherwise `null`.
  AdminAnalyticsReport? cachedReport(AdminAnalyticsRange range) {
    final cached = _cache[range];
    if (cached == null) return null;
    if (_clock().difference(cached.fetchedAt) > cacheTtl) return null;
    return cached;
  }

  void clearCache() => _cache.clear();

  Future<AdminAnalyticsReport> fetchDetailedAnalytics({
    required AdminAnalyticsRange range,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = cachedReport(range);
      if (cached != null) return Future.value(cached);
    }
    final pending = _inFlight[range];
    if (pending != null) return pending;

    final future = _build(range).then((report) {
      _cache[range] = report;
      return report;
    }).whenComplete(() {
      // Block body on purpose: returning the removed Future would make it await itself.
      _inFlight.remove(range);
    });
    _inFlight[range] = future;
    return future;
  }

  Future<AdminAnalyticsReport> _build(AdminAnalyticsRange range) async {
    final source = _resolveDataSource();
    if (source == null) {
      throw const AdminAnalyticsException('Firebase hazır değil; analitik verisi okunamadı.');
    }
    final q = _QueryTracker(source);
    final now = _clock();
    final cutoff = range.cutoff(now);
    final cutoffIso = cutoff?.toIso8601String();
    final nowIso = now.toIso8601String();
    String isoDaysAgo(int days) => now.subtract(Duration(days: days)).toIso8601String();

    // ---- Exact headline numbers (server-side count()/sum()) -------------------------------
    final results = await Future.wait<Object>([
      q.count('users'), // 0
      q.count('users', [AnalyticsFilter.gte('lastActiveAt', isoDaysAgo(1))]), // 1
      q.count('users', [AnalyticsFilter.gte('lastActiveAt', isoDaysAgo(7))]), // 2
      q.count('users', [AnalyticsFilter.gte('lastActiveAt', isoDaysAgo(30))]), // 3
      cutoffIso == null
          ? q.count('users')
          : q.count('users', [AnalyticsFilter.gte('createdAt', cutoffIso)]), // 4
      q.count('users', const [AnalyticsFilter.eq('emailVerified', true)]), // 5
      q.count('users', [AnalyticsFilter.lt('lastActiveAt', isoDaysAgo(150))]), // 6
      q.count('users', const [AnalyticsFilter.eq('isPremium', true)]), // 7
      q.count('users', const [AnalyticsFilter.gt('subscriptionProductId', '')]), // 8
      q.count('users', const [AnalyticsFilter.eq('adminGrantedPro', true)]), // 9
      q.count('users', const [AnalyticsFilter.eq('subscriptionProductId', _productMonthly)]), // 10
      q.count('users', const [AnalyticsFilter.eq('subscriptionProductId', _productAnnual)]), // 11
      q.count('trips'), // 12
      cutoffIso == null
          ? q.count('trips')
          : q.count('trips', [AnalyticsFilter.gte('createdAt', cutoffIso)]), // 13
      q.count('trips', [AnalyticsFilter.gt('startDate', nowIso)]), // 14 upcoming
      q.count('trips', [AnalyticsFilter.lt('endDate', nowIso)]), // 15 completed
      q.count('expenses'), // 16
      q.count('checklist_items'), // 17
      q.count('checklist_items', const [AnalyticsFilter.eq('isPacked', true)]), // 18
      q.count('itinerary_items'), // 19
      q.count('trips', const [AnalyticsFilter.eq('isShared', true)]), // 20
      q.count('friendships', const [AnalyticsFilter.eq('status', 'accepted')]), // 21
      q.count('friendships', const [AnalyticsFilter.eq('status', 'pending')]), // 22
      q.count('documents'), // 23
      q.count('documents', const [AnalyticsFilter.eq('fileType', 'pdf')]), // 24
      q.sum('users', 'totalVaultStorageBytes'), // 25
      q.count('documents', const [AnalyticsFilter.eq('encryptionVersion', 'PBENC2')]), // 26
      q.count('documents', const [AnalyticsFilter.eq('encryptionVersion', 'PBENC1')]), // 27
      q.count('users', const [AnalyticsFilter.eq('legalAnalyticsConsent', true)]), // 28
      q.count('users', const [AnalyticsFilter.eq('legalAnalyticsConsent', false)]), // 29
      q.count('users', const [AnalyticsFilter.eq('banStatus', 'temporary')]), // 30
      q.count('users', const [AnalyticsFilter.eq('banStatus', 'permanent')]), // 31
      q.count('user_feedback'), // 32
      q.count('user_feedback', const [AnalyticsFilter.eq('status', 'new')]), // 33
      q.count('user_feedback', const [AnalyticsFilter.eq('status', 'reviewed')]), // 34
      q.count('user_feedback', const [AnalyticsFilter.eq('status', 'archived')]), // 35
      q.count('admin_audit_logs'), // 36
      cutoff == null
          ? q.count('admin_audit_logs')
          : q.count('admin_audit_logs', [AnalyticsFilter.gte('createdAt', cutoff)]), // 37
      // ---- Bounded samples (max 1000 docs each) for distributions ----------------------
      q.sample('users'), // 38
      cutoffIso == null
          ? Future.value(const <Map<String, dynamic>>[])
          : q.sample('users', [AnalyticsFilter.gte('createdAt', cutoffIso)]), // 39
      q.sample('trips'), // 40
      q.sample('expenses'), // 41
      cutoff == null
          ? q.sample('admin_audit_logs')
          : q.sample('admin_audit_logs', [AnalyticsFilter.gte('createdAt', cutoff)]), // 42
    ]);

    if (q.total > 0 && q.failed == q.total) {
      throw const AdminAnalyticsException('Analitik sorgularının hiçbiri yanıtlanamadı (yetki / bağlantı).');
    }

    int n(int i) => results[i] as int;
    List<Map<String, dynamic>> docs(int i) => results[i] as List<Map<String, dynamic>>;

    final totalUsers = n(0);
    final usersSample = docs(38);
    final signupSample = cutoffIso == null ? usersSample : docs(39);
    final tripsSample = docs(40);
    final expensesSample = docs(41);
    final auditSample = docs(42);

    // Growth ---------------------------------------------------------------------------------
    final growth = GrowthAnalytics(
      totalUsers: totalUsers,
      dailyActiveUsers: n(1),
      weeklyActiveUsers: n(2),
      monthlyActiveUsers: n(3),
      newSignupsInRange: n(4),
      signupSeries: buildSignupSeries(
        createdDates: signupSample.map((d) => parseAnalyticsDate(d['createdAt'] ?? d['created_at'])),
        bucket: range.bucket,
        from: cutoff,
        now: now,
      ),
      seriesBucket: range.bucket,
      seriesSampledCount: signupSample.length,
      verifiedUsers: n(5),
      inactive150DaysUsers: n(6),
    );

    // Pro ------------------------------------------------------------------------------------
    final pro = ProAnalytics(
      totalPro: n(7),
      playSubscribers: n(8),
      adminGrantedPro: n(9),
      monthlySubscribers: n(10),
      annualSubscribers: n(11),
      totalUsers: totalUsers,
    );

    // Content --------------------------------------------------------------------------------
    final totalTrips = n(12);
    final upcoming = n(14);
    final completed = n(15);
    final content = ContentAnalytics(
      totalTrips: totalTrips,
      tripsCreatedInRange: n(13),
      upcomingTrips: upcoming,
      completedTrips: completed,
      activeTrips: math.max(0, totalTrips - upcoming - completed),
      totalUsers: totalUsers,
      topDestinations: _distribution(
        tripsSample.map(_destinationKey),
        totalCount: totalTrips,
        labelOf: _destinationLabel,
        top: 10,
      ),
      totalExpenses: n(16),
      topCurrencies: _distribution(
        expensesSample.map((d) => (d['currency'] as String? ?? '').toUpperCase().trim()),
        totalCount: n(16),
        labelOf: (k) => k,
        top: 8,
      ),
      totalChecklistItems: n(17),
      packedChecklistItems: n(18),
      totalItineraryItems: n(19),
      sharedTrips: n(20),
      acceptedFriendships: n(21),
      pendingFriendships: n(22),
    );

    // Vault ----------------------------------------------------------------------------------
    var nearQuota = 0;
    for (final user in usersSample) {
      final bytes = ((user['totalVaultStorageBytes'] ?? user['total_vault_storage_bytes']) as num?)?.toInt() ?? 0;
      final quota = _isProDoc(user) ? ProFeatureGate.kProMaxCloudBytes : ProFeatureGate.kFreeMaxCloudBytes;
      if (bytes * 100 >= quota * nearQuotaPercent) nearQuota++;
    }
    final vault = VaultAnalytics(
      totalDocuments: n(23),
      pdfDocuments: n(24),
      totalStorageBytes: (results[25] as double).round(),
      totalUsers: totalUsers,
      nearQuotaUsers: nearQuota,
      quotaSampledCount: usersSample.length,
      pbenc2Documents: n(26),
      pbenc1Documents: n(27),
    );

    // Preferences ----------------------------------------------------------------------------
    final preferences = PreferenceAnalytics(
      languages: _distribution(
        usersSample.map((d) => _lowerString(d['appLanguage'] ?? d['app_language'] ?? d['languageCode'])),
        totalCount: totalUsers,
        labelOf: languageLabel,
      ),
      themes: _distribution(
        usersSample.map((d) => _lowerString(d['appThemeMode'] ?? d['app_theme_mode'] ?? d['themeMode'])),
        totalCount: totalUsers,
        labelOf: _themeLabel,
      ),
      analyticsOptIn: n(28),
      analyticsOptOut: n(29),
      totalUsers: totalUsers,
    );

    // Moderation -----------------------------------------------------------------------------
    final totalFeedback = n(32);
    final knownFeedback = n(33) + n(34) + n(35);
    final auditInRange = n(37);
    final moderation = ModerationAnalytics(
      temporaryBans: n(30),
      permanentBans: n(31),
      restrictedFeatures: _distribution(
        usersSample.expand((d) {
          final raw = d['restrictedFeatures'] ?? d['restricted_features'];
          return raw is List ? raw.map((e) => e.toString().trim()) : const Iterable<String>.empty();
        }),
        totalCount: totalUsers,
        sampledCount: usersSample.length,
        labelOf: (k) => k,
      ),
      totalFeedback: totalFeedback,
      feedbackStatuses: SampledDistribution(
        entries: _sorted([
          DistributionEntry(key: 'new', label: 'Yeni', count: n(33)),
          DistributionEntry(key: 'reviewed', label: 'İncelendi', count: n(34)),
          DistributionEntry(key: 'archived', label: 'Arşivlendi', count: n(35)),
          if (totalFeedback > knownFeedback)
            DistributionEntry(key: 'other', label: 'Diğer', count: totalFeedback - knownFeedback),
        ]),
        sampledCount: totalFeedback,
        totalCount: totalFeedback,
      ),
      auditActions: _distribution(
        auditSample.map((d) => (d['action'] ?? '').toString().trim()),
        totalCount: auditInRange,
        labelOf: (k) => k,
      ),
    );

    return AdminAnalyticsReport(
      range: range,
      fetchedAt: now,
      growth: growth,
      pro: pro,
      content: content,
      vault: vault,
      preferences: preferences,
      moderation: moderation,
      failedQueries: q.failed,
    );
  }

  // ---- helpers ---------------------------------------------------------------------------

  static const String _productMonthly = 'packbuddy_pro_monthly';
  static const String _productAnnual = 'packbuddy_pro_annual';

  static bool _isProDoc(Map<String, dynamic> d) =>
      d['isPremium'] == true || d['is_premium'] == true || d['isPro'] == true || d['pro'] == true || d['adminGrantedPro'] == true;

  static String _lowerString(Object? raw) => raw is String ? raw.trim().toLowerCase() : '';

  static String _destinationKey(Map<String, dynamic> trip) {
    final code = ((trip['countryCode'] ?? trip['country_code']) as String? ?? '').toUpperCase().trim();
    if (code.length == 2) return code;
    final destination = (trip['destination'] as String? ?? '').trim();
    return destination.isEmpty ? '' : 'dest:$destination';
  }

  static String _destinationLabel(String key) {
    if (key.startsWith('dest:')) return key.substring(5);
    final country = Country.findByCode(key);
    return country == null ? key : '${country.flag} ${country.name}';
  }

  static String _themeLabel(String key) {
    switch (key) {
      case 'dark':
        return 'Koyu';
      case 'light':
        return 'Açık';
      case 'system':
        return 'Sistem';
      default:
        return key;
    }
  }

  static const Map<String, String> _languageNames = {
    'ar': 'العربية',
    'de': 'Deutsch',
    'el': 'Ελληνικά',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'hi': 'हिन्दी',
    'id': 'Bahasa Indonesia',
    'it': 'Italiano',
    'ja': '日本語',
    'ko': '한국어',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'pt': 'Português',
    'ru': 'Русский',
    'sv': 'Svenska',
    'th': 'ไทย',
    'tr': 'Türkçe',
    'vi': 'Tiếng Việt',
    'zh': '中文',
  };

  /// "TR · Türkçe" style label for an `appLanguage` code.
  static String languageLabel(String code) {
    final name = _languageNames[code];
    return name == null ? code.toUpperCase() : '${code.toUpperCase()} · $name';
  }

  static List<DistributionEntry> _sorted(List<DistributionEntry> entries) =>
      entries..sort((a, b) => b.count.compareTo(a.count));

  /// Tallies [keys] (empty keys are counted as "Belirtilmemiş").
  static SampledDistribution _distribution(
    Iterable<String> keys, {
    required int totalCount,
    required String Function(String key) labelOf,
    int? sampledCount,
    int? top,
  }) {
    final counts = <String, int>{};
    var read = 0;
    for (final key in keys) {
      read++;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    var entries = _sorted(counts.entries
        .map((e) => DistributionEntry(
              key: e.key.isEmpty ? 'unknown' : e.key,
              label: e.key.isEmpty ? 'Belirtilmemiş' : labelOf(e.key),
              count: e.value,
            ))
        .toList());
    if (top != null && entries.length > top) entries = entries.sublist(0, top);
    final sampled = sampledCount ?? read;
    return SampledDistribution(
      entries: entries,
      sampledCount: sampled,
      totalCount: math.max(totalCount, sampled),
    );
  }
}

/// Parses Firestore date values (Timestamp, ISO-8601 string, epoch millis).
DateTime? parseAnalyticsDate(Object? raw) {
  if (raw is Timestamp) return raw.toDate();
  if (raw is DateTime) return raw;
  if (raw is String) return DateTime.tryParse(raw);
  if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
  return null;
}

DateTime _bucketStart(DateTime d, AdminSeriesBucket bucket) {
  switch (bucket) {
    case AdminSeriesBucket.day:
      return DateTime(d.year, d.month, d.day);
    case AdminSeriesBucket.week:
      final day = DateTime(d.year, d.month, d.day);
      return day.subtract(Duration(days: day.weekday - DateTime.monday));
    case AdminSeriesBucket.month:
      return DateTime(d.year, d.month);
  }
}

DateTime _nextBucket(DateTime start, AdminSeriesBucket bucket) {
  switch (bucket) {
    case AdminSeriesBucket.day:
      return DateTime(start.year, start.month, start.day + 1);
    case AdminSeriesBucket.week:
      return DateTime(start.year, start.month, start.day + 7);
    case AdminSeriesBucket.month:
      return DateTime(start.year, start.month + 1);
  }
}

/// Continuous (zero-filled) new-signup series from [from] (or the earliest signup) to [now].
/// All-time series are capped to the most recent [maxBuckets] buckets.
@visibleForTesting
List<TimeSeriesPoint> buildSignupSeries({
  required Iterable<DateTime?> createdDates,
  required AdminSeriesBucket bucket,
  required DateTime? from,
  required DateTime now,
  int maxBuckets = 24,
}) {
  final dates = createdDates.whereType<DateTime>().map((d) => d.toLocal()).where((d) => !d.isAfter(now)).toList();
  if (from == null && dates.isEmpty) return const [];
  final earliest = from ?? dates.reduce((a, b) => a.isBefore(b) ? a : b);

  final counts = <DateTime, int>{};
  for (final d in dates) {
    if (from != null && d.isBefore(from)) continue;
    final key = _bucketStart(d, bucket);
    counts[key] = (counts[key] ?? 0) + 1;
  }

  final points = <TimeSeriesPoint>[];
  final last = _bucketStart(now, bucket);
  var cursor = _bucketStart(earliest, bucket);
  while (!cursor.isAfter(last)) {
    points.add(TimeSeriesPoint(bucketStart: cursor, count: counts[cursor] ?? 0));
    cursor = _nextBucket(cursor, bucket);
  }
  final capped = from == null && points.length > maxBuckets;
  return capped ? points.sublist(points.length - maxBuckets) : points;
}

/// Wraps each query so a single failing query (missing index, rules) degrades to 0 / empty
/// instead of failing the whole report, while still counting failures.
class _QueryTracker {
  _QueryTracker(this.source);

  final AdminAnalyticsDataSource source;
  int total = 0;
  int failed = 0;

  Future<int> count(String collection, [List<AnalyticsFilter> filters = const []]) =>
      _guard(() => source.countDocs(collection, filters), 0, 'count($collection)');

  Future<double> sum(String collection, String field) =>
      _guard(() => source.sumField(collection, field), 0.0, 'sum($collection.$field)');

  Future<List<Map<String, dynamic>>> sample(String collection, [List<AnalyticsFilter> filters = const []]) =>
      _guard(
        () => source.sampleDocs(collection, filters: filters, limit: kAdminAnalyticsSampleLimit),
        const <Map<String, dynamic>>[],
        'sample($collection)',
      );

  Future<T> _guard<T>(Future<T> Function() run, T fallback, String label) async {
    total++;
    try {
      return await run();
    } catch (e) {
      failed++;
      debugPrint('[AdminAnalyticsService] $label notice: $e');
      return fallback;
    }
  }
}

/// App-wide (keep-alive) instance so the in-memory cache survives leaving the screen.
final adminAnalyticsServiceProvider = Provider<AdminAnalyticsService>((ref) => AdminAnalyticsService());
