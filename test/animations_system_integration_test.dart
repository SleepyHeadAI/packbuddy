import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/shared/widgets/app_animations.dart';

void main() {
  group('PackBuddy Animation System Integration Tests', () {
    testWidgets('AnimatedStrikethroughText renders cleanly across LTR and RTL directions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: AnimatedStrikethroughText(
                    text: 'Passport & Flight Tickets',
                    isCrossed: true,
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: AnimatedStrikethroughText(
                    text: 'تذكرة الطيران وجواز السفر',
                    isCrossed: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Passport & Flight Tickets'), findsOneWidget);
      expect(find.text('تذكرة الطيران وجواز السفر'), findsOneWidget);
    });

    testWidgets('AnimatedCurrencyCounter renders formatted currencies without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedCurrencyCounter(
                  value: 1250.50,
                  currency: 'EUR',
                ),
                AnimatedCurrencyCounter(
                  value: 45000.0,
                  currency: 'TRY',
                ),
                AnimatedCurrencyCounter(
                  value: 99.99,
                  currency: 'USD',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AnimatedCurrencyCounter), findsNWidgets(3));
    });

    testWidgets('AppShakeTransition mounts and animates on error trigger', (tester) async {
      bool isError = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: AppShakeTransition(
                  shake: isError,
                  child: const Text('PIN dots indicator'),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => setState(() => isError = true),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('PIN dots indicator'), findsOneWidget);

      // Trigger shake
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('PIN dots indicator'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('PIN dots indicator'), findsOneWidget);
    });

    testWidgets('AppFloatingIllustration renders and maintains child semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppFloatingIllustration(
              child: Icon(Icons.luggage_rounded, size: 40),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.luggage_rounded), findsOneWidget);
    });

    testWidgets('AppFadeSlide.staggered accurately offsets delay per index', (tester) async {
      final item0 = AppFadeSlide.staggered(
        index: 0,
        child: const Text('Item 0'),
      );
      final item3 = AppFadeSlide.staggered(
        index: 3,
        baseDelay: const Duration(milliseconds: 50),
        child: const Text('Item 3'),
      );

      expect(item0.delay, Duration.zero);
      expect(item3.delay, const Duration(milliseconds: 150));
    });
  });
}
