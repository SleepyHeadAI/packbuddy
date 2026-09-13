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
  Future<void> loadDocuments() async {}

  @override
  Future<Document?> pickAndAddDocument({
    required ImageSource source,
    required String title,
    required String category,
  }) async => null;

  @override
  Future<Document?> addDocument(Document doc) async => doc;

  @override
  Future<bool> deleteDocument(String docId) async => true;
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
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      // JSON (Firestore) serialization
      final json = doc.toJson();
      expect(json['id'], 'doc-123');
      expect(json['title'], 'Passport Scan');
      expect(json['category'], 'Passport');
      expect(json['isDeleted'], false);

      final fromJsonDoc = Document.fromJson(json);
      expect(fromJsonDoc.id, doc.id);
      expect(fromJsonDoc.title, doc.title);
      expect(fromJsonDoc.localImagePath, doc.localImagePath);

      // SQLite Map serialization
      final map = doc.toMap();
      expect(map['id'], 'doc-123');
      expect(map['local_image_path'], doc.localImagePath);
      expect(map['is_deleted'], 0);

      final fromMapDoc = Document.fromMap(map);
      expect(fromMapDoc.id, doc.id);
      expect(fromMapDoc.isDeleted, false);

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
    });
  });
}
