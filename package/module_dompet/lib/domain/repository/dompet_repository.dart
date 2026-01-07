import 'package:module_dompet/domain/entities/dompet_entity.dart';

/// Repository interface for Dompet (wallet) operations
abstract class DompetRepository {
  /// Get dompet by Firebase user ID
  Future<DompetEntity?> getDompetByUserId(String userId);

  /// Create new dompet for user with initial amount
  Future<DompetEntity> createDompet(String userId, double initialAmount);

  /// Watch dompet for reactive updates
  Stream<DompetEntity?> watchDompet(String userId);
}
