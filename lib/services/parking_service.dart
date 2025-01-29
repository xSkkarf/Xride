
import 'package:xride/data/parkings/parking_model.dart';
import 'package:xride/data/parkings/parking_repo.dart';

class ParkingService {
  final ParkingRepo parkingRepo = ParkingRepo();

  Future<List<ParkingModel>> getParkings() async {
    final List<ParkingModel> parkings = await parkingRepo.getParkings(); 

    return parkings;
  }
  
  
}