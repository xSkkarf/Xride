class ParkingModel {
  final int id;
  final String parkName;
  final double radius;
  final double latitude;
  final double longitude;

  ParkingModel({
    required this.id,
    required this.parkName,
    required this.radius,
    required this.latitude,
    required this.longitude,
  });

  factory ParkingModel.fromJson(Map<String, dynamic> json) {
    return ParkingModel(
      id: json['id'],
      parkName: json['park_name'],
      radius: json['radius'] ?? 0.0,
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }
}
