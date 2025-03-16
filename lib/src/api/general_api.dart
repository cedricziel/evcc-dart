import '../client.dart';

/// Interface for General API endpoints.
abstract class GeneralApi {
  /// Health check.
  ///
  /// Returns 200 if the evcc loop runs as expected.
  Future<String> getHealth();

  /// System state.
  ///
  /// Returns the complete state of the system.
  Future<Map<String, dynamic>> getState({String? jqFilter});
}

/// Implementation of the General API.
class GeneralApiImpl implements GeneralApi {
  final EvccClient _client;

  /// Creates a new General API implementation.
  GeneralApiImpl(this._client);

  @override
  Future<String> getHealth() async {
    return await _client.get<String>(
      '/health',
      converter: (json) => json.toString(),
    );
  }

  @override
  Future<Map<String, dynamic>> getState({String? jqFilter}) async {
    final queryParams = jqFilter != null ? {'jq': jqFilter} : null;

    return await _client.get<Map<String, dynamic>>(
      '/state',
      queryParams: queryParams,
      converter: (json) => json['result'] as Map<String, dynamic>,
    );
  }
}
