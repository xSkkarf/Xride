import 'package:location/location.dart';
import 'package:xride/data/cars/car_model.dart';
import 'package:xride/data/cars/car_repo.dart';

class HomeService {
  final Location location = Location();
  final CarRepo carRepo = CarRepo();

  Future<LocationData?> getInitialLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location service not enabled');
      }
    }

    // Check for location permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }
    }

    // Get the initial location
    return await location.getLocation();
  }

  Stream<LocationData> getLocationStream() {
    return location.onLocationChanged;
  }

  Future<List<CarModel>> fetchCars(String latitude, String longitude) async {
    return await carRepo.fetchCars(latitude, longitude);
  }
}
