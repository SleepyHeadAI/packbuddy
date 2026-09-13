import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/local_db/database_helper.dart';
import '../../../../data/sync_engine/sync_engine.dart';
import '../../domain/expense.dart';

/// State representation for expenses belonging to a specific trip
class ExpenseState {
  final bool isLoading;
  final List<Expense> expenses;
  final double totalSpent;
  final String? errorMessage;

  const ExpenseState({
    this.isLoading = false,
    this.expenses = const [],
    this.totalSpent = 0.0,
    this.errorMessage,
  });

  ExpenseState copyWith({
    bool? isLoading,
    List<Expense>? expenses,
    double? totalSpent,
    String? errorMessage,
  }) {
    return ExpenseState(
      isLoading: isLoading ?? this.isLoading,
      expenses: expenses ?? this.expenses,
      totalSpent: totalSpent ?? this.totalSpent,
      errorMessage: errorMessage,
    );
  }
}

/// Controller managing expenses for a specific Trip with SQLite and sync integration
class ExpenseController extends StateNotifier<ExpenseState> {
  final Ref _ref;
  final String _tripId;
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  ExpenseController(
    this._ref,
    this._tripId, {
    DatabaseHelper? dbHelper,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        super(const ExpenseState()) {
    loadExpenses();
  }

  /// Loads non-deleted expenses for the trip from SQLite
  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true);
    try {
      final expenses = await _dbHelper.getExpenses(
        tripId: _tripId,
        includeDeleted: false,
      );
      final total = expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        expenses: expenses,
        totalSpent: total,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Adds a new expense, persists to SQLite and triggers background sync
  Future<Expense?> addExpense({
    required String title,
    required double amount,
    required String currency,
    required String category,
    required DateTime date,
    String? receiptPath,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final newExpense = Expense(
        id: _uuid.v4(),
        tripId: _tripId,
        title: title,
        amount: amount,
        currency: currency,
        category: category,
        date: date,
        receiptPath: receiptPath,
        paymentMethod: paymentMethod,
        notes: notes,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      await _dbHelper.insertExpense(newExpense);

      final updatedList = [newExpense, ...state.expenses];
      final newTotal = updatedList.fold<double>(0.0, (sum, item) => sum + item.amount);

      state = state.copyWith(
        expenses: updatedList,
        totalSpent: newTotal,
      );

      // Trigger background two-way sync
      _ref.read(syncEngineProvider.notifier).performSync();

      return newExpense;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// Soft deletes an expense, updates state and triggers background sync
  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _dbHelper.deleteExpense(expenseId);

      final updatedList = state.expenses.where((e) => e.id != expenseId).toList();
      final newTotal = updatedList.fold<double>(0.0, (sum, item) => sum + item.amount);

      state = state.copyWith(
        expenses: updatedList,
        totalSpent: newTotal,
      );

      // Trigger background two-way sync
      _ref.read(syncEngineProvider.notifier).performSync();

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

/// Family provider keyed by tripId with autoDispose to prevent memory leaks
final expenseControllerProvider =
    StateNotifierProvider.autoDispose.family<ExpenseController, ExpenseState, String>(
  (ref, tripId) {
    return ExpenseController(ref, tripId);
  },
);
