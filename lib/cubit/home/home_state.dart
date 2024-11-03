part of 'home_cubit.dart';

@immutable
sealed class HomeState {}


class LocationLoading extends HomeState {}

class LocationLoaded extends HomeState {
  final LocationData locationData;
  final CameraPosition initialPosition;
  final Marker currentLocationMarker;
  final Set<Marker> carMarkers;

  LocationLoaded({
    required this.locationData,
    required this.initialPosition,
    required this.currentLocationMarker,
    required this.carMarkers,
  });
}

class LocationError extends HomeState {
  final String error;
  LocationError(this.error);
}

class CarsLoading extends HomeState {}

class CarsLoaded extends HomeState {
  final Set<Marker> carMarkers;
  CarsLoaded(this.carMarkers);
}

class CarsError extends HomeState {
  final String error;
  CarsError(this.error);
}