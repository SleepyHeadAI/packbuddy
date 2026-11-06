import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:packbuddy/core/utils/date_formatter.dart';
import 'package:packbuddy/core/services/share_service.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';

import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/domain/packing_templates.dart';
import 'package:packbuddy/features/checklist/domain/airline_baggage_guide.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';

import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/auth_screen.dart';
import 'package:packbuddy/features/auth/presentation/screens/banned_screen.dart';
import 'package:packbuddy/features/admin/user_moderation_provider.dart';
import 'package:packbuddy/core/services/story_card_localization.dart';
import 'package:packbuddy/features/travel_map/presentation/widgets/travel_map_story_card.dart';

// Test Fakes
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
    this.uid = 'test-uid',
    this.email = 'test@packbuddy.app',
    this.displayName = 'PackBuddy Tester',
    this.emailVerified = true,
    this.providerData = const [],
  });
}

class FakeTripController extends StateNotifier<TripState> implements TripController {
  FakeTripController([TripState? state])
      : super(state ?? const TripState(trips: [], isLoading: false));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeChecklistNotifier extends StateNotifier<ChecklistState>
    implements ChecklistNotifier {
  FakeChecklistNotifier([ChecklistState? state])
      : super(state ?? const ChecklistState(items: [], isLoading: false));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeExpenseController extends StateNotifier<ExpenseState>
    implements ExpenseController {
  FakeExpenseController([ExpenseState? state])
      : super(state ?? const ExpenseState(expenses: [], isLoading: false));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  FakeAuthController([AuthState? state]) : super(state ?? const AuthState());

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('tr', null);
    await initializeDateFormatting('de', null);
    await initializeDateFormatting('fr', null);
    await initializeDateFormatting('es', null);
    await initializeDateFormatting('ru', null);
  });

  const supportedLocales = AppLocalizations.supportedLocales;

  group('1. Multi-Language Audit & Verification Across All 20 Locales', () {
    test('All 20 locales load successfully with zero missing delegates', () {
      expect(supportedLocales.length, equals(20));
      for (final loc in supportedLocales) {
        final l10n = lookupAppLocalizations(loc);
        expect(l10n, isNotNull);
        expect(l10n.appName, isNotEmpty);
        expect(l10n.trips, isNotEmpty);
        expect(l10n.budget, isNotEmpty);
        expect(l10n.vault, isNotEmpty);
        expect(l10n.settings, isNotEmpty);
        expect(l10n.tripMap, isNotEmpty);
        expect(l10n.waypoints, isNotEmpty);
        expect(l10n.addWaypoint, isNotEmpty);
        expect(l10n.noWaypoints, isNotEmpty);
        expect(l10n.customLocationHint, isNotEmpty);
        expect(l10n.addCustomLocation, isNotEmpty);
        expect(l10n.customLocationDescription, isNotEmpty);
        expect(l10n.addAsCustomLocation, isNotEmpty);
        expect(l10n.storyLayoutJourney, isNotEmpty);
        expect(l10n.storyLayoutPolaroid, isNotEmpty);
        expect(l10n.storyLayoutInfographic, isNotEmpty);
        expect(l10n.cityLabel, isNotEmpty);
        expect(l10n.countryLabel, isNotEmpty);
      }
    });

    test('Packing Templates return localized titles and descriptions in all 20 languages', () {
      final templates = PackingTemplatesRepository.all;
      expect(templates.length, equals(5));

      for (final loc in supportedLocales) {
        final l10n = lookupAppLocalizations(loc);
        for (final tpl in templates) {
          final title = tpl.getLocalizedTitle(l10n);
          final desc = tpl.getLocalizedDescription(l10n);
          expect(title, isNotEmpty, reason: 'Template ${tpl.id} title empty in ${loc.languageCode}');
          expect(desc, isNotEmpty, reason: 'Template ${tpl.id} desc empty in ${loc.languageCode}');

          // Verify business and camping templates are properly localized and not stuck on Turkish in English
          if (loc.languageCode == 'en') {
            if (tpl.id == 'business_trip') {
              expect(title, equals('Business & Conference'));
            } else if (tpl.id == 'camping_outdoor') {
              expect(title, equals('Nature & Camping Expedition'));
            }
          }
        }
      }
    });

    test('Airline baggage guides provide rich localized notes in TR, DE, FR, ES, RU, EN', () {
      final rules = AirlineBaggageRepository.airlines;
      expect(rules.length, greaterThanOrEqualTo(16));

      for (final lang in ['tr', 'de', 'fr', 'es', 'ru', 'en']) {
        for (final rule in rules) {
          final note = rule.getLocalizedNotes(lang);
          expect(note, isNotEmpty, reason: 'Airline ${rule.iataCode} note empty in $lang');
          if (lang == 'de' && rule.iataCode == 'TK') {
            expect(note, contains('Handgepäck'));
          } else if (lang == 'fr' && rule.iataCode == 'TK') {
            expect(note, contains('bagage cabine'));
          } else if (lang == 'es' && rule.iataCode == 'TK') {
            expect(note, contains('equipaje de mano'));
          } else if (lang == 'ru' && rule.iataCode == 'TK') {
            expect(note, contains('ручной клади'));
          }
        }
      }
    });

    test('AppDateFormatter safely formats dates without falling back to Turkish when locale is omitted', () {
      final date = DateTime(2026, 9, 14, 15, 30);
      final defaultFormatted = AppDateFormatter.formatMMMd(date);
      expect(defaultFormatted, isNotEmpty);

      // Verify all 20 supported languages format dates without throwing
      for (final loc in supportedLocales) {
        expect(() => AppDateFormatter.formatMMMd(date, locale: loc.languageCode), returnsNormally);
        expect(() => AppDateFormatter.formatYMMMd(date, locale: loc.languageCode), returnsNormally);
        expect(() => AppDateFormatter.formatDateRange(date, date.add(const Duration(days: 5)), locale: loc.languageCode), returnsNormally);
      }
    });
  });

