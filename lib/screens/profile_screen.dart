import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xride/cubit/user/user_cubit.dart';
import 'package:xride/cubit/user_photo/user_photo_cubit.dart';
import 'package:xride/data/user/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> isUserPhotosEnabled = {
    'licence_photo': 'enabled',
    'national_id_photo': 'enabled',
    'personal_photo': 'enabled',
    'delete_personal_photo': 'disabled',
  };

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future<void> setup() async {
    if (!mounted) return; // Check if the widget is still mounted before calling Cubit
    await context.read<UserCubit>().fetchUserInfo(); 
    if (!mounted) return;

    final state = context.read<UserCubit>().state;
    if (state is UserFetchSuccess && mounted) {
      final user = state.user;
      setState(() {
        isUserPhotosEnabled['personal_photo'] = (user.personalPhoto == "") ? 'enabled' : 'disabled';
        isUserPhotosEnabled['delete_personal_photo'] = (user.personalPhoto == "") ? 'disabled' : 'enabled';
        isUserPhotosEnabled['national_id_photo'] = (user.nationalIdPhoto == "") ? 'enabled' : 'disabled';
        isUserPhotosEnabled['licence_photo'] = (user.licencePhoto == "") ? 'enabled' : 'disabled';
      });
    }
  }

  void _handleUpload(String photoType) async {
    if (!mounted) return;
    await context.read<UserPhotoCubit>().handleUpload(photoType);
    if (!mounted) return;
    
    await setup();

  }

  void _handleDelete(String photoType) async {
    await context.read<UserPhotoCubit>().handleDelete(photoType);
    await setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: MultiBlocListener(
            listeners: [
              BlocListener<UserPhotoCubit, UserPhotoState>(
                listener: (context, state) {
                  if (state is UserPhotoFail) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error)),
                      );
                    }
                  } else if (state is UserPhotoFetchSuccess) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Upload done successfully")),
                      );
                    }
                    context.read<UserCubit>().fetchUserInfo();
                  } else if (state is UserPhotoDeleteSuccess) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Deletion done successfully")),
                      );
                    }
                    context.read<UserCubit>().fetchUserInfo();
                  }
                },
              ),
              BlocListener<UserCubit, UserState>(
                listener: (context, state) {
                  if (state is UserFetchFail) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error)),
                      );
                    }
                  }
                },
              ),
            ],
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                if (userState is UserFetchSuccess) {
                  UserModel user = userState.user;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: (isUserPhotosEnabled['personal_photo'] == 'enabled') ? () => _handleUpload('personal_photo'): null,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: 
                              userState.user.personalPhoto != ""
                              ? NetworkImage(userState.user.personalPhoto):
                              const AssetImage('assets/profile_pic.png'),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.black,
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                                    onPressed: (isUserPhotosEnabled['personal_photo'] == 'enabled')
                                        ? () => _handleUpload('personal_photo')
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: (isUserPhotosEnabled['delete_personal_photo'] == 'enabled')
                            ? () => _handleDelete('personal_photo')
                            : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete Personal Photo'),
                      ),
                      const SizedBox(height: 20),
                      _buildPhotoSection("National ID Photo", user.nationalIdPhoto, "national_id_photo"),
                      _buildPhotoSection("Licence Photo", user.licencePhoto, "licence_photo"),
                      const SizedBox(height: 20),
                      _buildProfileInfo("Username", user.username),
                      _buildProfileInfo("Email", user.email),
                      _buildProfileInfo("First Name", user.firstName),
                      _buildProfileInfo("Last Name", user.lastName),
                      _buildProfileInfo("Wallet Balance", "\$${user.walletBalance}"),
                      _buildProfileInfo("Phone Number", user.phoneNumber),
                      _buildProfileInfo("Address", user.address),
                      _buildProfileInfo("National ID", user.nationalId),
                      const SizedBox(height: 20),
                    ],
                  );
                } else if (userState is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text("Failed to fetch user data"));
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(String title, String? photoUrl, String photoType) {
    return Column(
      children: [
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: photoUrl != ""
              ? Image.network(photoUrl!)
              : Center(child: Text("No $title")),
        ),
        ElevatedButton(
          onPressed: (isUserPhotosEnabled[photoType] == 'enabled') ? () => _handleUpload(photoType) : null,
          child: Text('Upload $title'),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
