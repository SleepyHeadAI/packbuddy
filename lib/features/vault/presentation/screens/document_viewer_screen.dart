import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import '../controllers/vault_controller.dart';

/// Fullscreen zoomable document viewer screen supporting images and PDFs
class DocumentViewerScreen extends ConsumerWidget {
  final Document document;

  const DocumentViewerScreen({super.key, required this.document});

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDocument),
        content: Text(l10n.deleteDocumentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorPastel),
            onPressed: () {
              ref.read(vaultControllerProvider.notifier).deleteDocument(document.id);
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(context).pop(); // close viewer
            },
            child: Text(l10n.deleteDocument),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String cat, AppLocalizations l10n) {
    switch (cat.toLowerCase()) {
      case 'passport':
      case 'pasaport':
      case 'id & passport':
      case 'kimlik & pasaport':
        return l10n.idAndPassport;
      case 'ticket':
      case 'bilet':
      case 'tickets':
        return l10n.tickets;
      case 'booking':
      case 'rezervasyon':
      case 'hotel booking':
      case 'otel rezervasyonu':
        return l10n.accommodation;
      case 'health':
      case 'sağlık':
      case 'insurance':
      case 'sigorta':
      case 'health & insurance':
      case 'sağlık & sigorta':
        return l10n.healthAndInsurance;
      default:
        return cat;
    }
  }

  void _openFileExternally(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final file = File(document.localImagePath);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fileNotFoundLocally)),
      );
      return;
    }
    await OpenFilex.open(document.localImagePath);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final docFile = File(document.localImagePath);
    final bool fileExists = docFile.existsSync();
    final bool isPdf = document.isPdf;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              document.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_getCategoryLabel(document.category, l10n)} • ${dateFormat.format(document.createdAt)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
            tooltip: l10n.openInExternalApp,
            onPressed: () => _openFileExternally(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorPastel),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: Center(
        child: !fileExists
            ? Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.insert_drive_file_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      document.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.fileNotFoundLocally,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              )
            : isPdf
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE53935).withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 64,
                            color: Color(0xFFE53935),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          document.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.pdfBadge,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (document.notes != null && document.notes!.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              document.notes!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _openFileExternally(context),
                          icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                          label: Text(
                            l10n.openPdf,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  )
                : InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Image.file(
                      docFile,
                      fit: BoxFit.contain,
                    ),
                  ),
      ),
    );
  }
}
