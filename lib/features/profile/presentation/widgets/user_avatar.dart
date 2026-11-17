import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/profile/domain/animal_avatar.dart';
import 'package:packbuddy/features/profile/presentation/widgets/animal_avatar_widget.dart';

/// Universal Serene Voyage User Avatar Widget
/// Seamlessly renders:
/// 1) Cute animated animal avatars (avatar:animal_cat, etc.)
/// 2) Local file photos from gallery (File)
/// 3) Base64 data URI photos
/// 4) Network URLs
/// 5) Graceful fallback initial letter with radiant gradient
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? displayName;
  final String? email;
  final double size;
  final bool isAnimated;
  final bool showEditBadge;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.displayName,
    this.email,
    this.size = 80,
    this.isAnimated = true,
    this.showEditBadge = false,
    this.onTap,
    this.onEditTap,
  });

  String _getInitial() {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim()[0].toUpperCase();
    }
    if (email != null && email!.trim().isNotEmpty) {
      return email!.trim()[0].toUpperCase();
    }
    return 'P';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget avatarCore;

    final effectivePhotoUrl = (photoUrl != null && photoUrl!.trim().isNotEmpty)
        ? photoUrl!.trim()
        : PreferencesService.instance.getUserAvatar();

    final animal = AnimalAvatar.findById(effectivePhotoUrl);
    if (animal != null) {
      // 1. Animated Animal Avatar
      avatarCore = AnimalAvatarWidget(
        avatar: animal,
        size: size,
        isAnimated: isAnimated,
      );
    } else if (effectivePhotoUrl != null && effectivePhotoUrl.isNotEmpty) {
      final raw = effectivePhotoUrl;
      if (raw.startsWith('data:image')) {
        // 2. Base64 Data URI
        try {
          final commaIndex = raw.indexOf(',');
          final b64 = commaIndex != -1 ? raw.substring(commaIndex + 1) : raw;
          final bytes = base64Decode(b64);
          avatarCore = ClipOval(
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallback(theme, isDark),
            ),
          );
        } catch (_) {
          avatarCore = _buildFallback(theme, isDark);
        }
      } else if (raw.startsWith('http://') || raw.startsWith('https://')) {
        // 3. Network URL
        avatarCore = ClipOval(
          child: Image.network(
            raw,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildFallback(theme, isDark),
          ),
        );
      } else {
        // 4. Local File path
        try {
          final filePath = raw.startsWith('file://') ? raw.substring(7) : raw;
          final file = File(filePath);
          if (file.existsSync()) {
            avatarCore = ClipOval(
              child: Image.file(
                file,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(theme, isDark),
              ),
            );
          } else {
            avatarCore = _buildFallback(theme, isDark);
          }
        } catch (_) {
          avatarCore = _buildFallback(theme, isDark);
        }
      }
    } else {
      // 5. Fallback Initial Letter
      avatarCore = _buildFallback(theme, isDark);
    }

    if (!showEditBadge) {
      if (onTap != null) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: avatarCore,
        );
      }
      return avatarCore;
    }

    // With Edit Camera Badge
    final badgeSize = size * 0.32;
    return GestureDetector(
      onTap: onEditTap ?? onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        clipBehavior: Clip.none,
        children: [
          avatarCore,
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: badgeSize * 0.55,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(ThemeData theme, bool isDark) {
    final initial = _getInitial();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? [theme.colorScheme.primary, theme.colorScheme.tertiary]
              : [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.40,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
