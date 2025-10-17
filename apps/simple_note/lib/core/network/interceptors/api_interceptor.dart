// lib/core/network/interceptors/api_interceptor.dart
import 'package:dio/dio.dart';
import 'package:simple_note/core/network/exception/api_exception.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authentication token here if needed
    // final token = await getToken();
    // options.headers['Authorization'] = 'Bearer $token';

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // You can handle common response logic here if needed
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle common errors
    final exception = _handleDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please try again.',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['message'] ?? 'Server error occurred';

        return ApiException(
          message: message,
          statusCode: statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled');

      case DioExceptionType.connectionError:
        return ApiException(message: 'No internet connection');

      case DioExceptionType.badCertificate:
        return ApiException(message: 'Certificate verification failed');

      case DioExceptionType.unknown:
        return ApiException(
          message: 'An unexpected error occurred',
          data: error.error,
        );
    }
  }
}
