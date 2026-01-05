import 'package:json_annotation/json_annotation.dart';
import 'package:module_core/constant/constant.dart';
import 'tempat_model.dart';

part 'transaction_detail_model.g.dart';

@JsonSerializable()
class TransactionDetailModel {
  final int? id;
  final double amount;
  final DateTime tanggal;
  final bool isUpload;
  final TypeTransaction type;
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
    this.receiptImagePath,
    this.voiceNotePath,
    this.place,
    required this.dompetmonthid,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) => _$TransactionDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionDetailModelToJson(this);

  // Convenience to build detail from base transaction + tempat
  factory TransactionDetailModel.fromTransactionAndPlace(Map<String, dynamic> txJson, TempatModel? tempat) {
    final tx = TransactionDetailModel.fromJson(txJson);
    return tx.copyWith(place: tempat);
  }

  TransactionDetailModel copyWith({TempatModel? place}) => TransactionDetailModel(
    id: id,
    amount: amount,
    tanggal: tanggal,
    isUpload: isUpload,
    type: type,
    receiptImagePath: receiptImagePath,
    voiceNotePath: voiceNotePath,
    place: place ?? this.place,
    dompetmonthid: dompetmonthid,
  );
}
