import 'package:xride/data/cars/car_model.dart';
import 'package:xride/data/cars/car_repo.dart';

class CarService {
  final CarRepo carRepo = CarRepo();

  Future<List<CarModel>> fetchCars(String latitude, String longitude) async {
    return await carRepo.fetchCars(latitude, longitude);
  }
}
