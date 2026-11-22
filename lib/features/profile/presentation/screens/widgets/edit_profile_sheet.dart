import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/l10n/app_l10n_lookup.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/country_picker_sheet.dart';
import 'package:packbuddy/features/profile/data/profile_service.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/travel_style.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/widgets/avatar_picker_sheet.dart';
import 'package:packbuddy/features/profile/presentation/widgets/user_avatar.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

/// Modal bottom sheet allowing users to customize their display name, bio, and home country
class EditProfileSheet extends ConsumerStatefulWidget {
  final UserProfile profile;
  final String languageCode;

  const EditProfileSheet({
    super.key,
    required this.profile,
    required this.languageCode,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfile profile,
    required String languageCode,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(
        profile: profile,
        languageCode: languageCode,
      ),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _statusController;
  late final TextEditingController _bioController;
  String? _selectedCountryCode;
  String? _selectedCity;
  late List<String> _selectedStyles;
  bool _isSaving = false;

  static List<String> _statusPresets(AppLocalizations l10n) => [
        l10n.statusPresetPacking,
        l10n.statusPresetOnTheRoad,
        l10n.statusPresetVacation,
        l10n.statusPresetPlanning,
        l10n.statusPresetResting,
      ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName ?? '');
    _usernameController = TextEditingController(text: widget.profile.username ?? '');
    _statusController = TextEditingController(text: widget.profile.travelStatus ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _selectedCountryCode = widget.profile.homeCountryCode;
    _selectedCity = widget.profile.homeCity;
    _selectedStyles = List<String>.from(widget.profile.travelStyles);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _statusController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickCountry() async {
    final result = await CountryPickerSheet.show(context);
    if (result != null) {
      setState(() {
        _selectedCountryCode = result.country.code;
        _selectedCity = result.selectedCity;
      });
    }
  }

  void _toggleStyle(String styleId) {
    setState(() {
      if (_selectedStyles.contains(styleId)) {
        _selectedStyles.remove(styleId);
      } else {
        if (_selectedStyles.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ProfileLocalization.getTravelStylesSubtitle(widget.languageCode)),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _selectedStyles.add(styleId);
      }
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final usernameRaw = _usernameController.text.trim().toLowerCase();
    final statusRaw = _statusController.text.trim();

    if (usernameRaw.isNotEmpty && !ProfileService.isValidUsername(usernameRaw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ProfileLocalization.getUsernameInvalid(widget.languageCode)),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await ref.read(profileControllerProvider.notifier).updateProfile(
      displayName: name,
      bio: bio,
      homeCountryCode: _selectedCountryCode,
      homeCity: _selectedCity,
      username: usernameRaw.isNotEmpty ? usernameRaw : null,
      clearUsername: usernameRaw.isEmpty,
      travelStatus: statusRaw.isNotEmpty ? statusRaw : null,
      clearTravelStatus: statusRaw.isEmpty,
      travelStyles: _selectedStyles,
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      Navigator.of(context).pop();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ProfileLocalization.getProfileUpdated(widget.languageCode)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = widget.languageCode;

    String countryText = ProfileLocalization.getSelectCountry(lang);
    if (_selectedCountryCode != null && _selectedCountryCode!.isNotEmpty) {
      final c = Country.findByCode(_selectedCountryCode!);
      if (c != null) {
        countryText = '${c.flag} ${c.getLocalizedName(lang)}';
        if (_selectedCity != null && _selectedCity!.isNotEmpty) {
          countryText = '$countryText, $_selectedCity';
        }
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ProfileLocalization.getEditProfile(lang),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Profile Photo & Change Button
            Center(
              child: Builder(
                builder: (context) {
                  final activeProfile =
                      ref.watch(profileControllerProvider).profile ?? widget.profile;
                  return Column(
                    children: [
                      UserAvatar(
                        photoUrl: activeProfile.photoUrl,
                        displayName: activeProfile.displayName,
                        email: activeProfile.email,
                        size: 76,
                        isAnimated: true,
                        showEditBadge: true,
                        onTap: () {
                          AvatarPickerSheet.show(
                            context,
                            profile: activeProfile,
                            languageCode: lang,
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: () {
                          AvatarPickerSheet.show(
                            context,
                            profile: activeProfile,
                            languageCode: lang,
                          );
                        },
                        icon: const Icon(Icons.photo_camera_rounded, size: 15),
                        label: Text(
                          ProfileLocalization.getChangePhoto(lang),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Display Name Field
            Text(
              ProfileLocalization.getDisplayName(lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: ProfileLocalization.getDisplayName(lang),
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainer
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Username (Buddy ID) Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ProfileLocalization.getUsername(lang),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  '@${_usernameController.text.trim().toLowerCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _usernameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: ProfileLocalization.getUsernameHint(lang),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    widthFactor: 1.0,
                    child: Text(
                      '@',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                helperText: ProfileLocalization.getUsernameHelper(lang),
                helperMaxLines: 2,
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainer
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Travel Status Field
            Text(
              ProfileLocalization.getTravelStatus(lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            // Quick status presets
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusPresets(AppLocalizations.of(context) ?? appL10nFor(lang)).map((preset) {
                  final isSelected = _statusController.text == preset;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 6),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _statusController.text = isSelected ? '' : preset;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          preset,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(
                hintText: ProfileLocalization.getTravelStatusHint(lang),
                prefixIcon: const Icon(Icons.flight_takeoff_rounded, size: 20),
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainer
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Home Country Selection
            Text(
              ProfileLocalization.getHomeCountry(lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickCountry,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainer
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.public_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        countryText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedCountryCode != null ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bio Field (About Me - 300 chars limit)
            Text(
              ProfileLocalization.getBio(lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: ProfileLocalization.getBioHint(lang),
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceContainer
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Travel Styles Multi-Select
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ProfileLocalization.getTravelStyles(lang),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                Text(
                  '${_selectedStyles.length} / 3',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _selectedStyles.length == 3 ? const Color(0xFF10B981) : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              ProfileLocalization.getTravelStylesSubtitle(lang),
              style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TravelStyle.catalog.map((style) {
                final isSelected = _selectedStyles.contains(style.id);
                return InkWell(
                  onTap: () => _toggleStyle(style.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : (isDark
                              ? theme.colorScheme.surfaceContainer
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.15),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(style.emoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          style.getLocalizedName(lang),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Save Action
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        ProfileLocalization.getSave(lang),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
