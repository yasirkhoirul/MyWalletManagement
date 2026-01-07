import 'dart:io';

import 'package:logger/logger.dart';
import 'package:module_dompet/data/datasource/dompet_local_datasource.dart';
import 'package:module_dompet/data/datasource/receipt_remote_datasource.dart';
import 'package:module_dompet/data/model/receipt_result_model.dart';
import 'package:module_dompet/data/model/transaction_detail_model.dart';
import 'package:module_dompet/domain/entities/dompet_month_entity.dart';
import 'package:module_dompet/domain/entities/receipt_entity.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/domain/repository/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DompetLocalDatasource localDatasource;
  final ReceiptRemoteDataSource remoteDataSource;
  TransactionRepositoryImpl(
    this.localDatasource, {
    required this.remoteDataSource,
  });

  @override
  Future<int> insertTransaction(TransactionEntity entity, int dompetId) async {
    final model = TransactionDetailModel.fromEntity(entity);

    try {
      await localDatasource.insertTransaction(model, dompetId);
      return 1;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream<List<TransactionEntity>> getListTransaction({bool? withTempat}) {
    try {
      return localDatasource.getListTransaction(withTempat: withTempat).map((
        models,
      ) {
        return models.map((model) => model.toEntity()).toList();
      });
    } catch (e) {
      throw Exception('Failed to get list transaction: $e');
    }
  }

  @override
  Stream<List<TransactionEntity>> getTransactionsByDompetId(int dompetId) {
    try {
      return localDatasource.watchTransactionsByDompetId(dompetId).map((
        models,
      ) {
        return models.map((model) => model.toEntity()).toList();
      });
    } catch (e) {
      throw Exception('Failed to get transactions by dompetId: $e');
    }
  }

  @override
  Future<TransactionEntity> getTransactionDetail(int transactionId) async {
    try {
      final model = await localDatasource.getDetail(transactionId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get transaction detail: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionEntity entity, int dompetId) async {
    try {
      final model = TransactionDetailModel.fromEntity(entity);
      await localDatasource.updateTransaction(model, dompetId);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Stream<List<DompetMonthEntity>> watchDompetMonths(int dompetId) {
    try {
      return localDatasource.watchDompetMonths(dompetId).map((models) {
        return models.map((model) => model.toEntity()).toList();
      });
    } catch (e) {
      throw Exception('Failed to watch dompet months: $e');
    }
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    try {
      await localDatasource.deleteTransaction(transactionId);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  @override
  Future<void> deleteDompetMonth(int dompetMonthId) async {
    try {
      await localDatasource.deleteDompetMonth(dompetMonthId);
    } catch (e) {
      throw Exception('Failed to delete dompet month: $e');
    }
  }

  @override
  Future<ReceiptEntity?> processReceipt(File imageFile) async {
    try {
      final ReceiptAnalysisResult? data = await remoteDataSource.processReceipt(
        imageFile,
      );
      if (data == null) {
        return null;
      }
      return ReceiptEntity(
        amount: data.amount,
        description: data.description,
        category: data.category,
        date: data.date,
        receiptUrl: data.receiptUrl,
      );
    } catch (e) {
      Logger().e(e);
      rethrow;
    }
  }
}
