import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';
import 'package:xride/data/cars/car_model.dart';
import 'package:xride/network/api_client.dart';

class CarRepo {

  final ApiClient apiClient = ApiClient(); 

  Future<List<CarModel>> fetchCars(String latitude, String longitude) async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');


    if (accessToken == null) {
      throw Exception('No access token found');
    }

    try {
      final response = await apiClient.dio.get(
        '${XConstants.baseUrl}/${XConstants.backendVersion}/car/nearby-available/',
        options: Options(headers: {'Authorization': 'JWT $accessToken'}),
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        final List<CarModel> car = (response.data["nearby_cars"] as List)
            .map((item) => CarModel.fromJson(item))
            .toList();
        return car;
      } else {
        print('Failed to fetch nearby cars not 200');
        throw Exception('Failed to fetch nearby cars not 200');
      }
    } on DioException catch (e) {
      print('Failed to fetch nearby cars: ${e.response!.data['error']}');
      throw Exception('${e.response!.data['error']}');
    }
  }
  
}
