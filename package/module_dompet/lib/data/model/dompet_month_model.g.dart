// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dompet_month_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DompetMonthModel _$DompetMonthModelFromJson(Map<String, dynamic> json) =>
    DompetMonthModel(
      id: (json['id'] as num?)?.toInt(),
      pemasukkan: (json['pemasukkan'] as num).toDouble(),
      pengeluaran: (json['pengeluaran'] as num).toDouble(),
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      dompetid: (json['dompetid'] as num).toInt(),
    );

Map<String, dynamic> _$DompetMonthModelToJson(DompetMonthModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pemasukkan': instance.pemasukkan,
      'pengeluaran': instance.pengeluaran,
      'month': instance.month,
      'year': instance.year,
      'dompetid': instance.dompetid,
    };
