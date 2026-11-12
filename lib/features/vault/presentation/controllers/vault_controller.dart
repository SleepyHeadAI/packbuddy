import 'dart:async';
import 'dart:convert';
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
  Future<String?> encodeFileForCloud(String filePath, {String? userId}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      var bytes = await file.readAsBytes();
      if (SecurityService.instance.isEncrypted(bytes)) {
        bytes = await SecurityService.instance.decryptBytes(bytes, userId: userId);
      }
      const maxCloudBytes = 750 * 1024;
      if (bytes.length <= maxCloudBytes) {
        return base64Encode(bytes);
      } else {
        // Never corrupt binary files by byte-slicing!
        // Large files are safely preserved in local offline storage and chunked by sync engine.
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Eagerly writes document metadata and raw bytes/chunks directly to Firestore
  /// so Admin and other devices immediately have access without waiting for full sync loop
  Future<void> _eagerCloudSyncDocument(Document doc, Uint8List rawBytes) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) return;
      final firestore = FirebaseFirestore.instance;

      const maxDirectBytes = 750 * 1024;
      if (rawBytes.length <= maxDirectBytes) {
        final payload = base64Encode(rawBytes);
        await firestore.collection('documents').doc(doc.id).set(
          doc.copyWith(userId: uid, cloudDataBase64: payload).toJson(),
          SetOptions(merge: true),
        );
      } else {
        // Large document (>750KB e.g. 1.3MB camera photo): upload doc metadata with empty cloudDataBase64
        // and immediately upload chunked subcollection into documents/{id}/chunks
        await firestore.collection('documents').doc(doc.id).set(
          doc.copyWith(userId: uid, cloudDataBase64: '').toJson(),
          SetOptions(merge: true),
        );
        final payload = base64Encode(rawBytes);
        const chunkSize = 400 * 1024;
        final totalChunks = (payload.length / chunkSize).ceil();
        final batch = firestore.batch();
        for (int i = 0; i < totalChunks; i++) {
          final start = i * chunkSize;
          final end = (start + chunkSize < payload.length) ? start + chunkSize : payload.length;
          final chunkStr = payload.substring(start, end);
          batch.set(
            firestore.collection('documents').doc(doc.id).collection('chunks').doc('chunk_$i'),
            {
              'index': i,
              'total': totalChunks,
              'chunk': chunkStr,
              'updated_at': doc.updatedAt.millisecondsSinceEpoch,
            },
            SetOptions(merge: true),
          );
        }
        await batch.commit();
      }
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

    final savedPin = _prefs.getVaultPin();
    if (savedPin != null && savedPin == pin) {
      _prefs.setVaultLocked(false);
      _prefs.resetVaultFailedPinAttempts();
      state = state.copyWith(isLocked: false);
      return true;
    }

    _prefs.recordVaultFailedPinAttempt();
    return false;
  }

  /// Checks if vault PIN entry is temporarily locked out due to >= 5 failed attempts in 10 mins
  bool isPinLockedOut() => _prefs.isVaultPinLockedOut();

  /// Gets remaining lockout seconds (0 if not locked out)
  int getPinLockoutRemainingSeconds() => _prefs.getVaultPinLockoutRemainingSeconds();

  /// Gets remaining allowed attempts before lockout (from 5 down to 0)
  int getRemainingPinAttempts() {
    final count = _prefs.getRecentVaultFailedPinAttemptsCount();
    return (PreferencesService.vaultMaxFailedPinAttempts - count).clamp(0, PreferencesService.vaultMaxFailedPinAttempts);
  }

  /// Clears failed attempt history
  Future<void> resetFailedPinAttempts() async {
    await _prefs.resetVaultFailedPinAttempts();
  }

  /// Manually locks the vault immediately
  void lockVault() {
    _prefs.setVaultLocked(true);
    state = state.copyWith(isLocked: true);
  }

  /// Sets a new PIN code for vault protection and syncs to cloud
  Future<void> setPin(String pin) async {
    await _prefs.setVaultPin(pin);
    await _prefs.resetVaultFailedPinAttempts();
    state = state.copyWith(hasPin: true);
    await _syncSecuritySettingsToCloud(pin: pin, updatePin: true);
  }

  /// Removes the vault PIN code and locks the vault until a new PIN is set
  Future<void> removePin() async {
    await _prefs.setVaultPin(null);
    await _prefs.setVaultLocked(true);
    state = state.copyWith(hasPin: false, isLocked: true);
    await _syncSecuritySettingsToCloud(pin: null, updatePin: true);
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

  /// Refreshes PIN and biometric availability without altering the active session lock state
  void refreshSecurityState() {
    state = state.copyWith(
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

      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final originalFile = File(pickedFile.path);
      final rawBytes = await originalFile.readAsBytes();
      final encryptedBytes = await SecurityService.instance.encryptBytes(rawBytes, userId: currentUid);
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(encryptedBytes);
      final fileBytes = rawBytes.length;

      // 3. Create Document entity with cloud payload
      final cleanExt = ext.replaceAll('.', '').toLowerCase();
      final cloudData = await encodeFileForCloud(targetPath, userId: currentUid);
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

      // 7. Eager cloud push & trigger background two-way sync
      unawaited(_eagerCloudSyncDocument(newDoc, rawBytes));
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
      final rawBytes = await originalFile.readAsBytes();
      final encryptedBytes = await SecurityService.instance.encryptBytes(rawBytes, userId: currentUid);
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(encryptedBytes);
      final fileBytes = rawBytes.length;

      final cleanExt = ext.replaceAll('.', '').toLowerCase();
      final cloudData = await encodeFileForCloud(targetPath, userId: currentUid);
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

      // Eager cloud push & trigger background two-way sync
      unawaited(_eagerCloudSyncDocument(newDoc, rawBytes));
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
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final effectiveUid = (doc.userId.isEmpty && currentUid.isNotEmpty) ? currentUid : doc.userId;
      if ((cloudData == null || cloudData.isEmpty) && doc.localImagePath.isNotEmpty) {
        cloudData = await encodeFileForCloud(doc.localImagePath, userId: effectiveUid);
      }
      if (ext == null || ext.isEmpty) {
        ext = p.extension(doc.localImagePath).replaceAll('.', '').toLowerCase();
        if (ext.isEmpty) ext = doc.isPdf ? 'pdf' : 'jpg';
      }
      final docToSave = doc.copyWith(
        userId: effectiveUid,
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
      if (docToSave.cloudDataBase64 != null && docToSave.cloudDataBase64!.isNotEmpty) {
        try {
          unawaited(_eagerCloudSyncDocument(docToSave, base64Decode(docToSave.cloudDataBase64!)));
        } catch (_) {}
      } else if (docToSave.localImagePath.isNotEmpty) {
        try {
          final f = File(docToSave.localImagePath);
          if (f.existsSync()) {
            final rawBytes = f.readAsBytesSync();
            final bytesToSync = SecurityService.instance.isEncrypted(rawBytes)
                ? await SecurityService.instance.decryptBytes(rawBytes, userId: docToSave.userId)
                : rawBytes;
            unawaited(_eagerCloudSyncDocument(docToSave, bytesToSync));
          }
        } catch (_) {}
      }
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
