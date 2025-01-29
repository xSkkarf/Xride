import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xride/cubit/auth/auth_cubit.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  BuildContext? context; // Store the BuildContext

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio();
  }

  // Initialize the ApiClient with BuildContext
  void initialize(BuildContext context) {
    this.context = context;
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add the access token to the request header
          final prefs = await SharedPreferences.getInstance();
          final accessToken = prefs.getString('accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'JWT $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Access AuthCubit from the context
            if (context != null) {
              final authCubit = context!.read<AuthCubit>();
              if (error.response?.data['code'] == 'user_not_found') {
                // Logout the user if user not found
                await authCubit.logout();
                return handler.next(error);
              } else {
                bool refreshSuccess = await authCubit.attemptTokenRefresh();

                if (refreshSuccess) {
                  // Retry the original request with the new token
                  final response = await _retryRequest(error.requestOptions);
                  return handler.resolve(response);
                } else {
                  // Logout the user if refresh token fails
                  await authCubit.logout();
                  return handler.next(error);
                }
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}