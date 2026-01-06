import 'package:json_annotation/json_annotation.dart';
import 'package:module_dompet/domain/entities/dompet_month_entity.dart';

part 'dompet_month_model.g.dart';

@JsonSerializable()
class DompetMonthModel {
  final int? id;
  final double pemasukkan;
  final double pengeluaran;
  final int month;
  final int year;
  final int dompetid;

  DompetMonthModel({
    this.id,
    required this.pemasukkan,
    required this.pengeluaran,
    required this.month,
    required this.year,
    required this.dompetid,
  });

  factory DompetMonthModel.fromJson(Map<String, dynamic> json) => _$DompetMonthModelFromJson(json);
  Map<String, dynamic> toJson() => _$DompetMonthModelToJson(this);

  DompetMonthEntity toEntity() => DompetMonthEntity(
    id: id,
    pemasukkan: pemasukkan,
    pengeluaran: pengeluaran,
    month: month,
    year: year,
    dompetid: dompetid,
  );

  factory DompetMonthModel.fromEntity(DompetMonthEntity entity) => DompetMonthModel(
    id: entity.id,
    pemasukkan: entity.pemasukkan,
    pengeluaran: entity.pengeluaran,
    month: entity.month,
    year: entity.year,
    dompetid: entity.dompetid,
  );
}
