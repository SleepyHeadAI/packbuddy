import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import '../../data/feedback_service.dart';
import '../../domain/feedback_localization.dart';
import '../../domain/user_feedback.dart';

/// Screen in the Executive Admin Panel displaying all submitted user suggestions and feedback
class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  List<UserFeedback> _feedbackList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    setState(() => _isLoading = true);
    final list = await FeedbackService.instance.getAllFeedback();
    if (mounted) {
      setState(() {
        _feedbackList = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Öneriyi Sil'),
        content: const Text('Bu kullanıcı önerisini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorPastel),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FeedbackService.instance.deleteFeedback(id);
      _loadFeedback();
    }
  }

  Future<void> _toggleStatus(UserFeedback item) async {
    await FeedbackService.instance.markAsReviewed(item.id);
    _loadFeedback();
  }

  void _showImageDialog(UserFeedback item) {
    Widget imageWidget;
    if (item.imageBase64 != null && item.imageBase64!.isNotEmpty) {
      imageWidget = Image.memory(base64Decode(item.imageBase64!));
    } else if (item.localImagePath != null && item.localImagePath!.isNotEmpty) {
      imageWidget = Image.file(File(item.localImagePath!));
    } else {
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(child: imageWidget),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryAmber : AppColors.primaryLight)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lightbulb_rounded,
                size: 20,
                color: isDark ? AppColors.primaryAmber : AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                FeedbackL10n.getAdminTitle(langCode),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadFeedback,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeedback,
              child: _feedbackList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 54,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              FeedbackL10n.getAdminNoFeedback(langCode),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _feedbackList.length,
                      separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _feedbackList[index];
                        final isNew = item.status == 'new';

                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isNew
                                  ? (isDark ? AppColors.primaryAmber : AppColors.primaryLight)
                                      .withValues(alpha: 0.5)
                                  : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                              width: isNew ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row: User Email & Status
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.userEmail,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${item.createdAt.day}.${item.createdAt.month}.${item.createdAt.year} ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Status Chip
                                  InkWell(
                                    onTap: () => _toggleStatus(item),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isNew
                                            ? (isDark
                                                ? AppColors.primaryAmber.withValues(alpha: 0.2)
                                                : const Color(0xFFFEF3C7))
                                            : (isDark
                                                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                                : const Color(0xFFD1FAE5)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isNew ? 'Yeni' : 'İncelendi',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: isNew
                                              ? (isDark ? AppColors.primaryAmber : const Color(0xFF92400E))
                                              : (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Delete button
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    color: AppColors.errorPastel,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _delete(item.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Message Text
                              SelectableText(
                                item.message,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),

                              // Attached Image preview
                              if ((item.imageBase64 != null && item.imageBase64!.isNotEmpty) ||
                                  (item.localImagePath != null && item.localImagePath!.isNotEmpty)) ...[
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () => _showImageDialog(item),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.image_rounded, size: 16),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Ekli Görseli Görüntüle',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.open_in_new_rounded,
                                          size: 13,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

