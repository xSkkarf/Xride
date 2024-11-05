part of 'car_cubit.dart';

@immutable
sealed class CarState {}

final class CarInitial extends CarState {}

class CarsLoading extends CarState {}

class CarsLoaded extends CarState {
  final Set<Marker> carMarkers;
  final List<CarModel> cars;
  CarsLoaded({required this.carMarkers, required this.cars});
}

class CarsError extends CarState {
  final String error;
  CarsError(this.error);
}