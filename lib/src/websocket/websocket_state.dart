/// WebSocket state cache for the EVCC API.
library;

import 'dart:async';

/// A cache of WebSocket state data.
class EvccWebSocketState {
  /// The current state data.
  final Map<String, dynamic> _state = {};

  /// Stream controller for state updates.
  final _stateController = StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of state updates.
  Stream<Map<String, dynamic>> get updates => _stateController.stream;

  /// Gets a copy of the current state.
  Map<String, dynamic> get current => Map.from(_state);

  /// Updates the state with a new key-value pair.
  void update(String key, dynamic value) {
    _state[key] = value;
    _stateController.add(current);
  }

  /// Updates the state with multiple key-value pairs.
  void updateAll(Map<String, dynamic> updates) {
    _state.addAll(updates);
    _stateController.add(current);
  }

  /// Clears the state.
  void clear() {
    _state.clear();
    _stateController.add(current);
  }

  /// Gets the PV power in watts.
  num? get pvPower => _state['pvPower'] as num?;

  /// Gets the PV energy in watt-hours.
  num? get pvEnergy => _state['pvEnergy'] as num?;

  /// Gets the home power in watts.
  num? get homePower => _state['homePower'] as num?;

  /// Gets the battery state of charge (0-100).
  num? get batterySoc => _state['batterySoc'] as num?;

  /// Gets the battery power in watts.
  num? get batteryPower => _state['batteryPower'] as num?;

  /// Gets the battery energy in watt-hours.
  num? get batteryEnergy => _state['batteryEnergy'] as num?;

  /// Gets the green share of home energy (0-1).
  num? get greenShareHome => _state['greenShareHome'] as num?;

  /// Gets the green share of loadpoint energy (0-1).
  num? get greenShareLoadpoints => _state['greenShareLoadpoints'] as num?;

  /// Gets the grid electricity price in currency/kWh.
  num? get tariffGrid => _state['tariffGrid'] as num?;

  /// Gets the CO2 intensity of grid electricity in g/kWh.
  num? get tariffCo2 => _state['tariffCo2'] as num?;

  /// Gets the solar electricity price/value in currency/kWh.
  num? get tariffSolar => _state['tariffSolar'] as num?;

  /// Gets the home electricity price in currency/kWh.
  num? get tariffPriceHome => _state['tariffPriceHome'] as num?;

  /// Gets the CO2 intensity of home electricity in g/kWh.
  num? get tariffCo2Home => _state['tariffCo2Home'] as num?;

  /// Gets the loadpoint electricity price in currency/kWh.
  num? get tariffPriceLoadpoints => _state['tariffPriceLoadpoints'] as num?;

  /// Gets the CO2 intensity of loadpoint electricity in g/kWh.
  num? get tariffCo2Loadpoints => _state['tariffCo2Loadpoints'] as num?;

  /// Gets the auxiliary power in watts.
  num? get auxPower => _state['auxPower'] as num?;

  /// Gets the site title.
  String? get siteTitle => _state['siteTitle'] as String?;

  /// Gets the system version.
  String? get version => _state['version'] as String?;

  /// Gets the currency used for pricing.
  String? get currency => _state['currency'] as String?;

  /// Gets all loadpoint properties for a specific index.
  Map<String, dynamic> getLoadpointProperties(int index) {
    final result = <String, dynamic>{};
    final prefix = 'loadpoints.$index.';

    for (final entry in _state.entries) {
      if (entry.key.startsWith(prefix)) {
        final property = entry.key.substring(prefix.length);
        result[property] = entry.value;
      }
    }

    return result;
  }

  /// Gets a loadpoint property by index and property name.
  dynamic getLoadpointProperty(int index, String property) {
    return _state['loadpoints.$index.$property'];
  }

  /// Gets the number of loadpoints in the system.
  int get loadpointCount {
    final loadpointIndices = <int>{};

    for (final key in _state.keys) {
      if (key.startsWith('loadpoints.')) {
        final match = RegExp(r'loadpoints\.(\d+)\.').firstMatch(key);
        if (match != null) {
          loadpointIndices.add(int.parse(match.group(1)!));
        }
      }
    }

    return loadpointIndices.length;
  }

  /// Closes the state controller.
  void dispose() {
    _stateController.close();
  }
}
