/// EVCC API client for Dart
///
/// A Dart client for the EVCC (Electric Vehicle Charge Controller) API.
library;

import 'package:http/http.dart' as http;

export 'src/client.dart';
export 'src/models/models.dart';
export 'src/api/api.dart';

import 'src/client.dart';
import 'src/api/api.dart';

/// Main entry point for the EVCC API client.
class EvccApi {
  /// The underlying HTTP client
  final EvccClient client;

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
  EvccApi({
    String baseUrl = 'https://demo.evcc.io/api',
    http.Client? httpClient,
  }) : client = EvccClient(baseUrl: baseUrl, httpClient: httpClient) {
    auth = AuthApiImpl(client);
    general = GeneralApiImpl(client);
    loadpoints = LoadpointsApiImpl(client);
    vehicles = VehiclesApiImpl(client);
    battery = HomeBatteryApiImpl(client);
    tariffs = TariffsApiImpl(client);
    sessions = SessionsApiImpl(client);
    system = SystemApiImpl(client);
  }
}
