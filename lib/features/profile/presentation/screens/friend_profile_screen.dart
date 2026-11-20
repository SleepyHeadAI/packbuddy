import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/share_trip_sheet.dart';
import 'package:packbuddy/features/profile/domain/friend_localization.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/travel_badge.dart';
import 'package:packbuddy/features/profile/domain/travel_style.dart';
import 'package:packbuddy/features/profile/presentation/controllers/friends_controller.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/world_map_profile_card.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';

/// Serene Voyage visitor mode profile screen displaying a friend's travel stats,
/// active presence status, gamified badges, and mutual travel affinity.
class FriendProfileScreen extends ConsumerStatefulWidget {
  final String friendUid;
  final FriendUserSummary fallbackSummary;

  const FriendProfileScreen({
    super.key,
    required this.friendUid,
    required this.fallbackSummary,
  });

  @override
  ConsumerState<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends ConsumerState<FriendProfileScreen> {
  late FriendUserSummary _summary;
  int _totalTrips = 0;
  int _totalCountries = 0;
  int _totalItems = 0;
  int _totalDocuments = 0;
  List<String> _friendVisitedCodes = [];
  List<TravelCountry> _friendCountries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _summary = widget.fallbackSummary;
    if (_summary.travelMapCountries != null) {
      _friendCountries = WorldMapProfileCard.parseCountriesFromRaw(_summary.travelMapCountries);
      _friendVisitedCodes = _friendCountries
          .where((c) => c.isVisited || c.isLived)
          .map((c) => c.code.toUpperCase())
          .toList();
      _totalCountries = _friendVisitedCodes.length;
    } else {
      _friendCountries = WorldCountriesData.allCountries;
    }
    _loadRemoteProfile();
  }

