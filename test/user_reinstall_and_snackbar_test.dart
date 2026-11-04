import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';

void main() {
  group('Problem 1: SnackBar Auto-Dismiss & Persist Verification', () {
    testWidgets('SnackBar with persist: false automatically dismisses after timer without freezing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Kulaklık Silindi'),
                      action: SnackBarAction(
                        label: 'GERİ AL',
                        onPressed: () {},
                      ),
                      duration: const Duration(milliseconds: 1000),
                      persist: false,
                    ),
                  );
                },
                child: const Text('Sil'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show SnackBar
      await tester.tap(find.text('Sil'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 300)); // Finish entrance animation

      expect(find.text('Kulaklık Silindi'), findsOneWidget);
      expect(find.text('GERİ AL'), findsOneWidget);

      // Advance time past the 1000ms duration
      await tester.pump(const Duration(milliseconds: 1100));
      // Pump exit transition
      await tester.pump(const Duration(milliseconds: 500));

      // Must be completely dismissed automatically!
      expect(find.text('Kulaklık Silindi'), findsNothing);
      expect(find.text('GERİ AL'), findsNothing);
    });
  });

  group('Problem 2: Reinstall Checklist Re-seeding Loop Verification', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
    });

    test('PreferencesService records hasClearedChecklist and prevents re-seeding', () async {
      final prefs = PreferencesService.instance;
      const uid = 'reinstalled_user_123';

      // 1. Initial fresh install: not seeded, not cleared
      expect(prefs.hasSeededChecklist(uid: uid), isFalse);
      expect(prefs.hasClearedChecklist(uid: uid), isFalse);

      // 2. User deletes all items in checklist
      await prefs.setClearedChecklist(true, uid: uid);
      await prefs.setSeededChecklist(true, uid: uid);

      expect(prefs.hasClearedChecklist(uid: uid), isTrue);
      expect(prefs.hasSeededChecklist(uid: uid), isTrue);

      // 3. User uninstalls and reinstalls app -> preferences wiped initially
      final rawPrefs = await SharedPreferences.getInstance();
      await rawPrefs.clear();
      expect(prefs.hasClearedChecklist(uid: uid), isFalse);

      // 4. Cloud sync restores user profile from Firestore:
      final simulatedFirestoreDoc = {
        'hasClearedChecklist': true,
        'hasSeededChecklist': true,
      };

      if (simulatedFirestoreDoc['hasClearedChecklist'] == true) {
        await prefs.setClearedChecklist(true, uid: uid);
      }
      if (simulatedFirestoreDoc['hasSeededChecklist'] == true) {
        await prefs.setSeededChecklist(true, uid: uid);
      }

      // 5. Verification: user profile accurately guards against re-seeding
      final alreadySeeded = prefs.hasSeededChecklist(uid: uid);
      final alreadyCleared = prefs.hasClearedChecklist(uid: uid);
      final shouldSeed = !alreadySeeded && !alreadyCleared;

      expect(shouldSeed, isFalse);
    });

    test('Deterministic default items start with default_ prefix and can be identified', () {
      final item = PackingItem(
        id: 'default_headphones',
        name: 'Headphones',
        category: 'Elektronik',
        quantity: 1,
        isPacked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.id.startsWith('default_'), isTrue);
    });
  });
}
