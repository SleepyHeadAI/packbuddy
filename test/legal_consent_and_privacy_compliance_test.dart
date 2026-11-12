import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:packbuddy/core/services/legal_consent_localization.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/legal_consent_provider.dart';
import 'package:packbuddy/features/auth/presentation/screens/legal_consent_screen.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUserInfo extends Fake implements UserInfo {
  @override
  final String providerId;

  FakeUserInfo({required this.providerId});
}

class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool emailVerified;
  @override
  final List<UserInfo> providerData;

  FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = true,
    this.providerData = const [],
  });

  @override
  Future<void> reload() async {}
}

class MockLocaleNotifier extends LocaleNotifier {
  MockLocaleNotifier(Locale initial) : super() {
    state = initial;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('1. Legal Consent Localization (All 20 Languages)', () {
    const allLanguages = LegalConsentLocalization.supportedLanguages;

    test('All 20 languages return non-empty strings and full 8 categories and 10 articles', () {
      expect(allLanguages.length, 20);

      for (final lang in allLanguages) {
        final title = LegalConsentLocalization.getTitle(lang);
        final subtitle = LegalConsentLocalization.getSubtitle(lang);
        final tabSummary = LegalConsentLocalization.getTabSummary(lang);
        final tabArticles = LegalConsentLocalization.getTabArticles(lang);
        final mandatoryTerms = LegalConsentLocalization.getMandatoryTermsCheckbox(lang);
        final mandatoryData = LegalConsentLocalization.getMandatoryDataConsentCheckbox(lang);
        final optionalAnalytics = LegalConsentLocalization.getOptionalAnalyticsCheckbox(lang);
        final acceptBtn = LegalConsentLocalization.getAcceptButton(lang);
        final declineBtn = LegalConsentLocalization.getDeclineButton(lang);
        final dialogTitle = LegalConsentLocalization.getDeclineDialogTitle(lang);
        final dialogContent = LegalConsentLocalization.getDeclineDialogContent(lang);
        final validationMsg = LegalConsentLocalization.getValidationMustAccept(lang);

        expect(title.isNotEmpty, isTrue, reason: 'Empty title for $lang');
        expect(subtitle.isNotEmpty, isTrue, reason: 'Empty subtitle for $lang');
        expect(tabSummary.isNotEmpty, isTrue, reason: 'Empty tabSummary for $lang');
        expect(tabArticles.isNotEmpty, isTrue, reason: 'Empty tabArticles for $lang');
        expect(mandatoryTerms.isNotEmpty, isTrue, reason: 'Empty mandatoryTerms for $lang');
        expect(mandatoryData.isNotEmpty, isTrue, reason: 'Empty mandatoryData for $lang');
        expect(optionalAnalytics.isNotEmpty, isTrue, reason: 'Empty optionalAnalytics for $lang');
        expect(acceptBtn.isNotEmpty, isTrue, reason: 'Empty acceptBtn for $lang');
        expect(declineBtn.isNotEmpty, isTrue, reason: 'Empty declineBtn for $lang');
        expect(dialogTitle.isNotEmpty, isTrue, reason: 'Empty dialogTitle for $lang');
        expect(dialogContent.isNotEmpty, isTrue, reason: 'Empty dialogContent for $lang');
        expect(validationMsg.isNotEmpty, isTrue, reason: 'Empty validationMsg for $lang');

        // Check 8 Summary Categories
        final categories = LegalConsentLocalization.getCategories(lang);
        expect(categories.length, 8, reason: 'Categories count mismatch for $lang');
        for (final cat in categories) {
          expect(cat.title.isNotEmpty, isTrue);
          expect(cat.subtitle.isNotEmpty, isTrue);
          expect(cat.bulletPoints.isNotEmpty, isTrue);
        }

        // Check 10 Legal Articles
        final articles = LegalConsentLocalization.getArticles(lang);
        expect(articles.length, 10, reason: 'Articles count mismatch for $lang');
        for (var i = 0; i < 10; i++) {
          expect(articles[i].number, i + 1);
          expect(articles[i].title.isNotEmpty, isTrue);
          expect(articles[i].content.isNotEmpty, isTrue);
        }
      }
    });
  });

  group('2. PreferencesService Legal Consent Persistence', () {
    test('Default is false, setting accepted persists with version and timestamp', () async {
      final prefs = PreferencesService.instance;
      expect(prefs.hasAcceptedLegalConsent(), isFalse);
      expect(prefs.hasAcceptedLegalConsent(uid: 'user_abc'), isFalse);

      await prefs.setLegalConsentAccepted(
        true,
        uid: 'user_abc',
        version: '1.0.0',
        analyticsConsent: true,
      );

      expect(prefs.hasAcceptedLegalConsent(), isTrue);
      expect(prefs.hasAcceptedLegalConsent(uid: 'user_abc'), isTrue);
      expect(prefs.getLegalConsentVersion(uid: 'user_abc'), '1.0.0');
      expect(prefs.getLegalConsentDate(uid: 'user_abc'), isNotNull);
      expect(prefs.isAnalyticsConsentGiven(uid: 'user_abc'), isTrue);
    });
  });

  group('3. LegalConsentProvider Riverpod StateNotifier', () {
    test('Accepting and revoking consent updates state and preferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(legalConsentProvider), isFalse);

      await container.read(legalConsentProvider.notifier).acceptConsent(
        version: '1.0.0',
        analyticsConsent: true,
      );

      expect(container.read(legalConsentProvider), isTrue);
      expect(PreferencesService.instance.hasAcceptedLegalConsent(), isTrue);

      await container.read(legalConsentProvider.notifier).revokeConsent();
      expect(container.read(legalConsentProvider), isFalse);
    });
  });

