import '../client.dart';

/// Interface for System API endpoints.
abstract class SystemApi {
  /// Get logs.
  ///
  /// Returns the latest log lines.
  Future<List<String>> getLogs({
    List<String>? areas,
    String? level,
    int? count,
    String? format,
  });

  /// Get list of all log areas.
  ///
  /// Returns a list of all log areas.
  Future<List<String>> getLogAreas();

  /// Shutdown evcc.
  ///
  /// Shuts down the evcc instance.
  Future<void> shutdown();

  /// Get telemetry status.
  ///
  /// Returns the current telemetry status.
  Future<bool> getTelemetryStatus();

  /// Enable/disable telemetry.
  ///
  /// Enable or disable telemetry.
  Future<bool> setTelemetry(bool enable);
}

/// Implementation of the System API.
class SystemApiImpl implements SystemApi {
  final EvccClient _client;

  /// Creates a new System API implementation.
  SystemApiImpl(this._client);

  @override
  Future<List<String>> getLogs({
    List<String>? areas,
    String? level,
    int? count,
    String? format,
  }) async {
    final queryParams = <String, dynamic>{};

    if (areas != null && areas.isNotEmpty) queryParams['areas'] = areas;
    if (level != null) queryParams['level'] = level;
    if (count != null) queryParams['count'] = count.toString();
    if (format != null) queryParams['format'] = format;

    final response = await _client.get<Map<String, dynamic>>(
      '/system/log',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );

    final result = response['result'] as List<dynamic>;
    return result.map((item) => item.toString()).toList();
  }

  @override
  Future<List<String>> getLogAreas() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/system/log/areas',
    );

    final result = response['result'] as List<dynamic>;
    return result.map((item) => item.toString()).toList();
  }

  @override
  Future<void> shutdown() async {
    await _client.post<void>('/system/shutdown');
  }

  @override
  Future<bool> getTelemetryStatus() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/settings/telemetry',
    );
    return response['result'] as bool;
  }

  @override
  Future<bool> setTelemetry(bool enable) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/settings/telemetry/${enable ? 'true' : 'false'}',
    );
    return response['result'] as bool;
  }
}
