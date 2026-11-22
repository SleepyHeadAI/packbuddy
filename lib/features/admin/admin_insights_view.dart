part of 'admin_dashboard_screen.dart';

/// Extended travel-intelligence insights (session engagement, world map demand, trip
/// analytics, user geography, social graph, travel personas, KVKK deletion archive).
///
/// Moved out of the main admin dashboard (Faz 2) and shown as the "Ek Analizler" tab of
/// [AdminAnalyticsScreen]. Its heavy queries ([AdminService.fetchDetailedAnalytics] and
/// [AdminService.fetchDeletedAccountsArchive]) run only when this view is first shown, via
/// [AdminController.loadInsights]; afterwards the controller keeps the result in memory.
class AdminLegacyInsightsView extends ConsumerStatefulWidget {
  const AdminLegacyInsightsView({super.key});

  @override
  ConsumerState<AdminLegacyInsightsView> createState() => _AdminLegacyInsightsViewState();
}

class _AdminLegacyInsightsViewState extends ConsumerState<AdminLegacyInsightsView> {
  final Set<String> _expandedCountries = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(adminControllerProvider.notifier).loadInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminState = ref.watch(adminControllerProvider);

    if (!adminState.insightsLoaded) {
      return Center(
        key: const ValueKey('admin_insights_loading'),
        child: adminState.isInsightsLoading
            ? const CircularProgressIndicator()
            : TextButton.icon(
                onPressed: () => ref.read(adminControllerProvider.notifier).loadInsights(force: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Yeniden dene'),
              ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminControllerProvider.notifier).loadInsights(force: true),
      child: ListView(
        key: const PageStorageKey('admin_insights_list'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
        children: [
          _buildEngagementAnalyticsSection(context, adminState.detailedAnalytics, isDark),
          const SizedBox(height: 20),
          _buildWorldMapAnalyticsCard(context, adminState, isDark),
          const SizedBox(height: 20),
          _buildTripAnalyticsCard(context, adminState.detailedAnalytics, isDark),
          const SizedBox(height: 20),
          _buildGeoAnalyticsSection(context, adminState, isDark, l10n),
          const SizedBox(height: 20),
          _buildSocialAndCommunityAnalyticsCard(context, adminState, isDark),
          const SizedBox(height: 20),
          _buildTravelStylesAndPersonaAnalyticsCard(context, adminState.detailedAnalytics, isDark),
          const SizedBox(height: 20),
          _buildDeletedAccountsAnalyticsCard(context, adminState.deletedAccountsSummary, isDark),
        ],
      ),
    );
  }

  /// Interactive Live Engagement & Session Analytics
  Widget _buildEngagementAnalyticsSection(
    BuildContext context,
    AdminDetailedAnalytics analytics,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    final avgSessionStr = analytics.formattedAverageSessionDuration;
    final totalDurationStr = analytics.formattedTotalPlatformDuration;
    final avgTripDaysStr = analytics.formattedAverageTripDuration;
    final avgExpenseStr = analytics.formattedAverageExpense;

    return AppCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 20,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Kullanım & Oturum İstatistikleri' : 'Usage & Session Analytics',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      isTr
                          ? 'Tüm kullanıcıların toplam ve ortalama oturum süreleri ile etkileşimi'
                          : 'Platform-wide aggregated user session duration & activity',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2x2 Grid of Live Engagement Metrics
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Ortalama Süre' : 'Avg Session',
                  value: avgSessionStr,
                  subtitle: isTr ? 'Oturum başına' : 'Per session',
                  icon: Icons.timer_rounded,
                  iconColor: const Color(0xFFD97706),
                  bgColor: isDark ? const Color(0xFF2E2312) : const Color(0xFFFEF3C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Toplam Süre' : 'Total App Time',
                  value: totalDurationStr,
                  subtitle: isTr ? 'Platform geneli' : 'Platform logged',
                  icon: Icons.hourglass_top_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  bgColor: isDark ? const Color(0xFF132338) : const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Ortalama Gezi' : 'Avg Trip Length',
                  value: avgTripDaysStr,
                  subtitle: isTr ? 'Planlanan süre' : 'Planned duration',
                  icon: Icons.date_range_rounded,
                  iconColor: const Color(0xFF10B981),
                  bgColor: isDark ? const Color(0xFF132E27) : const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Gezi Başı Bütçe' : 'Avg Expense / Trip',
                  value: avgExpenseStr,
                  subtitle: isTr ? 'Ortalama harcama' : 'Per trip spend',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: isDark ? const Color(0xFF241B36) : const Color(0xFFF5F3FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Platform Conversion & Verification Rates
          Text(
            isTr ? 'Platform Sağlık Oranları' : 'Platform Health Ratios',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _buildHealthProgressBar(
            label: isTr ? 'Pro Üye Dönüşüm Oranı' : 'Pro Conversion Rate',
            value: analytics.proConversionRate,
            displayValue: '%${(analytics.proConversionRate * 100).toStringAsFixed(1)}',
            barColor: const Color(0xFFD97706),
          ),
          const SizedBox(height: 10),
          _buildHealthProgressBar(
            label: isTr ? 'Doğrulanmış Hesap Oranı' : 'Verified Accounts Rate',
            value: analytics.emailVerificationRate,
            displayValue: '%${(analytics.emailVerificationRate * 100).toStringAsFixed(1)}',
            barColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthProgressBar({
    required String label,
    required double value,
    required String displayValue,
    required Color barColor,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  /// World Travel Map Analytics (Wishlist, Visited, Lived, Continents) - Strictly from Travel Map
  Widget _buildWorldMapAnalyticsCard(
    BuildContext context,
    AdminState state,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final activeTab = state.selectedCountryAnalyticsTab;
    final analytics = state.detailedAnalytics;

    List<CountryTravelMetric> countryList;
    Color themeColor;
    String title;
    String subtitle;
    String emptyMessage;

    switch (activeTab) {
      case 'visited':
        countryList = analytics.topVisitedCountries;
        themeColor = const Color(0xFF3B82F6);
        title = isTr ? 'Haritada Gezilen Ülkeler' : 'World Map: Visited Countries';
        subtitle = isTr
            ? 'Kullanıcıların Dünya Haritasında bizzat gezildi olarak işaretlediği ülkeler'
            : 'Destinations marked as visited on travelers world maps';
        emptyMessage = isTr
            ? 'Kullanıcılar Dünya Haritasında gezdikleri ülkeleri işaretledikçe burada listelenir.'
            : 'Will appear as users mark visited countries on map.';
        break;
      case 'lived':
        countryList = analytics.topLivedCountries;
        themeColor = const Color(0xFF10B981);
        title = isTr ? 'Kullanıcıların Yaşadığı Ülkeler' : 'World Map: Residence & Lived';
        subtitle = isTr
            ? 'Kullanıcıların haritada yaşadım/ikamet olarak işaretlediği yerler ve profil kökenleri'
            : 'Primary residences and places users lived on map';
        emptyMessage = isTr
            ? 'Kullanıcıların haritada yaşadıkları ülkeler burada listelenir.'
            : 'User residences from map will appear here.';
        break;
      case 'continents':
        countryList = const [];
        themeColor = const Color(0xFF8B5CF6);
        title = isTr ? 'Harita Kıtalar Dağılımı' : 'World Map: Continent Breakdown';
        subtitle = isTr
            ? 'Kullanıcıların harita işaretlemelerine göre kıtalar bazında dağılımı'
            : 'Regional breakdown of map marks across the 5 continents';
        emptyMessage = isTr
            ? 'Kıta harita verileri toplanıyor.'
            : 'Continent map data is being aggregated.';
        break;
      case 'wishlist':
      default:
        countryList = analytics.topWishlistCountries;
        themeColor = const Color(0xFFD97706);
        title = isTr ? 'Haritada Gitmek İstenen Ülkeler' : 'World Map: Wishlist Destinations';
        subtitle = isTr
            ? 'Kullanıcıların Dünya Haritasında keşfetmek/gitmek istiyorum olarak işaretlediği hedefler'
            : 'Destinations marked on wishlist bucket list by travelers';
        emptyMessage = isTr
            ? 'Kullanıcılar Dünya Haritasında gitmek istedikleri ülkeleri işaretledikçe burada listelenir.'
            : 'Will appear as users mark wishlist countries on map.';
        break;
    }

    return AppCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.public_rounded,
                  size: 20,
                  color: themeColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isTr ? 'Dünya Haritası Verileri İstatistikleri' : 'World Travel Map Analytics',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isTr ? 'Harita Kaynaklı' : 'Map Sourced',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: themeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive Segmented Tab Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCountryHubTab(
                  context: context,
                  label: isTr ? '🌟 Gitmek İstenen' : '🌟 Wishlist',
                  tabKey: 'wishlist',
                  current: activeTab,
                  activeColor: const Color(0xFFD97706),
                ),
                const SizedBox(width: 8),
                _buildCountryHubTab(
                  context: context,
                  label: isTr ? '✈️ Gezilen & Görülen' : '✈️ Visited',
                  tabKey: 'visited',
                  current: activeTab,
                  activeColor: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 8),
                _buildCountryHubTab(
                  context: context,
                  label: isTr ? '🏠 Yaşanılan Ülke' : '🏠 Residence',
                  tabKey: 'lived',
                  current: activeTab,
                  activeColor: const Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                _buildCountryHubTab(
                  context: context,
                  label: isTr ? '🌍 Kıtalar' : '🌍 Continents',
                  tabKey: 'continents',
                  current: activeTab,
                  activeColor: const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Content of Active Tab
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: themeColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (activeTab != 'continents' && countryList.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  isTr ? '${countryList.length} Ülke' : '${countryList.length} Countries',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          if (activeTab == 'continents')
            _buildContinentList(context, analytics.continentShares)
          else if (countryList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 36,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      emptyMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: countryList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildCountryRankRow(
                  context: context,
                  rank: index + 1,
                  item: item,
                  color: themeColor,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCountryHubTab({
    required BuildContext context,
    required String label,
    required String tabKey,
    required String current,
    required Color activeColor,
  }) {
    final isSelected = tabKey == current;
    final theme = Theme.of(context);

    return BouncyPressable(
      onTap: () {
        ref.read(adminControllerProvider.notifier).setCountryAnalyticsTab(tabKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildCountryRankRow({
    required BuildContext context,
    required int rank,
    required CountryTravelMetric item,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final percentStr = (item.percentage * 100).toStringAsFixed(1);

    Color rankBg;
    Color rankText;
    if (rank == 1) {
      rankBg = const Color(0xFFFEF3C7);
      rankText = const Color(0xFFD97706);
    } else if (rank == 2) {
      rankBg = const Color(0xFFF1F5F9);
      rankText = const Color(0xFF64748B);
    } else if (rank == 3) {
      rankBg = const Color(0xFFFFEDD5);
      rankText = const Color(0xFFC2410C);
    } else {
      rankBg = theme.colorScheme.surfaceContainerHighest;
      rankText = theme.colorScheme.onSurfaceVariant;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: rankBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: rankText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(item.flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.countryName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.countryCode,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.count} (%$percentStr)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.percentage.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinentList(
    BuildContext context,
    List<ContinentShareMetric> continentShares,
  ) {
    final theme = Theme.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    if (continentShares.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            isTr ? 'Kıta seyahat verileri toplanıyor.' : 'Continent data is being aggregated.',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final langCode = Localizations.localeOf(context).languageCode;

    return Column(
      children: continentShares.map((c) {
        final percentStr = (c.percentage * 100).toStringAsFixed(1);
        final localizedName = ContinentLocalization.getContinentName(c.continentName, langCode);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(c.icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizedName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${c.count} (%$percentStr)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: c.percentage.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Trip Data Analytics (Destinations, Dates, Budgets, Transport, Currencies) - Strictly from Trips collection
  Widget _buildTripAnalyticsCard(
    BuildContext context,
    AdminDetailedAnalytics analytics,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    return AppCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flight_takeoff_rounded,
                  size: 20,
                  color: Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isTr ? 'Seyahat Verileri İstatistikleri' : 'Trip Data Analytics',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isTr ? 'Seyahatler Kaynaklı' : 'Trips Sourced',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0EA5E9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTr
                          ? 'Planlanan gerçek seyahatler, rotalar, harcamalar ve ulaşım tercihleri'
                          : 'Real trip itineraries, destinations, budgets and transport modes',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 Mini Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Yaklaşan Geziler' : 'Upcoming Trips',
                  value: '${analytics.upcomingTripsCount}',
                  subtitle: isTr ? 'Gelecek planlar' : 'Scheduled ahead',
                  icon: Icons.flight_takeoff_rounded,
                  iconColor: const Color(0xFF0EA5E9),
                  bgColor: isDark ? const Color(0xFF0C2B3E) : const Color(0xFFE0F2FE),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Tamamlanan Geziler' : 'Past Trips',
                  value: '${analytics.completedTripsCount}',
                  subtitle: isTr ? 'Geçmiş seyahatler' : 'Completed travels',
                  icon: Icons.flight_land_rounded,
                  iconColor: const Color(0xFF10B981),
                  bgColor: isDark ? const Color(0xFF132E27) : const Color(0xFFECFDF5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Ortalama Süre' : 'Avg Duration',
                  value: analytics.formattedAverageTripDuration,
                  subtitle: isTr ? 'Seyahat başına' : 'Per itinerary',
                  icon: Icons.date_range_rounded,
                  iconColor: const Color(0xFFD97706),
                  bgColor: isDark ? const Color(0xFF2E2312) : const Color(0xFFFEF3C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Gezi Başı Harcama' : 'Avg Expense',
                  value: analytics.formattedAverageExpense,
                  subtitle: isTr ? 'Seyahat maliyeti' : 'Expense / trip',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: isDark ? const Color(0xFF241B36) : const Color(0xFFF5F3FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // En Çok Seyahat Planlanan Rotalar
          Text(
            isTr ? 'En Çok Seyahat Planlanan Rotalar (Ülkeler)' : 'Top Planned Trip Destinations',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (analytics.topTripDestinations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  isTr
                      ? 'Kullanıcılar yeni seyahat oluşturdukça rotalar burada listelenir.'
                      : 'Will appear as travelers create trips.',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            Column(
              children: analytics.topTripDestinations.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildCountryRankRow(
                  context: context,
                  rank: index + 1,
                  item: item,
                  color: const Color(0xFF0EA5E9),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Transport Mode Preferences
          Text(
            isTr ? 'Popüler Ulaşım Modları' : 'Transport Modes',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 10),
          if (analytics.transportPreferences.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                isTr
                    ? 'Gezilere ulaşım türü eklendikçe burada listelenir.'
                    : 'Will appear as trips specify transport.',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: analytics.transportPreferences.map((t) {
                final percent = (t.percentage * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(t.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: Text(
                          t.label,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: t.percentage.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${t.count} (%$percent)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Top Currencies & Vault Categories
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Currencies Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Para Birimleri' : 'Currencies',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (analytics.currencyShares.isEmpty)
                      Text(
                        isTr ? 'Veri toplanıyor' : 'Aggregating',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      )
                    else
                      ...analytics.currencyShares.take(4).map((c) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c.currencyCode,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${c.count} (%${(c.percentage * 100).toStringAsFixed(0)})',
                                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Vault Categories Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Kasa Belge Türleri' : 'Vault Categories',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (analytics.vaultCategories.isEmpty)
                      Text(
                        isTr ? 'Belge yüklenmedi' : 'No docs yet',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      )
                    else
                      ...analytics.vaultCategories.take(4).map((v) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.description_outlined, size: 13, color: Color(0xFF8B5CF6)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  v.label,
                                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${v.count}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Interactive Period Geo-Analytics & Activity Section
  Widget _buildGeoAnalyticsSection(
    BuildContext context,
    AdminState state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final activeUsers = state.activeUsersInPeriod;
    final breakdown = state.countryBreakdown;

    return AppCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Globe Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.public_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.adminGeoAnalytics,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l10n.localeName.startsWith('tr')
                          ? 'Anlık Canlı Konum ve Şehir Dağılımı (Detay için dokunun)'
                          : 'Real-Time Live Location & City Breakdown (Tap to expand)',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successPastel.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.successPastel,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${activeUsers.length} Active',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successPastel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Period Filter Selector (Live, Daily, Weekly, Monthly, Yearly)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodChip(
                  label: l10n.adminPeriodLive,
                  period: AnalyticsPeriod.live,
                  current: state.analyticsPeriod,
                ),
                const SizedBox(width: 8),
                _buildPeriodChip(
                  label: l10n.adminPeriodDaily,
                  period: AnalyticsPeriod.daily,
                  current: state.analyticsPeriod,
                ),
                const SizedBox(width: 8),
                _buildPeriodChip(
                  label: l10n.adminPeriodWeekly,
                  period: AnalyticsPeriod.weekly,
                  current: state.analyticsPeriod,
                ),
                const SizedBox(width: 8),
                _buildPeriodChip(
                  label: l10n.adminPeriodMonthly,
                  period: AnalyticsPeriod.monthly,
                  current: state.analyticsPeriod,
                ),
                const SizedBox(width: 8),
                _buildPeriodChip(
                  label: l10n.adminPeriodYearly,
                  period: AnalyticsPeriod.yearly,
                  current: state.analyticsPeriod,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Country Breakdown Content
          if (breakdown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_off_rounded,
                      size: 32,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.adminNoActiveUsers,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: breakdown.map((item) {
                final flag = countryCodeToFlagEmoji(item.countryCode);
                final percentStr = (item.percentage * 100).toStringAsFixed(1);
                final isTr = l10n.localeName.startsWith('tr');
                final localizedCountry = CountryLocalization.getCountryName(item.countryCode, l10n.localeName) ?? item.countryName;
                final isExpanded = _expandedCountries.contains(item.countryCode);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    key: ValueKey('geo_country_${item.countryCode}'),
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedCountries.remove(item.countryCode);
                        } else {
                          _expandedCountries.add(item.countryCode);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                flag,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$localizedCountry (${item.countryCode})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${item.activeUserCount} ($percentStr%)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: item.percentage.clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isTr
                                              ? '${localizedCountry.toUpperCase()} ŞEHİR DAĞILIMI'
                                              : '${item.countryCode} CITY BREAKDOWN',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isTr
                                            ? '($localizedCountry içi oran)'
                                            : '(share of country)',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontStyle: FontStyle.italic,
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (item.cities.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        isTr ? 'Şehir verisi henüz kaydedilmedi' : 'No city data yet',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  else
                                    ...item.cities.map((city) {
                                      final cityPercentStr = (city.percentage * 100).toStringAsFixed(1);
                                      final cityNameDisplay = city.cityName.isNotEmpty
                                          ? city.cityName
                                          : (isTr ? 'Diğer / Bilinmeyen Şehir' : 'Other / Unknown City');

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.location_on_rounded,
                                                        size: 11,
                                                        color: theme.colorScheme.primary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Flexible(
                                                        child: Text(
                                                          cityNameDisplay,
                                                          style: TextStyle(
                                                            fontSize: 11.5,
                                                            fontWeight: FontWeight.w600,
                                                            color: theme.colorScheme.onSurface,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${city.activeUserCount} (%$cityPercentStr)',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(3),
                                              child: LinearProgressIndicator(
                                                value: city.percentage.clamp(0.0, 1.0),
                                                minHeight: 4,
                                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  theme.colorScheme.primary.withValues(alpha: 0.75),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip({
    required String label,
    required AnalyticsPeriod period,
    required AnalyticsPeriod current,
  }) {
    final isSelected = period == current;
    final theme = Theme.of(context);

    return BouncyPressable(
      onTap: () {
        ref.read(adminControllerProvider.notifier).setAnalyticsPeriod(period);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }


  /// Global Social Network & Friendship Intelligence Hub Card
  Widget _buildSocialAndCommunityAnalyticsCard(
    BuildContext context,
    AdminState state,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final detailed = state.detailedAnalytics;

    final friendshipsCount = detailed.totalFriendships > 0
        ? detailed.totalFriendships
        : state.metrics.totalFriendships;
    final pendingCount = detailed.totalPendingFriendRequests > 0
        ? detailed.totalPendingFriendRequests
        : state.metrics.totalPendingFriendRequests;
    final usernamesClaimed = state.metrics.totalUsernamesClaimed > 0
        ? state.metrics.totalUsernamesClaimed
        : state.allUsers.where((u) => u.hasUsername).length;
    final totalUsers = state.allUsers.length;
    final usernamePct = totalUsers > 0 ? (usernamesClaimed / totalUsers * 100) : 0.0;
    final avgFriends = detailed.averageFriendsPerUser > 0
        ? detailed.averageFriendsPerUser
        : (totalUsers > 0 ? (friendshipsCount * 2 / totalUsers) : 0.0);

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.diversity_3_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isTr ? 'Sosyal Ağ & Arkadaşlık Analitiği' : 'Social Network & Friends Hub',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isTr ? 'Topluluk' : 'Community',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTr
                          ? 'Gezginler arası arkadaşlık bağlantıları, bekleyen istekler ve kullanıcı adı sahipliği.'
                          : 'Travel buddy connections, pending friend requests and @username adoption.',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 4 Mini Metrics
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Toplam Arkadaşlık' : 'Friendships',
                  value: '$friendshipsCount',
                  subtitle: isTr ? 'Onaylı Bağlantı' : 'Confirmed',
                  icon: Icons.handshake_rounded,
                  iconColor: const Color(0xFF0284C7),
                  bgColor: isDark ? const Color(0xFF0C2433) : const Color(0xFFE0F2FE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Bekleyen İstek' : 'Requests',
                  value: '$pendingCount',
                  subtitle: isTr ? 'Cevap Bekleyen' : 'Pending',
                  icon: Icons.mark_email_unread_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  bgColor: isDark ? const Color(0xFF2E2312) : const Color(0xFFFEF3C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? '@Kullanıcı Adı' : '@Username Claim',
                  value: '%${usernamePct.toStringAsFixed(1)}',
                  subtitle: isTr ? '$usernamesClaimed Gezgin' : '$usernamesClaimed Claimed',
                  icon: Icons.alternate_email_rounded,
                  iconColor: const Color(0xFF10B981),
                  bgColor: isDark ? const Color(0xFF132E27) : const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Ortalama Arkadaş' : 'Avg Friends',
                  value: avgFriends.toStringAsFixed(1),
                  subtitle: isTr ? 'Gezgin Başına' : 'Per Traveler',
                  icon: Icons.people_alt_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: isDark ? const Color(0xFF24153E) : const Color(0xFFF3E8FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Global Travel Styles, Persona & Achievements Analytics Card
  Widget _buildTravelStylesAndPersonaAnalyticsCard(
    BuildContext context,
    AdminDetailedAnalytics detailed,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    final styles = detailed.travelStyleShares;
    final diamondBadges = detailed.badgeTierShares.firstWhere((b) => b.key == 'diamond', orElse: () => const PreferenceShareMetric(key: 'diamond', label: 'Elmas', icon: '💎', count: 0, percentage: 0)).count;
    final goldBadges = detailed.badgeTierShares.firstWhere((b) => b.key == 'gold', orElse: () => const PreferenceShareMetric(key: 'gold', label: 'Altın', icon: '🥇', count: 0, percentage: 0)).count;
    final silverBadges = detailed.badgeTierShares.firstWhere((b) => b.key == 'silver', orElse: () => const PreferenceShareMetric(key: 'silver', label: 'Gümüş', icon: '🥈', count: 0, percentage: 0)).count;
    final bronzeBadges = detailed.badgeTierShares.firstWhere((b) => b.key == 'bronze', orElse: () => const PreferenceShareMetric(key: 'bronze', label: 'Bronz', icon: '🥉', count: 0, percentage: 0)).count;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Seyahat Tarzı & Başarım Analitiği' : 'Travel Persona & Achievements',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTr
                          ? 'Gezgin tarzları, profil doluluk metrikleri ve kazanılan başarı rozetleri.'
                          : 'Persona preferences, profile completeness and unlocked achievements.',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Profil Doluluk Barları
          Text(
            isTr ? 'Profil Tamamlama Oranları' : 'Profile Completeness Index',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildHealthProgressBar(
            label: isTr ? '@Kullanıcı Adı Sahipliği' : '@Username Handle Claimed',
            value: detailed.usernameClaimRate,
            displayValue: '%${(detailed.usernameClaimRate * 100).toStringAsFixed(1)}',
            barColor: const Color(0xFF0284C7),
          ),
          const SizedBox(height: 6),
          _buildHealthProgressBar(
            label: isTr ? 'Biyografi (Hakkında) Yazma' : 'Bio Written',
            value: detailed.bioAdoptionRate,
            displayValue: '%${(detailed.bioAdoptionRate * 100).toStringAsFixed(1)}',
            barColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 6),
          _buildHealthProgressBar(
            label: isTr ? 'Seyahat Durumu Paylaşma' : 'Travel Status Set',
            value: detailed.travelStatusAdoptionRate,
            displayValue: '%${(detailed.travelStatusAdoptionRate * 100).toStringAsFixed(1)}',
            barColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 6),
          _buildHealthProgressBar(
            label: isTr ? 'Seyahat Tarzı Seçimi' : 'Travel Style Selected',
            value: detailed.travelStylesAdoptionRate,
            displayValue: '%${(detailed.travelStylesAdoptionRate * 100).toStringAsFixed(1)}',
            barColor: const Color(0xFF8B5CF6),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 2. Popüler Seyahat Tarzları
          Text(
            isTr ? 'En Popüler Seyahat Tarzları' : 'Popular Travel Styles',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (styles.isEmpty)
            Text(
              isTr ? 'Henüz seyahat tarzı verisi toplanmadı.' : 'No travel style data collected yet.',
              style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: styles.take(8).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(s.icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '${s.label} (${s.count})',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 3. Başarım Rozetleri Dağılımı
          Text(
            isTr ? 'Kazanılan Seyahat Başarım Rozetleri' : 'Unlocked Achievement Badges',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        '$diamondBadges',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF00BCD4)),
                      ),
                      Text(
                        isTr ? 'Elmas' : 'Diamond',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF00BCD4), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text('🥇', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        '$goldBadges',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFFFF8F00)),
                      ),
                      Text(
                        isTr ? 'Altın' : 'Gold',
                        style: const TextStyle(fontSize: 10, color: Color(0xFFFF8F00), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9E9E9E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text('🥈', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        '$silverBadges',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF757575)),
                      ),
                      Text(
                        isTr ? 'Gümüş' : 'Silver',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF757575), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCD7F32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text('🥉', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        '$bronzeBadges',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF8D5524)),
                      ),
                      Text(
                        isTr ? 'Bronz' : 'Bronze',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF8D5524), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedAccountsAnalyticsCard(
    BuildContext context,
    DeletedAccountsSummary summary,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      backgroundColor: isDark ? AppColors.surfaceRaisedDark : AppColors.surfaceRaisedLight,
      border: BorderSide(
        color: isDark ? AppColors.borderSubtle(true) : AppColors.borderSubtle(false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.errorPastel.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_delete_rounded, color: AppColors.errorPastel, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Kalıcı Hesap Silme & KVKK Analitik Arşivi' : 'Deleted Accounts & GDPR Analytics',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      isTr
                          ? 'Google Play Veri Güvenliği uyumlu anonim retention verileri'
                          : 'Google Play Data Safety compliant anonymized retention metrics',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.errorPastel.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${summary.totalDeleted} ${isTr ? "Kayıt" : "Records"}',
                  style: const TextStyle(
                    color: AppColors.errorPastel,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Ort. Seyahat' : 'Avg Trips',
                  value: summary.avgTripsBeforeDeletion.toStringAsFixed(1),
                  subtitle: isTr ? 'Silinmeden önce' : 'Before deletion',
                  icon: Icons.flight_takeoff_rounded,
                  iconColor: AppColors.primaryAmber,
                  bgColor: AppColors.primaryAmber.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Ort. Eşya' : 'Avg Items',
                  value: summary.avgItemsBeforeDeletion.toStringAsFixed(1),
                  subtitle: isTr ? 'Liste büyüklüğü' : 'List size',
                  icon: Icons.checklist_rtl_rounded,
                  iconColor: AppColors.secondaryLight,
                  bgColor: AppColors.secondaryLight.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStatCard(
                  context: context,
                  title: isTr ? 'Pro Dönüşüm' : 'Pro Users',
                  value: '%${summary.proUserPercentage.toStringAsFixed(0)}',
                  subtitle: isTr ? 'Abonelik payı' : 'Subscription share',
                  icon: Icons.workspace_premium_rounded,
                  iconColor: AppColors.actionGold,
                  bgColor: AppColors.actionGold.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