  group('4. LegalConsentScreen Responsive UI Across Screen Sizes & Languages', () {
    const screenSizes = [
      Size(320, 568),  // Small phone (iPhone SE 1)
      Size(390, 844),  // Standard phone (iPhone 14)
      Size(412, 915),  // Large phone (Pixel 7)
      Size(800, 1280), // Tablet (10-inch)
    ];

    for (final size in screenSizes) {
      testWidgets('Renders at ${size.width}x${size.height} in Turkish & English without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final lang in ['tr', 'en', 'de', 'ar']) {
          await PreferencesService.instance.setLocale(Locale(lang));

          await tester.pumpWidget(
            ProviderScope(
              key: ValueKey('provider_scope_$lang'),
              child: MaterialApp(
                key: ValueKey('material_app_$lang'),
                locale: Locale(lang),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: LegalConsentScreen(
                  key: ValueKey('legal_consent_$lang'),
                  isMandatoryGate: true,
                  isReviewMode: false,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Title & badges should be rendered
          expect(find.byType(LegalConsentScreen), findsOneWidget);

          // Verify Segmented Tab Switcher
          final articlesTabFinder = find.text(LegalConsentLocalization.getTabArticles(lang));
          expect(articlesTabFinder, findsOneWidget);

          // Tap Articles Tab to switch view to 10 articles
          await tester.tap(articlesTabFinder);
          await tester.pumpAndSettle();

          // Switch back to Summary Tab
          final summaryTabFinder = find.text(LegalConsentLocalization.getTabSummary(lang));
          expect(summaryTabFinder, findsOneWidget);
          await tester.tap(summaryTabFinder);
          await tester.pumpAndSettle();

          // Verify Accept & Decline buttons exist
          final acceptBtnFinder = find.text(LegalConsentLocalization.getAcceptButton(lang));
          expect(acceptBtnFinder, findsOneWidget);

          final declineBtnFinder = find.text(LegalConsentLocalization.getDeclineButton(lang));
          expect(declineBtnFinder, findsOneWidget);

          // No exception or render overflow
          expect(tester.takeException(), isNull);
        }
      });
    }

    testWidgets('Tapping Accept without ticking checkboxes shows validation error', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith((ref) => MockLocaleNotifier(const Locale('tr'))),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LegalConsentScreen(
              isMandatoryGate: true,
              isReviewMode: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Accept without checking mandatory checkboxes
      final acceptBtn = find.text(LegalConsentLocalization.getAcceptButton('tr'));
      await tester.tap(acceptBtn);
      await tester.pumpAndSettle();

      // Validation error message should be visible
      expect(find.text(LegalConsentLocalization.getValidationMustAccept('tr')), findsOneWidget);

      // Now tick both mandatory checkboxes
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(3)); // 2 mandatory + 1 optional

      await tester.tap(checkboxes.at(0));
      await tester.pumpAndSettle();

      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      // Tap Accept now
      await tester.tap(acceptBtn);
      await tester.pumpAndSettle();

      // Validation error should disappear and consent should be accepted
      expect(PreferencesService.instance.hasAcceptedLegalConsent(), isTrue);
    });

    testWidgets('Review mode renders verification banner and close button', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await PreferencesService.instance.setLegalConsentAccepted(
        true,
        version: '1.0.0',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith((ref) => MockLocaleNotifier(const Locale('tr'))),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: LegalConsentScreen(
              isMandatoryGate: false,
              isReviewMode: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verification text should be found
      expect(find.textContaining('Sözleşme Onaylandı'), findsOneWidget);
      expect(find.text(LegalConsentLocalization.getCloseButton('tr')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('5. AuthWallGate Mandatory Legal Consent Gating', () {
    testWidgets('Authenticated user without legal consent is strictly blocked by LegalConsentScreen', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await PreferencesService.instance.setOnboardingCompleted(true);
      await PreferencesService.instance.setLegalConsentAccepted(false);

      final fakeUser = FakeUser(
        uid: 'user_123',
        email: 'user@packbuddy.com',
        emailVerified: true,
        providerData: [FakeUserInfo(providerId: 'google.com')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authUserProvider.overrideWithValue(fakeUser),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AuthWallGate(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Must strictly display LegalConsentScreen
      expect(find.byType(LegalConsentScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('mandatory_legal_consent_wall')), findsOneWidget);
    });
  });
}
