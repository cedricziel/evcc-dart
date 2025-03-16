import 'package:evcc_api/evcc_api.dart';

/// This example demonstrates how to manage vehicles using the EVCC API client.
void main() async {
  // Initialize the API client with your EVCC instance URL
  final api = EvccApi(baseUrl: 'http://192.168.1.100:7070/api');

  try {
    // Login if required
    await api.auth.login('your-password');

    // Set vehicle SoC limit
    await api.vehicles.setSocLimit('vehicle_1', 80);
    print('Set vehicle_1 SoC limit to 80%');

    // Set minimum SoC for fast charging
    await api.vehicles.setMinSoc('vehicle_1', 20);
    print('Set vehicle_1 minimum SoC to 20%');

    // Create a SoC-based charging plan
    // Charge to 80% by 7:00 AM tomorrow
    final now = DateTime.now();
    final tomorrow7am = DateTime(
      now.year,
      now.month,
      now.day + 1,
      7, // hour
      0, // minute
      0, // second
    );

    await api.vehicles.setSocPlan(
      'vehicle_1',
      80,
      tomorrow7am.toIso8601String(),
    );
    print('Created charging plan: 80% by ${tomorrow7am.toIso8601String()}');

    // Create a repeating plan for weekdays
    final plan = RepeatingPlans(
      plans: [
        RepeatingPlan(
          active: true,
          soc: 80,
          time: '07:00',
          tz: 'Europe/Berlin',
          weekdays: [1, 2, 3, 4, 5], // Monday to Friday
        ),
        RepeatingPlan(
          active: true,
          soc: 90,
          time: '09:00',
          tz: 'Europe/Berlin',
          weekdays: [6, 0], // Saturday and Sunday
        ),
      ],
    );

    await api.vehicles.updateRepeatingPlans('vehicle_1', plan.toJson());
    print('Created repeating charging plans');

    // Delete a charging plan when no longer needed
    // await api.vehicles.deleteSocPlan('vehicle_1');
    // print('Deleted charging plan');

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
