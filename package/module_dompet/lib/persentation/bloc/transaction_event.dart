part of 'transaction_bloc.dart';

@immutable
sealed class TransactionEvent {}

class GetTransactionDetailEvent extends TransactionEvent {
  final int transactionId;
  GetTransactionDetailEvent(this.transactionId);
}

class InsertTransactionEvent extends TransactionEvent {
  final TransactionEntity entity;
  final int dompetId;
  InsertTransactionEvent(this.entity, this.dompetId);
}

class UpdateTransactionEvent extends TransactionEvent {
  final TransactionEntity entity;
  final int dompetId;
  UpdateTransactionEvent(this.entity, this.dompetId);
}

class DeleteTransactionEvent extends TransactionEvent {
  final int transactionId;
  DeleteTransactionEvent(this.transactionId);
}

class ProcessReceiptEvent extends TransactionEvent {
  final File imageFile;
  ProcessReceiptEvent(this.imageFile);
}
