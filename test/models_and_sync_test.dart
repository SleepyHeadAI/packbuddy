import 'package:flutter_test/flutter_test.dart';
import 'package:packbuddy/features/budget/domain/trip.dart';
import 'package:packbuddy/features/budget/domain/expense.dart';
import 'package:packbuddy/data/sync_engine/sync_engine.dart';

void main() {
  group('Trip Model Tests', () {
    test('Trip serialization and deserialization (JSON & SQLite Map)', () {
      final now = DateTime.now();
      final trip = Trip(
        id: 'trip-123',
        title: 'Tokyo Summer Trip',
        destination: 'Tokyo, Japan',
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        defaultCurrency: 'JPY',
        budgetLimit: 250000.0,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      // JSON (Firestore) serialization
      final json = trip.toJson();
      expect(json['id'], 'trip-123');
      expect(json['defaultCurrency'], 'JPY');
      expect(json['isDeleted'], false);

      final fromJsonTrip = Trip.fromJson(json);
      expect(fromJsonTrip.id, trip.id);
      expect(fromJsonTrip.title, trip.title);
      expect(fromJsonTrip.budgetLimit, 250000.0);

      // SQLite Map serialization
      final map = trip.toMap();
      expect(map['id'], 'trip-123');
      expect(map['is_deleted'], 0);

      final fromMapTrip = Trip.fromMap(map);
      expect(fromMapTrip.id, trip.id);
      expect(fromMapTrip.isDeleted, false);

      // Soft delete copyWith
      final deletedTrip = trip.copyWith(isDeleted: true);
      expect(deletedTrip.isDeleted, true);
      expect(deletedTrip.toMap()['is_deleted'], 1);
    });
  });

  group('Expense Model Tests', () {
    test('Expense serialization and deserialization (JSON & SQLite Map)', () {
      final now = DateTime.now();
      final expense = Expense(
        id: 'exp-456',
        tripId: 'trip-123',
        title: 'Shinkansen Bullet Train Ticket',
        amount: 14500.0,
        currency: 'JPY',
        category: 'Transportation',
        date: now,
        receiptPath: '/path/to/receipt.jpg',
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      // JSON serialization
      final json = expense.toJson();
      expect(json['id'], 'exp-456');
      expect(json['tripId'], 'trip-123');
      expect(json['amount'], 14500.0);

      final fromJsonExpense = Expense.fromJson(json);
      expect(fromJsonExpense.id, expense.id);
      expect(fromJsonExpense.title, expense.title);

      // SQLite Map serialization
      final map = expense.toMap();
      expect(map['id'], 'exp-456');
      expect(map['trip_id'], 'trip-123');
      expect(map['is_deleted'], 0);

      final fromMapExpense = Expense.fromMap(map);
      expect(fromMapExpense.id, expense.id);
      expect(fromMapExpense.isDeleted, false);

      // Soft delete test
      final deletedExpense = expense.copyWith(isDeleted: true);
      expect(deletedExpense.isDeleted, true);
      expect(deletedExpense.toMap()['is_deleted'], 1);
    });
  });

  group('SyncEngine Tests', () {
    test('SyncEngine initial state is idle', () {
      final syncEngine = SyncEngine();
      expect(syncEngine.state.status, SyncStatus.idle);
      expect(syncEngine.state.errorMessage, isNull);
    });

    test('SyncEngine performSync gracefully transitions state', () async {
      final syncEngine = SyncEngine();
      // Calling performSync in test environment transitions gracefully
      await syncEngine.performSync();
      // Should not be in syncing state after completion
      expect(syncEngine.state.status != SyncStatus.syncing, isTrue);
    });
  });
}
