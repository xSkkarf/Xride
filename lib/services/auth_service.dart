import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
      return await attemptTokenRefresh(refreshToken, prefs);
    }

    // Check if the access token is expired
    if (JwtDecoder.isExpired(accessToken!)) {
      // Attempt to refresh the token
      return await attemptTokenRefresh(refreshToken!, prefs);
    }

    // If token is still valid, return true
    return true;
  }

  // Helper function to handle token refreshing
  Future<bool> attemptTokenRefresh(String refreshToken, SharedPreferences prefs) async {
    try {
      print('Attempting to refresh token...');
      final response = await dio.post('$baseUrl/token/refresh/', data: {
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


  Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken')!;
  }

  Future<bool> monitorTokenExpiration() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    print('Monitoring token expiration...');
    
    if (refreshToken == null) {
      print('Refresh token is null. Logging out.');
      return false;
    }

    if (accessToken != null && JwtDecoder.isExpired(accessToken)) {
      print('Access token has expired. Attempting to refresh.');
      return await attemptTokenRefresh(refreshToken, prefs);
    } else if (accessToken != null) {
      final expirationDate = JwtDecoder.getExpirationDate(accessToken);
      final currentTime = DateTime.now();
      final timeUntilExpiration = expirationDate.difference(currentTime);

      print('Access token is valid. Expires in ${timeUntilExpiration.inMinutes} minutes.');

      if (timeUntilExpiration > const Duration(minutes: 1)) {
        print('Scheduling token refresh 1 minute before expiration.');
        Future.delayed(timeUntilExpiration - const Duration(minutes: 1), () async {
          final success = await attemptTokenRefresh(refreshToken, prefs);
          if (success) {
            print('Token successfully refreshed. Monitoring again.');
            await monitorTokenExpiration(); // Continue monitoring after refresh
          }
        });
      } else {
        print('Token is expiring soon. Refreshing now.');
        final success = await attemptTokenRefresh(refreshToken, prefs);
        if (success) {
          print('Token successfully refreshed. Monitoring again.');
          await monitorTokenExpiration(); // Continue monitoring after refresh
        }
      }
    }

    return false;
  }
}
