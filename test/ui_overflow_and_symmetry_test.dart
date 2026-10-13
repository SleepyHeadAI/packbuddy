import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/auth_screen.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/admin/admin_service.dart';
import 'package:packbuddy/features/admin/admin_controller.dart';
import 'package:packbuddy/features/admin/admin_dashboard_screen.dart';

// =============================================================================
// FAKES & TEST FIXTURES
// =============================================================================

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
    this.uid = 'test-admin-uid',
    this.email = 'sleepyheadaitr@gmail.com',
    this.displayName = 'Alexander von Humboldt',
    this.emailVerified = true,
    this.providerData = const [],
  });
}

class FakeTripController extends StateNotifier<TripState>
    implements TripController {
  FakeTripController([TripState? state])
      : super(state ?? const TripState(isLoading: false, trips: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeChecklistNotifier extends StateNotifier<ChecklistState>
    implements ChecklistNotifier {
  FakeChecklistNotifier([ChecklistState? state])
      : super(state ?? const ChecklistState(isLoading: false, items: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeVaultController extends StateNotifier<VaultState>
    implements VaultController {
  FakeVaultController([VaultState? state])
      : super(state ?? const VaultState(isLoading: false, documents: []));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeSyncEngine extends StateNotifier<SyncState> implements SyncEngine {
  FakeSyncEngine([SyncState? state]) : super(state ?? const SyncState());

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeRevenueCatNotifier extends StateNotifier<ProSubscriptionState>
    implements MockRevenueCatNotifier {
  FakeRevenueCatNotifier([ProSubscriptionState? state])
      : super(state ?? const ProSubscriptionState(isPro: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakePackingRemindersNotifier extends StateNotifier<bool>
    implements PackingRemindersNotifier {
  FakePackingRemindersNotifier([super.state = true]);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeAdminController extends StateNotifier<AdminState>
    implements AdminController {
  FakeAdminController([AdminState? state])
      : super(state ?? const AdminState(isLoading: false));

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
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues({
      'packbuddy_is_pro_member': true,
      'theme_mode': 'light',
      'locale': 'de',
    });
    await PreferencesService.init();
  });

  // Reusable comprehensive test data with long strings & large numbers
  final sampleTrip = Trip(
    id: 'trip-stress-1',
    title: 'Große Mitteleuropäische Kultur- und Sommerreise',
    destination: 'Berlin, Deutschland & Wien, Österreich',
    startDate: DateTime(2026, 8, 1),
    endDate: DateTime(2026, 8, 25),
    budgetLimit: 1250000.0,
    defaultCurrency: 'EUR',
    transportMode: 'Hızlı Tren / Hochgeschwindigkeitszug',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final sampleItem1 = PackingItem(
    id: 'pack-item-1',
    name: 'Hochwertige Geräuschunterdrückende Over-Ear Kopfhörer',
    category: 'Elektronik & Reiseausstattung',
    quantity: 4,
    isPacked: true,
    tag: 'CARRY-ON ONLY',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final sampleItem2 = PackingItem(
    id: 'pack-item-2',
    name: 'Internationale Reisekrankenversicherungspolice und Notfallkontakt',
    category: 'Dokumente & Finanzen',
    quantity: 1,
    isPacked: false,
    tag: 'ESSENTIAL',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final sampleDoc1 = Document(
    id: 'doc-stress-1',
    title: 'Biometrischer Reisepass der Bundesrepublik Deutschland',
    category: 'Pasaport',
    fileType: 'image',
    localImagePath: '/tmp/passport.jpg',
    tripId: sampleTrip.id,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final sampleDoc2 = Document(
    id: 'doc-stress-2',
    title: 'Elektronische Bordkarte und Transitgenehmigung für Hin- und Rückflug',
    category: 'Biletler',
    subCategory: 'Uçak Bileti',
    fileType: 'pdf',
    localImagePath: '/tmp/flight_ticket.pdf',
    tripId: sampleTrip.id,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final sampleAdminMetrics = const AdminPlatformMetrics(
    totalUsers: 14250,
    verifiedUsers: 12890,
    proUsers: 6420,
    totalTrips: 34210,
    totalExpenses: 89740,
    totalDocuments: 15420,
    totalChecklistItems: 125600,
  );

  final sampleAdminUsers = [
    AdminUserModel(
      uid: 'user-admin-1',
      email: 'sleepyheadaitr@gmail.com',
      displayName: 'Maximilian Fürst von Bismarck-Schönhausen',
      emailVerified: true,
      isPremium: true,
      provider: 'google.com',
      lastLoginAt: DateTime(2026, 10, 13, 14, 30),
      createdAt: DateTime(2026, 1, 1),
    ),
    AdminUserModel(
      uid: 'user-stress-2',
      email: 'konstantin.konstantinopolsky.travels@international-domain.org',
      displayName: 'Константин Константинопольский',
      emailVerified: false,
      isPremium: false,
      provider: 'password',
      lastLoginAt: DateTime(2026, 10, 12, 10, 15),
      createdAt: DateTime(2026, 2, 1),
    ),
  ];

  /// Helper to wrap screens with standardized Riverpod scope and text scaling
  Widget buildStressApp({
    required Widget screen,
    required Locale locale,
    ThemeData? theme,
    List<Override> extraOverrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        tripControllerProvider.overrideWith(
          (ref) => FakeTripController(
            TripState(isLoading: false, trips: [sampleTrip]),
          ),
        ),
        checklistControllerProvider.overrideWith(
          (ref) => FakeChecklistNotifier(
            ChecklistState(isLoading: false, items: [sampleItem1, sampleItem2]),
          ),
        ),
        vaultControllerProvider.overrideWith(
          (ref) => FakeVaultController(
            VaultState(isLoading: false, documents: [sampleDoc1, sampleDoc2]),
          ),
        ),
        syncEngineProvider.overrideWith(
          (ref) => FakeSyncEngine(
            const SyncState(status: SyncStatus.upToDate, syncedCount: 42),
          ),
        ),
        proSubscriptionProvider.overrideWith(
          (ref) => FakeRevenueCatNotifier(
            const ProSubscriptionState(isPro: true),
          ),
        ),
        packingRemindersProvider.overrideWith(
          (ref) => FakePackingRemindersNotifier(true),
        ),
        isAdminProvider.overrideWithValue(true),
        authUserProvider.overrideWithValue(FakeUser()),
        adminControllerProvider.overrideWith(
          (ref) => FakeAdminController(
            AdminState(
              isLoading: false,
              metrics: sampleAdminMetrics,
              allUsers: sampleAdminUsers,
            ),
          ),
        ),
        ...extraOverrides,
      ],
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.15),
            ),
            child: child!,
          );
        },
        home: screen,
      ),
    );
  }

  // Define screen constraints under test
  const screenSizes = <String, Size>{
    'iPhone SE 1st Gen (320x568)': Size(320, 568),
    'Compact Android (360x640)': Size(360, 640),
  };

  // Verbose test locales to stress word-wrap and layout bounds
  const testLocales = <String, Locale>{
    'German (de)': Locale('de'),
    'Russian (ru)': Locale('ru'),
  };

  group('Phase 4: Screen-Wide Overflow & Symmetry Stress Testing', () {
    for (final sizeEntry in screenSizes.entries) {
      final sizeName = sizeEntry.key;
      final size = sizeEntry.value;

      for (final localeEntry in testLocales.entries) {
        final localeName = localeEntry.key;
        final locale = localeEntry.value;

        testWidgets(
            '1. DashboardScreen renders zero overflows on $sizeName in $localeName',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildStressApp(
              screen: const DashboardScreen(),
              locale: locale,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          expect(tester.takeException(), isNull);
          expect(find.byType(DashboardScreen), findsOneWidget);
        });

        testWidgets(
            '2. TripsScreen renders zero overflows on $sizeName in $localeName',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildStressApp(
              screen: const TripsScreen(),
              locale: locale,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          final err = tester.takeException();
          if (err != null) {
            for (final ro in tester.allRenderObjects) {
              if (ro.toString().contains('OVERFLOWING')) {
                debugPrint('FOUND OVERFLOWING IN TripsScreen:\n${ro.toStringDeep()}');
              }
            }
          }
          expect(err, isNull);
          expect(find.byType(TripsScreen), findsOneWidget);
        });

        testWidgets(
            '3. ChecklistScreen renders zero overflows on $sizeName in $localeName',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildStressApp(
              screen: const ChecklistScreen(),
              locale: locale,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          expect(tester.takeException(), isNull);
          expect(find.byType(ChecklistScreen), findsOneWidget);
        });

        testWidgets(
            '4. VaultScreen renders zero overflows on $sizeName in $localeName',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildStressApp(
              screen: const VaultScreen(),
              locale: locale,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          expect(tester.takeException(), isNull);
          expect(find.byType(VaultScreen), findsOneWidget);
        });

        testWidgets(
            '5. SettingsScreen renders zero overflows on $sizeName in $localeName',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildStressApp(
              screen: const SettingsScreen(),
              locale: locale,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          expect(tester.takeException(), isNull);
          expect(find.byType(SettingsScreen), findsOneWidget);
        });

        testWidgets(
            '6. AuthScreen renders zero overflows on $sizeName in $localeName',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildStressApp(
              screen: const AuthScreen(),
              locale: locale,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          final err = tester.takeException();
          if (err != null) {
            for (final ro in tester.allRenderObjects) {
              if (ro.toString().contains('OVERFLOWING')) {
                debugPrint('FOUND OVERFLOWING RENDER OBJECT:\n${ro.toStringDeep()}');
              }
            }
          }
          expect(err, isNull);
          expect(find.byType(AuthScreen), findsOneWidget);
        });

        testWidgets(
            '7. AdminDashboardScreen renders zero overflows on $sizeName in $localeName',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildStressApp(
              screen: const AdminDashboardScreen(),
              locale: locale,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          expect(tester.takeException(), isNull);
          expect(find.byType(AdminDashboardScreen), findsOneWidget);
        });
      }
    }

    testWidgets(
        '8a. PaywallSheet renders zero overflows with 1.15x text scale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildStressApp(
          screen: const Scaffold(body: PaywallSheet()),
          locale: const Locale('de'),
        ),
      );
      await tester.pump();
      final err = tester.takeException();
      if (err != null) {
        for (final ro in tester.allRenderObjects) {
          if (ro.toString().contains('OVERFLOWING')) {
            debugPrint('FOUND OVERFLOW IN PaywallSheet:\n${ro.toStringDeep()}');
          }
        }
      }
      expect(err, isNull);
    });

    testWidgets(
        '8b. AddTripSheet renders zero overflows with 1.15x text scale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildStressApp(
          screen: const Scaffold(body: AddTripSheet()),
          locale: const Locale('de'),
        ),
      );
      await tester.pump();
      final err = tester.takeException();
      if (err != null) {
        for (final ro in tester.allRenderObjects) {
          if (ro.toString().contains('OVERFLOWING')) {
            debugPrint('FOUND OVERFLOW IN AddTripSheet:\n${ro.toStringDeep()}');
          }
        }
      }
      expect(err, isNull);
    });

    testWidgets(
        '8c. AddExpenseSheet renders zero overflows with 1.15x text scale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        buildStressApp(
          screen: const Scaffold(
            body: AddExpenseSheet(
              tripId: 'trip-stress-1',
              defaultCurrency: 'EUR',
            ),
          ),
          locale: const Locale('de'),
        ),
      );
      await tester.pump();
      final err = tester.takeException();
      if (err != null) {
        for (final ro in tester.allRenderObjects) {
          if (ro.toString().contains('OVERFLOWING')) {
            debugPrint('FOUND OVERFLOW IN AddExpenseSheet:\n${ro.toStringDeep()}');
          }
        }
      }
      expect(err, isNull);
    });
  });
}
