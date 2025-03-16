import 'package:evcc_api/evcc_api.dart';

/// This example demonstrates basic usage of the EVCC API client.
void main() async {
  // Initialize the API client with your EVCC instance URL
  final api = EvccApi(baseUrl: 'http://192.168.1.100:7070/api');

  try {
    // Check if authentication is required
    final isAuthenticated = await api.auth.getStatus();
    print('Authentication status: $isAuthenticated');

    // If authentication is required, login
    if (!isAuthenticated) {
      await api.auth.login('your-password');
      print('Logged in successfully');
    }

    // Get system health
    final health = await api.general.getHealth();
    print('System health: $health');

    // Get system state
    final state = await api.general.getState();
    print('System state: $state');

    // Logout when done
    if (isAuthenticated) {
      await api.auth.logout();
      print('Logged out successfully');
    }
  } catch (e) {
    if (e is EvccApiException) {
      print('API Error: ${e.statusCode} - ${e.message}');
    } else {
      print('Error: $e');
    }
  }
}
