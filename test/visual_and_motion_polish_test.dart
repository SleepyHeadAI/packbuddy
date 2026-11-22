// Visual, theme and motion lock-in tests (visual audit, phase 3).
//
// 1. Critical screens / bottom sheets render in light + dark at 320x568 and
//    412x915 with zero RenderFlex overflow and zero exceptions.
// 2. Animated shared widgets run with REAL motion (reduced motion disabled),
//    leave no active Ticker after removal and behave with
//    MediaQuery(disableAnimations: true).
// 3. VaultCloudQuotaBanner appears when isCloudQuotaExceeded == true
//    (quotaSkippedFiles == 0 and > 0) and stays hidden otherwise.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_motion.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/currency_picker_sheet.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/airline_guide_sheet.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_item.dart';
import 'package:packbuddy/features/itinerary/presentation/controllers/itinerary_controller.dart';
import 'package:packbuddy/features/itinerary/presentation/screens/itinerary_screen.dart';
import 'package:packbuddy/features/profile/domain/animal_avatar.dart';
import 'package:packbuddy/features/profile/presentation/screens/friends_screen.dart';
import 'package:packbuddy/features/profile/presentation/widgets/animal_avatar_widget.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_cloud_quota_banner.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_pin_recovery_sheet.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/app_animations.dart';
import 'package:packbuddy/shared/widgets/app_card.dart';
import 'package:packbuddy/shared/widgets/app_skeleton.dart';
import 'package:packbuddy/shared/widgets/status_badge.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeUser extends Fake implements User {
  @override
  String get uid => 'polish-user';
  @override
  String? get email => 'polish@packbuddy.app';
  @override
  String? get displayName => 'Polish Tester';
  @override
  bool get emailVerified => true;
  @override
  List<UserInfo> get providerData => const [];
}

class _FakeLocaleNotifier extends LocaleNotifier {
  _FakeLocaleNotifier(Locale initial) : super() {
    state = initial;
  }
}

