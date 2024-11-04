import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xride/data/cars/car_model.dart';
import 'package:xride/services/car_service.dart';

part 'car_state.dart';

class CarCubit extends Cubit<CarState> {
  final CarService carService;
  CarCubit(this.carService) : super(CarInitial());

  Future<void> fetchCars(String latitude, String longitude) async {
    try {
      final List<CarModel> cars =
          await carService.fetchCars(latitude, longitude);

      final BitmapDescriptor customMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(
            size: Size(40, 40)),
        'assets/car.png',
      );

      final Set<Marker> carMarkers = cars.map((car) {
        return Marker(
          markerId: MarkerId(car.id.toString()),
          position: LatLng(car.latitude, car.longitude),
          infoWindow: InfoWindow(title: car.carName),
          icon: customMarker,
        );
      }).toSet();

      emit(CarsLoaded(
        carMarkers: carMarkers,
      ));
      
    } catch (e) {
      print('Failed to fetch cars: $e');
      emit(CarsError(e.toString()));
    }
  }
}
