import 'package:evcc_api/evcc_api.dart';

/// This example demonstrates how to manage home battery using the EVCC API client.
void main() async {
  // Initialize the API client with your EVCC instance URL
  final api = EvccApi(baseUrl: 'http://192.168.1.100:7070/api');

  try {
    // Login if required
    await api.auth.login('your-password');

    // Set battery buffer SoC
    // This is the minimum SoC that the battery should maintain
    await api.battery.setBufferSoc(20);
    print('Set battery buffer SoC to 20%');

    // Set battery buffer start SoC
    // This is the SoC at which the buffer starts to be active
    await api.battery.setBufferStartSoc(15);
    print('Set battery buffer start SoC to 15%');

    // Set battery priority SoC
    // This is the SoC at which the battery gets priority over vehicle charging
    await api.battery.setPrioritySoc(50);
    print('Set battery priority SoC to 50%');

    // Control battery discharge during vehicle fast charging
    await api.battery.setBatteryDischargeControl(true);
    print('Enabled battery discharge control');

    // Set grid charge limit based on electricity price
    // Only charge battery from grid when price is below 0.15 EUR/kWh
    await api.battery.setBatteryGridChargeLimit(0.15);
    print('Set battery grid charge limit to 0.15 EUR/kWh');

    // Set residual power
    // This is the target operating point of the control loop
    await api.battery.setResidualPower(100); // 100W
    print('Set residual power to 100W');

    // Remove grid charge limit when no longer needed
    // await api.battery.removeBatteryGridChargeLimit();
    // print('Removed battery grid charge limit');

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
