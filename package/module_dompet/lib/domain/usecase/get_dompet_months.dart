import 'package:module_dompet/domain/entities/dompet_month_entity.dart';
import 'package:module_dompet/domain/repository/transaction_repository.dart';

class GetDompetMonths {
  final TransactionRepository repository;

  GetDompetMonths(this.repository);

  Stream<List<DompetMonthEntity>> execute(int dompetId) {
    return repository.watchDompetMonths(dompetId);
  }
}
