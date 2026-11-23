// Faz 3 — 20-language localization audit.
//
// 1. ARB integrity: identical key sets, no empty values, placeholder/ICU parity
//    with the English template.
// 2. Android home-widget strings.xml integrity across values/ + 19 locales.
// 3. Geo data coverage: capitals for every country, 7 non-Latin scripts for
//    every popular city.
// 4. Overflow sweep (all 20 languages x overflowAuditSizes) + RTL (ar) rendering
//    of critical screens and the components that show the longest labels.
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

import 'package:packbuddy/core/l10n/locale_provider.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/core/theme/app_theme.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:packbuddy/features/auth/presentation/screens/legal_consent_screen.dart';
import 'package:packbuddy/features/budget/domain/city_localization.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/trips_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/currency_picker_sheet.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/checklist/presentation/screens/checklist_screen.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/add_packing_item_sheet.dart';
import 'package:packbuddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:packbuddy/features/profile/domain/user_profile.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/edit_profile_sheet.dart';
import 'package:packbuddy/features/profile/presentation/screens/widgets/world_map_profile_card.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/settings_screen.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/features/travel_map/data/capital_localization.dart';
import 'package:packbuddy/features/travel_map/data/world_countries_data.dart';
import 'package:packbuddy/features/travel_map/domain/travel_country.dart';
import 'package:packbuddy/features/vault/domain/document.dart';
import 'package:packbuddy/features/vault/presentation/controllers/vault_controller.dart';
import 'package:packbuddy/features/vault/presentation/screens/vault_screen.dart';
import 'package:packbuddy/features/vault/presentation/screens/widgets/vault_lock_view.dart';
import 'package:packbuddy/l10n/app_localizations.dart';
import 'package:packbuddy/shared/widgets/quick_actions_sheet.dart';

// =============================================================================
// Constants
// =============================================================================

const all20Languages = [
  'ar', 'de', 'el', 'en', 'es', 'fr', 'hi', 'id', 'it', 'ja',
  'ko', 'nl', 'pl', 'pt', 'ru', 'sv', 'th', 'tr', 'vi', 'zh',
];

/// Every critical screen is swept in all 20 languages at each of these sizes:
/// smallest phone, the `< 360` small-screen breakpoint, large phone, tablet.
const overflowAuditSizes = [Size(320, 568), Size(360, 640), Size(412, 915), Size(800, 1280)];

/// Android resource folder per app language (Indonesian uses legacy `in`).
String androidValuesFolder(String lang) {
  if (lang == 'en') return 'values';
  if (lang == 'id') return 'values-in';
  return 'values-$lang';
}

const nonLatinCityScripts = ['ar', 'zh', 'ja', 'el', 'th', 'hi', 'ko'];

// =============================================================================
// Fakes
// =============================================================================

class FakeUser extends Fake implements User {
  @override
  final String uid = 'test-user-id';
  @override
  final String? email = 'tester@packbuddy.app';
  @override
  final String? displayName = 'Master Traveler';
  @override
  final bool emailVerified = true;
  @override
  final List<UserInfo> providerData = const [];
}

class FakeLocaleNotifier extends LocaleNotifier {
  FakeLocaleNotifier(Locale initial) : super() {
    state = initial;
  }
}

