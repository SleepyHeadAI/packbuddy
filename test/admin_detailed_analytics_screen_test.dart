import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/admin/admin_analytics_screen.dart';
import 'package:packbuddy/features/admin/admin_analytics_service.dart';

/// In-memory [AdminAnalyticsDataSource] mirroring Firestore filter semantics
/// (a filter never matches a missing field or a value of a different type).
class InMemoryAnalyticsDataSource implements AdminAnalyticsDataSource {
  InMemoryAnalyticsDataSource(this.collections, {this.failAll = false, this.failCollections = const {}});

  final Map<String, List<Map<String, dynamic>>> collections;
  final bool failAll;
  final Set<String> failCollections;
  Completer<void>? gate;

  int countCalls = 0;
  int sumCalls = 0;
  int sampleCalls = 0;
  final List<int> requestedSampleLimits = [];

  Future<void> _maybeFail(String collection) async {
    if (gate != null) await gate!.future;
    if (failAll || failCollections.contains(collection)) {
      throw FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');
    }
  }

  static Object? _comparable(Object? v) {
    if (v is Timestamp) return v.toDate();
    return v;
  }

  static int? _compare(Object? a, Object? b) {
    final x = _comparable(a);
    final y = _comparable(b);
    if (x is String && y is String) return x.compareTo(y);
    if (x is num && y is num) return x.compareTo(y);
    if (x is DateTime && y is DateTime) return x.compareTo(y);
    return null;
  }

  static bool _matches(Map<String, dynamic> doc, AnalyticsFilter f) {
    if (!doc.containsKey(f.field)) return false;
    final value = doc[f.field];
    if (f.op == AnalyticsFilterOp.isEqualTo) return value == f.value;
    final c = _compare(value, f.value);
    if (c == null) return false;
    switch (f.op) {
      case AnalyticsFilterOp.isGreaterThan:
        return c > 0;
      case AnalyticsFilterOp.isGreaterThanOrEqualTo:
        return c >= 0;
      case AnalyticsFilterOp.isLessThan:
        return c < 0;
      case AnalyticsFilterOp.isEqualTo:
        return c == 0;
    }
  }

  Iterable<Map<String, dynamic>> _query(String collection, List<AnalyticsFilter> filters) =>
      (collections[collection] ?? const []).where((d) => filters.every((f) => _matches(d, f)));

  @override
  Future<int> countDocs(String collection, [List<AnalyticsFilter> filters = const []]) async {
    countCalls++;
    await _maybeFail(collection);
    return _query(collection, filters).length;
  }

  @override
  Future<double> sumField(String collection, String field) async {
    sumCalls++;
    await _maybeFail(collection);
    return _query(collection, const []).fold<double>(0, (s, d) => s + ((d[field] as num?)?.toDouble() ?? 0));
  }

  @override
  Future<List<Map<String, dynamic>>> sampleDocs(
    String collection, {
    List<AnalyticsFilter> filters = const [],
    int limit = kAdminAnalyticsSampleLimit,
  }) async {
    sampleCalls++;
    requestedSampleLimits.add(limit);
    await _maybeFail(collection);
    return _query(collection, filters).take(limit).toList();
  }

  int get totalCalls => countCalls + sumCalls + sampleCalls;
}

final DateTime kNow = DateTime(2026, 11, 22, 12);

String iso(Duration ago) => kNow.subtract(ago).toIso8601String();

