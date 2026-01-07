import 'package:json_annotation/json_annotation.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final int? id;
  final double amount;
  final DateTime tanggal;
  final bool isUpload;
  final TypeTransaction type;
  final String? description;
  final ExpenseCategory? expenseCategory;
  final String? receiptImagePath;
  final String? voiceNotePath;
  final int? place; // foreign key to Tempat
  final int dompetmonthid;

  TransactionModel({
    this.id,
    required this.amount,
    required this.tanggal,
    required this.isUpload,
    required this.type,
    this.description,
    this.expenseCategory,
    this.receiptImagePath,
    this.voiceNotePath,
    this.place,
    required this.dompetmonthid,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  TransactionEntity toEntity() => TransactionEntity(
    id: id,
    amount: amount,
    tanggal: tanggal,
    isUpload: isUpload,
    type: type,
    description: description,
    expenseCategory: expenseCategory,
    receiptImagePath: receiptImagePath,
    voiceNotePath: voiceNotePath,
    place:
        null, // Place info not in this model; use TransactionDetailModel for full details
    dompetmonthid: dompetmonthid,
  );

  factory TransactionModel.fromEntity(TransactionEntity entity) =>
      TransactionModel(
        id: entity.id,
        amount: entity.amount,
        tanggal: entity.tanggal,
        isUpload: entity.isUpload,
        type: entity.type,
        description: entity.description,
        expenseCategory: entity.expenseCategory,
        receiptImagePath: entity.receiptImagePath,
        voiceNotePath: entity.voiceNotePath,
        place: null,
        dompetmonthid: entity.dompetmonthid,
      );
}
