import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xride/cubit/car/car_cubit.dart';
import 'package:xride/cubit/location/location_cubit.dart';
import 'package:xride/cubit/payment/payment_cubit.dart';
import 'package:xride/screens/home_screen.dart';
import 'package:xride/screens/login_screen.dart';
import 'package:xride/screens/payment_screen.dart';
import 'package:xride/screens/payment_web_screen.dart';
import 'package:xride/services/car_service.dart';
import 'package:xride/services/location_service.dart';
import 'package:xride/services/payment_service.dart';

class AppRouter {
  static const String loginScreen = "/";
  static const String homeScreen = "/home_screen";
  static const String paymentScreen = "/payment_screen";
  static const String paymentWebScreen = "/payment_web_screen";

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => const LogInScreen());
      case homeScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => MultiBlocProvider(
            providers: [
              BlocProvider<LocationCubit>(
                create: (context) => LocationCubit(LocationService())),
              BlocProvider<CarCubit>(
                create: (context) => CarCubit(CarService())),
            ], 
            child: const HomeScreen()),
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
