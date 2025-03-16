import 'package:evcc_api/evcc_api.dart';

/// This example demonstrates how to manage loadpoints using the EVCC API client.
void main() async {
  // Initialize the API client with your EVCC instance URL
  final api = EvccApi(baseUrl: 'http://192.168.1.100:7070/api');

  try {
    // Login if required
    await api.auth.login('your-password');

    // Get the first loadpoint state
    final loadpointState = await api.general.getState(
      jqFilter: '.loadpoints[0]',
    );
    print('Loadpoint state: $loadpointState');

    // Set charging mode to PV (solar charging)
    await api.loadpoints.setMode(1, 'pv');
    print('Set charging mode to PV');

    // Set charging limits
    await api.loadpoints.setSocLimit(1, 80);
    print('Set SoC limit to 80%');

    // Set current limits
    await api.loadpoints.setMinCurrent(1, 6);
    await api.loadpoints.setMaxCurrent(1, 16);
    print('Set current limits: min 6A, max 16A');

    // Set phases
    await api.loadpoints.setPhases(1, 3);
    print('Set to 3-phase charging');

    // Enable battery boost
    await api.loadpoints.setBatteryBoost(1, true);
    print('Enabled battery boost');

    // Set smart charging cost limit
    await api.loadpoints.setSmartCostLimit(1, 0.25);
    print('Set smart charging cost limit to 0.25 EUR/kWh');

    // Get charging plan
    final plan = await api.loadpoints.getPlan(1);
    print('Current charging plan: $plan');

    // Create a charging plan
    await api.loadpoints.setEnergyPlan(
      1,
      10000, // 10 kWh
      DateTime.now().add(Duration(hours: 8)).toIso8601String(),
    );
    print('Created energy-based charging plan');

    // Assign a vehicle to the loadpoint
    await api.loadpoints.assignVehicle(1, 'vehicle_1');
    print('Assigned vehicle_1 to loadpoint 1');

    // Logout when done
    await api.auth.logout();
  } catch (e) {
    if (e is EvccApiException) {
      print('API Error: ${e.statusCode} - ${e.message}');
    } else {
      print('Error: $e');
    }
  }
}
