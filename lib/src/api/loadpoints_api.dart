import '../client.dart';

/// Interface for Loadpoints API endpoints.
abstract class LoadpointsApi {
  /// Set battery boost.
  ///
  /// Enables or disables battery boost.
  Future<bool> setBatteryBoost(int id, bool enable);

  /// Disable threshold-delay.
  ///
  /// Specifies the delay before charging stops in solar mode.
  Future<int> setDisableDelay(int id, int delay);

  /// Disable threshold.
  ///
  /// Specifies the grid draw power to stop charging in solar mode.
  Future<num> setDisableThreshold(int id, num threshold);

  /// Enable threshold-delay.
  ///
  /// Specifies the delay before charging starts in solar mode.
  Future<int> setEnableDelay(int id, int delay);

  /// Enable threshold.
  ///
  /// Specifies the available surplus power to start charging in solar mode.
  Future<num> setEnableThreshold(int id, num threshold);

  /// Update energy limit.
  ///
  /// Updates the energy limit of the loadpoint.
  Future<num> setEnergyLimit(int id, num power);

  /// Update limit SoC.
  ///
  /// Updates the SoC limit of the loadpoint.
  Future<num> setSocLimit(int id, num soc);

  /// Update maximum current.
  ///
  /// Updates the maximum current of the loadpoint.
  Future<num> setMaxCurrent(int id, num current);

  /// Update minimum current.
  ///
  /// Updates the minimum current of the loadpoint.
  Future<num> setMinCurrent(int id, num current);

  /// Update charge mode.
  ///
  /// Changes the charging behavior of the loadpoint.
  Future<String> setMode(int id, String mode);

  /// Update allowed phases.
  ///
  /// Updates the allowed phases of the loadpoint.
  Future<num> setPhases(int id, int phases);

  /// Get plan rates.
  ///
  /// Returns the current charging plan for this loadpoint.
  Future<Map<String, dynamic>> getPlan(int id);

  /// Delete energy-based charging plan.
  ///
  /// Deletes the charging plan.
  Future<void> deleteEnergyPlan(int id);

  /// Set energy-based charging plan.
  ///
  /// Creates a charging plan with fixed time and energy target.
  Future<Map<String, dynamic>> setEnergyPlan(
    int id,
    num power,
    String timestamp,
  );

  /// Get repeating plan preview.
  ///
  /// Simulates a repeating charging plan and returns the result.
  Future<Map<String, dynamic>> getRepeatingPlanPreview(
    int id,
    num soc,
    List<int> weekdays,
    String hourMinuteTime,
    String timezone,
  );

  /// Get preview of a charging plan.
  ///
  /// Simulates a charging plan and returns the result.
  Future<Map<String, dynamic>> getStaticPlanPreview(
    int id,
    String type,
    num goal,
    String timestamp,
  );

  /// Set priority.
  ///
  /// Sets the priority of the loadpoint.
  Future<int> setPriority(int id, int priority);

  /// Remove smart charging cost limit.
  ///
  /// Removes the price or emission limit for fast-charging with grid energy.
  Future<void> removeSmartCostLimit(int id);

  /// Set smart charging cost limit.
  ///
  /// Sets the price or emission limit for fast-charging with grid energy.
  Future<num> setSmartCostLimit(int id, num cost);

  /// Delete vehicle.
  ///
  /// Removes the association of a vehicle to the loadpoint.
  Future<void> deleteVehicle(int id);

  /// Start vehicle detection.
  ///
  /// Starts the automatic vehicle detection process.
  Future<void> startVehicleDetection(int id);

  /// Assign vehicle.
  ///
  /// Changes the association of a vehicle to the loadpoint.
  Future<Map<String, dynamic>> assignVehicle(int id, String name);

  /// Remove smart charging cost limit for all loadpoints.
  ///
  /// Convenience method to remove limit for all loadpoints at once.
  Future<void> removeAllSmartCostLimits();

  /// Set smart charging cost limit for all loadpoints.
  ///
  /// Convenience method to set smart charging cost limit for all loadpoints at once.
  Future<num> setAllSmartCostLimits(num cost);
}

