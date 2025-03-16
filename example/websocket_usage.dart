import 'dart:async';
import 'package:evcc_api/evcc_api.dart';

/// This example demonstrates how to use the EVCC WebSocket API client.
/// It connects to a local EVCC instance at 192.168.178.40:7070.
void main() async {
  // Initialize the API client with the local EVCC instance URL
  final api = EvccApi(baseUrl: 'http://192.168.178.40:7070/api');

  // You can also provide a specific WebSocket URL if needed
  // final api = EvccApi(
  //   baseUrl: 'http://192.168.178.40:7070/api',
  //   wsUrl: 'ws://192.168.178.40:7070/ws',
  // );

  print('Connecting to WebSocket...');

  // Listen for connection state changes
  api.ws.connectionStateStream.listen((state) {
    print('WebSocket connection state: $state');
  });

  try {
    // Connect to the WebSocket
    await api.ws.connect();
    print('Connected to WebSocket');

    // Listen for state updates
    api.ws.state.updates.listen((state) {
      print('State updated:');

      // Print system overview
      print('System Overview:');
      print('  Site: ${state['siteTitle']}');
      print('  Version: ${state['version']}');
      print('  Currency: ${state['currency']}');
      print('  PV Power: ${state['pvPower']} W');
      print('  Home Power: ${state['homePower']} W');
      print('  Battery SoC: ${state['batterySoc']}%');

      // Print loadpoint information
      final loadpointCount = api.ws.state.loadpointCount;
      print('Loadpoints ($loadpointCount):');
      for (var i = 0; i < loadpointCount; i++) {
        final props = api.ws.state.getLoadpointProperties(i);
        print('  Loadpoint $i:');
        props.forEach((key, value) {
          print('    $key: $value');
        });
      }

      // Print tariff information
      print('Tariffs:');
      if (state['tariffGrid'] != null) {
        print('  Grid: ${state['tariffGrid']} ${state['currency']}/kWh');
      }
      if (state['tariffCo2'] != null) {
        print('  CO2: ${state['tariffCo2']} g/kWh');
      }
      if (state['tariffSolar'] != null) {
        print('  Solar: ${state['tariffSolar']} ${state['currency']}/kWh');
      }

      // Print green share information
      if (state['greenShareHome'] != null) {
        print('  Green Share Home: ${(state['greenShareHome'] as num) * 100}%');
      }
      if (state['greenShareLoadpoints'] != null) {
        print(
          '  Green Share Loadpoints: ${(state['greenShareLoadpoints'] as num) * 100}%',
        );
      }
    });

    // You can also use the helper getters on the state object
    api.ws.state.updates.listen((_) {
      print('\nUsing helper getters:');
      print('  PV Power: ${api.ws.state.pvPower} W');
      print('  Home Power: ${api.ws.state.homePower} W');
      print('  Battery SoC: ${api.ws.state.batterySoc}%');
      print('  Site Title: ${api.ws.state.siteTitle}');
      print('  Currency: ${api.ws.state.currency}');
    });

    // For specific updates, you can listen to the raw message stream
    api.ws.messages.where((msg) => msg.containsKey('pvPower')).listen((msg) {
      print('\nPV Power update: ${msg['pvPower']} W');
    });

    api.ws.messages.where((msg) => msg.containsKey('homePower')).listen((msg) {
      print('Home Power update: ${msg['homePower']} W');
    });

    api.ws.messages.where((msg) => msg.containsKey('batterySoc')).listen((msg) {
      print('Battery SoC update: ${msg['batterySoc']}%');
    });

    // Keep the program running for 5 minutes
    print('Listening for messages for 5 minutes...');
    await Future.delayed(Duration(minutes: 5));

    // Clean up
    await api.ws.disconnect();
    await api.close();
    print('Disconnected from WebSocket');
  } catch (e) {
    print('Error: $e');
    await api.close();
  }
}

/// Example of tracking state over time
class StateTracker {
  // Use the built-in state cache
  final EvccWebSocketState state;

  StateTracker(this.state);

  void trackState() {
    state.updates.listen((currentState) {
      printCurrentState();
    });
  }

