import 'package:json_annotation/json_annotation.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'tempat_model.dart';

part 'transaction_detail_model.g.dart';

@JsonSerializable()
class TransactionDetailModel {
  final int? id;
  final double amount;
  final DateTime tanggal;
  final bool isUpload;
  final TypeTransaction type;
  final String? description;
  final ExpenseCategory? expenseCategory;
  final String? receiptImagePath;
  final String? voiceNotePath;
  final TempatModel? place; // place can be nullable
  final int dompetmonthid;

  TransactionDetailModel({
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

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionDetailModelToJson(this);

  // Convenience to build detail from base transaction + tempat
  factory TransactionDetailModel.fromTransactionAndPlace(
    Map<String, dynamic> txJson,
    TempatModel? tempat,
  ) {
    final tx = TransactionDetailModel.fromJson(txJson);
    return tx.copyWith(place: tempat);
  }

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
    place: place?.toEntity(),
    dompetmonthid: dompetmonthid,
  );

  factory TransactionDetailModel.fromEntity(TransactionEntity entity) =>
      TransactionDetailModel(
        id: entity.id,
        amount: entity.amount,
        tanggal: entity.tanggal,
        isUpload: entity.isUpload,
        type: entity.type,
        description: entity.description,
        expenseCategory: entity.expenseCategory,
        receiptImagePath: entity.receiptImagePath,
        voiceNotePath: entity.voiceNotePath,
        place: entity.place == null
            ? null
            : TempatModel.fromEntity(entity.place!),
        dompetmonthid: entity.dompetmonthid,
      );

  TransactionDetailModel copyWith({
    String? description,
    ExpenseCategory? expenseCategory,
    TempatModel? place,
  }) => TransactionDetailModel(
    id: id,
    amount: amount,
    tanggal: tanggal,
    isUpload: isUpload,
    type: type,
    description: description ?? this.description,
    expenseCategory: expenseCategory ?? this.expenseCategory,
    receiptImagePath: receiptImagePath,
    voiceNotePath: voiceNotePath,
    place: place ?? this.place,
    dompetmonthid: dompetmonthid,
  );
}
