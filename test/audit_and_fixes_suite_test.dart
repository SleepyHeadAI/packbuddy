import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packbuddy/core/services/currency_service.dart';
import 'package:packbuddy/core/utils/currency_formatter.dart';
import 'package:packbuddy/features/checklist/domain/packing_item.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/features/budget/presentation/controllers/trip_controller.dart';
import 'package:packbuddy/features/budget/presentation/controllers/expense_controller.dart';
import 'package:packbuddy/features/checklist/presentation/controllers/checklist_controller.dart';
import 'package:packbuddy/features/settings/data/mock_revenuecat_service.dart';
import 'package:packbuddy/features/settings/presentation/screens/widgets/paywall_sheet.dart';
import 'package:packbuddy/features/checklist/presentation/screens/widgets/add_packing_item_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_expense_sheet.dart';
import 'package:packbuddy/features/budget/presentation/screens/widgets/add_trip_sheet.dart';
import 'package:packbuddy/data/local_db/database_helper.dart';
import 'package:packbuddy/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Audit Fix 1: CurrencyService & CurrencyFormatter 30 Currencies Synchrony', () {
    test('CurrencyService supports all 30 currencies defined in CurrencyFormatter', () {
      expect(CurrencyService.supportedCurrencies.length, 30);
      expect(CurrencyFormatter.supportedCurrencies.length, 30);
      for (final code in CurrencyFormatter.supportedCurrencies) {
        expect(CurrencyService.supportedCurrencies.contains(code), isTrue,
            reason: 'CurrencyService should support $code');
        final rate = CurrencyService.ratesAgainstUsd[code];
        expect(rate, isNotNull);
        expect(rate, greaterThan(0.0));
      }
    });

    test('CurrencyService conversion and symbols work accurately', () {
      expect(CurrencyService.getCurrencySymbol('NZD'), 'NZ\$');
      expect(CurrencyService.getCurrencySymbol('CZK'), 'Kč');
      expect(CurrencyService.getCurrencySymbol('HUF'), 'Ft');
      expect(CurrencyService.getCurrencySymbol('ILS'), '₪');
      expect(CurrencyService.getCurrencySymbol('ZAR'), 'R');
      expect(CurrencyService.getCurrencySymbol('QAR'), 'QR');

      final nzdConverted = CurrencyService.convert(amount: 100, fromCurrency: 'USD', toCurrency: 'NZD');
      expect(nzdConverted, closeTo(166.0, 0.1));
    });
  });

  group('Audit Fix 2: PackingItem Resilient Deserialization', () {
    test('PackingItem parses fromMap with integer timestamp and boolean int', () {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final map = {
        'id': 'item-1',
        'trip_id': 'trip-1',
        'name': 'Pasaport',
        'category': 'Belgeler',
        'quantity': 2,
        'weight_kg': 0.1,
        'is_packed': 1,
        'tag': 'ESSENTIAL',
        'compartment': 'Ön Cep',
        'created_at': nowMs,
        'updated_at': nowMs,
      };

      final item = PackingItem.fromMap(map);
      expect(item.id, 'item-1');
      expect(item.name, 'Pasaport');
      expect(item.isPacked, isTrue);
      expect(item.quantity, 2);
    });

    test('PackingItem parses fromMap with ISO-8601 string and bool literal', () {
      final isoString = DateTime.now().toIso8601String();
      final map = {
        'id': 'item-2',
        'trip_id': 'trip-2',
        'name': 'Kulaklık',
        'category': 'Elektronik',
        'quantity': 1,
        'weight_kg': 0.3,
        'is_packed': false,
        'tag': 'CARRY-ON',
        'compartment': 'Ana Bölme',
        'created_at': isoString,
        'updated_at': isoString,
      };

      final item = PackingItem.fromMap(map);
      expect(item.id, 'item-2');
      expect(item.name, 'Kulaklık');
      expect(item.isPacked, isFalse);
    });

    test('PackingItem toJson contains both camelCase and snake_case fields for multi-layer sync', () {
      final item = PackingItem(
        id: 'item-3',
        tripId: 'trip-3',
        name: 'Gözlük',
        category: 'Aksesuar',
        quantity: 1,
        weightKg: 0.2,
        isPacked: true,
        tag: 'CARRY-ON',
        compartment: 'Ön Cep',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = item.toJson();
      expect(json['is_packed'], 1);
      expect(json['isPacked'], true);
      expect(json['weight_kg'], 0.2);
      expect(json['weightKg'], 0.2);
    });
  });

  group('Audit Fix 3: Trip & Expense Controller Edits & Undo Tests', () {
    test('TripController updateTrip updates state reactively', () async {
      final fakeDb = _FakeDatabaseHelper();
      final container = ProviderContainer(
        overrides: [
          tripControllerProvider.overrideWith((ref) => TripController(ref, dbHelper: fakeDb)),
        ],
      );
      final controller = container.read(tripControllerProvider.notifier);

      final original = Trip(
        id: 'test-trip-id',
        title: 'Roma Seyahati',
        destination: 'Roma, İtalya',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 5)),
        defaultCurrency: 'EUR',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      controller.state = TripState(trips: [original]);

      final updated = original.copyWith(title: 'Roma & Floransa Turu');
      await controller.updateTrip(updated);

      expect(controller.state.trips.first.title, 'Roma & Floransa Turu');
    });

    test('ExpenseController updateExpense & restoreExpense recalculate totalSpent', () async {
      final fakeDb = _FakeDatabaseHelper();
      final container = ProviderContainer(
        overrides: [
          expenseControllerProvider('trip-1').overrideWith(
            (ref) => ExpenseController(ref, 'trip-1', dbHelper: fakeDb),
          ),
        ],
      );
      // Keep provider alive so autoDispose does not immediately dispose it
      container.listen(expenseControllerProvider('trip-1'), (previous, next) {});
      final controller = container.read(expenseControllerProvider('trip-1').notifier);

      final exp1 = Expense(
        id: 'exp-1',
        tripId: 'trip-1',
        title: 'Akşam Yemeği',
        amount: 50.0,
        currency: 'EUR',
        category: 'Food',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      controller.state = ExpenseState(
        expenses: [exp1],
        totalSpent: 50.0,
      );

      // 1. Update expense amount to 80.0
      final updatedExp = exp1.copyWith(amount: 80.0);
      await controller.updateExpense(updatedExp);

      expect(controller.state.expenses.first.amount, 80.0);
      expect(controller.state.totalSpent, 80.0);

      // 2. Soft delete
      await controller.deleteExpense(exp1.id);
      expect(controller.state.expenses.isEmpty, isTrue);
      expect(controller.state.totalSpent, 0.0);

      // 3. Restore (Undo)
      await controller.restoreExpense(exp1);
      expect(controller.state.expenses.length, 1);
      expect(controller.state.expenses.first.title, 'Akşam Yemeği');
    });

    test('ChecklistNotifier updateItem updates item in state', () async {
      final fakeDb = _FakeDatabaseHelper();
      final controller = ChecklistNotifier(fakeDb);

      final item = PackingItem(
        id: 'chk-1',
        name: 'Tişört',
        category: 'Kıyafet',
        quantity: 2,
        weightKg: 0.4,
        isPacked: false,
        tag: 'CARRY-ON',
        compartment: 'Ana Bölme',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      controller.state = ChecklistState(items: [item]);

      final updated = item.copyWith(quantity: 5, weightKg: 1.0);
      await controller.updateItem(updated);

      expect(controller.state.items.first.quantity, 5);
      expect(controller.state.items.first.weightKg, 1.0);
    });
  });

  group('Audit Fix 4: Widget Edit Sheets & Paywall Pro State', () {
    testWidgets('PaywallSheet displays active Pro state when user is subscribed', (tester) async {
      final fakeNotifier = _FakeProNotifier(const ProSubscriptionState(
        isPro: true,
        activePlan: SubscriptionPlan.annual,
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proSubscriptionProvider.overrideWith((ref) => fakeNotifier),
          ],
          child: MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: PaywallSheet(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('PackBuddy Pro Aktif'), findsOneWidget);
      expect(find.textContaining('Yıllık Plan'), findsOneWidget);
      expect(find.text('Tamam'), findsOneWidget);
    });

    testWidgets('AddPackingItemSheet displays edit mode title and button when itemToEdit is supplied',
        (tester) async {
      final item = PackingItem(
        id: 'edit-item-1',
        name: 'Güneş Gözlüğü',
        category: 'Aksesuar',
        quantity: 1,
        weightKg: 0.1,
        isPacked: false,
        tag: 'CARRY-ON',
        compartment: 'Ön Cep',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AddPackingItemSheet(itemToEdit: item),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Eşyayı Düzenle'), findsOneWidget);
      expect(find.text('Kaydet'), findsOneWidget);
      expect(find.text('Güneş Gözlüğü'), findsOneWidget);
    });

    testWidgets('AddExpenseSheet displays edit mode title when expenseToEdit is supplied',
        (tester) async {
      final expense = Expense(
        id: 'edit-exp-1',
        tripId: 'trip-1',
        title: 'Müze Bileti',
        amount: 25.0,
        currency: 'EUR',
        category: 'Entertainment',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AddExpenseSheet(
                tripId: 'trip-1',
                defaultCurrency: 'EUR',
                expenseToEdit: expense,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Harcamayı Düzenle'), findsOneWidget);
      expect(find.text('Müze Bileti'), findsOneWidget);
    });

    testWidgets('AddTripSheet displays edit mode title when tripToEdit is supplied', (tester) async {
      final trip = Trip(
        id: 'edit-trip-1',
        title: 'Paris Gezisi',
        destination: 'Paris, Fransa',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 4)),
        defaultCurrency: 'EUR',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AddTripSheet(tripToEdit: trip),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Seyahati Düzenle'), findsOneWidget);
      expect(find.text('Paris Gezisi'), findsOneWidget);
    });
  });
}

class _FakeProNotifier extends StateNotifier<ProSubscriptionState> implements MockRevenueCatNotifier {
  _FakeProNotifier(super.state);

  @override
  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(activePlan: plan);
  }

  @override
  Future<bool> purchaseActivePlan() async => true;

  @override
  Future<bool> restorePurchases() async => true;

  @override
  Future<void> resetProStatus() async {}
}

class _FakeDatabaseHelper implements DatabaseHelper {
  final Map<String, Trip> trips = {};
  final Map<String, Expense> expenses = {};
  final Map<String, PackingItem> items = {};

  @override
  Future<int> insertTrip(Trip trip) async {
    trips[trip.id] = trip;
    return 1;
  }

  @override
  Future<int> updateTrip(Trip trip) async {
    trips[trip.id] = trip;
    return 1;
  }

  @override
  Future<Trip?> getTripById(String id) async => trips[id];

  @override
  Future<int> insertExpense(Expense expense) async {
    expenses[expense.id] = expense;
    return 1;
  }

  @override
  Future<int> updateExpense(Expense expense) async {
    expenses[expense.id] = expense;
    return 1;
  }

  @override
  Future<int> deleteExpense(String id) async {
    expenses.remove(id);
    return 1;
  }

  @override
  Future<int> restoreExpense(String id) async => 1;

  @override
  Future<int> insertChecklistItem(PackingItem item) async {
    items[item.id] = item;
    return 1;
  }

  @override
  Future<int> updateChecklistItem(PackingItem item) async {
    items[item.id] = item;
    return 1;
  }

  @override
  Future<List<PackingItem>> getChecklistItems({String? tripId, bool includeDeleted = false}) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
