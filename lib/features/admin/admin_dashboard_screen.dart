import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/bouncy_pressable.dart';
import '../vault/domain/document.dart';
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
            const SizedBox(height: 24),

            // Geographic & Activity Analytics Section
            _buildGeoAnalyticsSection(context, adminState, isDark, l10n),
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
                if (adminState.isLoading || adminState.isActionLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
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
                  subtitle: '${metrics.totalExpenses} ${l10n.adminTotalExpenses.toLowerCase()}',
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
                  subtitle: '${metrics.totalChecklistItems} ${l10n.adminTotalItems.toLowerCase()}',
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
          subtitle: '${metrics.totalDocuments} ${l10n.adminTotalDocs.toLowerCase()}',
          icon: Icons.cloud_done_rounded,
          iconColor: const Color(0xFF0EA5E9),
          backgroundColor: isDark
              ? const Color(0xFF0C2B3E)
              : const Color(0xFFE0F2FE),
        ),
      ],
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
                child: Text(
                  l10n.adminGeoAnalytics,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                              '${item.countryName} (${item.countryCode})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.primaryCurrency,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.activeUserCount} ($percentStr%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
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
                    ],
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
    final allCount = state.allUsers.length;
    final proCount = state.allUsers.where((u) => u.isPremium).length;
    final bannedCount = state.allUsers.where((u) => u.isCurrentlyBanned).length;
    final restrictedCount =
        state.allUsers.where((u) => u.restrictedFeatures.isNotEmpty).length;

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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: AppColors.primaryLight,
                              content: Text(
                                '${l10n.adminProStatusUpdated}: ${newVal ? l10n.adminGrantPro : l10n.adminRevokePro} (${user.email})',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              duration: const Duration(seconds: 2),
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

            // Manage / Moderate Button
            Align(
              alignment: Alignment.centerRight,
              child: BouncyPressable(
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
                      title: l10n.adminRestrictTripCreate,
                      icon: Icons.flight_takeoff_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'expense_add',
                      title: l10n.adminRestrictExpenseAdd,
                      icon: Icons.receipt_long_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'vault_upload',
                      title: l10n.adminRestrictVaultUpload,
                      icon: Icons.cloud_upload_rounded,
                    ),
                    const Divider(height: 1),
                    _buildRestrictionToggle(
                      keyName: 'cloud_sync',
                      title: l10n.adminRestrictCloudSync,
                      icon: Icons.sync_disabled_rounded,
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
    required IconData icon,
  }) {
    final isRestricted = _restrictions.contains(keyName);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isRestricted
                ? const Color(0xFF8B5CF6)
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isRestricted ? FontWeight.w700 : FontWeight.w500,
                color: isRestricted ? const Color(0xFF8B5CF6) : null,
              ),
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
      builder: (ctx) {
        final theme = Theme.of(context);
        final ext = doc.fileExtension?.toUpperCase() ?? 'DOC';
        final isImage = ['JPG', 'JPEG', 'PNG', 'WEBP', 'GIF'].contains(ext);
        final base64Payload = doc.cloudDataBase64;
        final hasBytes = base64Payload != null && base64Payload.isNotEmpty;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Icon(
                isImage ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  doc.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
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
                  Text(
                    '${doc.category} • $ext • ${formatStorageBytes(doc.fileSize)}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  if (hasBytes && isImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 280),
                        width: double.infinity,
                        color: Colors.black12,
                        child: InteractiveViewer(
                          maxScale: 4.0,
                          child: Image.memory(
                            base64Decode(base64Payload),
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
                    )
                  else if (hasBytes)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded, size: 36, color: Color(0xFFEF4444)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.adminDocumentTypePdf,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Base64 Cloud Payload: ${base64Payload.length} chars',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cloud payload not synced for this item (metadata only).',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.errorPastel,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _confirmDeleteDocumentAsAdmin(ctx, doc, l10n),
              icon: const Icon(Icons.delete_forever_rounded, size: 16),
              label: Text(l10n.adminDeleteDocument),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDocumentAsAdmin(BuildContext dialogContext, VaultDocument doc, AppLocalizations l10n) {
    showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.adminDeleteDocument),
        content: Text(l10n.adminDeleteDocumentConfirm),
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
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              Navigator.of(dialogContext).pop();
              await ref.read(adminServiceProvider).deleteUserDocumentAsAdmin(
                uid: widget.user.uid,
                documentId: doc.id,
              );
              _reloadDocuments();
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.adminDocumentDeleted),
                    backgroundColor: AppColors.successPastel,
                  ),
                );
              }
            },
            child: Text(l10n.adminDeleteDocument),
          ),
        ],
      ),
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
