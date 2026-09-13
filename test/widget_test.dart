import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/main.dart';

void main() {
  testWidgets('PackBuddy smoke test and dashboard render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PackBuddyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the title and welcome messages are present
    expect(find.text('PackBuddy'), findsWidgets);
    expect(find.text("PackBuddy'ye Hoş Geldiniz"), findsOneWidget);
  });
}
