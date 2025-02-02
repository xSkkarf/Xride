import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xride/cubit/live_data/live_data_cubit.dart';
import 'package:xride/cubit/location/location_cubit.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  GoogleMapController? mapController;
  Set<Marker> carMarkers = {};
  Marker? userMarker; // User's live location
  LatLng? userLocation; // Store user position

  @override
  void initState() {
    super.initState();
    context.read<LiveDataCubit>(); // Start listening to WebSocket for cars
    context.read<LocationCubit>().fetchInitialLocation(); // Get initial user location
    context.read<LocationCubit>().trackLocationUpdates(); // Start live user tracking
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Live Car Tracking'),
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen for Live Car Data Updates
          BlocListener<LiveDataCubit, LiveDataState>(
            listener: (context, state) {
              if (state is LiveDataLoaded) {
                setState(() {
                  carMarkers = state.carMarkers;
                });
              }
            },
          ),
          // Listen for User Location Updates
          BlocListener<LocationCubit, LocationState>(
            listener: (context, state) {
              if (state is LocationLoaded) {
                setState(() {
                  userLocation = LatLng(
                    state.locationData.latitude!,
                    state.locationData.longitude!,
                  );
                  userMarker = state.currentLocationMarker;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<LocationCubit, LocationState>(
          builder: (context, locationState) {
            if (locationState is LocationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (locationState is LocationLoaded) {
              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: userLocation ?? const LatLng(25.276987, 55.296249),
                  zoom: 14,
                ),
                markers: {
                  if (userMarker != null) userMarker!,
                  ...carMarkers, // Merge car and user markers
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            } else {
              return const Center(child: Text("Failed to fetch user location"));
            }
          },
        ),
      ),
    );
  }
}
