import 'package:module_dompet/domain/entities/dompet_entity.dart';
import 'package:module_dompet/domain/repository/dompet_repository.dart';

/// Usecase to get or create a dompet (wallet) for a user
class GetOrCreateDompet {
  final DompetRepository _repository;

  const GetOrCreateDompet(this._repository);

  /// Get dompet by user ID, returns null if not found
  Future<DompetEntity?> execute(String userId) {
    return _repository.getDompetByUserId(userId);
  }

  /// Create a new dompet for user with initial amount
  Future<DompetEntity> create(String userId, double initialAmount) {
    return _repository.createDompet(userId, initialAmount);
  }

  /// Watch dompet for reactive updates
  Stream<DompetEntity?> watch(String userId) {
    return _repository.watchDompet(userId);
  }
}
