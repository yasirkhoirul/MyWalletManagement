import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/domain/repository/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  Future<void> execute(TransactionEntity entity, int dompetId) {
    return repository.updateTransaction(entity, dompetId);
  }
}