class _FakeTripController extends StateNotifier<TripState> implements TripController {
  _FakeTripController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class _FakeChecklistNotifier extends StateNotifier<ChecklistState> implements ChecklistNotifier {
  _FakeChecklistNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class _FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  _FakeVaultController(super.state);

  @override
  int getRemainingPinAttempts() => 5;

  @override
  bool isPinLockedOut() => false;

  @override
  int getPinLockoutRemainingSeconds() => 0;

  @override
  Future<void> resetFailedPinAttempts() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class _FakeSyncEngine extends StateNotifier<SyncState> implements SyncEngine {
  _FakeSyncEngine(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class _FakeProNotifier extends StateNotifier<ProSubscriptionState> implements MockRevenueCatNotifier {
  _FakeProNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class _FakePackingRemindersNotifier extends StateNotifier<bool> implements PackingRemindersNotifier {
  _FakePackingRemindersNotifier() : super(true);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _now = DateTime(2026, 6, 1);

final _trip = Trip(
  id: 'polish-trip',
  userId: 'polish-user',
  title: 'European Grand Tour & Cultural Expedition Across Many Cities',
  destination: 'Berlin, Deutschland & Wien, Österreich',
  countryCode: 'DE',
  startDate: _now.add(const Duration(days: 3)),
  endDate: _now.add(const Duration(days: 10)),
  budgetLimit: 2500,
  createdAt: _now,
  updatedAt: _now,
);

final _packingItem = PackingItem(
  id: 'polish-item',
  tripId: 'polish-trip',
  name: 'Noise Cancelling Headphones With Extra Long Travel Cable',
  category: 'Electronics',
  quantity: 1,
  isPacked: false,
  createdAt: _now,
  updatedAt: _now,
);

final _document = Document(
  id: 'polish-doc',
  tripId: 'polish-trip',
  title: 'Biometric Passport & International Travel Insurance',
  category: 'Passport',
  subCategory: 'Primary',
  localImagePath: 'test/path/passport.pdf',
  fileType: 'pdf',
  fileSizeBytes: 1024 * 500,
  createdAt: _now,
  updatedAt: _now,
);

final _itineraryItem = ItineraryItem(
  id: 'polish-itin',
  userId: 'polish-user',
  tripId: 'polish-trip',
  dayNumber: 1,
  date: '2026-06-04',
  time: '14:30',
  title: 'Brandenburger Tor and Museum Island Detailed Walking Tour',
  location: 'Pariser Platz, 10117 Berlin, Deutschland',
  description: 'Meeting point at the northern gate.',
  category: 'sightseeing',
  cost: 25.50,
  currency: 'EUR',
  isCompleted: false,
  createdAt: _now,
  updatedAt: _now,
);

const _sizes = <Size>[Size(320, 568), Size(412, 915)];

Widget _scope({
  required Widget home,
  required ThemeData theme,
  SyncState syncState = const SyncState(status: SyncStatus.upToDate),
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      localeProvider.overrideWith((ref) => _FakeLocaleNotifier(locale)),
      authUserProvider.overrideWithValue(_FakeUser()),
      tripControllerProvider.overrideWith(
        (ref) => _FakeTripController(TripState(isLoading: false, trips: [_trip])),
      ),
      checklistControllerProvider.overrideWith(
        (ref) => _FakeChecklistNotifier(ChecklistState(isLoading: false, items: [_packingItem])),
      ),
      vaultControllerProvider.overrideWith(
        (ref) => _FakeVaultController(
          VaultState(isLoading: false, documents: [_document], hasPin: true, isLocked: false),
        ),
      ),
      syncEngineProvider.overrideWith((ref) => _FakeSyncEngine(syncState)),
      proSubscriptionProvider.overrideWith(
        (ref) => _FakeProNotifier(const ProSubscriptionState(isPro: true)),
      ),
      packingRemindersProvider.overrideWith((ref) => _FakePackingRemindersNotifier()),
      itineraryControllerFamily(_trip.id).overrideWith((ref) {
        final controller = ItineraryController(ref, _trip.id);
        controller.state = ItineraryState(
          tripId: _trip.id,
          selectedDay: 1,
          totalDays: 8,
          items: [_itineraryItem],
        );
        return controller;
      }),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Lets layout, post-frame callbacks and short entrance animations finish
/// without pumpAndSettle (some screens host indefinite indicators).
Future<void> _settleFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 400));
}

/// Removes the tree and asserts no ticker / transient frame callback leaked.
Future<void> _expectNoTickerLeak(WidgetTester tester, String label) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  expect(tester.takeException(), isNull, reason: '$label threw while being disposed');
  expect(
    SchedulerBinding.instance.transientCallbackCount,
    0,
    reason: '$label left an active Ticker after removal',
  );
}

Widget _motionHost(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, appChild) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
      child: appChild!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    await PreferencesService.init();
    await PreferencesService.instance.setOnboardingCompleted(true);
    await PreferencesService.instance.setLegalConsentAccepted(true, uid: 'polish-user');
  });

  // -------------------------------------------------------------------------
  // 1. Light & dark × 320x568 / 412x915: zero overflow, zero exceptions
  // -------------------------------------------------------------------------
  group('1. Screens & sheets render cleanly in light/dark at compact and large sizes', () {
    final themes = <String, ThemeData>{
      'Light': AppTheme.lightTheme,
      'Dark': AppTheme.darkTheme,
    };

    final targets = <String, Widget Function()>{
      'DashboardScreen': () => const DashboardScreen(),
      'TripsScreen': () => const TripsScreen(),
      'ChecklistScreen': () => const ChecklistScreen(),
      'VaultScreen': () => const VaultScreen(),
      'ItineraryScreen': () => ItineraryScreen(trip: _trip),
      'FriendsScreen': () => const FriendsScreen(),
      'CurrencyPickerSheet': () => const Scaffold(
            body: CurrencyPickerSheet(selectedCurrency: 'EUR', defaultCurrency: 'TRY'),
          ),
      'AirlineGuideSheet': () => const Scaffold(body: AirlineGuideSheet()),
      'VaultPinRecoverySheet': () => const Scaffold(
            body: VaultPinRecoverySheet(testVerificationCode: '123456'),
          ),
    };

    for (final themeEntry in themes.entries) {
      for (final size in _sizes) {
        for (final target in targets.entries) {
          final label = '${target.key} ${themeEntry.key} ${size.width.toInt()}x${size.height.toInt()}';
          testWidgets('$label renders without overflow or exceptions', (tester) async {
            _setViewport(tester, size);
            // The Vault variant also carries the quota banner so the band is
            // covered at both sizes and in both themes.
            final syncState = target.key == 'VaultScreen'
                ? const SyncState(
                    status: SyncStatus.upToDate,
                    isCloudQuotaExceeded: true,
                    quotaSkippedFiles: 12,
                  )
                : const SyncState(status: SyncStatus.upToDate);

            await tester.pumpWidget(
              _scope(home: target.value(), theme: themeEntry.value, syncState: syncState),
            );
            await _settleFrames(tester);

            expect(tester.takeException(), isNull, reason: '$label overflowed or threw');
            if (target.key == 'VaultScreen') {
              expect(find.byKey(const ValueKey('vault_cloud_quota_banner')), findsOneWidget);
            }
          });
        }
      }
    }
  });

  // -------------------------------------------------------------------------
  // 2. Real motion: no leaked Ticker, and disableAnimations is respected
  // -------------------------------------------------------------------------
  group('2. Animated widgets leave no active Ticker (real motion)', () {
    setUp(() => AppMotion.debugForceReducedMotion = false);
    tearDown(() => AppMotion.debugForceReducedMotion = true);

    final avatar = AnimalAvatar.all.first;

    final animated = <String, Widget Function()>{
      'AppPulse': () => const AppPulse(child: Icon(Icons.favorite)),
      'AppFloatingIllustration': () => const AppFloatingIllustration(child: Icon(Icons.luggage)),
      'AnimalAvatarWidget': () => AnimalAvatarWidget(avatar: avatar, size: 64),
      'AppSkeleton': () => const SizedBox(
            width: 300,
            height: 400,
            child: AppSkeletonList(itemCount: 3),
          ),
      'AppFadeSlide': () => const AppFadeSlide(
            delay: Duration(milliseconds: 120),
            child: Text('fade'),
          ),
    };

    for (final entry in animated.entries) {
      testWidgets('${entry.key} animates and disposes without a leaked Ticker', (tester) async {
        await tester.pumpWidget(_motionHost(entry.value()));
        await tester.pump(const Duration(milliseconds: 16));
        // Real motion is running: repeating animations keep frames scheduled.
        if (entry.key != 'AppFadeSlide') {
          expect(
            SchedulerBinding.instance.transientCallbackCount,
            greaterThan(0),
            reason: '${entry.key} should animate when reduced motion is off',
          );
        }
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pump(const Duration(milliseconds: 700));
        expect(tester.takeException(), isNull);
        await _expectNoTickerLeak(tester, entry.key);
      });

      testWidgets('${entry.key} is static with MediaQuery(disableAnimations: true)', (tester) async {
        await tester.pumpWidget(_motionHost(entry.value(), disableAnimations: true));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        expect(
          SchedulerBinding.instance.transientCallbackCount,
          0,
          reason: '${entry.key} must not animate when animations are disabled',
        );
        await _expectNoTickerLeak(tester, '${entry.key} (disableAnimations)');
      });
    }

    testWidgets('StatusBadge survives repeated spin start/stop cycles', (tester) async {
      var spinning = false;
      late StateSetter setOuter;
      await tester.pumpWidget(
        _motionHost(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return StatusBadge(
                label: 'Syncing',
                icon: Icons.sync_rounded,
                backgroundColor: Colors.amber.shade100,
                textColor: Colors.brown,
                isSpinning: spinning,
              );
            },
          ),
        ),
      );

      for (var i = 0; i < 6; i++) {
        setOuter(() => spinning = !spinning);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull, reason: 'cycle $i threw');
        if (spinning) {
          expect(SchedulerBinding.instance.transientCallbackCount, greaterThan(0));
        }
      }

      // End while spinning so disposal of a running controller is exercised.
      setOuter(() => spinning = true);
      await tester.pump(const Duration(milliseconds: 100));
      await _expectNoTickerLeak(tester, 'StatusBadge');
    });

