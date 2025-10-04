import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiException(this.message, {this.statusCode, this.error});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// ============================================================================
// Response Parser Type Definition
// ============================================================================

/// Function type for parsing API responses
/// Takes raw JSON and a data parser, returns ApiResponse<T>
// typedef ResponseParser =
//     T Function<T>(Map<String, dynamic> json, T Function(dynamic) fromJsonT);

/// Default parser for ApiResponse structure
// ApiResponse<T> defaultResponseParser<T>(
//   Map<String, dynamic> json,
//   T Function(dynamic) fromJsonT,
// ) {
//   return ApiResponse<T>.fromJson(json, fromJsonT);
// }

// /// Alternative: Direct data parser (no wrapper)
// T directDataParser<T>(
//   Map<String, dynamic> json,
//   T Function(dynamic) fromJsonT,
// ) {
//   return fromJsonT(json);
// }

abstract interface class ApiClient {
  Future<T> get<T>(
    String path, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<void> delete(String path, {Map<String, String>? headers});
}

// TODO: Add support for interceptors
class HttpApiClient implements ApiClient {
  final String baseUrl;
  final http.Client client;
  final Map<String, String> defaultHeaders;

  HttpApiClient({
    required this.baseUrl,
    http.Client? client,
    Map<String, String>? defaultHeaders,
    Function? responseParser,
  }) : client = client ?? http.Client(),
       defaultHeaders =
           defaultHeaders ??
           {'Content-Type': 'application/json', 'Accept': 'application/json'};

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {...defaultHeaders, ...?headers};
  }

  // TODO: Add support for query parameters
  // TODO: Replace Uri.parse with Uri()
  Uri _buildUri(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$cleanBaseUrl/$cleanPath');
  }

  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // TODO: Cast will throw if response.body is null
      if (response.body.isEmpty) {
        return null as T;
      }

      final jsonData = json.decode(response.body);

      if (fromJson != null) {
        if (jsonData is List) {
          // Handle list responses
          return jsonData
                  .map((item) => fromJson(item as Map<String, dynamic>))
                  .toList()
              as T;
        } else {
          // Handle single object responses
          return fromJson(jsonData as Map<String, dynamic>);
        }
      }

      return jsonData as T;
    }

    // Handle errors
    String errorMessage = 'Request failed';
    try {
      final errorData = json.decode(response.body);
      // TODO : Add better error handling
      errorMessage = errorData['detail'] ?? errorMessage;
    } catch (_) {
      errorMessage = response.body.isNotEmpty
          ? response.body
          : 'Status ${response.statusCode}';
    }

    throw ApiException(errorMessage, statusCode: response.statusCode);
  }

  @override
  Future<T> get<T>(
    String path, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
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
  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
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
  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
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
  Future<void> delete(String path, {Map<String, String>? headers}) async {
    try {
      final response = await client.delete(
        _buildUri(path),
        headers: _mergeHeaders(headers),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      String errorMessage = 'Delete failed';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['detail'] ?? errorMessage;
      } catch (_) {}

      throw ApiException(errorMessage, statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('DELETE request failed: $e', error: e);
    }
  }
}
