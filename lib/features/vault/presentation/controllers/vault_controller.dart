import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/core/services/biometric_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/telemetry_service.dart';
import 'package:packbuddy/core/services/security_service.dart';
import 'package:packbuddy/core/services/vault_pin_service.dart';
import 'package:packbuddy/core/services/pro_entitlement_service.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/vault/domain/document.dart';

/// State representation for Document Vault
class VaultState {
  final bool isLoading;
  final List<Document> documents;
  final String? errorMessage;
  final bool isLocked;
  final bool hasPin;
  final bool isBiometricEnabled;

  const VaultState({
    this.isLoading = false,
    this.documents = const [],
    this.errorMessage,
    this.isLocked = false,
    this.hasPin = false,
    this.isBiometricEnabled = false,
  });

  VaultState copyWith({
    bool? isLoading,
    List<Document>? documents,
    String? errorMessage,
    bool? isLocked,
    bool? hasPin,
    bool? isBiometricEnabled,
  }) {
    return VaultState(
      isLoading: isLoading ?? this.isLoading,
      documents: documents ?? this.documents,
      errorMessage: errorMessage,
      isLocked: isLocked ?? this.isLocked,
      hasPin: hasPin ?? this.hasPin,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}

/// Controller managing Document Vault storage, image & PDF picking, cloud sync, and biometric/PIN security
class VaultController extends StateNotifier<VaultState> {
  final Ref _ref;
  final DatabaseHelper _dbHelper;
  final ImagePicker _picker;
  final PreferencesService _prefs;
  final _uuid = const Uuid();

  VaultController(
    this._ref, {
    DatabaseHelper? dbHelper,
    ImagePicker? picker,
    PreferencesService? prefs,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _picker = picker ?? ImagePicker(),
        _prefs = prefs ?? PreferencesService.instance,
        super(VaultState(
          isLocked: (prefs ?? PreferencesService.instance).isVaultLocked(),
          hasPin: VaultPinService.instance.hasPin(),
          isBiometricEnabled: (prefs ?? PreferencesService.instance).isVaultBiometricEnabled(),
        )) {
    _loadPinState();
    loadDocuments();
  }

  VaultPinService get _pins => VaultPinService.instance;

  /// Loads the hashed PIN record from secure storage for the current user, then refreshes state.
  Future<void> _loadPinState() async {
    try {
      await _pins.ensureLoaded();
    } catch (e) {
      debugPrint('[VaultController] PIN state load notice: $e');
    }
    if (mounted) refreshSecurityState();
  }

  /// Formerly produced a PLAINTEXT base64 copy of the file for Firestore. Vault bytes now only
  /// leave the device AES-encrypted via Firebase Storage (C4), so no cloud payload is produced.
  Future<String?> encodeFileForCloud(String filePath, {String? userId}) async => null;

  /// Eagerly writes document METADATA ONLY to Firestore so other devices see the entry quickly.
  /// File bytes are never written to Firestore (no plaintext base64 / chunks): the sync engine
  /// uploads them AES-encrypted to Firebase Storage (C4).
  Future<void> _eagerCloudSyncDocument(Document doc) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) return;
      await FirebaseFirestore.instance.collection('documents').doc(doc.id).set(
        doc.copyWith(userId: uid, clearCloudData: true).toJson(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[VaultController] eager cloud sync notice: $e');
    }
  }

  /// Attempts to unlock the vault using a PIN code.
  /// PIN is strictly mandatory: vault can only be unlocked if a PIN was set and matches.
  /// Enforces security lockout: 5 wrong attempts within 10 minutes locks the vault.
  bool unlockVault(String pin) {
    if (isPinLockedOut()) {
      return false;
    }

    // Salted PBKDF2 hash comparison (C3); the plaintext PIN is never stored.
    if (_pins.verifyPin(pin)) {
      _prefs.setVaultLocked(false);
      unawaited(_pins.resetFailedAttempts());
      state = state.copyWith(isLocked: false);
      return true;
    }

    unawaited(_pins.recordFailedAttempt());
    return false;
  }

  /// Checks if vault PIN entry is temporarily locked out due to >= 5 failed attempts in 10 mins
  bool isPinLockedOut() => _pins.isLockedOut();

  /// Gets remaining lockout seconds (0 if not locked out)
  int getPinLockoutRemainingSeconds() => _pins.lockoutRemainingSeconds();

  /// Gets remaining allowed attempts before lockout (from 5 down to 0)
  int getRemainingPinAttempts() {
    final count = _pins.failedAttemptsCount();
    return (VaultPinService.maxFailedAttempts - count).clamp(0, VaultPinService.maxFailedAttempts);
  }

  /// Clears failed attempt history
  Future<void> resetFailedPinAttempts() async {
    await _pins.resetFailedAttempts();
  }

  /// Manually locks the vault immediately
  void lockVault() {
    _prefs.setVaultLocked(true);
    state = state.copyWith(isLocked: true);
  }

  /// Sets a new PIN code for vault protection. The PIN stays on this device only
  /// (salted hash in secure storage) and is never written to Firestore (C3).
  Future<void> setPin(String pin) async {
    await _pins.setPin(pin);
    await _pins.resetFailedAttempts();
    state = state.copyWith(hasPin: true);
  }

  /// Removes the vault PIN code and locks the vault until a new PIN is set
  Future<void> removePin() async {
    await _pins.setPin(null);
    await _prefs.setVaultLocked(true);
    state = state.copyWith(hasPin: false, isLocked: true);
  }

  /// Unlocks the vault via real biometric verification (Fingerprint / Face ID)
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    final success = await BiometricService.instance.authenticate(
      localizedReason: reason ?? 'Verify your fingerprint or face to unlock your travel vault',
    );
    if (success) {
      _prefs.setVaultLocked(false);
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  /// Sets or updates biometric authentication preference and syncs to cloud
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setVaultBiometricEnabled(enabled);
    state = state.copyWith(isBiometricEnabled: enabled);
    await _syncSecuritySettingsToCloud(biometricEnabled: enabled);
  }

  /// Synchronizes the biometric preference to Firestore. The vault PIN is never synced.
  Future<void> _syncSecuritySettingsToCloud({
    bool? biometricEnabled,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
      if (biometricEnabled != null) {
        data['vaultBiometricEnabled'] = biometricEnabled;
        data['vaultBiometricUpdatedAt'] = DateTime.now().toUtc().toIso8601String();
      }
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        data,
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[VaultController] sync security settings notice: $e');
    }
  }

  /// Refreshes PIN and biometric availability without altering the active session lock state
  void refreshSecurityState() {
    if (!_pins.isLoaded()) {
      // Account switched or first access: load this user's hashed PIN, then refresh again.
      unawaited(_loadPinState());
    }
    state = state.copyWith(
      hasPin: _pins.hasPin(),
      isBiometricEnabled: _prefs.isVaultBiometricEnabled(),
    );
  }

  /// Resets controller state on logout or account switch
  void resetState() {
    if (!_pins.isLoaded()) unawaited(_loadPinState());
    state = VaultState(
      isLocked: _prefs.isVaultLocked(),
      hasPin: _pins.hasPin(),
      isBiometricEnabled: _prefs.isVaultBiometricEnabled(),
      documents: const [],
    );
  }

  /// Loads all active (non-deleted) documents from SQLite
  Future<void> loadDocuments({String? tripId, String? userId}) async {
    refreshSecurityState();
    state = state.copyWith(isLoading: true);
    try {
      final docs = await _dbHelper.getDocuments(
        tripId: tripId,
        userId: userId,
        includeDeleted: false,
      );
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        documents: docs,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Safely picks an image from camera or gallery and persists it for offline use
  Future<Document?> pickAndAddDocument({
    required ImageSource source,
    required String title,
    required String category,
    String? subCategory,
    String? tripId,
    String? notes,
  }) async {
    // Feature restriction guard (Phase 3)
    if (_prefs.getRestrictedFeatures().contains('vault_upload')) {
      state = state.copyWith(errorMessage: 'restricted_vault_upload');
      return null;
    }

    try {
      // 1. Pick image (automatically compressed to max ~1600px and 80 quality for cloud & memory safety)
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (pickedFile == null) {
        // User cancelled selection - return gracefully without error
        return null;
      }

      final originalFile = File(pickedFile.path);

      // Strict Single File 10 MB Limit Enforcement, checked BEFORE loading bytes (OOM protection)
      final fileBytes = await originalFile.length();
      if (fileBytes > ProFeatureGate.kMaxSingleFileBytes) {
        state = state.copyWith(errorMessage: 'file_too_large_10mb');
        return null;
      }
      final rawBytes = await originalFile.readAsBytes();

      // Pro Feature Gate check (Free: max 5 docs, 50MB total; Pro: unlimited docs, 5GB total)
      final isPro = _ref.read(proSubscriptionProvider).isPro;
      final currentDocCount = state.documents.where((d) => !d.isDeleted).length;
      final totalVaultBytes = state.documents.where((d) => !d.isDeleted).fold<int>(0, (total, d) => total + d.fileSizeBytes);

      if (!ProFeatureGate.canAddVaultDocument(
        isPro: isPro,
        currentDocCount: currentDocCount,
        fileSizeBytes: fileBytes,
        totalVaultBytes: totalVaultBytes,
      )) {
        TelemetryService.instance.logProGateHit(
          featureKey: 'vault_limit',
          context: 'docs_${currentDocCount}_bytes_$totalVaultBytes',
        );
        state = state.copyWith(errorMessage: 'pro_vault_limit_reached');
        return null;
      }

      // 2. Copy image to application documents directory for permanent offline availability
      final appDir = await getApplicationDocumentsDirectory();
      final vaultDir = Directory(p.join(appDir.path, 'vault'));
      if (!await vaultDir.exists()) {
        await vaultDir.create(recursive: true);
      }

      final ext = p.extension(pickedFile.path).isNotEmpty ? p.extension(pickedFile.path) : '.jpg';
      final fileName = '${_uuid.v4()}$ext';
      final targetPath = p.join(vaultDir.path, fileName);

      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final encryptedBytes = await SecurityService.instance.encryptBytes(rawBytes, userId: currentUid);
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(encryptedBytes);

      // 3. Create Document entity with cloud payload
      final cleanExt = ext.replaceAll('.', '').toLowerCase();
      final now = DateTime.now();
      final newDoc = Document(
        id: _uuid.v4(),
        userId: currentUid,
        title: title,
        category: category,
        subCategory: subCategory,
        localImagePath: targetPath,
        tripId: tripId,
        fileType: 'image',
        notes: notes,
        fileSizeBytes: fileBytes,
        fileExtension: cleanExt,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      // 4. Persist to SQLite
      await _dbHelper.insertDocument(newDoc);

      // 5. Update state
      state = state.copyWith(
        documents: [newDoc, ...state.documents],
      );

      // 6. Log telemetry event
      TelemetryService.instance.logDocumentUploaded(
        category: category,
        fileSizeBytes: fileBytes,
        fileExtension: ext,
      );

      // 7. Eager cloud push & trigger background two-way sync
      unawaited(_eagerCloudSyncDocument(newDoc));
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

      return newDoc;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// Safely picks a document or PDF via file picker and persists it
  Future<Document?> pickAndAddFileDocument({
    required String title,
    required String category,
    String? subCategory,
    String? tripId,
    String? notes,
  }) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (file == null || file.path == null) {
        return null;
      }

      final pickedPath = file.path!;
      final appDir = await getApplicationDocumentsDirectory();
      final vaultDir = Directory(p.join(appDir.path, 'vault'));
      if (!await vaultDir.exists()) {
        await vaultDir.create(recursive: true);
      }

      final ext = p.extension(pickedPath).isNotEmpty ? p.extension(pickedPath) : '.pdf';
      final isPdf = ext.toLowerCase() == '.pdf';
      final fileName = '${_uuid.v4()}$ext';
      final targetPath = p.join(vaultDir.path, fileName);

      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final originalFile = File(pickedPath);
      // Strict Single File 10 MB Limit Enforcement, checked BEFORE loading bytes (OOM protection)
      final fileBytes = await originalFile.length();
      if (fileBytes > ProFeatureGate.kMaxSingleFileBytes) {
        state = state.copyWith(errorMessage: 'file_too_large_10mb');
        return null;
      }
      final rawBytes = await originalFile.readAsBytes();

      // Pro Feature Gate check (Free: max 5 docs, 50MB total; Pro: unlimited docs, 5GB total)
      final isPro = _ref.read(proSubscriptionProvider).isPro;
      final currentDocCount = state.documents.where((d) => !d.isDeleted).length;
      final totalVaultBytes = state.documents.where((d) => !d.isDeleted).fold<int>(0, (total, d) => total + d.fileSizeBytes);

      if (!ProFeatureGate.canAddVaultDocument(
        isPro: isPro,
        currentDocCount: currentDocCount,
        fileSizeBytes: fileBytes,
        totalVaultBytes: totalVaultBytes,
      )) {
        TelemetryService.instance.logProGateHit(
          featureKey: 'vault_limit',
          context: 'docs_${currentDocCount}_bytes_$totalVaultBytes',
        );
        state = state.copyWith(errorMessage: 'pro_vault_limit_reached');
        return null;
      }

      final encryptedBytes = await SecurityService.instance.encryptBytes(rawBytes, userId: currentUid);
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(encryptedBytes);

      final cleanExt = ext.replaceAll('.', '').toLowerCase();
      final now = DateTime.now();
      final newDoc = Document(
        id: _uuid.v4(),
        userId: currentUid,
        title: title,
        category: category,
        subCategory: subCategory,
        localImagePath: targetPath,
        tripId: tripId,
        fileType: isPdf ? 'pdf' : 'image',
        notes: notes,
        fileSizeBytes: fileBytes,
        fileExtension: cleanExt,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      await _dbHelper.insertDocument(newDoc);
      state = state.copyWith(
        documents: [newDoc, ...state.documents],
      );

      TelemetryService.instance.logDocumentUploaded(
        category: category,
        fileSizeBytes: fileBytes,
        fileExtension: ext,
      );

      // Eager cloud push & trigger background two-way sync
      unawaited(_eagerCloudSyncDocument(newDoc));
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}
      return newDoc;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// Adds an existing document directly (for manual entry or unit tests)
  Future<Document?> addDocument(Document doc) async {
    if (_prefs.getRestrictedFeatures().contains('vault_upload')) {
      state = state.copyWith(errorMessage: 'restricted_vault_upload');
      return null;
    }
    try {
      var fileBytes = doc.fileSizeBytes;
      if (fileBytes == 0 && doc.localImagePath.isNotEmpty) {
        try {
          final f = File(doc.localImagePath);
          if (f.existsSync()) {
            fileBytes = f.lengthSync();
          }
        } catch (_) {}
      }
      if (fileBytes > ProFeatureGate.kMaxSingleFileBytes) {
        state = state.copyWith(errorMessage: 'file_too_large_10mb');
        return null;
      }

      final isPro = _ref.read(proSubscriptionProvider).isPro;
      final currentDocCount = state.documents.where((d) => !d.isDeleted).length;
      final totalVaultBytes = state.documents.where((d) => !d.isDeleted).fold<int>(0, (total, d) => total + d.fileSizeBytes);

      if (!ProFeatureGate.canAddVaultDocument(
        isPro: isPro,
        currentDocCount: currentDocCount,
        fileSizeBytes: fileBytes,
        totalVaultBytes: totalVaultBytes,
      )) {
        TelemetryService.instance.logProGateHit(
          featureKey: 'vault_limit',
          context: 'docs_${currentDocCount}_bytes_$totalVaultBytes',
        );
        state = state.copyWith(errorMessage: 'pro_vault_limit_reached');
        return null;
      }

      var ext = doc.fileExtension;
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final effectiveUid = (doc.userId.isEmpty && currentUid.isNotEmpty) ? currentUid : doc.userId;
      if (ext == null || ext.isEmpty) {
        ext = p.extension(doc.localImagePath).replaceAll('.', '').toLowerCase();
        if (ext.isEmpty) ext = doc.isPdf ? 'pdf' : 'jpg';
      }
      final docToSave = doc.copyWith(
        userId: effectiveUid,
        fileSizeBytes: fileBytes,
        fileExtension: ext,
      );
      await _dbHelper.insertDocument(docToSave);
      state = state.copyWith(
        documents: [docToSave, ...state.documents],
      );
      TelemetryService.instance.logDocumentUploaded(
        category: docToSave.category,
        fileSizeBytes: fileBytes,
        fileExtension: p.extension(docToSave.localImagePath),
      );
      unawaited(_eagerCloudSyncDocument(docToSave));
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}
      return docToSave;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// Updates an existing document in SQLite and triggers background sync
  Future<Document?> updateDocument(Document updated) async {
    try {
      final docToSave = updated.copyWith(updatedAt: DateTime.now());
      await _dbHelper.updateDocument(docToSave);

      final index = state.documents.indexWhere((d) => d.id == updated.id);
      final updatedList = List<Document>.from(state.documents);
      if (index != -1) {
        updatedList[index] = docToSave;
      } else {
        updatedList.insert(0, docToSave);
      }

      state = state.copyWith(documents: updatedList);

      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

      return docToSave;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// Soft deletes a document, updates state, and triggers background sync
  Future<bool> deleteDocument(String docId) async {
    try {
      await _dbHelper.deleteDocument(docId);

      state = state.copyWith(
        documents: state.documents.where((d) => d.id != docId).toList(),
      );

      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Restores a soft-deleted document (enables Undo in UI)
  Future<bool> restoreDocument(Document doc) async {
    try {
      await _dbHelper.insertDocument(doc);
      state = state.copyWith(
        documents: [doc, ...state.documents],
      );
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

/// Global provider for VaultController
final vaultControllerProvider =
    StateNotifierProvider<VaultController, VaultState>((ref) {
  return VaultController(ref);
});