    testWidgets('StatusBadge does not spin with disableAnimations', (tester) async {
      await tester.pumpWidget(
        _motionHost(
          StatusBadge(
            label: 'Syncing',
            icon: Icons.sync_rounded,
            backgroundColor: Colors.amber.shade100,
            textColor: Colors.brown,
            isSpinning: true,
          ),
          disableAnimations: true,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(SchedulerBinding.instance.transientCallbackCount, 0);
      await _expectNoTickerLeak(tester, 'StatusBadge (disableAnimations)');
    });

    testWidgets('AppCard toggles onTap null <-> non-null without ticker errors', (tester) async {
      VoidCallback? onTap = () {};
      late StateSetter setOuter;
      await tester.pumpWidget(
        _motionHost(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return SizedBox(
                width: 260,
                child: AppCard(
                  onTap: onTap,
                  child: const Padding(padding: EdgeInsets.all(16), child: Text('card')),
                ),
              );
            },
          ),
        ),
      );

      for (var i = 0; i < 6; i++) {
        if (onTap != null) {
          // Press mid-animation, then drop onTap while the press is held.
          final gesture = await tester.startGesture(tester.getCenter(find.text('card')));
          await tester.pump(const Duration(milliseconds: 40));
          setOuter(() => onTap = null);
          await tester.pump();
          await gesture.up();
        } else {
          setOuter(() => onTap = () {});
        }
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: 'cycle $i threw');
      }

      await _expectNoTickerLeak(tester, 'AppCard');
    });

    testWidgets('AppStateSwitcher cross-fades states and disposes cleanly', (tester) async {
      var state = 'loading';
      late StateSetter setOuter;
      await tester.pumpWidget(
        _motionHost(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return SizedBox(
                width: 300,
                height: 400,
                child: AppStateSwitcher(
                  stateKey: state,
                  child: state == 'loading'
                      ? const AppSkeletonList(itemCount: 2)
                      : Text('state:$state'),
                ),
              );
            },
          ),
        ),
      );

      for (final next in ['empty', 'content', 'loading', 'content']) {
        setOuter(() => state = next);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));
        // Mid-transition: the switcher's own animation is running.
        expect(SchedulerBinding.instance.transientCallbackCount, greaterThan(0));
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);
      }
      expect(find.text('state:content'), findsOneWidget);

      await _expectNoTickerLeak(tester, 'AppStateSwitcher');
    });

    testWidgets('AppStateSwitcher swaps instantly with disableAnimations', (tester) async {
      var state = 'a';
      late StateSetter setOuter;
      await tester.pumpWidget(
        _motionHost(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return AppStateSwitcher(stateKey: state, child: Text('state:$state'));
            },
          ),
          disableAnimations: true,
        ),
      );

      setOuter(() => state = 'b');
      await tester.pump();
      await tester.pump();
      expect(find.text('state:b'), findsOneWidget);
      expect(find.text('state:a'), findsNothing);
      expect(tester.takeException(), isNull);
      await _expectNoTickerLeak(tester, 'AppStateSwitcher (disableAnimations)');
    });
  });

  // -------------------------------------------------------------------------
  // 3. Vault cloud quota banner
  // -------------------------------------------------------------------------
  group('3. VaultCloudQuotaBanner', () {
    Widget bannerHost(SyncState syncState, {Locale locale = const Locale('en')}) {
      return ProviderScope(
        overrides: [
          syncEngineProvider.overrideWith((ref) => _FakeSyncEngine(syncState)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: VaultCloudQuotaBanner()),
        ),
      );
    }

    const bannerKey = ValueKey('vault_cloud_quota_banner');

    testWidgets('hidden when quota is not exceeded', (tester) async {
      await tester.pumpWidget(bannerHost(const SyncState()));
      await tester.pump();
      expect(find.byKey(bannerKey), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('visible with the zero-skipped copy when quotaSkippedFiles == 0', (tester) async {
      await tester.pumpWidget(bannerHost(const SyncState(isCloudQuotaExceeded: true)));
      await tester.pump();
      expect(find.byKey(bannerKey), findsOneWidget);
      expect(find.text('Cloud storage is full'), findsOneWidget);
      expect(
        find.text('New documents are kept on this device until cloud space is available.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('visible with the singular copy when quotaSkippedFiles == 1', (tester) async {
      await tester.pumpWidget(
        bannerHost(const SyncState(isCloudQuotaExceeded: true, quotaSkippedFiles: 1)),
      );
      await tester.pump();
      expect(find.byKey(bannerKey), findsOneWidget);
      expect(
        find.text("1 document wasn't backed up and is kept on this device only."),
        findsOneWidget,
      );
    });

    testWidgets('visible with the plural copy when quotaSkippedFiles > 1', (tester) async {
      await tester.pumpWidget(
        bannerHost(const SyncState(isCloudQuotaExceeded: true, quotaSkippedFiles: 7)),
      );
      await tester.pump();
      expect(find.byKey(bannerKey), findsOneWidget);
      expect(
        find.text("7 documents weren't backed up and are kept on this device only."),
        findsOneWidget,
      );
    });

    testWidgets('localized in Turkish', (tester) async {
      await tester.pumpWidget(
        bannerHost(
          const SyncState(isCloudQuotaExceeded: true, quotaSkippedFiles: 3),
          locale: const Locale('tr'),
        ),
      );
      await tester.pump();
      expect(find.byKey(bannerKey), findsOneWidget);
      expect(find.text('3 belge yedeklenemedi, yalnızca bu cihazda saklanıyor.'), findsOneWidget);
    });

    testWidgets('renders a non-empty title and body in all 20 locales', (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        await tester.pumpWidget(
          bannerHost(
            const SyncState(isCloudQuotaExceeded: true, quotaSkippedFiles: 2),
            locale: locale,
          ),
        );
        await tester.pump();
        final l10n = await AppLocalizations.delegate.load(locale);
        expect(l10n.vaultCloudQuotaTitle.trim(), isNotEmpty, reason: '$locale title');
        expect(l10n.vaultCloudQuotaBody(0).trim(), isNotEmpty, reason: '$locale body(0)');
        expect(l10n.vaultCloudQuotaBody(2).trim(), isNotEmpty, reason: '$locale body(2)');
        expect(find.text(l10n.vaultCloudQuotaTitle), findsOneWidget, reason: '$locale banner');
        expect(tester.takeException(), isNull, reason: '$locale threw');
      }
    });

    testWidgets('animates in with real motion and leaves no ticker', (tester) async {
      AppMotion.debugForceReducedMotion = false;
      addTearDown(() => AppMotion.debugForceReducedMotion = true);

      await tester.pumpWidget(
        bannerHost(const SyncState(isCloudQuotaExceeded: true, quotaSkippedFiles: 4)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(bannerKey), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _expectNoTickerLeak(tester, 'VaultCloudQuotaBanner');
    });
  });
}
