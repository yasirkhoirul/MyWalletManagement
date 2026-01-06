class TempatEntity {
  final int? id;
  final double lat;
  final double lng;
  final String countryCode;
  final String areaCode;
  final String areaSource;

  TempatEntity({
    this.id,
    required this.lat,
    required this.lng,
    required this.countryCode,
    required this.areaCode,
    required this.areaSource,
  });

  @override
  String toString() => 'TempatEntity(id: $id, lat: $lat, lng: $lng, countryCode: $countryCode, areaCode: $areaCode, areaSource: $areaSource)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempatEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lat == other.lat &&
          lng == other.lng &&
          countryCode == other.countryCode &&
          areaCode == other.areaCode &&
          areaSource == other.areaSource;

  @override
  int get hashCode => Object.hash(id, lat, lng, countryCode, areaCode, areaSource);
}
