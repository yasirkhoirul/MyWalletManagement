import 'package:module_core/constant/constant.dart';

class ReceiptAnalysisResult {
  final double? amount;
  final String? description;
  final ExpenseCategory? category;
  final DateTime? date;
  final String? receiptUrl;

  ReceiptAnalysisResult({
    this.amount,
    this.description,
    this.category,
    this.date,
    this.receiptUrl,
  });
}
