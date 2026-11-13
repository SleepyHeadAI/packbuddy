import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/add_document_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

class FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  FakeVaultController([VaultState? state]) : super(state ?? const VaultState(isLoading: false, documents: []));

  @override
  bool isPinLockedOut() => false;

  @override
  int getPinLockoutRemainingSeconds() => 0;

  @override
  int getRemainingPinAttempts() => 5;

  @override
  Future<void> resetFailedPinAttempts() async {}

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
  Future<String?> encodeFileForCloud(String filePath, {String? userId}) async => null;

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
  Future<bool> authenticateWithBiometrics({String? reason}) async => true;

  @override
  Future<void> setBiometricEnabled(bool enabled) async {}

  @override
  void refreshSecurityState() {}
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
      expect(find.text('Güvenli Kasa'), findsWidgets);
      expect(find.text('Henüz kaydedilmiş belge yok'), findsOneWidget);
      expect(find.text('Belge Ekle'), findsWidgets);
      expect(find.text('Pasaport Slotu'), findsOneWidget);
    });

    testWidgets('VaultScreen renders "All" trip filter chip and removes redundant "General" chip', (tester) async {
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
            locale: Locale('en'),
            home: VaultScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify "All" filter chip exists (l10n.allFilter)
      expect(find.text('All'), findsWidgets);
      // Verify redundant "General" trip filter chip is removed
      expect(find.text('General'), findsNothing);
      expect(find.text('All Trips'), findsNothing);
    });

    testWidgets('VaultScreen passport slot preserves Passport identity even if document is titled Tickets', (tester) async {
      final doc = Document(
        id: 'doc-pass-1',
        title: 'Tickets', // Reproducing the issue reported by the user
        category: 'Passport',
        localImagePath: '/vault/pass.jpg',
        createdAt: DateTime(2026, 11, 12),
        updatedAt: DateTime(2026, 11, 12),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultControllerProvider.overrideWith(
              (ref) => FakeVaultController(VaultState(isLoading: false, documents: [doc])),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: VaultScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Top right slot should still retain 'Passport Slot' identity
      expect(find.text('Passport Slot'), findsOneWidget);
      // And show the document title in subtitle
      expect(find.textContaining('Tickets'), findsWidgets);
    });

    testWidgets('VaultScreen passport slot shows document title when title contains Passport', (tester) async {
      final doc = Document(
        id: 'doc-pass-2',
        title: 'My Passport',
        category: 'Passport',
        localImagePath: '/vault/pass.jpg',
        createdAt: DateTime(2026, 11, 12),
        updatedAt: DateTime(2026, 11, 12),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultControllerProvider.overrideWith(
              (ref) => FakeVaultController(VaultState(isLoading: false, documents: [doc])),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: VaultScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show 'My Passport' directly as title
      expect(find.text('My Passport'), findsWidgets);
    });

    testWidgets('AddDocumentSheet with isCategoryLocked: true locks category to Passport and does not allow selecting others', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(
              body: AddDocumentSheet(
                initialCategory: 'Passport',
                isCategoryLocked: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Category is locked to ID & Passport
      expect(find.text('ID & Passport'), findsWidgets);
      // Other categories are not selectable/present
      expect(find.text('Accommodation'), findsNothing);
      expect(find.text('Health & Insurance'), findsNothing);
      // Title defaults to My Passport
      expect(find.text('My Passport'), findsOneWidget);
    });

    testWidgets('Tapping passport slot when document exists opens options sheet without overflow on small screens', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final doc = Document(
        id: 'doc-pass-1',
        title: 'Brezilya Pasaportu',
        category: 'Passport',
        localImagePath: '/vault/pass.jpg',
        createdAt: DateTime(2026, 11, 12),
        updatedAt: DateTime(2026, 11, 12),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultControllerProvider.overrideWith(
              (ref) => FakeVaultController(VaultState(isLoading: false, documents: [doc])),
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

      // Tap on the passport slot (showing its title 'Brezilya Pasaportu')
      await tester.tap(find.text('Brezilya Pasaportu').first);
      await tester.pumpAndSettle();

      // Options sheet should appear
      expect(find.text('Belgeyi Görüntüle'), findsOneWidget);
      expect(find.textContaining('Değiştir'), findsOneWidget);
      expect(find.text('Belgeyi Sil'), findsOneWidget);
    });

    testWidgets('VaultScreen renders cleanly without overflows in German and Arabic (RTL) on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      for (final locale in [const Locale('de'), const Locale('ar')]) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              vaultControllerProvider.overrideWith(
                (ref) => FakeVaultController(const VaultState(isLoading: false, documents: [])),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              home: const VaultScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
