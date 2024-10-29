
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';
import 'package:xride/data/user/user_model.dart';

class UserRepo {

  Future<UserModel> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('No access token found');
    }

    try {
      final response = await Dio().get(
        '${XConstants.baseUrl}/${XConstants.backendVersion}/user/profile',
        options: Options(headers: {'Authorization': 'JWT $accessToken'}),
      );

      if (response.statusCode == 200) {
        final UserModel user = UserModel.fromJson(response.data);
        return user;
      } else {
        print('Failed to fetch user profile not 200');
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
      print('Failed to fetch user profile: $e');
      throw Exception('Failed to fetch user profile');
    }
  }

  void saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('id', user.id);
    prefs.setString('username', user.username);
    prefs.setString('email', user.email);
    prefs.setString('firstName', user.firstName);
    prefs.setString('lastName', user.lastName);
    prefs.setDouble('walletBalance', user.walletBalance);
    prefs.setString('phoneNumber', user.phoneNumber);
    prefs.setString('address', user.address);
    prefs.setString('nationalId', user.nationalId);
  }

}