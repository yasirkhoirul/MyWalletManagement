import 'package:bloc/bloc.dart';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_dompet/domain/entities/dompet_month_entity.dart';
import 'package:module_dompet/domain/usecase/get_dompet_months.dart';
import 'package:module_dompet/domain/usecase/delete_dompet_month.dart';

part 'dompet_month_event.dart';
part 'dompet_month_state.dart';

class DompetMonthBloc extends Bloc<DompetMonthEvent, DompetMonthState> {
  final GetDompetMonths getDompetMonths;
  final DeleteDompetMonth deleteDompetMonth;

  StreamSubscription<List<DompetMonthEntity>>? _monthsSub;
  final Set<int> _deletingIds = {};

  DompetMonthBloc(this.getDompetMonths, this.deleteDompetMonth) : super(DompetMonthInitial()) {
    on<GetDompetMonthsEvent>(_onGetDompetMonths);
    on<_DompetMonthsUpdatedEvent>(_onMonthsUpdated);
    on<_DompetMonthsErrorEvent>(_onMonthsError);
    on<DeleteDompetMonthEvent>(_onDeleteDompetMonth);
  }

  void _onGetDompetMonths(
    GetDompetMonthsEvent event,
    Emitter<DompetMonthState> emit,
  ) {
    // cancel previous subscription
    _monthsSub?.cancel();
    emit(DompetMonthLoading());

    _monthsSub = getDompetMonths.execute(event.dompetId).listen(
      (months) => add(_DompetMonthsUpdatedEvent(months)),
      onError: (err) => add(_DompetMonthsErrorEvent(err.toString())),
    );
  }

  void _onMonthsUpdated(
    _DompetMonthsUpdatedEvent event,
    Emitter<DompetMonthState> emit,
  ) {
    emit(DompetMonthSuccess(event.months, deletingIds: Set.from(_deletingIds)));
  }

  void _onMonthsError(
    _DompetMonthsErrorEvent event,
    Emitter<DompetMonthState> emit,
  ) {
    emit(DompetMonthError(event.message));
  }

  Future<void> _onDeleteDompetMonth(
    DeleteDompetMonthEvent event,
    Emitter<DompetMonthState> emit,
  ) async {
    final id = event.dompetMonthId;

    // mark as deleting
    _deletingIds.add(id);
    if (state is DompetMonthSuccess) {
      final s = state as DompetMonthSuccess;
      emit(DompetMonthSuccess(s.months, deletingIds: Set.from(_deletingIds)));
    }

    try {
      await deleteDompetMonth.execute(id);

      // remove deleting marker
      _deletingIds.remove(id);

      // re-emit current months state (stream will also update)
      if (state is DompetMonthSuccess) {
        final s = state as DompetMonthSuccess;
        emit(DompetMonthSuccess(s.months, deletingIds: Set.from(_deletingIds)));
      }

      emit(DompetMonthActionSuccess('Berhasil menghapus bulan'));
    } catch (e) {
      _deletingIds.remove(id);
      if (state is DompetMonthSuccess) {
        final s = state as DompetMonthSuccess;
        emit(DompetMonthSuccess(s.months, deletingIds: Set.from(_deletingIds)));
      }
      emit(DompetMonthActionFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _monthsSub?.cancel();
    return super.close();
  }
}
