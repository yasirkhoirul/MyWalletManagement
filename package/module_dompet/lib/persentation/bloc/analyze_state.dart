import 'package:equatable/equatable.dart';
import 'package:module_core/constant/constant.dart';

abstract class AnalyzeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnalyzeInitial extends AnalyzeState {}

class AnalyzeLoading extends AnalyzeState {}

class AnalyzeLoaded extends AnalyzeState {
  /// Daily spending map: day -> amount
  final Map<int, double> dailySpending;

  /// Category spending map
  final Map<ExpenseCategory, double> categorySpending;

  /// Highest spending day
  final int? highestSpendingDay;
  final double highestSpendingAmount;

  /// Month and year being analyzed
  final int month;
  final int year;

  AnalyzeLoaded({
    required this.dailySpending,
    required this.categorySpending,
    required this.month,
    required this.year,
    this.highestSpendingDay,
    this.highestSpendingAmount = 0,
  });

  @override
  List<Object?> get props => [
    dailySpending,
    categorySpending,
    month,
    year,
    highestSpendingDay,
  ];
}

class AnalyzeError extends AnalyzeState {
  final String message;
  AnalyzeError(this.message);

  @override
  List<Object?> get props => [message];
}
