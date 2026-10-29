import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/services/security_service.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import '../controllers/vault_controller.dart';

/// Fullscreen zoomable document viewer screen supporting images and full in-app PDF viewing with FLAG_SECURE protection
class DocumentViewerScreen extends ConsumerStatefulWidget {
  final Document document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  PdfControllerPinch? _pdfController;
  int _pdfPagesCount = 0;
  int _pdfCurrentPage = 1;
  bool _pdfError = false;
  String? _pdfErrorMessage;

  @override
  void initState() {
    super.initState();
    SecurityService.instance.enableSecureScreen();

    if (widget.document.isPdf) {
      final file = File(widget.document.localImagePath);
      if (file.existsSync()) {
        try {
          _pdfController = PdfControllerPinch(
            document: PdfDocument.openFile(widget.document.localImagePath),
          );
        } catch (e) {
          _pdfError = true;
          _pdfErrorMessage = e.toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    SecurityService.instance.disableSecureScreen();
    super.dispose();
  }

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
              ref.read(vaultControllerProvider.notifier).deleteDocument(widget.document.id);
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
    final file = File(widget.document.localImagePath);
    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fileNotFoundLocally)),
      );
      return;
    }
    await OpenFilex.open(widget.document.localImagePath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final docFile = File(widget.document.localImagePath);
    final bool fileExists = docFile.existsSync();
    final bool isPdf = widget.document.isPdf;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.document.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_getCategoryLabel(widget.document.category, l10n)} • ${dateFormat.format(widget.document.createdAt)}',
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
            tooltip: l10n.deleteDocument,
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
                      widget.document.title,
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
                ? _buildPdfViewer(context, l10n)
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

  Widget _buildPdfViewer(BuildContext context, AppLocalizations l10n) {
    if (_pdfError || _pdfController == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 54, color: Color(0xFFE53935)),
            ),
            const SizedBox(height: 16),
            Text(
              widget.document.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _pdfErrorMessage ?? l10n.fileNotFoundLocally,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
              onPressed: () => _openFileExternally(context),
              icon: const Icon(Icons.open_in_browser_rounded),
              label: Text(l10n.openInExternalApp),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: PdfViewPinch(
            controller: _pdfController!,
            onDocumentLoaded: (document) {
              if (mounted) {
                setState(() {
                  _pdfPagesCount = document.pagesCount;
                });
              }
            },
            onPageChanged: (page) {
              if (mounted) {
                setState(() {
                  _pdfCurrentPage = page;
                });
              }
            },
            builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (_) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              pageLoaderBuilder: (_) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorBuilder: (_, error) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image_rounded, color: Color(0xFFE53935), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      '${l10n.pdfError}: $error',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _openFileExternally(context),
                      child: Text(l10n.openInExternalApp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Floating Page Counter & Controls
        if (_pdfPagesCount > 0)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_pdfPagesCount > 1) ...[
                      InkWell(
                        onTap: _pdfCurrentPage > 1
                            ? () => _pdfController?.previousPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                )
                            : null,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: _pdfCurrentPage > 1 ? Colors.white : Colors.white38,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '$_pdfCurrentPage / $_pdfPagesCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (_pdfPagesCount > 1) ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _pdfCurrentPage < _pdfPagesCount
                            ? () => _pdfController?.nextPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                )
                            : null,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: _pdfCurrentPage < _pdfPagesCount ? Colors.white : Colors.white38,
                          size: 22,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
