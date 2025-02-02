import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xride/cubit/live_data/live_data_cubit.dart';
import 'package:xride/cubit/location/location_cubit.dart';
import 'package:xride/cubit/user/user_cubit.dart';
import 'package:xride/my_widgets/user_drawer.dart';
import 'package:xride/screens/admin_web_view_screen.dart';

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
  int selectedIndex = 0; // Track selected tab

  @override
  void initState() {
    super.initState();
    context.read<LocationCubit>().fetchInitialLocation(); // Get initial user location
    context.read<UserCubit>().fetchUserInfo(); // Fetch user data
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Widget adminHomeScreen() {
    return MultiBlocListener(
        listeners: [
          // Listen for Live Car Data Updates
          BlocListener<LiveDataCubit, LiveDataState>(
            listener: (context, state) {
              if (state is LiveDataLoaded) {
                setState(() {
                  carMarkers = state.carMarkers;
                  print("Car Markers: $carMarkers");
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
                markers: carMarkers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              );
            } else {
              return const Center(child: Text("Failed to fetch user location"));
            }
          },
        ),
      );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index; // Change the screen
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Live Tracking'),
      ),
      drawer: const UserDrawer(),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          // Live Tracking Map
          MultiBlocListener(
            listeners: [
              BlocListener<LiveDataCubit, LiveDataState>(
                listener: (context, state) {
                  if (state is LiveDataLoaded) {
                    setState(() {
                      carMarkers = state.carMarkers;
                    });
                  }
                },
              ),
              BlocListener<LocationCubit, LocationState>(
                listener: (context, state) {
                  if (state is LocationLoaded) {
                    setState(() {
                      userLocation = LatLng(
                        state.locationData.latitude!,
                        state.locationData.longitude!,
                      );
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
                    markers: carMarkers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  );
                } else {
                  return const Center(child: Text("Failed to fetch user location"));
                }
              },
            ),
          ),

          // Django Admin Panel (WebView)
          const AdminWebViewScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Live Tracking"),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: "Admin Panel"),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
