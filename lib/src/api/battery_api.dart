import '../client.dart';

/// Interface for Home Battery API endpoints.
abstract class HomeBatteryApi {
  /// Control battery-discharge.
  ///
  /// Prevent home battery discharge during vehicle fast charging.
  Future<bool> setBatteryDischargeControl(bool enable);

  /// Remove battery grid charge limit.
  ///
  /// Remove battery grid charge limit.
  Future<void> removeBatteryGridChargeLimit();

  /// Set battery grid charge limit.
  ///
  /// Charge home battery from grid when price or emissions are below the threshold.
  Future<num> setBatteryGridChargeLimit(num cost);

  /// Set battery buffer SoC.
  ///
  /// Set battery buffer SoC.
  Future<num> setBufferSoc(num soc);

  /// Set battery buffer start SoC.
  ///
  /// Set battery buffer start SoC.
  Future<num> setBufferStartSoc(num soc);

  /// Set battery priority SoC.
  ///
  /// Set battery priority SoC.
  Future<num> setPrioritySoc(num soc);

  /// Set grid residual power.
  ///
  /// Sets target operating point of the control loop.
  Future<num> setResidualPower(num power);
}

/// Implementation of the Home Battery API.
class HomeBatteryApiImpl implements HomeBatteryApi {
  final EvccClient _client;

  /// Creates a new Home Battery API implementation.
  HomeBatteryApiImpl(this._client);

  @override
  Future<bool> setBatteryDischargeControl(bool enable) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/batterydischargecontrol/${enable ? 'true' : 'false'}',
    );
    return response['result'] as bool;
  }

  @override
  Future<void> removeBatteryGridChargeLimit() async {
    await _client.delete<void>('/batterygridchargelimit');
  }

  @override
  Future<num> setBatteryGridChargeLimit(num cost) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/batterygridchargelimit/$cost',
    );
    return response['result'] as num;
  }

  @override
  Future<num> setBufferSoc(num soc) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/buffersoc/$soc',
    );
    return response['result'] as num;
  }

  @override
  Future<num> setBufferStartSoc(num soc) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/bufferstartsoc/$soc',
    );
    return response['result'] as num;
  }

  @override
  Future<num> setPrioritySoc(num soc) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/prioritysoc/$soc',
    );
    return response['result'] as num;
  }

  @override
  Future<num> setResidualPower(num power) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/residualpower/$power',
    );
    return response['result'] as num;
  }
}
