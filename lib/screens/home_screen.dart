import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xride/app_router.dart';
import 'package:xride/cubit/auth/auth_cubit.dart';
import 'package:xride/data/user/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().fetchUserInfo();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_money),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.paymentScreen);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'User Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text(
                (user != null)
                    ? 'Balance: \$${user!.walletBalance}'
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
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is UserFetchSuccess) {
            setState(() {
              user = state.user;
            });
          } else if (state is UserLoggedOut) {
            Navigator.pushReplacementNamed(context, AppRouter.loginScreen);
          } else if (state is AuthFailure) {
            // Handle any error that may occur during logout
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error),
            ));
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is UserFetchFail) {
              return Center(
                child: Text('Failed to load user info: ${state.error}'),
              );
            } else {
              return Center(
                child: Text(
                  'Home Screen Content, ${user?.username ?? 'loading'}',
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
