import 'package:module_core/constant/constant.dart';
import 'tempat_entity.dart';

class TransactionEntity {
  final int? id;
  final double amount;
  final DateTime tanggal;
  final bool isUpload;
  final TypeTransaction type;
  final String? receiptImagePath;
  final String? voiceNotePath;
  final TempatEntity? place;
  final int dompetmonthid;

  TransactionEntity({
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

  @override
  String toString() => 'TransactionEntity(id: $id, amount: $amount, tanggal: $tanggal, isUpload: $isUpload, type: $type, place: $place, dompetmonthid: $dompetmonthid)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          amount == other.amount &&
          tanggal == other.tanggal &&
          isUpload == other.isUpload &&
          type == other.type &&
          receiptImagePath == other.receiptImagePath &&
          voiceNotePath == other.voiceNotePath &&
          place == other.place &&
          dompetmonthid == other.dompetmonthid;

  @override
  int get hashCode => Object.hash(
      id, amount, tanggal, isUpload, type, receiptImagePath, voiceNotePath, place, dompetmonthid);
}
