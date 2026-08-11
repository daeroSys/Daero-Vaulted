import 'package:dio/dio.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    // Retry Interceptor Placeholder
    // Authentication Interceptor Placeholder
  }
}
