import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/core/constants/app_constants.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/core/services/legal_consent_localization.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/presentation/screens/legal_consent_screen.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LocaleNotifier extends LocaleNotifier {
  _LocaleNotifier(Locale initial) : super() {
    state = initial;
  }
}

class _ProNotifier extends StateNotifier<ProSubscriptionState> implements MockRevenueCatNotifier {
  _ProNotifier() : super(const ProSubscriptionState(isPro: false));

  @override
  void selectPlan(SubscriptionPlan plan) => state = state.copyWith(activePlan: plan);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _smallScreenLocales = ['tr', 'en', 'de', 'ru', 'ar', 'el', 'hi', 'fr'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('KVKK / GDPR - legal consent', () {
    Widget consentApp(String lang) => ProviderScope(
          overrides: [
            localeProvider.overrideWith((ref) => _LocaleNotifier(Locale(lang))),
          ],
          child: MaterialApp(
            locale: Locale(lang),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LegalConsentScreen(isMandatoryGate: true, isReviewMode: false),
          ),
        );

    testWidgets('analytics is optional and unchecked; user can continue without it', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(consentApp('tr'));
      await tester.pumpAndSettle();

      final analyticsBox = find.descendant(
        of: find.byKey(const Key('legal_analytics_checkbox')),
        matching: find.byType(Checkbox),
      );
      expect(tester.widget<Checkbox>(analyticsBox).value, isFalse);
      expect(find.textContaining('(İsteğe bağlı)'), findsOneWidget);
      expect(find.textContaining('(Zorunlu)'), findsNWidgets(2));

      // Tick only the two mandatory boxes
      final boxes = find.byType(Checkbox);
      await tester.tap(boxes.at(0));
      await tester.tap(boxes.at(1));
      await tester.pump();

      await tester.tap(find.text(LegalConsentLocalization.getAcceptButton('tr')));
      await tester.pumpAndSettle();

      expect(find.text(LegalConsentLocalization.getValidationMustAccept('tr')), findsNothing);
      expect(PreferencesService.instance.hasAcceptedLegalConsent(), isTrue);
      expect(PreferencesService.instance.isAnalyticsConsentGiven(), isFalse);
    });

    testWidgets('privacy policy & terms links are visible and tappable', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(consentApp('tr'));
      await tester.pumpAndSettle();

      final privacy = find.byKey(const Key('legal_privacy_policy_link'));
      final terms = find.byKey(const Key('legal_terms_link'));
      expect(privacy, findsOneWidget);
      expect(terms, findsOneWidget);
      expect(tester.widget<InkWell>(privacy).onTap, isNotNull);
      expect(tester.widget<InkWell>(terms).onTap, isNotNull);
      expect(find.text('Aydınlatma Metni ve Gizlilik Politikası'), findsOneWidget);
    });

    for (final lang in _smallScreenLocales) {
      testWidgets('consent screen has no overflow on 320x568 ($lang)', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(consentApp(lang));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Paywall pre-purchase disclosure', () {
    Widget paywallApp(String lang) => ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => _ProNotifier()),
            isAdminProvider.overrideWith((ref) => false),
            authUserProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: Locale(lang),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: PaywallSheet()),
          ),
        );

    testWidgets('auto-renew / cancellation notice and legal links sit under the buy button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(paywallApp('tr'));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
      final notice = find.byKey(const Key('paywall_auto_renew_notice'));
      expect(notice, findsOneWidget);
      expect(tester.widget<Text>(notice).data, l10n.subscriptionAutoRenewNotice);
      expect(l10n.subscriptionAutoRenewNotice, contains('otomatik'));
      expect(l10n.subscriptionAutoRenewNotice, contains('Google Play'));

      // The notice is rendered below the subscribe button
      final buyY = tester.getTopLeft(find.text(l10n.subscribeNow)).dy;
      expect(tester.getTopLeft(notice).dy, greaterThan(buyY));

      expect(find.byKey(const Key('paywall_terms_link')), findsOneWidget);
      expect(find.byKey(const Key('paywall_privacy_link')), findsOneWidget);
    });

    for (final lang in _smallScreenLocales) {
      testWidgets('paywall has no overflow on 320x568 ($lang)', (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(paywallApp(lang));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Invite-code self-join disabled for v1.0 (Firestore rule B1)', () {
    test('feature flag is off and the controller never attempts a self-join', () async {
      expect(AppConstants.kInviteCodeJoinEnabled, isFalse);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final joined = await container.read(tripControllerProvider.notifier).joinTripByInviteCode('PB-ABC12');
      expect(joined, isNull);
    });

    test('join entry point and invite code card are gated by the flag', () {
      final tripsScreen = File('lib/features/budget/presentation/screens/trips_screen.dart').readAsStringSync();
      final shareSheet =
          File('lib/features/budget/presentation/screens/widgets/share_trip_sheet.dart').readAsStringSync();
      expect(tripsScreen, contains('if (AppConstants.kInviteCodeJoinEnabled)'));
      expect(shareSheet, contains('if (AppConstants.kInviteCodeJoinEnabled) ...['));
    });
  });

  group('20-language ARB sync', () {
    const newKeys = [
      'deleteAccountNowTitle',
      'deleteAccountNowMessage',
      'deleteAccountNowButton',
      'deleteAccountPasswordLabel',
      'deleteAccountGoogleReauthHint',
      'deleteAccountDoneNotice',
      'deleteAccountFailedNotice',
      'subscriptionAutoRenewNotice',
    ];
    const legacyKeys = [
      'deleteAccountConfirmationTitle',
      'deleteAccountConfirmationMessage',
      'deleteAccountButton',
      'deleteAccountScheduledNotice',
    ];

    test('every locale has the new keys translated (not English) and no legacy 15-day keys', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      for (final locale in AppLocalizations.supportedLocales) {
        final l = await AppLocalizations.delegate.load(locale);
        final values = <String, String>{
          'deleteAccountNowTitle': l.deleteAccountNowTitle,
          'deleteAccountNowMessage': l.deleteAccountNowMessage,
          'deleteAccountNowButton': l.deleteAccountNowButton,
          'deleteAccountPasswordLabel': l.deleteAccountPasswordLabel,
          'deleteAccountGoogleReauthHint': l.deleteAccountGoogleReauthHint,
          'deleteAccountDoneNotice': l.deleteAccountDoneNotice,
          'deleteAccountFailedNotice': l.deleteAccountFailedNotice,
          'subscriptionAutoRenewNotice': l.subscriptionAutoRenewNotice,
        };
        expect(values.keys, containsAll(newKeys));
        if (locale.languageCode != 'en') {
          expect(l.deleteAccountNowMessage, isNot(en.deleteAccountNowMessage),
              reason: '${locale.languageCode} must not fall back to English');
          expect(l.subscriptionAutoRenewNotice, isNot(en.subscriptionAutoRenewNotice),
              reason: '${locale.languageCode} must not fall back to English');
        }
      }
      final generated = File('lib/l10n/app_localizations.dart').readAsStringSync();
      for (final k in legacyKeys) {
        expect(generated, isNot(contains('get $k;')), reason: '$k should be removed');
      }
    });
  });
}
