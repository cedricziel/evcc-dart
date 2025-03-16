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

    // Listen for all messages
    final subscription = api.ws.messages.listen((message) {
      print('Received message: $message');

      // Handle different message types
      if (message is FullStateMessage) {
        // Handle the full state message received on initial connection
        print('Received full state message:');
        print('  Site: ${message.siteTitle}');
        print('  Version: ${message.version}');
        print('  Currency: ${message.currency}');

        // Print system overview
        print('System Overview:');
        print('  PV Power: ${message.pvPower} W');
        print('  Home Power: ${message.homePower} W');
        print('  Battery SoC: ${message.batterySoc}%');

        // Print loadpoint information
        print('Loadpoints (${message.loadpointCount}):');
        for (var i = 0; i < message.loadpointCount; i++) {
          final props = message.getLoadpointProperties(i);
          print('  Loadpoint $i:');
          props.forEach((key, value) {
            print('    $key: $value');
          });
        }

        // Print tariff information
        print('Tariffs:');
        if (message.tariffGrid != null) {
          print('  Grid: ${message.tariffGrid} ${message.currency}/kWh');
        }
        if (message.tariffCo2 != null) {
          print('  CO2: ${message.tariffCo2} g/kWh');
        }
        if (message.tariffSolar != null) {
          print('  Solar: ${message.tariffSolar} ${message.currency}/kWh');
        }

        // Print green share information
        if (message.greenShareHome != null) {
          print('  Green Share Home: ${message.greenShareHome! * 100}%');
        }
        if (message.greenShareLoadpoints != null) {
          print(
            '  Green Share Loadpoints: ${message.greenShareLoadpoints! * 100}%',
          );
        }
      } else if (message is PvPowerMessage) {
        print('PV Power: ${message.pvPower} W');
      } else if (message is PvEnergyMessage) {
        print('PV Energy: ${message.pvEnergy} Wh');
      } else if (message is PvDetailsMessage) {
        for (var i = 0; i < message.pv.length; i++) {
          final detail = message.pv[i];
          print(
            'PV $i - Power: ${detail.power} W, Energy: ${detail.energy} Wh',
          );
        }
      } else if (message is HomePowerMessage) {
        print('Home Power: ${message.homePower} W');
      } else if (message is LoadpointMessage) {
        print(
          'Loadpoint ${message.loadpointIndex} - ${message.property}: ${message.value}',
        );
      } else if (message is ForecastMessage) {
        print('Forecast:');
        print(
          '  CO2: ${message.co2.length} periods, first: ${message.co2.first.price} g/kWh',
        );
        print(
          '  Grid: ${message.grid.length} periods, first: ${message.grid.first.price} EUR/kWh',
        );
        print(
          '  Solar today: ${message.solar.today.energy} Wh, complete: ${message.solar.today.complete}',
        );
        print(
          '  Solar tomorrow: ${message.solar.tomorrow.energy} Wh, complete: ${message.solar.tomorrow.complete}',
        );
        print('  Solar timeseries: ${message.solar.timeseries.length} entries');
      } else if (message is GreenShareHomeMessage) {
        print('Green Share Home: ${message.percentage * 100}%');
      } else if (message is GreenShareLoadpointsMessage) {
        print('Green Share Loadpoints: ${message.percentage * 100}%');
      } else if (message is TariffGridMessage) {
        print('Tariff Grid: ${message.price} EUR/kWh');
      } else if (message is TariffCo2Message) {
        print('Tariff CO2: ${message.intensity} g/kWh');
      } else if (message is TariffSolarMessage) {
        print('Tariff Solar: ${message.price} EUR/kWh');
      } else if (message is TariffPriceHomeMessage) {
        print('Tariff Price Home: ${message.price} EUR/kWh');
      } else if (message is TariffCo2HomeMessage) {
        print('Tariff CO2 Home: ${message.intensity} g/kWh');
      } else if (message is TariffPriceLoadpointsMessage) {
        print('Tariff Price Loadpoints: ${message.price} EUR/kWh');
      } else if (message is TariffCo2LoadpointsMessage) {
        print('Tariff CO2 Loadpoints: ${message.intensity} g/kWh');
      } else if (message is BatteryGridChargeActiveMessage) {
        print('Battery Grid Charge Active: ${message.active}');
      } else if (message is BatteryCapacityMessage) {
        print('Battery Capacity: ${message.capacity} kWh');
      } else if (message is BatterySocMessage) {
        print('Battery SoC: ${message.soc}%');
      } else if (message is BatteryPowerMessage) {
        print('Battery Power: ${message.power} W');
      } else if (message is BatteryEnergyMessage) {
        print('Battery Energy: ${message.energy} Wh');
      } else if (message is BatteryDetailsMessage) {
        for (var i = 0; i < message.battery.length; i++) {
          final detail = message.battery[i];
          print(
            'Battery $i - Power: ${detail.power} W, Capacity: ${detail.capacity} kWh, SoC: ${detail.soc}%, Controllable: ${detail.controllable}',
          );
        }
      } else if (message is GridDetailsMessage) {
        print(
          'Grid - Power: ${message.grid.power} W, Energy: ${message.grid.energy} Wh',
        );
        print('  Powers: ${message.grid.powers}');
        print('  Currents: ${message.grid.currents}');
      } else if (message is LogMessage) {
        print(
          'Log - Level: ${message.log.level}, Message: ${message.log.message}',
        );
      } else if (message is GenericMessage) {
        print('Generic message: ${message.data}');
      }
    });

    // Keep the program running for 5 minutes
    print('Listening for messages for 5 minutes...');
    await Future.delayed(Duration(minutes: 5));

    // Clean up
    subscription.cancel();
    await api.ws.disconnect();
    await api.close();
    print('Disconnected from WebSocket');
  } catch (e) {
    print('Error: $e');
    await api.close();
  }
}

