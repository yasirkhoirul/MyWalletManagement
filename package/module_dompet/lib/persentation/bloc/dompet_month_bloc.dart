import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'dompet_month_event.dart';
part 'dompet_month_state.dart';

class DompetMonthBloc extends Bloc<DompetMonthEvent, DompetMonthState> {
  DompetMonthBloc() : super(DompetMonthInitial()) {
    on<DompetMonthEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
