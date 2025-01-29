part of 'parking_cubit.dart';

@immutable
abstract class ParkingState {}

class ParkingInitial extends ParkingState {}

class ParkingLoading extends ParkingState {}

class ParkingLoaded extends ParkingState {
  final List<ParkingModel> parkings;
  ParkingLoaded(this.parkings);
}

class ParkingError extends ParkingState {
  final String error;
  ParkingError(this.error);
}