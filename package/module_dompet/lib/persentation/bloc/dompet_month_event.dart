part of 'dompet_month_bloc.dart';

@immutable
sealed class DompetMonthEvent {}

class GetDompetMonthsEvent extends DompetMonthEvent {
  final int dompetId;
  GetDompetMonthsEvent(this.dompetId);
}

class DeleteDompetMonthEvent extends DompetMonthEvent {
  final int dompetMonthId;
  DeleteDompetMonthEvent(this.dompetMonthId);
}

// Internal event used to update the months list from the stream
class _DompetMonthsUpdatedEvent extends DompetMonthEvent {
  final List<DompetMonthEntity> months;
  _DompetMonthsUpdatedEvent(this.months);
}

class _DompetMonthsErrorEvent extends DompetMonthEvent {
  final String message;
  _DompetMonthsErrorEvent(this.message);
}
