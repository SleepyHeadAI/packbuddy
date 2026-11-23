// ignore_for_file: subtype_of_sealed_class, must_be_immutable
// Paket B (DB v16): payer attribution, exchange rate frozen at entry, trip crew leave / purge.
// Runs against a real in-memory SQLite (sqflite_common_ffi) and hand-written Firestore fakes.
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:packbuddy/core/constants/app_constants.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/services/notification_service.dart';
import 'package:packbuddy/core/services/preferences_service.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';
import 'package:packbuddy/features/auth/auth_controller.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/screens/trip_detail_screen.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/budget_analytics_card.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/trip_members_sheet.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/itinerary/domain/itinerary_item.dart';
import 'package:packbuddy/features/profile/domain/friendship.dart';
import 'package:packbuddy/features/profile/presentation/controllers/friends_controller.dart';
import 'package:packbuddy/features/profile/presentation/controllers/profile_controller.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeUser extends Fake implements User {
  _FakeUser(this.uid, {this.email});
  @override
  final String uid;
  @override
  final String? email;
  @override
  bool get emailVerified => true;
  @override
  String? get displayName => null;
}

class _FakeAuth extends Fake implements FirebaseAuth {
  _FakeAuth(this.currentUser);
  @override
  User? currentUser;
}

class _FakeSnap extends Fake implements DocumentSnapshot<Map<String, dynamic>> {
  _FakeSnap(this.exists);
  @override
  final bool exists;
}

class _FakeQuery extends Fake implements Query<Map<String, dynamic>> {
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) =>
      const Stream.empty();
}

class _FakeDoc extends Fake implements DocumentReference<Map<String, dynamic>> {
  Map<Object, Object?>? lastUpdate;
  Object? updateError;
  Object? getError;
  bool readable = false;
  int getCalls = 0;

  @override
  Future<void> update(Map<Object, Object?> data) async {
    if (updateError != null) throw updateError!;
    lastUpdate = data;
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    getCalls++;
    if (getError != null) throw getError!;
    return _FakeSnap(readable);
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) =>
      const Stream.empty();
}

class _FakeCollection extends Fake implements CollectionReference<Map<String, dynamic>> {
  final Map<String, _FakeDoc> docs = {};

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) => docs.putIfAbsent(path ?? '', _FakeDoc.new);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      invocation.memberName == #where ? _FakeQuery() : super.noSuchMethod(invocation);
}

class _FakeFirestore extends Fake implements FirebaseFirestore {
  final Map<String, _FakeCollection> collections = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      collections.putIfAbsent(collectionPath, _FakeCollection.new);

  _FakeDoc tripDoc(String id) => collection('trips').doc(id) as _FakeDoc;
}

/// Records leave calls; on success it purges like the real engine does.
class _FakeSyncEngine extends StateNotifier<SyncState> implements SyncEngine {
  _FakeSyncEngine() : super(const SyncState());
  bool leaveResult = true;
  final List<(String, List<String>)> leaveCalls = [];

