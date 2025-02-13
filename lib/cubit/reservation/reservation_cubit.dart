import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:xride/data/cars/car_model.dart';
import 'package:xride/data/parkings/parking_model.dart';
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
  dynamic _reservationResponse;
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
      _reservationResponse = response;
      emit(ReservationSuccess(response));
      return true;
  }

  void checkActiveReservation() async {
    emit(ReservationLoading());
    try {
      final response = await reservationService.checkActiveReservation();
      if(response['status'] == 'active'){
        _reservationResponse = response;
        emit(ReservationSuccess(response));
      } else {
        emit(ReservationInitial());
      }
    } catch(e){
      emit(ReservationError(e.toString()));
    }
  }

  Future<Map<ParkingModel, double>> beginRelease(int carId, Function onConfirm) async{
    emit(ReservationLoading());
    final sortedParkings = await onConfirm();
    emit(ReservationCancelling(carId));
    return sortedParkings;
  }

  Future<void> releaseCar(int carId, int parkinId, double latitude, double longitude) async {
    try {
      await reservationService.releaseCar(carId, parkinId, latitude, longitude);
      emit(ReservationCancellingSuccess());
      emit(ReservationInitial());
    } catch(e){
      throw Exception(e.toString()); 
    }
  }

  void cancelRelease() {
    emit(ReservationSuccess(_reservationResponse));
  }

  void toggleLockCar(int carId) async {
    try {
      await reservationService.toggleLockCar(carId);
    } catch(e){
      rethrow;
    }
  }

  
}
