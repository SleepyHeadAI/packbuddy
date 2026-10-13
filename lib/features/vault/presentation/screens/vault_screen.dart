import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import '../controllers/vault_controller.dart';
import '../../domain/document.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'document_viewer_screen.dart';
import 'widgets/add_document_sheet.dart';
import 'widgets/vault_lock_view.dart';

/// Redesigned Document Vault screen with pinned passport hero slot, trip filters, and format-specific windows
class VaultScreen extends ConsumerStatefulWidget {
  final String? initialTripId;

  const VaultScreen({super.key, this.initialTripId});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  String? _selectedTripFilter; // null = all, 'general' = unassigned, or trip.id
  String? _selectedCategoryFilter; // null = all, or category name
  String? _selectedSubCategoryFilter; // null = all, or subcategory name for Biletler

  @override
  void initState() {
    super.initState();
    _selectedTripFilter = widget.initialTripId;
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('pasaport') || cat.contains('passport') || cat.contains('kimlik') || cat.contains('vize')) {
      return const Color(0xFF1E3A8A); // Deep Royal Navy
    } else if (cat.contains('bilet') || cat.contains('ticket') || cat.contains('transit')) {
      return const Color(0xFF0284C7); // Sky Blue
    } else if (cat.contains('konaklama') || cat.contains('booking') || cat.contains('rezervasyon') || cat.contains('hotel')) {
      return const Color(0xFF059669); // Emerald
    } else if (cat.contains('sağlık') || cat.contains('sigorta') || cat.contains('insurance')) {
      return const Color(0xFFE11D48); // Rose
    } else {
      return const Color(0xFF7C3AED); // Purple
    }
  }

  IconData _getCategoryIcon(String category, [String? subCategory]) {
    if (subCategory != null) {
      final sub = subCategory.toLowerCase();
      if (sub.contains('uçak') || sub.contains('flight')) return Icons.flight_takeoff_rounded;
      if (sub.contains('otobüs') || sub.contains('bus')) return Icons.directions_bus_rounded;
      if (sub.contains('gemi') || sub.contains('feribot') || sub.contains('ferry') || sub.contains('boat')) return Icons.directions_boat_rounded;
      if (sub.contains('tren') || sub.contains('train')) return Icons.train_rounded;
    }
    final cat = category.toLowerCase();
    if (cat.contains('pasaport') || cat.contains('passport') || cat.contains('kimlik') || cat.contains('vize')) {
      return Icons.menu_book_rounded;
    } else if (cat.contains('bilet') || cat.contains('ticket') || cat.contains('transit')) {
      return Icons.confirmation_number_rounded;
    } else if (cat.contains('konaklama') || cat.contains('booking') || cat.contains('hotel') || cat.contains('rezervasyon')) {
      return Icons.hotel_rounded;
    } else if (cat.contains('sağlık') || cat.contains('sigorta') || cat.contains('insurance')) {
      return Icons.health_and_safety_rounded;
    } else {
      return Icons.folder_open_rounded;
    }
  }

  bool _matchesCategory(Document doc, String? categoryFilter) {
    if (categoryFilter == null) return true;
    final cat = doc.category.toLowerCase();
    switch (categoryFilter) {
      case 'Biletler':
        return cat == 'biletler' || cat == 'bilet' || cat == 'ticket' || cat == 'transit' || cat == 'boarding pass';
      case 'Konaklama':
        return cat == 'konaklama' || cat == 'booking' || cat == 'rezervasyon' || cat == 'hotel' || cat == 'otel';
      case 'Kimlik & Pasaport':
        return cat == 'kimlik & pasaport' || cat == 'pasaport' || cat == 'passport' || cat == 'vize' || cat == 'visa' || cat == 'vize & kimlik';
      case 'Sağlık & Sigorta':
        return cat == 'sağlık & sigorta' || cat == 'sigorta' || cat == 'insurance' || cat == 'sağlık';
      case 'Diğer Belgeler':
        return cat == 'diğer belgeler' || cat == 'diğer' || cat == 'other';
      default:
        return cat == categoryFilter.toLowerCase();
    }
  }

  bool _matchesSubCategory(Document doc, String? subCatFilter) {
    if (subCatFilter == null) return true;
    if (doc.subCategory == null) return false;
    return doc.subCategory!.toLowerCase() == subCatFilter.toLowerCase();
  }

  bool _isTransitOrTicket(String category) {
    final cat = category.toLowerCase();
    return cat == 'ticket' ||
        cat == 'bilet' ||
        cat == 'transit' ||
        cat == 'boarding pass' ||
        cat == 'biniş kartı' ||
        cat == 'booking' ||
        cat == 'rezervasyon';
  }

  void _showUndoDeleteSnackBar(BuildContext context, Document doc) {
    final l10n = AppLocalizations.of(context)!;
    final deletedMsg = '${doc.title} ${l10n.deleted}';
    final undoLabel = l10n.undo.toUpperCase();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                deletedMsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: undoLabel,
          textColor: const Color(0xFFFDE047),
          onPressed: () {
            ref.read(vaultControllerProvider.notifier).restoreDocument(doc);
          },
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Document doc) {
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
              ref.read(vaultControllerProvider.notifier).deleteDocument(doc.id);
              Navigator.of(ctx).pop();
              _showUndoDeleteSnackBar(context, doc);
            },
            child: Text(l10n.deleteDocument),
          ),
        ],
      ),
    );
  }

  void _showNativeWalletSheet(BuildContext context, Document doc) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        reverseDuration: Duration(milliseconds: 200),
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (ctx) {
        return RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.confirmation_number_rounded, color: Color(0xFF0284C7), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.boardingPassAndTransit,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          l10n.boardingPassSubtitle,
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Realistic Pass Card Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF38BDF8), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doc.title.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TRANSIT PASS',
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF334155), height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.boardingPassPassenger, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(l10n.boardingPassSampleTraveler, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(l10n.boardingPassGate, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('A14 • 12B', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Simulated barcode strip
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          28,
                          (i) => Container(
                            width: (i % 3 == 0) ? 3 : (i % 2 == 0 ? 2 : 1),
                            height: 26,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Action 1: Görüntüle
              InkWell(
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DocumentViewerScreen(document: doc)),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility_rounded, color: theme.colorScheme.onPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.viewDocumentAction,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action 2: Harici Uygulamada Aç
              InkWell(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final path = doc.localImagePath;
                  if (File(path).existsSync()) {
                    await OpenFilex.open(path);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.fileNotFoundLocally),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new_rounded, color: theme.colorScheme.onSurface, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        l10n.openInExternalApp,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final vaultState = ref.watch(vaultControllerProvider);
    final tripState = ref.watch(tripControllerProvider);
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

    // Listen for error messages cleanly
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

    // Find the latest uploaded passport document if any
    final passportDoc = vaultState.documents.cast<Document?>().firstWhere(
          (d) => d?.category.toLowerCase() == 'passport' || d?.category.toLowerCase() == 'pasaport',
          orElse: () => null,
        );

    // Filter documents based on trip selection, category, and subcategory
    final filteredDocuments = vaultState.documents.where((d) {
      if (_selectedTripFilter != null) {
        if (_selectedTripFilter == 'general') {
          if (d.tripId != null && d.tripId!.isNotEmpty) return false;
        } else if (d.tripId != _selectedTripFilter) {
          return false;
        }
      }
      if (!_matchesCategory(d, _selectedCategoryFilter)) return false;
      if (_selectedCategoryFilter == 'Biletler' && !_matchesSubCategory(d, _selectedSubCategoryFilter)) {
        return false;
      }
      return true;
    }).toList();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.vault),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (vaultState.hasPin && !vaultState.isLocked)
              IconButton(
                icon: const Icon(Icons.lock_open_rounded),
                tooltip: l10n.lockVault,
                onPressed: () {
                  ref.read(vaultControllerProvider.notifier).lockVault();
                },
              ),
            if (vaultState.isLocked)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.lock_rounded, size: 20),
              ),
          ],
        ),
        floatingActionButton: vaultState.isLocked
            ? null
            : FloatingActionButton.extended(
                heroTag: null,
                onPressed: () => AddDocumentSheet.show(
                  context,
                  initialTripId: _selectedTripFilter == 'general' ? null : _selectedTripFilter,
                ),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 3,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addDocument, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
      body: vaultState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vaultState.isLocked
              ? const VaultLockView()
              : CustomScrollView(
              slivers: [
                // Top Hero Row: Quick Vault Card (Left) & Pinned Passport Window (Right)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Vault Status Window
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 155,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.shield_outlined,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.successPastel.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        l10n.secureBadge,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.successPastel,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${vaultState.documents.length}',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      l10n.savedDocument,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  l10n.offlineAndEncrypted,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Right: Pinned Passport Window (Always on the Top Right)
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (passportDoc != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DocumentViewerScreen(document: passportDoc),
                                  ),
                                );
                              } else {
                                AddDocumentSheet.show(context, initialCategory: 'Passport');
                              }
                            },
                            child: Container(
                              height: 155,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: passportDoc != null
                                      ? [
                                          const Color(0xFF1E3A8A),
                                          const Color(0xFF172554),
                                        ]
                                      : [
                                          theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                                          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: passportDoc != null
                                      ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                                      : theme.colorScheme.outlineVariant,
                                  width: 1.5,
                                ),
                                boxShadow: passportDoc != null
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: passportDoc != null
                                              ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                              : theme.colorScheme.secondary.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.menu_book_rounded,
                                          size: 20,
                                          color: passportDoc != null
                                              ? const Color(0xFFF59E0B)
                                              : theme.colorScheme.secondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: passportDoc != null
                                              ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                                              : theme.colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          passportDoc != null ? l10n.readyBadge : l10n.pinnedBadge,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: passportDoc != null
                                                ? const Color(0xFFF59E0B)
                                                : theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        passportDoc != null ? passportDoc.title : l10n.passportSlot,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: passportDoc != null ? Colors.white : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        passportDoc != null
                                            ? dateFormat.format(passportDoc.createdAt)
                                            : l10n.saveYourPassport,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: passportDoc != null
                                              ? Colors.white.withValues(alpha: 0.8)
                                              : theme.colorScheme.primary,
                                          fontWeight: passportDoc != null ? FontWeight.normal : FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        passportDoc != null ? Icons.visibility_rounded : Icons.add_circle_outline_rounded,
                                        size: 13,
                                        color: passportDoc != null
                                            ? const Color(0xFFF59E0B)
                                            : theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        passportDoc != null ? l10n.tapToView : l10n.quickUpload,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: passportDoc != null
                                              ? Colors.white.withValues(alpha: 0.7)
                                              : theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category and Subcategory Filters Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Categories
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: Text('${l10n.allDocuments} (${vaultState.documents.length})'),
                                selected: _selectedCategoryFilter == null,
                                selectedColor: theme.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color: _selectedCategoryFilter == null
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _selectedCategoryFilter = null;
                                      _selectedSubCategoryFilter = null;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                avatar: const Icon(Icons.confirmation_number_rounded, size: 15),
                                label: Text(l10n.tickets),
                                selected: _selectedCategoryFilter == 'Biletler',
                                selectedColor: const Color(0xFF0284C7),
                                labelStyle: TextStyle(
                                  color: _selectedCategoryFilter == 'Biletler'
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                onSelected: (val) {
                                  setState(() {
                                    _selectedCategoryFilter = val ? 'Biletler' : null;
                                    _selectedSubCategoryFilter = null;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                avatar: const Icon(Icons.hotel_rounded, size: 15),
                                label: Text(l10n.accommodation),
                                selected: _selectedCategoryFilter == 'Konaklama',
                                selectedColor: const Color(0xFF059669),
                                labelStyle: TextStyle(
                                  color: _selectedCategoryFilter == 'Konaklama'
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                onSelected: (val) {
                                  setState(() {
                                    _selectedCategoryFilter = val ? 'Konaklama' : null;
                                    _selectedSubCategoryFilter = null;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                avatar: const Icon(Icons.assignment_ind_rounded, size: 15),
                                label: Text(l10n.idAndPassport),
                                selected: _selectedCategoryFilter == 'Kimlik & Pasaport',
                                selectedColor: const Color(0xFF1E3A8A),
                                labelStyle: TextStyle(
                                  color: _selectedCategoryFilter == 'Kimlik & Pasaport'
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                onSelected: (val) {
                                  setState(() {
                                    _selectedCategoryFilter = val ? 'Kimlik & Pasaport' : null;
                                    _selectedSubCategoryFilter = null;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                avatar: const Icon(Icons.health_and_safety_rounded, size: 15),
                                label: Text(l10n.healthAndInsurance),
                                selected: _selectedCategoryFilter == 'Sağlık & Sigorta',
                                selectedColor: const Color(0xFFE11D48),
                                labelStyle: TextStyle(
                                  color: _selectedCategoryFilter == 'Sağlık & Sigorta'
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                onSelected: (val) {
                                  setState(() {
                                    _selectedCategoryFilter = val ? 'Sağlık & Sigorta' : null;
                                    _selectedSubCategoryFilter = null;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                avatar: const Icon(Icons.folder_open_rounded, size: 15),
                                label: Text(l10n.otherDocuments),
                                selected: _selectedCategoryFilter == 'Diğer Belgeler',
                                selectedColor: const Color(0xFF7C3AED),
                                labelStyle: TextStyle(
                                  color: _selectedCategoryFilter == 'Diğer Belgeler'
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                onSelected: (val) {
                                  setState(() {
                                    _selectedCategoryFilter = val ? 'Diğer Belgeler' : null;
                                    _selectedSubCategoryFilter = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        // Subcategories Bar for Biletler (Uçak, Otobüs, Gemi/Feribot, Tren)
                        if (_selectedCategoryFilter == 'Biletler') ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                              ),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: Text(l10n.allTickets),
                                    selected: _selectedSubCategoryFilter == null,
                                    selectedColor: const Color(0xFF0284C7),
                                    labelStyle: TextStyle(
                                      color: _selectedSubCategoryFilter == null
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      if (val) setState(() => _selectedSubCategoryFilter = null);
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.flight_takeoff_rounded, size: 13),
                                    label: Text(l10n.flightTickets),
                                    selected: _selectedSubCategoryFilter == 'Uçak Bileti',
                                    selectedColor: const Color(0xFF0284C7),
                                    labelStyle: TextStyle(
                                      color: _selectedSubCategoryFilter == 'Uçak Bileti'
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      setState(() => _selectedSubCategoryFilter = val ? 'Uçak Bileti' : null);
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.directions_bus_rounded, size: 13),
                                    label: Text(l10n.busTickets),
                                    selected: _selectedSubCategoryFilter == 'Otobüs Bileti',
                                    selectedColor: const Color(0xFF0284C7),
                                    labelStyle: TextStyle(
                                      color: _selectedSubCategoryFilter == 'Otobüs Bileti'
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      setState(() => _selectedSubCategoryFilter = val ? 'Otobüs Bileti' : null);
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.directions_boat_rounded, size: 13),
                                    label: Text(l10n.ferryBoat),
                                    selected: _selectedSubCategoryFilter == 'Gemi / Feribot Bileti',
                                    selectedColor: const Color(0xFF0284C7),
                                    labelStyle: TextStyle(
                                      color: _selectedSubCategoryFilter == 'Gemi / Feribot Bileti'
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      setState(() => _selectedSubCategoryFilter = val ? 'Gemi / Feribot Bileti' : null);
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.train_rounded, size: 13),
                                    label: Text(l10n.trainTickets),
                                    selected: _selectedSubCategoryFilter == 'Tren Bileti',
                                    selectedColor: const Color(0xFF0284C7),
                                    labelStyle: TextStyle(
                                      color: _selectedSubCategoryFilter == 'Tren Bileti'
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      setState(() => _selectedSubCategoryFilter = val ? 'Tren Bileti' : null);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Trip Filter Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: Text(l10n.allTrips),
                                selected: _selectedTripFilter == null,
                                selectedColor: theme.colorScheme.secondaryContainer,
                                labelStyle: TextStyle(
                                  color: _selectedTripFilter == null
                                      ? theme.colorScheme.onSecondaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _selectedTripFilter = null);
                                },
                              ),
                              const SizedBox(width: 6),
                              ChoiceChip(
                                avatar: const Icon(Icons.public_rounded, size: 13),
                                label: Text(l10n.general),
                                selected: _selectedTripFilter == 'general',
                                selectedColor: theme.colorScheme.secondaryContainer,
                                labelStyle: TextStyle(
                                  color: _selectedTripFilter == 'general'
                                      ? theme.colorScheme.onSecondaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _selectedTripFilter = 'general');
                                },
                              ),
                              ...tripState.trips.map((trip) {
                                final isSelected = _selectedTripFilter == trip.id;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: ChoiceChip(
                                    avatar: const Icon(Icons.flight_takeoff_rounded, size: 13),
                                    label: Text(trip.title),
                                    selected: isSelected,
                                    selectedColor: theme.colorScheme.secondaryContainer,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? theme.colorScheme.onSecondaryContainer
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      if (val) setState(() => _selectedTripFilter = trip.id);
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Divider(height: 1),
                  ),
                ),

                // Documents Grid
                if (vaultState.documents.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
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
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () => AddDocumentSheet.show(context),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(l10n.addDocument),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (filteredDocuments.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_off_rounded,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noDocumentsForFilter,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 90),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.74,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = filteredDocuments[index];
                          final file = File(doc.localImagePath);
                          final exists = file.existsSync();
                          final categoryColor = _getCategoryColor(doc.category);
                          final categoryIcon = _getCategoryIcon(doc.category, doc.subCategory);
                          final isPdf = doc.isPdf;

                          // Find attached trip title if any
                          final attachedTrip = doc.tripId != null
                              ? tripState.trips.cast<Trip?>().firstWhere(
                                    (t) => t?.id == doc.tripId,
                                    orElse: () => null,
                                  )
                              : null;

                          final isTransit = _isTransitOrTicket(doc.category);

                          return Dismissible(
                            key: ValueKey('vault_doc_${doc.id}'),
                            direction: DismissDirection.horizontal,
                            dragStartBehavior: DragStartBehavior.down,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isTransit ? const Color(0xFF0284C7) : theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                isTransit ? Icons.wallet_rounded : Icons.visibility_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                if (isTransit) {
                                  _showNativeWalletSheet(context, doc);
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => DocumentViewerScreen(document: doc)),
                                  );
                                }
                                return false;
                              } else if (direction == DismissDirection.startToEnd) {
                                ref.read(vaultControllerProvider.notifier).deleteDocument(doc.id);
                                _showUndoDeleteSnackBar(context, doc);
                                return true;
                              }
                              return false;
                            },
                            child: AppCard(
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
                                  // Thumbnail / Document Window
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                          child: isPdf
                                              ? Container(
                                                  color: const Color(0xFFE53935).withValues(alpha: 0.1),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(14),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFE53935).withValues(alpha: 0.15),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.picture_as_pdf_rounded,
                                                          size: 36,
                                                          color: Color(0xFFE53935),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        l10n.pdfFileBadge,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFFE53935),
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : exists
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
                                                          size: 38,
                                                          color: categoryColor,
                                                        ),
                                                      ),
                                                    ),
                                        ),

                                        // PDF or Image badge
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isPdf
                                                  ? const Color(0xFFE53935)
                                                  : Colors.black.withValues(alpha: 0.6),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              isPdf ? l10n.pdfBadge : l10n.imageBadge,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Delete button icon
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: IconButton(
                                            visualDensity: VisualDensity.compact,
                                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                            color: Colors.white,
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.black.withValues(alpha: 0.4),
                                            ),
                                            onPressed: () => _showDeleteDialog(context, doc),
                                          ),
                                        ),

                                        // Native Wallet overlay badge for Transit / Ticket
                                        if (isTransit)
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: InkWell(
                                              onTap: () => _showNativeWalletSheet(context, doc),
                                              borderRadius: BorderRadius.circular(14),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.75),
                                                  borderRadius: BorderRadius.circular(14),
                                                  border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.wallet_rounded, color: Color(0xFF38BDF8), size: 12),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      l10n.addToWallet,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Document Details Footer
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Category Pill Badge
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: categoryColor.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(categoryIcon, size: 10, color: categoryColor),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        doc.category,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: categoryColor,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (isTransit) ...[
                                              const SizedBox(width: 4),
                                              IconButton(
                                                icon: const Icon(Icons.wallet_rounded, size: 16, color: Color(0xFF0284C7)),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                tooltip: l10n.boardingPassOptions,
                                                onPressed: () => _showNativeWalletSheet(context, doc),
                                              ),
                                            ],
                                            if (isPdf) ...[
                                              const SizedBox(width: 4),
                                              IconButton(
                                                icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                tooltip: l10n.openPdf,
                                                onPressed: () => OpenFilex.open(doc.localImagePath),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Title
                                        Text(
                                          doc.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),

                                        // Trip badge or Date
                                        if (attachedTrip != null) ...[
                                          Text(
                                            '✈️ ${attachedTrip.title}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ] else ...[
                                          Text(
                                            AppDateFormatter.formatYMMMd(
                                              doc.createdAt,
                                              locale: Localizations.localeOf(context).languageCode,
                                            ),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontSize: 10,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: filteredDocuments.length,
                      ),
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}
