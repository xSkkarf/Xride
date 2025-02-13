
class LiveDataModel {
  final int carId;
  final double speed;
  final int fuel;
  final double latitude;
  final double longitude;
  final String engine;
  final String doors;
  final String lastUpdated;

  LiveDataModel({
    required this.carId,
    required this.speed,
    required this.fuel,
    required this.latitude,
    required this.longitude,
    required this.engine,
    required this.doors,
    required this.lastUpdated,
  });

  factory LiveDataModel.fromJson(Map<String, dynamic> json) {
    return LiveDataModel(
      carId: json['car_id'] ?? 0,
      speed: json['speed'] ?? 0,
      fuel: json['fuel'] ?? 0,
      latitude: json['Latitude'] ?? 0.0,
      longitude: json['Longitude'] ?? 0.0,
      engine: json['Engine'] ?? '',
      doors: json['Doors'] ?? '',
      lastUpdated: json['Last Updated:'] ?? '',
    );
  }
}