class FakeTripController extends StateNotifier<TripState> implements TripController {
  FakeTripController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeChecklistNotifier extends StateNotifier<ChecklistState> implements ChecklistNotifier {
  FakeChecklistNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeVaultController extends StateNotifier<VaultState> implements VaultController {
  FakeVaultController(super.state);

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

class FakeSyncEngine extends StateNotifier<SyncState> implements SyncEngine {
  FakeSyncEngine(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

class FakeRevenueCatNotifier extends StateNotifier<ProSubscriptionState> implements MockRevenueCatNotifier {
  FakeRevenueCatNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

/// Opens a real quick-actions overlay (the floating bubbles users actually see)
/// right after the first frame, so the overflow sweep measures it.
class _QuickActionsOpener extends ConsumerStatefulWidget {
  const _QuickActionsOpener(this.open);

  final Future<void> Function(BuildContext context, WidgetRef ref) open;

  @override
  ConsumerState<_QuickActionsOpener> createState() => _QuickActionsOpenerState();
}

class _QuickActionsOpenerState extends ConsumerState<_QuickActionsOpener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.open(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.expand());
}

class FakePackingRemindersNotifier extends StateNotifier<bool> implements PackingRemindersNotifier {
  FakePackingRemindersNotifier() : super(true);

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}

// =============================================================================
// ARB helpers
// =============================================================================

Map<String, Map<String, dynamic>> loadAllArbs() {
  final result = <String, Map<String, dynamic>>{};
  for (final lang in all20Languages) {
    final file = File('lib/l10n/app_$lang.arb');
    expect(file.existsSync(), isTrue, reason: 'missing lib/l10n/app_$lang.arb');
    result[lang] = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }
  return result;
}

Set<String> messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

Set<String> declaredPlaceholders(Map<String, dynamic> enArb, String key) {
  final meta = enArb['@$key'];
  if (meta is Map && meta['placeholders'] is Map) {
    return (meta['placeholders'] as Map).keys.cast<String>().toSet();
  }
  return const {};
}

bool isIcuMessage(String value) => RegExp(r'\{\s*\w+\s*,\s*(plural|select)\s*,').hasMatch(value);

Set<String> simplePlaceholderTokens(String value) =>
    RegExp(r'\{([A-Za-z_]\w*)\}').allMatches(value).map((m) => m[1]!).toSet();

bool bracesBalanced(String value) {
  var depth = 0;
  for (final ch in value.runes) {
    if (ch == 0x7B) depth++;
    if (ch == 0x7D) depth--;
    if (depth < 0) return false;
  }
  return depth == 0;
}

// =============================================================================
// Overflow capture
// =============================================================================

/// Runs [body] while recording every layout-overflow error reported through
/// [FlutterError.onError]. Any other error is forwarded so the test still fails.
Future<List<String>> captureOverflows(Future<void> Function() body) async {
  final overflows = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('overflowed')) {
      final source = RegExp(r'(lib/[\w/]+\.dart:\d+)')
          .firstMatch(details.toString().replaceAll('\\', '/'))
          ?.group(1);
      overflows.add('${text.split('\n').first}${source != null ? ' @ $source' : ''}');
    } else {
      previous?.call(details);
    }
  };
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
  return overflows;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // 1. ARB integrity
  // ---------------------------------------------------------------------------
  group('1. ARB integrity across 20 languages', () {
    late Map<String, Map<String, dynamic>> arbs;
    late Set<String> enKeys;

    setUpAll(() {
      arbs = loadAllArbs();
      enKeys = messageKeys(arbs['en']!);
    });

    test('exactly 20 ARB files exist and match supportedLocales', () {
      final files = Directory('lib/l10n')
          .listSync()
          .whereType<File>()
          .where((f) => RegExp(r'app_[a-z]{2}\.arb$').hasMatch(f.path.replaceAll('\\', '/')))
          .toList();
      expect(files.length, 20);
      final supported = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
      expect(supported, all20Languages.toSet());
    });

    test('every language has the same keys as app_en.arb (0 missing, 0 orphan)', () {
      final problems = <String>[];
      for (final lang in all20Languages) {
        final keys = messageKeys(arbs[lang]!);
        final missing = enKeys.difference(keys);
        final orphan = keys.difference(enKeys);
        if (missing.isNotEmpty) problems.add('$lang missing ${missing.length}: ${missing.take(10).join(', ')}');
        if (orphan.isNotEmpty) problems.add('$lang orphan ${orphan.length}: ${orphan.take(10).join(', ')}');
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('no empty values in any language', () {
      final problems = <String>[];
      for (final lang in all20Languages) {
        for (final key in messageKeys(arbs[lang]!)) {
          final value = arbs[lang]![key];
          if (value is! String || value.trim().isEmpty) problems.add('$lang.$key');
        }
      }
      expect(problems, isEmpty, reason: 'Empty values: ${problems.take(30).join(', ')}');
    });

    test('placeholders and ICU structure match app_en.arb in all 20 languages', () {
      final en = arbs['en']!;
      final problems = <String>[];
      for (final key in enKeys) {
        final enValue = en[key] as String;
        final declared = declaredPlaceholders(en, key);
        final enIcu = isIcuMessage(enValue);
        for (final lang in all20Languages) {
          final value = arbs[lang]![key];
          if (value is! String) continue; // reported by the key-parity test
          if (!bracesBalanced(value)) {
            problems.add('$lang.$key: unbalanced braces');
            continue;
          }
          for (final p in declared) {
            if (!RegExp('\\{\\s*$p\\s*[,}]').hasMatch(value)) {
              problems.add('$lang.$key: missing {$p}');
            }
          }
          if (enIcu != isIcuMessage(value)) {
            problems.add('$lang.$key: ICU plural/select mismatch');
          } else if (enIcu) {
            if (!value.contains('other{') && !RegExp(r'other\s*\{').hasMatch(value)) {
              problems.add('$lang.$key: ICU message without "other" branch');
            }
          } else {
            final extra = simplePlaceholderTokens(value).difference(declared);
            if (extra.isNotEmpty) problems.add('$lang.$key: unknown placeholder(s) $extra');
          }
        }
      }
      expect(problems, isEmpty, reason: problems.take(40).join('\n'));
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Android strings.xml integrity
  // ---------------------------------------------------------------------------
  group('2. Android widget strings.xml integrity (values + 19 locales)', () {
    const resRoot = 'android/app/src/main/res';

    Map<String, String> parseStrings(String lang) {
      final file = File('$resRoot/${androidValuesFolder(lang)}/strings.xml');
      expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');
      final doc = XmlDocument.parse(file.readAsStringSync()); // throws on invalid XML
      expect(doc.rootElement.name.local, 'resources');
      final map = <String, String>{};
      for (final el in doc.rootElement.findElements('string')) {
        if (el.getAttribute('translatable') == 'false') continue;
        final name = el.getAttribute('name');
        expect(name, isNotNull);
        expect(map.containsKey(name), isFalse, reason: 'duplicate $name in $lang');
        map[name!] = el.innerText;
      }
      return map;
    }

    test('all 20 files are valid XML with the same 52 non-empty keys', () {
      final en = parseStrings('en');
      expect(en.length, 52);
      final problems = <String>[];
      for (final lang in all20Languages) {
        final map = parseStrings(lang);
        final missing = en.keys.toSet().difference(map.keys.toSet());
        final orphan = map.keys.toSet().difference(en.keys.toSet());
        if (missing.isNotEmpty) problems.add('$lang missing: $missing');
        if (orphan.isNotEmpty) problems.add('$lang orphan: $orphan');
        map.forEach((k, v) {
          if (v.trim().isEmpty) problems.add('$lang.$k empty');
          final enHasFormat = en[k]?.contains(r'%1$d') ?? false;
          if (enHasFormat != v.contains(r'%1$d')) problems.add('$lang.$k format arg mismatch');
        });
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });

    test('brand string exists once in the default values only', () {
      final doc = XmlDocument.parse(File('$resRoot/values/strings.xml').readAsStringSync());
      final brand = doc.rootElement
          .findElements('string')
          .where((e) => e.getAttribute('name') == 'widget_brand')
          .toList();
      expect(brand.length, 1);
      expect(brand.single.getAttribute('translatable'), 'false');
    });

    test('manifest widget labels and layouts reference string resources', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      final widgetLabels = RegExp(r'android:label="([^"]*)"')
          .allMatches(manifest)
          .map((m) => m[1]!)
          .where((l) => l.startsWith('PackBuddy:') || l.startsWith('@string/widget_label'))
          .toList();
      expect(widgetLabels.length, 12);
      expect(widgetLabels.every((l) => l.startsWith('@string/')), isTrue, reason: '$widgetLabels');

      final turkishLiteral = RegExp(r'android:text="[^"@]*[çğışöüÇĞİŞÖÜ][^"]*"');
      final offenders = Directory('$resRoot/layout')
          .listSync()
          .whereType<File>()
          .where((f) => turkishLiteral.hasMatch(f.readAsStringSync()))
          .map((f) => f.path)
          .toList();
      expect(offenders, isEmpty, reason: 'Hard-coded Turkish layout text in $offenders');
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Geo data coverage
  // ---------------------------------------------------------------------------
  group('3. Geographic data coverage', () {
    test('CapitalLocalization covers every country in WorldCountriesData', () {
      const missingMarker = '__MISSING__';
      final missing = <String>[];
      for (final c in WorldCountriesData.allCountries) {
        final en = CapitalLocalization.getCapitalName(c.code, 'en', fallback: missingMarker);
        if (en == missingMarker || en.trim().isEmpty) missing.add(c.code);
        for (final lang in all20Languages) {
          final name = CapitalLocalization.getCapitalName(c.code, lang, fallback: missingMarker);
          if (name == missingMarker || name.trim().isEmpty) missing.add('${c.code}/$lang');
        }
      }
      expect(missing, isEmpty, reason: 'Capitals missing: ${missing.take(30).join(', ')}');
    });

    test('CityLocalization has 285 cities with all 7 non-Latin scripts filled', () {
      final cities = CityLocalization.popularCities;
      expect(cities.length, 285);
      final ids = cities.map((c) => c.id).toSet();
      expect(ids.length, cities.length, reason: 'Duplicate city ids');

      final missing = <String>[];
      for (final city in cities) {
        for (final script in nonLatinCityScripts) {
          final v = city.names[script];
          if (v == null || v.trim().isEmpty) missing.add('${city.id}/$script');
        }
      }
      expect(missing, isEmpty, reason: 'Missing scripts: ${missing.take(40).join(', ')}');
    });
  });

  // ---------------------------------------------------------------------------
  // 4. Overflow (all 20 languages x overflowAuditSizes) + RTL
  // ---------------------------------------------------------------------------
  group('4. Overflow & RTL in all 20 languages', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'packbuddy_is_pro_member': false,
        'theme_mode': 'light',
      });
      await PreferencesService.init();
      await PreferencesService.instance.setOnboardingCompleted(true);
      await PreferencesService.instance.setLegalConsentAccepted(true, uid: 'test-user-id');
    });

    final now = DateTime(2026, 6, 1);
    final trip = Trip(
      id: 'trip-1',
      userId: 'test-user-id',
      title: 'European Grand Tour & Cultural Expedition',
      destination: 'Berlin, Deutschland & Wien, Österreich',
      countryCode: 'DE',
      startDate: now.add(const Duration(days: 3)),
      endDate: now.add(const Duration(days: 10)),
      budgetLimit: 2500,
      transportMode: 'uçak',
      createdAt: now,
      updatedAt: now,
    );
    // Trip status follows the real clock: these dates always show the "ongoing" badge, the
    // longest header label (it overflowed 320px in id/pt/th/tr/vi before it was width-capped).
    final today = DateTime.now();
    final ongoingTrip = trip.copyWith(
      id: 'trip-ongoing',
      startDate: today.subtract(const Duration(days: 1)),
      endDate: today.add(const Duration(days: 3)),
    );
    final item = PackingItem(
      id: 'item-1',
      tripId: 'trip-1',
      name: 'Noise Cancelling Headphones',
      category: 'Electronics',
      quantity: 2,
      isPacked: false,
      createdAt: now,
      updatedAt: now,
    );
    final doc = Document(
      id: 'doc-1',
      tripId: 'trip-1',
      title: 'Biometric Passport & International Travel Insurance',
      category: 'Passport',
      subCategory: 'Primary',
      localImagePath: 'test/path/passport.pdf',
      fileType: 'pdf',
      fileSizeBytes: 1024 * 500,
      createdAt: now,
      updatedAt: now,
    );
    final failedSync = SyncState(
      status: SyncStatus.failed,
      lastSyncTime: now,
      errorMessage: 'network_unreachable',
    );
    final countries = WorldCountriesData.allCountries.map((c) {
      if (c.code == 'TR') return c.copyWith(status: CountryStatus.lived);
      if (['FR', 'DE', 'GR', 'JP', 'BR'].contains(c.code)) return c.copyWith(status: CountryStatus.visited);
      if (['NO', 'IS', 'NZ'].contains(c.code)) return c.copyWith(status: CountryStatus.wishlist);
      return c;
    }).toList();

    Widget scope({
      required String lang,
      required Widget home,
      VaultState? vault,
      SyncState? sync,
    }) {
      final locale = Locale(lang);
      return ProviderScope(
        overrides: [
          localeProvider.overrideWith((ref) => FakeLocaleNotifier(locale)),
          authUserProvider.overrideWithValue(FakeUser()),
          tripControllerProvider.overrideWith(
            (ref) => FakeTripController(TripState(isLoading: false, trips: [trip])),
          ),
          checklistControllerProvider.overrideWith(
            (ref) => FakeChecklistNotifier(ChecklistState(isLoading: false, items: [item])),
          ),
          vaultControllerProvider.overrideWith(
            (ref) => FakeVaultController(vault ?? VaultState(isLoading: false, documents: [doc])),
          ),
          syncEngineProvider.overrideWith((ref) => FakeSyncEngine(sync ?? failedSync)),
          proSubscriptionProvider.overrideWith(
            (ref) => FakeRevenueCatNotifier(const ProSubscriptionState(isPro: false)),
          ),
          packingRemindersProvider.overrideWith((ref) => FakePackingRemindersNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      );
    }

    /// name -> builder(lang). Each is rendered in every stress language.
    final cases = <String, Widget Function(String lang)>{
      'PaywallSheet': (l) => scope(lang: l, home: const Scaffold(body: PaywallSheet())),
      'LegalConsentScreen': (l) => scope(lang: l, home: const LegalConsentScreen(isMandatoryGate: true)),
      'WorldMapProfileCard (own)': (l) => scope(
            lang: l,
            home: Scaffold(
              body: SingleChildScrollView(
                child: WorldMapProfileCard(countries: countries, isOwnProfile: true, onOpenMap: () {}),
              ),
            ),
          ),
      'WorldMapProfileCard (friend)': (l) => scope(
            lang: l,
            home: Scaffold(
              body: SingleChildScrollView(
                child: WorldMapProfileCard(
                  countries: countries,
                  isOwnProfile: false,
                  friendName: 'Konstantinos Papadopoulos',
                  mutualVisitedCodes: const ['TR', 'FR', 'DE'],
                ),
              ),
            ),
          ),
      'CurrencyPickerSheet': (l) => scope(
            lang: l,
            home: const Scaffold(body: CurrencyPickerSheet(selectedCurrency: 'EUR', defaultCurrency: 'TRY')),
          ),
      'EditProfileSheet': (l) => scope(
            lang: l,
            home: Scaffold(
              body: EditProfileSheet(
                profile: UserProfile(
                  uid: 'test-user-id',
                  displayName: 'Maximilian Schwarzenberger',
                  email: 'tester@packbuddy.app',
                  createdAt: DateTime(2025, 5, 1),
                ),
                languageCode: l,
              ),
            ),
          ),
      'VaultLockView (PIN)': (l) => scope(
            lang: l,
            vault: const VaultState(isLoading: false, isLocked: true, hasPin: true),
            home: const Scaffold(body: VaultLockView()),
          ),
      'VaultLockView (no PIN)': (l) => scope(
            lang: l,
            vault: const VaultState(isLoading: false, isLocked: true, hasPin: false),
            home: const Scaffold(body: VaultLockView()),
          ),
      // Long labels: syncNow, lastSync, syncFailed
      'SettingsScreen (sync failed)': (l) => scope(lang: l, home: const SettingsScreen()),
      // Long labels: syncNow, syncFailed, addTrip
      'DashboardScreen (sync failed)': (l) => scope(lang: l, home: const DashboardScreen()),
      // Long labels: addTrip, flight
      'TripsScreen': (l) => scope(lang: l, home: const TripsScreen()),
      // Long label: ongoingTrip status badge next to the destination
      'TripDetailScreen (ongoing trip)': (l) => scope(lang: l, home: TripDetailScreen(trip: ongoingTrip)),
      // Long label: addItem
      'ChecklistScreen': (l) => scope(lang: l, home: const ChecklistScreen(tripId: 'trip-1', tripTitle: 'European Grand Tour')),
      'AddPackingItemSheet (add)': (l) => scope(lang: l, home: const Scaffold(body: AddPackingItemSheet(tripId: 'trip-1'))),
      // Long label: editItem
      'AddPackingItemSheet (edit)': (l) => scope(
            lang: l,
            home: Scaffold(body: AddPackingItemSheet(tripId: 'trip-1', itemToEdit: item)),
          ),
      // Long labels: tapToView, lockVault
      'VaultScreen (unlocked)': (l) => scope(
            lang: l,
            vault: VaultState(isLoading: false, isLocked: false, hasPin: true, documents: [doc]),
            home: const VaultScreen(),
          ),
      // Long label: emailVerifyResendCooldown
      'EmailVerificationScreen': (l) => scope(lang: l, home: const EmailVerificationScreen()),
      // Real quick-actions overlays (floating bubbles): every preset label.
      'QuickActions overlay (dashboard)': (l) => scope(
            lang: l,
            home: _QuickActionsOpener((c, ref) => QuickActionsSheet.showForDashboard(c, ref: ref)),
          ),
      'QuickActions overlay (trips)': (l) => scope(
            lang: l,
            home: _QuickActionsOpener((c, _) => QuickActionsSheet.showForTrips(c)),
          ),
      'QuickActions overlay (vault)': (l) => scope(
            lang: l,
            home: _QuickActionsOpener((c, _) => QuickActionsSheet.showForVault(c)),
          ),
      'QuickActions overlay (checklist)': (l) => scope(
            lang: l,
            home: _QuickActionsOpener(
              (c, _) => QuickActionsSheet.showForChecklist(c, tripId: 'trip-1', tripTitle: 'European Grand Tour'),
            ),
          ),
      // Long labels: addTrip, addItem inside quick-action rows
      'QuickActionsSheet': (l) {
        final t = lookupAppLocalizations(Locale(l));
        return scope(
          lang: l,
          home: Scaffold(
            body: QuickActionsSheet(
              title: t.syncNow,
              subtitle: '${t.lastSync}: 01.06.2026 12:00',
              items: [
                for (final label in [t.addTrip, t.addItem, t.editItem, t.lockVault, t.tapToView, t.flight])
                  QuickActionItem(
                    icon: Icons.add_rounded,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue.withValues(alpha: 0.1),
                    title: label,
                    subtitle: t.emailVerifyResendCooldown(59),
                    onTap: () {},
                  ),
              ],
            ),
          ),
        );
      },
    };

    for (final entry in cases.entries) {
      for (final size in overflowAuditSizes) {
        final sizeLabel = '${size.width.toInt()}x${size.height.toInt()}';
        testWidgets('${entry.key} renders on $sizeLabel without overflow in all 20 languages', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final failures = <String>[];
          for (final lang in all20Languages) {
            final overflows = await captureOverflows(() async {
              // Unique key per language: re-pumping an unkeyed ProviderScope
              // reuses its container, so `localeProvider.overrideWith` (like every
              // other `overrideWith` notifier) would stay on the first language.
              await tester.pumpWidget(KeyedSubtree(key: ValueKey(lang), child: entry.value(lang)));
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 300));
            });
            for (final o in overflows) {
              failures.add('[$lang] $o');
            }

            // Harness guard: the fresh scope must really run in this language.
            final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)), listen: false);
            final providerLang = container.read(localeProvider).languageCode;
            if (providerLang != lang) failures.add('[$lang] localeProvider is still $providerLang');

            // RTL: Arabic must lay out right-to-left inside the rendered tree.
            final scaffoldFinder = find.byType(Scaffold);
            if (scaffoldFinder.evaluate().isNotEmpty) {
              final dir = Directionality.of(tester.element(scaffoldFinder.first));
              final expected = lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;
              if (dir != expected) failures.add('[$lang] text direction is $dir, expected $expected');
            }
          }

          // Dispose timers/animations before the next case.
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 1));

          expect(failures, isEmpty, reason: '${entry.key} @ $sizeLabel:\n${failures.join('\n')}');
        });
      }
    }
  });
}
