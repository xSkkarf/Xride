import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';
import 'package:xride/data/cars/car_model.dart';
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
        carMarkers: {},
      ));

      // Fetch cars after loading the initial location
      await fetchCars(
          locationData.latitude.toString(), locationData.longitude.toString());
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

        // Check if the current state is LocationLoaded to retain existing car markers
        Set<Marker> carMarkers = {};
        if (state is LocationLoaded) {
          carMarkers = (state as LocationLoaded).carMarkers;
        }

        emit(LocationLoaded(
          locationData: locationData,
          initialPosition: CameraPosition(target: currentLatLng, zoom: 14),
          currentLocationMarker: Marker(
            markerId: const MarkerId('current_location'),
            position: currentLatLng,
          ),
          carMarkers: carMarkers, // Preserve car markers
        ));
      });
    } catch (e) {
      print('Failed to get location updates: $e');
      emit(LocationError(e.toString()));
    }
  }

  Future<void> fetchCars(String latitude, String longitude) async {
    try {
      final List<CarModel> cars =
          await homeService.fetchCars(latitude, longitude);

      final BitmapDescriptor customMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(40, 40)), // Size of the icon (can be adjusted)
        'assets/car.png', // Path to the asset in pubspec.yaml
      );

      final Set<Marker> carMarkers = cars.map((car) {
        return Marker(
          markerId: MarkerId(car.id.toString()),
          position: LatLng(car.latitude, car.longitude),
          infoWindow: InfoWindow(title: car.carName),
          icon: customMarker,
        );
      }).toSet();

      if (state is LocationLoaded) {
        // Update the existing LocationLoaded state with the car markers
        final locationLoadedState = state as LocationLoaded;
        emit(LocationLoaded(
          locationData: locationLoadedState.locationData,
          initialPosition: locationLoadedState.initialPosition,
          currentLocationMarker: locationLoadedState.currentLocationMarker,
          carMarkers: carMarkers,
        ));
      }
    } catch (e) {
      print('Failed to fetch cars: $e');
      emit(LocationError(e.toString()));
    }
  }
}
