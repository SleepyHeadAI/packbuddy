import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/profile/domain/animal_avatar.dart';
import 'package:packbuddy/features/profile/presentation/widgets/animal_avatar_widget.dart';

void main() {
  group('AnimalAvatar Animation & Rendering Suite', () {
    testWidgets('Renders all 20 cute animal avatars without error', (tester) async {
      for (final animal in AnimalAvatar.all) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: AnimalAvatarWidget(
                  avatar: animal,
                  size: 96,
                  isAnimated: false,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(AnimalAvatarWidget), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Rendering failed for ${animal.id}');
      }
    });

    testWidgets('Renders at multiple animation progress phases (idle, blink, smile & wink)', (tester) async {
      final phases = [
        0.0,  // Idle breathing
        0.20, // Natural double blink
        0.35, // Ear wiggle
        0.70, // Sweet smile, playful wink & floating heart
        0.95, // Calming down
      ];

      for (final animal in AnimalAvatar.all) {
        for (final phase in phases) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: AnimalFacePainter(
                      avatarId: animal.id,
                      accentColor: animal.accentColor,
                      progress: phase,
                    ),
                  ),
                ),
              ),
            ),
          );

          expect(tester.takeException(), isNull,
              reason: 'Animation phase $phase failed for ${animal.id}');
        }
      }
    });

    testWidgets('AnimalFacePainter shouldRepaint triggers correctly on changes', (tester) async {
      final painter1 = AnimalFacePainter(
        avatarId: 'animal_cat',
        accentColor: Colors.pink,
        progress: 0.1,
      );
      final painterSame = AnimalFacePainter(
        avatarId: 'animal_cat',
        accentColor: Colors.pink,
        progress: 0.1,
      );
      final painterDiffProgress = AnimalFacePainter(
        avatarId: 'animal_cat',
        accentColor: Colors.pink,
        progress: 0.7,
      );
      final painterDiffAnimal = AnimalFacePainter(
        avatarId: 'animal_dog',
        accentColor: Colors.pink,
        progress: 0.1,
      );

      expect(painterSame.shouldRepaint(painter1), isFalse);
      expect(painterDiffProgress.shouldRepaint(painter1), isTrue);
      expect(painterDiffAnimal.shouldRepaint(painter1), isTrue);
    });

    testWidgets('AnimalAvatarWidget triggers onTap callback with tactile feedback', (tester) async {
      bool tapped = false;
      final cat = AnimalAvatar.findById('animal_cat')!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimalAvatarWidget(
                avatar: cat,
                size: 80,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      final avatarFinder = find.byType(AnimalAvatarWidget);
      expect(avatarFinder, findsOneWidget);

      await tester.tap(avatarFinder);
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
