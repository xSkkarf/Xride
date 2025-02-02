import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xride/app_router.dart';
import 'package:xride/cubit/auth/auth_cubit.dart';
import 'package:xride/cubit/car/car_cubit.dart';
import 'package:xride/cubit/location/location_cubit.dart';
import 'package:xride/cubit/parking/parking_cubit.dart';
import 'package:xride/cubit/reservation/reservation_cubit.dart';
import 'package:xride/cubit/user/user_cubit.dart';
import 'package:xride/data/cars/car_model.dart';
import 'package:xride/data/parkings/parking_model.dart';
import 'package:xride/data/user/user_model.dart';
import 'package:xride/my_widgets/user_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? user;
  GoogleMapController? mapController;
  double latitude = 0.0;
  double longitude = 0.0;
  Set<Marker> allMarkers = {};
  Set<Marker> parkMarkers = {};
  Set<Circle> allCircles = {};
  Set<Polyline> allPolylines = {};
  int lastSelectedMarkerId = -1;
  
  Map<ParkingModel, double> sortedParkings = {};
  bool parkMarkersToggle = true;

  @override
  void initState() {
    super.initState();
    context.read<LocationCubit>().fetchInitialLocation();
    context.read<UserCubit>().fetchUserInfo();
    context.read<ReservationCubit>().checkActiveReservation();
    context.read<ParkingCubit>().fetchParkings(latitude, longitude);
  }

  void toggleMarkers() {
    setState(() {
      parkMarkersToggle = !parkMarkersToggle;
      parkMarkersToggle ? allMarkers.addAll(parkMarkers) : allMarkers.removeAll(parkMarkers);
    });
  }

  Future<void> drawRouteToParking(double destLatitude, double destLongitude) async {
    try {
      // Fetch current location from LocationCubit
      final locationState = context.read<LocationCubit>().state;
      if (locationState is! LocationLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch current location")),
        );
        return;
      }

      final double userLat = locationState.locationData.latitude!;
      final double userLon = locationState.locationData.longitude!;

      // Fetch directions from Google Maps API
      final List<LatLng> routePoints = await context.read<LocationCubit>().getRoutePoints(userLat, userLon, destLatitude, destLongitude);

      setState(() {
        allPolylines.clear(); // Remove existing routes
        allPolylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: routePoints,
            geodesic: true,
          ),
        );

      });
    } catch (e) {
      print("Error drawing route: $e");
    }
  }


  void updateParkingMarkers(List<ParkingModel> parkings) {
    setState(() {
      allCircles.addAll(
        parkings.map(
          (parking) => Circle(
            circleId: CircleId('parking_${parking.id}'),
            center: LatLng(parking.latitude, parking.longitude),
            radius: parking.radius*1000,
            fillColor: Colors.green.withOpacity(0.3),
            strokeWidth: 2,
            strokeColor: Colors.green.withOpacity(0.5),
          ),
        ),
      );
      parkMarkers.addAll(
        parkings.map(
          (parking) => Marker(
            markerId: MarkerId('parking_${parking.id}'),
            position: LatLng(parking.latitude, parking.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: parking.parkName,
              onTap: () async {
                if (lastSelectedMarkerId == parking.id) {
                  setState(() {
                    allPolylines.clear();
                    lastSelectedMarkerId = -1;
                  });
                  return;
                }
                await drawRouteToParking(parking.latitude, parking.longitude);
                lastSelectedMarkerId = parking.id;
              },
            ),
            zIndex: 5,
          ),
        ),
      );

      allMarkers.addAll(parkMarkers);

    });
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onTapCar(CarModel car) {
    Navigator.pushNamed(
      context,
      AppRouter.carDetailsScreen,
      arguments:
          ReservationArgs(car, latitude.toString(), longitude.toString()),
    );
  }

  void updateCars() {
    if (context.read<ReservationCubit>().state is! ReservationSuccess) {
      context.read<CarCubit>().fetchCars(
          latitude.toString(), longitude.toString(), onTapCar);
    }
  }

  Future<Map<ParkingModel, double>> releaseCar(int carId) async{
    final sortedParkings = context.read<ReservationCubit>().beginRelease(carId, () async {
      final parkings = ( context.read<ParkingCubit>().state as ParkingLoaded).parkings;
      final sortedParkings = context.read<ParkingCubit>().sortParkingsByDistance(parkings, latitude, longitude);
      return sortedParkings;
     }
    );
    return sortedParkings;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Xride'),
        actions: [
          IconButton(
            onPressed: toggleMarkers,
            icon: Icon(!parkMarkersToggle ? Icons.location_off: Icons.location_on),
            color: (!parkMarkersToggle ? Colors.black : Colors.green),
          ),
          IconButton(
              onPressed: () {
                updateCars();
                context.read<UserCubit>().fetchUserInfo();
                context.read<ReservationCubit>().checkActiveReservation();
                context.read<ParkingCubit>().fetchParkings(latitude, longitude);
              },
              icon: const Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.attach_money),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.paymentScreen);
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 232, 233, 235),
      drawer: const UserDrawer(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is UserLoggedOut) {
                Navigator.pushReplacementNamed(context, AppRouter.loginScreen);
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                ));
              }
            },
          ),
          BlocListener<UserCubit, UserState>(
            listener: (context, state) {
              if (state is UserFetchFail) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                ));
              } else if (state is UserFetchSuccess) {
                setState(() {
                  user = state.user;
                });
              }
            },
          ),
          BlocListener<ParkingCubit, ParkingState>(
            listener: (context, state) {
              if (state is ParkingError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                ));
              } else if (state is ParkingLoaded) {
                updateParkingMarkers(state.parkings);
              }
            },
          ),
          BlocListener<CarCubit, CarState>(
            listener: (context, state) {
              if (state is CarsError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                ));
              } else if (state is CarsLoaded) {
                setState(() {
                  allMarkers.addAll(state.carMarkers);
                });
              }
            },
          ),
          BlocListener<LocationCubit, LocationState>(
            listener: (context, state) {
              if (state is LocationError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                ));
              } else if (state is LocationLoaded) {
                context.read<CarCubit>().fetchCars(
                    state.locationData.latitude.toString(),
                    state.locationData.longitude.toString(),
                    onTapCar);
              }
            },
          ),
        ],
        child: BlocBuilder<ReservationCubit, ReservationState>(
          builder: (context, state) {
            return Stack(
              children: [
                BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    if (state is LocationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is LocationLoaded) {
                      latitude = state.locationData.latitude!;
                      longitude = state.locationData.longitude!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 75.0),
                        child: GoogleMap(
                          onMapCreated: onMapCreated,
                          markers: allMarkers,
                          circles: allCircles,
                          initialCameraPosition: state.initialPosition,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          polylines: allPolylines,
                        ),
                      );
                    } else if (state is LocationError) {
                      return Center(
                        child: Text('Error: //${state.error}'),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.1, // Default height of the sheet
                    minChildSize: 0.1, // Minimum height (collapsed)
                    maxChildSize: 0.45, // Maximum height (expanded)
                    builder: (context, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                        child: BlocBuilder<CarCubit, CarState>(
                          builder: (context, carState) {
                            if (carState is CarsError) {
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  carState.error,
                                  textAlign: TextAlign.center,
                                )
                              );
                            } else if (carState is CarsLoaded) {
                                return BlocListener<ReservationCubit, ReservationState>(
                                  listener: (context, reservationState) {
                                    if (reservationState is ReservationCancellingSuccess) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Car released successfully'),
                                        ),
                                      );
                                      context.read<ReservationCubit>().checkActiveReservation();
                                      context.read<ParkingCubit>().fetchParkings(latitude, longitude);
                                      updateCars();
                                      context.read<UserCubit>().fetchUserInfo();
                                    }
                                  },
                                  child: 
                                  BlocBuilder<ReservationCubit,ReservationState>(
                                    builder: (context, reservationState) {
                                      if (reservationState is ReservationSuccess) {
                                        // Display active reservation details
                                        return SingleChildScrollView(
                                          controller: scrollController,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Active Reservation',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineMedium,
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  'Car: ${reservationState.response['car_model']}',
                                                  style:
                                                      const TextStyle(fontSize: 16),
                                                ),
                                                Text(
                                                  'Reservation Plan: ${reservationState.response['reservation_plan']}',
                                                  style:
                                                      const TextStyle(fontSize: 16),
                                                ),
                                                Text(
                                                  'Start Time: ${reservationState.response['start_time']}',
                                                  style:
                                                      const TextStyle(fontSize: 16),
                                                ),
                                                Text(
                                                  'End Time: ${reservationState.response['end_time']}',
                                                  style:
                                                      const TextStyle(fontSize: 16),
                                                ),
                                                const SizedBox(height: 20),
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        try {
                                                          sortedParkings = await releaseCar(reservationState.response['car_id']);
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(e.toString().replaceAll('Exception:', '').trim()), // Remove "Exception:" from message
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: const Text('Release the car'),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      else if (reservationState is ReservationCancelling){
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListView.builder(
                                              controller: scrollController,
                                              itemCount: sortedParkings.length+1,
                                              itemBuilder: (context, index) {
                                                if (index == 0){
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        context.read<ReservationCubit>().cancelRelease();
                                                      },
                                                      child: const Text('Back'),
                                                    ),
                                                  );
                                                }
                                                final parking = sortedParkings.keys.elementAt(index-1);
                                                return Material(
                                                  color: Colors.white,
                                                  child: InkWell(
                                                    onTap: () async {
                                                        try {
                                                          await context.read<ReservationCubit>().releaseCar(reservationState.carId, parking.id, latitude, longitude);
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(e.toString().replaceAll('Exception:', '').trim()), // Remove "Exception:" from message
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    child: ListTile(
                                                      title: Text(parking.parkName),
                                                      subtitle: Text('Distance: ${(sortedParkings[parking]!/1000).toStringAsFixed(2)} km'),
                                                      trailing: IconButton(onPressed: () {
                                                          mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(parking.latitude, parking.longitude)));
                                                        },
                                                        icon: const Icon(Icons.directions),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                        );
                                      }
                                      else if (reservationState is ReservationLoading) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      else {
                                        // Display list of available cars
                                        return ListView.builder(
                                          controller:
                                              scrollController, // Enables scrolling in sheet
                                          itemCount: carState.cars.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index == 0) {
                                              return Container(
                                                margin: const EdgeInsets.fromLTRB(
                                                    100, 10, 100, 10),
                                                height: 5,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey,
                                                ),
                                              );
                                            }
                                            final car = carState.cars[index - 1];
                                            return Material(
                                              color: Colors.white,
                                              child: InkWell(
                                                onTap: () {
                                                    onTapCar(car);
                                                  },
                                                child: ListTile(
                                                  leading: const Icon(
                                                    Icons.directions_car,
                                                    color: Colors.blue,
                                                  ),
                                                  title: Text(car.carModel),
                                                  subtitle:
                                                      Text('\$${car.bookingPrice12H}'),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                );
                              }else {
                                return const SizedBox.shrink();
                              } 
                          }
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

