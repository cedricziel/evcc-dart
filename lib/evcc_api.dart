/// EVCC API client for Dart
///
/// A Dart client for the EVCC (Electric Vehicle Charge Controller) API.
library;

import 'package:http/http.dart' as http;

export 'src/client.dart';
export 'src/models/models.dart';
export 'src/api/api.dart';
export 'src/websocket/websocket_client.dart';
export 'src/websocket/websocket_messages.dart';
export 'src/websocket/websocket_state.dart';

import 'src/client.dart';
import 'src/api/api.dart';
import 'src/websocket/websocket_client.dart';

/// Main entry point for the EVCC API client.
class EvccApi {
  /// The underlying HTTP client
  final EvccClient client;

  /// WebSocket client for real-time updates
  late final EvccWebSocketClient ws;

  /// Auth-related endpoints
  late final AuthApi auth;

  /// General endpoints
  late final GeneralApi general;

  /// Loadpoints-related endpoints
  late final LoadpointsApi loadpoints;

  /// Vehicles-related endpoints
  late final VehiclesApi vehicles;

  /// Home Battery-related endpoints
  late final HomeBatteryApi battery;

  /// Tariffs-related endpoints
  late final TariffsApi tariffs;

  /// Sessions-related endpoints
  late final SessionsApi sessions;

  /// System-related endpoints
  late final SystemApi system;

  /// Creates a new EVCC API client.
  ///
  /// [baseUrl] - The base URL of the EVCC API. Defaults to 'https://demo.evcc.io/api'.
  /// [httpClient] - An optional HTTP client to use for requests.
  /// [wsUrl] - The WebSocket URL. If not provided, it will be derived from the base URL.
  EvccApi({
    String baseUrl = 'https://demo.evcc.io/api',
    http.Client? httpClient,
    String? wsUrl,
  }) : client = EvccClient(baseUrl: baseUrl, httpClient: httpClient) {
    auth = AuthApiImpl(client);
    general = GeneralApiImpl(client);
    loadpoints = LoadpointsApiImpl(client);
    vehicles = VehiclesApiImpl(client);
    battery = HomeBatteryApiImpl(client);
    tariffs = TariffsApiImpl(client);
    sessions = SessionsApiImpl(client);
    system = SystemApiImpl(client);

    // Initialize WebSocket client
    final wsEndpoint = wsUrl ?? _deriveWebSocketUrl(baseUrl);
    ws = EvccWebSocketClient(wsEndpoint);
  }

  /// Derives the WebSocket URL from the base URL.
  ///
  /// Example: 'http://192.168.1.100:7070/api' -> 'ws://192.168.1.100:7070/ws'
  String _deriveWebSocketUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return '$scheme://${uri.authority}/ws';
  }

  /// Closes the API client and releases resources.
  Future<void> close() async {
    await ws.close();
    client.close();
  }
}
