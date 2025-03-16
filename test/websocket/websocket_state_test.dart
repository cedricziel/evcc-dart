import 'package:evcc_api/evcc_api.dart';
import 'package:test/test.dart';

void main() {
  group('EvccWebSocketState', () {
    late EvccWebSocketState state;

    setUp(() {
      state = EvccWebSocketState();
    });

    test('should update state correctly', () {
      // Act
      state.update('pvPower', 1000);

      // Assert
      expect(state.pvPower, 1000);
      expect(state.current['pvPower'], 1000);
    });

    test('should update multiple values', () {
      // Act
      state.updateAll({'pvPower': 1000, 'homePower': 500, 'batterySoc': 75});

      // Assert
      expect(state.pvPower, 1000);
      expect(state.homePower, 500);
      expect(state.batterySoc, 75);
    });

    test('should emit updates', () async {
      // Arrange
      final updates = <Map<String, dynamic>>[];
      final subscription = state.updates.listen(updates.add);

      // Act
      state.update('pvPower', 1000);
      state.update('homePower', 500);

      // Wait for updates to be processed
      await Future.delayed(Duration.zero);

      // Assert
      expect(updates.length, 2);
      expect(updates[0]['pvPower'], 1000);
      expect(updates[1]['pvPower'], 1000);
      expect(updates[1]['homePower'], 500);

      // Cleanup
      await subscription.cancel();
    });

    test('should clear state', () {
      // Arrange
      state.update('pvPower', 1000);
      state.update('homePower', 500);
      expect(state.current.length, 2);

      // Act
      state.clear();

      // Assert
      expect(state.current.isEmpty, true);
      expect(state.pvPower, null);
      expect(state.homePower, null);
    });

    test('should handle loadpoint properties', () {
      // Arrange
      state.update('loadpoints.0.charging', true);
      state.update('loadpoints.0.connected', true);
      state.update('loadpoints.0.vehicleSoc', 75);
      state.update('loadpoints.1.charging', false);

      // Act & Assert
      expect(state.loadpointCount, 2);

      final lp0 = state.getLoadpointProperties(0);
      expect(lp0.length, 3);
      expect(lp0['charging'], true);
      expect(lp0['connected'], true);
      expect(lp0['vehicleSoc'], 75);

      final lp1 = state.getLoadpointProperties(1);
      expect(lp1.length, 1);
      expect(lp1['charging'], false);

      expect(state.getLoadpointProperty(0, 'charging'), true);
      expect(state.getLoadpointProperty(0, 'vehicleSoc'), 75);
      expect(state.getLoadpointProperty(1, 'charging'), false);
      expect(state.getLoadpointProperty(1, 'nonexistent'), null);
    });

    test('should provide helper getters', () {
      // Arrange
      state.updateAll({
        'pvPower': 1000,
        'pvEnergy': 5000,
        'homePower': 500,
        'batterySoc': 75,
        'batteryPower': 200,
        'batteryEnergy': 1000,
        'greenShareHome': 0.8,
        'greenShareLoadpoints': 0.6,
        'tariffGrid': 0.30,
        'tariffCo2': 250,
        'tariffSolar': 0.10,
        'tariffPriceHome': 0.25,
        'tariffCo2Home': 200,
        'tariffPriceLoadpoints': 0.28,
        'tariffCo2Loadpoints': 220,
        'auxPower': 100,
        'siteTitle': 'Home',
        'version': '1.0.0',
        'currency': 'EUR',
      });

      // Act & Assert
      expect(state.pvPower, 1000);
      expect(state.pvEnergy, 5000);
      expect(state.homePower, 500);
      expect(state.batterySoc, 75);
      expect(state.batteryPower, 200);
      expect(state.batteryEnergy, 1000);
      expect(state.greenShareHome, 0.8);
      expect(state.greenShareLoadpoints, 0.6);
      expect(state.tariffGrid, 0.30);
      expect(state.tariffCo2, 250);
      expect(state.tariffSolar, 0.10);
      expect(state.tariffPriceHome, 0.25);
      expect(state.tariffCo2Home, 200);
      expect(state.tariffPriceLoadpoints, 0.28);
      expect(state.tariffCo2Loadpoints, 220);
      expect(state.auxPower, 100);
      expect(state.siteTitle, 'Home');
      expect(state.version, '1.0.0');
      expect(state.currency, 'EUR');
    });
  });
}
