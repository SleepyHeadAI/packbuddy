import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/bouncy_pressable.dart';
import 'admin_service.dart';
import 'admin_controller.dart';

/// Executive Admin Dashboard providing platform metrics, database overview,
/// and interactive user entitlement management.
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

            // Platform Metrics Grid
            _buildMetricsGrid(context, adminState.metrics, isDark),
            const SizedBox(height: 28),

            // User Management Section
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
                  subtitle: '${metrics.verifiedUsers} ${l10n.adminVerifiedUsers.toLowerCase()}',
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

    final lastLoginStr = user.lastLoginAt != null
        ? AppDateFormatter.formatDateTime(user.lastLoginAt!)
        : '-';

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
                  backgroundColor: user.isPremium
                      ? const Color(0xFFD97706).withValues(alpha: 0.2)
                      : theme.colorScheme.primaryContainer,
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName.substring(0, 1).toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: user.isPremium
                          ? const Color(0xFFD97706)
                          : theme.colorScheme.primary,
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

            // Bottom Badges & Meta
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Verification Badge
                if (user.emailVerified)
                  StatusBadge(
                    label: l10n.adminVerifiedUsers,
                    icon: Icons.verified_rounded,
                    backgroundColor: AppColors.successPastel.withValues(alpha: 0.15),
                    textColor: AppColors.successPastel,
                    maxWidth: 130,
                  )
                else
                  StatusBadge(
                    label: l10n.emailVerifyNotVerifiedYet,
                    icon: Icons.hourglass_top_rounded,
                    backgroundColor: AppColors.warningPastel.withValues(alpha: 0.15),
                    textColor: AppColors.warningPastel,
                    maxWidth: 130,
                  ),
                if (user.isPremium)
                  const StatusBadge(
                    label: 'PRO',
                    icon: Icons.star_rounded,
                    backgroundColor: Color(0x2ED97706),
                    textColor: Color(0xFFD97706),
                    maxWidth: 70,
                  ),
                // Storage Badge
                StatusBadge(
                  label: formatStorageBytes(user.totalVaultStorageBytes),
                  icon: Icons.cloud_outlined,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEFF6FF),
                  textColor: const Color(0xFF3B82F6),
                  maxWidth: 110,
                ),
                // Last Login Date
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
                      lastLoginStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
