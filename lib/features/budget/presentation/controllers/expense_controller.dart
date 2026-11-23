import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/local_db/database_helper.dart';
import '../../../../data/sync_engine/sync_engine.dart';
import '../../../../core/services/telemetry_service.dart';
import '../../domain/expense.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/app_widget_service.dart';
import '../../../auth/auth_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

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

  static double _sumIn(List<Expense> expenses, String currency) =>
      expenses.fold<double>(0.0, (sum, e) => sum + e.amountIn(currency));

  /// Name stamped as creator (and offered as "me" in the payer picker):
  /// profile name → auth display name → e-mail prefix.
  static String? displayNameFor(String? profileName, User? authUser) {
    for (final name in [profileName, authUser?.displayName]) {
      final trimmed = name?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    final email = authUser?.email?.trim();
    return (email != null && email.isNotEmpty) ? email.split('@').first : null;
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
      final total = _sumIn(expenses, tripCurrency);
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
    String? paymentMethod,
    String? notes,
    String? paidByName,
  }) async {
    // Feature restriction guard (Phase 3)
    if (PreferencesService.instance.getRestrictedFeatures().contains('expense_add')) {
      state = state.copyWith(errorMessage: 'restricted_expense_add');
      return null;
    }

    try {
      final trip = await _dbHelper.getTripById(_tripId);
      final tripCurrency = trip?.defaultCurrency ?? currency;
      final now = DateTime.now();
      final currentUid = _ref.read(authUserProvider)?.uid ?? '';
      final authorName = displayNameFor(
        _ref.read(profileControllerProvider).profile?.displayName,
        _ref.read(authUserProvider),
      );

      final payer = paidByName?.trim();
      final lockedRate = Expense.rateAtEntry(currency, tripCurrency);
      final newExpense = Expense(
        id: _uuid.v4(),
        userId: currentUid,
        tripId: _tripId,
        title: title,
        amount: amount,
        currency: currency,
        category: category,
        date: date,
        paymentMethod: paymentMethod,
        notes: notes,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
        createdByName: authorName,
        paidByName: (payer == null || payer.isEmpty) ? null : payer,
        exchangeRateToTrip: lockedRate,
        tripCurrencySnapshot: lockedRate == null ? null : tripCurrency,
      );

      await _dbHelper.insertExpense(newExpense);

      // If collaborative trip, push immediately to Firestore for real-time collaborator view
      if (trip != null && trip.isCollaborative) {
        try {
          _ref.read(syncEngineProvider.notifier).pushExpense(newExpense);
        } catch (_) {}
      }

      final updatedList = [newExpense, ...state.expenses];
      final newTotal = _sumIn(updatedList, tripCurrency);

      if (!mounted) return newExpense;
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

      // Refresh Home Screen widgets in real time
      AppWidgetService.syncCurrentState().catchError((_) {});

      return newExpense;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
      return null;
    }
  }

  /// Updates an existing expense, updates state and triggers background sync
  Future<Expense?> updateExpense(Expense updated) async {
    try {
      final trip = await _dbHelper.getTripById(_tripId);
      final tripCurrency = trip?.defaultCurrency ?? updated.currency;

      // createdByName stays the original creator (spec 4.3). The frozen rate belongs to the
      // original currency, so it is re-captured only when the currency changed; legacy NULL
      // rows that keep their currency stay on live rates.
      var expenseToSave = updated.copyWith(updatedAt: DateTime.now());
      final original = state.expenses.where((e) => e.id == updated.id).firstOrNull;
      if (original != null && original.currency != updated.currency) {
        final lockedRate = Expense.rateAtEntry(updated.currency, tripCurrency);
        expenseToSave = expenseToSave.copyWith(
          exchangeRateToTrip: lockedRate,
          tripCurrencySnapshot: tripCurrency,
          clearExchangeRate: lockedRate == null,
        );
      }

      await _dbHelper.updateExpense(expenseToSave);

      if (trip != null && trip.isCollaborative) {
        try {
          _ref.read(syncEngineProvider.notifier).pushExpense(expenseToSave);
        } catch (_) {}
      }

      final index = state.expenses.indexWhere((e) => e.id == updated.id);
      final updatedList = List<Expense>.from(state.expenses);
      if (index != -1) {
        updatedList[index] = expenseToSave;
      } else {
        updatedList.insert(0, expenseToSave);
      }

      final newTotal = _sumIn(updatedList, tripCurrency);

      if (!mounted) return expenseToSave;
      state = state.copyWith(
        expenses: updatedList,
        totalSpent: newTotal,
      );

      // Trigger background two-way sync
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

      // Refresh Home Screen widgets in real time
      AppWidgetService.syncCurrentState().catchError((_) {});

      return expenseToSave;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
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
      final newTotal = _sumIn(updatedList, tripCurrency);

      state = state.copyWith(
        expenses: updatedList,
        totalSpent: newTotal,
      );

      // Trigger background two-way sync
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

      // Refresh Home Screen widgets in real time
      AppWidgetService.syncCurrentState().catchError((_) {});

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
      final newTotal = _sumIn(updatedList, tripCurrency);

      if (!mounted) return true;
      state = state.copyWith(
        expenses: updatedList,
        totalSpent: newTotal,
      );

      // If collaborative trip, mark as deleted in Firestore immediately
      if (trip != null && trip.isCollaborative) {
        try {
          _ref.read(syncEngineProvider.notifier).deleteRemoteExpense(expenseId);
        } catch (_) {}
      }

      // Trigger background two-way sync
      try {
        _ref.read(syncEngineProvider.notifier).performSync();
      } catch (_) {}

      // Refresh Home Screen widgets in real time
      AppWidgetService.syncCurrentState().catchError((_) {});

      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
      return false;
    }
  }
}

/// Family provider keyed by tripId
final expenseControllerProvider =
    StateNotifierProvider.family<ExpenseController, ExpenseState, String>(
  (ref, tripId) {
    return ExpenseController(ref, tripId);
  },
);
