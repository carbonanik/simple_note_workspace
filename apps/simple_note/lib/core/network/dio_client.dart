import 'package:dio/dio.dart';
import 'package:simple_note/core/network/interceptors/api_interceptor.dart';

class DioClient {
  static Dio create({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(ApiInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        error: true,
        requestBody: true,
        responseBody: true,
      ),
    );
    return dio;
  }
}
