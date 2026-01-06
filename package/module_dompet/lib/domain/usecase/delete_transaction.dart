import 'package:module_dompet/domain/repository/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  Future<void> execute(int transactionId) {
    return repository.deleteTransaction(transactionId);
  }
}
