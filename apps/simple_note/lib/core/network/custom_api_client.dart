import 'dart:convert';
import 'package:http/http.dart' as http;

// Generic API Response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final Map<String, dynamic>? meta;

  ApiResponse({this.data, this.message, this.meta});
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiException(this.message, {this.statusCode, this.error});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// Abstract response adapter interface
abstract class ResponseAdapter {
  ApiResponse<T> adapt<T>(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  );

  String? extractErrorMessage(Map<String, dynamic> json);
}

// Adapter for {data, message, meta} pattern
class WrappedResponseAdapter implements ResponseAdapter {
  final String dataKey;
  final String messageKey;
  final String metaKey;

  WrappedResponseAdapter({
    this.dataKey = 'data',
    this.messageKey = 'message',
    this.metaKey = 'meta',
  });

  @override
  ApiResponse<T> adapt<T>(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    final rawData = json[dataKey];
    T? parsedData;

    if (fromJson != null && rawData != null) {
      parsedData = fromJson(rawData);
    } else {
      parsedData = rawData as T?;
    }

    return ApiResponse<T>(
      data: parsedData,
      message: json[messageKey] as String?,
      meta: json[metaKey] as Map<String, dynamic>?,
    );
  }

  @override
  String? extractErrorMessage(Map<String, dynamic> json) {
    return json[messageKey] as String? ?? json['detail'] as String?;
  }
}

// Adapter for direct response (no wrapper)
class DirectResponseAdapter implements ResponseAdapter {
  @override
  ApiResponse<T> adapt<T>(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    T? parsedData;

    if (fromJson != null) {
      parsedData = fromJson(json);
    } else {
      parsedData = json as T;
    }

    return ApiResponse<T>(data: parsedData);
  }

  @override
  String? extractErrorMessage(Map<String, dynamic> json) {
    return json['error'] as String? ??
        json['message'] as String? ??
        json['detail'] as String?;
  }
}

// Adapter for custom patterns like {success, result, error}
class CustomResponseAdapter implements ResponseAdapter {
  final String dataKey;
  final String? errorKey;
  final String? messageKey;

  CustomResponseAdapter({
    required this.dataKey,
    this.errorKey,
    this.messageKey,
  });

  @override
  ApiResponse<T> adapt<T>(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    final rawData = json[dataKey];
    T? parsedData;

    if (fromJson != null && rawData != null) {
      if (rawData is List) {
        parsedData = rawData.map((item) => fromJson(item)).toList() as T;
      } else {
        parsedData = fromJson(rawData);
      }
    } else {
      parsedData = rawData as T?;
    }

    return ApiResponse<T>(
      data: parsedData,
      message: messageKey != null ? json[messageKey] as String? : null,
    );
  }

  @override
  String? extractErrorMessage(Map<String, dynamic> json) {
    return (errorKey != null ? json[errorKey] as String? : null) ??
        json['message'] as String? ??
        json['detail'] as String?;
  }
}

abstract interface class ApiClient {
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  });

  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  });

  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  });

  Future<ApiResponse<void>> delete(String path, {Map<String, String>? headers});
}

class HttpApiClient implements ApiClient {
  final String baseUrl;
  final http.Client client;
  final Map<String, String> defaultHeaders;
  final ResponseAdapter responseAdapter;

  HttpApiClient({
    required this.baseUrl,
    http.Client? client,
    Map<String, String>? defaultHeaders,
    ResponseAdapter? responseAdapter,
  }) : client = client ?? http.Client(),
       defaultHeaders =
           defaultHeaders ??
           {'Content-Type': 'application/json', 'Accept': 'application/json'},
       responseAdapter = responseAdapter ?? DirectResponseAdapter();

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {...defaultHeaders, ...?headers};
  }

  Uri _buildUri(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$cleanBaseUrl/$cleanPath');
  }

  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse<T>();
      }

      final jsonData = json.decode(response.body);

      if (jsonData is! Map<String, dynamic>) {
        throw ApiException(
          'Invalid response format: API response is not a map',
        );
      }

      // Use adapter for object responses
      return responseAdapter.adapt<T>(jsonData, fromJson);
    }

    // Handle errors
    String errorMessage = 'Request failed';
    try {
      final errorData = json.decode(response.body);
      if (errorData is Map<String, dynamic>) {
        errorMessage =
            responseAdapter.extractErrorMessage(errorData) ?? errorMessage;
      }
    } catch (_) {
      errorMessage = response.body.isNotEmpty
          ? response.body
          : 'Status ${response.statusCode}';
    }

    throw ApiException(errorMessage, statusCode: response.statusCode);
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await client.get(
        _buildUri(path),
        headers: _mergeHeaders(headers),
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('GET request failed: $e', error: e);
    }
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await client.post(
        _buildUri(path),
        headers: _mergeHeaders(headers),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('POST request failed: $e', error: e);
    }
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await client.put(
        _buildUri(path),
        headers: _mergeHeaders(headers),
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('PUT request failed: $e', error: e);
    }
  }

  @override
  Future<ApiResponse<void>> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await client.delete(
        _buildUri(path),
        headers: _mergeHeaders(headers),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return ApiResponse<void>();
        }

        final jsonData = json.decode(response.body);
        if (jsonData is Map<String, dynamic>) {
          return responseAdapter.adapt<void>(jsonData, null);
        }
        return ApiResponse<void>();
      }

      String errorMessage = 'Delete failed';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map<String, dynamic>) {
          errorMessage =
              responseAdapter.extractErrorMessage(errorData) ?? errorMessage;
        }
      } catch (_) {}

      throw ApiException(errorMessage, statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('DELETE request failed: $e', error: e);
    }
  }
}
