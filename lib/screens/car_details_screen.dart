import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xride/cubit/reservation/reservation_cubit.dart';
import 'package:xride/cubit/user/user_cubit.dart';

class CarDetailsScreen extends StatefulWidget {
  final ReservationArgs reservationArgs;

  const CarDetailsScreen({super.key, required this.reservationArgs});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  String? selectedPriceOption;
  Map<String, String> plans = {
    '2 Hours': '2H',
    '6 Hours': '6H',
    '12 Hours': '12H',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservationArgs.car.carModel),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Information Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              shadowColor: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Car Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.reservationArgs.car.carModel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Plate: ${widget.reservationArgs.car.carPlate}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Door Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.reservationArgs.car.doorStatus,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Temperature',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.thermostat,
                                    size: 16, color: Colors.grey[700]),
                                const SizedBox(width: 4),
                                Text(
                                    '${widget.reservationArgs.car.temperature}°C'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Reservation Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.reservationArgs.car.reservationStatus,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Location Section with Map
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.15), // Adjust opacity for softer shadow
                    spreadRadius: 1, // The spread of the shadow
                    blurRadius: 4, // The blur radius of the shadow
                    offset: const Offset(
                        0, 2), // Offset to give it a slight downward shadow
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.reservationArgs.car.latitude,
                        widget.reservationArgs.car.longitude),
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: {
                    Marker(
                      markerId:
                          MarkerId(widget.reservationArgs.car.id.toString()),
                      position: LatLng(widget.reservationArgs.car.latitude,
                          widget.reservationArgs.car.longitude),
                      infoWindow: InfoWindow(
                          title: widget.reservationArgs.car.carModel),
                    ),
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Booking Prices Card with selectable options
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              shadowColor: Colors.black,
              child: BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                    double walletBalance = 0.0;
                    if (state is UserFetchSuccess) {
                      walletBalance = state.user.walletBalance;
                    }
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Booking Duration',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildPriceOption(
                            '2 Hours',
                            widget.reservationArgs.car.bookingPrice2H,
                            walletBalance),
                        buildPriceOption(
                            '6 Hours',
                            widget.reservationArgs.car.bookingPrice6H,
                            walletBalance),
                        buildPriceOption(
                            '12 Hours',
                            widget.reservationArgs.car.bookingPrice12H,
                            walletBalance),
                        const SizedBox(height: 20),
                        // Reserve Button
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Balance: \$$walletBalance',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              BlocListener<ReservationCubit, ReservationState>(
                                listener: (context, state) {
                                  if (state is ReservationError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.message),
                                      ),
                                    );
                                  }
                                },
                                child: BlocBuilder<ReservationCubit,
                                    ReservationState>(
                                  builder: (context, state) {
                                    if (state is ReservationLoading) {
                                      return const CircularProgressIndicator();
                                    } else {
                                      return ElevatedButton(
                                        onPressed: selectedPriceOption != null ? () async {
                                            final result = await context.read<ReservationCubit>().reserve(
                                              widget.reservationArgs.car.id,
                                              plans[selectedPriceOption!]!,
                                              widget.reservationArgs.latitude,
                                              widget.reservationArgs.longitude,
                                            );
                                            if (result) {Navigator.of(context).pop();};
                                          }: null,
                                        child: const Text('Reserve',
                                            style: TextStyle(fontSize: 15)),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ]),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a selectable price option
  Widget buildPriceOption(String title, String price, double walletBalance) {
    return RadioListTile<String>(
      value: title,
      groupValue: selectedPriceOption,
      onChanged: (value) {
        if (walletBalance >= double.parse(price)) {
          setState(() {
            selectedPriceOption = value;
          });
        } else {
          const snackBar = SnackBar(
            content: Text('Insufficient balance'),
            duration: Duration(seconds: 1),
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      title: Text(title,
          style: TextStyle(
              fontSize: 16,
              color: (walletBalance >= double.parse(price))
                  ? Colors.black
                  : Colors.grey)),
      subtitle: Text(
        '\$$price',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: (walletBalance >= double.parse(price))
              ? Colors.black87
              : Colors.grey,
        ),
      ),
      activeColor: Colors.blue,
      controlAffinity: ListTileControlAffinity.trailing,
      toggleable: true,
    );
  }
}
