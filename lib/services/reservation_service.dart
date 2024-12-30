import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';

class ReservationService {
  Future<void> reserveCar(int carId, String plan, String latitude, String longitude) async {
    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('accessToken')!;

    final requestData = {
      "reservation_plan": plan,
      "location_latitude": latitude,
      "location_longitude": longitude,
    };

    print('Request data: $requestData');

    try {
      final Response response = await Dio().post(
        "${XConstants.baseUrl}/${XConstants.backendVersion}/car/$carId/reserve/",
        options: Options(headers: {'Authorization': 'JWT $accessToken'}),
        data: requestData,
      );
      // Handle the response if needed
      print('Reservation successful: ${response.data}');
    } on DioException catch (e) {
      if (e.response != null) {
        print('DioException: ${e.message}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        throw Exception(e.response?.data['error']);
      } else {
        print('DioException: ${e.message}');
      }
      rethrow;
    } catch (e) {
      // Handle other exceptions
      print('Exception: $e');
      rethrow;
    }
  }
}