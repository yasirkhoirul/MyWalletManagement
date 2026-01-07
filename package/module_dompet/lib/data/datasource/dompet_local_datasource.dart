import 'package:drift/drift.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/data/datasource/db/dao.dart';
import 'package:module_dompet/data/datasource/db/database.dart';
import 'package:module_dompet/data/datasource/sync_service.dart';
import 'package:module_dompet/data/model/dompet_model.dart';
import 'package:module_dompet/data/model/dompet_month_model.dart';
import 'package:module_dompet/data/model/tempat_model.dart';
import 'package:module_dompet/data/model/transaction_detail_model.dart';
import 'package:module_dompet/data/model/transaction_model.dart';

abstract class DompetLocalDatasource {
  Future<TransactionDetailModel> getDetail(int transactionId);
  Stream<List<TransactionModel>> getListTransaction({bool? withTempat});
  Stream<List<TransactionModel>> watchTransactionsByDompetId(int dompetId);
  Future<void> insertTransaction(TransactionDetailModel payload, int dompetId);
  Future<void> updateTransaction(TransactionDetailModel payload, int dompetId);
  Future<void> deleteTransaction(int transactionId);
  Future<void> deleteDompetMonth(int dompetMonthId);
  Stream<List<DompetMonthModel>> watchDompetMonths(int dompetId);

  // Dompet operations
  Future<DompetModel?> getDompetByUserId(String userId);
  Future<int> createDompet(String userId, double initialAmount);
  Stream<DompetModel?> watchDompetByUserId(String userId);
}

class DompetLocalDatasourceImpl implements DompetLocalDatasource {
  final TransactionDao transactionDao;
  final AppDatabase appDatabase;
  const DompetLocalDatasourceImpl(this.appDatabase, this.transactionDao);
  @override
  Future<void> deleteDompetMonth(int dompetMonthId) async {
    await transactionDao.deleteDompetMonth(dompetMonthId);
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    // Use soft delete for offline-first sync
    // Transaction will be marked for deletion and removed from Firestore on next sync
    await transactionDao.softDeleteTransaction(transactionId);
  }

  @override
  Future<TransactionDetailModel> getDetail(int transactionId) async {
    final result = await transactionDao.getTransactionDetail(transactionId);
    final tx = result.readTable(appDatabase.transactions);
    final tempat = result.readTableOrNull(appDatabase.tempat);

    // Map Tempat data to TempatModel if exists
    TempatModel? tempatModel;
    if (tempat != null) {
      tempatModel = TempatModel(
        id: tempat.id,
        lat: tempat.lat,
        lng: tempat.lng,
        countryCode: tempat.countryCode,
        areaCode: tempat.areaCode,
        areaSource: tempat.areaSource,
      );
    }

    return TransactionDetailModel(
      id: tx.id,
      amount: tx.amount,
      tanggal: tx.tanggal,
      isUpload: tx.isUpload,
      type: tx.type,
      description: tx.description,
      expenseCategory: tx.expenseCategory,
      receiptImagePath: tx.receiptImagePath,
      voiceNotePath: tx.voiceNotePath,
      place: tempatModel,
      dompetmonthid: tx.dompetmonthid,
    );
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
          description: tx.description,
          expenseCategory: tx.expenseCategory,
          receiptImagePath: tx.receiptImagePath,
          voiceNotePath: tx.voiceNotePath,
          place: null, // place info not included in basic Transaction
          dompetmonthid: tx.dompetmonthid,
        );
      }).toList();
    });
  }

  @override
  Stream<List<TransactionModel>> watchTransactionsByDompetId(int dompetId) {
    return transactionDao.watchTransactionsByDompetId(dompetId).map((
      transactions,
    ) {
      return transactions.map((tx) {
        return TransactionModel(
          id: tx.id,
          amount: tx.amount,
          tanggal: tx.tanggal,
          isUpload: tx.isUpload,
          type: tx.type,
          description: tx.description,
          expenseCategory: tx.expenseCategory,
          receiptImagePath: tx.receiptImagePath,
          voiceNotePath: tx.voiceNotePath,
          place: null,
          dompetmonthid: tx.dompetmonthid,
        );
      }).toList();
    });
  }

  @override
  Future<void> insertTransaction(
    TransactionDetailModel payload,
    int dompetId,
  ) async {
    // First, upsert DompetMonth to get the dompetmonthid
    final isPemasukkan = payload.type == TypeTransaction.pemasukkan;
    final dompetMonthId = await transactionDao.upsertDompetMonth(
      dompetId: dompetId,
      month: payload.tanggal.month,
      year: payload.tanggal.year,
      amount: payload.amount,
      isPemasukkan: isPemasukkan,
    );

    // Create TransactionsCompanion for insertion with the dompetmonthid
    final now = DateTime.now();
    final companion = TransactionsCompanion.insert(
      uuid: SyncService.generateUuid(), // Auto-generate UUID for sync
      amount: payload.amount,
      tanggal: payload.tanggal,
      isUpload: const Value(false), // Not uploaded yet - pending sync
      type: payload.type,
      description: Value(payload.description),
      expenseCategory: Value(payload.expenseCategory),
      receiptImagePath: Value(payload.receiptImagePath),
      voiceNotePath: Value(payload.voiceNotePath),
      wantToDelete: const Value(false),
      updatedAt: now,
      dompetmonthid: dompetMonthId,
    );

    final txId = await transactionDao.insertTransaction(companion);

    // Insert place if provided and link it to the transaction
    if (payload.place != null) {
      final p = payload.place!;
      await appDatabase
          .into(appDatabase.tempat)
          .insertOnConflictUpdate(
            TempatCompanion(
              id: p.id == null ? const Value.absent() : Value(p.id!),
              lat: Value(p.lat),
              lng: Value(p.lng),
              countryCode: Value(p.countryCode),
              areaCode: Value(p.areaCode),
              areaSource: Value(p.areaSource),
              transactionId: Value(txId),
            ),
          );
    }
  }

  @override
  Future<void> updateTransaction(
    TransactionDetailModel payload,
    int dompetId,
  ) async {
    // DAO updateTransaction now handles DompetMonth adjustment internally
    await transactionDao.updateTransaction(payload);
  }

  @override
  Stream<List<DompetMonthModel>> watchDompetMonths(int dompetId) {
    return transactionDao.watchDompetMonths(dompetId).map((months) {
      return months
          .map(
            (m) => DompetMonthModel(
              id: m.id,
              pemasukkan: m.pemasukkan,
              pengeluaran: m.pengeluaran,
              month: m.month,
              year: m.year,
              dompetid: m.dompetid,
            ),
          )
          .toList();
    });
  }

  // ============ DOMPET OPERATIONS ============

  @override
  Future<DompetModel?> getDompetByUserId(String userId) async {
    final data = await transactionDao.getDompetByUserId(userId);
    if (data == null) return null;
    return DompetModel(
      id: data.id,
      userId: data.userid,
      amount: data.amount,
      pengeluaran: data.pengeluaran,
      pemasukkan: data.pemasukkan,
    );
  }

  @override
  Future<int> createDompet(String userId, double initialAmount) async {
    return await transactionDao.createDompet(userId, initialAmount);
  }

  @override
  Stream<DompetModel?> watchDompetByUserId(String userId) {
    return transactionDao.watchDompetByUserId(userId).map((data) {
      if (data == null) return null;
      return DompetModel(
        id: data.id,
        userId: data.userid,
        amount: data.amount,
        pengeluaran: data.pengeluaran,
        pemasukkan: data.pemasukkan,
      );
    });
  }
}
