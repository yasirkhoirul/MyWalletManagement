import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_dompet/data/datasource/db/dao.dart';
import 'package:module_dompet/persentation/bloc/analyze_event.dart';
import 'package:module_dompet/persentation/bloc/analyze_state.dart';

class AnalyzeBloc extends Bloc<AnalyzeEvent, AnalyzeState> {
  final TransactionDao _dao;

  AnalyzeBloc(this._dao) : super(AnalyzeInitial()) {
    on<LoadAnalyzeData>(_onLoadAnalyzeData);
  }

  Future<void> _onLoadAnalyzeData(
    LoadAnalyzeData event,
    Emitter<AnalyzeState> emit,
  ) async {
    emit(AnalyzeLoading());

    try {
      // Get daily spending
      final dailySpending = await _dao.getDailySpendingForMonth(
        event.dompetId,
        event.month,
        event.year,
      );

      // Get category spending for the selected month
      final categorySpending = await _dao.getSpendingByCategoryForMonth(
        event.dompetId,
        event.month,
        event.year,
      );

      // Find highest spending day
      int? highestDay;
      double highestAmount = 0;

      dailySpending.forEach((day, amount) {
        if (amount > highestAmount) {
          highestAmount = amount;
          highestDay = day;
        }
      });

      emit(
        AnalyzeLoaded(
          dailySpending: dailySpending,
          categorySpending: categorySpending,
          month: event.month,
          year: event.year,
          highestSpendingDay: highestDay,
          highestSpendingAmount: highestAmount,
        ),
      );
    } catch (e) {
      emit(AnalyzeError(e.toString()));
    }
  }
}
