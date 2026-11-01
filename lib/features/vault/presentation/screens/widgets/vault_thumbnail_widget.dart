import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:packbuddy/core/services/security_service.dart';
import 'package:packbuddy/features/vault/domain/document.dart';

/// In-memory LRU-like cache for decrypted vault thumbnails and rendered PDF first-page previews
class _VaultThumbnailCache {
  static final Map<String, Uint8List> _memoryCache = {};
  static const int _maxEntries = 120;

  static Uint8List? get(String key) => _memoryCache[key];

  static void set(String key, Uint8List bytes) {
    if (_memoryCache.length >= _maxEntries) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[key] = bytes;
  }
}

/// Secure, high-performance thumbnail renderer for vault documents.
/// Automatically handles:
/// 1. At-rest AES-256 decryption of picked images in memory (fixing "Invalid image data").
/// 2. First-page preview rendering of PDF documents (replacing plain "PDF DOSYASI" placeholder).
/// 3. Memory caching for jank-free 120 FPS scrolling.
/// 4. Graceful fallbacks for missing/corrupted files.
class VaultThumbnailWidget extends StatefulWidget {
  final Document document;
  final Color categoryColor;
  final IconData categoryIcon;
  final BoxFit fit;

  const VaultThumbnailWidget({
    super.key,
    required this.document,
    required this.categoryColor,
    required this.categoryIcon,
    this.fit = BoxFit.cover,
  });

  @override
  State<VaultThumbnailWidget> createState() => _VaultThumbnailWidgetState();
}

class _VaultThumbnailWidgetState extends State<VaultThumbnailWidget> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  bool _hasError = false;

  String get _cacheKey => '${widget.document.id}_${widget.document.updatedAt.millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant VaultThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id ||
        oldWidget.document.updatedAt != widget.document.updatedAt ||
        oldWidget.document.localImagePath != widget.document.localImagePath) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    final cached = _VaultThumbnailCache.get(_cacheKey);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _thumbnailBytes = cached;
          _isLoading = false;
          _hasError = false;
        });
      }
      return;
    }

    final file = File(widget.document.localImagePath);
    if (!file.existsSync()) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      return;
    }

    try {
      final rawBytes = await file.readAsBytes();
      final decrypted = await SecurityService.instance.decryptBytes(rawBytes);

      if (widget.document.isPdf) {
        // Render first page of PDF document as thumbnail
        Uint8List? renderedPdfBytes;
        try {
          final pdfDoc = await PdfDocument.openData(decrypted);
          final page = await pdfDoc.getPage(1);
          final pageImage = await page.render(
            width: (page.width * 1.5).clamp(200.0, 600.0),
            height: (page.height * 1.5).clamp(280.0, 800.0),
            format: PdfPageImageFormat.jpeg,
          );
          renderedPdfBytes = pageImage?.bytes;
          await page.close();
          await pdfDoc.close();
        } catch (e) {
          debugPrint('[VaultThumbnailWidget] PDF page render notice: $e');
        }

        if (renderedPdfBytes != null) {
          _VaultThumbnailCache.set(_cacheKey, renderedPdfBytes);
          if (mounted) {
            setState(() {
              _thumbnailBytes = renderedPdfBytes;
              _isLoading = false;
              _hasError = false;
            });
          }
          return;
        } else {
          // If native PDF rendering is unavailable, mark as fallback
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          }
          return;
        }
      } else {
        // Standard Image document
        _VaultThumbnailCache.set(_cacheKey, decrypted);
        if (mounted) {
          setState(() {
            _thumbnailBytes = decrypted;
            _isLoading = false;
            _hasError = false;
          });
        }
      }
    } catch (e) {
      debugPrint('[VaultThumbnailWidget] Load error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Widget _buildFallback(BuildContext context) {
    final isPdf = widget.document.isPdf;

    if (isPdf) {
      // Stylized, elegant PDF Document Cover card
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFDC2626).withValues(alpha: 0.16),
              const Color(0xFFB91C1C).withValues(alpha: 0.06),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 28,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PDF BELGESİ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: widget.categoryColor.withValues(alpha: 0.12),
      child: Center(
        child: Icon(
          widget.categoryIcon,
          size: 38,
          color: widget.categoryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: widget.categoryColor.withValues(alpha: 0.08),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.categoryColor),
            ),
          ),
        ),
      );
    }

    if (_hasError || _thumbnailBytes == null) {
      return _buildFallback(context);
    }

    return Image.memory(
      _thumbnailBytes!,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback(context);
      },
    );
  }
}
