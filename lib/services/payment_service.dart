import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';
import 'package:xride/network/api_client.dart';

class PaymentService{

  final ApiClient apiClient = ApiClient(); 

  Future<String> getPaymentKey(int amount,String currency)async{
    try {
      SharedPreferences prefs= await SharedPreferences.getInstance();
      String authanticationToken= await getAuthenticationToken();

      print("authanticationToken: $authanticationToken");

      int orderId= await getOrderId(
        authanticationToken: authanticationToken, 
        amount: (100*amount).toString(), 
        currency: currency,
      );

      String accessToken = getAccessToken(prefs); 


      String paymentKey= await getPaymentToken(
        authanticationToken: authanticationToken,
        amount: (100*amount).toString(),
        currency: currency,
        orderId: orderId.toString(),
      );

      print("BEFORE INITIALIZING PAYMENT");
      try{
        int statusCode = await initializePayment(authanticationToken, amount, accessToken);
        print("statusCode: $statusCode");
        if(statusCode != 201){
          print("Failed to initialize payment");
          throw Exception();
        }
      } catch(e){
        print("Failed to initialize payment: $e");
        throw Exception("Failed to initialize payment: $e");
      }
      
      return paymentKey;
    } catch (e) {
      throw Exception();
    }
  }

  Future<String>getAuthenticationToken()async{
    final Response response=await apiClient.dio.post(
      "https://accept.paymob.com/api/auth/tokens",
      data: {
        "api_key":XConstants.payMobApiKey, 
      }
    );
    return response.data["token"];
  }

  String getAccessToken(SharedPreferences prefs){
    return prefs.getString("accessToken")!;
  }

  Future<int> initializePayment(
    String authanticationToken,
    int amount,
    String accessToken
    )async{
      final Response response = await apiClient.dio.post(
        "${XConstants.baseUrl}/${XConstants.backendVersion}/user/payments/create/",
        options: Options(headers: {'Authorization': 'JWT $accessToken'}),
        data: {
          "amount": amount,
          "order_id": authanticationToken,
        },
      );
      return response.statusCode ?? 404;
    
  }

  Future<int>getOrderId({
    required String authanticationToken,
    required String amount,
    required String currency,
  })async{
    final Response response=await apiClient.dio.post(
      "https://accept.paymob.com/api/ecommerce/orders",
      data: {
        "auth_token":  authanticationToken,
        "amount_cents":amount, //  >>(STRING)<<
        "currency": currency,//Not Req
        "delivery_needed": "false",
        "items": [],
      }
    );
    return response.data["id"];  //INTGER
  }
  
  Future<String> getPaymentToken({
    required String authanticationToken,
    required String orderId,
    required String amount,
    required String currency,
  }) async{
    final Response response=await apiClient.dio.post(
      "https://accept.paymob.com/api/acceptance/payment_keys",
      data: {
        //ALL OF THEM ARE REQIERD
        "expiration": 3600,

        "auth_token": authanticationToken,//From First Api
        "order_id":orderId, //From Second Api  >>(STRING)<<
        "integration_id": XConstants.payMobIntegrationId,//Integration Id Of The Payment Method
        
        "amount_cents": amount, 
        "currency": currency, 
        
        "billing_data": {
          //Have To Be Values
          "first_name": "Clifford", 
          "last_name": "Nicolas", 
          "email": "claudette09@exa.com",
          "phone_number": "+86(8)9135210487",

          //Can Set "NA"
          "apartment": "NA",  
          "floor": "NA", 
          "street": "NA", 
          "building": "NA", 
          "shipping_method": "NA", 
          "postal_code": authanticationToken, 
          "city": "NA", 
          "country": "NA", 
          "state": "NA"
        }, 
      }
    );
    return response.data["token"];
  }

}