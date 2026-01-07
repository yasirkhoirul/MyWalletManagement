// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDetailModel _$TransactionDetailModelFromJson(
  Map<String, dynamic> json,
) => TransactionDetailModel(
  id: (json['id'] as num?)?.toInt(),
  amount: (json['amount'] as num).toDouble(),
  tanggal: DateTime.parse(json['tanggal'] as String),
  isUpload: json['isUpload'] as bool,
  type: $enumDecode(_$TypeTransactionEnumMap, json['type']),
  description: json['description'] as String?,
  expenseCategory: $enumDecodeNullable(
    _$ExpenseCategoryEnumMap,
    json['expenseCategory'],
  ),
  receiptImagePath: json['receiptImagePath'] as String?,
  voiceNotePath: json['voiceNotePath'] as String?,
  place: json['place'] == null
      ? null
      : TempatModel.fromJson(json['place'] as Map<String, dynamic>),
  dompetmonthid: (json['dompetmonthid'] as num).toInt(),
);

Map<String, dynamic> _$TransactionDetailModelToJson(
  TransactionDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'tanggal': instance.tanggal.toIso8601String(),
  'isUpload': instance.isUpload,
  'type': _$TypeTransactionEnumMap[instance.type]!,
  'description': instance.description,
  'expenseCategory': _$ExpenseCategoryEnumMap[instance.expenseCategory],
  'receiptImagePath': instance.receiptImagePath,
  'voiceNotePath': instance.voiceNotePath,
  'place': instance.place,
  'dompetmonthid': instance.dompetmonthid,
};

const _$TypeTransactionEnumMap = {
  TypeTransaction.pemasukkan: 'pemasukkan',
  TypeTransaction.pengeluaran: 'pengeluaran',
};

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.makanan: 'makanan',
  ExpenseCategory.transportasi: 'transportasi',
  ExpenseCategory.belanja: 'belanja',
  ExpenseCategory.hiburan: 'hiburan',
  ExpenseCategory.kesehatan: 'kesehatan',
  ExpenseCategory.pendidikan: 'pendidikan',
  ExpenseCategory.tagihan: 'tagihan',
  ExpenseCategory.lainnya: 'lainnya',
};