  @override
  Future<bool> leaveSharedTrip(String tripId, List<String> identities) async {
    leaveCalls.add((tripId, identities));
    if (leaveResult) await DatabaseHelper.instance.purgeLocalSharedTrip(tripId);
    return leaveResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeNotifications extends Fake implements INotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeProfileController extends StateNotifier<ProfileState> implements ProfileController {
  _FakeProfileController() : super(const ProfileState());
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeTripController extends StateNotifier<TripState> implements TripController {
  _FakeTripController(Trip trip) : super(TripState(trips: [trip]));
  int leaveCalls = 0;

  @override
  Future<bool> leaveTrip(String tripId) async {
    leaveCalls++;
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeFriendsController extends StateNotifier<FriendsState> implements FriendsController {
  _FakeFriendsController()
      : super(const FriendsState(friends: [
          FriendUserSummary(uid: 'friend-uid', displayName: 'Ahmet Yılmaz', username: 'ahmet'),
        ]));
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeExpenseController extends StateNotifier<ExpenseState> implements ExpenseController {
  _FakeExpenseController(List<Expense> expenses) : super(ExpenseState(expenses: expenses));
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _FakeChecklistNotifier extends StateNotifier<ChecklistState> implements ChecklistNotifier {
  _FakeChecklistNotifier() : super(const ChecklistState(items: [], isLoading: false));
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _now = DateTime(2026, 11, 20, 12);

Trip _trip(String id, {String userId = 'owner-uid', List<String> collaborators = const []}) => Trip(
      id: id,
      userId: userId,
      title: 'Trip $id',
      destination: 'Roma, İtalya',
      startDate: _now,
      endDate: _now.add(const Duration(days: 4)),
      defaultCurrency: 'TRY',
      createdAt: _now,
      updatedAt: _now,
      isShared: collaborators.isNotEmpty,
      collaborators: collaborators,
    );

Expense _expense(
  String id,
  String tripId, {
  double amount = 10,
  String currency = 'EUR',
  String? createdByName,
  String? paidByName,
  double? rate,
  String? snapshot,
}) =>
    Expense(
      id: id,
      userId: 'member-uid',
      tripId: tripId,
      title: 'Expense $id',
      amount: amount,
      currency: currency,
      category: 'Food',
      date: _now,
      createdAt: _now,
      updatedAt: _now,
      createdByName: createdByName,
      paidByName: paidByName,
      exchangeRateToTrip: rate,
      tripCurrencySnapshot: snapshot,
    );

/// A trip with one row in each child table (expenses, checklist_items, itinerary_items).
Future<void> _seedTripWithChildren(Database db, Trip trip) async {
  await db.insert(AppConstants.tableTrips, trip.toMap());
  await db.insert(AppConstants.tableExpenses, _expense('exp-${trip.id}', trip.id).toMap());
  await db.insert(
    AppConstants.tableChecklistItems,
    PackingItem(
      id: 'item-${trip.id}',
      tripId: trip.id,
      name: 'Passport',
      category: 'Documents',
      createdAt: _now,
      updatedAt: _now,
    ).toMap(),
  );
  await db.insert(
    AppConstants.tableItineraryItems,
    ItineraryItem(
      id: 'itin-${trip.id}',
      userId: 'owner-uid',
      tripId: trip.id,
      dayNumber: 1,
      date: '2026-11-20',
      title: 'Colosseum',
      createdAt: _now,
      updatedAt: _now,
    ).toMap(),
  );
}

Future<Map<String, int>> _rowCounts(Database db, String tripId) async {
  Future<int> count(String table, String column) async =>
      (await db.query(table, where: '$column = ?', whereArgs: [tripId])).length;
  return {
    'trips': await count(AppConstants.tableTrips, 'id'),
    'expenses': await count(AppConstants.tableExpenses, 'trip_id'),
    'checklist_items': await count(AppConstants.tableChecklistItems, 'trip_id'),
    'itinerary_items': await count(AppConstants.tableItineraryItems, 'trip_id'),
  };
}

const _allRows = {'trips': 1, 'expenses': 1, 'checklist_items': 1, 'itinerary_items': 1};
const _noRows = {'trips': 0, 'expenses': 0, 'checklist_items': 0, 'itinerary_items': 0};

/// Seeds live rates (against USD) the way CurrencyService persists them.
Future<void> _setLiveRates(Map<String, double> rates) async {
  SharedPreferences.setMockInitialValues({'packbuddy_cached_currency_rates': jsonEncode(rates)});
  CurrencyService.resetToDefaults();
  await CurrencyService.init();
}

Future<Database> _openDb() => databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false, // every call gets its own in-memory database
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await _openDb();
    await DatabaseHelper.instance.createSchemaForTesting(db);
    DatabaseHelper.setDatabaseForTesting(db);
    // 1 EUR = 40 TRY, 1 USD = 36 TRY
    await _setLiveRates({'EUR': 0.9, 'TRY': 36.0, 'USD': 1.0});
    await PreferencesService.init();
  });

  tearDown(() async {
    DatabaseHelper.setDatabaseForTesting(null);
    await db.close();
    CurrencyService.resetToDefaults();
  });

  // -------------------------------------------------------------------------
  group('1. SQLite v15 → v16 migration', () {
    test('databaseVersion is 16 and a fresh schema has the three new expense columns', () async {
      expect(AppConstants.databaseVersion, 16);
      final cols = (await db.rawQuery('PRAGMA table_info(${AppConstants.tableExpenses})'))
          .map((r) => r['name'])
          .toSet();
      expect(cols, containsAll(['paid_by_name', 'exchange_rate_to_trip', 'trip_currency_snapshot']));
    });

    test('upgrade keeps legacy rows intact with NULL payer / rate that fall back safely', () async {
      final legacy = await _openDb();
      addTearDown(legacy.close);
      // v15 expenses table (no v16 columns)
      await legacy.execute('''
        CREATE TABLE ${AppConstants.tableExpenses} (
          id TEXT PRIMARY KEY NOT NULL, user_id TEXT NOT NULL, trip_id TEXT NOT NULL,
          title TEXT NOT NULL, amount REAL NOT NULL, currency TEXT NOT NULL, category TEXT NOT NULL,
          date TEXT NOT NULL, payment_method TEXT, notes TEXT, created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0, created_by_name TEXT,
          order_index INTEGER NOT NULL DEFAULT 0
        )''');
      await legacy.insert(AppConstants.tableExpenses, {
        'id': 'old-1',
        'user_id': 'u1',
        'trip_id': 't1',
        'title': 'Pizza',
        'amount': 10.0,
        'currency': 'EUR',
        'category': 'Food',
        'date': _now.toIso8601String(),
        'created_at': _now.millisecondsSinceEpoch,
        'updated_at': _now.millisecondsSinceEpoch,
        'created_by_name': 'Ayşe',
      });

      await DatabaseHelper.instance.upgradeSchemaForTesting(legacy, 15, 16);

      final rows = await legacy.query(AppConstants.tableExpenses);
      expect(rows, hasLength(1));
      expect(rows.single['title'], 'Pizza');
      expect(rows.single['paid_by_name'], isNull);
      expect(rows.single['exchange_rate_to_trip'], isNull);
      expect(rows.single['trip_currency_snapshot'], isNull);

      final expense = Expense.fromMap(rows.single);
      expect(expense.effectivePayer, 'Ayşe');
      expect(expense.hasLockedRate, isFalse);
      expect(expense.amountIn('TRY'), closeTo(400, 1e-9)); // live: 10 EUR × 40

      // Re-running the upgrade (or the self-heal) must not fail on existing columns.
      await DatabaseHelper.instance.upgradeSchemaForTesting(legacy, 15, 16);
      expect(await legacy.query(AppConstants.tableExpenses), hasLength(1));
    });

    test('DatabaseHelper round-trips the new fields', () async {
      await db.insert(AppConstants.tableTrips, _trip('t1').toMap());
      await DatabaseHelper.instance.insertExpense(
        _expense('e1', 't1', paidByName: 'Ahmet', createdByName: 'Ayşe', rate: 40, snapshot: 'TRY'),
      );
      final loaded = (await DatabaseHelper.instance.getExpenses(tripId: 't1')).single;
      expect(loaded.paidByName, 'Ahmet');
      expect(loaded.exchangeRateToTrip, 40);
      expect(loaded.tripCurrencySnapshot, 'TRY');
    });
  });

  // -------------------------------------------------------------------------
  group('2. Expense model', () {
    test('toJson/fromJson and toMap/fromMap keep payer + frozen rate', () {
      final e = _expense('e1', 't1', paidByName: 'Ahmet', createdByName: 'Ayşe', rate: 40, snapshot: 'TRY');
      for (final copy in [Expense.fromJson(e.toJson()), Expense.fromMap(e.toMap())]) {
        expect(copy.paidByName, 'Ahmet');
        expect(copy.createdByName, 'Ayşe');
        expect(copy.exchangeRateToTrip, 40);
        expect(copy.tripCurrencySnapshot, 'TRY');
      }
      final json = e.toJson();
      expect(json['paid_by_name'], 'Ahmet');
      expect(json['paidByName'], 'Ahmet');
      expect(json['exchange_rate_to_trip'], 40);
      expect(json['tripCurrencySnapshot'], 'TRY');
    });

    test('legacy payloads (v15) decode with NULL fields; effectivePayer falls back', () {
      final legacyJson = _expense('e1', 't1', createdByName: 'Ayşe').toJson()
        ..removeWhere((k, _) => k.contains('aid') || k.contains('xchange') || k.contains('napshot'));
      final fromJson = Expense.fromJson(legacyJson);
      expect(fromJson.paidByName, isNull);
      expect(fromJson.exchangeRateToTrip, isNull);
      expect(fromJson.effectivePayer, 'Ayşe');
      expect(_expense('e2', 't1').effectivePayer, '');
      expect(_expense('e3', 't1', createdByName: 'Ayşe', paidByName: '  ').effectivePayer, 'Ayşe');
    });

    test('untrusted rate values from Firestore are dropped (live fallback)', () {
      for (final bad in [0, -3, 'abc', double.infinity, double.nan]) {
        final e = Expense.fromJson({..._expense('e1', 't1').toJson(), 'exchange_rate_to_trip': bad});
        expect(e.exchangeRateToTrip, isNull, reason: 'value $bad');
        expect(e.amountIn('TRY'), closeTo(400, 1e-9));
      }
      expect(Expense.fromJson({..._expense('e1', 't1').toJson(), 'exchange_rate_to_trip': 40}).exchangeRateToTrip, 40.0);
    });
  });

  // -------------------------------------------------------------------------
  group('3. Frozen rate vs live rate', () {
    test('rateAtEntry only freezes usable rates', () {
      expect(Expense.rateAtEntry('EUR', 'TRY'), closeTo(40, 1e-9));
      expect(Expense.rateAtEntry('TRY', 'TRY'), 1.0);
      expect(Expense.rateAtEntry('XXX', 'TRY'), isNull); // unknown currency → stay on live
      expect(Expense.rateAtEntry('EUR', ''), isNull);
    });

    test('locked expenses ignore later live-rate changes; NULL-rate expenses follow them', () async {
      final locked = _expense('e1', 't1', rate: 40, snapshot: 'TRY');
      final legacy = _expense('e2', 't1');
      expect(locked.amountIn('TRY'), closeTo(400, 1e-9));
      expect(legacy.amountIn('TRY'), closeTo(400, 1e-9));

      await _setLiveRates({'EUR': 0.9, 'TRY': 45.0, 'USD': 1.0}); // 1 EUR = 50 TRY now
      expect(locked.amountIn('TRY'), closeTo(400, 1e-9));
      expect(legacy.amountIn('TRY'), closeTo(500, 1e-9));
      // Target ≠ snapshot: frozen leg EUR→TRY, live leg TRY→USD (400 TRY / 45)
      expect(locked.amountIn('USD'), closeTo(400 / 45, 1e-9));
      // Same currency never converts
      expect(locked.amountIn('EUR'), 10);
    });

    test('ExpenseController freezes the rate on add, keeps the creator and re-freezes on currency change', () async {
      await db.insert(AppConstants.tableTrips, _trip('t1', userId: '').toMap());
      await db.insert(AppConstants.tableExpenses, _expense('legacy', 't1', createdByName: 'Ayşe').toMap());

      final container = ProviderContainer(overrides: [
        authUserProvider.overrideWithValue(_FakeUser('owner-uid', email: 'owner@example.com')),
        profileControllerProvider.overrideWith((ref) => _FakeProfileController()),
        syncEngineProvider.overrideWith((ref) => _FakeSyncEngine()),
        expenseControllerProvider('t1').overrideWith(
          (ref) => ExpenseController(ref, 't1', dbHelper: DatabaseHelper.instance),
        ),
      ]);
      addTearDown(container.dispose);
      container.listen(expenseControllerProvider('t1'), (_, _) {});
      final controller = container.read(expenseControllerProvider('t1').notifier);
      await controller.loadExpenses();

      final added = await controller.addExpense(
        title: 'Museum',
        amount: 10,
        currency: 'EUR',
        category: 'Entertainment',
        date: _now,
        paidByName: ' Ahmet ',
      );
      expect(added!.exchangeRateToTrip, closeTo(40, 1e-9));
      expect(added.tripCurrencySnapshot, 'TRY');
      expect(added.paidByName, 'Ahmet');
      expect(added.createdByName, 'owner'); // e-mail prefix fallback
      expect(controller.state.totalSpent, closeTo(800, 1e-9));

      await _setLiveRates({'EUR': 0.9, 'TRY': 45.0, 'USD': 1.0});
      await controller.loadExpenses();
      expect(controller.state.totalSpent, closeTo(400 + 500, 1e-9)); // locked + live legacy

      final unknown = await controller.addExpense(
        title: 'Snack',
        amount: 5,
        currency: 'XXX',
        category: 'Food',
        date: _now,
      );
      expect(unknown!.exchangeRateToTrip, isNull);
      expect(unknown.tripCurrencySnapshot, isNull);

      final legacy = controller.state.expenses.firstWhere((e) => e.id == 'legacy');
      final edited = await controller.updateExpense(legacy.copyWith(amount: 12));
      expect(edited!.createdByName, 'Ayşe'); // spec 4.3: creator preserved
      expect(edited.exchangeRateToTrip, isNull); // same currency: legacy stays on live rates

      final switched = await controller.updateExpense(added.copyWith(currency: 'USD'));
      expect(switched!.exchangeRateToTrip, closeTo(45, 1e-9)); // re-frozen for USD→TRY
      expect(switched.tripCurrencySnapshot, 'TRY');
    });
  });

  // -------------------------------------------------------------------------
  group('4. Leaving a shared trip', () {
    test('leaveIdentities mirrors isTripCollaborator(): uid + verified e-mail (and lowercase)', () {
      expect(
        TripController.leaveIdentities(uid: 'u1', email: 'Ahmet@Mail.com', emailVerified: true),
        ['u1', 'Ahmet@Mail.com', 'ahmet@mail.com'],
      );
      expect(TripController.leaveIdentities(uid: 'u1', email: 'a@b.com', emailVerified: true), ['u1', 'a@b.com']);
      expect(TripController.leaveIdentities(uid: 'u1', email: 'a@b.com', emailVerified: false), ['u1']);
      expect(TripController.leaveIdentities(uid: 'u1', email: null, emailVerified: true), ['u1']);
    });

    test('firestore.rules isSelfLeave() matches the keys and identities the client sends', () {
      final rules = File('firestore.rules').readAsStringSync();
      expect(rules, contains('function isSelfLeave()'));
      expect(rules, contains("affectedKeys().hasOnly(['collaborators', 'updated_at', 'updatedAt'])"));
      expect(rules, contains('[request.auth.uid, request.auth.token.email, request.auth.token.email.lower()]'));
      expect(rules, contains('removed.hasOnly(self)'));
      expect(RegExp(r'\|\|\s*isSelfLeave\(\)').hasMatch(rules), isTrue, reason: 'trips update must allow isSelfLeave()');
    });

    test('purgeLocalSharedTrip hard-deletes the trip and its children only', () async {
      await _seedTripWithChildren(db, _trip('shared', collaborators: ['member-uid']));
      await _seedTripWithChildren(db, _trip('other'));

      await DatabaseHelper.instance.purgeLocalSharedTrip('shared');

      expect(await _rowCounts(db, 'shared'), _noRows);
      expect(await _rowCounts(db, 'other'), _allRows);
      expect(await db.query(AppConstants.tableTrips, where: 'is_deleted = 1'), isEmpty); // no tombstone
    });

    group('SyncEngine.leaveSharedTrip', () {
      late _FakeFirestore firestore;
      late SyncEngine engine;

      setUp(() async {
        firestore = _FakeFirestore();
        engine = SyncEngine(
          dbHelper: DatabaseHelper.instance,
          firestore: firestore,
          auth: _FakeAuth(_FakeUser('member-uid', email: 'member@example.com')),
        );
        await _seedTripWithChildren(db, _trip('shared', collaborators: ['member-uid', 'member@example.com']));
      });

      tearDown(() => engine.dispose());

      test('removes only the caller identities with rule-allowed keys, then purges locally', () async {
        final ok = await engine.leaveSharedTrip('shared', ['member-uid', 'member@example.com']);

        expect(ok, isTrue);
        final update = firestore.tripDoc('shared').lastUpdate!;
        expect(update.keys.toSet(), {'collaborators', 'updated_at', 'updatedAt'});
        expect(update['collaborators'], isA<FieldValue>());
        expect(await _rowCounts(db, 'shared'), _noRows);
      });

      test('keeps local data when Firestore rejects the write', () async {
        firestore.tripDoc('shared').updateError =
            FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');

        expect(await engine.leaveSharedTrip('shared', ['member-uid']), isFalse);
        expect(await _rowCounts(db, 'shared'), _allRows);
      });

      test('no identities → no write', () async {
        expect(await engine.leaveSharedTrip('shared', const []), isFalse);
        expect(firestore.tripDoc('shared').lastUpdate, isNull);
      });
    });

    group('SyncEngine.purgeIfRemovedFromSharedTrip (removed by the owner)', () {
      late _FakeFirestore firestore;
      late _FakeAuth auth;
      late SyncEngine engine;

      setUp(() {
        firestore = _FakeFirestore();
        auth = _FakeAuth(_FakeUser('member-uid'));
        engine = SyncEngine(dbHelper: DatabaseHelper.instance, firestore: firestore, auth: auth);
      });

      tearDown(() => engine.dispose());

      test('purges a trip someone else owns once the server confirms the access loss', () async {
        await _seedTripWithChildren(db, _trip('shared', collaborators: ['member-uid']));
        firestore.tripDoc('shared').getError =
            FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');

        await engine.purgeIfRemovedFromSharedTrip('shared');
        expect(await _rowCounts(db, 'shared'), _noRows);
      });

      test('never purges a trip the current user owns', () async {
        await _seedTripWithChildren(db, _trip('mine', userId: 'member-uid', collaborators: ['friend@example.com']));
        firestore.tripDoc('mine').getError =
            FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');

        await engine.purgeIfRemovedFromSharedTrip('mine');
        expect(await _rowCounts(db, 'mine'), _allRows);
        expect(firestore.tripDoc('mine').getCalls, 0);
      });

      test('keeps data when the trip is still readable (transient error)', () async {
        await _seedTripWithChildren(db, _trip('shared', collaborators: ['member-uid']));
        firestore.tripDoc('shared').readable = true;

        await engine.purgeIfRemovedFromSharedTrip('shared');
        expect(await _rowCounts(db, 'shared'), _allRows);
      });

      test('does nothing while signed out', () async {
        await _seedTripWithChildren(db, _trip('shared', collaborators: ['member-uid']));
        auth.currentUser = null;
        firestore.tripDoc('shared').getError =
            FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');

        await engine.purgeIfRemovedFromSharedTrip('shared');
        expect(await _rowCounts(db, 'shared'), _allRows);
      });
    });

    group('TripController.leaveTrip', () {
      late _FakeSyncEngine engine;
      late ProviderContainer container;
      late TripController controller;

      setUp(() async {
        await _seedTripWithChildren(db, _trip('shared', collaborators: ['member-uid', 'member@example.com']));
        await _seedTripWithChildren(db, _trip('own', userId: 'member-uid', collaborators: ['friend@example.com']));
        engine = _FakeSyncEngine();
        container = ProviderContainer(overrides: [
          authUserProvider.overrideWithValue(_FakeUser('member-uid', email: 'member@example.com')),
          syncEngineProvider.overrideWith((ref) => engine),
          tripControllerProvider.overrideWith(
            (ref) => TripController(ref, dbHelper: DatabaseHelper.instance, notificationService: _FakeNotifications()),
          ),
        ]);
        controller = container.read(tripControllerProvider.notifier);
        await Future<void>.delayed(const Duration(milliseconds: 50)); // constructor load
        await controller.loadTrips(userId: 'member-uid');
        expect(controller.state.trips.map((t) => t.id), containsAll(['shared', 'own']));
      });

      tearDown(() => container.dispose());

      test('collaborator leaves: rule identities sent, trip purged and removed from state', () async {
        expect(await controller.leaveTrip('shared'), isTrue);

        expect(engine.leaveCalls.single.$1, 'shared');
        expect(engine.leaveCalls.single.$2, ['member-uid', 'member@example.com']);
        expect(controller.state.trips.any((t) => t.id == 'shared'), isFalse);
        expect(await _rowCounts(db, 'shared'), _noRows);
      });

      test('the owner can never leave (no cloud call, nothing deleted)', () async {
        expect(await controller.leaveTrip('own'), isFalse);

        expect(engine.leaveCalls, isEmpty);
        expect(controller.state.trips.any((t) => t.id == 'own'), isTrue);
        expect(await _rowCounts(db, 'own'), _allRows);
      });

      test('a failed leave keeps the trip in state and on disk', () async {
        engine.leaveResult = false;

        expect(await controller.leaveTrip('shared'), isFalse);
        expect(controller.state.trips.any((t) => t.id == 'shared'), isTrue);
        expect(await _rowCounts(db, 'shared'), _allRows);
      });
    });
  });

  // -------------------------------------------------------------------------
  group('5. New UI in all 20 languages at 320x568', () {
    const rawUid = 'AbCdEfGhIjKlMnOpQrStUvWxYz12'; // unresolvable uid entry → generic label
    // Fixed past dates keep the status badge stable regardless of the machine clock.
    final sharedTrip = _trip('shared', collaborators: ['@ahmet', 'ayse@example.com', rawUid, 'member-uid'])
        .copyWith(startDate: DateTime(2025, 3, 1), endDate: DateTime(2025, 3, 5));
    final owner = _FakeUser('owner-uid', email: 'owner@example.com');
    final member = _FakeUser('member-uid', email: 'member@example.com');

    Future<_FakeTripController> pump(
      WidgetTester tester,
      Widget child,
      Locale locale,
      User user, {
      List<Expense> expenses = const [],
      bool asScreen = false,
    }) async {
      final trips = _FakeTripController(sharedTrip);
      await tester.pumpWidget(ProviderScope(
        key: UniqueKey(), // fresh container per locale/user (overrides are not re-applied on update)
        overrides: [
          authUserProvider.overrideWithValue(user),
          tripControllerProvider.overrideWith((ref) => trips),
          friendsControllerProvider.overrideWith((ref) => _FakeFriendsController()),
          profileControllerProvider.overrideWith((ref) => _FakeProfileController()),
          checklistControllerProvider.overrideWith((ref) => _FakeChecklistNotifier()),
          expenseControllerProvider(sharedTrip.id).overrideWith((ref) => _FakeExpenseController(expenses)),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: asScreen ? child : Scaffold(body: Align(alignment: Alignment.bottomCenter, child: child)),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      return trips;
    }

    testWidgets('TripDetailScreen: crew row, payer/creator attribution and locked-rate icon', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final expenses = [
        _expense('e1', 'shared', createdByName: 'Ayşe', paidByName: 'Ahmet Yılmaz', rate: 40, snapshot: 'TRY'),
        _expense('e2', 'shared', createdByName: 'Ayşe'),
      ];

      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        await pump(tester, TripDetailScreen(trip: sharedTrip), locale, owner, expenses: expenses, asScreen: true);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'detail screen, $locale');
        expect(find.textContaining(l10n.tripCrew), findsOneWidget);

        final attribution = find.text(l10n.paidByAndAddedBy('Ahmet Yılmaz', 'Ayşe'));
        await tester.dragUntilVisible(attribution, find.byType(CustomScrollView), const Offset(0, -200));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'expense tiles, $locale');
        expect(find.text(l10n.paidByName('Ayşe')), findsOneWidget);
        expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget); // only e1 has a frozen rate
      }
    });

    testWidgets('TripMembersSheet: owner can remove members, collaborators see only "leave"', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);

        await pump(tester, TripMembersSheet(trip: sharedTrip), locale, owner);
        expect(tester.takeException(), isNull, reason: 'owner view, $locale');
        expect(find.text(l10n.tripCrew), findsOneWidget);
        expect(find.text('Ahmet Yılmaz'), findsOneWidget); // @ahmet resolved via friends
        expect(find.byIcon(Icons.person_remove_rounded), findsNWidgets(4));
        expect(find.text(l10n.shareTrip), findsOneWidget);
        expect(find.text(l10n.leaveTrip), findsNothing);

        await pump(tester, TripMembersSheet(trip: sharedTrip), locale, member);
        expect(tester.takeException(), isNull, reason: 'member view, $locale');
        expect(find.byIcon(Icons.person_remove_rounded), findsNothing);
        expect(find.text(l10n.leaveTrip), findsOneWidget);
      }
    });

    testWidgets('leaving asks for confirmation and reports a failed leave', (tester) async {
      final l10n = lookupAppLocalizations(const Locale('tr'));
      final trips = await pump(tester, TripMembersSheet(trip: sharedTrip), const Locale('tr'), member);

      await tester.tap(find.text(l10n.leaveTrip));
      await tester.pumpAndSettle();
      expect(find.text(l10n.leaveTripConfirm), findsOneWidget);
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
      expect(trips.leaveCalls, 0);

      await tester.tap(find.text(l10n.leaveTrip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.leaveTrip).last); // dialog's destructive button
      await tester.pumpAndSettle();
      expect(trips.leaveCalls, 1);
      expect(find.text(l10n.authErrorNetworkFailed), findsOneWidget);
      await tester.pump(const Duration(seconds: 5)); // let the snackbar timer finish
      await tester.pumpAndSettle();
    });

    testWidgets('AddExpenseSheet: payer picker only for the owner of a shared trip', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final sheet = AddExpenseSheet(tripId: sharedTrip.id, defaultCurrency: 'TRY');

      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        await pump(tester, sheet, locale, owner);
        expect(tester.takeException(), isNull, reason: 'owner view, $locale');
        expect(find.text(l10n.paidByLabel), findsOneWidget);

        await pump(tester, sheet, locale, member);
        expect(find.text(l10n.paidByLabel), findsNothing);
      }

      await pump(tester, sheet, const Locale('en'), owner);
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.text('Ahmet Yılmaz'), findsWidgets);
      expect(find.text('ayse@example.com'), findsWidgets);
      expect(find.text(rawUid), findsNothing); // raw uids are never offered as payer names
    });

    testWidgets('BudgetAnalyticsCard: payer tab groups by payer, only on shared trips', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final expenses = [
        _expense('e1', 'shared', createdByName: 'Ayşe', rate: 40, snapshot: 'TRY'),
        _expense('e2', 'shared', createdByName: 'Ayşe', paidByName: 'ahmet yılmaz '),
        _expense('e3', 'shared', createdByName: 'Ahmet Yılmaz', currency: 'TRY', amount: 100),
      ];
      Widget card(Trip trip) => SingleChildScrollView(
            child: BudgetAnalyticsCard(expenses: expenses, tripCurrency: 'TRY', totalSpent: 900, trip: trip),
          );

      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        await pump(tester, card(sharedTrip), locale, owner);
        await tester.tap(find.text(l10n.payerBreakdown));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'payer tab, $locale');
        // Case-insensitive grouping: "Ahmet Yılmaz" (e3) + "ahmet yılmaz " (e2) → one row
        expect(find.text('(2)'), findsOneWidget);
        expect(find.text('(1)'), findsOneWidget);
      }

      await pump(tester, card(_trip('solo')), const Locale('en'), owner);
      expect(find.text(lookupAppLocalizations(const Locale('en')).payerBreakdown), findsNothing);
    });
  });
}
