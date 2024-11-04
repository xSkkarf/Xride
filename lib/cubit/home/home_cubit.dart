import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:xride/services/home_service.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService homeService;

  HomeCubit(this.homeService) : super(LocationLoading());

  void fetchInitialLocation() async {
    emit(LocationLoading());
    try {
      final locationData = await homeService.getInitialLocation();
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
      final locationStream = homeService.getLocationStream();
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
