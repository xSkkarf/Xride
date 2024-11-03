class CarModel {
  final int id;
  final String carName;
  final String carPlate;
  final int year;
  final String doorStatus;
  final double temperature;
  final double latitude;
  final double longitude;
  final String reservationStatus;
  final String bookingPrice2H;
  final String bookingPrice6H;
  final String bookingPrice12H;

  CarModel({
    required this.id,
    required this.carName,
    required this.carPlate,
    required this.year,
    required this.doorStatus,
    required this.temperature,
    required this.latitude,
    required this.longitude,
    required this.reservationStatus,
    required this.bookingPrice2H,
    required this.bookingPrice6H,
    required this.bookingPrice12H,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as int,
      carName: json['car_name'] ?? '',
      carPlate: json['car_plate'] ?? '',
      year: json['year'] as int,
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
      'car_name': carName,
      'car_plate': carPlate,
      'year': year,
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