import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local_db/database_helper.dart';
import '../../../../data/sync_engine/sync_engine.dart';
import '../../../../core/services/app_widget_service.dart';
import '../../../../core/services/telemetry_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../domain/packing_item.dart';
import '../../domain/packing_templates.dart';
import '../../domain/airline_baggage_guide.dart';
import '../../domain/canonical_packing_catalog.dart';
import '../../../auth/auth_controller.dart';
import '../../../../l10n/app_localizations.dart';

/// State of the Checklist & Luggage system
class ChecklistState {
  final List<PackingItem> items;
  final bool isLoading;
  final String searchQuery;
  final String? selectedCategory;
  final bool isSearchExpanded;
  final String? errorMessage;
  final String? activeTripId;
  final AirlineBaggageRule? selectedAirline;

  const ChecklistState({
    this.items = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedCategory,
    this.isSearchExpanded = false,
    this.errorMessage,
    this.activeTripId,
    this.selectedAirline,
  });

  static final Map<String, String> _canonicalTokens = _buildCanonicalTokens();

  static Map<String, String> _buildCanonicalTokens() {
    final map = <String, String>{
      '': 'all',
      'all': 'all',
      'tümü': 'all',
      'tumu': 'all',
      'alle': 'all',
      'todos': 'all',
      'tous': 'all',
      'все': 'all',
      'clothing': 'clothing',
      'kıyafet': 'clothing',
      'kiyafet': 'clothing',
      'kleidung': 'clothing',
      'ropa': 'clothing',
      'vetements': 'clothing',
      'vêtements': 'clothing',
      'одежда': 'clothing',
      'electronics': 'electronics',
      'elektronik': 'electronics',
      'electronica': 'electronics',
      'électronique': 'electronics',
      'электроника': 'electronics',
      'toiletries': 'toiletries',
      'kişisel bakım': 'toiletries',
      'kisisel bakim': 'toiletries',
      'personal care': 'toiletries',
      'körperpflege': 'toiletries',
      'higiene': 'toiletries',
      'toilette': 'toilette',
      'туалетные принадлежности': 'toiletries',
      'documents': 'documents',
      'belgeler': 'documents',
      'dokumente': 'documents',
      'documentos': 'documents',
      'документы': 'documents',
      'accessories': 'accessories',
      'aksesuar': 'accessories',
      'zubehör': 'accessories',
      'zubehor': 'accessories',
      'accesorios': 'accessories',
      'accessoires': 'accessories',
      'аксессуары': 'accessories',
    };

    // Dynamically register localized tokens across all 20 supported languages
    for (final locale in AppLocalizations.supportedLocales) {
      try {
        final l10n = lookupAppLocalizations(locale);
        map[l10n.allCategories.trim().toLowerCase()] = 'all';
        map[l10n.categoryClothing.trim().toLowerCase()] = 'clothing';
        map[l10n.categoryElectronics.trim().toLowerCase()] = 'electronics';
        map[l10n.categoryToiletries.trim().toLowerCase()] = 'toiletries';
        map[l10n.categoryDocuments.trim().toLowerCase()] = 'documents';
        map[l10n.categoryAccessories.trim().toLowerCase()] = 'accessories';
      } catch (_) {}
    }
    return map;
  }

  /// Normalizes and resolves a category string into a language-independent canonical token across all 20 languages
  static String normalizeCategoryToken(String category) {
    final lower = category.trim().toLowerCase();
    return _canonicalTokens[lower] ?? lower;
  }

