import 'package:shared_preferences/shared_preferences.dart';

class HomeService {

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
  }
}
