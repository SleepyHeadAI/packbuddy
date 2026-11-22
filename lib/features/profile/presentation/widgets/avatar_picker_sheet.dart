import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_radius.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:packbuddy/features/profile/domain/animal_avatar.dart';
import 'package:packbuddy/features/profile/domain/profile_localization.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/features/profile/presentation/widgets/animal_avatar_widget.dart';

/// Serene Voyage Modal Bottom Sheet allowing users to:
/// 1) Pick custom photo from phone gallery
/// 2) Choose from 20 cute animated animal avatars
/// 3) Remove existing photo and revert to initials
class AvatarPickerSheet extends ConsumerStatefulWidget {
  final UserProfile profile;
  final String languageCode;

  const AvatarPickerSheet({
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
      builder: (_) => AvatarPickerSheet(
        profile: profile,
        languageCode: languageCode,
      ),
    );
  }

  @override
  ConsumerState<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends ConsumerState<AvatarPickerSheet> {
  AnimalCategory _selectedCategory = AnimalCategory.all;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  List<AnimalAvatar> get _filteredAnimals =>
      AnimalAvatar.getByCategory(_selectedCategory);

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);
    try {
      AppHaptics.light();
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 82,
      );

      if (pickedFile == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      String savedPathOrData;
      if (!kIsWeb) {
        final appDir = await getApplicationDocumentsDirectory();
        final avatarDir = Directory(p.join(appDir.path, 'packbuddy_avatars'));
        if (!avatarDir.existsSync()) {
          avatarDir.createSync(recursive: true);
        }

        final fileName = 'avatar_${widget.profile.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedFile = File(p.join(avatarDir.path, fileName));
        await File(pickedFile.path).copy(savedFile.path);

        // Also check if we can convert to base64 for seamless cloud sync
        final bytes = await savedFile.readAsBytes();
        if (bytes.lengthInBytes < 600 * 1024) {
          // Under 600KB: store as base64 data URI so it syncs across cloud/firestore effortlessly
          final base64String = base64Encode(bytes);
          savedPathOrData = 'data:image/jpeg;base64,$base64String';
        } else {
          savedPathOrData = savedFile.path;
        }
      } else {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        savedPathOrData = 'data:image/jpeg;base64,$base64String';
      }

      final success = await ref
          .read(profileControllerProvider.notifier)
          .updatePhotoUrl(savedPathOrData);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ProfileLocalization.getPhotoUpdated(widget.languageCode)),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorGenericRetry),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectAnimal(AnimalAvatar animal) async {
    AppHaptics.medium();
    setState(() => _isLoading = true);
    final uri = AnimalAvatar.toUri(animal.id);
    final success = await ref
        .read(profileControllerProvider.notifier)
        .updatePhotoUrl(uri);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(animal.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${animal.getName(widget.languageCode)} - ${ProfileLocalization.getPhotoUpdated(widget.languageCode)}',
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    AppHaptics.light();
    setState(() => _isLoading = true);
    final success = await ref
        .read(profileControllerProvider.notifier)
        .updatePhotoUrl(null, clearPhoto: true);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ProfileLocalization.getPhotoUpdated(widget.languageCode)),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final mediaQuery = MediaQuery.of(context);
    final currentPhoto = widget.profile.photoUrl;

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: mediaQuery.padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: AppRadius.sheetRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 40,
              height: 4.5,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.face_retouching_natural_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ProfileLocalization.getSelectAvatar(lang),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
          const SizedBox(height: 14),

          // Quick Action Cards: Gallery & Remove
          Row(
            children: [
              // 1. Pick from Gallery Button
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: _isLoading ? null : _pickFromGallery,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                              ]
                            : [
                                theme.colorScheme.primary.withValues(alpha: 0.12),
                                theme.colorScheme.primary.withValues(alpha: 0.05),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            ProfileLocalization.getChooseFromGallery(lang),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
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

              // 2. Remove Photo Button (if set)
              if (currentPhoto != null && currentPhoto.isNotEmpty) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: _isLoading ? null : _removePhoto,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.errorContainer.withValues(alpha: 0.4)
                          : theme.colorScheme.errorContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Tooltip(
                      message: ProfileLocalization.getRemovePhoto(lang),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Section Title & 20 Cute Animals Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ProfileLocalization.getCuteAnimalAvatars(lang),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '20 ✨',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(
                  label: '${ProfileLocalization.getAll(lang)} (${AnimalAvatar.all.length})',
                  category: AnimalCategory.all,
                  theme: theme,
                ),
                const SizedBox(width: 6),
                _buildCategoryChip(
                  label: '${ProfileLocalization.getPets(lang)} (${AnimalAvatar.getByCategory(AnimalCategory.pets).length})',
                  category: AnimalCategory.pets,
                  theme: theme,
                ),
                const SizedBox(width: 6),
                _buildCategoryChip(
                  label: '${ProfileLocalization.getForest(lang)} (${AnimalAvatar.getByCategory(AnimalCategory.forest).length})',
                  category: AnimalCategory.forest,
                  theme: theme,
                ),
                const SizedBox(width: 6),
                _buildCategoryChip(
                  label: '${ProfileLocalization.getWild(lang)} (${AnimalAvatar.getByCategory(AnimalCategory.wild).length})',
                  category: AnimalCategory.wild,
                  theme: theme,
                ),
                const SizedBox(width: 6),
                _buildCategoryChip(
                  label: '${ProfileLocalization.getSpecial(lang)} (${AnimalAvatar.getByCategory(AnimalCategory.special).length})',
                  category: AnimalCategory.special,
                  theme: theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Grid of 20 Animals
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width < 330 ? 3 : (width > 600 ? 5 : 4);
                      final avatarSize = (width / crossAxisCount * 0.52).clamp(36.0, 52.0);

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.74,
                        ),
                        itemCount: _filteredAnimals.length,
                        itemBuilder: (context, index) {
                          final animal = _filteredAnimals[index];
                          final isSelected = currentPhoto != null &&
                              (currentPhoto == animal.id ||
                                  currentPhoto == AnimalAvatar.toUri(animal.id));

                          return InkWell(
                            onTap: () => _selectAnimal(animal),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? theme.colorScheme.surfaceContainer
                                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(alpha: 0.05)),
                                  width: isSelected ? 2.5 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.28),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Stack with Avatar + Selection Checkmark
                                  Stack(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    children: [
                                      AnimalAvatarWidget(
                                        avatar: animal,
                                        size: avatarSize,
                                        isAnimated: true,
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.all(2.5),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            size: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Animal Name with FittedBox to prevent any wrapping or overflow
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      animal.getName(lang),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required AnimalCategory category,
    required ThemeData theme,
  }) {
    final isSelected = _selectedCategory == category;
    return InkWell(
      onTap: () {
        AppHaptics.selection();
        setState(() => _selectedCategory = category);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
