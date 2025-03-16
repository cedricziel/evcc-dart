import '../client.dart';

/// Interface for Vehicles API endpoints.
abstract class VehiclesApi {
  /// Set SoC limit.
  ///
  /// Charging will stop when this SoC is reached.
  Future<Map<String, dynamic>> setSocLimit(String name, num soc);

  /// Set minimum SoC.
  ///
  /// Vehicle will be fast-charged until this SoC is reached.
  Future<Map<String, dynamic>> setMinSoc(String name, num soc);

  /// Update repeating plans.
  ///
  /// Updates the repeating charging plan.
  Future<Map<String, dynamic>> updateRepeatingPlans(
    String name,
    Map<String, dynamic> plans,
  );

  /// Delete a SoC-based charging plan.
  ///
  /// Deletes the charging plan.
  Future<void> deleteSocPlan(String name);

  /// Set a SoC-based charging plan.
  ///
  /// Creates a charging plan with fixed time and SoC target.
  Future<Map<String, dynamic>> setSocPlan(
    String name,
    num soc,
    String timestamp,
  );
}

/// Implementation of the Vehicles API.
class VehiclesApiImpl implements VehiclesApi {
  final EvccClient _client;

  /// Creates a new Vehicles API implementation.
  VehiclesApiImpl(this._client);

  @override
  Future<Map<String, dynamic>> setSocLimit(String name, num soc) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/vehicles/$name/limitsoc/$soc',
    );
    return response['result'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> setMinSoc(String name, num soc) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/vehicles/$name/minsoc/$soc',
    );
    return response['result'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateRepeatingPlans(
    String name,
    Map<String, dynamic> plans,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/vehicles/$name/plan/repeating',
      body: plans,
    );
    return response['result'] as Map<String, dynamic>;
  }

  @override
  Future<void> deleteSocPlan(String name) async {
    await _client.delete<void>('/vehicles/$name/plan/soc');
  }

  @override
  Future<Map<String, dynamic>> setSocPlan(
    String name,
    num soc,
    String timestamp,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/vehicles/$name/plan/soc/$soc/$timestamp',
    );
    return response['result'] as Map<String, dynamic>;
  }
}
