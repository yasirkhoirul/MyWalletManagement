part of 'transaction_list_bloc.dart';

@immutable
sealed class TransactionListState {}

final class TransactionListInitial extends TransactionListState {}

final class TransactionListLoading extends TransactionListState {}

final class TransactionListSuccess extends TransactionListState {
  final List<TransactionEntity> transactions;
  TransactionListSuccess(this.transactions);
}

final class TransactionListError extends TransactionListState {
  final String message;
  TransactionListError(this.message);
}