Map<String, List<Map<String, dynamic>>> seedCollections() {
  return {
    'users': [
      {
        'uid': 'u1',
        'createdAt': iso(const Duration(days: 2)),
        'lastActiveAt': iso(const Duration(hours: 2)),
        'emailVerified': true,
        'isPremium': true,
        'subscriptionProductId': 'packbuddy_pro_monthly',
        'appLanguage': 'tr',
        'appThemeMode': 'dark',
        'legalAnalyticsConsent': true,
        'banStatus': 'none',
        'restrictedFeatures': <String>[],
        'totalVaultStorageBytes': 10 * 1024 * 1024,
      },
      {
        'uid': 'u2',
        'createdAt': iso(const Duration(days: 20)),
        'lastActiveAt': iso(const Duration(days: 3)),
        'emailVerified': true,
        'isPremium': true,
        'adminGrantedPro': true,
        'appLanguage': 'en',
        'appThemeMode': 'light',
        'legalAnalyticsConsent': false,
        'banStatus': 'temporary',
        'restrictedFeatures': <String>['vault', 'trips'],
        'totalVaultStorageBytes': 20 * 1024 * 1024,
      },
      {
        'uid': 'u3',
        'createdAt': iso(const Duration(days: 200)),
        'lastActiveAt': iso(const Duration(days: 160)),
        'emailVerified': false,
        'isPremium': false,
        'appLanguage': 'tr',
        'appThemeMode': 'dark',
        'banStatus': 'permanent',
        'restrictedFeatures': <String>['vault'],
        // 45 MB of 50 MB free quota → ≥ 80 %
        'totalVaultStorageBytes': 45 * 1024 * 1024,
      },
    ],
    'trips': [
      {
        'countryCode': 'JP',
        'createdAt': iso(const Duration(days: 1)),
        'startDate': iso(const Duration(days: -10)),
        'endDate': iso(const Duration(days: -20)),
        'isShared': true,
      },
      {
        'countryCode': 'JP',
        'createdAt': iso(const Duration(days: 40)),
        'startDate': iso(const Duration(days: 2)),
        'endDate': iso(const Duration(days: -2)),
        'isShared': false,
      },
      {
        'countryCode': 'FR',
        'createdAt': iso(const Duration(days: 100)),
        'startDate': iso(const Duration(days: 60)),
        'endDate': iso(const Duration(days: 50)),
        'isShared': false,
      },
    ],
    'expenses': [
      {'currency': 'EUR'},
      {'currency': 'EUR'},
      {'currency': 'TRY'},
    ],
    'checklist_items': [
      {'isPacked': true},
      {'isPacked': true},
      {'isPacked': false},
      {'isPacked': false},
    ],
    'itinerary_items': [{}, {}],
    'friendships': [
      {'status': 'accepted'},
      {'status': 'pending'},
    ],
    'documents': [
      {'fileType': 'pdf', 'encryptionVersion': 'PBENC2'},
      {'fileType': 'image'},
      {'fileType': 'image', 'encryptionVersion': 'PBENC1'},
    ],
    'user_feedback': [
      {'status': 'new'},
      {'status': 'new'},
      {'status': 'reviewed'},
    ],
    'admin_audit_logs': [
      {'action': 'grant_pro', 'createdAt': kNow.subtract(const Duration(days: 1))},
      {'action': 'ban_user', 'createdAt': kNow.subtract(const Duration(days: 5))},
      {'action': 'grant_pro', 'createdAt': kNow.subtract(const Duration(days: 60))},
    ],
  };
}

AdminAnalyticsService serviceFor(InMemoryAnalyticsDataSource source, {DateTime Function()? clock}) =>
    AdminAnalyticsService(dataSource: source, clock: clock ?? () => kNow);

Widget hostFor(AdminAnalyticsService service, {ThemeData? theme}) => ProviderScope(
      overrides: [adminAnalyticsServiceProvider.overrideWithValue(service)],
      child: MaterialApp(theme: theme, home: const AdminAnalyticsScreen()),
    );

