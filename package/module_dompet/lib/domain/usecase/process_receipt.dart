import 'dart:io';

import 'package:module_dompet/domain/entities/receipt_entity.dart';
import 'package:module_dompet/domain/repository/transaction_repository.dart';

class ProcessReceipt {
  final TransactionRepository repository;

  ProcessReceipt(this.repository);

  Future<ReceiptEntity?> call(File imageFile) async {
    return await repository.processReceipt(imageFile);
  }
}
