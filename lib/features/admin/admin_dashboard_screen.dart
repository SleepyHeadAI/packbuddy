import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';
import '../../core/services/security_service.dart';
import '../../core/services/email_dispatch_service.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/bouncy_pressable.dart';
import '../vault/domain/document.dart';
import '../budget/domain/country_localization.dart';
import 'admin_service.dart';
import 'admin_controller.dart';

/// Executive Admin Dashboard providing platform metrics, Geo-Analytics,
/// and interactive user entitlement & moderation management.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedCountries = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Strict access wall for non-admin accounts
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminDashboard),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.errorPastel.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.gpp_bad_rounded,
                    size: 64,
                    color: AppColors.errorPastel,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.adminAccessRestricted,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.adminAccessRestrictedDesc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                BouncyPressable(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l10n.ok,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final adminState = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.adminDashboard,
                style: const TextStyle(fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.syncNow,
            onPressed: () => ref.read(adminControllerProvider.notifier).refreshData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminControllerProvider.notifier).refreshData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Top Section: Executive Overview Header
            Text(
              l10n.adminMetrics,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.adminDashboardDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Platform Metrics Grid (Clutter-free, no redundant Verified card)
            _buildMetricsGrid(context, adminState.metrics, isDark),
            const SizedBox(height: 20),

            // Geographic & Activity Analytics Section
            _buildGeoAnalyticsSection(context, adminState, isDark, l10n),
            const SizedBox(height: 20),

            // Live Engagement & Session Analytics
            _buildEngagementAnalyticsSection(context, adminState.detailedAnalytics, isDark),
            const SizedBox(height: 20),

            // 1. World Travel Map Analytics (Wishlist, Visited, Lived, Continents)
            _buildWorldMapAnalyticsCard(context, adminState, isDark),
            const SizedBox(height: 20),

            // 2. Trip Data Analytics (Destinations, Dates, Budgets, Transport, Currencies)
            _buildTripAnalyticsCard(context, adminState.detailedAnalytics, isDark),
            const SizedBox(height: 20),

            // 3. User Preferences Analytics (Theme & Language Distribution)
            _buildThemeAndLanguageSection(context, adminState.detailedAnalytics, isDark),
            const SizedBox(height: 28),

            // User Management Section Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.adminUserManagement,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${adminState.filteredUsers.length} / ${adminState.allUsers.length} ${l10n.adminTotalUsers.toLowerCase()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Button to run Inactivity Scan
                BouncyPressable(
                  onTap: adminState.isActionLoading
                      ? null
                      : () => _showInactivityScanConfirmationDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.errorPastel.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.errorPastel.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_delete_rounded,
                          size: 15,
                          color: AppColors.errorPastel,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          Localizations.localeOf(context).languageCode == 'tr'
                              ? 'İnaktiflik Taraması'
                              : 'Inactivity Scan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.errorPastel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (adminState.isLoading || adminState.isActionLoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // User Filter Chips (All, Pro, Banned, Restricted)
            _buildUserFilterChips(context, adminState, l10n),
            const SizedBox(height: 12),

            // Search Bar
            AppCard(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(adminControllerProvider.notifier).setSearchQuery(val);
                },
                decoration: InputDecoration(
                  hintText: l10n.adminSearchUsers,
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  icon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(adminControllerProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User Cards List
            if (adminState.filteredUsers.isEmpty)
              _buildEmptyUsersCard(context, l10n)
            else
              ...adminState.filteredUsers.map(
                (user) => _buildUserCard(context, user, isDark, l10n),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Clutter-free metrics grid with verified counter removed
  Widget _buildMetricsGrid(
    BuildContext context,
    AdminPlatformMetrics metrics,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final avgTripsPerUser = metrics.totalUsers > 0
        ? (metrics.totalTrips / metrics.totalUsers).toStringAsFixed(1)
        : '0.0';
    final avgDocsPerUser = metrics.totalUsers > 0
        ? (metrics.totalDocuments / metrics.totalUsers).toStringAsFixed(1)
        : '0.0';

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _MetricCard(
                  title: l10n.adminTotalUsers,
                  value: metrics.totalUsers.toString(),
                  subtitle: '${metrics.totalUsers} registered',
                  icon: Icons.people_alt_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: l10n.adminProUsers,
                  value: metrics.proUsers.toString(),
                  subtitle: metrics.totalUsers > 0
                      ? '%${((metrics.proUsers / metrics.totalUsers) * 100).toStringAsFixed(1)} rate'
                      : '0%',
                  icon: Icons.workspace_premium_rounded,
                  iconColor: const Color(0xFFD97706),
                  backgroundColor: isDark
                      ? const Color(0xFF292218)
                      : const Color(0xFFFEF3C7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _MetricCard(
                  title: l10n.adminTotalTrips,
                  value: metrics.totalTrips.toString(),
                  subtitle: isTr
                      ? 'Ort. $avgTripsPerUser / kullanıcı • ${metrics.totalTrips} toplam'
                      : 'Avg $avgTripsPerUser / user • ${metrics.totalTrips} total',
                  icon: Icons.flight_takeoff_rounded,
                  iconColor: const Color(0xFF10B981),
                  backgroundColor: isDark
                      ? const Color(0xFF132E27)
                      : const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: l10n.adminTotalDocs,
                  value: metrics.totalDocuments.toString(),
                  subtitle: isTr
                      ? 'Ort. $avgDocsPerUser / kullanıcı • ${metrics.totalDocuments} toplam'
                      : 'Avg $avgDocsPerUser / user • ${metrics.totalDocuments} total',
                  icon: Icons.inventory_2_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  backgroundColor: isDark
                      ? const Color(0xFF261D38)
                      : const Color(0xFFF5F3FF),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title: l10n.adminTotalStorage,
          value: formatStorageBytes(metrics.totalStorageBytes),
          subtitle: isTr
              ? '${metrics.totalDocuments} ${l10n.adminTotalDocs.toLowerCase()} • ${metrics.totalChecklistItems} eşya'
              : '${metrics.totalDocuments} ${l10n.adminTotalDocs.toLowerCase()} • ${metrics.totalChecklistItems} items',
          icon: Icons.cloud_done_rounded,
          iconColor: const Color(0xFF0EA5E9),
          backgroundColor: isDark
              ? const Color(0xFF0C2B3E)
              : const Color(0xFFE0F2FE),
        ),
      ],
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

  /// App Theme & Language Preferences Distribution Section
  Widget _buildThemeAndLanguageSection(
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
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.palette_outlined,
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
                      isTr ? 'Kullanıcı Tercihleri (Tema ve Dil)' : 'User Preferences (Theme & Language)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                    ),
                    Text(
                      isTr
                          ? 'Kullanıcıların tema modları ve uygulama dili dağılımı'
                          : 'Distribution of theme modes and interface languages',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Theme Modes Breakdown
          Text(
            isTr ? 'Uygulama Teması Dağılımı' : 'App Theme Distribution',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (analytics.themeShares.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                isTr ? 'Tema verisi toplanıyor...' : 'Aggregating theme data...',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: analytics.themeShares.map((m) {
                final pct = (m.percentage * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(m.icon, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 150,
                        child: Text(
                          m.label,
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
                            value: m.percentage.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${m.count} (%$pct)',
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

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Language Preferences Breakdown
          Text(
            isTr ? 'Uygulama Dili Dağılımı' : 'Language Distribution',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (analytics.languageShares.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                isTr ? 'Dil verisi toplanıyor...' : 'Aggregating language data...',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: analytics.languageShares.map((m) {
                final pct = (m.percentage * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(m.icon, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 150,
                        child: Text(
                          m.label,
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
                            value: m.percentage.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${m.count} (%$pct)',
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

  /// Directory Filter Chips (All, Pro, Banned, Restricted)
  Widget _buildUserFilterChips(
    BuildContext context,
    AdminState state,
    AppLocalizations l10n,
  ) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final allCount = state.allUsers.length;
    final proCount = state.allUsers.where((u) => u.isPremium).length;
    final bannedCount = state.allUsers.where((u) => u.isCurrentlyBanned).length;
    final restrictedCount =
        state.allUsers.where((u) => u.restrictedFeatures.isNotEmpty).length;
    final inactive5thCount =
        state.allUsers.where((u) => u.is5thMonthWarningPeriod).length;
    final inactive6thCount =
        state.allUsers.where((u) => u.is6thMonthPurgeReady).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDirectoryFilterChip(
            label: '${l10n.adminFilterAll} ($allCount)',
            filter: UserFilterChip.all,
            current: state.userFilter,
          ),
          const SizedBox(width: 8),
          _buildDirectoryFilterChip(
            label: '${l10n.adminFilterPro} ($proCount)',
            filter: UserFilterChip.pro,
            current: state.userFilter,
          ),
          const SizedBox(width: 8),
          _buildDirectoryFilterChip(
            label: '${l10n.adminFilterBanned} ($bannedCount)',
            filter: UserFilterChip.banned,
            current: state.userFilter,
            badgeColor: AppColors.errorPastel,
          ),
          const SizedBox(width: 8),
          _buildDirectoryFilterChip(
            label: '${l10n.adminFilterRestricted} ($restrictedCount)',
            filter: UserFilterChip.restricted,
            current: state.userFilter,
            badgeColor: const Color(0xFF8B5CF6),
          ),
          const SizedBox(width: 8),
          _buildDirectoryFilterChip(
            label: isTr ? '5. Ay Uyarı ($inactive5thCount)' : '5th Mo Warning ($inactive5thCount)',
            filter: UserFilterChip.inactive5thMonth,
            current: state.userFilter,
            badgeColor: const Color(0xFFD97706),
          ),
          const SizedBox(width: 8),
          _buildDirectoryFilterChip(
            label: isTr ? '6+ Ay Silinecek ($inactive6thCount)' : '6+ Mo Purge ($inactive6thCount)',
            filter: UserFilterChip.inactive6thMonth,
            current: state.userFilter,
            badgeColor: AppColors.errorPastel,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryFilterChip({
    required String label,
    required UserFilterChip filter,
    required UserFilterChip current,
    Color? badgeColor,
  }) {
    final isSelected = filter == current;
    final theme = Theme.of(context);

    return BouncyPressable(
      onTap: () {
        ref.read(adminControllerProvider.notifier).setUserFilter(filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (badgeColor ?? theme.colorScheme.primary)
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

  Widget _buildEmptyUsersCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return AppCard(
      borderRadius: 22,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.adminNoUsersFound,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    AdminUserModel user,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    IconData providerIcon = Icons.email_rounded;
    if (user.provider.contains('google')) {
      providerIcon = Icons.g_mobiledata_rounded;
    } else if (user.provider.contains('apple')) {
      providerIcon = Icons.apple_rounded;
    }

    final displayName = user.displayName.isNotEmpty
        ? user.displayName
        : (user.email.isNotEmpty ? user.email.split('@').first : 'Traveler');

    final lastActiveStr =
        AppDateFormatter.formatDateTime(user.effectiveLastActiveAt);

    final flagEmoji = countryCodeToFlagEmoji(user.countryCode);
    final isBanned = user.isCurrentlyBanned;
    final isRestricted = user.restrictedFeatures.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: User Avatar/Info + Pro Status Switch
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isBanned
                      ? AppColors.errorPastel.withValues(alpha: 0.2)
                      : (user.isPremium
                          ? const Color(0xFFD97706).withValues(alpha: 0.2)
                          : theme.colorScheme.primaryContainer),
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName.substring(0, 1).toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isBanned
                          ? AppColors.errorPastel
                          : (user.isPremium
                              ? const Color(0xFFD97706)
                              : theme.colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            providerIcon,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email.isNotEmpty ? user.email : user.uid,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 13,
                            color: user.is6thMonthPurgeReady
                                ? AppColors.errorPastel
                                : (user.is5thMonthWarningPeriod
                                    ? const Color(0xFFD97706)
                                    : (user.inactiveDays <= 7
                                        ? const Color(0xFF10B981)
                                        : theme.colorScheme.onSurfaceVariant)),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              Localizations.localeOf(context).languageCode == 'tr'
                                  ? 'Son Aktif: ${AppDateFormatter.formatRelativeTime(user.effectiveLastActiveAt, locale: 'tr')} ($lastActiveStr)'
                                  : 'Last Active: ${AppDateFormatter.formatRelativeTime(user.effectiveLastActiveAt, locale: 'en')} ($lastActiveStr)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: (user.is6thMonthPurgeReady || user.is5thMonthWarningPeriod)
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: user.is6thMonthPurgeReady
                                    ? AppColors.errorPastel
                                    : (user.is5thMonthWarningPeriod
                                        ? const Color(0xFFD97706)
                                        : theme.colorScheme.onSurfaceVariant),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pro Membership Toggle Switch
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Switch.adaptive(
                      value: user.isPremium,
                      activeThumbColor: const Color(0xFFD97706),
                      activeTrackColor: const Color(0xFFD97706).withValues(alpha: 0.5),
                      onChanged: (newVal) async {
                        final success = await ref
                            .read(adminControllerProvider.notifier)
                            .toggleUserProStatus(user.uid, newVal);

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: AppColors.primaryLight,
                              content: Text(
                                '${l10n.adminProStatusUpdated}: ${newVal ? l10n.adminGrantPro : l10n.adminRevokePro} (${user.email.isNotEmpty ? user.email : user.uid})',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Metadata Badges (Country Flag + Code, Currency, Storage, Last Active, Ban, Restricted)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Country Badge
                StatusBadge(
                  label: '$flagEmoji ${user.countryCode}',
                  icon: Icons.place_outlined,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  textColor: theme.colorScheme.onSurface,
                  maxWidth: 90,
                ),

                // Currency Badge
                StatusBadge(
                  label: user.currencyCode,
                  icon: Icons.payments_outlined,
                  backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                  textColor: const Color(0xFF10B981),
                  maxWidth: 80,
                ),

                // Storage Badge
                StatusBadge(
                  label: formatStorageBytes(user.totalVaultStorageBytes),
                  icon: Icons.cloud_outlined,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEFF6FF),
                  textColor: const Color(0xFF3B82F6),
                  maxWidth: 100,
                ),

                // Pro Badge
                if (user.isPremium)
                  const StatusBadge(
                    label: 'PRO',
                    icon: Icons.star_rounded,
                    backgroundColor: Color(0x2ED97706),
                    textColor: Color(0xFFD97706),
                    maxWidth: 70,
                  ),

                // Ban Status Badge
                if (isBanned)
                  StatusBadge(
                    label: user.banStatus == 'permanent'
                        ? l10n.adminPermanentBan
                        : l10n.adminTemporaryBan,
                    icon: Icons.block_rounded,
                    backgroundColor: AppColors.errorPastel.withValues(alpha: 0.15),
                    textColor: AppColors.errorPastel,
                    maxWidth: 130,
                  ),

                // Restricted Features Badge
                if (isRestricted)
                  StatusBadge(
                    label: '${user.restrictedFeatures.length} Restricted',
                    icon: Icons.lock_clock_rounded,
                    backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    textColor: const Color(0xFF8B5CF6),
                    maxWidth: 130,
                  ),

                // Pending Deletion Badge
                if (user.deletionStatus == 'pending_deletion')
                  StatusBadge(
                    label: l10n.adminPendingDeletionBadge(user.daysUntilPermanentDeletion ?? 15),
                    icon: Icons.delete_sweep_rounded,
                    backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    textColor: const Color(0xFFD97706),
                    maxWidth: 240,
                  ),

                // 6+ Months Inactivity (Purge Ready) Badge
                if (user.is6thMonthPurgeReady)
                  StatusBadge(
                    label: Localizations.localeOf(context).languageCode == 'tr'
                        ? '6+ Ay İnaktif (${user.inactiveDays} gün)'
                        : '6+ Mo Inactive (${user.inactiveDays}d)',
                    icon: Icons.auto_delete_rounded,
                    backgroundColor: AppColors.errorPastel.withValues(alpha: 0.15),
                    textColor: AppColors.errorPastel,
                    maxWidth: 200,
                  ),

                // 5th Month Inactivity (Warning Period) Badge
                if (user.is5thMonthWarningPeriod)
                  StatusBadge(
                    label: Localizations.localeOf(context).languageCode == 'tr'
                        ? '5. Ay Uyarı (${user.inactiveDays} gün)'
                        : '5th Mo Warning (${user.inactiveDays}d)',
                    icon: Icons.mark_email_unread_rounded,
                    backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    textColor: const Color(0xFFD97706),
                    maxWidth: 200,
                  ),

                // Inactivity Warnings Count Badge
                if (user.inactivityWarningCount > 0)
                  StatusBadge(
                    label: Localizations.localeOf(context).languageCode == 'tr'
                        ? '${user.inactivityWarningCount} Uyarı Gönderildi'
                        : '${user.inactivityWarningCount} Warnings Sent',
                    icon: Icons.outgoing_mail,
                    backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                    textColor: const Color(0xFF6366F1),
                    maxWidth: 160,
                  ),

                // Last Active Date
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lastActiveStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Actions: Uyarı Gönder & Kullanıcıyı Yönet
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                BouncyPressable(
                  onTap: () => _showSendWarningBottomSheet(context, user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          size: 15,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            Localizations.localeOf(context).languageCode == 'tr'
                                ? 'Uyarı Gönder'
                                : 'Send Warning',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD97706),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BouncyPressable(
                  onTap: () => _showUserModerationSheet(context, user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 15,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l10n.adminModerateUser,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserModerationSheet(BuildContext context, AdminUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UserModerationBottomSheet(user: user),
    );
  }

  void _showSendWarningBottomSheet(BuildContext context, AdminUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SendWarningBottomSheet(user: user),
    );
  }

  void _showInactivityScanConfirmationDialog(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorPastel.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.schedule_send_rounded,
                color: AppColors.errorPastel,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isTr ? 'İnaktif Hesap İlkesi Taraması' : 'Inactivity Policy Scan',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTr
                  ? 'Bu işlem tüm kullanıcıları tarayarak şu kuralları uygular:'
                  : 'This process scans all users and applies these policies:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.mark_email_unread_rounded, size: 18, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTr
                          ? '5. Ay Uyarıları (150-179 gün):\nSon 7 gün içinde uyarı almamış inaktif kullanıcılara haftalık "Hesabınız 30 gün içinde silinecektir" e-postası gönderilir.'
                          : '5th Month Warnings (150-179 days):\nWeekly warning emails sent to users without a warning in the last 7 days.',
                      style: const TextStyle(fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorPastel.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorPastel.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.delete_forever_rounded, size: 18, color: AppColors.errorPastel),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTr
                          ? '6+ Ay Otomatik Silme (180+ gün):\nHesabına 6 aydır girmeyen kullanıcıların hesapları ve tüm verileri kalıcı olarak silinir.'
                          : '6+ Month Auto-Purge (180+ days):\nAccounts inactive for 6+ months and all cloud data will be permanently wiped.',
                      style: const TextStyle(fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorPastel,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final messenger = ScaffoldMessenger.of(context);
              final result = await ref.read(adminControllerProvider.notifier).runInactivityScan();
              if (result != null && mounted) {
                messenger.clearSnackBars();
                messenger.showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppColors.primaryLight,
                    duration: const Duration(seconds: 4),
                    content: Text(
                      isTr
                          ? 'Tarama Tamamlandı: ${result.totalScanned} taranan, ${result.warningsSent} uyarı e-postası, ${result.accountsPurged} silinen hesap.'
                          : 'Scan Complete: ${result.totalScanned} scanned, ${result.warningsSent} warnings sent, ${result.accountsPurged} accounts purged.',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: Text(isTr ? 'Taramayı Başlat' : 'Start Scan'),
          ),
        ],
      ),
    );
  }
}

/// Comprehensive User Moderation Bottom Sheet
class _UserModerationBottomSheet extends ConsumerStatefulWidget {
  final AdminUserModel user;

  const _UserModerationBottomSheet({required this.user});

  @override
  ConsumerState<_UserModerationBottomSheet> createState() =>
      _UserModerationBottomSheetState();
}

class _UserModerationBottomSheetState
    extends ConsumerState<_UserModerationBottomSheet> {
  late bool _isPro;
  late String _banStatus; // 'none', 'temporary', 'permanent'
  late String? _banExpiresAt;
  late TextEditingController _reasonController;
  late Set<String> _restrictions;
  late Future<List<VaultDocument>> _documentsFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isPro = widget.user.isPremium;
    _banStatus = widget.user.banStatus;
    _banExpiresAt = widget.user.banExpiresAt;
    _reasonController = TextEditingController(text: widget.user.banReason ?? '');
    _restrictions = Set.from(widget.user.restrictedFeatures);
    _documentsFuture = ref.read(adminServiceProvider).fetchUserDocuments(widget.user.uid);
  }

  void _reloadDocuments() {
    setState(() {
      _documentsFuture = ref.read(adminServiceProvider).fetchUserDocuments(widget.user.uid);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _setBanDuration(String type, Duration? duration) {
    setState(() {
      _banStatus = type;
      if (duration != null) {
        _banExpiresAt = DateTime.now().add(duration).toIso8601String();
      } else {
        _banExpiresAt = null;
      }
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;

    final success = await ref
        .read(adminControllerProvider.notifier)
        .updateUserModeration(
          uid: widget.user.uid,
          isPremium: _isPro,
          banStatus: _banStatus,
          banExpiresAt: _banExpiresAt,
          banReason: _reasonController.text.trim().isEmpty
              ? null
              : _reasonController.text.trim(),
          restrictedFeatures: _restrictions.toList(),
        );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.successPastel,
            content: Text(
              l10n.adminChangesSaved,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: bottomInset + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.security_rounded,
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adminModerateUser,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.user.email.isNotEmpty
                              ? widget.user.email
                              : widget.user.uid,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pending Deletion Banner & Super Admin Controls
              if (widget.user.deletionStatus == 'pending_deletion') ...[
                AppCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.adminPendingDeletionBadge(widget.user.daysUntilPermanentDeletion ?? 15),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                await ref.read(adminServiceProvider).cancelAccountDeletionAsAdmin(widget.user.uid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.adminDeletionCancelled),
                                      backgroundColor: AppColors.successPastel,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                  ref.read(adminControllerProvider.notifier).loadUsers();
                                }
                              },
                              child: Text(l10n.adminCancelDeletion),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.errorPastel,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _confirmPurgeUser(context, l10n),
                              child: Text(l10n.adminPurgeNow),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Inactivity & Auto-Deletion Status (6 Months / 5th Month Policy)
              _buildInactivityStatusCard(context),
              const SizedBox(height: 16),

              // Comprehensive User Analytics & Metrics Hub
              _buildUserAnalyticsHub(context, widget.user),
              const SizedBox(height: 16),

              // SECTION 1: Pro Membership Toggle
              AppCard(
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.adminProUsers,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _isPro ? l10n.adminGrantPro : l10n.adminRevokePro,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isPro,
                      activeThumbColor: const Color(0xFFD97706),
                      activeTrackColor: const Color(0xFFD97706).withValues(alpha: 0.5),
                      onChanged: (val) => setState(() => _isPro = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 2: Account Ban & Suspension
              Text(
                l10n.adminBanStatusLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBanChoiceChip(
                          label: l10n.adminUnbanned,
                          isSelected: _banStatus == 'none',
                          onTap: () => _setBanDuration('none', null),
                          activeColor: AppColors.successPastel,
                        ),
                        _buildBanChoiceChip(
                          label: l10n.adminBan24h,
                          isSelected: _banStatus == 'temporary' &&
                              _banExpiresAt != null &&
                              _isExpiresWithin(const Duration(hours: 25)),
                          onTap: () => _setBanDuration('temporary', const Duration(hours: 24)),
                          activeColor: AppColors.warningPastel,
                        ),
                        _buildBanChoiceChip(
                          label: l10n.adminBan7d,
                          isSelected: _banStatus == 'temporary' &&
                              _banExpiresAt != null &&
                              _isExpiresAround(7),
                          onTap: () => _setBanDuration('temporary', const Duration(days: 7)),
                          activeColor: AppColors.warningPastel,
                        ),
                        _buildBanChoiceChip(
                          label: l10n.adminBan30d,
                          isSelected: _banStatus == 'temporary' &&
                              _banExpiresAt != null &&
                              _isExpiresAround(30),
                          onTap: () => _setBanDuration('temporary', const Duration(days: 30)),
                          activeColor: AppColors.warningPastel,
                        ),
                        _buildBanChoiceChip(
                          label: l10n.adminPermanentBan,
                          isSelected: _banStatus == 'permanent',
                          onTap: () => _setBanDuration('permanent', null),
                          activeColor: AppColors.errorPastel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        labelText: l10n.adminBanReasonLabel,
                        hintText: l10n.adminBanReasonHint,
                        prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 3: Granular Feature Restrictions
              Text(
                l10n.adminFeatureRestrictionsLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildRestrictionToggle(
                      keyName: 'trip_create',
                      title: isTr ? 'Seyahat Oluşturma' : l10n.adminRestrictTripCreate,
                      subtitle: isTr ? 'Yeni gezi planı ve rota ekleme' : 'Create new trip itineraries',
                      icon: Icons.flight_takeoff_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'trip_share',
                      title: isTr ? 'Seyahat Paylaşımı & İşbirliği' : 'Trip Collaboration',
                      subtitle: isTr ? 'Gezilere arkadaş davet etme ve ortak yönetim' : 'Invite members & share trips',
                      icon: Icons.group_add_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'expense_add',
                      title: isTr ? 'Harcama & Bütçe Girişi' : l10n.adminRestrictExpenseAdd,
                      subtitle: isTr ? 'Seyahat harcaması ve bütçe kaydetme' : 'Add expenses & manage budget',
                      icon: Icons.receipt_long_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'checklist_manage',
                      title: isTr ? 'Bavul Listesi Yönetimi' : 'Packing Checklist',
                      subtitle: isTr ? 'Bavul eşyaları ekleme ve düzenleme' : 'Manage packing luggage items',
                      icon: Icons.checklist_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'vault_upload',
                      title: isTr ? 'Güvenli Kasa Dosya Yükleme' : l10n.adminRestrictVaultUpload,
                      subtitle: isTr ? 'Pasaport, bilet ve kasa belgesi yükleme' : 'Upload vault documents & tickets',
                      icon: Icons.cloud_upload_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'travel_map_edit',
                      title: isTr ? 'Dünya Haritası İşaretleme' : 'World Travel Map Editing',
                      subtitle: isTr ? 'Ülke işaretleme ve keşif hedefleri ekleme' : 'Mark countries & wishlist on map',
                      icon: Icons.public_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'cloud_sync',
                      title: isTr ? 'Bulut Senkronizasyonu' : l10n.adminRestrictCloudSync,
                      subtitle: isTr ? 'Verilerin buluta senkronize edilmesi' : 'Sync data with remote cloud',
                      icon: Icons.sync_disabled_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'ai_features',
                      title: isTr ? 'Akıllı Asistan & AI Önerileri' : 'Smart AI Suggestions',
                      subtitle: isTr ? 'Yapay zeka bavul ve gezi tavsiyeleri' : 'Smart AI luggage recommendations',
                      icon: Icons.auto_awesome_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'export_data',
                      title: isTr ? 'Rapor & Veri Dışa Aktarma' : 'Data & PDF Export',
                      subtitle: isTr ? 'PDF seyahat özeti ve veri dışa aktarımı' : 'Export PDF itineraries & records',
                      icon: Icons.file_download_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 4: Uploaded Vault Documents (Inspect / Moderate)
              Text(
                l10n.adminVaultDocumentsTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<VaultDocument>>(
                future: _documentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final docs = snapshot.data ?? [];
                  if (docs.isEmpty) {
                    return AppCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          l10n.adminNoDocumentsUploaded,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: docs.map((doc) {
                      final ext = doc.fileExtension?.toUpperCase() ?? 'DOC';
                      final isImage = ['JPG', 'JPEG', 'PNG', 'WEBP', 'GIF'].contains(ext);
                      final isPdf = ext == 'PDF';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          borderRadius: 14,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isImage ? const Color(0xFF3B82F6) : const Color(0xFFEF4444)).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isImage ? Icons.image_rounded : (isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded),
                                  size: 20,
                                  color: isImage ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.title,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${doc.category} • $ext • ${formatStorageBytes(doc.fileSize)}',
                                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _inspectDocument(context, doc, l10n),
                                child: Text(l10n.adminInspectDocument, style: const TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // SAVE BUTTON
              BouncyPressable(
                onTap: _isSaving ? null : _saveChanges,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.adminSaveChanges,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isExpiresWithin(Duration d) {
    if (_banExpiresAt == null) return false;
    final exp = DateTime.tryParse(_banExpiresAt!);
    if (exp == null) return false;
    final diff = exp.difference(DateTime.now());
    return diff.inHours > 0 && diff.inHours <= d.inHours;
  }

  bool _isExpiresAround(int days) {
    if (_banExpiresAt == null) return false;
    final exp = DateTime.tryParse(_banExpiresAt!);
    if (exp == null) return false;
    final diffDays = exp.difference(DateTime.now()).inDays;
    return (diffDays - days).abs() <= 1;
  }

  Widget _buildBanChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    final theme = Theme.of(context);
    return BouncyPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
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

  Widget _buildRestrictionToggle({
    required String keyName,
    required String title,
    String? subtitle,
    required IconData icon,
  }) {
    final isRestricted = _restrictions.contains(keyName);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: (isRestricted ? const Color(0xFF8B5CF6) : theme.colorScheme.surfaceContainerHighest)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isRestricted
                  ? const Color(0xFF8B5CF6)
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isRestricted ? FontWeight.w700 : FontWeight.w600,
                    color: isRestricted ? const Color(0xFF8B5CF6) : null,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: isRestricted,
            activeThumbColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
            onChanged: (val) {
              setState(() {
                if (val) {
                  _restrictions.add(keyName);
                } else {
                  _restrictions.remove(keyName);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  void _inspectDocument(BuildContext context, VaultDocument doc, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AdminVaultInspectDialog(
        doc: doc,
        uid: widget.user.uid,
        onDeleted: _reloadDocuments,
      ),
    );
  }

  Widget _buildInactivityStatusCard(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final user = ref.watch(adminControllerProvider).allUsers.firstWhere(
      (u) => u.uid == widget.user.uid,
      orElse: () => widget.user,
    );
    final inactiveDays = user.inactiveDays;
    final is5thMonth = user.is5thMonthWarningPeriod;
    final is6thMonth = user.is6thMonthPurgeReady;

    Color statusColor;
    String statusTitle;
    IconData statusIcon;

    if (is6thMonth) {
      statusColor = AppColors.errorPastel;
      statusTitle = isTr ? '6+ Ay İnaktif (Hesap Silinmeye Hazır)' : '6+ Months Inactive (Purge Ready)';
      statusIcon = Icons.delete_forever_rounded;
    } else if (is5thMonth) {
      statusColor = const Color(0xFFD97706);
      statusTitle = isTr ? '5. Ay Uyarı Döneminde (Haftalık E-posta)' : '5th Month Warning Period (Weekly Email)';
      statusIcon = Icons.mark_email_unread_rounded;
    } else {
      statusColor = const Color(0xFF10B981);
      statusTitle = isTr ? 'Normal / Aktif Kullanıcı' : 'Active Account';
      statusIcon = Icons.check_circle_outline_rounded;
    }

    final lastWarningStr = user.lastInactivityWarningAt != null
        ? AppDateFormatter.formatDateTime(user.lastInactivityWarningAt!)
        : (isTr ? 'Henüz gönderilmedi' : 'None sent yet');

    return AppCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'İnaktiflik ve Otomatik Silme' : 'Inactivity & Auto-Purge Policy',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _buildInfoRow(
            icon: Icons.history_rounded,
            label: isTr ? 'Son Aktiflik:' : 'Last Active:',
            value: '${AppDateFormatter.formatRelativeTime(user.effectiveLastActiveAt, locale: isTr ? 'tr' : 'en')} ($inactiveDays gün)',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: isTr ? 'Tam Tarih:' : 'Exact Date:',
            value: AppDateFormatter.formatDateTime(user.effectiveLastActiveAt),
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            icon: Icons.mail_outline_rounded,
            label: isTr ? '5. Ay Uyarıları:' : '5th Mo Warnings:',
            value: isTr
                ? '${user.inactivityWarningCount} adet gönderildi (Son: $lastWarningStr)'
                : '${user.inactivityWarningCount} sent (Last: $lastWarningStr)',
          ),
          if (is5thMonth) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
              icon: Icons.timer_outlined,
              label: isTr ? 'Kalıcı Silinmeye:' : 'Until Permanent Purge:',
              value: isTr ? '${180 - inactiveDays} gün kaldı' : '${180 - inactiveDays} days remaining',
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              // Interactive warning button
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _showSendWarningBottomSheet(context, user),
                  icon: const Icon(Icons.send_rounded, size: 14),
                  label: Text(
                    isTr ? 'Uyarı Gönder' : 'Send Warning',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              if (is6thMonth) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.errorPastel,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => _confirmPurgeUser(context, AppLocalizations.of(context)!),
                    icon: const Icon(Icons.delete_forever_rounded, size: 14),
                    label: Text(
                      isTr ? 'Şimdi Sil' : 'Purge Now',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Displays comprehensive analytics and metrics hub for this specific user
  Widget _buildUserAnalyticsHub(BuildContext context, AdminUserModel baseUser) {
    final theme = Theme.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final user = ref.watch(adminControllerProvider).allUsers.firstWhere(
      (u) => u.uid == baseUser.uid,
      orElse: () => baseUser,
    );
    final liveFlag = countryCodeToFlagEmoji(user.effectiveLiveCountryCode);

    String themeLabel;
    String themeIcon;
    switch (user.appThemeMode.toLowerCase()) {
      case 'dark':
        themeLabel = isTr ? 'Koyu Tema' : 'Dark Theme';
        themeIcon = '🌙';
        break;
      case 'light':
        themeLabel = isTr ? 'Açık Tema' : 'Light Theme';
        themeIcon = '☀️';
        break;
      default:
        themeLabel = isTr ? 'Sistem' : 'System';
        themeIcon = '⚙️';
        break;
    }

    String langLabel;
    String langFlag;
    switch (user.appLanguage.toLowerCase()) {
      case 'tr':
        langLabel = 'Türkçe';
        langFlag = '🇹🇷';
        break;
      case 'en':
        langLabel = 'English';
        langFlag = '🇬🇧';
        break;
      case 'de':
        langLabel = 'Deutsch';
        langFlag = '🇩🇪';
        break;
      case 'fr':
        langLabel = 'Français';
        langFlag = '🇫🇷';
        break;
      case 'es':
        langLabel = 'Español';
        langFlag = '🇪🇸';
        break;
      default:
        langLabel = user.appLanguage.toUpperCase();
        langFlag = '🌐';
        break;
    }

    return AppCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF0EA5E9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Kullanıcı İstatistik & Analitik Özeti' : 'User Analytics & Metrics',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    Text(
                      isTr
                          ? 'Canlı konum, oturum ve seyahat verileri'
                          : 'Live location, sessions, and travel metrics',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Canlı Konum ve Tercihler
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTr ? 'Canlı Konum' : 'Live Location',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(liveFlag, style: const TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              user.liveCity.isNotEmpty
                                  ? '${user.effectiveLiveCountryName} (${user.liveCity})'
                                  : user.effectiveLiveCountryName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTr ? 'Tercihler' : 'Preferences',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$themeIcon $themeLabel • $langFlag $langLabel',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2. Oturum & Kullanım Metrikleri
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTr ? 'Toplam Oturum' : 'Total Sessions',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${user.sessionCount} ${isTr ? "oturum" : "sessions"}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        formatDurationSeconds(user.totalSessionSeconds.toDouble()),
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTr ? 'Ortalama Süre' : 'Avg Duration',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatDurationSeconds(user.sessionCount > 0 ? (user.totalSessionSeconds / user.sessionCount) : 0.0),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${isTr ? "Son:" : "Last:"} ${formatDurationSeconds(user.lastSessionSeconds.toDouble())}',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3. Dünya Haritası İstatistikleri
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🌍', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          isTr ? 'Dünya Haritası Keşfi' : 'World Map Exploration',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text(
                      '%${user.worldExploredPercentage.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (user.worldExploredPercentage / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildUserStatBadge(isTr ? 'Gezilen' : 'Visited', '${user.visitedWorldMapCount}', const Color(0xFF10B981)),
                    _buildUserStatBadge(isTr ? 'Hedef' : 'Wishlist', '${user.wishlistWorldMapCount}', const Color(0xFF3B82F6)),
                    _buildUserStatBadge(isTr ? 'Yaşanan' : 'Lived', '${user.livedWorldMapCount}', const Color(0xFF8B5CF6)),
                    _buildUserStatBadge(isTr ? 'Kasa' : 'Vault', formatStorageBytes(user.totalVaultStorageBytes), const Color(0xFF6B7280)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmPurgeUser(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.adminPurgeConfirmTitle),
        content: Text(l10n.adminPurgeConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorPastel,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              await ref.read(adminServiceProvider).purgeUserDataAsAdmin(widget.user.uid);
              if (mounted) {
                messenger.clearSnackBars();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.adminDataPurged),
                    backgroundColor: AppColors.errorPastel,
                  ),
                );
                nav.pop();
                ref.read(adminControllerProvider.notifier).loadUsers();
              }
            },
            child: Text(l10n.adminPurgeNow),
          ),
        ],
      ),
    );
  }

  void _showSendWarningBottomSheet(BuildContext context, AdminUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SendWarningBottomSheet(user: user),
    );
  }
}

/// Admin interactive Vault Document inspection modal with PDF viewing, zoom & moderation
class _AdminVaultInspectDialog extends ConsumerStatefulWidget {
  final VaultDocument doc;
  final String uid;
  final VoidCallback onDeleted;

  const _AdminVaultInspectDialog({
    required this.doc,
    required this.uid,
    required this.onDeleted,
  });

  @override
  ConsumerState<_AdminVaultInspectDialog> createState() => _AdminVaultInspectDialogState();
}

class _AdminVaultInspectDialogState extends ConsumerState<_AdminVaultInspectDialog> {
  Uint8List? _decryptedBytes;
  bool _isLoading = true;
  String? _errorMessage;
  PdfControllerPinch? _pdfController;
  int _pdfPageCount = 0;
  int _pdfCurrentPage = 1;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadDocumentBytes();
  }

  Future<void> _loadDocumentBytes() async {
    try {
      Uint8List? rawBytes;
      if (widget.doc.cloudDataBase64 != null && widget.doc.cloudDataBase64!.isNotEmpty) {
        rawBytes = base64Decode(widget.doc.cloudDataBase64!);
      } else if (widget.doc.localImagePath.isNotEmpty) {
        final f = File(widget.doc.localImagePath);
        if (await f.exists()) {
          rawBytes = await f.readAsBytes();
        }
      }

      if (rawBytes == null || rawBytes.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Belge verisi (cloud payload) henüz cihazla eşitlenmemiş.';
          });
        }
        return;
      }

      final decrypted = await SecurityService.instance.decryptBytes(rawBytes);
      if (!mounted) return;

      setState(() {
        _decryptedBytes = decrypted;
        _isLoading = false;
      });

      final ext = widget.doc.fileExtension?.toUpperCase() ?? 'DOC';
      final isPdf = ext == 'PDF' || widget.doc.isPdf;
      if (isPdf) {
        try {
          _pdfController = PdfControllerPinch(
            document: PdfDocument.openData(decrypted),
          );
        } catch (e) {
          debugPrint('[_AdminVaultInspectDialog] PdfDocument error: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Belge çözümlenirken hata oluştu: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _openExternal() async {
    if (_decryptedBytes == null) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final ext = widget.doc.fileExtension?.toLowerCase() ?? 'pdf';
      final tempFile = File('${tempDir.path}/packbuddy_inspect_${widget.doc.id}.$ext');
      await tempFile.writeAsBytes(_decryptedBytes!);
      await OpenFilex.open(tempFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dosya açılamadı: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.adminDeleteDocument),
        content: Text(l10n.adminDeleteDocumentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorPastel,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isTr ? 'Evet, Kalıcı Olarak Sil' : 'Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isDeleting = true);
      final messenger = ScaffoldMessenger.of(context);
      final nav = Navigator.of(context);
      await ref.read(adminServiceProvider).deleteUserDocumentAsAdmin(
        uid: widget.uid,
        documentId: widget.doc.id,
      );
      widget.onDeleted();
      if (mounted) {
        nav.pop();
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.adminDocumentDeleted),
            backgroundColor: AppColors.successPastel,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final ext = widget.doc.fileExtension?.toUpperCase() ?? 'DOC';
    final isImage = ['JPG', 'JPEG', 'PNG', 'WEBP', 'GIF'].contains(ext);
    final isPdf = ext == 'PDF' || widget.doc.isPdf;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isPdf
                      ? const Color(0xFFEF4444)
                      : (isImage ? const Color(0xFF3B82F6) : theme.colorScheme.primary))
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPdf
                  ? Icons.picture_as_pdf_rounded
                  : (isImage ? Icons.image_rounded : Icons.description_rounded),
              color: isPdf
                  ? const Color(0xFFEF4444)
                  : (isImage ? const Color(0xFF3B82F6) : theme.colorScheme.primary),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doc.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.doc.category.toUpperCase()} • $ext • ${formatStorageBytes(widget.doc.fileSize)}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                Container(
                  height: 240,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(strokeWidth: 2),
                      const SizedBox(height: 12),
                      Text(
                        isTr ? 'Belge şifresi çözülüyor...' : 'Decrypting document payload...',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorPastel.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.errorPastel.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.errorPastel, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 12, color: AppColors.errorPastel),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isPdf && _pdfController != null) ...[
                // PDF Viewer Controls Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isTr
                            ? 'Sayfa $_pdfCurrentPage / $_pdfPageCount'
                            : 'Page $_pdfCurrentPage / $_pdfPageCount',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.chevron_left_rounded, size: 20),
                            onPressed: _pdfCurrentPage > 1
                                ? () => _pdfController?.previousPage(
                                      curve: Curves.ease,
                                      duration: const Duration(milliseconds: 200),
                                    )
                                : null,
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.chevron_right_rounded, size: 20),
                            onPressed: _pdfCurrentPage < _pdfPageCount
                                ? () => _pdfController?.nextPage(
                                      curve: Curves.ease,
                                      duration: const Duration(milliseconds: 200),
                                    )
                                : null,
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.open_in_new_rounded, size: 18),
                            tooltip: isTr ? 'Cihazda Aç' : 'Open External',
                            onPressed: _openExternal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Interactive Pinchable PDF Surface
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 380,
                    width: double.infinity,
                    color: Colors.black12,
                    child: PdfViewPinch(
                      controller: _pdfController!,
                      onDocumentLoaded: (doc) {
                        if (mounted) setState(() => _pdfPageCount = doc.pagesCount);
                      },
                      onPageChanged: (page) {
                        if (mounted) setState(() => _pdfCurrentPage = page);
                      },
                    ),
                  ),
                ),
              ] else if (isImage && _decryptedBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 320),
                    width: double.infinity,
                    color: Colors.black12,
                    child: InteractiveViewer(
                      maxScale: 4.0,
                      child: Image.memory(
                        _decryptedBytes!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.file_present_rounded, size: 36, color: Color(0xFF0EA5E9)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doc.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${formatStorageBytes(widget.doc.fileSize)} • $ext',
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        if (_decryptedBytes != null)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: _openExternal,
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text(isTr ? 'Tam Ekran / Cihazda Aç' : 'Open in App/Device'),
          ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.errorPastel,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: _isDeleting ? null : _confirmDelete,
          icon: _isDeleting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.delete_forever_rounded, size: 16),
          label: Text(isTr ? 'Belgeyi Sil' : 'Delete Document'),
        ),
      ],
    );
  }
}

/// Bottom sheet dialog to compose and dispatch interactive warning to a user
class _SendWarningBottomSheet extends ConsumerStatefulWidget {
  final AdminUserModel user;

  const _SendWarningBottomSheet({required this.user});

  @override
  ConsumerState<_SendWarningBottomSheet> createState() => _SendWarningBottomSheetState();
}

class _SendWarningBottomSheetState extends ConsumerState<_SendWarningBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late String _selectedType;
  bool _sendInApp = true;
  late bool _sendEmail;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _sendEmail = widget.user.email.isNotEmpty;
    _selectedType = widget.user.is5thMonthWarningPeriod || widget.user.is6thMonthPurgeReady
        ? 'inactivity'
        : 'policy_violation';
    _titleController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_titleController.text.isEmpty) {
      _applyPreset(_selectedType);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _applyPreset(String type) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    setState(() {
      _selectedType = type;
      switch (type) {
        case 'inactivity':
          final remaining = (180 - widget.user.inactiveDays).clamp(1, 30);
          _titleController.text = isTr
              ? 'Hesabınız $remaining Gün İçinde Silinecektir'
              : 'Your Account Will Be Purged in $remaining Days';
          _messageController.text = isTr
              ? 'PackBuddy hesabınıza yaklaşık 5 aydır giriş yapmadığınızı fark ettik. Veri saklama ve gizlilik politikamız gereğince 6 ay (180 gün) boyunca giriş yapılmayan hesaplar ve bu hesaplara ait seyahatler, harcamalar, bavul listeleri ve kasa belgeleri kalıcı olarak silinmektedir.\n\nHesabınızın kalıcı olarak silinmesine yaklaşık $remaining gün kaldı. Hesabınızı ve tüm verilerinizi korumak için lütfen PackBuddy mobil uygulamasına giriş yapınız.'
              : 'We noticed you have not logged into PackBuddy for 5 months. Accounts inactive for 6 months (180 days) and all cloud travel data will be permanently wiped. You have approximately $remaining days remaining. Please open the app and log in to keep your account safe.';
          break;
        case 'policy_violation':
          _titleController.text = isTr
              ? 'Kullanım Koşulları & Topluluk Uyarısı'
              : 'Community & Terms of Service Warning';
          _messageController.text = isTr
              ? 'Hesabınızın PackBuddy Kullanım Koşulları veya Topluluk Kurallarına aykırı hareket ettiği tespit edilmiştir. Lütfen kurallara uygun hareket ediniz; ihlalin devamı durumunda hesabınızdaki bazı özellikler kısıtlanabilir veya hesabınız askıya alınabilir.'
              : 'Your account was flagged for behavior inconsistent with PackBuddy Terms of Service. Please ensure platform compliance to avoid account suspension or feature restrictions.';
          break;
        case 'vault_quota':
          _titleController.text = isTr
              ? 'Güvenli Kasa Depolama Kotası Uyarısı'
              : 'Vault Storage Quota Alert';
          _messageController.text = isTr
              ? 'Güvenli Kasa depolama kullanımınız sınır limitlerine yaklaştı. Lütfen eski veya gereksiz belgelerinizi gözden geçirerek yer açınız.'
              : 'Your encrypted vault storage usage is approaching allowed limits. Please review and remove old or unnecessary documents to continue syncing files.';
          break;
        case 'suspicious_activity':
          _titleController.text = isTr
              ? 'Hesap Güvenliği & Şüpheli Giriş Bildirimi'
              : 'Security & Suspicious Login Alert';
          _messageController.text = isTr
              ? 'Hesabınızda olağandışı bir oturum aktivitesi algılandı. Eğer bu işlemi siz yapmadıysanız, lütfen şifrenizi hemen güncelleyiniz ve güvenlik adımlarınızı gözden geçiriniz.'
              : 'Unusual login activity was detected on your account. If this was not you, please update your credentials immediately.';
          break;
        case 'custom':
        default:
          _titleController.text = isTr
              ? 'PackBuddy Yönetiminden Önemli Bildirim'
              : 'Important Notice from PackBuddy';
          _messageController.text = isTr
              ? 'Sayın kullanıcımız,\n\n'
              : 'Dear traveler,\n\n';
          break;
      }
    });
  }

  Future<void> _submitWarning() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final isTr = Localizations.localeOf(context).languageCode == 'tr';

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isTr ? 'Lütfen başlık ve uyarı metnini doldurun.' : 'Please enter title and message.'),
          backgroundColor: AppColors.errorPastel,
        ),
      );
      return;
    }

    if (!_sendInApp && !_sendEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isTr ? 'En az bir gönderim kanalı seçmelisiniz.' : 'Select at least one delivery channel.'),
          backgroundColor: AppColors.errorPastel,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    final success = await ref.read(adminControllerProvider.notifier).sendUserWarning(
      uid: widget.user.uid,
      title: title,
      message: message,
      warningType: _selectedType,
      sendInAppNotification: _sendInApp,
      sendEmail: _sendEmail,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: AppColors.successPastel,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isTr
                        ? 'Uyarı başarıyla iletildi (${_sendInApp ? "Uygulama İçi" : ""}${_sendInApp && _sendEmail ? " + " : ""}${_sendEmail ? "E-posta" : ""})'
                        : 'Warning sent successfully (${_sendInApp ? "In-App" : ""}${_sendInApp && _sendEmail ? " + " : ""}${_sendEmail ? "Email" : ""})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            action: _sendEmail && widget.user.email.isNotEmpty
                ? SnackBarAction(
                    label: isTr ? 'E-postayı Aç' : 'Open Email',
                    textColor: Colors.white,
                    onPressed: () {
                      EmailDispatchService.instance.launchEmailDraft(
                        toEmail: widget.user.email,
                        subject: '⚠️ PackBuddy Bildirimi: $title',
                        body: EmailDispatchService.instance.formatWarningEmailText(
                          displayName: widget.user.displayName,
                          title: title,
                          message: message,
                        ),
                      );
                    },
                  )
                : null,
            persist: false,
          ),
        );

        // If target user is the currently logged in admin user, surface an immediate In-App Dialog
        final currentAuthUid = FirebaseAuth.instance.currentUser?.uid;
        if (currentAuthUid == widget.user.uid) {
          showDialog(
            context: context,
            builder: (dCtx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEA580C), size: 48),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Text(message, style: const TextStyle(fontSize: 14, height: 1.4)),
              ),
              actions: [
                if (_sendEmail && widget.user.email.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.email_outlined, size: 16),
                    label: Text(isTr ? 'Posta Uygulamasında Aç' : 'Open in Mail App'),
                    onPressed: () {
                      Navigator.of(dCtx).pop();
                      EmailDispatchService.instance.launchEmailDraft(
                        toEmail: widget.user.email,
                        subject: '⚠️ PackBuddy Bildirimi: $title',
                        body: EmailDispatchService.instance.formatWarningEmailText(
                          displayName: widget.user.displayName,
                          title: title,
                          message: message,
                        ),
                      );
                    },
                  ),
                FilledButton(
                  onPressed: () => Navigator.of(dCtx).pop(),
                  child: Text(isTr ? 'Anladım' : 'Got it'),
                ),
              ],
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isTr ? 'Uyarı gönderilirken bir hata oluştu.' : 'Failed to send warning.'),
            backgroundColor: AppColors.errorPastel,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final presets = [
      {'key': 'inactivity', 'label': isTr ? '⏳ 5. Ay İnaktiflik' : '⏳ Inactivity'},
      {'key': 'policy_violation', 'label': isTr ? '⚠️ Topluluk & Koşullar' : '⚠️ Policy'},
      {'key': 'vault_quota', 'label': isTr ? '📦 Kasa Depolama' : '📦 Storage'},
      {'key': 'suspicious_activity', 'label': isTr ? '🔒 Şüpheli Giriş' : '🔒 Security'},
      {'key': 'custom', 'label': isTr ? '✍️ Özel Mesaj' : '✍️ Custom'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: bottomInset + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notification_important_rounded,
                      size: 22,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTr ? 'Kullanıcıya Uyarı Gönder' : 'Send Warning to User',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.user.email.isNotEmpty ? widget.user.email : widget.user.uid,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preset Selector Chips
              Text(
                isTr ? 'Uyarı Şablonu Seçin:' : 'Select Warning Template:',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: presets.map((p) {
                    final isSelected = _selectedType == p['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(p['label']!),
                        selectedColor: const Color(0xFFD97706).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFFD97706),
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFD97706) : theme.colorScheme.onSurface,
                        ),
                        onSelected: (_) => _applyPreset(p['key']!),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Title Field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: isTr ? 'Uyarı Başlığı' : 'Warning Title',
                  prefixIcon: const Icon(Icons.title_rounded, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Message Body Field
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: isTr ? 'Uyarı Metni / Açıklama' : 'Warning Message / Details',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.description_rounded, size: 20),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),

              // Delivery Channels Card
              AppCard(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'İletim Kanalları' : 'Delivery Channels',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile.adaptive(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        isTr ? 'Uygulama İçi Bildirim' : 'In-App Notification & Push',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        isTr
                            ? 'Kullanıcının bildirimler merkezine ve anlık bildirim çubuğuna düşer'
                            : 'Appears in user notification center and banner',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      value: _sendInApp,
                      activeThumbColor: const Color(0xFFD97706),
                      activeTrackColor: const Color(0xFFD97706).withValues(alpha: 0.5),
                      onChanged: (val) => setState(() => _sendInApp = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        isTr ? 'E-posta Bildirimi' : 'Email Notification',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        widget.user.email.isNotEmpty
                            ? widget.user.email
                            : (isTr ? 'Kullanıcının e-posta adresi bulunmuyor' : 'User has no email'),
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      value: _sendEmail,
                      activeThumbColor: const Color(0xFFD97706),
                      activeTrackColor: const Color(0xFFD97706).withValues(alpha: 0.5),
                      onChanged: widget.user.email.isNotEmpty
                          ? (val) => setState(() => _sendEmail = val)
                          : null,
                    ),
                    if (widget.user.email.isNotEmpty) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          ),
                          icon: const Icon(Icons.outgoing_mail, size: 18, color: Color(0xFFD97706)),
                          label: Text(
                            isTr ? 'Posta Uygulamasında Taslağı Aç (Gmail vb.)' : 'Open Draft in Mail App',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
                          ),
                          onPressed: () {
                            final title = _titleController.text.trim();
                            final message = _messageController.text.trim();
                            EmailDispatchService.instance.launchEmailDraft(
                              toEmail: widget.user.email,
                              subject: '⚠️ PackBuddy Bildirimi: ${title.isNotEmpty ? title : "Önemli Uyarı"}',
                              body: EmailDispatchService.instance.formatWarningEmailText(
                                displayName: widget.user.displayName,
                                title: title,
                                message: message,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(isTr ? 'İptal' : 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: _isSending ? null : _submitWarning,
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        isTr ? 'Uyarıyı Gönder' : 'Send Warning',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
