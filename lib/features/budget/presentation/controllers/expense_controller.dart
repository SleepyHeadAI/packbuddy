import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/local_db/database_helper.dart';
import '../../../../data/sync_engine/sync_engine.dart';
import '../../../../core/services/telemetry_service.dart';
import '../../domain/expense.dart';
import '../../../../core/services/currency_service.dart';

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
      final trip = await _dbHelper.getTripById(_tripId);
      final tripCurrency = trip?.defaultCurrency ?? 'USD';
      final expenses = await _dbHelper.getExpenses(
        tripId: _tripId,
        includeDeleted: false,
      );
      final total = expenses.fold<double>(0.0, (sum, item) {
        final converted = CurrencyService.convert(
          amount: item.amount,
          fromCurrency: item.currency,
          toCurrency: tripCurrency,
        );
        return sum + converted;
      });
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
      final trip = await _dbHelper.getTripById(_tripId);
      final tripCurrency = trip?.defaultCurrency ?? currency;
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
      final newTotal = updatedList.fold<double>(0.0, (sum, item) {
        final converted = CurrencyService.convert(
          amount: item.amount,
          fromCurrency: item.currency,
          toCurrency: tripCurrency,
        );
        return sum + converted;
      });

      state = state.copyWith(
        expenses: updatedList,
        totalSpent: newTotal,
      );

      // Log telemetry event
      TelemetryService.instance.logExpenseLogged(
        category: category,
        amount: amount,
        currency: currency,
      );

      // Trigger background two-way sync
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

      return newExpense;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// Updates an existing expense, updates state and triggers background sync
  Future<Expense?> updateExpense(Expense updated) async {
    try {
      final trip = await _dbHelper.getTripById(_tripId);
      final tripCurrency = trip?.defaultCurrency ?? updated.currency;
      final expenseToSave = updated.copyWith(updatedAt: DateTime.now());

      await _dbHelper.updateExpense(expenseToSave);

      final index = state.expenses.indexWhere((e) => e.id == updated.id);
      final updatedList = List<Expense>.from(state.expenses);
      if (index != -1) {
        updatedList[index] = expenseToSave;
      } else {
        updatedList.insert(0, expenseToSave);
      }

      final newTotal = updatedList.fold<double>(0.0, (sum, item) {
        final converted = CurrencyService.convert(
          amount: item.amount,
          fromCurrency: item.currency,
          toCurrency: tripCurrency,
        );
        return sum + converted;
      });

      state = state.copyWith(
        expenses: updatedList,
        totalSpent: newTotal,
      );

      // Trigger background two-way sync
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

      return expenseToSave;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  /// Restores a soft-deleted expense (used for Undo)
  Future<bool> restoreExpense(Expense expense) async {
    try {
      await _dbHelper.restoreExpense(expense.id);
      final trip = await _dbHelper.getTripById(_tripId);
      final tripCurrency = trip?.defaultCurrency ?? expense.currency;

      final updatedList = [expense, ...state.expenses.where((e) => e.id != expense.id)];
      final newTotal = updatedList.fold<double>(0.0, (sum, item) {
        final converted = CurrencyService.convert(
          amount: item.amount,
          fromCurrency: item.currency,
          toCurrency: tripCurrency,
        );
        return sum + converted;
      });

      state = state.copyWith(
        expenses: updatedList,
        totalSpent: newTotal,
      );

      // Trigger background two-way sync
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Soft deletes an expense, updates state and triggers background sync
  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _dbHelper.deleteExpense(expenseId);
      final trip = await _dbHelper.getTripById(_tripId);
      final tripCurrency = trip?.defaultCurrency ?? 'USD';

      final updatedList = state.expenses.where((e) => e.id != expenseId).toList();
      final newTotal = updatedList.fold<double>(0.0, (sum, item) {
        final converted = CurrencyService.convert(
          amount: item.amount,
          fromCurrency: item.currency,
          toCurrency: tripCurrency,
        );
        return sum + converted;
      });

      state = state.copyWith(
        expenses: updatedList,
        totalSpent: newTotal,
      );

      // Trigger background two-way sync
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

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
