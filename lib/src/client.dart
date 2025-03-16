import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:uri/uri.dart';

/// Exception thrown when an API request fails.
class EvccApiException implements Exception {
  /// The HTTP status code.
  final int statusCode;

  /// The error message.
  final String message;

  /// Creates a new API exception.
  EvccApiException(this.statusCode, this.message);

  @override
  String toString() => 'EvccApiException: $statusCode - $message';
}

/// Base client for the EVCC API.
class EvccClient {
  /// The base URL of the API.
  final String baseUrl;

  /// The HTTP client used for requests.
  final http.Client _httpClient;

  /// The authentication cookie.
  String? _authCookie;

  /// Creates a new EVCC API client.
  ///
  /// [baseUrl] - The base URL of the API.
  /// [httpClient] - An optional HTTP client to use for requests.
  EvccClient({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Returns whether the client is authenticated.
  bool get isAuthenticated => _authCookie != null;

  /// Sets the authentication cookie.
  @protected
  void setAuthCookie(String cookie) {
    _authCookie = cookie;
  }

  /// Clears the authentication cookie.
  @protected
  void clearAuthCookie() {
    _authCookie = null;
  }

  /// Builds a URI for the given path and query parameters.
  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl$path');

    if (queryParams == null || queryParams.isEmpty) {
      return uri;
    }

    final template = UriTemplate('${uri.toString()}{?params*}');
    return Uri.parse(template.expand({'params': queryParams}));
  }

  /// Creates headers for the request.
  Map<String, String> _createHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _authCookie != null) {
      headers['Cookie'] = _authCookie!;
    }

    return headers;
  }

  /// Handles the response from the API.
  Future<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json) converter,
  ) async {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) {
        return null as T;
      }

      try {
        final json = jsonDecode(body);
        return converter(json);
      } catch (e) {
        throw EvccApiException(statusCode, 'Failed to parse response: $e');
      }
    } else {
      throw EvccApiException(statusCode, 'Request failed: $body');
    }
  }

  /// Performs a GET request.
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? converter,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    final headers = _createHeaders(includeAuth: includeAuth);

    final response = await _httpClient.get(uri, headers: headers);
    return _handleResponse(response, converter ?? ((json) => json as T));
  }

  /// Performs a POST request.
  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? converter,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    final headers = _createHeaders(includeAuth: includeAuth);

    final encodedBody = body != null ? jsonEncode(body) : null;
    final response = await _httpClient.post(
      uri,
      headers: headers,
      body: encodedBody,
    );
    return _handleResponse(response, converter ?? ((json) => json as T));
  }

  /// Performs a PUT request.
  Future<T> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? converter,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    final headers = _createHeaders(includeAuth: includeAuth);

    final encodedBody = body != null ? jsonEncode(body) : null;
    final response = await _httpClient.put(
      uri,
      headers: headers,
      body: encodedBody,
    );
    return _handleResponse(response, converter ?? ((json) => json as T));
  }

  /// Performs a DELETE request.
  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? converter,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    final headers = _createHeaders(includeAuth: includeAuth);

    final response = await _httpClient.delete(uri, headers: headers);
    return _handleResponse(response, converter ?? ((json) => json as T));
  }

  /// Performs a PATCH request.
  Future<T> patch<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? converter,
    bool includeAuth = true,
  }) async {
    final uri = _buildUri(path, queryParams);
    final headers = _createHeaders(includeAuth: includeAuth);

    final encodedBody = body != null ? jsonEncode(body) : null;
    final response = await _httpClient.patch(
      uri,
      headers: headers,
      body: encodedBody,
    );
    return _handleResponse(response, converter ?? ((json) => json as T));
  }

  /// Closes the HTTP client.
  void close() {
    _httpClient.close();
  }
}
