part of 'transaction_bloc.dart';

@immutable
sealed class TransactionState {}

final class TransactionInitial extends TransactionState {}

final class TransactionLoading extends TransactionState {}

final class TransactionDetailSuccess extends TransactionState {
  final TransactionEntity transaction;
  TransactionDetailSuccess(this.transaction);
}

final class TransactionSuccess extends TransactionState {
  final String message;
  TransactionSuccess(this.message);
}

final class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}

final class ProcessReceiptLoading extends TransactionState {}

final class ProcessReceiptSuccess extends TransactionState {
  final ReceiptEntity receipt;
  ProcessReceiptSuccess(this.receipt);
}

final class ProcessReceiptError extends TransactionState {
  final String message;
  ProcessReceiptError(this.message);
}
