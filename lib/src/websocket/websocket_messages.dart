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
    // Check if this is a full state message
    // Full state messages contain multiple key properties like version, siteTitle, etc.
    if (json.containsKey('version') &&
        json.containsKey('siteTitle') &&
        json.containsKey('currency')) {
      return FullStateMessage.fromJson(json);
    }

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
    } else if (json.containsKey('batteryGridChargeActive')) {
      return BatteryGridChargeActiveMessage(
        json['batteryGridChargeActive'] as bool,
      );
    } else if (json.containsKey('batteryCapacity')) {
      return BatteryCapacityMessage(json['batteryCapacity'] as num);
    } else if (json.containsKey('batterySoc') && json.length == 1) {
      return BatterySocMessage(json['batterySoc'] as num);
    } else if (json.containsKey('batteryPower') && json.length == 1) {
      return BatteryPowerMessage(json['batteryPower'] as num);
    } else if (json.containsKey('batteryEnergy') && json.length == 1) {
      return BatteryEnergyMessage(json['batteryEnergy'] as num);
    } else if (json.containsKey('battery') && json.length == 1) {
      return BatteryDetailsMessage.fromJson(json);
    } else if (json.containsKey('grid') && json.length == 1) {
      return GridDetailsMessage.fromJson(json);
    } else if (json.containsKey('log')) {
      return LogMessage.fromJson(json);
    } else if (json.containsKey('auxPower') && json.length == 1) {
      return AuxPowerMessage(json['auxPower'] as num);
    } else if (json.containsKey('aux') && json.length == 1) {
      return AuxDetailsMessage.fromJson(json);
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

/// Full state message received when the WebSocket client initially connects.
/// Contains the complete system state.
class FullStateMessage extends EvccWebSocketMessage {
  /// The raw data from the full state message.
  final Map<String, dynamic> data;

  /// The system version.
  final String version;

  /// The site title.
  final String siteTitle;

  /// The currency used for pricing.
  final String currency;

  /// The PV power in watts.
  final num? pvPower;

  /// The PV energy in watt-hours.
  final num? pvEnergy;

  /// The home power in watts.
  final num? homePower;

  /// The battery state of charge (0-100).
  final num? batterySoc;

  /// The battery power in watts.
  final num? batteryPower;

  /// The battery energy in watt-hours.
  final num? batteryEnergy;

  /// The grid power in watts.
  final GridData? grid;

  /// The forecast data.
  final ForecastMessage? forecast;

  /// The statistics data.
  final StatisticsData? statistics;

  /// The green share of home energy (0-1).
  final num? greenShareHome;

  /// The green share of loadpoint energy (0-1).
  final num? greenShareLoadpoints;

  /// The grid electricity price in currency/kWh.
  final num? tariffGrid;

  /// The CO2 intensity of grid electricity in g/kWh.
  final num? tariffCo2;

  /// The solar electricity price/value in currency/kWh.
  final num? tariffSolar;

  /// The home electricity price in currency/kWh.
  final num? tariffPriceHome;

  /// The CO2 intensity of home electricity in g/kWh.
  final num? tariffCo2Home;

  /// The loadpoint electricity price in currency/kWh.
  final num? tariffPriceLoadpoints;

  /// The CO2 intensity of loadpoint electricity in g/kWh.
  final num? tariffCo2Loadpoints;

  /// The PV details.
  final List<PvDetail>? pv;

  /// The battery details.
  final List<BatteryDetail>? battery;

  /// Creates a new full state message.
  FullStateMessage({
    required this.data,
    required this.version,
    required this.siteTitle,
    required this.currency,
    this.pvPower,
    this.pvEnergy,
    this.homePower,
    this.batterySoc,
    this.batteryPower,
    this.batteryEnergy,
    this.grid,
    this.forecast,
    this.statistics,
    this.greenShareHome,
    this.greenShareLoadpoints,
    this.tariffGrid,
    this.tariffCo2,
    this.tariffSolar,
    this.tariffPriceHome,
    this.tariffCo2Home,
    this.tariffPriceLoadpoints,
    this.tariffCo2Loadpoints,
    this.pv,
    this.battery,
  });

  /// Creates a full state message from JSON.
  factory FullStateMessage.fromJson(Map<String, dynamic> json) {
    // Extract forecast if present
    ForecastMessage? forecastMessage;
    if (json.containsKey('forecast')) {
      forecastMessage = ForecastMessage.fromJson(json);
    }

    // Extract PV details if present
    List<PvDetail>? pvDetails;
    if (json.containsKey('pv')) {
      pvDetails =
          (json['pv'] as List)
              .map((e) => PvDetail.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    // Extract battery details if present
    List<BatteryDetail>? batteryDetails;
    if (json.containsKey('battery')) {
      batteryDetails =
          (json['battery'] as List)
              .map((e) => BatteryDetail.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    // Extract grid data if present
    GridData? gridData;
    if (json.containsKey('grid')) {
      gridData = GridData.fromJson(json['grid'] as Map<String, dynamic>);
    }

    // Extract statistics if present
    StatisticsData? statisticsData;
    if (json.containsKey('statistics')) {
      statisticsData = StatisticsData.fromJson(
        json['statistics'] as Map<String, dynamic>,
      );
    }

    return FullStateMessage(
      data: json,
      version: json['version'] as String,
      siteTitle: json['siteTitle'] as String,
      currency: json['currency'] as String,
      pvPower: json['pvPower'] as num?,
      pvEnergy: json['pvEnergy'] as num?,
      homePower: json['homePower'] as num?,
      batterySoc: json['batterySoc'] as num?,
      batteryPower: json['batteryPower'] as num?,
      batteryEnergy: json['batteryEnergy'] as num?,
      grid: gridData,
      forecast: forecastMessage,
      statistics: statisticsData,
      greenShareHome: json['greenShareHome'] as num?,
      greenShareLoadpoints: json['greenShareLoadpoints'] as num?,
      tariffGrid: json['tariffGrid'] as num?,
      tariffCo2: json['tariffCo2'] as num?,
      tariffSolar: json['tariffSolar'] as num?,
      tariffPriceHome: json['tariffPriceHome'] as num?,
      tariffCo2Home: json['tariffCo2Home'] as num?,
      tariffPriceLoadpoints: json['tariffPriceLoadpoints'] as num?,
      tariffCo2Loadpoints: json['tariffCo2Loadpoints'] as num?,
      pv: pvDetails,
      battery: batteryDetails,
    );
  }

  /// Gets a loadpoint property by index and property name.
  dynamic getLoadpointProperty(int index, String property) {
    final key = 'loadpoints.$index.$property';
    return data[key];
  }

  /// Gets all loadpoint properties for a specific index.
  Map<String, dynamic> getLoadpointProperties(int index) {
    final result = <String, dynamic>{};
    final prefix = 'loadpoints.$index.';

    for (final entry in data.entries) {
      if (entry.key.startsWith(prefix)) {
        final property = entry.key.substring(prefix.length);
        result[property] = entry.value;
      }
    }

    return result;
  }

  /// Gets the number of loadpoints in the system.
  int get loadpointCount {
    final loadpointIndices = <int>{};

    for (final key in data.keys) {
      if (key.startsWith('loadpoints.')) {
        final match = RegExp(r'loadpoints\.(\d+)\.').firstMatch(key);
        if (match != null) {
          loadpointIndices.add(int.parse(match.group(1)!));
        }
      }
    }

    return loadpointIndices.length;
  }

  @override
  String toString() =>
      'FullStateMessage(version: $version, siteTitle: $siteTitle)';
}

/// Grid data.
class GridData {
  /// The power in watts.
  final num power;

  /// The energy in watt-hours.
  final num energy;

  /// The power per phase in watts.
  final List<num> powers;

  /// The current per phase in amperes.
  final List<num> currents;

  /// Creates a new grid data.
  GridData({
    required this.power,
    required this.energy,
    required this.powers,
    required this.currents,
  });

  /// Creates grid data from JSON.
  factory GridData.fromJson(Map<String, dynamic> json) {
    return GridData(
      power: json['power'] as num,
      energy: json['energy'] as num,
      powers: (json['powers'] as List).cast<num>(),
      currents: (json['currents'] as List).cast<num>(),
    );
  }

  @override
  String toString() => 'GridData(power: $power, energy: $energy)';
}

/// Battery detail.
class BatteryDetail {
  /// The power in watts.
  final num power;

  /// The capacity in watt-hours.
  final num capacity;

  /// The state of charge (0-100).
  final num soc;

  /// Whether the battery is controllable.
  final bool controllable;

  /// Creates a new battery detail.
  BatteryDetail({
    required this.power,
    required this.capacity,
    required this.soc,
    required this.controllable,
  });

  /// Creates a battery detail from JSON.
  factory BatteryDetail.fromJson(Map<String, dynamic> json) {
    return BatteryDetail(
      power: json['power'] as num,
      capacity: json['capacity'] as num,
      soc: json['soc'] as num,
      controllable: json['controllable'] as bool,
    );
  }

  @override
  String toString() =>
      'BatteryDetail(power: $power, capacity: $capacity, soc: $soc, controllable: $controllable)';
}

/// Statistics data.
class StatisticsData {
  /// 30-day statistics.
  final PeriodStatistics thirtyDays;

  /// 365-day statistics.
  final PeriodStatistics yearToDate;

  /// This year's statistics.
  final PeriodStatistics thisYear;

  /// Total statistics.
  final PeriodStatistics total;

  /// Creates new statistics data.
  StatisticsData({
    required this.thirtyDays,
    required this.yearToDate,
    required this.thisYear,
    required this.total,
  });

  /// Creates statistics data from JSON.
  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      thirtyDays: PeriodStatistics.fromJson(
        json['30d'] as Map<String, dynamic>,
      ),
      yearToDate: PeriodStatistics.fromJson(
        json['365d'] as Map<String, dynamic>,
      ),
      thisYear: PeriodStatistics.fromJson(
        json['thisYear'] as Map<String, dynamic>,
      ),
      total: PeriodStatistics.fromJson(json['total'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() =>
      'StatisticsData(thirtyDays: $thirtyDays, yearToDate: $yearToDate, thisYear: $thisYear, total: $total)';
}

/// Period statistics.
class PeriodStatistics {
  /// Average CO2 intensity in g/kWh.
  final num avgCo2;

  /// Average price in currency/kWh.
  final num avgPrice;

  /// Charged energy in kWh.
  final num chargedKWh;

  /// Percentage of solar energy.
  final num solarPercentage;

  /// Creates new period statistics.
  PeriodStatistics({
    required this.avgCo2,
    required this.avgPrice,
    required this.chargedKWh,
    required this.solarPercentage,
  });

  /// Creates period statistics from JSON.
  factory PeriodStatistics.fromJson(Map<String, dynamic> json) {
    return PeriodStatistics(
      avgCo2: json['avgCo2'] as num,
      avgPrice: json['avgPrice'] as num,
      chargedKWh: json['chargedKWh'] as num,
      solarPercentage: json['solarPercentage'] as num,
    );
  }

  @override
  String toString() =>
      'PeriodStatistics(avgCo2: $avgCo2, avgPrice: $avgPrice, chargedKWh: $chargedKWh, solarPercentage: $solarPercentage)';
}

/// Battery grid charge active message.
class BatteryGridChargeActiveMessage extends EvccWebSocketMessage {
  /// Whether battery grid charging is active.
  final bool active;

  /// Creates a new battery grid charge active message.
  BatteryGridChargeActiveMessage(this.active);

  @override
  String toString() => 'BatteryGridChargeActiveMessage(active: $active)';
}

/// Battery capacity message.
class BatteryCapacityMessage extends EvccWebSocketMessage {
  /// The battery capacity in kWh.
  final num capacity;

  /// Creates a new battery capacity message.
  BatteryCapacityMessage(this.capacity);

  @override
  String toString() => 'BatteryCapacityMessage(capacity: $capacity)';
}

/// Battery state of charge message.
class BatterySocMessage extends EvccWebSocketMessage {
  /// The battery state of charge (0-100).
  final num soc;

  /// Creates a new battery state of charge message.
  BatterySocMessage(this.soc);

  @override
  String toString() => 'BatterySocMessage(soc: $soc)';
}

/// Battery power message.
class BatteryPowerMessage extends EvccWebSocketMessage {
  /// The battery power in watts.
  final num power;

  /// Creates a new battery power message.
  BatteryPowerMessage(this.power);

  @override
  String toString() => 'BatteryPowerMessage(power: $power)';
}

/// Battery energy message.
class BatteryEnergyMessage extends EvccWebSocketMessage {
  /// The battery energy in watt-hours.
  final num energy;

  /// Creates a new battery energy message.
  BatteryEnergyMessage(this.energy);

  @override
  String toString() => 'BatteryEnergyMessage(energy: $energy)';
}

/// Battery details message.
class BatteryDetailsMessage extends EvccWebSocketMessage {
  /// The battery details.
  final List<BatteryDetail> battery;

  /// Creates a new battery details message.
  BatteryDetailsMessage(this.battery);

  /// Creates a battery details message from JSON.
  factory BatteryDetailsMessage.fromJson(Map<String, dynamic> json) {
    final batteryList =
        (json['battery'] as List)
            .map((e) => BatteryDetail.fromJson(e as Map<String, dynamic>))
            .toList();
    return BatteryDetailsMessage(batteryList);
  }

  @override
  String toString() => 'BatteryDetailsMessage(battery: $battery)';
}

/// Grid details message.
class GridDetailsMessage extends EvccWebSocketMessage {
  /// The grid data.
  final GridData grid;

  /// Creates a new grid details message.
  GridDetailsMessage(this.grid);

  /// Creates a grid details message from JSON.
  factory GridDetailsMessage.fromJson(Map<String, dynamic> json) {
    return GridDetailsMessage(
      GridData.fromJson(json['grid'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() => 'GridDetailsMessage(grid: $grid)';
}

/// Log message.
class LogMessage extends EvccWebSocketMessage {
  /// The log data.
  final LogData log;

  /// Creates a new log message.
  LogMessage(this.log);

  /// Creates a log message from JSON.
  factory LogMessage.fromJson(Map<String, dynamic> json) {
    return LogMessage(LogData.fromJson(json['log'] as Map<String, dynamic>));
  }

  @override
  String toString() => 'LogMessage(log: $log)';
}

/// Log data.
class LogData {
  /// The log message.
  final String message;

  /// The log level.
  final String level;

  /// Creates a new log data.
  LogData({required this.message, required this.level});

  /// Creates log data from JSON.
  factory LogData.fromJson(Map<String, dynamic> json) {
    return LogData(
      message: json['message'] as String,
      level: json['level'] as String,
    );
  }

  @override
  String toString() => 'LogData(message: $message, level: $level)';
}

/// Auxiliary power message.
class AuxPowerMessage extends EvccWebSocketMessage {
  /// The auxiliary power in watts.
  final num auxPower;

  /// Creates a new auxiliary power message.
  AuxPowerMessage(this.auxPower);

  @override
  String toString() => 'AuxPowerMessage(auxPower: $auxPower)';
}

/// Auxiliary device detail.
class AuxDetail {
  /// The power in watts.
  final num power;

  /// The energy in watt-hours.
  final num energy;

  /// Creates a new auxiliary device detail.
  AuxDetail({required this.power, required this.energy});

  /// Creates an auxiliary device detail from JSON.
  factory AuxDetail.fromJson(Map<String, dynamic> json) {
    return AuxDetail(
      power: json['power'] as num,
      energy: json['energy'] as num,
    );
  }

  @override
  String toString() => 'AuxDetail(power: $power, energy: $energy)';
}

/// Auxiliary devices details message.
class AuxDetailsMessage extends EvccWebSocketMessage {
  /// The auxiliary devices details.
  final List<AuxDetail> aux;

  /// Creates a new auxiliary devices details message.
  AuxDetailsMessage(this.aux);

  /// Creates an auxiliary devices details message from JSON.
  factory AuxDetailsMessage.fromJson(Map<String, dynamic> json) {
    final auxList =
        (json['aux'] as List)
            .map((e) => AuxDetail.fromJson(e as Map<String, dynamic>))
            .toList();
    return AuxDetailsMessage(auxList);
  }

  @override
  String toString() => 'AuxDetailsMessage(aux: $aux)';
}
