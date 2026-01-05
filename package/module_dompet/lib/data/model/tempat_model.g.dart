// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tempat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TempatModel _$TempatModelFromJson(Map<String, dynamic> json) => TempatModel(
  id: (json['id'] as num?)?.toInt(),
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  countryCode: json['countryCode'] as String,
  areaCode: json['areaCode'] as String,
  areaSource: json['areaSource'] as String,
);

Map<String, dynamic> _$TempatModelToJson(TempatModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lat': instance.lat,
      'lng': instance.lng,
      'countryCode': instance.countryCode,
      'areaCode': instance.areaCode,
      'areaSource': instance.areaSource,
    };
