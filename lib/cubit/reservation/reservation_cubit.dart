import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:xride/data/cars/car_model.dart';
import 'package:xride/services/reservation_service.dart';

part 'reservation_state.dart';

class ReservationArgs{
  final CarModel car;
  final String latitude;
  final String longitude;

  ReservationArgs(this.car, this.latitude, this.longitude);
}

class ReservationCubit extends Cubit<ReservationState> {
  ReservationService reservationService;
  ReservationCubit(this.reservationService) : super(ReservationInitial());


  Future<bool> reserve(int carId, String plan, String latitude, String longitude) async {
    emit(ReservationLoading());
    final dynamic response;
    try {
      response = await reservationService.reserveCar(carId, plan, latitude, longitude);
    } catch(e){
      emit(ReservationError(e.toString()));
      return false;
    }
      emit(ReservationSuccess(response));
      return true;
  }

  void checkActiveReservation() async {
    emit(ReservationLoading());
    try {
      final response = await reservationService.checkActiveReservation();
      if(response['status'] == 'active'){
        emit(ReservationSuccess(response));
      } else {
        emit(ReservationInitial());
      }
    } catch(e){
      emit(ReservationError(e.toString()));
    }
  }
}
