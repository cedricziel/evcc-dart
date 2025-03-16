import '../client.dart';

/// Interface for Sessions API endpoints.
abstract class SessionsApi {
  /// Update vehicle of charging session.
  ///
  /// Update vehicle of charging session.
  Future<void> updateSession(int id, String vehicle, String loadpoint);

  /// Delete charging session.
  ///
  /// Delete charging session.
  Future<void> deleteSession(int id);

  /// Get charging sessions.
  ///
  /// Returns a list of charging sessions.
  Future<List<dynamic>> getSessions({
    String? format,
    String? lang,
    int? month,
    int? year,
  });
}

/// Implementation of the Sessions API.
class SessionsApiImpl implements SessionsApi {
  final EvccClient _client;

  /// Creates a new Sessions API implementation.
  SessionsApiImpl(this._client);

  @override
  Future<void> updateSession(int id, String vehicle, String loadpoint) async {
    await _client.put<void>(
      '/session/$id',
      body: {'vehicle': vehicle, 'loadpoint': loadpoint},
    );
  }

  @override
  Future<void> deleteSession(int id) async {
    await _client.delete<void>('/session/$id');
  }

  @override
  Future<List<dynamic>> getSessions({
    String? format,
    String? lang,
    int? month,
    int? year,
  }) async {
    final queryParams = <String, dynamic>{};

    if (format != null) queryParams['format'] = format;
    if (lang != null) queryParams['lang'] = lang;
    if (month != null) queryParams['month'] = month.toString();
    if (year != null) queryParams['year'] = year.toString();

    final response = await _client.get<Map<String, dynamic>>(
      '/sessions',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );

    return response['result'] as List<dynamic>;
  }
}
