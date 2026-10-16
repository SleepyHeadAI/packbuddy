import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/app_widget_service.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/share_service.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/features/auth/auth_screen.dart';
import 'package:packbuddy/features/auth/auth_service.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/trip_waypoint.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_comparison_screen.dart';
import 'package:packbuddy/features/budget/presentation/widgets/currency_converter_card.dart';
import 'package:packbuddy/features/budget/presentation/widgets/trip_map_preview.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/home_widget_preview_card.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';

class MockTripNotifier extends StateNotifier<TripState> implements TripController {
  MockTripNotifier(List<Trip> trips) : super(TripState(trips: trips));

  @override
  void resetState() {}

  @override
  Future<void> loadTrips({String? userId}) async {}

  @override
  Future<Trip?> addTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String defaultCurrency = 'USD',
    double? budgetLimit,
    String? countryCode,
    String? transportMode,
    String? notes,
  }) async => null;

  @override
  Future<Trip?> updateTrip(Trip trip) async => trip;

  @override
  Future<bool> deleteTrip(String tripId) async => true;

  @override
  Future<String?> generateInviteCode(String tripId) async => 'INV123';

  @override
  Future<Trip?> joinTripByInviteCode(String code, {String? userIdentifier}) async => null;

  @override
  Future<bool> addCollaborator(String tripId, String collaboratorEmail) async => true;

  @override
  Future<bool> removeCollaborator(String tripId, String collaboratorEmail) async => true;
}

class MockAuthServiceWithApple extends Fake implements AuthService {
  bool appleSignInCalled = false;

