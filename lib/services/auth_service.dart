import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';

class AuthService {
  final Dio dio = Dio();
  final String baseUrl = XConstants.baseUrl;

  Future<String> login(String username, String password) async {
    final response = await dio.post('$baseUrl/token/', data: {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      final String accessToken = response.data['access'];
      final String refreshToken = response.data['refresh'];
      final prefs = await SharedPreferences.getInstance();
      
      // Save access and refresh tokens
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);
      
      // Return the access token for further use
      return accessToken;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('accessToken');
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}
