import 'package:bloc/bloc.dart';
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
}