/// Example of filtering messages by type
void filterMessagesByType(EvccWebSocketClient ws) {
  // Filter for full state messages (received on initial connection)
  final fullStateStream =
      ws.messages
          .where((message) => message is FullStateMessage)
          .cast<FullStateMessage>();

  fullStateStream.listen((message) {
    print('Full state received:');
    print('  Site: ${message.siteTitle}');
    print('  Version: ${message.version}');
    print('  Loadpoints: ${message.loadpointCount}');

    // You can use this to initialize your application state
    // when the WebSocket connection is established
  });

  // Filter for PV power messages
  final pvPowerStream =
      ws.messages
          .where((message) => message is PvPowerMessage)
          .cast<PvPowerMessage>();

  pvPowerStream.listen((message) {
    print('PV Power update: ${message.pvPower} W');
  });

  // Filter for home power messages
  final homePowerStream =
      ws.messages
          .where((message) => message is HomePowerMessage)
          .cast<HomePowerMessage>();

  homePowerStream.listen((message) {
    print('Home Power update: ${message.homePower} W');
  });

  // Filter for forecast messages
  final forecastStream =
      ws.messages
          .where((message) => message is ForecastMessage)
          .cast<ForecastMessage>();

  forecastStream.listen((message) {
    print('Forecast update:');
    print('  Current grid price: ${message.grid.first.price} EUR/kWh');
    print('  Current CO2 intensity: ${message.co2.first.price} g/kWh');
    print('  Solar production today: ${message.solar.today.energy} Wh');
  });

  // Filter for green share messages
  final greenShareHomeStream =
      ws.messages
          .where((message) => message is GreenShareHomeMessage)
          .cast<GreenShareHomeMessage>();

  greenShareHomeStream.listen((message) {
    print('Green Share Home update: ${message.percentage * 100}%');
  });

  // Filter for tariff messages
  final tariffGridStream =
      ws.messages
          .where((message) => message is TariffGridMessage)
          .cast<TariffGridMessage>();

  tariffGridStream.listen((message) {
    print('Tariff Grid update: ${message.price} EUR/kWh');
  });

  final tariffCo2Stream =
      ws.messages
          .where((message) => message is TariffCo2Message)
          .cast<TariffCo2Message>();

  tariffCo2Stream.listen((message) {
    print('Tariff CO2 update: ${message.intensity} g/kWh');
  });

  // Filter for battery messages
  final batterySocStream =
      ws.messages
          .where((message) => message is BatterySocMessage)
          .cast<BatterySocMessage>();

  batterySocStream.listen((message) {
    print('Battery SoC update: ${message.soc}%');
  });

  final batteryPowerStream =
      ws.messages
          .where((message) => message is BatteryPowerMessage)
          .cast<BatteryPowerMessage>();

  batteryPowerStream.listen((message) {
    print('Battery Power update: ${message.power} W');
  });

  final batteryDetailsStream =
      ws.messages
          .where((message) => message is BatteryDetailsMessage)
          .cast<BatteryDetailsMessage>();

  batteryDetailsStream.listen((message) {
    print('Battery Details update:');
    for (var i = 0; i < message.battery.length; i++) {
      final detail = message.battery[i];
      print('  Battery $i - Power: ${detail.power} W, SoC: ${detail.soc}%');
    }
  });

  // Filter for grid messages
  final gridDetailsStream =
      ws.messages
          .where((message) => message is GridDetailsMessage)
          .cast<GridDetailsMessage>();

  gridDetailsStream.listen((message) {
    print('Grid update:');
    print('  Power: ${message.grid.power} W');
    print('  Energy: ${message.grid.energy} Wh');
  });

  // Filter for log messages
  final logStream =
      ws.messages.where((message) => message is LogMessage).cast<LogMessage>();

  logStream.listen((message) {
    print('Log [${message.log.level}]: ${message.log.message}');
  });
}