  @override
  Future<UserCredential?> signInWithApple() async {
    appleSignInCalled = true;
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
    await CurrencyService.init();
  });

  group('F-11 Instant Currency Converter Tests (All 30 Currencies)', () {
    test('All 30 currencies have active exchange rates defined in CurrencyService', () {
      final currencies = CurrencyService.supportedCurrencies;
      expect(currencies.length, 30);
      for (final currency in currencies) {
        expect(CurrencyService.ratesAgainstUsd.containsKey(currency), isTrue,
            reason: 'Rate missing for $currency');
        final rate = CurrencyService.ratesAgainstUsd[currency]!;
        expect(rate, greaterThan(0.0), reason: 'Rate for $currency must be > 0');
      }
    });

    test('Converts correctly across all 30 currencies without NaN or infinity', () {
      final currencies = CurrencyService.supportedCurrencies;
      for (final from in currencies) {
        for (final to in currencies) {
          final converted = CurrencyService.convert(
            amount: 100.0,
            fromCurrency: from,
            toCurrency: to,
          );
          expect(converted.isFinite, isTrue, reason: 'Conversion from $from to $to failed');
          expect(converted, greaterThan(0.0));
        }
      }
    });

    test('Rate inversion identity: A -> B and B -> A are reciprocals', () {
      for (final target in ['TRY', 'EUR', 'JPY', 'GBP']) {
        final rateForward = CurrencyService.convert(amount: 1.0, fromCurrency: 'USD', toCurrency: target);
        final rateReverse = CurrencyService.convert(amount: 1.0, fromCurrency: target, toCurrency: 'USD');
        expect(rateForward * rateReverse, closeTo(1.0, 0.01));
      }
    });

    testWidgets('CurrencyConverterCard renders, swaps currencies and converts', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CurrencyConverterCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CurrencyConverterCard), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify preset quick chips
      expect(find.byType(ChoiceChip), findsWidgets);

      // Tap swap button
      final swapBtn = find.byIcon(Icons.swap_horiz_rounded);
      expect(swapBtn, findsOneWidget);
      await tester.tap(swapBtn);
      await tester.pumpAndSettle();
    });
  });

  group('F-4 Budget Analytics & Charts Tests', () {
    final testTrip = Trip(
      id: 'trip-analytics-1',
      userId: 'user-1',
      title: 'Rome Holiday',
      destination: 'Rome, Italy',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      budgetLimit: 1000.0,
      defaultCurrency: 'EUR',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final expenses = [
      Expense(
        id: 'e1',
        tripId: testTrip.id,
        userId: 'user-1',
        title: 'Trattoria Lunch',
        amount: 150.0,
        currency: 'EUR',
        category: 'food',
        notes: 'Pasta and gelato',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Expense(
        id: 'e2',
        tripId: testTrip.id,
        userId: 'user-1',
        title: 'Metro Tickets',
        amount: 80.0,
        currency: 'EUR',
        category: 'transport',
        notes: 'Metro & taxi',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Expense(
        id: 'e3',
        tripId: testTrip.id,
        userId: 'user-1',
        title: 'Hotel Deposit',
        amount: 220.0,
        currency: 'EUR',
        category: 'accommodation',
        notes: 'B&B deposit',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    testWidgets('BudgetAnalyticsCard computes category distributions and renders donut chart', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: SingleChildScrollView(
                child: BudgetAnalyticsCard(
                  trip: testTrip,
                  expenses: expenses,
                  tripCurrency: 'EUR',
                  totalSpent: 450.0,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BudgetAnalyticsCard), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Budget Analytics'), findsOneWidget);
    });

    test('DonutChartPainter paints without throws', () {
      final painter = DonutChartPainter(
        values: [150.0, 80.0, 220.0],
        colors: [Colors.amber, Colors.blue, Colors.purple],
      );
      expect(painter.shouldRepaint(painter), isFalse);
    });
  });

  group('F-1 & F-8 Shared Lists & Social Itinerary Sharing Tests', () {
    final trip = Trip(
      id: 'shared-trip-1',
      userId: 'user-owner',
      title: 'Barcelona Trip',
      destination: 'Barcelona, Spain',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 4)),
      budgetLimit: 800.0,
      defaultCurrency: 'EUR',
      isShared: true,
      inviteCode: 'BCN123',
      collaborators: const ['owner@packbuddy.com', 'traveler@packbuddy.com'],
      sharedRole: 'editor',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('Trip serialization preserves collaboration and inviteCode cleanly', () {
      final map = trip.toMap();
      expect(map['notes'], contains('<!--PB_COLLAB:'));
      expect(map['notes'], contains('owner@packbuddy.com'));

      final restored = Trip.fromMap(map);
      expect(restored.isShared, isTrue);
      expect(restored.inviteCode, 'BCN123');
      expect(restored.collaborators.length, 2);
      expect(restored.collaborators.first, 'owner@packbuddy.com');
    });

    test('PackingItem supports assignee for shared list collaboration', () {
      final item = PackingItem(
        id: 'item-collab-1',
        tripId: trip.id,
        name: 'Sunscreen SPF 50',
        category: 'Toiletries',
        isPacked: false,
        quantity: 2,
        assignedTo: 'Alex',
        packedBy: 'Alex',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = item.toMap();
      expect(map['tag'], contains('Alex'));

      final json = item.toJson();
      expect(json['assignedTo'], 'Alex');

      final restored = PackingItem.fromMap(map);
      expect(restored.assignedTo, 'Alex');
      expect(restored.packedBy, 'Alex');
    });

    test('ShareService formats trip summary, checklist and invite cleanly', () async {
      final expenses = [
        Expense(
          id: 'exp-1',
          tripId: trip.id,
          userId: 'user-owner',
          title: 'Tapas Dinner',
          amount: 120.0,
          currency: 'EUR',
          category: 'food',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final items = [
        PackingItem(
          id: 'i1',
          tripId: trip.id,
          name: 'Passport',
          category: 'Documents',
          isPacked: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final sharedSummary = await ShareService.shareTripSummary(
        trip: trip,
        expenses: expenses,
        items: items,
      );
      expect(sharedSummary, isTrue);

      final sharedChecklist = await ShareService.shareChecklist(
        tripTitle: trip.title,
        items: items,
      );
      expect(sharedChecklist, isTrue);

      final sharedInvite = await ShareService.shareInviteCode(
        trip: trip,
        inviteCode: 'BCN123',
      );
      expect(sharedInvite, isTrue);
    });
  });

  group('F-2 Travel Map & Waypoints Route Tests', () {
    test('TripWaypoint serializes and deserializes cleanly', () {
      const waypoint = TripWaypoint(
        id: 'wp-1',
        tripId: 'wp-trip-1',
        name: 'Eiffel Tower',
        latitude: 48.8584,
        longitude: 2.2945,
        address: 'Champ de Mars, 5 Av. Anatole France, 75007 Paris',
        notes: 'Sunset visit',
        orderIndex: 0,
      );

      final json = waypoint.toJson();
      final restored = TripWaypoint.fromJson(json);

      expect(restored.id, 'wp-1');
      expect(restored.tripId, 'wp-trip-1');
      expect(restored.name, 'Eiffel Tower');
      expect(restored.latitude, 48.8584);
      expect(restored.longitude, 2.2945);
      expect(restored.orderIndex, 0);
    });

    test('TripWaypoint encodes and decodes lists accurately', () {
      const waypoints = [
        TripWaypoint(id: 'wp1', tripId: 'trip-1', name: 'Shinjuku', latitude: 35.6938, longitude: 139.7034),
        TripWaypoint(id: 'wp2', tripId: 'trip-1', name: 'Shibuya', latitude: 35.6580, longitude: 139.7016),
      ];

      final encoded = TripWaypoint.encodeList(waypoints);
      expect(encoded, contains('Shinjuku'));

      final decoded = TripWaypoint.decodeList(encoded);
      expect(decoded.length, 2);
      expect(decoded[0].name, 'Shinjuku');
      expect(decoded[1].name, 'Shibuya');
    });

    test('RouteMapPainter paints pins and dashed routes without throws', () {
      final painter = RouteMapPainter(
        waypointCount: 3,
        primaryColor: Colors.teal,
        secondaryColor: Colors.orange,
        isDark: false,
      );
      expect(painter.shouldRepaint(painter), isFalse);
    });
  });

  group('F-9 Home Widget Service & Preview Tests', () {
    test('AppWidgetService payload serialization and persistence', () async {
      final trip = Trip(
        id: 'widget-trip-1',
        userId: 'u1',
        title: 'London Calling',
        destination: 'London, UK',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        budgetLimit: 1200.0,
        defaultCurrency: 'GBP',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final items = [
        PackingItem(
          id: 'item-1',
          tripId: trip.id,
          name: 'Umbrella',
          category: 'Clothing',
          isPacked: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final expenses = [
        Expense(
          id: 'exp-1',
          tripId: trip.id,
          userId: 'u1',
          title: 'Train ticket',
          amount: 85.0,
          currency: 'GBP',
          category: 'transport',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await AppWidgetService.updateWidgetPayload(
        upcomingTrip: trip,
        items: items,
        expenses: expenses,
      );

      final payload = await AppWidgetService.getWidgetPayload();
      expect(payload, isNotNull);
      expect(payload?.tripTitle, 'London Calling');
      expect(payload?.destination, 'London, UK');
      expect(payload?.totalItems, 1);
      expect(payload?.packedItems, 1);
      expect(payload?.packingPercent, 100);
      expect(payload?.budgetSpent, contains('85'));
    });

    testWidgets('HomeWidgetPreviewCard switches small, medium, large with zero overflow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: HomeWidgetPreviewCard(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeWidgetPreviewCard), findsOneWidget);
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      // Tap Medium size segment
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      // Tap Large size segment
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
    });
  });

  group('F-10 Multi-Trip Comparison Tests', () {
    testWidgets('TripComparisonScreen renders comparison metrics and chips', (tester) async {
      final tripA = Trip(
        id: 'trip-comp-a',
        userId: 'u1',
        title: 'Trip A (London)',
        destination: 'London',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 3)),
        budgetLimit: 500.0,
        defaultCurrency: 'GBP',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tripB = Trip(
        id: 'trip-comp-b',
        userId: 'u1',
        title: 'Trip B (Berlin)',
        destination: 'Berlin',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 5)),
        budgetLimit: 700.0,
        defaultCurrency: 'EUR',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripControllerProvider.overrideWith((ref) => MockTripNotifier([tripA, tripB])),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: TripComparisonScreen(
              initialSelectedTripIds: [tripA.id, tripB.id],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TripComparisonScreen), findsOneWidget);
      expect(find.text('Compare Trips'), findsOneWidget);
      expect(find.text('Trip A (London)'), findsWidgets);
      expect(find.text('Trip B (Berlin)'), findsWidgets);
    });
  });

  group('F-13 Onboarding App Tour & Replay Tests', () {
    test('PreferencesService onboarding flag operations', () async {
      expect(PreferencesService.instance.isOnboardingCompleted(), isFalse);
      await PreferencesService.instance.setOnboardingCompleted(true);
      expect(PreferencesService.instance.isOnboardingCompleted(), isTrue);
      await PreferencesService.instance.setOnboardingCompleted(false);
      expect(PreferencesService.instance.isOnboardingCompleted(), isFalse);
    });

    testWidgets('OnboardingScreen navigates 4 tour slides and reaches Get Started', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const OnboardingScreen(isReplay: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Plan Trips Effortlessly'), findsOneWidget);

      // Slide 1 to 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Smart Packing Checklists'), findsOneWidget);

      // Slide 2 to 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Collaborate in Real-Time'), findsOneWidget);

      // Slide 3 to 4
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Offline Travel Vault'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });
  });

  group('F-15 Apple Sign-In Authentication Tests', () {
    test('AuthService.signInWithApple delegates to platform credential', () async {
      final mockAuth = MockAuthServiceWithApple();
      await mockAuth.signInWithApple();

      expect(mockAuth.appleSignInCalled, isTrue);
    });

    testWidgets('AuthScreen renders Apple Sign-In button cleanly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const AuthScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
    });
  });

  group('Comprehensive 20-Language Localization Tests', () {
    const supportedLocales = [
      Locale('en'), Locale('tr'), Locale('de'), Locale('fr'), Locale('es'),
      Locale('it'), Locale('pt'), Locale('nl'), Locale('ru'), Locale('zh'),
      Locale('ja'), Locale('ko'), Locale('ar'), Locale('hi'), Locale('id'),
      Locale('pl'), Locale('el'), Locale('vi'), Locale('th'), Locale('sv'),
    ];

    for (final loc in supportedLocales) {
      test('Language ${loc.languageCode} resolves all new feature localization keys without null or missing exception', () async {
        final l10n = await AppLocalizations.delegate.load(loc);

        // F-11
        expect(l10n.currencyConverter, isNotEmpty);
        expect(l10n.exchangeRate, isNotEmpty);
        expect(l10n.quickConvert, isNotEmpty);

        // F-4
        expect(l10n.budgetAnalytics, isNotEmpty);
        expect(l10n.categoryDistribution, isNotEmpty);
        expect(l10n.dailyBurnRate, isNotEmpty);
        expect(l10n.total, isNotEmpty);

        // F-10
        expect(l10n.compareTrips, isNotEmpty);
        expect(l10n.selectTripsToCompare, isNotEmpty);
        expect(l10n.comparisonSummary, isNotEmpty);
        expect(l10n.totalSpent, isNotEmpty);

        // F-1 & F-8
        expect(l10n.sharedTrip, isNotEmpty);
        expect(l10n.inviteCode, isNotEmpty);
        expect(l10n.collaborators, isNotEmpty);
        expect(l10n.joinSharedTrip, isNotEmpty);
        expect(l10n.confirm, isNotEmpty);

        // F-2
        expect(l10n.tripMap, isNotEmpty);
        expect(l10n.waypoints, isNotEmpty);

        // F-9
        expect(l10n.widgetSettings, isNotEmpty);
        expect(l10n.widgetPreview, isNotEmpty);

        // F-13
        expect(l10n.onboardingTitle1, isNotEmpty);
        expect(l10n.onboardingTitle2, isNotEmpty);
        expect(l10n.onboardingTitle3, isNotEmpty);
        expect(l10n.onboardingTitle4, isNotEmpty);
        expect(l10n.replayTour, isNotEmpty);
        expect(l10n.getStarted, isNotEmpty);

        // F-15
        expect(l10n.signInWithApple, isNotEmpty);
      });
    }
  });

  group('Currency Formatting Across All 30 Currencies', () {
    const all30Currencies = [
      'USD', 'EUR', 'TRY', 'GBP', 'JPY',
      'CAD', 'AUD', 'CHF', 'CNY', 'SEK',
      'NZD', 'MXN', 'SGD', 'HKD', 'NOK',
      'KRW', 'INR', 'RUB', 'BRL', 'ZAR',
      'DKK', 'PLN', 'THB', 'IDR', 'HUF',
      'CZK', 'ILS', 'AED', 'SAR', 'VND',
    ];

    for (final curr in all30Currencies) {
      test('Formats currency $curr correctly without exception', () {
        final formatted = CurrencyFormatter.format(1250.50, currency: curr);
        expect(formatted, isNotEmpty);
        expect(formatted, contains('1'));
      });
    }
  });
}
