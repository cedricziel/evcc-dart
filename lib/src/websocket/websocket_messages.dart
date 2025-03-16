/// WebSocket message models for the EVCC API.
library;

import 'dart:convert';

/// Base class for all WebSocket messages.
abstract class EvccWebSocketMessage {
  /// Creates a message from a JSON string.
  static EvccWebSocketMessage? fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      if (json is Map<String, dynamic>) {
        return fromJson(json);
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Creates a message from a JSON map.
  static EvccWebSocketMessage? fromJson(Map<String, dynamic> json) {
    // Check for specific message types
    if (json.containsKey('pvPower')) {
      return PvPowerMessage(json['pvPower'] as num);
    } else if (json.containsKey('pvEnergy')) {
      return PvEnergyMessage(json['pvEnergy'] as num);
    } else if (json.containsKey('pv')) {
      return PvDetailsMessage.fromJson(json);
    } else if (json.containsKey('homePower')) {
      return HomePowerMessage(json['homePower'] as num);
    } else if (json.containsKey('forecast')) {
      return ForecastMessage.fromJson(json);
    } else if (json.containsKey('greenShareHome')) {
      return GreenShareHomeMessage(json['greenShareHome'] as num);
    } else if (json.containsKey('greenShareLoadpoints')) {
      return GreenShareLoadpointsMessage(json['greenShareLoadpoints'] as num);
    } else if (json.containsKey('tariffGrid')) {
      return TariffGridMessage(json['tariffGrid'] as num);
    } else if (json.containsKey('tariffCo2')) {
      return TariffCo2Message(json['tariffCo2'] as num);
    } else if (json.containsKey('tariffSolar')) {
      return TariffSolarMessage(json['tariffSolar'] as num);
    } else if (json.containsKey('tariffPriceHome')) {
      return TariffPriceHomeMessage(json['tariffPriceHome'] as num);
    } else if (json.containsKey('tariffCo2Home')) {
      return TariffCo2HomeMessage(json['tariffCo2Home'] as num);
    } else if (json.containsKey('tariffPriceLoadpoints')) {
      return TariffPriceLoadpointsMessage(json['tariffPriceLoadpoints'] as num);
    } else if (json.containsKey('tariffCo2Loadpoints')) {
      return TariffCo2LoadpointsMessage(json['tariffCo2Loadpoints'] as num);
    }

    // Check for loadpoint messages
    final keys = json.keys.toList();
    if (keys.length == 1 && keys[0].startsWith('loadpoints.')) {
      return LoadpointMessage(keys[0], json[keys[0]]);
    }

    // If no specific type is recognized, return a generic message
    return GenericMessage(json);
  }
}

/// Generic message for unrecognized message types.
class GenericMessage extends EvccWebSocketMessage {
  /// The raw message data.
  final Map<String, dynamic> data;

  /// Creates a new generic message.
  GenericMessage(this.data);

  @override
  String toString() => 'GenericMessage($data)';
}

/// PV power message.
class PvPowerMessage extends EvccWebSocketMessage {
  /// The PV power in watts.
  final num pvPower;

  /// Creates a new PV power message.
  PvPowerMessage(this.pvPower);

  @override
  String toString() => 'PvPowerMessage(pvPower: $pvPower)';
}

/// PV energy message.
class PvEnergyMessage extends EvccWebSocketMessage {
  /// The PV energy in watt-hours.
  final num pvEnergy;

  /// Creates a new PV energy message.
  PvEnergyMessage(this.pvEnergy);

  @override
  String toString() => 'PvEnergyMessage(pvEnergy: $pvEnergy)';
}

/// PV details message.
class PvDetailsMessage extends EvccWebSocketMessage {
  /// The PV details.
  final List<PvDetail> pv;

  /// Creates a new PV details message.
  PvDetailsMessage(this.pv);

  /// Creates a PV details message from JSON.
  factory PvDetailsMessage.fromJson(Map<String, dynamic> json) {
    final pvList =
        (json['pv'] as List)
            .map((e) => PvDetail.fromJson(e as Map<String, dynamic>))
            .toList();
    return PvDetailsMessage(pvList);
  }

  @override
  String toString() => 'PvDetailsMessage(pv: $pv)';
}

/// PV detail.
class PvDetail {
  /// The power in watts.
  final num power;

  /// The energy in watt-hours.
  final num? energy;

  /// Creates a new PV detail.
  PvDetail({required this.power, this.energy});

