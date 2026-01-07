import 'package:equatable/equatable.dart';
import 'package:module_core/constant/constant.dart';

/// Represents a budget limit with its current spending
class BudgetLimitData {
  final int id;
  final ExpenseCategory category;
  final double limitAmount;
  final double currentSpent;
  final bool isNotified;

  BudgetLimitData({
    required this.id,
    required this.category,
    required this.limitAmount,
    required this.currentSpent,
    required this.isNotified,
  });

  double get percentage =>
      limitAmount > 0 ? (currentSpent / limitAmount * 100).clamp(0, 100) : 0;
  bool get isOverLimit => currentSpent >= limitAmount;
  double get remaining =>
      (limitAmount - currentSpent).clamp(0, double.infinity);
}

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<BudgetLimitData> budgets;
  final int month;
  final int year;

  const BudgetLoaded({
    required this.budgets,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [budgets, month, year];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetLimitReached extends BudgetState {
  final ExpenseCategory category;
  final double limit;
  final double current;

  const BudgetLimitReached({
    required this.category,
    required this.limit,
    required this.current,
  });

  @override
  List<Object?> get props => [category, limit, current];
}
