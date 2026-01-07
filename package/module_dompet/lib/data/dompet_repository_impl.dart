import 'package:module_dompet/data/datasource/dompet_local_datasource.dart';
import 'package:module_dompet/domain/entities/dompet_entity.dart';
import 'package:module_dompet/domain/repository/dompet_repository.dart';

/// Implementation of DompetRepository
class DompetRepositoryImpl implements DompetRepository {
  final DompetLocalDatasource _datasource;

  const DompetRepositoryImpl(this._datasource);

  @override
  Future<DompetEntity?> getDompetByUserId(String userId) async {
    final model = await _datasource.getDompetByUserId(userId);
    if (model == null) return null;
    return DompetEntity(
      id: model.id,
      userId: model.userId,
      amount: model.amount,
      pengeluaran: model.pengeluaran,
      pemasukkan: model.pemasukkan,
    );
  }

  @override
  Future<DompetEntity> createDompet(String userId, double initialAmount) async {
    final id = await _datasource.createDompet(userId, initialAmount);
    return DompetEntity(
      id: id,
      userId: userId,
      amount: initialAmount,
      pengeluaran: 0.0,
      pemasukkan: 0.0,
    );
  }

  @override
  Stream<DompetEntity?> watchDompet(String userId) {
    return _datasource.watchDompetByUserId(userId).map((model) {
      if (model == null) return null;
      return DompetEntity(
        id: model.id,
        userId: model.userId,
        amount: model.amount,
        pengeluaran: model.pengeluaran,
        pemasukkan: model.pemasukkan,
      );
    });
  }
}
