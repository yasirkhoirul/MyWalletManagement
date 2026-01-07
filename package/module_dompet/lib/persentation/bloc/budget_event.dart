import 'package:equatable/equatable.dart';
import 'package:module_core/constant/constant.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgets extends BudgetEvent {
  final int dompetId;
  final int month;
  final int year;

  const LoadBudgets({
    required this.dompetId,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [dompetId, month, year];
}

class SaveBudgetLimit extends BudgetEvent {
  final int dompetId;
  final ExpenseCategory category;
  final double limitAmount;
  final int month;
  final int year;

  const SaveBudgetLimit({
    required this.dompetId,
    required this.category,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [dompetId, category, limitAmount, month, year];
}

class DeleteBudgetLimit extends BudgetEvent {
  final int id;

  const DeleteBudgetLimit(this.id);

  @override
  List<Object?> get props => [id];
}

class CheckBudgetLimits extends BudgetEvent {
  final int dompetId;
  final int month;
  final int year;

  const CheckBudgetLimits({
    required this.dompetId,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [dompetId, month, year];
}
