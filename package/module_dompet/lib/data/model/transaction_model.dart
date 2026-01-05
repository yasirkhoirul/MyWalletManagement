import 'package:json_annotation/json_annotation.dart';
import 'package:module_core/constant/constant.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final int? id;
  final double amount;
  final DateTime tanggal;
  final bool isUpload;
  final TypeTransaction type;
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
    this.receiptImagePath,
    this.voiceNotePath,
    this.place,
    required this.dompetmonthid,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
