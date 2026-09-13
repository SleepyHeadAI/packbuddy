import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/shared/widgets/status_badge.dart';
import '../controllers/vault_controller.dart';
import 'document_viewer_screen.dart';
import 'widgets/add_document_sheet.dart';

/// Document Vault screen displaying saved passports, tickets, and reservations
class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Passport':
        return AppColors.primaryLight;
      case 'Ticket':
        return AppColors.secondaryLight;
      case 'Booking':
        return AppColors.warningPastel;
      case 'Other':
      default:
        return AppColors.tertiaryLight;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Passport':
        return Icons.badge_outlined;
      case 'Ticket':
        return Icons.confirmation_number_outlined;
      case 'Booking':
        return Icons.hotel_outlined;
      case 'Other':
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final vaultState = ref.watch(vaultControllerProvider);
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

    // Listen for errors (permission denied, disk full, etc.) and show SnackBar
    ref.listen<VaultState>(vaultControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: AppColors.errorPastel,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vault),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddDocumentSheet.show(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 3,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l10n.addDocument, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: vaultState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vaultState.documents.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            size: 44,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.noDocumentsYet,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noDocumentsSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        FilledButton.icon(
                          onPressed: () => AddDocumentSheet.show(context),
                          icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                          label: Text(l10n.addDocument),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 90),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: vaultState.documents.length,
                  itemBuilder: (context, index) {
                    final doc = vaultState.documents[index];
                    final file = File(doc.localImagePath);
                    final exists = file.existsSync();
                    final categoryColor = _getCategoryColor(doc.category);
                    final categoryIcon = _getCategoryIcon(doc.category);

                    return AppCard(
                      padding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DocumentViewerScreen(document: doc),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Thumbnail Preview
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: exists
                                  ? Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      color: categoryColor.withValues(alpha: 0.12),
                                      child: Center(
                                        child: Icon(
                                          categoryIcon,
                                          size: 36,
                                          color: categoryColor,
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          // Document Details Footer
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Pill Badge
                                StatusBadge(
                                  label: doc.category,
                                  icon: categoryIcon,
                                  backgroundColor: categoryColor.withValues(alpha: 0.15),
                                  textColor: categoryColor,
                                ),
                                const SizedBox(height: 6),

                                // Title
                                Text(
                                  doc.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),

                                // Date
                                Text(
                                  dateFormat.format(doc.createdAt),
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
                    );
                  },
                ),
    );
  }
}
