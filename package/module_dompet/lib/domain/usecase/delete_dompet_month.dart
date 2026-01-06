import 'package:module_dompet/domain/repository/transaction_repository.dart';

class DeleteDompetMonth {
  final TransactionRepository repository;

  DeleteDompetMonth(this.repository);

  Future<void> execute(int dompetMonthId) {
    return repository.deleteDompetMonth(dompetMonthId);
  }
}
