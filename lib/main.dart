import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:xride/app_router.dart';
import 'package:xride/cubit/auth/auth_cubit.dart';
import 'package:xride/cubit/reservation/reservation_cubit.dart';
import 'package:xride/cubit/user/user_cubit.dart';
import 'package:xride/data/user/user_repo.dart';
import 'package:xride/network/api_client.dart';
import 'package:xride/services/auth_service.dart';
import 'package:xride/services/reservation_service.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(
    MultiBlocProvider(providers: [
      BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(AuthService()),
      ),
      BlocProvider<UserCubit>(
        create: (context) => UserCubit(UserRepo()),
      ),
      BlocProvider(create: (context) => ReservationCubit(ReservationService()))
    ], child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppRouter appRouter = AppRouter();
  String initScreen = AppRouter.loginScreen;

  @override
  void initState() {
    context.read<AuthCubit>().checkLoginStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ApiClient().initialize(context);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Xride App',
        onGenerateRoute: appRouter.generateRoute,
        initialRoute: initScreen,
      );
  }
}