  /// Items filtered by active search query and category filter
  List<PackingItem> get filteredItems {
    return items.where((item) {
      // Category filter (Language-independent canonical matching)
      if (selectedCategory != null && selectedCategory!.isNotEmpty) {
        final selectedToken = normalizeCategoryToken(selectedCategory!);
        if (selectedToken != 'all') {
          final itemToken = normalizeCategoryToken(item.category);
          if (itemToken != selectedToken &&
              item.category.toLowerCase() != selectedCategory!.toLowerCase()) {
            return false;
          }
        }
      }

      // Search query (matches name, tag, or category)
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchName = item.name.toLowerCase().contains(query);
        final matchTag = item.tag.toLowerCase().contains(query);
        final matchCategory = item.category.toLowerCase().contains(query);
        final matchCompartment = item.compartment.toLowerCase().contains(query);
        if (!matchName && !matchTag && !matchCategory && !matchCompartment) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Count of packed items
  int get packedCount => items.where((i) => i.isPacked).length;

  /// Total item count
  int get totalCount => items.length;

  /// Packed percentage ratio (0.0 to 1.0)
  double get completionRatio => totalCount > 0 ? packedCount / totalCount : 0.0;

  ChecklistState copyWith({
    List<PackingItem>? items,
    bool? isLoading,
    String? searchQuery,
    String? selectedCategory,
    bool? isSearchExpanded,
    String? errorMessage,
    String? activeTripId,
    bool clearSelectedCategory = false,
    AirlineBaggageRule? selectedAirline,
    bool clearSelectedAirline = false,
  }) {
    return ChecklistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      isSearchExpanded: isSearchExpanded ?? this.isSearchExpanded,
      errorMessage: errorMessage,
      activeTripId: activeTripId ?? this.activeTripId,
      selectedAirline: clearSelectedAirline ? null : (selectedAirline ?? this.selectedAirline),
    );
  }
}

/// StateNotifier orchestrating packing checklist, item progress, and filtering
class ChecklistNotifier extends StateNotifier<ChecklistState> {
  final DatabaseHelper _db;
  final Ref? _ref;

  ChecklistNotifier([DatabaseHelper? db, ChecklistState? initialState, this._ref])
      : _db = db ?? DatabaseHelper.instance,
        super(initialState ?? const ChecklistState()) {
    if (initialState == null) {
      final initialUid = _ref?.read(authUserProvider)?.uid;
      loadItems(userId: initialUid);
    }
  }

  Timer? _syncDebounceTimer;

  void _triggerSync() {
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(const Duration(milliseconds: 1500), () {
      try {
        _ref?.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}
      try {
        AppWidgetService.syncCurrentState();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _syncDebounceTimer?.cancel();
    super.dispose();
  }

  /// Seed initial representative travel items with deterministic IDs
  static List<PackingItem> _buildSeedItems(String? userId) => [
        PackingItem(
          id: CanonicalPackingCatalog.generateDeterministicId(
            prefix: 'default',
            userId: userId,
            canonicalKey: 'headphones',
          ),
          name: 'Noise-Cancelling Headphones & Case',
          category: 'Elektronik',
          quantity: 1,
          isPacked: true,
          tag: 'CABIN ONLY',
          compartment: 'Sırt Çantası',
          createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 50)),
        ),
        PackingItem(
          id: CanonicalPackingCatalog.generateDeterministicId(
            prefix: 'default',
            userId: userId,
            canonicalKey: 'passport',
          ),
          name: 'Pasaport, Vize & Uçuş Biletleri',
          category: 'Belgeler',
          quantity: 1,
          isPacked: true,
          tag: 'ESSENTIAL',
          compartment: 'Ön Cep',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        PackingItem(
          id: CanonicalPackingCatalog.generateDeterministicId(
            prefix: 'default',
            userId: userId,
            canonicalKey: 'raincoat',
          ),
          name: 'Hafif Su Geçirmez Yağmurluk',
          category: 'Kıyafet',
          quantity: 1,
          isPacked: false,
          tag: 'CARRY-ON',
          compartment: 'Ana Bölme',
          createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 40)),
        ),
        PackingItem(
          id: CanonicalPackingCatalog.generateDeterministicId(
            prefix: 'default',
            userId: userId,
            canonicalKey: 'charger',
          ),
          name: 'Evrensel Seyahat Prizi & Hızlı Şarj Cihazı',
          category: 'Elektronik',
          quantity: 2,
          isPacked: true,
          tag: 'CABIN ONLY',
          compartment: 'Sırt Çantası',
          createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 35)),
        ),
        PackingItem(
          id: CanonicalPackingCatalog.generateDeterministicId(
            prefix: 'default',
            userId: userId,
            canonicalKey: 'toiletries',
          ),
          name: 'Kişisel Bakım & Kozmetik Çantası (100ml TSA)',
          category: 'Kişisel Bakım',
          quantity: 1,
          isPacked: false,
          tag: 'CARRY-ON',
          compartment: 'Kozmetik Bölmesi',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        PackingItem(
          id: CanonicalPackingCatalog.generateDeterministicId(
            prefix: 'default',
            userId: userId,
            canonicalKey: 'walking_shoes',
          ),
          name: 'Konforlu Yürüyüş Ayakkabısı',
          category: 'Kıyafet',
          quantity: 1,
          isPacked: false,
          tag: 'CHECK-IN',
          compartment: 'Ana Bölme',
          createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        PackingItem(
          id: CanonicalPackingCatalog.generateDeterministicId(
            prefix: 'default',
            userId: userId,
            canonicalKey: 'thermal_underwear',
          ),
          name: 'Merino Yün Termal İçlik & Çoraplar',
          category: 'Kıyafet',
          quantity: 3,
          isPacked: true,
          tag: 'CARRY-ON',
          compartment: 'Ana Bölme',
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        PackingItem(
          id: CanonicalPackingCatalog.generateDeterministicId(
            prefix: 'default',
            userId: userId,
            canonicalKey: 'powerbank',
          ),
          name: 'Powerbank 20.000 mAh (Uçuş Onaylı)',
          category: 'Elektronik',
          quantity: 1,
          isPacked: false,
          tag: 'CABIN ONLY',
          compartment: 'Ön Cep',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ];


  /// Resets controller state on logout or account switch
  void resetState() {
    state = const ChecklistState();
  }

  /// Loads items from database, seeding defaults if empty
  Future<void> loadItems({String? tripId, String? userId}) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, activeTripId: tripId);
    try {
      final effectiveUid = (userId != null && userId.isNotEmpty)
          ? userId
          : _ref?.read(authUserProvider)?.uid;

      // Deduplicate existing checklist items in SQLite for clean state
      await _db.deduplicateChecklistItems(userId: effectiveUid, tripId: tripId);
      var items = await _db.getChecklistItems(tripId: tripId, userId: effectiveUid);
      if (!mounted) return;

      // If user intentionally cleared checklist, purge any rogue default items
      if (effectiveUid != null && effectiveUid.isNotEmpty) {
        final isCleared = PreferencesService.instance.hasClearedChecklist(uid: effectiveUid);
        if (isCleared && items.any((i) => i.id.startsWith('default_'))) {
          await _db.deleteDefaultSeedItems(effectiveUid);
          items = await _db.getChecklistItems(tripId: tripId, userId: effectiveUid);
        }
      }

      // Only seed default items if:
      // 1. We are viewing the general checklist (tripId == null)
      // 2. We have an authenticated user (never auto-seed into guest storage before login)
      // 3. User hasn't already seeded or cleared the checklist
      if (items.isEmpty && tripId == null && effectiveUid != null && effectiveUid.isNotEmpty) {
        var alreadySeeded = PreferencesService.instance.hasSeededChecklist(uid: effectiveUid);
        var alreadyCleared = PreferencesService.instance.hasClearedChecklist(uid: effectiveUid);

        // If local prefs have no record (e.g. fresh install / reinstall), verify with Firestore first!
        if (!alreadySeeded && !alreadyCleared) {
          try {
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(effectiveUid).get();
            if (userDoc.exists && userDoc.data() != null) {
              final data = userDoc.data()!;
              if (data['hasClearedChecklist'] == true) {
                alreadyCleared = true;
                await PreferencesService.instance.setClearedChecklist(true, uid: effectiveUid);
              }
              if (data['hasSeededChecklist'] == true) {
                alreadySeeded = true;
                await PreferencesService.instance.setSeededChecklist(true, uid: effectiveUid);
              }
            }
          } catch (_) {}
        }

        final deletedItems = await _db.getDeletedChecklistItems(userId: effectiveUid);
        if (!alreadySeeded && !alreadyCleared && deletedItems.isEmpty) {
          // Seed default items for a rich first-run experience with deterministic IDs ONLY ONCE
          for (final item in _buildSeedItems(effectiveUid)) {
            await _db.insertChecklistItem(item, userId: effectiveUid);
          }
          await PreferencesService.instance.setSeededChecklist(true, uid: effectiveUid);
          try {
            unawaited(FirebaseFirestore.instance.collection('users').doc(effectiveUid).set({
              'hasSeededChecklist': true,
            }, SetOptions(merge: true)));
          } catch (_) {}
          if (!mounted) return;
          items = await _db.getChecklistItems(userId: effectiveUid);
        }
      }
      if (!mounted) return;
      state = state.copyWith(items: items, isLoading: false);
      AppWidgetService.syncCurrentState();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Checklist yüklenemedi: $e',
      );
    }
  }

  /// Toggles packed/complete state (invoked by checkbox or left swipe)
  Future<void> togglePacked(String id) async {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final current = state.items[index];
    final updated = current.copyWith(
      isPacked: !current.isPacked,
      updatedAt: DateTime.now(),
    );

    // Optimistic UI update
    final newItems = List<PackingItem>.from(state.items);
    newItems[index] = updated;
    state = state.copyWith(items: newItems);

    try {
      await _db.updateChecklistItem(updated);
      _triggerSync();
      TelemetryService.instance.logChecklistAction(
        action: updated.isPacked ? 'pack' : 'unpack',
        category: updated.category,
        itemCount: 1,
      );
    } catch (e) {
      // Revert on error
      newItems[index] = current;
      state = state.copyWith(items: newItems, errorMessage: 'Durum güncellenemedi: $e');
    }
  }

  /// Assigns an item to a collaborator (Feature F-1)
  Future<void> assignItem(String id, String? assignedTo) async {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final current = state.items[index];
    final updated = current.copyWith(
      assignedTo: assignedTo,
      updatedAt: DateTime.now(),
    );

    final newItems = List<PackingItem>.from(state.items);
    newItems[index] = updated;
    state = state.copyWith(items: newItems);

    try {
      await _db.updateChecklistItem(updated);
      _triggerSync();
    } catch (_) {}
  }

  /// Updates quantity via - 1 + stepper (minimum 1)
  Future<void> updateQuantity(String id, int delta) async {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final current = state.items[index];
    final newQuantity = (current.quantity + delta).clamp(1, 99);
    if (newQuantity == current.quantity) return;

    final updated = current.copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );

    // Optimistic UI update
    final newItems = List<PackingItem>.from(state.items);
    newItems[index] = updated;
    state = state.copyWith(items: newItems);

    try {
      await _db.updateChecklistItem(updated);
      _triggerSync();
    } catch (e) {
      newItems[index] = current;
      state = state.copyWith(items: newItems, errorMessage: 'Adet güncellenemedi: $e');
    }
  }

