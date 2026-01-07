import 'package:module_core/constant/constant.dart';

class ReceiptEntity {
  final double? amount;
  final String? description;
  final ExpenseCategory? category;
  final DateTime? date;
  final String? receiptUrl;

  ReceiptEntity({
    this.amount,
    this.description,
    this.category,
    this.date,
    this.receiptUrl,
  });

  @override
  String toString() => 'ReceiptEntity(amount: $amount, description: $description, category: $category, date: $date, receiptUrl: $receiptUrl)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptEntity &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          description == other.description &&
          category == other.category &&
          date == other.date &&
          receiptUrl == other.receiptUrl;

  @override
  int get hashCode => Object.hash(amount, description, category, date, receiptUrl);
}
