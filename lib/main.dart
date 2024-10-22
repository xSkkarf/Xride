import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xride/app_router.dart';
import 'package:xride/cubit/auth/auth_cubit.dart';
import 'package:xride/data/user/user_repo.dart';
import 'package:xride/services/auth_service.dart';

void main() {
  runApp(
    MultiBlocProvider(providers: [
      BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(AuthService(), UserRepo()),
      ),
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
    context.read<AuthCubit>().monitorTokenExpiration();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UserLoggedIn) {
          initScreen = AppRouter.homeScreen;
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'XRide App',
        onGenerateRoute: appRouter.generateRoute,
        initialRoute: initScreen,
      ),
    );
  }
}
