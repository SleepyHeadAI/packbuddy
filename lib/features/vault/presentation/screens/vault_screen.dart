import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_localization.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import '../controllers/vault_controller.dart';
import '../../domain/document.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'document_viewer_screen.dart';
import 'widgets/add_document_sheet.dart';
import 'widgets/vault_lock_view.dart';
import 'widgets/vault_pin_recovery_sheet.dart';
import 'widgets/vault_thumbnail_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:flutter/services.dart';
import 'package:packbuddy/core/services/biometric_service.dart';
import '../../../../core/services/security_service.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';

/// Redesigned Document Vault screen with pinned passport hero slot, trip filters, and format-specific windows
class VaultScreen extends ConsumerStatefulWidget {
  final String? initialTripId;
  final bool isTabMode;

  const VaultScreen({
    super.key,
    this.initialTripId,
    this.isTabMode = false,
  });

  static String getCategoryLabel(String cat, AppLocalizations l10n) {
    switch (cat.toLowerCase()) {
      case 'passport':
      case 'pasaport':
      case 'id & passport':
      case 'kimlik & pasaport':
        return l10n.idAndPassport;
      case 'ticket':
      case 'bilet':
      case 'tickets':
      case 'biletler':
        return l10n.tickets;
      case 'booking':
      case 'rezervasyon':
      case 'hotel booking':
      case 'otel rezervasyonu':
      case 'konaklama':
      case 'accommodation':
        return l10n.accommodation;
      case 'health':
      case 'sağlık':
      case 'insurance':
      case 'sigorta':
      case 'health & insurance':
      case 'sağlık & sigorta':
        return l10n.healthAndInsurance;
      case 'privatephotos':
      case 'private photos':
      case 'özel resimler':
      case 'özel resim':
      case 'özel fotoğraflar':
      case 'özel':
        return l10n.privatePhotos;
      case 'other':
      case 'diğer':
      case 'other documents':
      case 'diğer belgeler':
        return l10n.otherDocuments;
      default:
        return cat;
    }
  }

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> with WidgetsBindingObserver {
  String? _selectedTripFilter; // null = all, or trip.id
  String? _selectedCategoryFilter; // null = all, or category name
  String? _selectedSubCategoryFilter; // null = all, or subcategory name for Biletler
  bool _isPrivatePhotosUnlocked = false;

  bool _isPrivate(Document d) => d.isPrivate;

  bool get _isTabActive {
    if (!widget.isTabMode) return true;
    return ref.watch(mainNavigationIndexProvider) == 3;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedTripFilter = widget.initialTripId;

    // Enforce biometric/PIN authentication when vault tab is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.isTabMode || ref.read(mainNavigationIndexProvider) == 3) {
        final vaultState = ref.read(vaultControllerProvider);
        if (vaultState.hasPin && !vaultState.isLocked) {
          ref.read(vaultControllerProvider.notifier).lockVault();
        }
      }
    });
  }

  @override
  void deactivate() {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    _isPrivatePhotosUnlocked = false;
    if (_selectedCategoryFilter == 'Özel Resimler') {
      _selectedCategoryFilter = null;
    }
    // Lock vault when screen is deactivated / popped (deferred to avoid mutating during element deactivation)
    Future.microtask(() {
      try {
        final vaultState = ref.read(vaultControllerProvider);
        if (vaultState.hasPin && !vaultState.isLocked) {
          ref.read(vaultControllerProvider.notifier).lockVault();
        }
      } catch (_) {}
    });
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    // If system biometric prompt is actively presented, Android transitions to inactive.
    // We MUST NOT lock the vault or abort private safe while the biometric prompt is visible!
    if (BiometricService.instance.isAuthenticating) {
      return;
    }

    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.hidden) {
      // Immediately lock vault whenever app is backgrounded or minimized
      _isPrivatePhotosUnlocked = false;
      if (_selectedCategoryFilter == 'Özel Resimler') {
        _selectedCategoryFilter = null;
      }
      final vaultState = ref.read(vaultControllerProvider);
      if (vaultState.hasPin && !vaultState.isLocked) {
        ref.read(vaultControllerProvider.notifier).lockVault();
      }
    }
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('özel') || cat.contains('private')) {
      return const Color(0xFFE11D48); // Rose / Crimson
    } else if (cat.contains('pasaport') || cat.contains('passport') || cat.contains('kimlik') || cat.contains('vize')) {
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
    if (cat.contains('özel') || cat.contains('private')) {
      return Icons.lock_person_rounded;
    } else if (cat.contains('pasaport') || cat.contains('passport') || cat.contains('kimlik') || cat.contains('vize')) {
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
    final isDocPrivate = _isPrivate(doc);
    if (categoryFilter == null) {
      // Main Safe Page: strictly hide all private photos from the default view
      return !isDocPrivate;
    }
    if (categoryFilter == 'Özel Resimler') {
      return isDocPrivate;
    }
    // Any other category: strictly hide private photos
    if (isDocPrivate) return false;

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

  String _normalizeSubCategoryKey(String key) {
    final k = key.toLowerCase();
    if (k.contains('uçak') || k.contains('flight') || k.contains('flughafen') || k.contains('avion')) {
      return 'flightTicket';
    }
    if (k.contains('otobüs') || k.contains('bus')) {
      return 'busTicket';
    }
    if (k.contains('gemi') || k.contains('feribot') || k.contains('ferry') || k.contains('boat') || k.contains('bateau')) {
      return 'ferryTicket';
    }
    if (k.contains('tren') || k.contains('train') || k.contains('bahn')) {
      return 'trainTicket';
    }
    return key;
  }

  bool _matchesSubCategory(Document doc, String? subCatFilter) {
    if (subCatFilter == null) return true;
    if (doc.subCategory == null) return false;
    final docNorm = _normalizeSubCategoryKey(doc.subCategory!);
    final filterNorm = _normalizeSubCategoryKey(subCatFilter);
    return docNorm.toLowerCase() == filterNorm.toLowerCase();
  }


  void _openPdfSafely(BuildContext context, Document doc) async {
    final file = File(doc.localImagePath);
    if (!file.existsSync()) {
      // If local file is missing, open DocumentViewerScreen which auto-fetches from cloud/chunks
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DocumentViewerScreen(document: doc)),
        );
      }
      return;
    }
    try {
      final rawBytes = await file.readAsBytes();
      if (SecurityService.instance.isEncrypted(rawBytes)) {
        final decryptedBytes = await SecurityService.instance.decryptBytes(rawBytes, userId: doc.userId);
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/pb_vault_preview_${doc.id}.pdf');
        await tempFile.writeAsBytes(decryptedBytes);
        await OpenFilex.open(tempFile.path);
      } else {
        await OpenFilex.open(doc.localImagePath);
      }
    } catch (_) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DocumentViewerScreen(document: doc)),
        );
      }
    }
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
        persist: false,
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

  void _showSetPinDialog() {
    final l10n = AppLocalizations.of(context)!;
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.setVaultPin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.setPinDescription,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.fourDigitPin,
                prefixIcon: const Icon(Icons.pin_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                await ref.read(vaultControllerProvider.notifier).setPin(pin);
                if (await BiometricService.instance.isBiometricsAvailable()) {
                  await ref.read(vaultControllerProvider.notifier).setBiometricEnabled(true);
                }
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(l10n.pinProtectionActive)),
                        ],
                      ),
                      backgroundColor: AppColors.successPastel,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            child: Text(l10n.saveAndOpen),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockPrivatePhotos() async {
    final vaultState = ref.read(vaultControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    if (!vaultState.hasPin) {
      _showSetPinForPrivatePhotosPrompt();
      return;
    }

    final biometricsAvailable = await BiometricService.instance.isBiometricsAvailable();
    if (biometricsAvailable && vaultState.isBiometricEnabled) {
      final authenticated = await BiometricService.instance.authenticate(
        localizedReason: l10n.privatePhotosReason,
      );
      if (authenticated && mounted) {
        setState(() {
          _isPrivatePhotosUnlocked = true;
          _selectedCategoryFilter = 'Özel Resimler';
          _selectedSubCategoryFilter = null;
        });
        return;
      }
    }

    if (mounted) {
      _showVerifyPinSheetForPrivatePhotos();
    }
  }

  void _showSetPinForPrivatePhotosPrompt() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Color(0xFFE11D48)),
            const SizedBox(width: 8),
            Text(l10n.privatePhotos),
          ],
        ),
        content: Text(l10n.setPinFirstForPrivatePhotos),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showSetPinDialog();
            },
            child: Text(l10n.setup),
          ),
        ],
      ),
    );
  }

  void _showVerifyPinSheetForPrivatePhotos() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PrivatePhotosPinSheet(
        onSuccess: () {
          if (mounted) {
            setState(() {
              _isPrivatePhotosUnlocked = true;
              _selectedCategoryFilter = 'Özel Resimler';
              _selectedSubCategoryFilter = null;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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

    // Enforce biometric/PIN re-auth whenever user leaves or returns to Vault tab
    ref.listen<int>(mainNavigationIndexProvider, (previous, next) {
      if (previous == 3 && next != 3) {
        // Leaving Vault tab -> lock immediately and relock private photos
        _isPrivatePhotosUnlocked = false;
        if (_selectedCategoryFilter == 'Özel Resimler') {
          Future.microtask(() {
            if (mounted) setState(() => _selectedCategoryFilter = null);
          });
        }
        ref.read(vaultControllerProvider.notifier).lockVault();
      } else if (next == 3 && previous != 3) {
        // Entering Vault tab -> lock to enforce re-auth
        _isPrivatePhotosUnlocked = false;
        if (_selectedCategoryFilter == 'Özel Resimler') {
          Future.microtask(() {
            if (mounted) setState(() => _selectedCategoryFilter = null);
          });
        }
        ref.read(vaultControllerProvider.notifier).lockVault();
      }
    });

    final publicDocsCount = vaultState.documents.where((d) => !_isPrivate(d)).length;
    final privateDocsCount = vaultState.documents.where((d) => _isPrivate(d)).length;

    // Find the latest uploaded passport document if any (must NOT be a private photo)
    final passportDoc = vaultState.documents.cast<Document?>().firstWhere(
          (d) => d != null && !_isPrivate(d) && (d.category.toLowerCase() == 'passport' || d.category.toLowerCase() == 'pasaport'),
          orElse: () => null,
        );

    // Filter documents based on trip selection, category, and subcategory
    final filteredDocuments = vaultState.documents.where((d) {
      if (_selectedTripFilter != null && d.tripId != _selectedTripFilter) {
        return false;
      }
      if (!_matchesCategory(d, _selectedCategoryFilter)) return false;
      if (_selectedCategoryFilter == 'Biletler' && !_matchesSubCategory(d, _selectedSubCategoryFilter)) {
        return false;
      }
      return true;
    }).toList();

    // If hosted inside navigation shell and not the active tab, render a lightweight shell
    // to strictly prevent background biometric prompts and unnecessary heavy renders
    if (!_isTabActive) {
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedCategoryFilter == 'Özel Resimler') {
          setState(() {
            _selectedCategoryFilter = null;
            _isPrivatePhotosUnlocked = false;
          });
          return;
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          ref.read(mainNavigationIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'vault-hero-badge',
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: theme.colorScheme.tertiary,
                      size: 18,
                    ),
                  ),
                ),
                Hero(
                  tag: 'vault-hero-title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      l10n.vault,
                      style: theme.appBarTheme.titleTextStyle ??
                          theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (!vaultState.hasPin)
              IconButton(
                icon: const Icon(Icons.shield_outlined),
                tooltip: l10n.setVaultPin,
                onPressed: _showSetPinDialog,
              ),
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
        floatingActionButton: (vaultState.isLocked || filteredDocuments.isEmpty)
            ? null
            : FloatingActionButton(
                heroTag: null,
                onPressed: () => QuickActionsSheet.showForVault(
                  context,
                  selectedTripId: _selectedTripFilter,
                  selectedCategory: _selectedCategoryFilter,
                ),
                backgroundColor: _selectedCategoryFilter == 'Özel Resimler'
                    ? const Color(0xFFE11D48)
                    : theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                child: const Icon(Icons.add_rounded, size: 26),
              ),
      body: vaultState.isLocked
          ? VaultLockView(isTabMode: widget.isTabMode)
          : vaultState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  scrollCacheExtent: const ScrollCacheExtent.pixels(600.0),
                  slivers: [
                // Top Hero Row: Quick Vault Card (Left) & Pinned Passport Window (Right)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left: Özel Kasa (Private Safe) Gateway Card
                          Expanded(
                            flex: 1,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                key: const Key('private_photos_chip'),
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  if (_selectedCategoryFilter == 'Özel Resimler') {
                                    setState(() {
                                      _selectedCategoryFilter = null;
                                      _isPrivatePhotosUnlocked = false;
                                    });
                                  } else {
                                    if (_isPrivatePhotosUnlocked) {
                                      setState(() {
                                        _selectedCategoryFilter = 'Özel Resimler';
                                        _selectedSubCategoryFilter = null;
                                      });
                                    } else {
                                      _unlockPrivatePhotos();
                                    }
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedCategoryFilter == 'Özel Resimler'
                                        ? const Color(0xFFE11D48).withValues(alpha: isDark ? 0.2 : 0.08)
                                        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: _selectedCategoryFilter == 'Özel Resimler'
                                          ? const Color(0xFFE11D48)
                                          : (_isPrivatePhotosUnlocked
                                              ? const Color(0xFFE11D48).withValues(alpha: 0.5)
                                              : (isDark ? AppColors.outlineDark : AppColors.outlineLight)),
                                      width: _selectedCategoryFilter == 'Özel Resimler' ? 1.5 : 1,
                                    ),
                                    boxShadow: _selectedCategoryFilter == 'Özel Resimler'
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
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
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _isPrivatePhotosUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                                              size: 16,
                                              color: const Color(0xFFE11D48),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _isPrivatePhotosUnlocked
                                                      ? AppColors.successPastel.withValues(alpha: 0.2)
                                                      : const Color(0xFFE11D48).withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  _isPrivatePhotosUnlocked ? l10n.unlockedBadge : l10n.lockedBadge,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: _isPrivatePhotosUnlocked
                                                        ? AppColors.successPastel
                                                        : const Color(0xFFE11D48),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.privateVault,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _selectedCategoryFilter == 'Özel Resimler'
                                              ? const Color(0xFFE11D48)
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            _isPrivatePhotosUnlocked ? Icons.photo_library_outlined : Icons.shield_outlined,
                                            size: 12,
                                            color: _selectedCategoryFilter == 'Özel Resimler'
                                                ? const Color(0xFFE11D48)
                                                : theme.colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _isPrivatePhotosUnlocked
                                                  ? '$privateDocsCount ${l10n.privatePhotos}'
                                                  : l10n.tapToView,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: _selectedCategoryFilter == 'Özel Resimler'
                                                    ? const Color(0xFFE11D48)
                                                    : theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Right: Pinned Passport Window (Always on the Top Right)
                          Expanded(
                            flex: 1,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: passportDoc != null
                                        ? null
                                        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                                    gradient: passportDoc != null
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF1E3A8A),
                                              Color(0xFF172554),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: passportDoc != null
                                          ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                                          : (isDark ? AppColors.outlineDark : AppColors.outlineLight),
                                      width: 1,
                                    ),
                                    boxShadow: passportDoc != null
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
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
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: passportDoc != null
                                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                                  : theme.colorScheme.secondary.withValues(alpha: 0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.menu_book_rounded,
                                              size: 16,
                                              color: passportDoc != null
                                                  ? const Color(0xFFF59E0B)
                                                  : theme.colorScheme.secondary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: passportDoc != null
                                                      ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                                                      : theme.colorScheme.primaryContainer,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  passportDoc != null ? l10n.readyBadge : l10n.pinnedBadge,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: passportDoc != null
                                                        ? const Color(0xFFF59E0B)
                                                        : theme.colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        passportDoc != null ? passportDoc.title : l10n.passportSlot,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: passportDoc != null ? Colors.white : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            passportDoc != null ? Icons.visibility_rounded : Icons.add_circle_outline_rounded,
                                            size: 12,
                                            color: passportDoc != null
                                                ? const Color(0xFFF59E0B)
                                                : theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              passportDoc != null
                                                  ? dateFormat.format(passportDoc.createdAt)
                                                  : l10n.saveYourPassport,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: passportDoc != null
                                                    ? Colors.white.withValues(alpha: 0.8)
                                                    : theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
                                label: Text('${l10n.allDocuments} ($publicDocsCount)'),
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
                                      _isPrivatePhotosUnlocked = false;
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
                                    _isPrivatePhotosUnlocked = false;
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
                                    _isPrivatePhotosUnlocked = false;
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
                                    _isPrivatePhotosUnlocked = false;
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
                                    _isPrivatePhotosUnlocked = false;
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
                                    _isPrivatePhotosUnlocked = false;
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
                                    selected: _selectedSubCategoryFilter != null && _normalizeSubCategoryKey(_selectedSubCategoryFilter!) == 'flightTicket',
                                    selectedColor: const Color(0xFF0284C7),
                                    labelStyle: TextStyle(
                                      color: _selectedSubCategoryFilter != null && _normalizeSubCategoryKey(_selectedSubCategoryFilter!) == 'flightTicket'
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      setState(() => _selectedSubCategoryFilter = val ? 'flightTicket' : null);
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.directions_bus_rounded, size: 13),
                                    label: Text(l10n.busTickets),
                                    selected: _selectedSubCategoryFilter != null && _normalizeSubCategoryKey(_selectedSubCategoryFilter!) == 'busTicket',
                                    selectedColor: const Color(0xFF0284C7),
                                    labelStyle: TextStyle(
                                      color: _selectedSubCategoryFilter != null && _normalizeSubCategoryKey(_selectedSubCategoryFilter!) == 'busTicket'
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      setState(() => _selectedSubCategoryFilter = val ? 'busTicket' : null);
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.directions_boat_rounded, size: 13),
                                    label: Text(l10n.ferryBoat),
                                    selected: _selectedSubCategoryFilter != null && _normalizeSubCategoryKey(_selectedSubCategoryFilter!) == 'ferryTicket',
                                    selectedColor: const Color(0xFF0284C7),
                                    labelStyle: TextStyle(
                                      color: _selectedSubCategoryFilter != null && _normalizeSubCategoryKey(_selectedSubCategoryFilter!) == 'ferryTicket'
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      setState(() => _selectedSubCategoryFilter = val ? 'ferryTicket' : null);
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    avatar: const Icon(Icons.train_rounded, size: 13),
                                    label: Text(l10n.trainTickets),
                                    selected: _selectedSubCategoryFilter != null && _normalizeSubCategoryKey(_selectedSubCategoryFilter!) == 'trainTicket',
                                    selectedColor: const Color(0xFF0284C7),
                                    labelStyle: TextStyle(
                                      color: _selectedSubCategoryFilter != null && _normalizeSubCategoryKey(_selectedSubCategoryFilter!) == 'trainTicket'
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    onSelected: (val) {
                                      setState(() => _selectedSubCategoryFilter = val ? 'trainTicket' : null);
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
                                label: Text(l10n.allFilter),
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
                                      setState(() => _selectedTripFilter = val ? trip.id : null);
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

                // If currently viewing Özel Resimler, show sleek security status bar
                if (_selectedCategoryFilter == 'Özel Resimler')
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.privacy_tip_outlined, color: Color(0xFFE11D48), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.privatePhotosSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              key: const Key('lock_and_exit_button'),
                              onTap: () {
                                setState(() {
                                  _isPrivatePhotosUnlocked = false;
                                  _selectedCategoryFilter = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_rounded, size: 13, color: Color(0xFFE11D48)),
                                    const SizedBox(width: 4),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 90),
                                      child: Text(
                                        l10n.lockAndExit,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFE11D48),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Documents Grid
                if (filteredDocuments.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: (_selectedCategoryFilter == 'Özel Resimler'
                                          ? const Color(0xFFE11D48)
                                          : theme.colorScheme.secondaryContainer)
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _selectedCategoryFilter == 'Özel Resimler'
                                      ? Icons.photo_library_outlined
                                      : Icons.shield_outlined,
                                  size: 40,
                                  color: _selectedCategoryFilter == 'Özel Resimler'
                                      ? const Color(0xFFE11D48)
                                      : theme.colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _selectedCategoryFilter == 'Özel Resimler'
                                    ? l10n.noPrivatePhotosYet
                                    : (vaultState.documents.isEmpty ? l10n.noDocumentsYet : l10n.noDocumentsForFilter),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedCategoryFilter == 'Özel Resimler'
                                    ? l10n.noPrivatePhotosDesc
                                    : (vaultState.documents.isEmpty ? l10n.noDocumentsSubtitle : ''),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _selectedCategoryFilter == 'Özel Resimler'
                                      ? const Color(0xFFE11D48)
                                      : theme.colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () => AddDocumentSheet.show(
                                  context,
                                  initialTripId: _selectedTripFilter,
                                  initialCategory: _selectedCategoryFilter == 'Özel Resimler' ? 'PrivatePhotos' : null,
                                ),
                                icon: Icon(_selectedCategoryFilter == 'Özel Resimler'
                                    ? Icons.add_a_photo_rounded
                                    : Icons.add_rounded),
                                label: Text(
                                  _selectedCategoryFilter == 'Özel Resimler'
                                      ? l10n.addPrivatePhoto
                                      : l10n.addDocument,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        mainAxisExtent: 228,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = filteredDocuments[index];
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

                          return RepaintBoundary(
                            child: Dismissible(
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
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.visibility_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => DocumentViewerScreen(document: doc)),
                                );
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
                                          child: VaultThumbnailWidget(
                                            document: doc,
                                            categoryColor: categoryColor,
                                            categoryIcon: categoryIcon,
                                            fit: BoxFit.cover,
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
                                                        VaultScreen.getCategoryLabel(doc.category, l10n),
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
                                            if (isPdf) ...[
                                              const SizedBox(width: 4),
                                              IconButton(
                                                icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                tooltip: l10n.openPdf,
                                                onPressed: () => _openPdfSafely(context, doc),
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

/// Secure PIN Verification Sheet specifically designed for Private Vault / Private Photos
/// Provides real-time failed attempt limit visibility (out of 5),
/// security lockout countdown, and email PIN recovery integration.
class _PrivatePhotosPinSheet extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const _PrivatePhotosPinSheet({required this.onSuccess});

  @override
  ConsumerState<_PrivatePhotosPinSheet> createState() => _PrivatePhotosPinSheetState();
}

class _PrivatePhotosPinSheetState extends ConsumerState<_PrivatePhotosPinSheet> {
  String _entered = '';
  bool _isError = false;
  int _remainingAttempts = 5;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _remainingAttempts = ref.read(vaultControllerProvider.notifier).getRemainingPinAttempts();
    _checkLockout();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _checkLockout() {
    final controller = ref.read(vaultControllerProvider.notifier);
    if (controller.isPinLockedOut()) {
      _lockoutSeconds = controller.getPinLockoutRemainingSeconds();
      _startLockoutCountdown();
    }
  }

  void _startLockoutCountdown() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = ref.read(vaultControllerProvider.notifier).getPinLockoutRemainingSeconds();
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _lockoutSeconds = 0;
          _isError = false;
        });
      } else {
        setState(() {
          _lockoutSeconds = remaining;
        });
      }
    });
  }

  String _formatLockoutTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onDigitPressed(String d) {
    if (_lockoutSeconds > 0) {
      HapticFeedback.heavyImpact();
      return;
    }
    if (_entered.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _isError = false;
        _entered += d;
      });

      if (_entered.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_lockoutSeconds > 0) return;
    if (_entered.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _isError = false;
        _entered = _entered.substring(0, _entered.length - 1);
      });
    }
  }

  void _verifyPin() {
    final controller = ref.read(vaultControllerProvider.notifier);
    if (controller.isPinLockedOut()) {
      _checkLockout();
      return;
    }

    final success = controller.unlockVault(_entered);
    if (success) {
      _lockoutTimer?.cancel();
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      HapticFeedback.heavyImpact();
      final remaining = controller.getRemainingPinAttempts();
      setState(() {
        _isError = true;
        _entered = '';
        _remainingAttempts = remaining;
      });

      final lang = Localizations.localeOf(context).languageCode;
      if (controller.isPinLockedOut()) {
        _checkLockout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(DashboardLocalization.vaultLockedSnackbar(lang))),
              ],
            ),
            backgroundColor: AppColors.errorPastel,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        final errorMsg = DashboardLocalization.vaultIncorrectPinBanner(lang, remaining, 5);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            backgroundColor: AppColors.errorPastel,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _buildNumpadButton(String digit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = _lockoutSeconds > 0;
    return InkWell(
      onTap: isDisabled ? null : () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(32),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled
              ? (isDark ? const Color(0xFF1E1E26) : const Color(0xFFE5E7EB))
              : (isDark ? const Color(0xFF2A2A36) : const Color(0xFFF3F4F6)),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDisabled
                ? Theme.of(context).disabledColor
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, color: Color(0xFFE11D48), size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.privatePhotos,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.enterPinToUnlockVault,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),

              // Lockout Warning Container if locked out
              if (_lockoutSeconds > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.errorPastel.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.errorPastel.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_rounded, color: AppColors.errorPastel, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            DashboardLocalization.vaultLockedTitle(lang, _formatLockoutTime(_lockoutSeconds)),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.errorPastel,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DashboardLocalization.vaultLockedDesc(lang),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _entered.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? (_isError ? AppColors.errorPastel : const Color(0xFFE11D48))
                          : Colors.transparent,
                      border: Border.all(
                        color: _isError ? AppColors.errorPastel : const Color(0xFFE11D48),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // Prominently Visible In-Place Warning Banner & Remaining Attempt Counter
              if (_lockoutSeconds <= 0 && (_isError || _remainingAttempts < 5)) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFE11D48),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DashboardLocalization.vaultIncorrectPinBanner(lang, _remainingAttempts, 5),
                        style: const TextStyle(
                          color: Color(0xFFE11D48),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                const SizedBox(height: 24),
              ],

              // Number Pad
              for (var row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9']
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((d) => _buildNumpadButton(d)).toList(),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 64, height: 64),
                  _buildNumpadButton('0'),
                  InkWell(
                    onTap: _lockoutSeconds > 0 ? null : _onBackspace,
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.backspace_outlined,
                        size: 22,
                        color: _lockoutSeconds > 0
                            ? theme.disabledColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  VaultPinRecoverySheet.show(context);
                },
                icon: const Icon(Icons.help_outline_rounded, size: 16),
                label: Text(
                  l10n.forgotPin,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
