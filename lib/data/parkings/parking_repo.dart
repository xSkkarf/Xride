
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';
import 'package:xride/data/parkings/parking_model.dart';
import 'package:xride/network/api_client.dart';

class ParkingRepo {
  final ApiClient apiClient = ApiClient();
  Future<List<ParkingModel>> getParkings() async {

    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    
    try{
      Response response = await apiClient.dio.get(
      '${XConstants.baseUrl}/${XConstants.backendVersion}/locations/parking/',
        options: Options(headers: {'Authorization': 'JWT $accessToken'}),
      );

      if(response.statusCode == 200){
        final List<ParkingModel> parkings = (response.data as List)
            .map((item) => ParkingModel.fromJson(item))
            .toList();
        return parkings;
      } else {
        print('Failed to fetch nearby cars not 200');
        throw Exception('Failed to fetch nearby cars ${response.statusCode}');
      }
    } catch(e){
      print('Failed to fetch nearby cars: $e');
      throw Exception('Failed to fetch nearby cars');
    }
  }
  
  
}