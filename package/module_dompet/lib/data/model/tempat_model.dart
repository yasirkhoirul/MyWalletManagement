import 'package:json_annotation/json_annotation.dart';
import 'package:module_dompet/domain/entities/tempat_entity.dart';

part 'tempat_model.g.dart';

@JsonSerializable()
class TempatModel {
  final int? id;
  final double lat;
  final double lng;
  final String countryCode;
  final String areaCode;
  final String areaSource;

  TempatModel({
    this.id,
    required this.lat,
    required this.lng,
    required this.countryCode,
    required this.areaCode,
    required this.areaSource,
  });

  factory TempatModel.fromJson(Map<String, dynamic> json) => _$TempatModelFromJson(json);
  Map<String, dynamic> toJson() => _$TempatModelToJson(this);

  TempatEntity toEntity() => TempatEntity(
    id: id,
    lat: lat,
    lng: lng,
    countryCode: countryCode,
    areaCode: areaCode,
    areaSource: areaSource,
  );

  factory TempatModel.fromEntity(TempatEntity entity) => TempatModel(
    id: entity.id,
    lat: entity.lat,
    lng: entity.lng,
    countryCode: entity.countryCode,
    areaCode: entity.areaCode,
    areaSource: entity.areaSource,
  );
}