  void printCurrentState() {
    print('Current State:');
    print('  PV Power: ${state.pvPower ?? "unknown"} W');
    print('  Home Power: ${state.homePower ?? "unknown"} W');

    // Print forecast data if available
    if (state.current.containsKey('forecast')) {
      final forecast = state.current['forecast'] as Map<String, dynamic>;
      print('  Forecast:');

      if (forecast.containsKey('grid') &&
          forecast['grid'] is List &&
          (forecast['grid'] as List).isNotEmpty) {
        final grid = forecast['grid'] as List;
        print('    Current Grid Price: ${grid.first['price']} EUR/kWh');
      }

      if (forecast.containsKey('co2') &&
          forecast['co2'] is List &&
          (forecast['co2'] as List).isNotEmpty) {
        final co2 = forecast['co2'] as List;
        print('    Current CO2 Intensity: ${co2.first['price']} g/kWh');
      }

      if (forecast.containsKey('solar') &&
          forecast['solar'] is Map<String, dynamic> &&
          forecast['solar'].containsKey('today')) {
        final solar = forecast['solar'] as Map<String, dynamic>;
        final today = solar['today'] as Map<String, dynamic>;
        print('    Solar Today: ${today['energy']} Wh');
      }
    }

    // Print green share data if available
    if (state.greenShareHome != null || state.greenShareLoadpoints != null) {
      print('  Green Share:');
      if (state.greenShareHome != null) {
        print('    Home: ${(state.greenShareHome! * 100).toStringAsFixed(1)}%');
      }
      if (state.greenShareLoadpoints != null) {
        print(
          '    Loadpoints: ${(state.greenShareLoadpoints! * 100).toStringAsFixed(1)}%',
        );
      }
    }

    // Print tariff data if available
    if (state.tariffGrid != null ||
        state.tariffCo2 != null ||
        state.tariffSolar != null ||
        state.tariffPriceHome != null ||
        state.tariffCo2Home != null ||
        state.tariffPriceLoadpoints != null ||
        state.tariffCo2Loadpoints != null) {
      print('  Tariffs:');
      if (state.tariffGrid != null) {
        print('    Grid: ${state.tariffGrid} EUR/kWh');
      }
      if (state.tariffCo2 != null) {
        print('    CO2: ${state.tariffCo2} g/kWh');
      }
      if (state.tariffSolar != null) {
        print('    Solar: ${state.tariffSolar} EUR/kWh');
      }
      if (state.tariffPriceHome != null) {
        print('    Home Price: ${state.tariffPriceHome} EUR/kWh');
      }
      if (state.tariffCo2Home != null) {
        print('    Home CO2: ${state.tariffCo2Home} g/kWh');
      }
      if (state.tariffPriceLoadpoints != null) {
        print('    Loadpoints Price: ${state.tariffPriceLoadpoints} EUR/kWh');
      }
      if (state.tariffCo2Loadpoints != null) {
        print('    Loadpoints CO2: ${state.tariffCo2Loadpoints} g/kWh');
      }
    }

    // Print battery data if available
    if (state.batterySoc != null ||
        state.batteryPower != null ||
        state.batteryEnergy != null) {
      print('  Battery:');
      if (state.batterySoc != null) {
        print('    SoC: ${state.batterySoc!.toStringAsFixed(1)}%');
      }
      if (state.batteryPower != null) {
        print('    Power: ${state.batteryPower} W');
      }
      if (state.batteryEnergy != null) {
        print('    Energy: ${state.batteryEnergy} Wh');
      }
    }

    // Print loadpoint data
    print('  Loadpoints:');
    for (var i = 0; i < state.loadpointCount; i++) {
      final props = state.getLoadpointProperties(i);
      print('    Loadpoint $i:');
      for (final prop in props.entries) {
        print('      ${prop.key}: ${prop.value}');
      }
    }
    print('');
  }
}

/// Example of using the state cache with specific data types
void demonstrateStateUsage(EvccWebSocketClient ws) {
  // Create a state tracker
  final tracker = StateTracker(ws.state);
  tracker.trackState();

  // Listen for specific state changes
  ws.state.updates.listen((state) {
    if (state.containsKey('pvPower')) {
      print('PV Power changed: ${state['pvPower']} W');
    }
  });

  // Access specific properties directly
  ws.state.updates.listen((_) {
    if (ws.state.pvPower != null && ws.state.pvPower! > 1000) {
      print('High PV production: ${ws.state.pvPower} W');
    }

    if (ws.state.batterySoc != null && ws.state.batterySoc! < 20) {
      print('Low battery warning: ${ws.state.batterySoc}%');
    }
  });
}
