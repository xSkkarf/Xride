import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xride/constants/constants.dart';
import 'package:xride/data/live_data/live_data_model.dart';

part 'live_data_state.dart';


class LiveDataCubit extends Cubit<LiveDataState> {
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse("ws://${XConstants.baseUrl}/ws/car-status/"),
  );

  Set<Marker> carMarkers = {};

  LiveDataCubit() : super(LiveDataInitial()) {
    _listenToCarUpdates();
  }

  void _listenToCarUpdates() {
    _channel.stream.listen((event) {
      final List<dynamic> carsData = jsonDecode(event);
      List<LiveDataModel> cars = carsData.map((car) => LiveDataModel.fromJson(car)).toList();

      Set<Marker> newMarkers = cars.map((car) {
        return Marker(
          markerId: MarkerId(car.carId.toString()),
          position: LatLng(car.latitude, car.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: car.carId.toString(),
            snippet: "Speed: ${car.speed} km/h, Fuel: ${car.fuel}%",
          ),
        );
      }).toSet();

      emit(LiveDataLoaded(liveData: cars, carMarkers: newMarkers));
    });
  }

  @override
  Future<void> close() {
    _channel.sink.close();
    return super.close();
  }
}
