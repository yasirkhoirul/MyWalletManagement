// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: (json['id'] as num?)?.toInt(),
      amount: (json['amount'] as num).toDouble(),
      tanggal: DateTime.parse(json['tanggal'] as String),
      isUpload: json['isUpload'] as bool,
      type: $enumDecode(_$TypeTransactionEnumMap, json['type']),
      receiptImagePath: json['receiptImagePath'] as String?,
      voiceNotePath: json['voiceNotePath'] as String?,
      place: (json['place'] as num?)?.toInt(),
      dompetmonthid: (json['dompetmonthid'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'tanggal': instance.tanggal.toIso8601String(),
      'isUpload': instance.isUpload,
      'type': _$TypeTransactionEnumMap[instance.type]!,
      'receiptImagePath': instance.receiptImagePath,
      'voiceNotePath': instance.voiceNotePath,
      'place': instance.place,
      'dompetmonthid': instance.dompetmonthid,
    };

const _$TypeTransactionEnumMap = {
  TypeTransaction.pemasukkan: 'pemasukkan',
  TypeTransaction.pengeluaran: 'pengeluaran',
};
