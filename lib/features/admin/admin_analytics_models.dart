/// Data models for the detailed admin analytics screen ([AdminAnalyticsScreen]).
///
/// Every value here is derived from real Firestore data by [AdminAnalyticsService]:
/// headline numbers use server-side `count()` / `sum()` aggregations, distributions use a
/// bounded document sample (max [kAdminAnalyticsSampleLimit] docs per collection). Sampled
/// distributions carry [SampledDistribution.sampledCount] / [SampledDistribution.totalCount]
/// so the UI can show transparently how many documents a breakdown was computed from.
library;

/// Upper bound of documents read per collection for analytics distributions (Faz B #5).
const int kAdminAnalyticsSampleLimit = 1000;

/// Time window selectable on the analytics screen.
enum AdminAnalyticsRange {
  days7(7, '7G'),
  days30(30, '30G'),
  days90(90, '90G'),
  all(null, 'Tümü');

  const AdminAnalyticsRange(this.days, this.label);

  /// Window length in days; `null` means no lower bound (all time).
  final int? days;

  /// Short chip label shown in the range selector.
  final String label;

  /// Inclusive lower bound of the window, or `null` for [all].
  DateTime? cutoff(DateTime now) => days == null ? null : now.subtract(Duration(days: days!));

  /// Bucket size used for the new-signup time series.
  AdminSeriesBucket get bucket {
    switch (this) {
      case AdminAnalyticsRange.days7:
      case AdminAnalyticsRange.days30:
        return AdminSeriesBucket.day;
      case AdminAnalyticsRange.days90:
        return AdminSeriesBucket.week;
      case AdminAnalyticsRange.all:
        return AdminSeriesBucket.month;
    }
  }
}

enum AdminSeriesBucket { day, week, month }

/// One labelled bucket of a distribution (language, currency, destination...).
class DistributionEntry {
  final String key;
  final String label;
  final int count;

  const DistributionEntry({required this.key, required this.label, required this.count});
}

/// A ranked distribution, optionally computed from a bounded sample.
class SampledDistribution {
  /// Entries sorted by [DistributionEntry.count] descending.
  final List<DistributionEntry> entries;

  /// Number of documents the distribution was computed from.
  final int sampledCount;

  /// Exact number of documents in the population (from `count()`), or [sampledCount]
  /// when the distribution is exact.
  final int totalCount;

  const SampledDistribution({
    this.entries = const [],
    this.sampledCount = 0,
    this.totalCount = 0,
  });

  static const SampledDistribution empty = SampledDistribution();

  bool get isEmpty => entries.isEmpty || entries.every((e) => e.count == 0);

  /// True when only a subset of the population was read.
  bool get isSampled => sampledCount < totalCount;

  int get entriesTotal => entries.fold(0, (sum, e) => sum + e.count);

  /// Share of [entry] within the distribution (0.0 – 1.0).
  double shareOf(DistributionEntry entry) {
    final total = entriesTotal;
    return total == 0 ? 0.0 : entry.count / total;
  }
}

/// A point of a time series (e.g. new signups per day).
class TimeSeriesPoint {
  final DateTime bucketStart;
  final int count;

  const TimeSeriesPoint({required this.bucketStart, required this.count});
}

/// Growth & activity module.
class GrowthAnalytics {
  final int totalUsers;
  final int dailyActiveUsers;
  final int weeklyActiveUsers;
  final int monthlyActiveUsers;
  final int newSignupsInRange;
  final List<TimeSeriesPoint> signupSeries;
  final AdminSeriesBucket seriesBucket;

  /// Users read to build [signupSeries] vs. exact [newSignupsInRange].
  final int seriesSampledCount;
  final int verifiedUsers;
  final int inactive150DaysUsers;

  const GrowthAnalytics({
    this.totalUsers = 0,
    this.dailyActiveUsers = 0,
    this.weeklyActiveUsers = 0,
    this.monthlyActiveUsers = 0,
    this.newSignupsInRange = 0,
    this.signupSeries = const [],
    this.seriesBucket = AdminSeriesBucket.day,
    this.seriesSampledCount = 0,
    this.verifiedUsers = 0,
    this.inactive150DaysUsers = 0,
  });

  double get verifiedRate => _ratio(verifiedUsers, totalUsers);
}

/// Pro & subscription module.
class ProAnalytics {
  final int totalPro;
  final int playSubscribers;
  final int adminGrantedPro;
  final int monthlySubscribers;
  final int annualSubscribers;
  final int totalUsers;

  const ProAnalytics({
    this.totalPro = 0,
    this.playSubscribers = 0,
    this.adminGrantedPro = 0,
    this.monthlySubscribers = 0,
    this.annualSubscribers = 0,
    this.totalUsers = 0,
  });

  double get conversionRate => _ratio(totalPro, totalUsers);

  /// Play subscriptions with a product id other than the known monthly/annual ids.
  int get otherProductSubscribers {
    final other = playSubscribers - monthlySubscribers - annualSubscribers;
    return other < 0 ? 0 : other;
  }
}

