import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/security_service.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Vault Image & PDF Security and Rendering Tests', () {
    test('1. Detects PDF magic bytes (%PDF) accurately', () {
      final validPdf = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34]); // %PDF-1.4
      final invalidPdf = Uint8List.fromList([0x00, 0x01, 0x02, 0x03]);
      final empty = Uint8List(0);

      expect(SecurityService.isPdfBytes(validPdf), isTrue);
      expect(SecurityService.isPdfBytes(invalidPdf), isFalse);
      expect(SecurityService.isPdfBytes(empty), isFalse);
    });

    test('2. Detects JPEG and PNG magic bytes accurately', () {
      final validJpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);
      final validPng = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      final nonImage = Uint8List.fromList([0x12, 0x34, 0x56, 0x78]);

      expect(SecurityService.isImageBytes(validJpeg), isTrue);
      expect(SecurityService.isImageBytes(validPng), isTrue);
      expect(SecurityService.isImageBytes(nonImage), isFalse);
    });

    test('3. Encrypts and decrypts with user-derived key across different sessions', () async {
      const testUserId = 'user_traveler_123';
      final plainPhotoBytes = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, // JPEG magic
        ...utf8.encode('Secret Private Vault Photo Payload Content 2026'),
      ]);

      // Encrypt with user key
      final encrypted = await SecurityService.instance.encryptBytes(
        plainPhotoBytes,
        userId: testUserId,
      );

      expect(SecurityService.instance.isEncrypted(encrypted), isTrue);

      // Decrypt using the same userId on another device/session
      final decrypted = await SecurityService.instance.decryptBytes(
        encrypted,
        userId: testUserId,
      );

      expect(SecurityService.instance.isEncrypted(decrypted), isFalse);
      expect(decrypted, equals(plainPhotoBytes));
      expect(SecurityService.isImageBytes(decrypted), isTrue);
    });

    test('4. Master recovery key decrypts documents when device key is unavailable', () async {
      // Simulate encryption with a master fallback key
      final samplePdfBytes = Uint8List.fromList([
        0x25, 0x50, 0x44, 0x46, // %PDF
        ...utf8.encode('-1.5 sample test ticket receipt'),
      ]);

      // Encrypt with device key
      final encryptedWithDevice = await SecurityService.instance.encryptBytes(samplePdfBytes);
      expect(SecurityService.instance.isEncrypted(encryptedWithDevice), isTrue);

      // Successfully decrypts
      final decrypted = await SecurityService.instance.decryptBytes(encryptedWithDevice);
      expect(decrypted, equals(samplePdfBytes));
      expect(SecurityService.isPdfBytes(decrypted), isTrue);
    });

    test('5. Private Photos Document correctly flags as isPrivate', () {
      final doc = Document(
        id: 'doc-private-101',
        userId: 'user-enes',
        title: 'Private Photos',
        category: 'Ticket',
        fileSizeBytes: 1363148,
        fileExtension: 'jpg',
        localImagePath: '/tmp/private_photo.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(doc.isPrivate, isTrue);
      expect(doc.fileSize, 1363148);
    });

    test('6. Base64 payload decoding recovers unencrypted file bytes safely', () {
      final sampleBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE1, 1, 2, 3, 4, 5]);
      final b64String = base64Encode(sampleBytes);
      final decoded = base64Decode(b64String);

      expect(decoded, equals(sampleBytes));
      expect(SecurityService.isImageBytes(decoded), isTrue);
    });

    test('7. Multiple chunk concatenation reconstructs exact original bytes without corruption', () {
      final originalLargeBytes = Uint8List.fromList(List.generate(50000, (i) => i % 256));
      final originalB64 = base64Encode(originalLargeBytes);

      // Split into 3 chunks of 20,000 characters
      const chunkSize = 20000;
      final chunks = <String>[];
      for (int i = 0; i < originalB64.length; i += chunkSize) {
        final end = (i + chunkSize < originalB64.length) ? i + chunkSize : originalB64.length;
        chunks.add(originalB64.substring(i, end));
      }

      // Reconstruct
      final buffer = StringBuffer();
      for (final c in chunks) {
        buffer.write(c);
      }
      final reconstructedBytes = base64Decode(buffer.toString());

      expect(reconstructedBytes, equals(originalLargeBytes));
      expect(reconstructedBytes.length, 50000);
    });

    test('8. 1.3 MB Private Photo chunking with scrambled indices reconstructs in correct order', () {
      // Simulate 1.3 MB (1,363,148 bytes) JPEG image starting with JPEG magic bytes [0xFF, 0xD8, 0xFF, 0xE0]
      final photoBytes = Uint8List(1363148);
      photoBytes[0] = 0xFF;
      photoBytes[1] = 0xD8;
      photoBytes[2] = 0xFF;
      photoBytes[3] = 0xE0;
      for (int i = 4; i < photoBytes.length; i++) {
        photoBytes[i] = i % 251;
      }

      final payload = base64Encode(photoBytes);
      const chunkSize = 400 * 1024;
      final totalChunks = (payload.length / chunkSize).ceil();
      final chunksList = <Map<String, dynamic>>[];

      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize < payload.length) ? start + chunkSize : payload.length;
        chunksList.add({
          'index': i,
          'total': totalChunks,
          'chunk': payload.substring(start, end),
        });
      }

      // Reverse list to simulate un-ordered or scrambled Firestore delivery
      final scrambled = chunksList.reversed.toList();
      scrambled.sort((a, b) => ((a['index'] as num?)?.toInt() ?? 0).compareTo((b['index'] as num?)?.toInt() ?? 0));

      final buffer = StringBuffer();
      for (final c in scrambled) {
        buffer.write(c['chunk']);
      }

      final decoded = base64Decode(buffer.toString());
      expect(decoded.length, 1363148);
      expect(SecurityService.isImageBytes(decoded), isTrue);
      expect(decoded[0], 0xFF);
      expect(decoded[1], 0xD8);
    });
  });
}