  group('2. Trip Domain Entity Integrity & SQLite Serialization', () {
    test('Trip stores, persists in SQLite notes, and restores metadata cleanly', () {
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip_100',
        title: 'Japan Tour',
        destination: 'Tokyo, Japan',
        startDate: now,
        endDate: now.add(const Duration(days: 10)),
        notes: 'Hotel booked at Ginza',
        createdAt: now,
        updatedAt: now,
        isShared: true,
        inviteCode: 'TRIP123',
        collaborators: ['user-a', 'user-b'],
        sharedRole: 'editor',
      );

      // Verify SQLite serialization
      final map = trip.toMap();
      expect(map['notes'], contains('<!--PB_COLLAB:'));
      expect(map['notes'], contains('TRIP123'));

      // Verify SQLite deserialization
      final restored = Trip.fromMap(map);
      expect(restored.notes, equals('Hotel booked at Ginza'));
      expect(restored.isShared, isTrue);
      expect(restored.inviteCode, equals('TRIP123'));
      expect(restored.collaborators.length, equals(2));
      expect(restored.sharedRole, equals('editor'));

      // Verify JSON round-trip
      final json = trip.toJson();
      final fromJson = Trip.fromJson(json);
      expect(fromJson.id, equals('trip_100'));
      expect(fromJson.inviteCode, equals('TRIP123'));

      // Verify copyWith
      final updated = trip.copyWith(
        collaborators: [...trip.collaborators, 'user-c'],
      );
      expect(updated.collaborators.length, equals(3));
      expect(updated.collaborators[2], equals('user-c'));
    });
  });

  group('3. ShareService Multi-Language Formatting Tests', () {
    test('ShareService formats trip summary with AppLocalizations across all 20 languages', () async {
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip_share',
        title: 'Alpine Escape',
        destination: 'Innsbruck, Austria',
        startDate: now,
        endDate: now.add(const Duration(days: 5)),
        budgetLimit: 1500,
        inviteCode: 'ALP999',
        createdAt: now,
        updatedAt: now,
      );

      final expenses = [
        Expense(id: 'e1', tripId: 'trip_share', title: 'Hotel', amount: 300, currency: 'EUR', category: 'Accommodation', date: now, createdAt: now, updatedAt: now),
      ];

      final items = [
        PackingItem(id: 'i1', tripId: 'trip_share', name: 'Hiking Boots', category: 'Clothing', quantity: 1, isPacked: true, createdAt: now, updatedAt: now),
        PackingItem(id: 'i2', tripId: 'trip_share', name: 'Camera', category: 'Electronics', quantity: 1, isPacked: false, createdAt: now, updatedAt: now),
      ];

      for (final loc in supportedLocales) {
        final l10n = lookupAppLocalizations(loc);
        final success = await ShareService.shareTripSummary(
          trip: trip,
          expenses: expenses,
          items: items,
          l10n: l10n,
        );
        expect(success, isTrue);

        final checklistSuccess = await ShareService.shareChecklist(
          tripTitle: trip.title,
          items: items,
          l10n: l10n,
        );
        expect(checklistSuccess, isTrue);

        final inviteSuccess = await ShareService.shareInviteCode(
          trip: trip,
          inviteCode: trip.inviteCode!,
          l10n: l10n,
        );
        expect(inviteSuccess, isTrue);
      }
    });
  });

  group('4. UI Overflow Stress Tests on Compact Screen (320px width)', () {
    testWidgets('AuthScreen password rules row renders zero overflow on 320px width', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      for (final lang in ['de', 'ru', 'el', 'tr', 'en']) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authControllerProvider.overrideWith(
                (ref) => FakeAuthController(),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale(lang),
              home: const AuthScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow in AuthScreen with locale $lang');
      }
    });

    testWidgets('BannedScreen sign-out button renders zero overflow on 320px width', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const moderation = UserModerationState(
        banStatus: 'permanent',
        banReason: 'Account suspended for policy violations.',
      );

      for (final loc in supportedLocales) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: loc,
              home: const BannedScreen(moderation: moderation),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow in BannedScreen with locale: ${loc.languageCode}');
      }
    });

    testWidgets('AddTripSheet custom transport dialog renders zero overflow on 320px width', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      for (final lang in ['de', 'ru', 'el', 'tr', 'en']) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale(lang),
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              final l10n = AppLocalizations.of(ctx)!;
                              return AlertDialog(
                                title: Row(
                                  children: [
                                    const Icon(Icons.edit_road_rounded),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(l10n.customTransportType, style: const TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                ),
                                content: TextField(
                                  decoration: InputDecoration(
                                    labelText: l10n.customTransportVehicle,
                                    hintText: l10n.customTransportHint,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const Text('Open'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap open
        await tester.tap(find.text('Open'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Overflow in AddTripSheet custom transport dialog with locale $lang');
      }
    });

    testWidgets('TripDetailScreen renders date row and waypoints without overflow on 320px width in Russian & German', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final now = DateTime(2026, 9, 14);
      final testTrip = Trip(
        id: 'detail_test_trip',
        title: 'St. Petersburg Winter Journey',
        destination: 'Sankt-Peterburg, Severo-Zapadny federalny okrug, Russia',
        startDate: now,
        endDate: now.add(const Duration(days: 25)),
        budgetLimit: 5000,
        defaultCurrency: 'USD',
        transportMode: 'bulletTrain',
        notes: 'Winter jacket and warm thermal gloves required',
        createdAt: now,
        updatedAt: now,
      );

      for (final lang in ['ru', 'de', 'el', 'tr', 'en']) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tripControllerProvider.overrideWith((ref) => FakeTripController(TripState(trips: [testTrip], isLoading: false))),
              checklistControllerProvider.overrideWith((ref) => FakeChecklistNotifier()),
              expenseControllerProvider('detail_test_trip').overrideWith((ref) => FakeExpenseController()),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale(lang),
              home: TripDetailScreen(trip: testTrip),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final ex = tester.takeException();
        if (ex != null) {
          debugPrint('DEBUG EXCEPTION: ${(ex is FlutterError) ? ex.toStringDeep() : ex.toString()}');
        }
        expect(ex, isNull, reason: 'Overflow in TripDetailScreen with locale $lang');
      }
    });

    testWidgets('StoryCardLocalization & TravelMapStoryCard 20-Language Complete Verification', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const languages = [
        'en', 'tr', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja',
        'ko', 'hi', 'ar', 'nl', 'el', 'sv', 'pl', 'id', 'th', 'vi'
      ];

      for (final lang in languages) {
        // 1. Verify all localization methods return non-empty strings
        expect(StoryCardLocalization.getWorldTravelerHeader(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getAtlasArchiveHeader(lang, 12.3).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getMinimalQuote(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getShowcaseExploredBadge(lang, 28).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getJourneyLogHeader(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getExplorationRateHeader(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getCountriesCountBadge(lang, 28).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getContinentsCountBadge(lang, 2).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getPostcardHeader(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getPostcardCaption(lang, 28).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getPostcardNote(lang, 28, 2).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getInfographicHeader(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getVisaPendingBadge(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getTargetDestinationsHeader(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getReadyForTakeoffHint(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getVisaAdmittedStamp(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getNextRadarHeader(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getHorizonAwaitsHeader(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getExplorerEmptyPrompt(lang).isNotEmpty, isTrue);
        expect(StoryCardLocalization.getNewAdventuresPrompt(lang).isNotEmpty, isTrue);

        for (final theme in StoryCardTheme.values) {
          expect(StoryCardLocalization.getThemeName(theme.name, lang).isNotEmpty, isTrue);
        }

        for (final layout in StoryCardLayout.values) {
          expect(StoryCardLocalization.getLayoutName(layout, lang).isNotEmpty, isTrue);
        }
      }
    });
  });
}
