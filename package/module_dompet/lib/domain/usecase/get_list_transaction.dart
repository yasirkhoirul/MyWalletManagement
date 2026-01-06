import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/domain/repository/transaction_repository.dart';

class GetListTransaction {
  final TransactionRepository repository;

  GetListTransaction(this.repository);

  Stream<List<TransactionEntity>> execute({bool? withTempat}) {
    return repository.getListTransaction(withTempat: withTempat);
  }
}
