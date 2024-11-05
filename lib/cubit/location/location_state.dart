part of 'location_cubit.dart';

@immutable
sealed class LocationState {}


class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final LocationData locationData;
  final CameraPosition initialPosition;
  final Marker currentLocationMarker;

  LocationLoaded({
    required this.locationData,
    required this.initialPosition,
    required this.currentLocationMarker,
  });
}

class LocationError extends LocationState {
  final String error;
  LocationError(this.error);
}