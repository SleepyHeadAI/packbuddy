import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_card.dart';
import 'admin_analytics_service.dart';

/// Detailed admin statistics & analytics, opened on demand from the admin dashboard.
///
/// Queries run lazily only when this screen is opened; results are cached in memory per
/// range by [AdminAnalyticsService] so leaving and re-entering does not re-read Firestore.
/// The refresh button forces a new read.
class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  static const List<String> _tabs = ['Büyüme', 'Pro', 'İçerik', 'Kasa', 'Tercihler', 'Moderasyon'];

  AdminAnalyticsRange _range = AdminAnalyticsRange.days30;
  AdminAnalyticsReport? _report;
  Object? _error;
  bool _loading = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    final cached = ref.read(adminAnalyticsServiceProvider).cachedReport(_range);
    if (cached != null) {
      _report = cached;
    } else {
      _load();
    }
  }

  Future<void> _load({bool force = false}) async {
    final requestId = ++_requestId;
    final range = _range;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final report = await ref
          .read(adminAnalyticsServiceProvider)
          .fetchDetailedAnalytics(range: range, forceRefresh: force);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _report = report;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _selectRange(AdminAnalyticsRange range) {
    if (range == _range) return;
    _range = range;
    final cached = ref.read(adminAnalyticsServiceProvider).cachedReport(range);
    if (cached != null) {
      setState(() {
        _report = cached;
        _error = null;
      });
    } else {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    final showReport = report != null && report.range == _range && !_loading;

    Widget body;
    if (_error != null && !_loading) {
      body = _ErrorView(error: _error!, onRetry: () => _load(force: true));
    } else if (!showReport) {
      body = const _LoadingSkeleton();
    } else if (report.isEmpty) {
      body = const _EmptyView();
    } else {
      body = TabBarView(
        children: [
          _GrowthTab(report: report),
          _ProTab(report: report),
          _ContentTab(report: report),
          _VaultTab(report: report),
          _PreferencesTab(report: report),
          _ModerationTab(report: report),
        ],
      );
    }

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detaylı İstatistikler', maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              key: const ValueKey('admin_analytics_refresh'),
              tooltip: 'Yenile',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading ? null : () => _load(force: true),
            ),
          ],
          bottom: showReport && !report.isEmpty
              ? TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [for (final t in _tabs) Tab(text: t)],
                )
              : null,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _RangeHeader(
                range: _range,
                fetchedAt: showReport ? report.fetchedAt : null,
                failedQueries: showReport ? report.failedQueries : 0,
                enabled: !_loading,
                onSelect: _selectRange,
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================================
// Header / states
// ============================================================================================

class _RangeHeader extends StatelessWidget {
  final AdminAnalyticsRange range;
  final DateTime? fetchedAt;
  final int failedQueries;
  final bool enabled;
  final ValueChanged<AdminAnalyticsRange> onSelect;

  const _RangeHeader({
    required this.range,
    required this.fetchedAt,
    required this.failedQueries,
    required this.enabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final r in AdminAnalyticsRange.values)
                ChoiceChip(
                  key: ValueKey('admin_analytics_range_${r.name}'),
                  label: Text(r.label),
                  selected: r == range,
                  onSelected: enabled ? (_) => onSelect(r) : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            fetchedAt == null
                ? 'Yükleniyor…'
                : 'Son güncelleme: ${DateFormat('HH:mm').format(fetchedAt!)}'
                    '${failedQueries > 0 ? ' · $failedQueries sorgu yanıtlanamadı' : ''}',
            key: const ValueKey('admin_analytics_updated_at'),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final block = AppColors.surfaceRaised(isDark);
    Widget box(double height) => Container(
          height: height,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(color: block, borderRadius: BorderRadius.circular(16)),
        );
    return ListView(
      key: const ValueKey('admin_analytics_loading'),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(children: [Expanded(child: box(84)), const SizedBox(width: AppSpacing.md), Expanded(child: box(84))]),
        Row(children: [Expanded(child: box(84)), const SizedBox(width: AppSpacing.md), Expanded(child: box(84))]),
        box(160),
        box(120),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = error is AdminAnalyticsException ? (error as AdminAnalyticsException).message : '$error';
    return Center(
      key: const ValueKey('admin_analytics_error'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text('İstatistikler yüklenemedi', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              key: const ValueKey('admin_analytics_retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Yeniden dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      key: const ValueKey('admin_analytics_empty'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text('Henüz veri yok', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kullanıcı, seyahat veya belge oluştuğunda istatistikler burada görünecek.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================================
// Tabs
// ============================================================================================

class _TabList extends StatelessWidget {
  final String storageKey;
  final List<Widget> children;

  const _TabList({required this.storageKey, required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: PageStorageKey(storageKey),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) => children[i],
    );
  }
}

class _GrowthTab extends StatelessWidget {
  final AdminAnalyticsReport report;
  const _GrowthTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final g = report.growth;
    return _TabList(storageKey: 'analytics_growth', children: [
      _KpiGrid(items: [
        _Kpi('Toplam kullanıcı', _fmt(g.totalUsers), Icons.people_alt_outlined),
        _Kpi('Yeni kayıt (${report.range.label})', _fmt(g.newSignupsInRange), Icons.person_add_alt_1_outlined),
        _Kpi('DAU · 24s', _fmt(g.dailyActiveUsers), Icons.today_outlined),
        _Kpi('WAU · 7g', _fmt(g.weeklyActiveUsers), Icons.date_range_outlined),
        _Kpi('MAU · 30g', _fmt(g.monthlyActiveUsers), Icons.calendar_month_outlined),
        _Kpi('Doğrulanmış e-posta', _pct(g.verifiedRate), Icons.verified_outlined),
        _Kpi('150+ gün hareketsiz', _fmt(g.inactive150DaysUsers), Icons.hourglass_bottom_rounded),
      ]),
      _SeriesCard(
        title: 'Yeni kayıtlar · ${_bucketLabel(g.seriesBucket)}',
        points: g.signupSeries,
        bucket: g.seriesBucket,
        sampledCount: g.seriesSampledCount,
        totalCount: report.range == AdminAnalyticsRange.all ? g.totalUsers : g.newSignupsInRange,
      ),
    ]);
  }
}

class _ProTab extends StatelessWidget {
  final AdminAnalyticsReport report;
  const _ProTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final p = report.pro;
    return _TabList(storageKey: 'analytics_pro', children: [
      _KpiGrid(items: [
        _Kpi('Toplam Pro', _fmt(p.totalPro), Icons.workspace_premium_outlined),
        _Kpi('Dönüşüm oranı', _pct(p.conversionRate), Icons.trending_up_rounded),
        _Kpi('Google Play abonesi', _fmt(p.playSubscribers), Icons.shop_outlined),
        _Kpi('Admin Pro', _fmt(p.adminGrantedPro), Icons.admin_panel_settings_outlined),
      ]),
      _DistributionCard(
        title: 'Pro kaynağı',
        distribution: _exact([
          DistributionEntry(key: 'play', label: 'Google Play', count: p.playSubscribers),
          DistributionEntry(key: 'admin', label: 'Admin tarafından', count: p.adminGrantedPro),
        ]),
      ),
      _DistributionCard(
        title: 'Abonelik ürünü',
        distribution: _exact([
          DistributionEntry(key: 'monthly', label: 'Aylık', count: p.monthlySubscribers),
          DistributionEntry(key: 'annual', label: 'Yıllık', count: p.annualSubscribers),
          if (p.otherProductSubscribers > 0)
            DistributionEntry(key: 'other', label: 'Diğer ürün', count: p.otherProductSubscribers),
        ]),
      ),
    ]);
  }
}

class _ContentTab extends StatelessWidget {
  final AdminAnalyticsReport report;
  const _ContentTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final c = report.content;
    return _TabList(storageKey: 'analytics_content', children: [
      _KpiGrid(items: [
        _Kpi('Toplam seyahat', _fmt(c.totalTrips), Icons.luggage_outlined),
        _Kpi('Yeni seyahat (${report.range.label})', _fmt(c.tripsCreatedInRange), Icons.add_road_rounded),
        _Kpi('Kullanıcı başı seyahat', c.averageTripsPerUser.toStringAsFixed(2), Icons.person_pin_circle_outlined),
        _Kpi('Harcama kaydı', _fmt(c.totalExpenses), Icons.receipt_long_outlined),
        _Kpi('Bavul öğesi', _fmt(c.totalChecklistItems), Icons.checklist_rounded),
        _Kpi('Paketlenme oranı', _pct(c.packedRate), Icons.inventory_2_outlined),
        _Kpi('Plan aktivitesi', _fmt(c.totalItineraryItems), Icons.event_note_outlined),
        _Kpi('Paylaşılan seyahat', _fmt(c.sharedTrips), Icons.group_outlined),
        _Kpi('Arkadaşlık', _fmt(c.acceptedFriendships), Icons.handshake_outlined),
        _Kpi('Bekleyen istek', _fmt(c.pendingFriendships), Icons.mark_email_unread_outlined),
      ]),
      _DistributionCard(
        title: 'Seyahat durumu',
        distribution: _exact([
          DistributionEntry(key: 'active', label: 'Aktif', count: c.activeTrips),
          DistributionEntry(key: 'upcoming', label: 'Yaklaşan', count: c.upcomingTrips),
          DistributionEntry(key: 'completed', label: 'Tamamlanan', count: c.completedTrips),
        ]),
      ),
      _DistributionCard(title: 'En popüler 10 destinasyon', distribution: c.topDestinations),
      _DistributionCard(title: 'En popüler para birimleri', distribution: c.topCurrencies),
    ]);
  }
}

class _VaultTab extends StatelessWidget {
  final AdminAnalyticsReport report;
  const _VaultTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final v = report.vault;
    return _TabList(storageKey: 'analytics_vault', children: [
      _KpiGrid(items: [
        _Kpi('Toplam belge', _fmt(v.totalDocuments), Icons.folder_copy_outlined),
        _Kpi('Kullanılan depolama', formatAnalyticsBytes(v.totalStorageBytes), Icons.cloud_outlined),
        _Kpi('Kullanıcı başı', formatAnalyticsBytes(v.averageStorageBytesPerUser.round()), Icons.person_outline),
        _Kpi('%80+ kota', _fmt(v.nearQuotaUsers), Icons.warning_amber_rounded),
      ]),
      if (v.quotaSampledCount > 0 && v.quotaSampledCount < v.totalUsers)
        _SampleNote(sampled: v.quotaSampledCount, total: v.totalUsers, subject: 'kota hesabı'),
      _DistributionCard(
        title: 'Belge türü',
        distribution: _exact([
          DistributionEntry(key: 'pdf', label: 'PDF', count: v.pdfDocuments),
          DistributionEntry(key: 'image', label: 'Görsel', count: v.imageDocuments),
        ]),
      ),
      _DistributionCard(
        title: 'Şifreleme sürümü',
        distribution: _exact([
          DistributionEntry(key: 'PBENC2', label: 'PBENC2 · AES-GCM', count: v.pbenc2Documents),
          DistributionEntry(key: 'PBENC1', label: 'PBENC1 · eski', count: v.pbenc1Documents),
          DistributionEntry(key: 'unknown', label: 'Metadata yok', count: v.unknownEncryptionDocuments),
        ]),
      ),
    ]);
  }
}

class _PreferencesTab extends StatelessWidget {
  final AdminAnalyticsReport report;
  const _PreferencesTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final p = report.preferences;
    return _TabList(storageKey: 'analytics_prefs', children: [
      _KpiGrid(items: [
        _Kpi('Analitik açık rıza', _pct(p.optInRate), Icons.privacy_tip_outlined),
        _Kpi('Dil sayısı', _fmt(p.languages.entries.where((e) => e.key != 'unknown').length), Icons.translate_rounded),
      ]),
      _DistributionCard(
        title: 'Analitik rızası (KVKK)',
        distribution: _exact([
          DistributionEntry(key: 'in', label: 'Açık rıza (opt-in)', count: p.analyticsOptIn),
          DistributionEntry(key: 'out', label: 'Reddetti (opt-out)', count: p.analyticsOptOut),
          DistributionEntry(key: 'unset', label: 'Yanıtlanmamış', count: p.analyticsUnset),
        ]),
      ),
      _DistributionCard(title: 'Uygulama dili', distribution: p.languages),
      _DistributionCard(title: 'Tema tercihi', distribution: p.themes),
    ]);
  }
}

class _ModerationTab extends StatelessWidget {
  final AdminAnalyticsReport report;
  const _ModerationTab({required this.report});

  @override
  Widget build(BuildContext context) {
    final m = report.moderation;
    return _TabList(storageKey: 'analytics_moderation', children: [
      _KpiGrid(items: [
        _Kpi('Banlı hesap', _fmt(m.bannedUsers), Icons.block_rounded),
        _Kpi('Geçici ban', _fmt(m.temporaryBans), Icons.timer_outlined),
        _Kpi('Kalıcı ban', _fmt(m.permanentBans), Icons.gpp_bad_outlined),
        _Kpi('Geri bildirim', _fmt(m.totalFeedback), Icons.feedback_outlined),
      ]),
      _DistributionCard(title: 'Kısıtlı özellikler', distribution: m.restrictedFeatures),
      _DistributionCard(title: 'Geri bildirim durumu', distribution: m.feedbackStatuses),
      _DistributionCard(title: 'Denetim kayıtları (${report.range.label})', distribution: m.auditActions),
    ]);
  }
}

// ============================================================================================
// Building blocks
// ============================================================================================

class _Kpi {
  final String label;
  final String value;
  final IconData icon;
  const _Kpi(this.label, this.value, this.icon);
}

class _KpiGrid extends StatelessWidget {
  final List<_Kpi> items;
  const _KpiGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 640 ? 4 : 2;
      const gap = AppSpacing.md;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final item in items) SizedBox(width: width, child: _KpiTile(item: item))],
      );
    });
  }
}

