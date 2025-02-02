import 'package:flutter_dotenv/flutter_dotenv.dart';

class XConstants{
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";
  static final String hostName = dotenv.env['HOST_NAME'] ?? "";
  static final String backendVersion = dotenv.env['BACKEND_VERSION'] ?? "";

  static final String payMobApiKey = dotenv.env['PAYMOB_API_KEY'] ?? "";
  static final String payMobIntegrationId = dotenv.env['PAYMOB_INTEGRATION_ID'] ?? "";

  static final String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";
}