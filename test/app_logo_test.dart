import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/shared/widgets/app_logo.dart';

void main() {
  group('AppLogo Asset Existence & Verification Tests', () {
    test('Logo asset files exist in assets/images/ with non-zero size', () {
      final normalFile = File(AppLogo.normalAsset);
      final transparentFile = File(AppLogo.transparentAsset);

      expect(normalFile.existsSync(), isTrue, reason: 'assets/images/logo_normal.png must exist');
      expect(normalFile.lengthSync(), greaterThan(1000), reason: 'Normal logo file must not be empty');

      expect(transparentFile.existsSync(), isTrue, reason: 'assets/images/logo_transparent.png must exist');
      expect(transparentFile.lengthSync(), greaterThan(1000), reason: 'Transparent logo file must not be empty');
    });

    testWidgets('AppLogo.normal renders Image widget with normal asset', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLogo.normal(size: 64),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect((imageWidget.image as AssetImage).assetName, equals(AppLogo.normalAsset));
      expect(imageWidget.width, equals(64));
      expect(imageWidget.height, equals(64));
    });

    testWidgets('AppLogo.transparent renders Image widget with transparent asset', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLogo.transparent(size: 48),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect((imageWidget.image as AssetImage).assetName, equals(AppLogo.transparentAsset));
      expect(imageWidget.width, equals(48));
      expect(imageWidget.height, equals(48));
    });

    testWidgets('AppLogo defaults to transparent in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: AppLogo(size: 32),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect((imageWidget.image as AssetImage).assetName, equals(AppLogo.transparentAsset));
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

