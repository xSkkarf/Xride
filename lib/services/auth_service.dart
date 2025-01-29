import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:xride/network/api_client.dart';

class AuthService {
  final ApiClient apiClient = ApiClient(); 
  final String baseUrl = XConstants.baseUrl;

  Future<String> login(String username, String password) async {
    try{
      final response = await apiClient.dio.post('$baseUrl/auth/jwt/create/', data: {
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
    } on DioException catch (e) {
      if (e.response!.statusCode == 401) {
        throw Exception(e.response!.data);
      } else {
        throw Exception('Login failed');
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    if (accessToken == null && refreshToken == null) {
      // No tokens available, log out the user
      return false;
    }

    if (accessToken == null && refreshToken != null) {
      // Access token is missing but refresh token exists, try refreshing
      return await attemptTokenRefresh();
    }

    // Check if the access token is expired
    if (JwtDecoder.isExpired(accessToken!)) {
      if (refreshToken == null || JwtDecoder.isExpired(refreshToken)){
        return false;
      }
      // Attempt to refresh the token
      return await attemptTokenRefresh();
    }

    // If token is still valid, return true
    return true;
  }

  // Helper function to handle token refreshing
  Future<bool> attemptTokenRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    try {
      print('Attempting to refresh token...');
      if(refreshToken == null || JwtDecoder.isExpired(refreshToken)){
        return false;
      }
      final response = await apiClient.dio.post('$baseUrl/auth/jwt/refresh/', data: {
        'refresh': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await prefs.setString('accessToken', newAccessToken);
        print('Token refresh successful. New access token stored.');
        return true;
      } else {
        print('Token refresh failed. Logging out.');
        await logout();
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      await logout();
      return false;
    }
  }


  Future<bool> monitorTokenExpiration() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    print('Monitoring token expiration...');
    
    if (refreshToken == null || JwtDecoder.isExpired(refreshToken)) {
      print('Refresh token is null. Logging out.');
      return false;
    }

    if (accessToken != null && JwtDecoder.isExpired(accessToken)) {
      print('Access token has expired. Attempting to refresh.');
      return await attemptTokenRefresh();
    } else if (accessToken != null) {
      final expirationDate = JwtDecoder.getExpirationDate(accessToken);
      final currentTime = DateTime.now();
      final timeUntilExpiration = expirationDate.difference(currentTime);

      print('Access token is valid. Expires in ${timeUntilExpiration.inMinutes} minutes.');

      if (timeUntilExpiration > const Duration(minutes: 1)) {
        print('Scheduling token refresh 1 minute before expiration.');
        Future.delayed(timeUntilExpiration - const Duration(minutes: 1), () async {
          final success = await attemptTokenRefresh();
          if (success) {
            print('Token successfully refreshed. Monitoring again.');
            await monitorTokenExpiration(); // Continue monitoring after refresh
          }
        });
      } else {
        print('Token is expiring soon. Refreshing now.');
        final success = await attemptTokenRefresh();
        if (success) {
          print('Token successfully refreshed. Monitoring again.');
          await monitorTokenExpiration(); // Continue monitoring after refresh
        }
      }
    }

    return false;
  }

  

  Future<void> signup(
    String username,
    String email, 
    String firstName, 
    String lastName, 
    String phoneNumber,
    String address,
    String nationalId,
    String password,
    String rePassword) async {

      try{
        final response = await apiClient.dio.post('$baseUrl/auth/users/', data: {
          'username': username,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'address': address,
          'national_id': nationalId,
          'password': password,
          're_password': rePassword,
        });
      

        if (response.statusCode == 201) {
          print('User created successfully');
        } else {
          throw Exception('Signup failed');
        }

      } on DioException catch (e) {
        if (e.response!.statusCode == 400) {
          throw Exception(e.response!.data);
        } else {
          throw Exception('Signup failed');
        }
      }
  }
}
