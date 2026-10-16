import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  FakeVaultController([VaultState? state]) : super(state ?? const VaultState(isLoading: false, documents: []));

  @override
  void resetState() {}

  @override
  Future<void> loadDocuments({String? tripId, String? userId}) async {}

  @override
  Future<Document?> pickAndAddDocument({
    required ImageSource source,
    required String title,
    required String category,
    String? subCategory,
    String? tripId,
    String? notes,
  }) async => null;

  @override
  Future<Document?> pickAndAddFileDocument({
    required String title,
    required String category,
    String? subCategory,
    String? tripId,
    String? notes,
  }) async => null;

  @override
  Future<Document?> addDocument(Document doc) async => doc;

  @override
  Future<String?> encodeFileForCloud(String filePath) async => null;

  @override
  Future<Document?> updateDocument(Document updated) async => updated;

  @override
  Future<bool> deleteDocument(String docId) async => true;

  @override
  Future<bool> restoreDocument(Document doc) async => true;

  @override
  bool unlockVault(String pin) => true;

  @override
  void lockVault() {}

  @override
  Future<void> setPin(String pin) async {}

  @override
  Future<void> removePin() async {}

  @override
  bool authenticateWithBiometrics() => true;
}

void main() {
  group('Document Model Tests', () {
    test('Document serialization and deserialization (JSON & SQLite Map)', () {
      final now = DateTime.now();
      final doc = Document(
        id: 'doc-123',
        title: 'Passport Scan',
        category: 'Passport',
        localImagePath: '/data/user/0/com.sleepyhead.packbuddy/vault/pass.jpg',
        tripId: 'trip-abc',
        fileType: 'image',
        notes: 'Geçerlilik 2030',
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      expect(doc.isPdf, false);

      // JSON (Firestore) serialization
      final json = doc.toJson();
      expect(json['id'], 'doc-123');
      expect(json['title'], 'Passport Scan');
      expect(json['category'], 'Passport');
      expect(json['tripId'], 'trip-abc');
      expect(json['fileType'], 'image');
      expect(json['notes'], 'Geçerlilik 2030');
      expect(json['isDeleted'], false);

      final fromJsonDoc = Document.fromJson(json);
      expect(fromJsonDoc.id, doc.id);
      expect(fromJsonDoc.title, doc.title);
      expect(fromJsonDoc.localImagePath, doc.localImagePath);
      expect(fromJsonDoc.tripId, 'trip-abc');
      expect(fromJsonDoc.fileType, 'image');

      // SQLite Map serialization
      final map = doc.toMap();
      expect(map['id'], 'doc-123');
      expect(map['local_image_path'], doc.localImagePath);
      expect(map['trip_id'], 'trip-abc');
      expect(map['file_type'], 'image');
      expect(map['is_deleted'], 0);

      final fromMapDoc = Document.fromMap(map);
      expect(fromMapDoc.id, doc.id);
      expect(fromMapDoc.tripId, 'trip-abc');
      expect(fromMapDoc.isDeleted, false);

      // PDF detection test
      final pdfDoc = doc.copyWith(
        localImagePath: '/vault/ticket.pdf',
        fileType: 'pdf',
      );
      expect(pdfDoc.isPdf, true);

      // Soft delete copyWith
      final deletedDoc = doc.copyWith(isDeleted: true);
      expect(deletedDoc.isDeleted, true);
      expect(deletedDoc.toMap()['is_deleted'], 1);
    });
  });

  group('VaultScreen Widget Tests', () {
    testWidgets('Renders empty vault screen properly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultControllerProvider.overrideWith(
              (ref) => FakeVaultController(const VaultState(isLoading: false, documents: [])),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('tr'),
            home: VaultScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify title and empty state text are present
      expect(find.text('Belge Kasası'), findsWidgets);
      expect(find.text('Henüz kaydedilmiş belge yok'), findsOneWidget);
      expect(find.text('Belge Ekle'), findsWidgets);
      expect(find.text('Pasaport Slotu'), findsOneWidget);
    });
  });
}