/// Implementation of the Loadpoints API.
class LoadpointsApiImpl implements LoadpointsApi {
  final EvccClient _client;

  /// Creates a new Loadpoints API implementation.
  LoadpointsApiImpl(this._client);

  @override
  Future<bool> setBatteryBoost(int id, bool enable) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/batteryboost/${enable ? 'true' : 'false'}',
    );
    return response['result'] as bool;
  }

  @override
  Future<int> setDisableDelay(int id, int delay) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/disable/delay/$delay',
    );
    return response['result'] as int;
  }

  @override
  Future<num> setDisableThreshold(int id, num threshold) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/disable/threshold/$threshold',
    );
    return response['result'] as num;
  }

  @override
  Future<int> setEnableDelay(int id, int delay) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/enable/delay/$delay',
    );
    return response['result'] as int;
  }

  @override
  Future<num> setEnableThreshold(int id, num threshold) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/enable/threshold/$threshold',
    );
    return response['result'] as num;
  }

  @override
  Future<num> setEnergyLimit(int id, num power) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/limitenergy/$power',
    );
    return response['result'] as num;
  }

  @override
  Future<num> setSocLimit(int id, num soc) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/limitsoc/$soc',
    );
    return response['result'] as num;
  }

  @override
  Future<num> setMaxCurrent(int id, num current) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/maxcurrent/$current',
    );
    return response['result'] as num;
  }

  @override
  Future<num> setMinCurrent(int id, num current) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/mincurrent/$current',
    );
    return response['result'] as num;
  }

  @override
  Future<String> setMode(int id, String mode) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/mode/$mode',
    );
    return response['result'] as String;
  }

  @override
  Future<num> setPhases(int id, int phases) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/phases/$phases',
    );
    return response['result'] as num;
  }

  @override
  Future<Map<String, dynamic>> getPlan(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/loadpoints/$id/plan',
    );
    return response['result'] as Map<String, dynamic>;
  }

  @override
  Future<void> deleteEnergyPlan(int id) async {
    await _client.delete<void>('/loadpoints/$id/plan/energy');
  }

  @override
  Future<Map<String, dynamic>> setEnergyPlan(
    int id,
    num power,
    String timestamp,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/plan/energy/$power/$timestamp',
    );
    return response['result'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getRepeatingPlanPreview(
    int id,
    num soc,
    List<int> weekdays,
    String hourMinuteTime,
    String timezone,
  ) async {
    final weekdaysStr = weekdays.join(',');
    final response = await _client.get<Map<String, dynamic>>(
      '/loadpoints/$id/plan/repeating/preview/$soc/$weekdaysStr/$hourMinuteTime/$timezone',
    );
    return response['result'] as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getStaticPlanPreview(
    int id,
    String type,
    num goal,
    String timestamp,
  ) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/loadpoints/$id/plan/static/preview/$type/$goal/$timestamp',
    );
    return response['result'] as Map<String, dynamic>;
  }

  @override
  Future<int> setPriority(int id, int priority) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/priority/$priority',
    );
    return response['result'] as int;
  }

  @override
  Future<void> removeSmartCostLimit(int id) async {
    await _client.delete<void>('/loadpoints/$id/smartcostlimit');
  }

  @override
  Future<num> setSmartCostLimit(int id, num cost) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/smartcostlimit/$cost',
    );
    return response['result'] as num;
  }

  @override
  Future<void> deleteVehicle(int id) async {
    await _client.delete<void>('/loadpoints/$id/vehicle');
  }

  @override
  Future<void> startVehicleDetection(int id) async {
    await _client.patch<void>('/loadpoints/$id/vehicle');
  }

  @override
  Future<Map<String, dynamic>> assignVehicle(int id, String name) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/loadpoints/$id/vehicle/$name',
    );
    return response['result'] as Map<String, dynamic>;
  }

  @override
  Future<void> removeAllSmartCostLimits() async {
    await _client.delete<void>('/smartcostlimit');
  }

  @override
  Future<num> setAllSmartCostLimits(num cost) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/smartcostlimit/$cost',
    );
    return response['result'] as num;
  }
}