void main() {
  group('AdminAnalyticsService', () {
    test('computes every module from real collection data', () async {
      final source = InMemoryAnalyticsDataSource(seedCollections());
      final report = await serviceFor(source).fetchDetailedAnalytics(range: AdminAnalyticsRange.days30);

      // Growth & activity
      expect(report.growth.totalUsers, 3);
      expect(report.growth.dailyActiveUsers, 1);
      expect(report.growth.weeklyActiveUsers, 2);
      expect(report.growth.monthlyActiveUsers, 2);
      expect(report.growth.newSignupsInRange, 2);
      expect(report.growth.verifiedUsers, 2);
      expect(report.growth.verifiedRate, closeTo(2 / 3, 1e-9));
      expect(report.growth.inactive150DaysUsers, 1);
      expect(report.growth.signupSeries.length, 31);
      expect(report.growth.signupSeries.fold<int>(0, (s, p) => s + p.count), 2);

      // Pro & subscription
      expect(report.pro.totalPro, 2);
      expect(report.pro.playSubscribers, 1);
      expect(report.pro.adminGrantedPro, 1);
      expect(report.pro.monthlySubscribers, 1);
      expect(report.pro.annualSubscribers, 0);
      expect(report.pro.conversionRate, closeTo(2 / 3, 1e-9));

      // Trips, expenses & content
      final c = report.content;
      expect(c.totalTrips, 3);
      expect(c.tripsCreatedInRange, 1);
      expect(c.upcomingTrips, 1);
      expect(c.completedTrips, 1);
      expect(c.activeTrips, 1);
      expect(c.averageTripsPerUser, 1.0);
      expect(c.topDestinations.entries.first.key, 'JP');
      expect(c.topDestinations.entries.first.count, 2);
      expect(c.totalExpenses, 3);
      expect(c.topCurrencies.entries.first.key, 'EUR');
      expect(c.totalChecklistItems, 4);
      expect(c.packedRate, 0.5);
      expect(c.totalItineraryItems, 2);
      expect(c.sharedTrips, 1);
      expect(c.acceptedFriendships, 1);
      expect(c.pendingFriendships, 1);

      // Vault & storage
      final v = report.vault;
      expect(v.totalDocuments, 3);
      expect(v.pdfDocuments, 1);
      expect(v.imageDocuments, 2);
      expect(v.totalStorageBytes, 75 * 1024 * 1024);
      expect(v.averageStorageBytesPerUser, 25 * 1024 * 1024);
      expect(v.nearQuotaUsers, 1);
      expect(v.pbenc2Documents, 1);
      expect(v.pbenc1Documents, 1);
      expect(v.unknownEncryptionDocuments, 1);

      // Preferences & KVKK
      final p = report.preferences;
      expect(p.languages.entries.first.key, 'tr');
      expect(p.languages.entries.first.count, 2);
      expect(p.themes.entries.firstWhere((e) => e.key == 'dark').count, 2);
      expect(p.analyticsOptIn, 1);
      expect(p.analyticsOptOut, 1);
      expect(p.analyticsUnset, 1);
      expect(p.optInRate, 0.5);

      // Moderation & support
      final m = report.moderation;
      expect(m.temporaryBans, 1);
      expect(m.permanentBans, 1);
      expect(m.bannedUsers, 2);
      expect(m.restrictedFeatures.entries.first.key, 'vault');
      expect(m.restrictedFeatures.entries.first.count, 2);
      expect(m.totalFeedback, 3);
      expect(m.feedbackStatuses.entries.first.key, 'new');
      expect(m.feedbackStatuses.entries.first.count, 2);
      // Only the 2 audit logs within the last 30 days.
      expect(m.auditActions.entriesTotal, 2);

      expect(report.failedQueries, 0);
      expect(report.isEmpty, isFalse);
    });

    test('never requests more than 1000 docs and reports sampled/total transparently', () async {
      final users = List.generate(
        1200,
        (i) => <String, dynamic>{'appLanguage': i.isEven ? 'tr' : 'de', 'createdAt': iso(const Duration(days: 400))},
      );
      final source = InMemoryAnalyticsDataSource({'users': users});
      final report = await serviceFor(source).fetchDetailedAnalytics(range: AdminAnalyticsRange.all);

      expect(source.requestedSampleLimits, everyElement(lessThanOrEqualTo(kAdminAnalyticsSampleLimit)));
      expect(report.growth.totalUsers, 1200);
      expect(report.preferences.languages.sampledCount, 1000);
      expect(report.preferences.languages.totalCount, 1200);
      expect(report.preferences.languages.isSampled, isTrue);
    });

    test('caches per range, forceRefresh re-reads, TTL expiry re-reads', () async {
      var now = kNow;
      final source = InMemoryAnalyticsDataSource(seedCollections());
      final service = AdminAnalyticsService(dataSource: source, clock: () => now);

      await service.fetchDetailedAnalytics(range: AdminAnalyticsRange.days7);
      final callsAfterFirst = source.totalCalls;
      expect(callsAfterFirst, greaterThan(0));

      // Re-entering the screen within the TTL → no Firestore reads.
      final cached = await service.fetchDetailedAnalytics(range: AdminAnalyticsRange.days7);
      expect(source.totalCalls, callsAfterFirst);
      expect(service.cachedReport(AdminAnalyticsRange.days7), same(cached));

      // Different range is not served from another range's cache.
      expect(service.cachedReport(AdminAnalyticsRange.days30), isNull);

      // Manual refresh.
      await service.fetchDetailedAnalytics(range: AdminAnalyticsRange.days7, forceRefresh: true);
      expect(source.totalCalls, callsAfterFirst * 2);

      // TTL expired.
      now = kNow.add(const Duration(minutes: 6));
      expect(service.cachedReport(AdminAnalyticsRange.days7), isNull);
      await service.fetchDetailedAnalytics(range: AdminAnalyticsRange.days7);
      expect(source.totalCalls, callsAfterFirst * 3);
    });

    test('concurrent requests for the same range share one read', () async {
      final source = InMemoryAnalyticsDataSource(seedCollections());
      final service = serviceFor(source);
      final results = await Future.wait([
        service.fetchDetailedAnalytics(range: AdminAnalyticsRange.days90),
        service.fetchDetailedAnalytics(range: AdminAnalyticsRange.days90),
      ]);
      expect(identical(results[0], results[1]), isTrue);
      final single = InMemoryAnalyticsDataSource(seedCollections());
      await serviceFor(single).fetchDetailedAnalytics(range: AdminAnalyticsRange.days90);
      expect(source.totalCalls, single.totalCalls);
    });

    test('empty platform yields zeros and an empty report (no fake data)', () async {
      final report = await serviceFor(InMemoryAnalyticsDataSource({}))
          .fetchDetailedAnalytics(range: AdminAnalyticsRange.days30);
      expect(report.isEmpty, isTrue);
      expect(report.growth.totalUsers, 0);
      expect(report.pro.conversionRate, 0);
      expect(report.content.topDestinations.isEmpty, isTrue);
      expect(report.vault.totalStorageBytes, 0);
      expect(report.preferences.languages.isEmpty, isTrue);
      expect(report.moderation.auditActions.isEmpty, isTrue);
    });

    test('partial failures degrade to 0 and are counted; total failure throws', () async {
      final partial = InMemoryAnalyticsDataSource(seedCollections(), failCollections: {'documents'});
      final report = await serviceFor(partial).fetchDetailedAnalytics(range: AdminAnalyticsRange.days30);
      expect(report.vault.totalDocuments, 0);
      expect(report.growth.totalUsers, 3);
      expect(report.failedQueries, greaterThan(0));

      final broken = InMemoryAnalyticsDataSource(seedCollections(), failAll: true);
      final service = serviceFor(broken);
      await expectLater(
        service.fetchDetailedAnalytics(range: AdminAnalyticsRange.days30),
        throwsA(isA<AdminAnalyticsException>()),
      );
      // Failures are never cached.
      expect(service.cachedReport(AdminAnalyticsRange.days30), isNull);
    });

    test('buildSignupSeries zero-fills buckets and caps all-time series', () {
      final daily = buildSignupSeries(
        createdDates: [kNow.subtract(const Duration(days: 1)), kNow, null],
        bucket: AdminSeriesBucket.day,
        from: kNow.subtract(const Duration(days: 6)),
        now: kNow,
      );
      expect(daily.length, 7);
      expect(daily.last.count, 1);
      expect(daily[daily.length - 2].count, 1);
      expect(daily.first.count, 0);

      final monthly = buildSignupSeries(
        createdDates: [DateTime(2020, 1, 5), kNow],
        bucket: AdminSeriesBucket.month,
        from: null,
        now: kNow,
      );
      expect(monthly.length, 24);
      expect(monthly.last.count, 1);

      expect(
        buildSignupSeries(createdDates: const [], bucket: AdminSeriesBucket.month, from: null, now: kNow),
        isEmpty,
      );
    });
  });

  group('AdminAnalyticsScreen', () {
    testWidgets('shows loading skeleton, then KPI cards from real data', (tester) async {
      final source = InMemoryAnalyticsDataSource(seedCollections())..gate = Completer<void>();
      await tester.pumpWidget(hostFor(serviceFor(source)));
      await tester.pump();
      expect(find.byKey(const ValueKey('admin_analytics_loading')), findsOneWidget);

      source.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('admin_analytics_loading')), findsNothing);
      expect(find.text('Toplam kullanıcı'), findsOneWidget);
      expect(find.text('Son güncelleme: 12:00'), findsOneWidget);
      expect(find.byKey(const ValueKey('admin_analytics_signup_chart')), findsOneWidget);
    });

    testWidgets('range chips refetch; returning to a cached range does not re-read', (tester) async {
      final source = InMemoryAnalyticsDataSource(seedCollections());
      await tester.pumpWidget(hostFor(serviceFor(source)));
      await tester.pumpAndSettle();
      final perReport = source.totalCalls;

      await tester.tap(find.byKey(const ValueKey('admin_analytics_range_days7')));
      await tester.pumpAndSettle();
      expect(source.totalCalls, perReport * 2);
      expect(find.text('Yeni kayıt (7G)'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('admin_analytics_range_days30')));
      await tester.pumpAndSettle();
      expect(source.totalCalls, perReport * 2);
      expect(find.text('Yeni kayıt (30G)'), findsOneWidget);
    });

    testWidgets('refresh button forces a new read; re-opening the screen uses the cache', (tester) async {
      final source = InMemoryAnalyticsDataSource(seedCollections());
      final service = serviceFor(source);
      await tester.pumpWidget(hostFor(service));
      await tester.pumpAndSettle();
      final perReport = source.totalCalls;

      await tester.tap(find.byKey(const ValueKey('admin_analytics_refresh')));
      await tester.pumpAndSettle();
      expect(source.totalCalls, perReport * 2);

      // Leave and re-enter.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(hostFor(service));
      await tester.pumpAndSettle();
      expect(source.totalCalls, perReport * 2);
      expect(find.text('Toplam kullanıcı'), findsOneWidget);
    });

    testWidgets('error state with working retry', (tester) async {
      final source = InMemoryAnalyticsDataSource(seedCollections(), failAll: true);
      await tester.pumpWidget(hostFor(serviceFor(source)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('admin_analytics_error')), findsOneWidget);
      expect(find.text('İstatistikler yüklenemedi'), findsOneWidget);

      final callsBefore = source.totalCalls;
      await tester.tap(find.byKey(const ValueKey('admin_analytics_retry')));
      await tester.pumpAndSettle();
      expect(source.totalCalls, greaterThan(callsBefore));
    });

    testWidgets('empty state when the platform has no data', (tester) async {
      await tester.pumpWidget(hostFor(serviceFor(InMemoryAnalyticsDataSource({}))));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('admin_analytics_empty')), findsOneWidget);
      expect(find.text('Henüz veri yok'), findsOneWidget);
    });

    testWidgets('all six tabs render on a 320x568 dark screen without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(hostFor(
        serviceFor(InMemoryAnalyticsDataSource(seedCollections())),
        theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      const tabs = ['Pro', 'İçerik', 'Kasa', 'Tercihler', 'Moderasyon'];
      const markers = ['Toplam Pro', 'Toplam seyahat', 'Toplam belge', 'Analitik açık rıza', 'Banlı hesap'];
      for (var i = 0; i < tabs.length; i++) {
        await tester.ensureVisible(find.widgetWithText(Tab, tabs[i]));
        await tester.tap(find.widgetWithText(Tab, tabs[i]));
        await tester.pumpAndSettle();
        expect(find.text(markers[i]), findsOneWidget, reason: 'tab ${tabs[i]}');
        expect(tester.takeException(), isNull, reason: 'overflow on tab ${tabs[i]}');
      }
    });
  });
}
