import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xride/cubit/user/user_cubit.dart';
import 'package:xride/data/cars/car_model.dart';

class CarDetailsScreen extends StatefulWidget {
  final CarModel car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  String? selectedPriceOption; // Holds the selected price option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car.carName),
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
                      widget.car.carName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Year: ${widget.car.year}, Plate: ${widget.car.carPlate}',
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
                              widget.car.doorStatus,
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
                                Text('${widget.car.temperature}°C'),
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
                      widget.car.reservationStatus,
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
                    target: LatLng(widget.car.latitude, widget.car.longitude),
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId(widget.car.id.toString()),
                      position:
                          LatLng(widget.car.latitude, widget.car.longitude),
                      infoWindow: InfoWindow(title: widget.car.carName),
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
              child: Padding(
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
                    buildPriceOption('2 Hours', widget.car.bookingPrice2H),
                    buildPriceOption('6 Hours', widget.car.bookingPrice6H),
                    buildPriceOption('12 Hours', widget.car.bookingPrice12H),
                    const SizedBox(height: 20),
                    // Reserve Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BlocBuilder<UserCubit, UserState>(
                          builder: (context, state){
                            // Show the user balance
                            return Text('Balance: \$${(state as UserFetchSuccess).user.walletBalance}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            );
                            
                          }

                        ),
                        ElevatedButton(
                          onPressed: selectedPriceOption != null
                              ? () {
                                  // Handle reservation logic here
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Reserved for $selectedPriceOption'),
                                    ),
                                  );
                                }
                              : null,
                          child: const Text('Reserve',
                              style: TextStyle(fontSize: 15)),
                        ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a selectable price option
  Widget buildPriceOption(String title, String price) {
    return RadioListTile<String>(
      value: title,
      groupValue: selectedPriceOption,
      onChanged: (value) {
        setState(() {
          selectedPriceOption = value;
        });
      },
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: Text('\$$price',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      activeColor: Colors.blue,
    );
  }
}