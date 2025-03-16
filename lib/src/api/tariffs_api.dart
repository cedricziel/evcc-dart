import '../client.dart';

/// Interface for Tariffs API endpoints.
abstract class TariffsApi {
  /// Get tariff information.
  ///
  /// Returns the prices or emission values for the upcoming hours.
  Future<Map<String, dynamic>> getTariff(String type);
}

/// Implementation of the Tariffs API.
class TariffsApiImpl implements TariffsApi {
  final EvccClient _client;

  /// Creates a new Tariffs API implementation.
  TariffsApiImpl(this._client);

  @override
  Future<Map<String, dynamic>> getTariff(String type) async {
    final response = await _client.get<Map<String, dynamic>>('/tariff/$type');
    return response['result'] as Map<String, dynamic>;
  }
}
