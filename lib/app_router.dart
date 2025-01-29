import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xride/cubit/car/car_cubit.dart';
import 'package:xride/cubit/location/location_cubit.dart';
import 'package:xride/cubit/parking/parking_cubit.dart';
import 'package:xride/cubit/payment/payment_cubit.dart';
import 'package:xride/cubit/reservation/reservation_cubit.dart';
import 'package:xride/screens/car_details_screen.dart';
import 'package:xride/screens/home_screen.dart';
import 'package:xride/screens/login_screen.dart';
import 'package:xride/screens/payment_screen.dart';
import 'package:xride/screens/payment_web_screen.dart';
import 'package:xride/screens/signup_screen.dart';
import 'package:xride/services/car_service.dart';
import 'package:xride/services/location_service.dart';
import 'package:xride/services/parking_service.dart';
import 'package:xride/services/payment_service.dart';

class AppRouter {
  static const String loginScreen = "/";
  static const String signupScreen = "/signup_screen";
  static const String homeScreen = "/home_screen";
  static const String paymentScreen = "/payment_screen";
  static const String paymentWebScreen = "/payment_web_screen";
  static const String carDetailsScreen = "/car_details_screen";

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const LogInScreen());
      case signupScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SignupScreen());
      case homeScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => MultiBlocProvider(providers: [
            BlocProvider<LocationCubit>(
                create: (context) => LocationCubit(LocationService())),
            BlocProvider<CarCubit>(create: (context) => CarCubit(CarService())),
            BlocProvider<ParkingCubit>(
                create: (context) => ParkingCubit(ParkingService())),
          ], child: const HomeScreen()),
        );
      case carDetailsScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => CarDetailsScreen(
            reservationArgs: settings.arguments as ReservationArgs,
          ),
        );
      case paymentScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
              create: (context) => PaymentCubit(PaymentService()),
              child: const PaymentScreen()),
        );
      case paymentWebScreen:
        return MaterialPageRoute(
            builder: (BuildContext context) => PaymentWebView(
                paymentArgs: settings.arguments as PaymentWebArgs));
    }
    return null;
  }
}
