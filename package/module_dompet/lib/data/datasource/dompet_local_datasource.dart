import 'package:module_dompet/data/datasource/db/dao.dart';
import 'package:module_dompet/data/datasource/db/database.dart';
import 'package:module_dompet/data/model/transaction_detail_model.dart';
import 'package:module_dompet/data/model/transaction_model.dart';

abstract class DompetLocalDatasource {
  Future<TransactionDetailModel> getDetail();
  Stream<List<TransactionModel>> getListTransaction({bool? withTempat});
  Future<void> insertTransaction(TransactionDetailModel payload);
  Future<void> updateTransaction(TransactionDetailModel payload);
  Future<void> deleteTransaction();
  Future<void> deleteDompetMonth();
}

class DompetLocalDatasourceImpl implements DompetLocalDatasource {
  final TransactionDao transactionDao;
  final AppDatabase appDatabase;
  const DompetLocalDatasourceImpl(this.appDatabase,this.transactionDao);
  @override
  Future<void> deleteDompetMonth() {
    // TODO: implement deleteDompetMonth
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTransaction() {
    // TODO: implement deleteTransaction
    throw UnimplementedError();
  }

  @override
  Future<TransactionDetailModel> getDetail() {
    // TODO: implement getDetail
    throw UnimplementedError();
  }

  @override
  Stream<List<TransactionModel>> getListTransaction({bool? withTempat}) {
    Stream<List<Transaction>> dataStream;
    
    if (withTempat != null) {
      if (withTempat) {
        dataStream = transactionDao.watchTransactionsWithPlace();
      } else {
        dataStream = transactionDao.watchTransactionsWithOutPlace();
      }
    } else {
      dataStream = transactionDao.watchTransactions();
    }
    
    return dataStream.map((transactions) {
      return transactions.map((tx) {
        return TransactionModel(
          id: tx.id,
          amount: tx.amount,
          tanggal: tx.tanggal,
          isUpload: tx.isUpload,
          type: tx.type,
          receiptImagePath: tx.receiptImagePath,
          voiceNotePath: tx.voiceNotePath,
          place: null, // place info not included in basic Transaction
          dompetmonthid: tx.dompetmonthid,
        );
      }).toList();
    });
  }

  @override
  Future<void> insertTransaction(TransactionDetailModel payload) {
    // TODO: implement insertTransaction
    throw UnimplementedError();
  }

  @override
  Future<void> updateTransaction(TransactionDetailModel payload) {
    // TODO: implement updateTransaction
    throw UnimplementedError();
  }

}