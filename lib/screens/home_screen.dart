import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xride/app_router.dart';
import 'package:xride/cubit/auth/auth_cubit.dart';
import 'package:xride/cubit/car/car_cubit.dart';
import 'package:xride/cubit/location/location_cubit.dart';
import 'package:xride/cubit/reservation/reservation_cubit.dart';
import 'package:xride/cubit/user/user_cubit.dart';
import 'package:xride/data/cars/car_model.dart';
import 'package:xride/data/user/user_model.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<LocationCubit>().fetchInitialLocation();
    context.read<UserCubit>().fetchUserInfo();
    context.read<ReservationCubit>().checkActiveReservation();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onTapCar(CarModel car) {
    Navigator.pushNamed(
      context,
      AppRouter.carDetailsScreen,
      arguments:
          ReservationArgs(car, latitude.toString(), longitude.toString(), clearCarMarkers),
    );
  }

  void clearCarMarkers() {
    setState(() {
      allMarkers = {};
    });
    context.read<UserCubit>().fetchUserInfo();
  }

  void updateCars() {
    if (context.read<ReservationCubit>().state is! ReservationSuccess) {
      context.read<CarCubit>().fetchCars(
          latitude.toString(), longitude.toString(), onTapCar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
              onPressed: () {
                updateCars();
                context.read<UserCubit>().fetchUserInfo();
                context.read<ReservationCubit>().checkActiveReservation();
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
          BlocListener<CarCubit, CarState>(
            listener: (context, state) {
              if (state is CarsError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.error),
                ));
              } else if (state is CarsLoaded) {
                setState(() {
                  allMarkers = state.carMarkers;
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
                          initialCameraPosition: state.initialPosition,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
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
                BlocBuilder<CarCubit, CarState>(
                  builder: (context, carState) {
                    if (carState is CarsLoaded) {
                      return Padding(
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
                              child: BlocBuilder<ReservationCubit,ReservationState>(
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
                                            ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  await context.read<ReservationCubit>().releaseCar(reservationState.response['car_id']);
                                                  updateCars(); // Refresh the car list
                                                  context.read<UserCubit>().fetchUserInfo(); // Refresh user balance
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
                                          ],
                                        ),
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
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.directions_car,
                                            color: Colors.blue,
                                          ),
                                          title: Text(car.carModel),
                                          subtitle:
                                              Text('\$${car.bookingPrice12H}'),
                                          onTap: () {
                                            onTapCar(car);
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  (state is UserFetchSuccess) ? state.user.username:
                  'User Info',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: Text(
                  (state is UserFetchSuccess)
                      ? 'Balance: \$${state.user.walletBalance}'
                      : 'loading',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.paymentScreen);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  showLogoutConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showLogoutConfirmationDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                parentContext.read<AuthCubit>().logout();
                Navigator.pushReplacementNamed(context, AppRouter.loginScreen);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
