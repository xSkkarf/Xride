import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';
import 'package:xride/network/api_client.dart';

class ReservationService {

  final ApiClient apiClient = ApiClient();
  
  dynamic getLocalTime(String time) {
    final localTime = DateTime.parse(time).toLocal();
    return localTime;
  }

  Future<dynamic> checkActiveReservation() async {
    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('accessToken')!;

    try {
      final Response response = await apiClient.dio.get(
        "${XConstants.baseUrl}/${XConstants.backendVersion}/user/trips/active/",
        options: Options(headers: {'Authorization': 'JWT $accessToken'}),
      );

      final data = {
        'reservation_id': response.data['reservation_id'],
        'car_id': response.data['car_id'],
        'car_model': response.data['car_model'],
        'car_plate': response.data['car_plate'],
        'reservation_plan': response.data['reservation_plan'],
        'start_time': getLocalTime(response.data['start_time']),
        'end_time': getLocalTime(response.data['end_time']),
        'status': response.data['status'],
      };

      return data;

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

  Future<dynamic> reserveCar(int carId, String plan, String latitude, String longitude) async {
    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('accessToken')!;

    final requestData = {
      "reservation_plan": plan,
      "location_latitude": latitude,
      "location_longitude": longitude,
    };

    print('Request data: $requestData');

    try {
      final Response response = await apiClient.dio.post(
        "${XConstants.baseUrl}/${XConstants.backendVersion}/car/$carId/reserve/",
        options: Options(headers: {'Authorization': 'JWT $accessToken'}),
        data: requestData,
      );

      final data = {
        'reservation_id': response.data['reservation_id'],
        'car_id': response.data['car_id'],
        'car_model': response.data['car_model'],
        'car_plate': response.data['car_plate'],
        'reservation_plan': response.data['reservation_plan'],
        'start_time': getLocalTime(response.data['start_time']),
        'end_time': getLocalTime(response.data['end_time']),
        'status': response.data['status'],
      };
      // Handle the response if needed
      print('Reservation successful: ${data}');
      return data;

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

  Future<void> releaseCar(int carId, int parkingId, double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('accessToken')!;

    try {
      await apiClient.dio.post(
        "${XConstants.baseUrl}/${XConstants.backendVersion}/car/$carId/release/",
        options: Options(headers: {'Authorization': 'JWT $accessToken'}),
        data: {
          'park_dist': parkingId,
          'location_latitude': latitude,
          'location_longitude': longitude,
        },
      );

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