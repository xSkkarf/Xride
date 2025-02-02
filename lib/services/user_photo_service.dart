import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';
import 'package:xride/network/api_client.dart';

class UserPhotoService {

  final ApiClient apiClient = ApiClient();

  Future<String?> uploadPhoto(String photoType) async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    if (accessToken == null) return "Unauthorized";

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return "No file selected.";

    FormData formData = FormData.fromMap({
      photoType: await MultipartFile.fromFile(pickedFile.path, filename: pickedFile.name),
    });

    try {
      Response response = await apiClient.dio.post(
        "${XConstants.baseUrl}/auth/user/upload-photo/",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "JWT $accessToken",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200) {
        return "Photo uploaded successfully";
      } else {
        print(response.data["error"]);
        return response.data["error"] ?? "Error uploading photo";
      }
    } on DioException catch (e) {
      print(e);
      return "Failed to upload photo: $e";
    }
  }

  Future<String?> deletePhoto(String photoType) async {
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    if (accessToken == null) return "Unauthorized";

    try {
      Response response = await apiClient.dio.delete(
        "${XConstants.baseUrl}/auth/user/delete-photo/",
        data: {"photo_type": photoType},
        options: Options(headers: {"Authorization": "JWT $accessToken"}),
      );

      if (response.statusCode == 204) {
        return "Photo deleted successfully";
      } else {
        return response.data["error"] ?? "Error deleting photo";
      }
    } catch (e) {
      return "Failed to delete photo: $e";
    }
  }
}
