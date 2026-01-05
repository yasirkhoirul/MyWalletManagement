import 'package:json_annotation/json_annotation.dart';

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

  // Convenience: create from a Drift generated data class if needed
  // (e.g., if you have a `TempatData` class after codegen)
  // factory TempatModel.fromData(TempatData d) => TempatModel(
  //   id: d.id,
  //   lat: d.lat,
  //   lng: d.lng,
  //   countryCode: d.countryCode,
  //   areaCode: d.areaCode,
  //   areaSource: d.areaSource,
  // );
}
