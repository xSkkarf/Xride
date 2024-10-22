import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/constants/constants.dart';

class PaymentService{

  Future<String> getPaymentKey(int amount,String currency)async{
    try {
      String authanticationToken= await getAuthenticationToken();

      int orderId= await getOrderId(
        authanticationToken: authanticationToken, 
        amount: (100*amount).toString(), 
        currency: currency,
      );

      String userId = getUserId().toString();
      String accessToken = getAccessToken().toString(); 


      String paymentKey= await getPaymentToken(
        authanticationToken: authanticationToken,
        amount: (100*amount).toString(),
        currency: currency,
        orderId: orderId.toString(),
        userId: userId,
      );

      // try{
      //   Future<int> statusCode = initializePayment(userId, orderId, amount, currency, authanticationToken, accessToken);
      //   if(statusCode != Future.value(200)){
      //     throw Exception();
      //   }
      // } catch(e){
      //   throw Exception();
      // }
      
      return paymentKey;
    } catch (e) {
      throw Exception();
    }
  }

  Future<String>getAuthenticationToken()async{
    final Response response=await Dio().post(
      "https://accept.paymob.com/api/auth/tokens",
      data: {
        "api_key":XConstants.payMobApiKey, 
      }
    );
    return response.data["token"];
  }

  Future<String> getAccessToken()async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getString("accessToken")!;
  }

  Future<int> initializePayment(
    String userId,
    int orderId,
    int amount,
    String currency,
    String authanticationToken,
    String accessToken
    )async{
    try {
      final Response response = await Dio().post(
        "${XConstants.baseUrl}/${XConstants.backendVersion}/user/payments/create/",
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        data: {
          "auth_token": authanticationToken,
          "amount": amount.toString(),
          "currency": currency,
          "order_id": orderId,
          "user_id": userId,
        },
      );
      return response.statusCode ?? 404;
    } catch (e) {
      if (e is DioException) {
        // Handle DioException specifically
        print('DioException: ${e.message}');
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
      } else {
        // Handle other exceptions
        print('Exception: $e');
      }
      return 404;
    }
  }

  Future<int>getUserId()async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    return prefs.getInt("id")!;
  }

  Future<int>getOrderId({
    required String authanticationToken,
    required String amount,
    required String currency,
  })async{
    final Response response=await Dio().post(
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
    required String userId
  }) async{
    final Response response=await Dio().post(
      "https://accept.paymob.com/api/acceptance/payment_keys",
      data: {
        //ALL OF THEM ARE REQIERD
        "expiration": 3600,

        "auth_token": authanticationToken,//From First Api
        "user_id": userId,
        "order_id":orderId,//From Second Api  >>(STRING)<<
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
          "postal_code": "NA", 
          "city": "NA", 
          "country": "NA", 
          "state": "NA"
        }, 
      }
    );
    return response.data["token"];
  }

}