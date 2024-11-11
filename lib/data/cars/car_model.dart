class CarModel {
  final int id;
  final String carModel;
  final String carPlate;
  final String doorStatus;
  final double temperature;
  final double latitude;
  final double longitude;
  final String reservationStatus;
  final String bookingPrice2H;
  final String bookingPrice6H;
  final String bookingPrice12H;
  final String region;

  CarModel({
    required this.id,
    required this.carModel,
    required this.carPlate,
    required this.doorStatus,
    required this.temperature,
    required this.latitude,
    required this.longitude,
    required this.reservationStatus,
    required this.bookingPrice2H,
    required this.bookingPrice6H,
    required this.bookingPrice12H,
    required this.region
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as int,
      region: json['location'] ?? '',
      carModel: json['car_model'] ?? '',
      carPlate: json['car_plate'] ?? '',
      doorStatus: json['door_status'] ?? '',
      temperature: json['temperature'] ?? 0.0,
      latitude: json['location_latitude'] ?? 0.0,
      longitude: json['location_longitude'] ?? 0.0,
      reservationStatus: json['reservation_status'] ?? '',
      bookingPrice2H: json['booking_price_2H'] ?? '',
      bookingPrice6H: json['booking_price_6H'] ?? '',
      bookingPrice12H: json['booking_price_12H'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_name': carModel,
      'car_plate': carPlate,
      'door_status': doorStatus,
      'temperature': temperature,
      'location_latitude': latitude,
      'location_longitude': longitude,
      'reservation_status': reservationStatus,
      'booking_price_2H': bookingPrice2H,
      'booking_price_6H': bookingPrice6H,
      'booking_price_12H': bookingPrice12H,
    };
  }
}