  /// Creates a PV detail from JSON.
  factory PvDetail.fromJson(Map<String, dynamic> json) {
    return PvDetail(
      power: json['power'] as num,
      energy: json['energy'] as num?,
    );
  }

  @override
  String toString() => 'PvDetail(power: $power, energy: $energy)';
}

/// Home power message.
class HomePowerMessage extends EvccWebSocketMessage {
  /// The home power in watts.
  final num homePower;

  /// Creates a new home power message.
  HomePowerMessage(this.homePower);

  @override
  String toString() => 'HomePowerMessage(homePower: $homePower)';
}

/// Loadpoint message.
class LoadpointMessage extends EvccWebSocketMessage {
  /// The loadpoint path (e.g., 'loadpoints.0.smartCostActive').
  final String path;

  /// The loadpoint value.
  final dynamic value;

  /// Creates a new loadpoint message.
  LoadpointMessage(this.path, this.value);

  /// The loadpoint index.
  int get loadpointIndex {
    final match = RegExp(r'loadpoints\.(\d+)').firstMatch(path);
    return match != null ? int.parse(match.group(1)!) : -1;
  }

  /// The property name.
  String get property {
    final match = RegExp(r'loadpoints\.\d+\.(.+)').firstMatch(path);
    return match != null ? match.group(1)! : path;
  }

  @override
  String toString() => 'LoadpointMessage(path: $path, value: $value)';
}

/// Forecast message with CO2, grid pricing, and solar production data.
class ForecastMessage extends EvccWebSocketMessage {
  /// CO2 emissions forecast.
  final List<ForecastPeriod> co2;

  /// Grid pricing forecast.
  final List<ForecastPeriod> grid;

  /// Solar production forecast.
  final SolarForecast solar;

  /// Creates a new forecast message.
  ForecastMessage({required this.co2, required this.grid, required this.solar});

