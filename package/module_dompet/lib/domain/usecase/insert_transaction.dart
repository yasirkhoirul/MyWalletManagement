import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/domain/repository/transaction_repository.dart';

class InsertTransaction {
  final TransactionRepository repository;

  InsertTransaction(this.repository);

  Future<int> execute(TransactionEntity entity, int dompetId) {
    return repository.insertTransaction(entity, dompetId);
  }
}
