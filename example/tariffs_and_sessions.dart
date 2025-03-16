import 'package:evcc_api/evcc_api.dart';

/// This example demonstrates how to work with tariffs and charging sessions.
void main() async {
  // Initialize the API client with your EVCC instance URL
  final api = EvccApi(baseUrl: 'http://192.168.1.100:7070/api');

  try {
    // Login if required
    await api.auth.login('your-password');

    // Get grid tariff information
    final gridTariff = await api.tariffs.getTariff('grid');
    print('Grid tariff: $gridTariff');

    // Get feed-in tariff information
    final feedinTariff = await api.tariffs.getTariff('feedin');
    print('Feed-in tariff: $feedinTariff');

    // Get CO2 emissions information
    final co2Tariff = await api.tariffs.getTariff('co2');
    print('CO2 emissions: $co2Tariff');

    // Get charging sessions
    final sessions = await api.sessions.getSessions();
    print('All charging sessions: $sessions');

    // Get sessions for a specific month and year
    final marchSessions = await api.sessions.getSessions(month: 3, year: 2025);
    print('March 2025 sessions: $marchSessions');

    // Get sessions in CSV format
    final csvSessions = await api.sessions.getSessions(format: 'csv');
    print('Sessions in CSV format: $csvSessions');

    // Update a session (assign to a different vehicle)
    if (sessions.isNotEmpty) {
      final sessionId = int.parse(sessions[0]['id'].toString());
      await api.sessions.updateSession(
        sessionId,
        'vehicle_1', // Vehicle name
        'Garage', // Loadpoint name
      );
      print('Updated session $sessionId');
    }

    // Delete a session
    // if (sessions.isNotEmpty) {
    //   final sessionId = int.parse(sessions[0]['id'].toString());
    //   await api.sessions.deleteSession(sessionId);
    //   print('Deleted session $sessionId');
    // }

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