/// Trips, expenses & content module.
class ContentAnalytics {
  final int totalTrips;
  final int tripsCreatedInRange;
  final int activeTrips;
  final int upcomingTrips;
  final int completedTrips;
  final int totalUsers;
  final SampledDistribution topDestinations;
  final int totalExpenses;
  final SampledDistribution topCurrencies;
  final int totalChecklistItems;
  final int packedChecklistItems;
  final int totalItineraryItems;
  final int sharedTrips;
  final int acceptedFriendships;
  final int pendingFriendships;

  const ContentAnalytics({
    this.totalTrips = 0,
    this.tripsCreatedInRange = 0,
    this.activeTrips = 0,
    this.upcomingTrips = 0,
    this.completedTrips = 0,
    this.totalUsers = 0,
    this.topDestinations = SampledDistribution.empty,
    this.totalExpenses = 0,
    this.topCurrencies = SampledDistribution.empty,
    this.totalChecklistItems = 0,
    this.packedChecklistItems = 0,
    this.totalItineraryItems = 0,
    this.sharedTrips = 0,
    this.acceptedFriendships = 0,
    this.pendingFriendships = 0,
  });

  double get averageTripsPerUser => totalUsers == 0 ? 0.0 : totalTrips / totalUsers;

  double get packedRate => _ratio(packedChecklistItems, totalChecklistItems);
}

/// Vault & storage module.
class VaultAnalytics {
  final int totalDocuments;
  final int pdfDocuments;
  final int totalStorageBytes;
  final int totalUsers;

  /// Users at or above 80% of their cloud quota (computed from the user sample).
  final int nearQuotaUsers;
  final int quotaSampledCount;
  final int pbenc2Documents;
  final int pbenc1Documents;

  const VaultAnalytics({
    this.totalDocuments = 0,
    this.pdfDocuments = 0,
    this.totalStorageBytes = 0,
    this.totalUsers = 0,
    this.nearQuotaUsers = 0,
    this.quotaSampledCount = 0,
    this.pbenc2Documents = 0,
    this.pbenc1Documents = 0,
  });

  int get imageDocuments {
    final images = totalDocuments - pdfDocuments;
    return images < 0 ? 0 : images;
  }

  double get averageStorageBytesPerUser => totalUsers == 0 ? 0.0 : totalStorageBytes / totalUsers;

  /// Documents without an encryption-version metadata field.
  int get unknownEncryptionDocuments {
    final unknown = totalDocuments - pbenc2Documents - pbenc1Documents;
    return unknown < 0 ? 0 : unknown;
  }
}

/// Global preferences & KVKK consent module.
class PreferenceAnalytics {
  final SampledDistribution languages;
  final SampledDistribution themes;
  final int analyticsOptIn;
  final int analyticsOptOut;
  final int totalUsers;

  const PreferenceAnalytics({
    this.languages = SampledDistribution.empty,
    this.themes = SampledDistribution.empty,
    this.analyticsOptIn = 0,
    this.analyticsOptOut = 0,
    this.totalUsers = 0,
  });

  /// Users who never answered the consent prompt (no `legalAnalyticsConsent` field).
  int get analyticsUnset {
    final unset = totalUsers - analyticsOptIn - analyticsOptOut;
    return unset < 0 ? 0 : unset;
  }

  double get optInRate => _ratio(analyticsOptIn, analyticsOptIn + analyticsOptOut);
}

/// Moderation & support module.
class ModerationAnalytics {
  final int temporaryBans;
  final int permanentBans;
  final SampledDistribution restrictedFeatures;
  final int totalFeedback;
  final SampledDistribution feedbackStatuses;
  final SampledDistribution auditActions;

  const ModerationAnalytics({
    this.temporaryBans = 0,
    this.permanentBans = 0,
    this.restrictedFeatures = SampledDistribution.empty,
    this.totalFeedback = 0,
    this.feedbackStatuses = SampledDistribution.empty,
    this.auditActions = SampledDistribution.empty,
  });

  int get bannedUsers => temporaryBans + permanentBans;
}

/// Full detailed analytics report for one [AdminAnalyticsRange].
class AdminAnalyticsReport {
  final AdminAnalyticsRange range;
  final DateTime fetchedAt;
  final GrowthAnalytics growth;
  final ProAnalytics pro;
  final ContentAnalytics content;
  final VaultAnalytics vault;
  final PreferenceAnalytics preferences;
  final ModerationAnalytics moderation;

  /// Number of individual queries that failed (their metrics fall back to 0).
  final int failedQueries;

  const AdminAnalyticsReport({
    required this.range,
    required this.fetchedAt,
    this.growth = const GrowthAnalytics(),
    this.pro = const ProAnalytics(),
    this.content = const ContentAnalytics(),
    this.vault = const VaultAnalytics(),
    this.preferences = const PreferenceAnalytics(),
    this.moderation = const ModerationAnalytics(),
    this.failedQueries = 0,
  });

  /// True when the platform has no data at all yet.
  bool get isEmpty =>
      growth.totalUsers == 0 && content.totalTrips == 0 && vault.totalDocuments == 0 && moderation.totalFeedback == 0;
}

double _ratio(int part, int total) => total <= 0 ? 0.0 : (part / total).clamp(0.0, 1.0).toDouble();