  /// Creates a forecast message from JSON.
  factory ForecastMessage.fromJson(Map<String, dynamic> json) {
    final forecastData = json['forecast'] as Map<String, dynamic>;

    return ForecastMessage(
      co2:
          (forecastData['co2'] as List)
              .map((e) => ForecastPeriod.fromJson(e as Map<String, dynamic>))
              .toList(),
      grid:
          (forecastData['grid'] as List)
              .map((e) => ForecastPeriod.fromJson(e as Map<String, dynamic>))
              .toList(),
      solar: SolarForecast.fromJson(
        forecastData['solar'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  String toString() =>
      'ForecastMessage(co2: ${co2.length} periods, grid: ${grid.length} periods, solar: $solar)';
}

/// A time period with a price value.
class ForecastPeriod {
  /// Start time of the period.
  final DateTime start;

  /// End time of the period.
  final DateTime end;

  /// Price value for the period.
  final num price;

  /// Creates a new forecast period.
  ForecastPeriod({required this.start, required this.end, required this.price});

  /// Creates a forecast period from JSON.
  factory ForecastPeriod.fromJson(Map<String, dynamic> json) {
    return ForecastPeriod(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      price: json['price'] as num,
    );
  }

  @override
  String toString() =>
      'ForecastPeriod(start: $start, end: $end, price: $price)';
}

/// Solar production forecast.
class SolarForecast {
  /// Today's energy production data.
  final DailyEnergy today;

  /// Tomorrow's energy production data.
  final DailyEnergy tomorrow;

  /// Day after tomorrow's energy production data.
  final DailyEnergy dayAfterTomorrow;

  /// Detailed timeseries of solar production.
  final List<SolarTimeseriesEntry> timeseries;

  /// Creates a new solar forecast.
  SolarForecast({
    required this.today,
    required this.tomorrow,
    required this.dayAfterTomorrow,
    required this.timeseries,
  });

  /// Creates a solar forecast from JSON.
  factory SolarForecast.fromJson(Map<String, dynamic> json) {
    return SolarForecast(
      today: DailyEnergy.fromJson(json['today'] as Map<String, dynamic>),
      tomorrow: DailyEnergy.fromJson(json['tomorrow'] as Map<String, dynamic>),
      dayAfterTomorrow: DailyEnergy.fromJson(
        json['dayAfterTomorrow'] as Map<String, dynamic>,
      ),
      timeseries:
          (json['timeseries'] as List)
              .map(
                (e) => SolarTimeseriesEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  @override
  String toString() =>
      'SolarForecast(today: $today, tomorrow: $tomorrow, dayAfterTomorrow: $dayAfterTomorrow, timeseries: ${timeseries.length} entries)';
}

/// Daily energy production data.
class DailyEnergy {
  /// Energy production in watt-hours.
  final num energy;

  /// Whether the forecast is complete.
  final bool complete;

  /// Creates a new daily energy entry.
  DailyEnergy({required this.energy, required this.complete});

  /// Creates a daily energy entry from JSON.
  factory DailyEnergy.fromJson(Map<String, dynamic> json) {
    return DailyEnergy(
      energy: json['energy'] as num,
      complete: json['complete'] as bool,
    );
  }

  @override
  String toString() => 'DailyEnergy(energy: $energy, complete: $complete)';
}

/// Solar production timeseries entry.
class SolarTimeseriesEntry {
  /// Timestamp.
  final DateTime timestamp;

  /// Production value in watts.
  final num value;

  /// Creates a new timeseries entry.
  SolarTimeseriesEntry({required this.timestamp, required this.value});

  /// Creates a timeseries entry from JSON.
  factory SolarTimeseriesEntry.fromJson(Map<String, dynamic> json) {
    return SolarTimeseriesEntry(
      timestamp: DateTime.parse(json['ts'] as String),
      value: json['val'] as num,
    );
  }

  @override
  String toString() =>
      'SolarTimeseriesEntry(timestamp: $timestamp, value: $value)';
}

/// Green share home message.
class GreenShareHomeMessage extends EvccWebSocketMessage {
  /// The percentage of home energy from green sources (0-1).
  final num percentage;

  /// Creates a new green share home message.
  GreenShareHomeMessage(this.percentage);

  @override
  String toString() => 'GreenShareHomeMessage(percentage: $percentage)';
}

/// Green share loadpoints message.
class GreenShareLoadpointsMessage extends EvccWebSocketMessage {
  /// The percentage of loadpoint energy from green sources (0-1).
  final num percentage;

  /// Creates a new green share loadpoints message.
  GreenShareLoadpointsMessage(this.percentage);

  @override
  String toString() => 'GreenShareLoadpointsMessage(percentage: $percentage)';
}

/// Tariff grid message.
class TariffGridMessage extends EvccWebSocketMessage {
  /// The grid electricity price in currency/kWh.
  final num price;

  /// Creates a new tariff grid message.
  TariffGridMessage(this.price);

  @override
  String toString() => 'TariffGridMessage(price: $price)';
}

/// Tariff CO2 message.
class TariffCo2Message extends EvccWebSocketMessage {
  /// The CO2 intensity of grid electricity in g/kWh.
  final num intensity;

  /// Creates a new tariff CO2 message.
  TariffCo2Message(this.intensity);

  @override
  String toString() => 'TariffCo2Message(intensity: $intensity)';
}

/// Tariff solar message.
class TariffSolarMessage extends EvccWebSocketMessage {
  /// The solar electricity price/value in currency/kWh.
  final num price;

  /// Creates a new tariff solar message.
  TariffSolarMessage(this.price);

  @override
  String toString() => 'TariffSolarMessage(price: $price)';
}

/// Tariff price home message.
class TariffPriceHomeMessage extends EvccWebSocketMessage {
  /// The home electricity price in currency/kWh.
  final num price;

  /// Creates a new tariff price home message.
  TariffPriceHomeMessage(this.price);

  @override
  String toString() => 'TariffPriceHomeMessage(price: $price)';
}

/// Tariff CO2 home message.
class TariffCo2HomeMessage extends EvccWebSocketMessage {
  /// The CO2 intensity of home electricity in g/kWh.
  final num intensity;

  /// Creates a new tariff CO2 home message.
  TariffCo2HomeMessage(this.intensity);

  @override
  String toString() => 'TariffCo2HomeMessage(intensity: $intensity)';
}

/// Tariff price loadpoints message.
class TariffPriceLoadpointsMessage extends EvccWebSocketMessage {
  /// The loadpoint electricity price in currency/kWh.
  final num price;

  /// Creates a new tariff price loadpoints message.
  TariffPriceLoadpointsMessage(this.price);

  @override
  String toString() => 'TariffPriceLoadpointsMessage(price: $price)';
}

/// Tariff CO2 loadpoints message.
class TariffCo2LoadpointsMessage extends EvccWebSocketMessage {
  /// The CO2 intensity of loadpoint electricity in g/kWh.
  final num intensity;

  /// Creates a new tariff CO2 loadpoints message.
  TariffCo2LoadpointsMessage(this.intensity);

  @override
  String toString() => 'TariffCo2LoadpointsMessage(intensity: $intensity)';
}
