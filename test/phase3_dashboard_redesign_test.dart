import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_colors.dart';
import 'package:packbuddy/core/theme/app_icons.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/widgets/dashboard_mini_cards.dart';
import 'package:packbuddy/features/dashboard/presentation/widgets/horizontal_currency_converter_card.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/travel_map/presentation/controllers/travel_map_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_button.dart';
import 'package:packbuddy/shared/widgets/app_divider.dart';

class _FakeTripController extends StateNotifier<TripState> implements TripController {
  _FakeTripController({List<Trip>? trips})
      : super(TripState(isLoading: false, trips: trips ?? []));

  @override
  Future<void> loadTrips({String? userId}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  _FakeVaultController()
      : super(
          VaultState(
            isLoading: false,
            isLocked: false,
            hasPin: false,
            documents: [],
          ),
        );

  @override
  void lockVault() {}

  @override
  Future<void> loadDocuments({String? tripId, String? userId}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChecklistController extends StateNotifier<ChecklistState> implements ChecklistNotifier {
  _FakeChecklistController({List<PackingItem>? items})
      : super(
          ChecklistState(
            isLoading: false,
            items: items ?? [
              PackingItem(
                id: 'item_1',
                name: 'Passport',
                category: 'Documents',
                isPacked: true,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              PackingItem(
                id: 'item_2',
                name: 'Charger',
                category: 'Electronics',
                isPacked: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ],
          ),
        );

  @override
  Future<void> loadItems({String? tripId, String? userId}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTravelMapController extends StateNotifier<TravelMapState> implements TravelMapController {
  _FakeTravelMapController() : super(const TravelMapState());

  @override
  Future<void> loadCountries({String? userId, bool showLoading = false}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _buildTestApp({
  required Widget home,
  ThemeData? theme,
  List<Trip>? trips,
  List<PackingItem>? checklistItems,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      tripControllerProvider.overrideWith((ref) => _FakeTripController(trips: trips)),
      vaultControllerProvider.overrideWith((ref) => _FakeVaultController()),
      checklistControllerProvider.overrideWith((ref) => _FakeChecklistController(items: checklistItems)),
      travelMapControllerProvider.overrideWith((ref) => _FakeTravelMapController()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: home,
    ),
  );
}

Trip _createMockTrip({
  String id = 'trip_mock_1',
  String title = 'Tokyo Sakura Tour',
  String destination = 'Tokyo',
  String countryCode = 'JP',
  int daysInFuture = 5,
}) {
  final now = DateTime.now();
  final start = now.add(Duration(days: daysInFuture));
  final end = start.add(const Duration(days: 7));
  return Trip(
    id: id,
    title: title,
    destination: destination,
    countryCode: countryCode,
    startDate: start,
    endDate: end,
    transportMode: 'flight',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesService.init();
  });

  group('Phase 3 - Dashboard Redesign & Apple/Flighty Standards', () {
    testWidgets('Empty State Hero Card renders when trips list is empty', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          home: const DashboardScreen(),
          trips: [], // No trips!
        ),
      );
      await tester.pumpAndSettle();

      // Empty state card should be present with AppButton.primary
      expect(find.text('No trips planned yet'), findsOneWidget);
      expect(find.text('Tap the button below to add your first journey'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Add Trip'), findsOneWidget);
      expect(find.byIcon(AppIcons.flight), findsOneWidget);
    });

    testWidgets('Upcoming Trip Hero Card renders with tabular figures and clean divider', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final trip = _createMockTrip(daysInFuture: 5);

      await tester.pumpWidget(
        _buildTestApp(
          home: const DashboardScreen(),
          trips: [trip],
        ),
      );
      await tester.pumpAndSettle();

      // Trip Title & Destination
      expect(find.text('Tokyo Sakura Tour'), findsOneWidget);
      expect(find.textContaining('Tokyo'), findsWidgets);

      // AppDivider separating hero metadata
      expect(find.byType(AppDivider), findsWidgets);

      // Countdown pill text (e.g., '5 days left')
      final countdownFinder = find.text('5 days left');
      expect(countdownFinder, findsOneWidget);

      // Verify tabularFigures feature is enabled on the countdown text style
      final Text countdownWidget = tester.widget(countdownFinder);
      expect(countdownWidget.style?.fontFeatures?.any((f) => f.feature == 'tnum'), isTrue);
    });

    testWidgets('Light Theme Countdown Pill uses WCAG AAA brandAccentTextLight contrast', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final trip = _createMockTrip(daysInFuture: 3);

      await tester.pumpWidget(
        _buildTestApp(
          home: const DashboardScreen(),
          theme: AppTheme.lightTheme,
          trips: [trip],
        ),
      );
      await tester.pumpAndSettle();

      final countdownFinder = find.text('3 days left');
      expect(countdownFinder, findsOneWidget);

      final Text countdownWidget = tester.widget(countdownFinder);
      expect(countdownWidget.style?.color, equals(AppColors.brandAccentTextLight));
    });

    testWidgets('Dark Theme Countdown Pill uses brandAccentTextDark contrast', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final trip = _createMockTrip(daysInFuture: 3);

      await tester.pumpWidget(
        _buildTestApp(
          home: const DashboardScreen(),
          theme: AppTheme.darkTheme,
          trips: [trip],
        ),
      );
      await tester.pumpAndSettle();

      final countdownFinder = find.text('3 days left');
      expect(countdownFinder, findsOneWidget);

      final Text countdownWidget = tester.widget(countdownFinder);
      expect(countdownWidget.style?.color, equals(AppColors.brandAccentTextDark));
    });

    testWidgets('Luggage Checklist Card renders tabular figures mono counter and progress', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          home: const DashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Luggage & Checklist'), findsOneWidget);

      // Airline note icon
      expect(find.byIcon(AppIcons.flightTakeoff), findsOneWidget);

      // Verify Text.rich contains tabular figures
      final richTextFinder = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('1/2'),
      );
      expect(richTextFinder, findsOneWidget);

      final RichText richTextWidget = tester.widget(richTextFinder);
      final plainText = richTextWidget.text.toPlainText();
      expect(plainText, contains('1/2'));
      expect(plainText, contains('%50'));
    });

    testWidgets('Currency Converter Card renders tabular figures for rates and amount', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          home: const Scaffold(
            body: SingleChildScrollView(
              child: HorizontalCurrencyConverterCard(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find amounts/rate texts that use fontFeatures with 'tnum'
      final monoTexts = find.byWidgetPredicate((w) {
        if (w is Text) {
          return w.style?.fontFeatures?.any((f) => f.feature == 'tnum') ?? false;
        }
        return false;
      });
      expect(monoTexts, findsWidgets);
    });

    testWidgets('Dashboard Mini Cards render tabular figures', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: DashboardMiniTravelMap(
              visitedCountriesCount: 12,
              wishlistCount: 5,
              worldPercentage: 6.2,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final percentageFinder = find.text('6.2%');
      expect(percentageFinder, findsOneWidget);

      final Text textWidget = tester.widget(percentageFinder);
      expect(textWidget.style?.fontFeatures?.any((f) => f.feature == 'tnum'), isTrue);
    });

    testWidgets('Zero RenderFlex overflows in compact 320x568 and standard 390x844 viewports', (tester) async {
      for (final size in [const Size(320, 568), const Size(390, 844)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          _buildTestApp(
            home: const DashboardScreen(),
            trips: [_createMockTrip()],
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Failed at size $size');
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