/// Example of tracking state over time
class StateTracker {
  double? pvPower;
  double? homePower;
  final Map<int, Map<String, dynamic>> loadpointStates = {};

  // Forecast data
  double? currentGridPrice;
  double? currentCo2Intensity;
  double? solarTodayEnergy;
  double? solarTomorrowEnergy;

  // Green share data
  double? greenShareHome;
  double? greenShareLoadpoints;

  // Tariff data
  double? tariffGrid;
  double? tariffCo2;
  double? tariffSolar;
  double? tariffPriceHome;
  double? tariffCo2Home;
  double? tariffPriceLoadpoints;
  double? tariffCo2Loadpoints;

  // Battery data
  double? batterySoc;
  double? batteryPower;
  double? batteryEnergy;
  double? batteryCapacity;
  bool? batteryGridChargeActive;
  List<BatteryDetail>? batteryDetails;

  // Grid data
  GridData? gridData;

  void trackState(EvccWebSocketClient ws) {
    ws.messages.listen((message) {
      if (message is FullStateMessage) {
        // Initialize all state from the full state message
        print('Initializing state from full state message...');

        // Basic system data
        pvPower = message.pvPower?.toDouble();
        homePower = message.homePower?.toDouble();

        // Battery data
        if (message.batterySoc != null) {
          // Battery state of charge is already a percentage
          // No need to convert
        }

        // Tariff data
        tariffGrid = message.tariffGrid?.toDouble();
        tariffCo2 = message.tariffCo2?.toDouble();
        tariffSolar = message.tariffSolar?.toDouble();
        tariffPriceHome = message.tariffPriceHome?.toDouble();
        tariffCo2Home = message.tariffCo2Home?.toDouble();
        tariffPriceLoadpoints = message.tariffPriceLoadpoints?.toDouble();
        tariffCo2Loadpoints = message.tariffCo2Loadpoints?.toDouble();

        // Green share data
        greenShareHome = message.greenShareHome?.toDouble();
        greenShareLoadpoints = message.greenShareLoadpoints?.toDouble();

        // Forecast data
        if (message.forecast != null) {
          if (message.forecast!.grid.isNotEmpty) {
            currentGridPrice = message.forecast!.grid.first.price.toDouble();
          }
          if (message.forecast!.co2.isNotEmpty) {
            currentCo2Intensity = message.forecast!.co2.first.price.toDouble();
          }
          solarTodayEnergy = message.forecast!.solar.today.energy.toDouble();
          solarTomorrowEnergy =
              message.forecast!.solar.tomorrow.energy.toDouble();
        }

        // Loadpoint data
        for (var i = 0; i < message.loadpointCount; i++) {
          loadpointStates[i] = message.getLoadpointProperties(i);
        }

        _printCurrentState();
      } else if (message is PvPowerMessage) {
        pvPower = message.pvPower.toDouble();
        _printCurrentState();
      } else if (message is HomePowerMessage) {
        homePower = message.homePower.toDouble();
        _printCurrentState();
      } else if (message is LoadpointMessage) {
        final index = message.loadpointIndex;
        if (index >= 0) {
          loadpointStates[index] ??= {};
          loadpointStates[index]![message.property] = message.value;
          _printCurrentState();
        }
      } else if (message is ForecastMessage) {
        // Update forecast data
        if (message.grid.isNotEmpty) {
          currentGridPrice = message.grid.first.price.toDouble();
        }
        if (message.co2.isNotEmpty) {
          currentCo2Intensity = message.co2.first.price.toDouble();
        }
        solarTodayEnergy = message.solar.today.energy.toDouble();
        solarTomorrowEnergy = message.solar.tomorrow.energy.toDouble();
        _printCurrentState();
      } else if (message is GreenShareHomeMessage) {
        greenShareHome = message.percentage.toDouble();
        _printCurrentState();
      } else if (message is GreenShareLoadpointsMessage) {
        greenShareLoadpoints = message.percentage.toDouble();
        _printCurrentState();
      } else if (message is TariffGridMessage) {
        tariffGrid = message.price.toDouble();
        _printCurrentState();
      } else if (message is TariffCo2Message) {
        tariffCo2 = message.intensity.toDouble();
        _printCurrentState();
      } else if (message is TariffSolarMessage) {
        tariffSolar = message.price.toDouble();
        _printCurrentState();
      } else if (message is TariffPriceHomeMessage) {
        tariffPriceHome = message.price.toDouble();
        _printCurrentState();
      } else if (message is TariffCo2HomeMessage) {
        tariffCo2Home = message.intensity.toDouble();
        _printCurrentState();
      } else if (message is TariffPriceLoadpointsMessage) {
        tariffPriceLoadpoints = message.price.toDouble();
        _printCurrentState();
      } else if (message is TariffCo2LoadpointsMessage) {
        tariffCo2Loadpoints = message.intensity.toDouble();
        _printCurrentState();
      } else if (message is BatteryGridChargeActiveMessage) {
        batteryGridChargeActive = message.active;
        _printCurrentState();
      } else if (message is BatteryCapacityMessage) {
        batteryCapacity = message.capacity.toDouble();
        _printCurrentState();
      } else if (message is BatterySocMessage) {
        batterySoc = message.soc.toDouble();
        _printCurrentState();
      } else if (message is BatteryPowerMessage) {
        batteryPower = message.power.toDouble();
        _printCurrentState();
      } else if (message is BatteryEnergyMessage) {
        batteryEnergy = message.energy.toDouble();
        _printCurrentState();
      } else if (message is BatteryDetailsMessage) {
        batteryDetails = message.battery;
        _printCurrentState();
      } else if (message is GridDetailsMessage) {
        gridData = message.grid;
        _printCurrentState();
      }
    });
  }