  Future<void> _loadRemoteProfile() async {
    if (widget.friendUid.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (Firebase.apps.isNotEmpty) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(widget.friendUid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          _summary = FriendUserSummary.fromMap(data, fallbackUid: widget.friendUid);

          // Extract visited countries map or list
          final mapRaw = data['travelMapCountries'] ?? data['countries'] ?? data['visitedCountries'];
          if (mapRaw != null) {
            _friendCountries = WorldMapProfileCard.parseCountriesFromRaw(mapRaw);
            _friendVisitedCodes = _friendCountries
                .where((c) => c.isVisited || c.isLived)
                .map((c) => c.code.toUpperCase())
                .toList();
            _totalCountries = _friendVisitedCodes.length;
          } else if (_summary.travelMapCountries != null) {
            _friendCountries = WorldMapProfileCard.parseCountriesFromRaw(_summary.travelMapCountries);
            _friendVisitedCodes = _friendCountries
                .where((c) => c.isVisited || c.isLived)
                .map((c) => c.code.toUpperCase())
                .toList();
            _totalCountries = _friendVisitedCodes.length;
          }

          // Extract metrics if stored or calculate approximations
          _totalTrips = (data['totalTrips'] as int?) ?? (_friendVisitedCodes.isNotEmpty ? _friendVisitedCodes.length : 1);
          _totalItems = (data['totalPackingItems'] as int?) ?? 35;
          _totalDocuments = (data['totalDocuments'] as int?) ?? 1;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showInviteSheet() {
    final lang = Localizations.localeOf(context).languageCode;
    final trips = ref.read(tripControllerProvider).trips.where((t) => !t.isDeleted).toList();

    if (trips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(FriendLocalization.getNoPlannedTrips(lang)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FriendLocalization.getSelectTripToInvite(lang, _summary.displayName),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: trips.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF0284C7)),
                      title: Text(trip.title.isNotEmpty ? trip.title : trip.destination, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(trip.destination),
                      trailing: const Icon(Icons.send_rounded, size: 18),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        ShareTripSheet.show(context, trip);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;

    // Calculate mutual countries
    final currentUserVisitedCodes = ref.watch(travelMapControllerProvider).countries
        .where((c) => c.isVisited || c.isLived)
        .map((c) => c.code.toUpperCase())
        .toSet();

    final mutualCodes = _friendVisitedCodes.where((code) => currentUserVisitedCodes.contains(code)).toList();

    // Badges calculation
    final badges = TravelBadge.calculateBadges(
      totalTrips: _totalTrips,
      totalCountries: _totalCountries,
      totalItems: _totalItems,
      totalDocuments: _totalDocuments,
    );
    final unlockedBadges = badges.where((b) => b.isUnlocked).toList();

    // Selected styles
    final styles = _summary.travelStyles
        .map((id) => TravelStyle.findById(id))
        .whereType<TravelStyle>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _summary.displayName?.isNotEmpty == true ? _summary.displayName! : 'Traveler Profile',
          style: theme.appBarTheme.titleTextStyle ??
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'remove') {
                _confirmRemove(context, lang);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(Icons.person_remove_rounded, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      FriendLocalization.getRemoveFriend(lang),
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _loadRemoteProfile,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Header Card (Avatar, Name, @username, Presence, Travel Status, Country)
            _buildHeaderCard(context, theme, lang),
            const SizedBox(height: 18),

            // 2. Friend World Travel Map & Exploration Status Card
            WorldMapProfileCard(
              countries: _friendCountries,
              isOwnProfile: false,
              friendName: _summary.displayName,
              mutualVisitedCodes: mutualCodes,
            ),
            const SizedBox(height: 18),

            // 3. Mutual Travel Affinity Card (Ortak Noktalar)
            _buildMutualAffinityCard(context, theme, mutualCodes, lang),
            const SizedBox(height: 18),

            // 3. Travel Statistics Bento
            _buildTravelStatsCard(context, theme, lang),
            const SizedBox(height: 18),

            // 4. Travel Personality Styles
            if (styles.isNotEmpty) ...[
              _buildStylesCard(context, theme, styles, lang),
              const SizedBox(height: 18),
            ],

            // 5. Unlocked Travel Badges
            if (unlockedBadges.isNotEmpty) ...[
              _buildBadgesCard(context, theme, unlockedBadges, lang),
              const SizedBox(height: 24),
            ],

            // 6. Action Button: Invite to Shared Trip
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showInviteSheet,
                icon: const Icon(Icons.flight_takeoff_rounded, size: 18),
                label: Text(
                  FriendLocalization.getInviteToTrip(lang),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ThemeData theme, String lang) {
    String? countryDisplay;
    if (_summary.homeCountryCode != null && _summary.homeCountryCode!.isNotEmpty) {
      final c = Country.findByCode(_summary.homeCountryCode!);
      if (c != null) {
        countryDisplay = '${c.flag} ${c.getLocalizedName(lang)}';
        if (_summary.homeCity != null && _summary.homeCity!.isNotEmpty) {
          countryDisplay = '$countryDisplay, ${_summary.homeCity}';
        }
      }
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          UserAvatar(
            photoUrl: _summary.photoUrl,
            displayName: _summary.displayName,
            size: 80,
            fallbackToDeviceUserAvatar: false,
          ),
          const SizedBox(height: 12),

          // Display Name
          Text(
            _summary.displayName?.isNotEmpty == true ? _summary.displayName! : 'Traveler',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),

          // Username Handle
          if (_summary.username != null && _summary.username!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '@${_summary.username!}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Presence Status Chip (🟢 Şu an aktif / 🟡 2 saat önce aktifti)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: Text(
              PresenceFormatter.format(_summary.lastActiveAt, lang),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Current Travel Status (🧳 Bavul topluyor)
          if (_summary.travelStatus != null && _summary.travelStatus!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                _summary.travelStatus!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],

          // Country Pill
          if (countryDisplay != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_rounded, size: 14, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    countryDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Friend Bio / About (up to 300 characters)
          if (_summary.bio != null && _summary.bio!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '"${_summary.bio!}"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  height: 1.4,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMutualAffinityCard(
    BuildContext context,
    ThemeData theme,
    List<String> mutualCodes,
    String lang,
  ) {
    final count = mutualCodes.length;

    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.handshake_rounded, size: 16, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  FriendLocalization.getTravelAffinity(lang),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (count > 0) ...[
            Text(
              FriendLocalization.getMutualCountries(lang, count),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: mutualCodes.map((code) {
                final c = Country.findByCode(code);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c?.flag ?? '🏳️', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        c?.getLocalizedName(lang) ?? code,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Text(
              FriendLocalization.getNoMutualCountries(lang),
              style: TextStyle(
                fontSize: 12.5,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTravelStatsCard(BuildContext context, ThemeData theme, String lang) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.analytics_rounded, size: 16, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Text(
                ProfileLocalization.getTravelStats(lang),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  icon: Icons.public_rounded,
                  count: '$_totalCountries',
                  label: ProfileLocalization.getCountriesVisited(lang),
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  context,
                  icon: Icons.flight_rounded,
                  count: '$_totalTrips',
                  label: ProfileLocalization.getTotalTrips(lang),
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  context,
                  icon: Icons.luggage_rounded,
                  count: '$_totalItems',
                  label: ProfileLocalization.getPackingItems(lang),
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(count, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStylesCard(BuildContext context, ThemeData theme, List<TravelStyle> styles, String lang) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.style_rounded, size: 16, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Text(
                ProfileLocalization.getTravelStyles(lang),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: styles.map((style) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(style.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      style.getLocalizedName(lang),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildBadgesCard(BuildContext context, ThemeData theme, List<TravelBadge> badges, String lang) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.military_tech_rounded, size: 16, color: Color(0xFFFFB300)),
              ),
              const SizedBox(width: 8),
              Text(
                ProfileLocalization.getBadgesAndAchievements(lang),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return Container(
                  width: 82,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badge.tier.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: badge.tier.primaryColor.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(badge.iconData, color: badge.tier.primaryColor, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        badge.getLocalizedTitle(lang),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        badge.tier.getLocalizedLabel(lang),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: badge.tier.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(FriendLocalization.getRemoveFriend(lang)),
        content: Text(
          FriendLocalization.getRemoveFriendConfirm(lang, _summary.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(FriendLocalization.getCancel(lang)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(friendsControllerProvider.notifier).removeFriend(_summary.uid);
              Navigator.of(context).pop();
            },
            child: Text(FriendLocalization.getRemoveFriend(lang)),
          ),
        ],
      ),
    );
  }
}
