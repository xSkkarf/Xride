import 'package:flutter/material.dart';
import 'package:xride/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XRide App',
      onGenerateRoute: _appRouter.generateRoute,  // Use the AppRouter for navigation
      initialRoute: AppRouter.loginScreen,        // Set the initial route
    );
  }
}
