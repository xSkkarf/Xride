import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xride/app_router.dart';
import 'package:xride/cubit/auth/auth_cubit.dart';
import 'package:xride/cubit/user/user_cubit.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xride Login'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) async{
              if (state is UserLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login Successful!')),
                );
                await context.read<UserCubit>().fetchUserInfo();
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
          ),
          BlocListener<UserCubit, UserState>(
            listener: (context, state) {
              if (state is UserFetchSuccess) {
                if (state.user.isSuperUser) {
                  Navigator.pushReplacementNamed(context, AppRouter.adminHomeScreen);
                } else {
                  Navigator.pushReplacementNamed(context, AppRouter.homeScreen);
                }
              }
            },
          ),
        ],
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                      ),
                      TextField(
                        controller: passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      (authState is AuthLoading || userState is UserLoading)
                          ? const CircularProgressIndicator()
                          : (ElevatedButton(
                              onPressed: () {
                                final email = emailController.text;
                                final password = passwordController.text;
                                context
                                    .read<AuthCubit>()
                                    .login(email, password);
                              },
                              child: const Text('Login'),
                            )),
                      const SizedBox(height: 15),
                      const Text(
                        "or",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.signupScreen);
                        },
                        child: const Text('Create an account'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
