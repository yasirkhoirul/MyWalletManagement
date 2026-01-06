import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/domain/repository/transaction_repository.dart';

class GetTransactionDetail {
  final TransactionRepository repository;

  GetTransactionDetail(this.repository);

  Future<TransactionEntity> execute(int transactionId) {
    return repository.getTransactionDetail(transactionId);
  }
}
