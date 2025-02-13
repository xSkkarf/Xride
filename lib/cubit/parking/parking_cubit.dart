import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:xride/data/parkings/parking_model.dart';
import 'package:xride/services/parking_service.dart';

part 'parking_state.dart';

class ParkingCubit extends Cubit<ParkingState> {
  final ParkingService parkingService;
  ParkingCubit(this.parkingService) : super(ParkingInitial());

  void fetchParkings() async {
    emit(ParkingLoading());
    try {
      final parkings = await parkingService.getParkings();
      emit(ParkingLoaded(parkings));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  // Sort parkings by distance and return a map of parking and distance
  Map<ParkingModel, double> sortParkingsByDistance(List<ParkingModel> parkings, double latitude, double longitude) {
    final Map<ParkingModel, double> sortedParkings = {};
    for (var parking in parkings) {
      final distance = Geolocator.distanceBetween(latitude, longitude, parking.latitude, parking.longitude);
      sortedParkings[parking] = distance;
    }
    return Map.fromEntries(sortedParkings.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)));
  }
}
