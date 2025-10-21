// lib/core/network/exceptions/api_exception.dart
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioError(dynamic error) {
    String message = 'An unknown error occurred';
    int? statusCode;
    dynamic data;

    if (error is DioException) {
      statusCode = error.response?.statusCode;
      data = error.response?.data;

      if (error.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timeout with the server';
      } else if (error.type == DioExceptionType.receiveTimeout) {
        message = 'Receive timeout in connection with the server';
      } else if (error.type == DioExceptionType.badResponse) {
        message = 'Received invalid status code: $statusCode';
      } else if (error.type == DioExceptionType.cancel) {
        message = 'Request to the server was cancelled';
      } else if (error.type == DioExceptionType.unknown) {
        message = 'An unexpected error occurred: ${error.message}';
      } else {
        message = error.message ?? message;
      }
    }

    return ApiException(message: message, statusCode: statusCode, data: data);
  }

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
