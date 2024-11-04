part of 'home_cubit.dart';

@immutable
sealed class HomeState {}


class LocationLoading extends HomeState {}

class LocationLoaded extends HomeState {
  final LocationData locationData;
  final CameraPosition initialPosition;
  final Marker currentLocationMarker;

  LocationLoaded({
    required this.locationData,
    required this.initialPosition,
    required this.currentLocationMarker,
  });
}

class LocationError extends HomeState {
  final String error;
  LocationError(this.error);
}