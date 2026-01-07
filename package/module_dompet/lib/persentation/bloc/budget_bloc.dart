import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart';
import 'package:module_dompet/data/datasource/db/dao.dart';
import 'package:module_dompet/data/datasource/db/database.dart';
import 'package:module_dompet/persentation/bloc/budget_event.dart';
import 'package:module_dompet/persentation/bloc/budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final TransactionDao _transactionDao;

  BudgetBloc(this._transactionDao) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<SaveBudgetLimit>(_onSaveBudgetLimit);
    on<DeleteBudgetLimit>(_onDeleteBudgetLimit);
    on<CheckBudgetLimits>(_onCheckBudgetLimits);
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      // Get budget limits for the month
      final budgetLimits = await _transactionDao.getBudgetLimitsForMonth(
        event.dompetId,
        event.month,
        event.year,
      );

      // Get spending for each category
      final categorySpending = await _transactionDao
          .getSpendingByCategoryForMonth(
            event.dompetId,
            event.month,
            event.year,
          );

      // Build budget data list
      final budgetData = budgetLimits.map((limit) {
        final spent = categorySpending[limit.category] ?? 0.0;
        return BudgetLimitData(
          id: limit.id,
          category: limit.category,
          limitAmount: limit.limitAmount,
          currentSpent: spent,
          isNotified: limit.isNotified,
        );
      }).toList();

      emit(
        BudgetLoaded(budgets: budgetData, month: event.month, year: event.year),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onSaveBudgetLimit(
    SaveBudgetLimit event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _transactionDao.insertOrUpdateBudgetLimit(
        BudgetLimitsCompanion(
          dompetId: Value(event.dompetId),
          category: Value(event.category),
          limitAmount: Value(event.limitAmount),
          month: Value(event.month),
          year: Value(event.year),
          isNotified: const Value(false),
        ),
      );

      // Reload budgets
      add(
        LoadBudgets(
          dompetId: event.dompetId,
          month: event.month,
          year: event.year,
        ),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDeleteBudgetLimit(
    DeleteBudgetLimit event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _transactionDao.deleteBudgetLimit(event.id);

      // Get current state to reload
      if (state is BudgetLoaded) {
        final currentState = state as BudgetLoaded;
        // Trigger reload by getting dompetId from first budget
        if (currentState.budgets.isNotEmpty) {
          // Reload will be handled by the page
        }
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onCheckBudgetLimits(
    CheckBudgetLimits event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      // Get budget limits
      final budgetLimits = await _transactionDao.getBudgetLimitsForMonth(
        event.dompetId,
        event.month,
        event.year,
      );

      // Get spending for each category
      final categorySpending = await _transactionDao
          .getSpendingByCategoryForMonth(
            event.dompetId,
            event.month,
            event.year,
          );

      // Check for limits reached
      for (final limit in budgetLimits) {
        final spent = categorySpending[limit.category] ?? 0.0;
        if (spent >= limit.limitAmount && !limit.isNotified) {
          // Mark as notified
          await _transactionDao.markBudgetAsNotified(limit.id);

          // Emit limit reached state for notification
          emit(
            BudgetLimitReached(
              category: limit.category,
              limit: limit.limitAmount,
              current: spent,
            ),
          );
        }
      }
    } catch (e) {
      // Silently handle errors in background check
    }
  }
}
