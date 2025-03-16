import 'package:evcc_api/evcc_api.dart';

/// This example demonstrates how to perform system operations using the EVCC API client.
void main() async {
  // Initialize the API client with your EVCC instance URL
  final api = EvccApi(baseUrl: 'http://192.168.1.100:7070/api');

  try {
    // Login if required
    await api.auth.login('your-password');

    // Get logs with INFO level
    final logs = await api.system.getLogs(level: 'INFO', count: 100);
    print('Logs: ${logs.length} entries');

    // Get available log areas
    final areas = await api.system.getLogAreas();
    print('Log areas: $areas');

    // Get logs for a specific area
    if (areas.isNotEmpty) {
      final areaLogs = await api.system.getLogs(
        areas: [areas[0]],
        level: 'INFO',
        count: 50,
      );
      print('Logs for ${areas[0]}: ${areaLogs.length} entries');
    }

    // Get telemetry status
    final telemetryEnabled = await api.system.getTelemetryStatus();
    print('Telemetry enabled: $telemetryEnabled');

    // Enable telemetry (requires sponsorship)
    // await api.system.setTelemetry(true);
    // print('Enabled telemetry');

    // Disable telemetry
    // await api.system.setTelemetry(false);
    // print('Disabled telemetry');

    // Shutdown EVCC (use with caution)
    // This will terminate the EVCC instance
    // The underlying system (docker, systemd, etc.) is expected to restart it
    // await api.system.shutdown();
    // print('Shutting down EVCC');

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
