import 'dart:io';

import 'package:module_dompet/domain/entities/dompet_month_entity.dart';
import 'package:module_dompet/domain/entities/receipt_entity.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  // Read
  Stream<List<TransactionEntity>> getListTransaction({bool? withTempat});
  Stream<List<TransactionEntity>> getTransactionsByDompetId(int dompetId);
  Future<TransactionEntity> getTransactionDetail(int transactionId);
  Future<ReceiptEntity?> processReceipt(File imageFile);

  // Create
  Future<int> insertTransaction(TransactionEntity entity, int dompetId);

  // Update
  Future<void> updateTransaction(TransactionEntity entity, int dompetId);

  // Delete
  Future<void> deleteTransaction(int transactionId);
  Future<void> deleteDompetMonth(int dompetMonthId);

  // DompetMonth
  Stream<List<DompetMonthEntity>> watchDompetMonths(int dompetId);
}
