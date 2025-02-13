import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xride/constants/constants.dart';
import 'package:xride/data/live_data/live_data_model.dart';

part 'live_data_state.dart';


class LiveDataCubit extends Cubit<LiveDataState> {
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse("wss://${XConstants.hostName}/ws/car-status/"),
  );

  Set<Marker> carMarkers = {};

  LiveDataCubit() : super(LiveDataInitial()) {
    _listenToCarUpdates();
  }

  void _listenToCarUpdates() {
    _channel.stream.listen((event) {
      if (event != null && event.isNotEmpty) { // Prevent decoding null/empty data
        try {
          final dynamic data = jsonDecode(event);
          
          if (data is! Map<String, dynamic>) {
            print("Invalid data format received: $data");
            return; // Exit if data is not a map
          }

          if (!data.containsKey('car_data')) {
            print("Missing 'car_data' key: $data");
            return; // Exit if key is missing
          }

          LiveDataModel car = LiveDataModel.fromJson(data['car_data']);

          print('######## lat: ${car.latitude}, longitude: ${car.longitude}');

          Set<Marker> newMarkers = {
            Marker(
              markerId: MarkerId(car.carId.toString()),
              position: LatLng(car.latitude, car.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(
                title: car.carId.toString(),
                snippet: "Speed: ${car.speed} km/h, Fuel: ${car.fuel}%",
              ),
            ),
          };

          emit(LiveDataLoaded(liveData: car, carMarkers: newMarkers));
        } catch (e) {
          print("JSON Parsing Error: $e"); // Debugging
        }
      } else {
        print("Received empty WebSocket event");
      }
    });
  }


  @override
  Future<void> close() {
    _channel.sink.close();
    return super.close();
  }
}
