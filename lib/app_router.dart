import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xride/cubit/auth/auth_cubit.dart';
import 'package:xride/cubit/home/home_cubit.dart';
import 'package:xride/cubit/payment/payment_cubit.dart';
import 'package:xride/screens/home_screen.dart';
import 'package:xride/screens/login_screen.dart';
import 'package:xride/screens/payment_screen.dart';
import 'package:xride/screens/payment_web_screen.dart';
import 'package:xride/services/auth_service.dart';
import 'package:xride/services/home_service.dart';
import 'package:xride/services/payment_service.dart';

class AppRouter {
  static const String loginScreen = "/";
  static const String homeScreen = "/home_screen";
  static const String paymentScreen = "/payment_screen";
  static const String paymentWebScreen = "/payment_web_screen";


  Route? generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case loginScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => AuthCubit(AuthService()),
            child: const LogInScreen()
          ),
        );
      case homeScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => MultiBlocProvider(
            providers: [BlocProvider<HomeCubit>(create: (context) => HomeCubit(HomeService()))],
            child: const HomeScreen()
          ),
        );
      case paymentScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => BlocProvider(
            create: (context) => PaymentCubit(PaymentService()),
            child: const PaymentScreen()
          ),
        );
      case paymentWebScreen:
        return MaterialPageRoute(
          builder: (BuildContext context) => PaymentWebView(paymentUrl: settings.arguments as String)
        );
    }
    return null;
  }
}