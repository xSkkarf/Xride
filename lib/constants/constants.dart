import 'package:flutter_dotenv/flutter_dotenv.dart';

class XConstants{
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";
  static final String backendVersion = dotenv.env['BACKEND_VERSION'] ?? "";

  static final String payMobApiKey = dotenv.env['PAYMOB_API_KEY'] ?? "";
  static final String payMobIntegrationId = dotenv.env['PAYMOB_INTEGRATION_ID'] ?? "";
}