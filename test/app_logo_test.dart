import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/shared/widgets/app_logo.dart';

String _assetOf(WidgetTester tester) =>
    (tester.widget<Image>(find.byType(Image)).image as AssetImage).assetName;

void main() {
  group('AppLogo Asset Existence & Verification Tests', () {
    test('Brand logo assets exist in assets/images/ with non-zero size', () {
      for (final path in [AppLogo.forDarkAsset, AppLogo.forLightAsset]) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: '$path must exist');
        expect(file.lengthSync(), greaterThan(1000), reason: '$path must not be empty');
      }
    });

    testWidgets('AppLogo uses the terracotta mark on light themes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLogo(size: 64))),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(_assetOf(tester), equals(AppLogo.forLightAsset));
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.width, equals(64));
      expect(imageWidget.height, equals(64));
    });

    testWidgets('AppLogo uses the off-white mark on dark themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: AppLogo(size: 32)),
        ),
      );

      expect(_assetOf(tester), equals(AppLogo.forDarkAsset));
    });

    testWidgets('AppLogo.transparent follows the theme like AppLogo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLogo.transparent(size: 48))),
      );
      expect(_assetOf(tester), equals(AppLogo.forLightAsset));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(body: AppLogo.transparent(size: 48)),
        ),
      );
      await tester.pumpAndSettle(); // MaterialApp animates theme changes
      expect(_assetOf(tester), equals(AppLogo.forDarkAsset));
    });

    testWidgets('AppLogo supports hero animations', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLogo.transparent(size: 40, heroTag: 'test-hero'),
          ),
        ),
      );

      expect(find.byType(Hero), findsOneWidget);
    });
  });
}
