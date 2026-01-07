part of 'transaction_list_bloc.dart';

@immutable
sealed class TransactionListEvent {}

class GetListTransaction extends TransactionListEvent {
  final bool? withTempat;
  GetListTransaction({this.withTempat});
}

class GetTransactionsByDompetIdEvent extends TransactionListEvent {
  final int dompetId;
  GetTransactionsByDompetIdEvent(this.dompetId);
}

// Internal event used to update the transactions list from the stream
class _TransactionsUpdatedEvent extends TransactionListEvent {
  final List<TransactionEntity> transactions;
  _TransactionsUpdatedEvent(this.transactions);
}

class _TransactionsErrorEvent extends TransactionListEvent {
  final String message;
  _TransactionsErrorEvent(this.message);
}
