import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:xride/services/location_service.dart';
part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationService locationService;

  LocationCubit(this.locationService) : super(LocationLoading());

  void fetchInitialLocation() async {
    emit(LocationLoading());
    try {
      final locationData = await locationService.getInitialLocation();
      if (locationData == null) {
        emit(LocationError('Failed to get location data.'));
        return;
      }

      final currentLatLng =
          LatLng(locationData.latitude!, locationData.longitude!);
      print('Current location: $currentLatLng');

      // Initial location loading
      emit(LocationLoaded(
        locationData: locationData,
        initialPosition: CameraPosition(target: currentLatLng, zoom: 14),
        currentLocationMarker: Marker(
          markerId: const MarkerId('current_location'),
          position: currentLatLng,
        ),
      ));

    } catch (e) {
      print('Failed to get initial location: $e');
      emit(LocationError(e.toString()));
    }
  }

  void trackLocationUpdates() {
    try {
      final locationStream = locationService.getLocationStream();
      locationStream.listen((locationData) {
        final currentLatLng =
            LatLng(locationData.latitude!, locationData.longitude!);


        emit(LocationLoaded(
          locationData: locationData,
          initialPosition: CameraPosition(target: currentLatLng, zoom: 14),
          currentLocationMarker: Marker(
            markerId: const MarkerId('current_location'),
            position: currentLatLng,
          ),
        ));
      });
    } catch (e) {
      print('Failed to get location updates: $e');
      emit(LocationError(e.toString()));
    }
  }
}
