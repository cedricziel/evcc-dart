import 'package:evcc_api/evcc_api.dart';
import 'package:test/test.dart';

void main() {
  group('EvccWebSocketMessage', () {
    test('fromJsonString should parse PvPowerMessage correctly', () {
      // Arrange
      const jsonString = '{"pvPower":170.7}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<PvPowerMessage>());
      expect((message as PvPowerMessage).pvPower, 170.7);
    });

    test('fromJsonString should parse PvEnergyMessage correctly', () {
      // Arrange
      const jsonString = '{"pvEnergy":200.819}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<PvEnergyMessage>());
      expect((message as PvEnergyMessage).pvEnergy, 200.819);
    });

    test('fromJsonString should parse PvDetailsMessage correctly', () {
      // Arrange
      const jsonString =
          '{"pv":[{"power":0},{"power":170.699996948242,"energy":200.818908691406}]}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<PvDetailsMessage>());

      final pvMessage = message as PvDetailsMessage;
      expect(pvMessage.pv.length, 2);
      expect(pvMessage.pv[0].power, 0);
      expect(pvMessage.pv[0].energy, null);
      expect(pvMessage.pv[1].power, 170.699996948242);
      expect(pvMessage.pv[1].energy, 200.818908691406);
    });

    test('fromJsonString should parse HomePowerMessage correctly', () {
      // Arrange
      const jsonString = '{"homePower":0}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<HomePowerMessage>());
      expect((message as HomePowerMessage).homePower, 0);
    });

    test('fromJsonString should parse LoadpointMessage correctly', () {
      // Arrange
      const jsonString = '{"loadpoints.0.smartCostActive":false}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<LoadpointMessage>());

      final lpMessage = message as LoadpointMessage;
      expect(lpMessage.path, 'loadpoints.0.smartCostActive');
      expect(lpMessage.value, false);
      expect(lpMessage.loadpointIndex, 0);
      expect(lpMessage.property, 'smartCostActive');
    });

    test('fromJsonString should handle null value for loadpoint', () {
      // Arrange
      const jsonString = '{"loadpoints.0.smartCostNextStart":null}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<LoadpointMessage>());

      final lpMessage = message as LoadpointMessage;
      expect(lpMessage.path, 'loadpoints.0.smartCostNextStart');
      expect(lpMessage.value, null);
      expect(lpMessage.loadpointIndex, 0);
      expect(lpMessage.property, 'smartCostNextStart');
    });

    test(
      'fromJsonString should handle unknown message types as GenericMessage',
      () {
        // Arrange
        const jsonString = '{"unknownType":123}';

        // Act
        final message = EvccWebSocketMessage.fromJsonString(jsonString);

        // Assert
        expect(message, isA<GenericMessage>());
        expect((message as GenericMessage).data, {'unknownType': 123});
      },
    );

    test('fromJsonString should return null for invalid JSON', () {
      // Arrange
      const jsonString = 'invalid json';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isNull);
    });

    test('fromJsonString should return null for non-object JSON', () {
      // Arrange
      const jsonString = '[1, 2, 3]';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isNull);
    });

    test('PvDetail toString should return a readable string', () {
      // Arrange
      final detail = PvDetail(power: 100, energy: 200);

      // Act
      final result = detail.toString();

      // Assert
      expect(result, 'PvDetail(power: 100, energy: 200)');
    });

    test('AuxDetail toString should return a readable string', () {
      // Arrange
      final detail = AuxDetail(power: 200, energy: 500);

      // Act
      final result = detail.toString();

      // Assert
      expect(result, 'AuxDetail(power: 200, energy: 500)');
    });

    test('AuxDetailsMessage toString should return a readable string', () {
      // Arrange
      final aux = [
        AuxDetail(power: 200, energy: 500),
        AuxDetail(power: 50, energy: 300),
      ];
      final message = AuxDetailsMessage(aux);

      // Act
      final result = message.toString();

      // Assert
      expect(result, 'AuxDetailsMessage(aux: $aux)');
    });

    test('LoadpointMessage should extract index and property correctly', () {
      // Arrange
      final message = LoadpointMessage('loadpoints.5.someProperty', 'value');

      // Act & Assert
      expect(message.loadpointIndex, 5);
      expect(message.property, 'someProperty');
    });

    test('LoadpointMessage should handle invalid path format', () {
      // Arrange
      final message = LoadpointMessage('invalid.path', 'value');

      // Act & Assert
      expect(message.loadpointIndex, -1);
      expect(message.property, 'invalid.path');
    });

    test('fromJsonString should parse ForecastMessage correctly', () {
      // Arrange
      const jsonString =
          '{"forecast":{"co2":[{"start":"2025-03-16T14:00:00+01:00","end":"2025-03-16T15:00:00+01:00","price":232}],"grid":[{"start":"2025-03-16T00:00:00+01:00","end":"2025-03-16T01:00:00+01:00","price":0.3002}],"solar":{"today":{"energy":2189.694489119848,"complete":true},"tomorrow":{"energy":10710.83241949696,"complete":true},"dayAfterTomorrow":{"energy":13475.58364475794,"complete":false},"timeseries":[{"ts":"2025-03-16T14:00:00+01:00","val":1533.71240092698}]}}}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<ForecastMessage>());

      final forecastMessage = message as ForecastMessage;
      expect(forecastMessage.co2.length, 1);
      expect(forecastMessage.co2.first.price, 232);
      expect(forecastMessage.grid.length, 1);
      expect(forecastMessage.grid.first.price, 0.3002);
      expect(forecastMessage.solar.today.energy, 2189.694489119848);
      expect(forecastMessage.solar.today.complete, true);
      expect(forecastMessage.solar.tomorrow.energy, 10710.83241949696);
      expect(forecastMessage.solar.tomorrow.complete, true);
      expect(forecastMessage.solar.dayAfterTomorrow.energy, 13475.58364475794);
      expect(forecastMessage.solar.dayAfterTomorrow.complete, false);
      expect(forecastMessage.solar.timeseries.length, 1);
      expect(forecastMessage.solar.timeseries.first.value, 1533.71240092698);
    });

    test('fromJsonString should parse GreenShareHomeMessage correctly', () {
      // Arrange
      const jsonString = '{"greenShareHome":1}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<GreenShareHomeMessage>());
      expect((message as GreenShareHomeMessage).percentage, 1);
    });

    test(
      'fromJsonString should parse GreenShareLoadpointsMessage correctly',
      () {
        // Arrange
        const jsonString = '{"greenShareLoadpoints":0.133}';

        // Act
        final message = EvccWebSocketMessage.fromJsonString(jsonString);

        // Assert
        expect(message, isA<GreenShareLoadpointsMessage>());
        expect((message as GreenShareLoadpointsMessage).percentage, 0.133);
      },
    );

    test('fromJsonString should parse TariffGridMessage correctly', () {
      // Arrange
      const jsonString = '{"tariffGrid":0.196}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<TariffGridMessage>());
      expect((message as TariffGridMessage).price, 0.196);
    });

    test('fromJsonString should parse TariffCo2Message correctly', () {
      // Arrange
      const jsonString = '{"tariffCo2":232}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<TariffCo2Message>());
      expect((message as TariffCo2Message).intensity, 232);
    });

    test('fromJsonString should parse TariffSolarMessage correctly', () {
      // Arrange
      const jsonString = '{"tariffSolar":1533.712}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<TariffSolarMessage>());
      expect((message as TariffSolarMessage).price, 1533.712);
    });

    test('fromJsonString should parse TariffPriceHomeMessage correctly', () {
      // Arrange
      const jsonString = '{"tariffPriceHome":0}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<TariffPriceHomeMessage>());
      expect((message as TariffPriceHomeMessage).price, 0);
    });

    test('fromJsonString should parse TariffCo2HomeMessage correctly', () {
      // Arrange
      const jsonString = '{"tariffCo2Home":0}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<TariffCo2HomeMessage>());
      expect((message as TariffCo2HomeMessage).intensity, 0);
    });

    test(
      'fromJsonString should parse TariffPriceLoadpointsMessage correctly',
      () {
        // Arrange
        const jsonString = '{"tariffPriceLoadpoints":0.17}';

        // Act
        final message = EvccWebSocketMessage.fromJsonString(jsonString);

        // Assert
        expect(message, isA<TariffPriceLoadpointsMessage>());
        expect((message as TariffPriceLoadpointsMessage).price, 0.17);
      },
    );

    test(
      'fromJsonString should parse TariffCo2LoadpointsMessage correctly',
      () {
        // Arrange
        const jsonString = '{"tariffCo2Loadpoints":201.049}';

        // Act
        final message = EvccWebSocketMessage.fromJsonString(jsonString);

        // Assert
        expect(message, isA<TariffCo2LoadpointsMessage>());
        expect((message as TariffCo2LoadpointsMessage).intensity, 201.049);
      },
    );

    test('fromJsonString should parse AuxPowerMessage correctly', () {
      // Arrange
      const jsonString = '{"auxPower":251.4}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<AuxPowerMessage>());
      expect((message as AuxPowerMessage).auxPower, 251.4);
    });

    test('fromJsonString should parse AuxDetailsMessage correctly', () {
      // Arrange
      const jsonString =
          '{"aux":[{"power":203,"energy":581.64},{"power":48.4000015258789,"energy":288.810577392578}]}';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<AuxDetailsMessage>());

      final auxMessage = message as AuxDetailsMessage;
      expect(auxMessage.aux.length, 2);
      expect(auxMessage.aux[0].power, 203);
      expect(auxMessage.aux[0].energy, 581.64);
      expect(auxMessage.aux[1].power, 48.4000015258789);
      expect(auxMessage.aux[1].energy, 288.810577392578);
    });

    test('fromJsonString should parse FullStateMessage correctly', () {
      // Arrange
      const jsonString = '''
      {
        "currency":"EUR",
        "version":"0.200.9",
        "siteTitle":"Home",
        "pvPower":180,
        "pvEnergy":200.899,
        "homePower":0,
        "batterySoc":20,
        "batteryPower":6,
        "batteryEnergy":0,
        "greenShareHome":1,
        "greenShareLoadpoints":0.132,
        "tariffGrid":0.196,
        "tariffCo2":232,
        "tariffSolar":1533.712,
        "tariffPriceHome":0,
        "tariffCo2Home":0,
        "tariffPriceLoadpoints":0.17,
        "tariffCo2Loadpoints":201.277,
        "grid":{
          "power":4.41,
          "energy":2041.0303999999999,
          "powers":[19.84,-40.83,25.4],
          "currents":[0.34,-0.85,0.2]
        },
        "battery":[
          {"power":6,"capacity":0,"soc":20,"controllable":false}
        ],
        "pv":[
          {"power":0},
          {"power":180,"energy":200.898864746094}
        ],
        "loadpoints.0.minCurrent":6,
        "loadpoints.0.maxCurrent":16,
        "loadpoints.0.charging":true,
        "loadpoints.0.connected":true,
        "loadpoints.0.vehicleSoc":61,
        "loadpoints.0.vehicleName":"speedy"
      }
      ''';

      // Act
      final message = EvccWebSocketMessage.fromJsonString(jsonString);

      // Assert
      expect(message, isA<FullStateMessage>());

      final fullStateMessage = message as FullStateMessage;
      expect(fullStateMessage.version, '0.200.9');
      expect(fullStateMessage.siteTitle, 'Home');
      expect(fullStateMessage.currency, 'EUR');
      expect(fullStateMessage.pvPower, 180);
      expect(fullStateMessage.pvEnergy, 200.899);
      expect(fullStateMessage.homePower, 0);
      expect(fullStateMessage.batterySoc, 20);
      expect(fullStateMessage.batteryPower, 6);
      expect(fullStateMessage.batteryEnergy, 0);
      expect(fullStateMessage.greenShareHome, 1);
      expect(fullStateMessage.greenShareLoadpoints, 0.132);
      expect(fullStateMessage.tariffGrid, 0.196);
      expect(fullStateMessage.tariffCo2, 232);
      expect(fullStateMessage.tariffSolar, 1533.712);
      expect(fullStateMessage.tariffPriceHome, 0);
      expect(fullStateMessage.tariffCo2Home, 0);
      expect(fullStateMessage.tariffPriceLoadpoints, 0.17);
      expect(fullStateMessage.tariffCo2Loadpoints, 201.277);

      // Check grid data
      expect(fullStateMessage.grid, isNotNull);
      expect(fullStateMessage.grid!.power, 4.41);
      expect(fullStateMessage.grid!.energy, 2041.0303999999999);
      expect(fullStateMessage.grid!.powers, [19.84, -40.83, 25.4]);
      expect(fullStateMessage.grid!.currents, [0.34, -0.85, 0.2]);

      // Check battery data
      expect(fullStateMessage.battery, isNotNull);
      expect(fullStateMessage.battery!.length, 1);
      expect(fullStateMessage.battery![0].power, 6);
      expect(fullStateMessage.battery![0].capacity, 0);
      expect(fullStateMessage.battery![0].soc, 20);
      expect(fullStateMessage.battery![0].controllable, false);

      // Check PV data
      expect(fullStateMessage.pv, isNotNull);
      expect(fullStateMessage.pv!.length, 2);
      expect(fullStateMessage.pv![0].power, 0);
      expect(fullStateMessage.pv![0].energy, null);
      expect(fullStateMessage.pv![1].power, 180);
      expect(fullStateMessage.pv![1].energy, 200.898864746094);

      // Check loadpoint data
      expect(fullStateMessage.loadpointCount, 1);
      expect(fullStateMessage.getLoadpointProperty(0, 'minCurrent'), 6);
      expect(fullStateMessage.getLoadpointProperty(0, 'maxCurrent'), 16);
      expect(fullStateMessage.getLoadpointProperty(0, 'charging'), true);
      expect(fullStateMessage.getLoadpointProperty(0, 'connected'), true);
      expect(fullStateMessage.getLoadpointProperty(0, 'vehicleSoc'), 61);
      expect(fullStateMessage.getLoadpointProperty(0, 'vehicleName'), 'speedy');

      // Check loadpoint properties map
      final loadpointProps = fullStateMessage.getLoadpointProperties(0);
      expect(loadpointProps.length, 6);
      expect(loadpointProps['minCurrent'], 6);
      expect(loadpointProps['maxCurrent'], 16);
      expect(loadpointProps['charging'], true);
      expect(loadpointProps['connected'], true);
      expect(loadpointProps['vehicleSoc'], 61);
      expect(loadpointProps['vehicleName'], 'speedy');
    });
  });
}
