# EVCC Dart API Client

A Dart client library for interacting with the [EVCC (Electric Vehicle Charge Controller)](https://evcc.io/) REST API. This package provides a type-safe way to control and monitor your EVCC installation from Dart applications.

## Features

- Complete API coverage for all EVCC endpoints
- Strongly typed models for request and response data
- Organized by API tags (Auth, General, Loadpoints, Vehicles, etc.)
- Authentication handling
- Error handling
- Comprehensive documentation

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  evcc_api: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Getting Started

Initialize the API client with the base URL of your EVCC installation:

```dart
import 'package:evcc_api/evcc_api.dart';

// Create an API client
final api = EvccApi(baseUrl: 'http://192.168.1.100:7070/api');
```

You can also provide a custom HTTP client if needed:

```dart
import 'package:http/http.dart' as http;

final customClient = http.Client();
final api = EvccApi(
  baseUrl: 'http://192.168.1.100:7070/api',
  httpClient: customClient,
);
```

## Usage Examples

### Authentication

```dart
// Login
await api.auth.login('your-password');

// Check authentication status
final isAuthenticated = await api.auth.getStatus();
print('Authenticated: $isAuthenticated');

// Logout
await api.auth.logout();
```

### System State

```dart
// Get complete system state
final state = await api.general.getState();
print('System state: $state');

// Get filtered state using JQ
final loadpoint = await api.general.getState(jqFilter: '.loadpoints[0]');
print('First loadpoint: $loadpoint');

// Health check
final health = await api.general.getHealth();
print('Health: $health');
```

### Loadpoint Management

```dart
// Set charging mode (off, now, minpv, pv)
await api.loadpoints.setMode(1, 'pv');

// Set charging limits
await api.loadpoints.setSocLimit(1, 80); // Limit to 80% SoC
await api.loadpoints.setEnergyLimit(1, 10000); // Limit to 10 kWh

// Control phases
await api.loadpoints.setPhases(1, 3); // Use 3 phases

// Set current limits
await api.loadpoints.setMinCurrent(1, 6); // Minimum 6A
await api.loadpoints.setMaxCurrent(1, 16); // Maximum 16A

// Enable/disable battery boost
await api.loadpoints.setBatteryBoost(1, true);

// Set smart charging cost limit
await api.loadpoints.setSmartCostLimit(1, 0.25); // 0.25 EUR/kWh or g/kWh
```

### Vehicle Operations

```dart
// Set vehicle SoC limit
await api.vehicles.setSocLimit('vehicle_1', 80);

// Set minimum SoC
await api.vehicles.setMinSoc('vehicle_1', 20);

// Create charging plan
await api.vehicles.setSocPlan(
  'vehicle_1',
  80,
  DateTime.now().add(Duration(hours: 8)).toIso8601String()
);

// Delete charging plan
await api.vehicles.deleteSocPlan('vehicle_1');

// Create repeating plan
final plan = RepeatingPlans(plans: [
  RepeatingPlan(
    active: true,
    soc: 80,
    time: '07:00',
    tz: 'Europe/Berlin',
    weekdays: [1, 2, 3, 4, 5], // Monday to Friday
  ),
]);
await api.vehicles.updateRepeatingPlans('vehicle_1', plan.toJson());
```

### Home Battery Control

```dart
// Set battery parameters
await api.battery.setBufferSoc(20);
await api.battery.setBufferStartSoc(15);
await api.battery.setPrioritySoc(50);

// Control battery discharge
await api.battery.setBatteryDischargeControl(true);

// Set grid charge limit
await api.battery.setBatteryGridChargeLimit(0.15); // 0.15 EUR/kWh or g/kWh

// Remove grid charge limit
await api.battery.removeBatteryGridChargeLimit();

// Set residual power
await api.battery.setResidualPower(100); // 100W
```

### Tariff Information

```dart
// Get grid tariff
final gridTariff = await api.tariffs.getTariff('grid');
print('Grid tariff: $gridTariff');

// Get feed-in tariff
final feedinTariff = await api.tariffs.getTariff('feedin');
print('Feed-in tariff: $feedinTariff');

// Get CO2 emissions
final co2Tariff = await api.tariffs.getTariff('co2');
print('CO2 emissions: $co2Tariff');
```

### Session Management

```dart
// Get charging sessions
final sessions = await api.sessions.getSessions();
print('Sessions: $sessions');

// Get sessions for a specific month and year
final monthSessions = await api.sessions.getSessions(
  month: 3,
  year: 2025,
);
print('March 2025 sessions: $monthSessions');

// Update session
await api.sessions.updateSession(
  1, // Session ID
  'vehicle_1', // Vehicle name
  'Garage', // Loadpoint name
);

// Delete session
await api.sessions.deleteSession(1);
```

### System Operations

```dart
// Get logs
final logs = await api.system.getLogs(
  level: 'INFO',
  count: 100,
);
print('Logs: $logs');

// Get log areas
final areas = await api.system.getLogAreas();
print('Log areas: $areas');

// Get telemetry status
final telemetryEnabled = await api.system.getTelemetryStatus();
print('Telemetry enabled: $telemetryEnabled');

// Enable/disable telemetry
await api.system.setTelemetry(true);

// Shutdown EVCC (use with caution)
// await api.system.shutdown();
```

### Error Handling

```dart
try {
  await api.auth.login('wrong-password');
} catch (e) {
  if (e is EvccApiException) {
    print('API Error: ${e.statusCode} - ${e.message}');
  } else {
    print('Error: $e');
  }
}
```

## API Reference

The API is organized into the following groups:

- **AuthApi**: Authentication and password management
- **GeneralApi**: System state and health checks
- **LoadpointsApi**: Charging point control and configuration
- **VehiclesApi**: Vehicle management and charging plans
- **HomeBatteryApi**: Home battery control and configuration
- **TariffsApi**: Electricity tariff and CO2 emission information
- **SessionsApi**: Charging session management
- **SystemApi**: System logs, telemetry, and shutdown

For detailed API documentation, refer to the [EVCC API documentation](https://docs.evcc.io/docs/reference/api).

## Contributing

Contributions are welcome! If you find a bug or want to add a feature, please open an issue or submit a pull request.

## License

This package is licensed under the MIT License - see the LICENSE file for details.
