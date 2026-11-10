import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/navigation_provider.dart';
import 'package:packbuddy/features/feedback/data/feedback_service.dart';
import 'package:packbuddy/features/feedback/domain/feedback_localization.dart';
import 'package:packbuddy/features/feedback/presentation/screens/admin_feedback_screen.dart';
import 'package:packbuddy/features/feedback/presentation/widgets/feedback_sheet.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Clean UI & Footer Verification', () {
    testWidgets('DashboardScreen does not show dev phase banner at bottom', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Faz 5'), findsNothing);
      expect(find.textContaining('Phase 5'), findsNothing);
    });

    testWidgets('SettingsScreen footer does not show SleepyHead INC. watermark', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('SleepyHead INC. CO.'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('PackBuddy v1.0.0'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('PackBuddy v1.0.0'), findsOneWidget);
    });
  });

  group('Feedback & Suggestion Service & Localization Suite', () {
    const all20Languages = [
      'en', 'tr', 'de', 'es', 'fr', 'it', 'pt', 'ru', 'zh', 'ja',
      'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi'
    ];

    test('All 20 languages provide full localization for feedback', () {
      for (final lang in all20Languages) {
        expect(FeedbackL10n.getTitle(lang), isNotEmpty);
        expect(FeedbackL10n.getSubtitle(lang), isNotEmpty);
        expect(FeedbackL10n.getInputHint(lang), isNotEmpty);
        expect(FeedbackL10n.getAttachImage(lang), isNotEmpty);
        expect(FeedbackL10n.getSubmit(lang), isNotEmpty);
        expect(FeedbackL10n.getSuccess(lang), isNotEmpty);
        expect(FeedbackL10n.getEmptyError(lang), isNotEmpty);
        expect(FeedbackL10n.getAdminTitle(lang), isNotEmpty);
        expect(FeedbackL10n.getAdminNoFeedback(lang), isNotEmpty);
      }
    });

    test('FeedbackService rejects empty or text exceeding 1000 characters and accepts valid', () async {
      final resEmpty = await FeedbackService.instance.submitFeedback(message: '   ');
      expect(resEmpty, isFalse);

      final tooLong = 'A' * 1001;
      final resTooLong = await FeedbackService.instance.submitFeedback(message: tooLong);
      expect(resTooLong, isFalse);

      const validText = 'PackBuddy is amazing! Would love to see offline currency charts.';
      final resValid = await FeedbackService.instance.submitFeedback(
        message: validText,
        userEmail: 'traveler@packbuddy.com',
      );
      expect(resValid, isTrue);

      final list = await FeedbackService.instance.getAllFeedback();
      expect(list.any((f) => f.message == validText), isTrue);
    });

    testWidgets('FeedbackSheet renders with character counter and attachment button in Turkish', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FeedbackSheet(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(FeedbackL10n.getTitle('tr')), findsOneWidget);
      expect(find.text('0 / 1000'), findsOneWidget);
      expect(find.text(FeedbackL10n.getAttachImage('tr')), findsOneWidget);
      expect(find.text(FeedbackL10n.getSubmit('tr')), findsOneWidget);

      // Type some characters
      await tester.enterText(find.byType(TextField), 'Harika bir uygulama!');
      await tester.pump();

      expect(find.text('20 / 1000'), findsOneWidget);
    });

    testWidgets('AdminFeedbackScreen renders correctly in Turkish', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AdminFeedbackScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AdminFeedbackScreen), findsOneWidget);
      expect(find.text(FeedbackL10n.getAdminTitle('tr')), findsOneWidget);
    });
  });

  group('Vault Security & Lock Re-authentication Suite', () {
    testWidgets('Vault locks every time user enters if PIN is configured', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set a PIN
      await container.read(vaultControllerProvider.notifier).setPin('1234');
      container.read(vaultControllerProvider.notifier).unlockVault('1234');
      expect(container.read(vaultControllerProvider).isLocked, isFalse);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VaultScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // On entry, VaultScreen should enforce lock
      expect(container.read(vaultControllerProvider).isLocked, isTrue);
      expect(find.byType(VaultLockView), findsOneWidget);

      // Unlock with PIN
      container.read(vaultControllerProvider.notifier).unlockVault('1234');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(container.read(vaultControllerProvider).isLocked, isFalse);
      expect(find.byType(VaultLockView), findsNothing);

      // Simulate tab switch: user was on Vault (tab 3) and switches to Home (tab 0)
      container.read(mainNavigationIndexProvider.notifier).state = 3;
      await tester.pump();
      container.read(mainNavigationIndexProvider.notifier).state = 0;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(container.read(vaultControllerProvider).isLocked, isTrue);

      container.read(mainNavigationIndexProvider.notifier).state = 3;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(container.read(vaultControllerProvider).isLocked, isTrue);
      expect(find.byType(VaultLockView), findsOneWidget);
    });
  });
}