  /// Updates full item attributes (name, category, tag, compartment)
  Future<void> updateItem(PackingItem updated) async {
    final index = state.items.indexWhere((i) => i.id == updated.id);
    if (index == -1) return;

    final current = state.items[index];
    final itemToSave = updated.copyWith(updatedAt: DateTime.now());

    final newItems = List<PackingItem>.from(state.items);
    newItems[index] = itemToSave;
    state = state.copyWith(items: newItems);

    try {
      await _db.updateChecklistItem(itemToSave);
      _triggerSync();
    } catch (e) {
      newItems[index] = current;
      state = state.copyWith(items: newItems, errorMessage: 'Eşya güncellenemedi: $e');
    }
  }

  /// Soft deletes item (invoked by right swipe or delete dialog)
  /// Returns the deleted item to enable immediate Undo capability in UI
  Future<PackingItem?> deleteItem(String id) async {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index == -1) return null;

    final deleted = state.items[index];
    final newItems = List<PackingItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: newItems);

    try {
      await _db.deleteChecklistItem(id);
      if (newItems.isEmpty && state.activeTripId == null) {
        final uid = _ref?.read(authUserProvider)?.uid;
        PreferencesService.instance.setClearedChecklist(true, uid: uid);
        PreferencesService.instance.setSeededChecklist(true, uid: uid);
        if (uid != null && uid.isNotEmpty) {
          try {
            unawaited(FirebaseFirestore.instance.collection('users').doc(uid).set({
              'hasClearedChecklist': true,
              'hasSeededChecklist': true,
            }, SetOptions(merge: true)));
          } catch (_) {}
        }
      }
      _triggerSync();
      return deleted;
    } catch (e) {
      // Revert
      newItems.insert(index, deleted);
      state = state.copyWith(items: newItems, errorMessage: 'Eşya silinemedi: $e');
      return null;
    }
  }

  /// Restores item from undo snackbar
  Future<void> restoreItem(PackingItem item) async {
    final newItems = List<PackingItem>.from(state.items)..insert(0, item);
    state = state.copyWith(items: newItems);

    try {
      await _db.restoreChecklistItem(item.id);
      final uid = _ref?.read(authUserProvider)?.uid;
      PreferencesService.instance.setClearedChecklist(false, uid: uid);
      if (uid != null && uid.isNotEmpty) {
        try {
          unawaited(FirebaseFirestore.instance.collection('users').doc(uid).set({
            'hasClearedChecklist': false,
          }, SetOptions(merge: true)));
        } catch (_) {}
      }
      _triggerSync();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Geri alma başarısız: $e');
    }
  }

  /// Adds a new packing item
  Future<void> addItem(PackingItem item) async {
    final currentUid = _ref?.read(authUserProvider)?.uid ?? '';
    final itemToSave = (item.userId.isEmpty && currentUid.isNotEmpty)
        ? item.copyWith(userId: currentUid)
        : item;
    final newItems = [itemToSave, ...state.items];
    state = state.copyWith(items: newItems);

    try {
      await _db.insertChecklistItem(itemToSave);
      PreferencesService.instance.setClearedChecklist(false, uid: currentUid);
      PreferencesService.instance.setSeededChecklist(true, uid: currentUid);
      if (currentUid.isNotEmpty) {
        try {
          unawaited(FirebaseFirestore.instance.collection('users').doc(currentUid).set({
            'hasClearedChecklist': false,
            'hasSeededChecklist': true,
          }, SetOptions(merge: true)));
        } catch (_) {}
      }
      _triggerSync();
      TelemetryService.instance.logChecklistAction(
        action: 'add',
        category: itemToSave.category,
        itemCount: 1,
      );
    } catch (e) {
      newItems.removeWhere((i) => i.id == itemToSave.id);
      state = state.copyWith(items: newItems, errorMessage: 'Eşya eklenemedi: $e');
    }
  }

  /// Bulk adds packing items (e.g. from a Smart Template)
  Future<void> addItems(List<PackingItem> items) async {
    if (items.isEmpty) return;
    final currentUid = _ref?.read(authUserProvider)?.uid ?? '';

    for (final item in items) {
      try {
        final itemToSave = (item.userId.isEmpty && currentUid.isNotEmpty)
            ? item.copyWith(userId: currentUid)
            : item;
        await _db.insertChecklistItem(itemToSave);
      } catch (e) {
        // Continue adding
      }
    }
    await _db.deduplicateChecklistItems(
      userId: state.items.isNotEmpty ? state.items.first.userId : null,
      tripId: state.activeTripId,
    );
    final refreshedItems = await _db.getChecklistItems(
      tripId: state.activeTripId,
      userId: state.items.isNotEmpty ? state.items.first.userId : null,
    );
    state = state.copyWith(items: refreshedItems);
    _triggerSync();
    TelemetryService.instance.logChecklistAction(
      action: 'bulk_add',
      itemCount: items.length,
    );
  }

  /// Imports a pre-curated template into the active checklist.
  /// Preserves all checked/packed items (isPacked == true), while removing
  /// unselected/unpacked items (isPacked == false) from prior templates to prevent clutter.
  Future<void> importTemplate(PackingTemplate template) async {
    // 1. Identify unpacked items and delete them from DB
    final unpackedItems = state.items.where((i) => !i.isPacked).toList();
    for (final unpacked in unpackedItems) {
      try {
        await _db.deleteChecklistItem(unpacked.id);
      } catch (_) {}
    }

    // 2. Retain all checked/packed items
    final preservedPackedItems = state.items.where((i) => i.isPacked).toList();
    final existingPackedCanonicalKeys = preservedPackedItems
        .map((i) => CanonicalPackingCatalog.resolveCanonicalKey(i.name) ?? CanonicalPackingCatalog.normalize(i.name))
        .toSet();

    // 3. Instantiate new template items (avoid duplicating already packed items)
    final effectiveUserId = preservedPackedItems.isNotEmpty ? preservedPackedItems.first.userId : null;
    final newPackingItems = template.items
        .where((t) {
          final tKey = CanonicalPackingCatalog.resolveCanonicalKey(t.name) ?? CanonicalPackingCatalog.normalize(t.name);
          return !existingPackedCanonicalKeys.contains(tKey);
        })
        .map((t) => t.toPackingItem(tripId: state.activeTripId, userId: effectiveUserId, templateId: template.id))
        .toList();

    for (final item in newPackingItems) {
      try {
        await _db.insertChecklistItem(item);
      } catch (_) {}
    }
    // Immediate in-memory state update ensuring reactive UI and unit test resilience
    final combined = [...preservedPackedItems, ...newPackingItems];
    state = state.copyWith(items: combined);

    try {
      await _db.deduplicateChecklistItems(userId: effectiveUserId, tripId: state.activeTripId);
      final refreshedItems = await _db.getChecklistItems(
        tripId: state.activeTripId,
        userId: effectiveUserId,
      );
      if (refreshedItems.isNotEmpty) {
        state = state.copyWith(items: refreshedItems);
      }
    } catch (_) {}
    _triggerSync();
    TelemetryService.instance.logChecklistAction(
      action: 'import_template',
      itemCount: newPackingItems.length,
    );
  }

  /// Category filter selection
  void setCategoryFilter(String? category) {
    if (category == null || category == 'Tümü') {
      state = state.copyWith(clearSelectedCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  /// Instant search query update
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Toggle collapsible search bar
  void toggleSearchExpanded() {
    final next = !state.isSearchExpanded;
    state = state.copyWith(
      isSearchExpanded: next,
      searchQuery: next ? state.searchQuery : '',
    );
  }

  /// Sets or clears selected airline rule for informational guidance
  void selectAirline(AirlineBaggageRule? airline) {
    if (airline != null) {
      state = state.copyWith(selectedAirline: airline);
    } else {
      state = state.copyWith(clearSelectedAirline: true);
    }
  }

  /// Convenience method for setting airline reference without weight limits
  void setLuggageLimit(double limit, {AirlineBaggageRule? airline}) {
    if (airline != null) {
      selectAirline(airline);
    }
  }
}

/// Global provider for Checklist StateNotifier
final checklistControllerProvider =
    StateNotifierProvider<ChecklistNotifier, ChecklistState>((ref) {
  return ChecklistNotifier(null, null, ref);
});
