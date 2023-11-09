class ChargerData {
  final int chargerId;
  final String availability;
  final String type;
  final String location;
  final double lat;
  final double lon;
  final int isStation;
  final int stationAvailable;
  final int timeToGet;
  final int rate;

  ChargerData({
    required this.chargerId,
    required this.availability,
    required this.type,
    required this.location,
    required this.lat,
    required this.lon,
    required this.isStation,
    required this.stationAvailable,
    required this.timeToGet,
    required this.rate,
  });

  factory ChargerData.fromJson(Map<String, dynamic> json) {
    return ChargerData(
      chargerId: json['charger_id'],
      availability: json['availability'],
      type: json['type'],
      location: json['Location'],
      lat: json['lat'],
      lon: json['lon'],
      isStation: json['isStation'],
      stationAvailable: json['station_available'],
      timeToGet: json['time_to_get'],
      rate: json['rate'],
    );
  }
}
class LocationData {
  final int locId;
  final String location;
  final double lat;
  final double lon;
  final int chargeSpot;

  LocationData({
    required this.locId,
    required this.location,
    required this.lat,
    required this.lon,
    required this.chargeSpot,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      locId: json['loc_id'],
      location: json['Location'],
      lat: json['lat'],
      lon: json['lon'],
      chargeSpot: json['charge_spot'],
    );
  }
}