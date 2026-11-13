import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/features/budget/domain/country.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/country_picker_sheet.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';

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
  late final TextEditingController _bioController;
  String? _selectedCountryCode;
  String? _selectedCity;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _selectedCountryCode = widget.profile.homeCountryCode;
    _selectedCity = widget.profile.homeCity;
  }

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();

    setState(() {
      _isSaving = true;
    });

    final success = await ref.read(profileControllerProvider.notifier).updateProfile(
      displayName: name,
      bio: bio,
      homeCountryCode: _selectedCountryCode,
      homeCity: _selectedCity,
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

    String countryText = lang == 'tr' ? 'Ülke seçin' : 'Select country';
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
            const SizedBox(height: 16),

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

            // Bio Field
            Text(
              ProfileLocalization.getBio(lang),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 150,
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
            const SizedBox(height: 12),

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