  void _printCurrentState() {
    print('Current State:');
    print('  PV Power: ${pvPower ?? "unknown"} W');
    print('  Home Power: ${homePower ?? "unknown"} W');

    // Print forecast data if available
    if (currentGridPrice != null ||
        currentCo2Intensity != null ||
        solarTodayEnergy != null) {
      print('  Forecast:');
      if (currentGridPrice != null) {
        print('    Current Grid Price: $currentGridPrice EUR/kWh');
      }
      if (currentCo2Intensity != null) {
        print('    Current CO2 Intensity: $currentCo2Intensity g/kWh');
      }
      if (solarTodayEnergy != null) {
        print('    Solar Today: $solarTodayEnergy Wh');
      }
      if (solarTomorrowEnergy != null) {
        print('    Solar Tomorrow: $solarTomorrowEnergy Wh');
      }
    }

    // Print green share data if available
    if (greenShareHome != null || greenShareLoadpoints != null) {
      print('  Green Share:');
      if (greenShareHome != null) {
        print('    Home: ${(greenShareHome! * 100).toStringAsFixed(1)}%');
      }
      if (greenShareLoadpoints != null) {
        print(
          '    Loadpoints: ${(greenShareLoadpoints! * 100).toStringAsFixed(1)}%',
        );
      }
    }

    // Print tariff data if available
    if (tariffGrid != null ||
        tariffCo2 != null ||
        tariffSolar != null ||
        tariffPriceHome != null ||
        tariffCo2Home != null ||
        tariffPriceLoadpoints != null ||
        tariffCo2Loadpoints != null) {
      print('  Tariffs:');
      if (tariffGrid != null) {
        print('    Grid: $tariffGrid EUR/kWh');
      }
      if (tariffCo2 != null) {
        print('    CO2: $tariffCo2 g/kWh');
      }
      if (tariffSolar != null) {
        print('    Solar: $tariffSolar EUR/kWh');
      }
      if (tariffPriceHome != null) {
        print('    Home Price: $tariffPriceHome EUR/kWh');
      }
      if (tariffCo2Home != null) {
        print('    Home CO2: $tariffCo2Home g/kWh');
      }
      if (tariffPriceLoadpoints != null) {
        print('    Loadpoints Price: $tariffPriceLoadpoints EUR/kWh');
      }
      if (tariffCo2Loadpoints != null) {
        print('    Loadpoints CO2: $tariffCo2Loadpoints g/kWh');
      }
    }

    // Print battery data if available
    if (batterySoc != null ||
        batteryPower != null ||
        batteryEnergy != null ||
        batteryCapacity != null ||
        batteryGridChargeActive != null ||
        batteryDetails != null) {
      print('  Battery:');
      if (batterySoc != null) {
        print('    SoC: ${batterySoc!.toStringAsFixed(1)}%');
      }
      if (batteryPower != null) {
        print('    Power: $batteryPower W');
      }
      if (batteryEnergy != null) {
        print('    Energy: $batteryEnergy Wh');
      }
      if (batteryCapacity != null) {
        print('    Capacity: $batteryCapacity kWh');
      }
      if (batteryGridChargeActive != null) {
        print('    Grid Charge Active: $batteryGridChargeActive');
      }
      if (batteryDetails != null) {
        for (var i = 0; i < batteryDetails!.length; i++) {
          final detail = batteryDetails![i];
          print('    Battery $i:');
          print('      Power: ${detail.power} W');
          print('      Capacity: ${detail.capacity} kWh');
          print('      SoC: ${detail.soc}%');
          print('      Controllable: ${detail.controllable}');
        }
      }
    }

    // Print grid data if available
    if (gridData != null) {
      print('  Grid:');
      print('    Power: ${gridData!.power} W');
      print('    Energy: ${gridData!.energy} Wh');
      print('    Powers: ${gridData!.powers}');
      print('    Currents: ${gridData!.currents}');
    }

    print('  Loadpoints:');
    for (final entry in loadpointStates.entries) {
      print('    Loadpoint ${entry.key}:');
      for (final prop in entry.value.entries) {
        print('      ${prop.key}: ${prop.value}');
      }
    }
    print('');
  }
}
