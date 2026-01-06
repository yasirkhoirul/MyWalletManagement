part of 'dompet_month_bloc.dart';

@immutable
sealed class DompetMonthState {}

final class DompetMonthInitial extends DompetMonthState {}

final class DompetMonthLoading extends DompetMonthState {}

final class DompetMonthSuccess extends DompetMonthState {
  final List<DompetMonthEntity> months;
  final Set<int> deletingIds; // per-item deleting indicator
  DompetMonthSuccess(this.months, {Set<int>? deletingIds}) : deletingIds = deletingIds ?? {};
}

final class DompetMonthError extends DompetMonthState {
  final String message;
  DompetMonthError(this.message);
}

// Transient states for action results
final class DompetMonthActionSuccess extends DompetMonthState {
  final String message;
  DompetMonthActionSuccess(this.message);
}

final class DompetMonthActionFailure extends DompetMonthState {
  final String message;
  DompetMonthActionFailure(this.message);
}
