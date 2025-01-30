import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:xride/constants/constants.dart';
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

  Future<List<LatLng>> getRoutePoints(double startLat, double startLon, double endLat, double endLon) async {
    final String apiKey = XConstants.googleMapsApiKey; // Replace with your API Key
    
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: apiKey,
        request: PolylineRequest(
          origin: PointLatLng(startLat, startLon),
          destination: PointLatLng(endLat, endLon),
          mode: TravelMode.driving,
          ), 
    );
    if (result.points.isNotEmpty) {
      List<LatLng> routePoints = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      return routePoints;
    } else {
      return [];
    }
  }

  

}