class _KpiTile extends StatelessWidget {
  final _Kpi item;
  const _KpiTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return AppCard(
      padding: AppSpacing.cardPaddingDense,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 18, color: accent),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(item.value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SampleNote extends StatelessWidget {
  final int sampled;
  final int total;
  final String subject;
  const _SampleNote({required this.sampled, required this.total, this.subject = 'dağılım'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Örneklem: ${_fmt(sampled)} / ${_fmt(total)} belgeden $subject',
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
}

class _DistributionCard extends StatelessWidget {
  final String title;
  final SampledDistribution distribution;

  const _DistributionCard({required this.title, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final track = AppColors.surfaceRaised(isDark);
    final muted = theme.colorScheme.onSurfaceVariant;
    return AppCard(
      padding: AppSpacing.cardPadding,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(title),
          if (distribution.isSampled) ...[
            const SizedBox(height: AppSpacing.xs),
            _SampleNote(sampled: distribution.sampledCount, total: distribution.totalCount),
          ],
          const SizedBox(height: AppSpacing.md),
          if (distribution.isEmpty)
            Text('Veri yok', style: theme.textTheme.bodySmall?.copyWith(color: muted))
          else
            for (final entry in distribution.entries) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(entry.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_fmt(entry.count)} · ${_pct(distribution.shareOf(entry))}',
                    style: theme.textTheme.bodySmall?.copyWith(color: muted, fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: distribution.shareOf(entry),
                  minHeight: 6,
                  backgroundColor: track,
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  final String title;
  final List<TimeSeriesPoint> points;
  final AdminSeriesBucket bucket;
  final int sampledCount;
  final int totalCount;

  const _SeriesCard({
    required this.title,
    required this.points,
    required this.bucket,
    required this.sampledCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;
    final maxCount = points.fold<int>(0, (m, p) => math.max(m, p.count));
    final dateFormat = DateFormat(bucket == AdminSeriesBucket.month ? 'MM.yy' : 'dd.MM');

    return AppCard(
      padding: AppSpacing.cardPadding,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(title),
          if (sampledCount < totalCount) ...[
            const SizedBox(height: AppSpacing.xs),
            _SampleNote(sampled: sampledCount, total: totalCount),
          ],
          const SizedBox(height: AppSpacing.md),
          if (points.isEmpty || maxCount == 0)
            Text('Bu aralıkta yeni kayıt yok', style: theme.textTheme.bodySmall?.copyWith(color: muted))
          else ...[
            SizedBox(
              key: const ValueKey('admin_analytics_signup_chart'),
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final p in points)
                    Expanded(
                      child: Tooltip(
                        message: '${dateFormat.format(p.bucketStart)}: ${p.count}',
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: points.length > 40 ? 0.5 : 1.5),
                          child: FractionallySizedBox(
                            heightFactor: p.count == 0 ? 0.02 : math.max(0.04, p.count / maxCount),
                            alignment: Alignment.bottomCenter,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: p.count == 0 ? AppColors.surfaceRaised(isDark) : accent,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text(dateFormat.format(points.first.bucketStart), style: theme.textTheme.labelSmall?.copyWith(color: muted)),
                const Spacer(),
                Text('Zirve: ${_fmt(maxCount)}', style: theme.textTheme.labelSmall?.copyWith(color: muted)),
                const Spacer(),
                Text(dateFormat.format(points.last.bucketStart), style: theme.textTheme.labelSmall?.copyWith(color: muted)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================================
// Formatting
// ============================================================================================

SampledDistribution _exact(List<DistributionEntry> entries) {
  final total = entries.fold<int>(0, (s, e) => s + e.count);
  return SampledDistribution(entries: entries, sampledCount: total, totalCount: total);
}

final NumberFormat _numberFormat = NumberFormat.decimalPattern('tr');

String _fmt(num value) => _numberFormat.format(value);

String _pct(double ratio) => '%${(ratio * 100).toStringAsFixed(ratio > 0 && ratio < 0.1 ? 1 : 0)}';

String _bucketLabel(AdminSeriesBucket bucket) {
  switch (bucket) {
    case AdminSeriesBucket.day:
      return 'günlük';
    case AdminSeriesBucket.week:
      return 'haftalık';
    case AdminSeriesBucket.month:
      return 'aylık';
  }
}

/// Human-readable byte size (B / KB / MB / GB).
String formatAnalyticsBytes(int bytes) {
  if (bytes <= 0) return '0 MB';
  const kb = 1024;
  const mb = kb * 1024;
  const gb = mb * 1024;
  if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(2)} GB';
  if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
  if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(0)} KB';
  return '$bytes B';
}
