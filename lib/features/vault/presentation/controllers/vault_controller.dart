import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          hasPin: (prefs ?? PreferencesService.instance).getVaultPin() != null,
          isBiometricEnabled: (prefs ?? PreferencesService.instance).isVaultBiometricEnabled(),
        )) {
    loadDocuments();
  }

  /// Encodes file bytes into base64 payload safely for cloud sync without byte truncation
  Future<String?> encodeFileForCloud(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      const maxCloudBytes = 750 * 1024;
      if (bytes.length <= maxCloudBytes) {
        return base64Encode(bytes);
      } else {
        // Never corrupt binary files by byte-slicing!
        // Large files are safely preserved in local offline storage.
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Attempts to unlock the vault using a PIN code
  bool unlockVault(String pin) {
    final savedPin = _prefs.getVaultPin();
    if (savedPin == null || savedPin == pin) {
      _prefs.setVaultLocked(false);
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  /// Manually locks the vault immediately
  void lockVault() {
    _prefs.setVaultLocked(true);
    state = state.copyWith(isLocked: true);
  }

  /// Sets a new PIN code for vault protection and syncs to cloud
  Future<void> setPin(String pin) async {
    await _prefs.setVaultPin(pin);
    state = state.copyWith(hasPin: true);
    await _syncSecuritySettingsToCloud(pin: pin, updatePin: true);
  }

  /// Removes the vault PIN code and syncs to cloud
  Future<void> removePin() async {
    await _prefs.setVaultPin(null);
    await _prefs.setVaultLocked(false);
    state = state.copyWith(hasPin: false, isLocked: false);
    await _syncSecuritySettingsToCloud(pin: null, updatePin: true);
  }

  /// Unlocks the vault via real biometric verification (Fingerprint / Face ID)
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    final success = await BiometricService.instance.authenticate(
      localizedReason: reason ?? 'Kasanın kilidini açmak için parmak izinizi doğrulayın',
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

  /// Synchronizes security settings (PIN code and biometric enablement) to Firestore cloud
  Future<void> _syncSecuritySettingsToCloud({
    String? pin,
    bool updatePin = false,
    bool? biometricEnabled,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };
      if (updatePin) {
        data['vaultPin'] = pin;
        data['vaultPinUpdatedAt'] = DateTime.now().toUtc().toIso8601String();
      }
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

  /// Refreshes security lock, pin, and biometric state when account changes or cloud sync completes
  void refreshSecurityState() {
    state = state.copyWith(
      isLocked: _prefs.isVaultLocked(),
      hasPin: _prefs.getVaultPin() != null,
      isBiometricEnabled: _prefs.isVaultBiometricEnabled(),
    );
  }

  /// Resets controller state on logout or account switch
  void resetState() {
    state = VaultState(
      isLocked: _prefs.isVaultLocked(),
      hasPin: _prefs.getVaultPin() != null,
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
      // 1. Pick image (safe null check if user cancels, optimized resolution for cloud storage)
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (pickedFile == null) {
        // User cancelled selection - return gracefully without error
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

      final originalFile = File(pickedFile.path);
      await originalFile.copy(targetPath);

      var fileBytes = 0;
      try {
        final targetFile = File(targetPath);
        if (await targetFile.exists()) {
          fileBytes = await targetFile.length();
        }
      } catch (_) {}

      // 3. Create Document entity with cloud payload
      final cleanExt = ext.replaceAll('.', '').toLowerCase();
      final cloudData = await encodeFileForCloud(targetPath);
      final now = DateTime.now();
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
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
        cloudDataBase64: cloudData,
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

      // 7. Trigger background two-way sync
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

      final originalFile = File(pickedPath);
      await originalFile.copy(targetPath);

      var fileBytes = 0;
      try {
        final targetFile = File(targetPath);
        if (await targetFile.exists()) {
          fileBytes = await targetFile.length();
        }
      } catch (_) {}

      final cleanExt = ext.replaceAll('.', '').toLowerCase();
      final cloudData = await encodeFileForCloud(targetPath);
      final now = DateTime.now();
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
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
        cloudDataBase64: cloudData,
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
      var cloudData = doc.cloudDataBase64;
      var ext = doc.fileExtension;
      if ((cloudData == null || cloudData.isEmpty) && doc.localImagePath.isNotEmpty) {
        cloudData = await encodeFileForCloud(doc.localImagePath);
      }
      if (ext == null || ext.isEmpty) {
        ext = p.extension(doc.localImagePath).replaceAll('.', '').toLowerCase();
        if (ext.isEmpty) ext = doc.isPdf ? 'pdf' : 'jpg';
      }
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final docToSave = doc.copyWith(
        userId: (doc.userId.isEmpty && currentUid.isNotEmpty) ? currentUid : doc.userId,
        fileSizeBytes: fileBytes,
        cloudDataBase64: cloudData,
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
