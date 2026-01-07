import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/domain/repository/transaction_repository.dart';

/// Usecase to get transactions filtered by dompetId
class GetTransactionsByDompet {
  final TransactionRepository repository;

  GetTransactionsByDompet(this.repository);

  Stream<List<TransactionEntity>> execute(int dompetId) {
    return repository.getTransactionsByDompetId(dompetId);
  }
}
