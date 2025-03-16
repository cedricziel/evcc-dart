import 'dart:convert';

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

    test('should capture all state from complete JSON payload', () {
      // Arrange - The complete JSON payload from a real system
      final jsonPayload = '''
      {"bufferSoc":80,"loadpoints.0.chargerPhases1p3p":true,"loadpoints.0.smartCostActive":false,"tariffGrid":0.23,"smartCostType":"priceforecast","loadpoints.0.chargedEnergy":426,"loadpoints.0.chargeTotalImport":5408.296,"mqtt":{"broker":"core-mosquitto:1883","topic":"evcc","user":"evcc"},"ext":[],"loadpoints.0.chargerSinglePhase":false,"loadpoints.0.vehicleOdometer":0,"batteryPower":6,"pvPower":210.4,"loadpoints.0.sessionPrice":0.08,"loadpoints.0.effectiveMinCurrent":6,"siteTitle":"Home","batteryMode":"unknown","currency":"EUR","loadpoints.0.disableThreshold":0,"loadpoints.0.chargerIcon":null,"batteryGridChargeActive":false,"batteryCapacity":1,"batteryEnergy":0,"loadpoints.0.maxCurrent":16,"loadpoints.0.pvAction":"inactive","loadpoints.0.chargeCurrent":8,"loadpoints.0.sessionCo2PerKWh":214.746,"loadpoints.0.charging":true,"tariffPriceLoadpoints":0.194,"tariffCo2Loadpoints":221.309,"interval":10,"gridConfigured":true,"vehicles":{"kona":{"title":"Kona","icon":"car","capacity":39,"features":["Offline"],"repeatingPlans":[]},"speedy":{"title":"Speedy","icon":"car","features":["CoarseCurrent"],"repeatingPlans":[]}},"loadpoints.0.chargerFeatureHeating":false,"batterySoc":20,"loadpoints.0.sessionSolarPercentage":15.785,"loadpoints.0.effectivePlanTime":null,"loadpoints.0.planProjectedEnd":null,"network":{"schema":"http","host":"evcc.local","port":7070},"loadpoints.0.phaseAction":"inactive","loadpoints.0.chargerFeatureIntegratedDevice":false,"loadpoints.0.planTime":null,"loadpoints.0.enabled":true,"loadpoints.0.planOverrun":0,"greenShareLoadpoints":0.155,"forecast":{"co2":[{"start":"2025-03-16T15:00:00+01:00","end":"2025-03-16T16:00:00+01:00","price":262},{"start":"2025-03-16T16:00:00+01:00","end":"2025-03-16T17:00:00+01:00","price":262},{"start":"2025-03-16T17:00:00+01:00","end":"2025-03-16T18:00:00+01:00","price":262},{"start":"2025-03-16T18:00:00+01:00","end":"2025-03-16T19:00:00+01:00","price":262},{"start":"2025-03-16T19:00:00+01:00","end":"2025-03-16T20:00:00+01:00","price":262},{"start":"2025-03-16T20:00:00+01:00","end":"2025-03-16T21:00:00+01:00","price":262},{"start":"2025-03-16T21:00:00+01:00","end":"2025-03-16T22:00:00+01:00","price":262},{"start":"2025-03-16T22:00:00+01:00","end":"2025-03-16T23:00:00+01:00","price":262},{"start":"2025-03-16T23:00:00+01:00","end":"2025-03-17T00:00:00+01:00","price":262},{"start":"2025-03-17T00:00:00+01:00","end":"2025-03-17T01:00:00+01:00","price":262},{"start":"2025-03-17T01:00:00+01:00","end":"2025-03-17T02:00:00+01:00","price":262},{"start":"2025-03-17T02:00:00+01:00","end":"2025-03-17T03:00:00+01:00","price":262},{"start":"2025-03-17T03:00:00+01:00","end":"2025-03-17T04:00:00+01:00","price":262},{"start":"2025-03-17T04:00:00+01:00","end":"2025-03-17T05:00:00+01:00","price":262},{"start":"2025-03-17T05:00:00+01:00","end":"2025-03-17T06:00:00+01:00","price":262},{"start":"2025-03-17T06:00:00+01:00","end":"2025-03-17T07:00:00+01:00","price":262},{"start":"2025-03-17T07:00:00+01:00","end":"2025-03-17T08:00:00+01:00","price":262},{"start":"2025-03-17T08:00:00+01:00","end":"2025-03-17T09:00:00+01:00","price":262},{"start":"2025-03-17T09:00:00+01:00","end":"2025-03-17T10:00:00+01:00","price":262},{"start":"2025-03-17T10:00:00+01:00","end":"2025-03-17T11:00:00+01:00","price":262},{"start":"2025-03-17T11:00:00+01:00","end":"2025-03-17T12:00:00+01:00","price":262},{"start":"2025-03-17T12:00:00+01:00","end":"2025-03-17T13:00:00+01:00","price":262},{"start":"2025-03-17T13:00:00+01:00","end":"2025-03-17T14:00:00+01:00","price":262},{"start":"2025-03-17T14:00:00+01:00","end":"2025-03-17T15:00:00+01:00","price":262},{"start":"2025-03-17T15:00:00+01:00","end":"2025-03-17T16:00:00+01:00","price":262},{"start":"2025-03-17T16:00:00+01:00","end":"2025-03-17T17:00:00+01:00","price":262},{"start":"2025-03-17T17:00:00+01:00","end":"2025-03-17T18:00:00+01:00","price":262},{"start":"2025-03-17T18:00:00+01:00","end":"2025-03-17T19:00:00+01:00","price":262},{"start":"2025-03-17T19:00:00+01:00","end":"2025-03-17T20:00:00+01:00","price":262},{"start":"2025-03-17T20:00:00+01:00","end":"2025-03-17T21:00:00+01:00","price":262},{"start":"2025-03-17T21:00:00+01:00","end":"2025-03-17T22:00:00+01:00","price":262},{"start":"2025-03-17T22:00:00+01:00","end":"2025-03-17T23:00:00+01:00","price":262},{"start":"2025-03-17T23:00:00+01:00","end":"2025-03-18T00:00:00+01:00","price":262},{"start":"2025-03-18T00:00:00+01:00","end":"2025-03-18T01:00:00+01:00","price":262},{"start":"2025-03-18T01:00:00+01:00","end":"2025-03-18T02:00:00+01:00","price":262},{"start":"2025-03-18T02:00:00+01:00","end":"2025-03-18T03:00:00+01:00","price":262},{"start":"2025-03-18T03:00:00+01:00","end":"2025-03-18T04:00:00+01:00","price":262},{"start":"2025-03-18T04:00:00+01:00","end":"2025-03-18T05:00:00+01:00","price":262},{"start":"2025-03-18T05:00:00+01:00","end":"2025-03-18T06:00:00+01:00","price":262},{"start":"2025-03-18T06:00:00+01:00","end":"2025-03-18T07:00:00+01:00","price":262},{"start":"2025-03-18T07:00:00+01:00","end":"2025-03-18T08:00:00+01:00","price":262},{"start":"2025-03-18T08:00:00+01:00","end":"2025-03-18T09:00:00+01:00","price":262},{"start":"2025-03-18T09:00:00+01:00","end":"2025-03-18T10:00:00+01:00","price":262},{"start":"2025-03-18T10:00:00+01:00","end":"2025-03-18T11:00:00+01:00","price":262},{"start":"2025-03-18T11:00:00+01:00","end":"2025-03-18T12:00:00+01:00","price":262},{"start":"2025-03-18T12:00:00+01:00","end":"2025-03-18T13:00:00+01:00","price":262},{"start":"2025-03-18T13:00:00+01:00","end":"2025-03-18T14:00:00+01:00","price":262},{"start":"2025-03-18T14:00:00+01:00","end":"2025-03-18T15:00:00+01:00","price":262}],"grid":[{"start":"2025-03-16T00:00:00+01:00","end":"2025-03-16T01:00:00+01:00","price":0.3002},{"start":"2025-03-16T01:00:00+01:00","end":"2025-03-16T02:00:00+01:00","price":0.2952},{"start":"2025-03-16T02:00:00+01:00","end":"2025-03-16T03:00:00+01:00","price":0.2879},{"start":"2025-03-16T03:00:00+01:00","end":"2025-03-16T04:00:00+01:00","price":0.2861},{"start":"2025-03-16T04:00:00+01:00","end":"2025-03-16T05:00:00+01:00","price":0.2866},{"start":"2025-03-16T05:00:00+01:00","end":"2025-03-16T06:00:00+01:00","price":0.2889},{"start":"2025-03-16T06:00:00+01:00","end":"2025-03-16T07:00:00+01:00","price":0.2944},{"start":"2025-03-16T07:00:00+01:00","end":"2025-03-16T08:00:00+01:00","price":0.2908},{"start":"2025-03-16T08:00:00+01:00","end":"2025-03-16T09:00:00+01:00","price":0.2859},{"start":"2025-03-16T09:00:00+01:00","end":"2025-03-16T10:00:00+01:00","price":0.2608},{"start":"2025-03-16T10:00:00+01:00","end":"2025-03-16T11:00:00+01:00","price":0.2218},{"start":"2025-03-16T11:00:00+01:00","end":"2025-03-16T12:00:00+01:00","price":0.1966},{"start":"2025-03-16T12:00:00+01:00","end":"2025-03-16T13:00:00+01:00","price":0.1943},{"start":"2025-03-16T13:00:00+01:00","end":"2025-03-16T14:00:00+01:00","price":0.1933},{"start":"2025-03-16T14:00:00+01:00","end":"2025-03-16T15:00:00+01:00","price":0.1961},{"start":"2025-03-16T15:00:00+01:00","end":"2025-03-16T16:00:00+01:00","price":0.23},{"start":"2025-03-16T16:00:00+01:00","end":"2025-03-16T17:00:00+01:00","price":0.2777},{"start":"2025-03-16T17:00:00+01:00","end":"2025-03-16T18:00:00+01:00","price":0.3321},{"start":"2025-03-16T18:00:00+01:00","end":"2025-03-16T19:00:00+01:00","price":0.3488},{"start":"2025-03-16T19:00:00+01:00","end":"2025-03-16T20:00:00+01:00","price":0.3597},{"start":"2025-03-16T20:00:00+01:00","end":"2025-03-16T21:00:00+01:00","price":0.3422},{"start":"2025-03-16T21:00:00+01:00","end":"2025-03-16T22:00:00+01:00","price":0.3213},{"start":"2025-03-16T22:00:00+01:00","end":"2025-03-16T23:00:00+01:00","price":0.3131},{"start":"2025-03-16T23:00:00+01:00","end":"2025-03-17T00:00:00+01:00","price":0.288},{"start":"2025-03-17T00:00:00+01:00","end":"2025-03-17T01:00:00+01:00","price":0.2861},{"start":"2025-03-17T01:00:00+01:00","end":"2025-03-17T02:00:00+01:00","price":0.2871},{"start":"2025-03-17T02:00:00+01:00","end":"2025-03-17T03:00:00+01:00","price":0.2869},{"start":"2025-03-17T03:00:00+01:00","end":"2025-03-17T04:00:00+01:00","price":0.2894},{"start":"2025-03-17T04:00:00+01:00","end":"2025-03-17T05:00:00+01:00","price":0.2953},{"start":"2025-03-17T05:00:00+01:00","end":"2025-03-17T06:00:00+01:00","price":0.316},{"start":"2025-03-17T06:00:00+01:00","end":"2025-03-17T07:00:00+01:00","price":0.354},{"start":"2025-03-17T07:00:00+01:00","end":"2025-03-17T08:00:00+01:00","price":0.375},{"start":"2025-03-17T08:00:00+01:00","end":"2025-03-17T09:00:00+01:00","price":0.354},{"start":"2025-03-17T09:00:00+01:00","end":"2025-03-17T10:00:00+01:00","price":0.313},{"start":"2025-03-17T10:00:00+01:00","end":"2025-03-17T11:00:00+01:00","price":0.2743},{"start":"2025-03-17T11:00:00+01:00","end":"2025-03-17T12:00:00+01:00","price":0.2533},{"start":"2025-03-17T12:00:00+01:00","end":"2025-03-17T13:00:00+01:00","price":0.2302},{"start":"2025-03-17T13:00:00+01:00","end":"2025-03-17T14:00:00+01:00","price":0.2264},{"start":"2025-03-17T14:00:00+01:00","end":"2025-03-17T15:00:00+01:00","price":0.2528},{"start":"2025-03-17T15:00:00+01:00","end":"2025-03-17T16:00:00+01:00","price":0.2764},{"start":"2025-03-17T16:00:00+01:00","end":"2025-03-17T17:00:00+01:00","price":0.3104},{"start":"2025-03-17T17:00:00+01:00","end":"2025-03-17T18:00:00+01:00","price":0.3633},{"start":"2025-03-17T18:00:00+01:00","end":"2025-03-17T19:00:00+01:00","price":0.4041},{"start":"2025-03-17T19:00:00+01:00","end":"2025-03-17T20:00:00+01:00","price":0.3954},{"start":"2025-03-17T20:00:00+01:00","end":"2025-03-17T21:00:00+01:00","price":0.3615},{"start":"2025-03-17T21:00:00+01:00","end":"2025-03-17T22:00:00+01:00","price":0.3345},{"start":"2025-03-17T22:00:00+01:00","end":"2025-03-17T23:00:00+01:00","price":0.3215},{"start":"2025-03-17T23:00:00+01:00","end":"2025-03-18T00:00:00+01:00","price":0.3044}],"solar":{"today":{"energy":1440.8490576581432,"complete":true},"tomorrow":{"energy":10710.83241949696,"complete":true},"dayAfterTomorrow":{"energy":13475.58364475794,"complete":false},"timeseries":[{"ts":"2025-03-15T23:00:00+01:00","val":0},{"ts":"2025-03-16T00:00:00+01:00","val":0},{"ts":"2025-03-16T01:00:00+01:00","val":0},{"ts":"2025-03-16T02:00:00+01:00","val":0},{"ts":"2025-03-16T03:00:00+01:00","val":0},{"ts":"2025-03-16T04:00:00+01:00","val":0},{"ts":"2025-03-16T05:00:00+01:00","val":0},{"ts":"2025-03-16T06:00:00+01:00","val":3.9887988919199997},{"ts":"2025-03-16T07:00:00+01:00","val":226.62809387008002},{"ts":"2025-03-16T08:00:00+01:00","val":500.02729936249995},{"ts":"2025-03-16T09:00:00+01:00","val":1088.8246709145},{"ts":"2025-03-16T10:00:00+01:00","val":1489.4132126067202},{"ts":"2025-03-16T11:00:00+01:00","val":1705.97061183258},{"ts":"2025-03-16T12:00:00+01:00","val":1821.57768725818},{"ts":"2025-03-16T13:00:00+01:00","val":1759.53567176352},{"ts":"2025-03-16T14:00:00+01:00","val":1533.71240092698},{"ts":"2025-03-16T15:00:00+01:00","val":1116.6249009545},{"ts":"2025-03-16T16:00:00+01:00","val":779.1277124599201},{"ts":"2025-03-16T17:00:00+01:00","val":335.6261116132201},{"ts":"2025-03-16T18:00:00+01:00","val":31.111010064420004},{"ts":"2025-03-16T19:00:00+01:00","val":0},{"ts":"2025-03-16T20:00:00+01:00","val":0},{"ts":"2025-03-16T21:00:00+01:00","val":0},{"ts":"2025-03-16T22:00:00+01:00","val":0},{"ts":"2025-03-16T23:00:00+01:00","val":0},{"ts":"2025-03-17T00:00:00+01:00","val":0},{"ts":"2025-03-17T01:00:00+01:00","val":0},{"ts":"2025-03-17T02:00:00+01:00","val":0},{"ts":"2025-03-17T03:00:00+01:00","val":0},{"ts":"2025-03-17T04:00:00+01:00","val":0},{"ts":"2025-03-17T05:00:00+01:00","val":0},{"ts":"2025-03-17T06:00:00+01:00","val":3.9499188919200003},{"ts":"2025-03-17T07:00:00+01:00","val":83.65186354938},{"ts":"2025-03-17T08:00:00+01:00","val":154.17430499328},{"ts":"2025-03-17T09:00:00+01:00","val":258.8465975505},{"ts":"2025-03-17T10:00:00+01:00","val":614.59630489482},{"ts":"2025-03-17T11:00:00+01:00","val":1713.44137234848},{"ts":"2025-03-17T12:00:00+01:00","val":1906.08387862122},{"ts":"2025-03-17T13:00:00+01:00","val":1857.78185283048},{"ts":"2025-03-17T14:00:00+01:00","val":1634.6254888125802},{"ts":"2025-03-17T15:00:00+01:00","val":1269.7341887012199},{"ts":"2025-03-17T16:00:00+01:00","val":819.97823308842},{"ts":"2025-03-17T17:00:00+01:00","val":358.33458719898005},{"ts":"2025-03-17T18:00:00+01:00","val":35.633828015679995},{"ts":"2025-03-17T19:00:00+01:00","val":0},{"ts":"2025-03-17T20:00:00+01:00","val":0},{"ts":"2025-03-17T21:00:00+01:00","val":0},{"ts":"2025-03-17T22:00:00+01:00","val":0},{"ts":"2025-03-17T23:00:00+01:00","val":0},{"ts":"2025-03-18T00:00:00+01:00","val":0},{"ts":"2025-03-18T01:00:00+01:00","val":0},{"ts":"2025-03-18T02:00:00+01:00","val":0},{"ts":"2025-03-18T03:00:00+01:00","val":0},{"ts":"2025-03-18T04:00:00+01:00","val":0},{"ts":"2025-03-18T05:00:00+01:00","val":0},{"ts":"2025-03-18T06:00:00+01:00","val":8.417755061520001},{"ts":"2025-03-18T07:00:00+01:00","val":263.96464432488},{"ts":"2025-03-18T08:00:00+01:00","val":718.75634553472},{"ts":"2025-03-18T09:00:00+01:00","val":1184.0706730348202},{"ts":"2025-03-18T10:00:00+01:00","val":1567.5743844400802},{"ts":"2025-03-18T11:00:00+01:00","val":1813.74764741898},{"ts":"2025-03-18T12:00:00+01:00","val":1912.09805457312},{"ts":"2025-03-18T13:00:00+01:00","val":1850.15210705},{"ts":"2025-03-18T14:00:00+01:00","val":1632.0965053725797},{"ts":"2025-03-18T15:00:00+01:00","val":1279.10368103658},{"ts":"2025-03-18T16:00:00+01:00","val":833.7434483345},{"ts":"2025-03-18T17:00:00+01:00","val":371.68995689448},{"ts":"2025-03-18T18:00:00+01:00","val":40.16844168168001},{"ts":"2025-03-18T19:00:00+01:00","val":0},{"ts":"2025-03-18T20:00:00+01:00","val":0},{"ts":"2025-03-18T21:00:00+01:00","val":0},{"ts":"2025-03-18T22:00:00+01:00","val":0}]}},"hems":{},"grid":{"power":42.97,"energy":2041.0538000000004,"powers":[20.09,-5.9,28.78],"currents":[0.35,-0.65,0.22]},"batteryDischargeControl":false,"loadpoints.0.vehicleDetectionActive":false,"loadpoints.0.batteryBoost":false,"loadpoints.0.smartCostNextStart":null,"loadpoints.0.connectedDuration":0,"loadpoints.0.vehicleWelcomeActive":false,"sponsor":{"name":"sponsorship unavailable","expiresAt":"0001-01-01T00:00:00Z"},"version":"0.200.9","loadpoints.0.limitSoc":80,"loadpoints.0.enableDelay":60,"loadpoints.0.sessionPricePerKWh":0.188,"loadpoints.0.planProjectedStart":null,"statistics":{"30d":{"avgCo2":226.23403295505517,"avgPrice":0.18243424111025985,"chargedKWh":7.25,"solarPercentage":13.230163844199263},"365d":{"avgCo2":226.23403295505517,"avgPrice":0.18243424111025985,"chargedKWh":7.25,"solarPercentage":13.230163844199263},"thisYear":{"avgCo2":226.23403295505517,"avgPrice":0.18243424111025985,"chargedKWh":7.25,"solarPercentage":13.230163844199263},"total":{"avgCo2":226.23403295505517,"avgPrice":0.18243424111025985,"chargedKWh":7.25,"solarPercentage":13.230163844199263}},"influx":{"url":"","database":"","org":"","user":"","insecure":false},"prioritySoc":20,"loadpoints.0.phasesConfigured":0,"loadpoints.0.vehicleName":"","loadpoints.0.effectiveLimitSoc":80,"tariffCo2":262,"eebus":false,"messaging":false,"residualPower":0,"loadpoints.0.enableThreshold":0,"loadpoints.0.smartCostLimit":null,"loadpoints.0.limitEnergy":0,"loadpoints.0.planActive":false,"loadpoints.0.chargePower":1393.344,"fatal":null,"battery":[{"power":6,"capacity":0,"soc":20,"controllable":false}],"loadpoints.0.title":"Garage","loadpoints.0.disableDelay":180,"loadpoints.0.phasesActive":1,"loadpoints.0.planEnergy":0,"pvEnergy":200.999,"loadpoints.0.effectivePlanSoc":0,"aux":[{"power":212,"energy":581.6},{"power":48.7000007629395,"energy":288.800567626953}],"bufferStartSoc":0,"loadpoints.0.pvRemaining":0,"auxPower":260.7,"homePower":0,"loadpoints.0.chargeDuration":1103,"loadpoints.0.effectivePriority":0,"tariffSolar":1116.625,"modbusproxy":[],"loadpoints.0.priority":0,"loadpoints.0.sessionEnergy":426,"loadpoints.0.chargerStatusReason":"unknown","greenShareHome":1,"loadpoints.0.mode":"minpv","loadpoints.0.effectivePlanId":0,"loadpoints.0.connected":true,"tariffPriceHome":0,"tariffCo2Home":0,"auth":{},"pv":[{"power":0},{"power":210.399993896484,"energy":200.998809814453}],"loadpoints.0.minCurrent":6,"loadpoints.0.phaseRemaining":0,"loadpoints.0.chargeCurrents":[6.004,0,0],"loadpoints.0.effectiveMaxCurrent":16}
      ''';

      // Parse the JSON string to a Dart map
      final jsonData = jsonDecode(jsonPayload) as Map<String, dynamic>;

      // Act
      state.updateAll(jsonData);

      // Assert - Verify all properties are correctly stored

      // Check basic properties using helper getters
      expect(state.pvPower, 210.4);
      expect(state.pvEnergy, 200.999);
      expect(state.homePower, 0);
      expect(state.batterySoc, 20);
      expect(state.batteryPower, 6);
      expect(state.batteryEnergy, 0);
      expect(state.greenShareHome, 1);
      expect(state.greenShareLoadpoints, 0.155);
      expect(state.tariffGrid, 0.23);
      expect(state.tariffCo2, 262);
      expect(state.tariffSolar, 1116.625);
      expect(state.tariffPriceHome, 0);
      expect(state.tariffCo2Home, 0);
      expect(state.tariffPriceLoadpoints, 0.194);
      expect(state.tariffCo2Loadpoints, 221.309);
      expect(state.auxPower, 260.7);
      expect(state.siteTitle, 'Home');
      expect(state.version, '0.200.9');
      expect(state.currency, 'EUR');

      // Check loadpoint properties
      expect(state.loadpointCount, 1);
      final lp0 = state.getLoadpointProperties(0);
      expect(lp0.length, 59); // Verify we have all loadpoint properties
      expect(lp0['charging'], true);
      expect(lp0['connected'], true);
      expect(lp0['chargerPhases1p3p'], true);
      expect(lp0['smartCostActive'], false);
      expect(lp0['chargedEnergy'], 426);
      expect(lp0['chargeTotalImport'], 5408.296);
      expect(lp0['title'], 'Garage');
      expect(lp0['mode'], 'minpv');
      expect(lp0['minCurrent'], 6);
      expect(lp0['maxCurrent'], 16);
      expect(lp0['chargePower'], 1393.344);
      expect(lp0['sessionEnergy'], 426);
      expect(lp0['sessionSolarPercentage'], 15.785);

      // Check complex nested structures

      // Grid data
      final grid = state.current['grid'] as Map<String, dynamic>;
      expect(grid['power'], 42.97);
      expect(grid['energy'], 2041.0538000000004);
      expect(grid['powers'], [20.09, -5.9, 28.78]);
      expect(grid['currents'], [0.35, -0.65, 0.22]);

      // Battery data
      final battery = state.current['battery'] as List<dynamic>;
      expect(battery.length, 1);
      expect(battery[0]['power'], 6);
      expect(battery[0]['capacity'], 0);
      expect(battery[0]['soc'], 20);
      expect(battery[0]['controllable'], false);

      // PV data
      final pv = state.current['pv'] as List<dynamic>;
      expect(pv.length, 2);
      expect(pv[0]['power'], 0);
      expect(pv[1]['power'], 210.399993896484);
      expect(pv[1]['energy'], 200.998809814453);

      // Aux data
      final aux = state.current['aux'] as List<dynamic>;
      expect(aux.length, 2);
      expect(aux[0]['power'], 212);
      expect(aux[0]['energy'], 581.6);
      expect(aux[1]['power'], 48.7000007629395);
      expect(aux[1]['energy'], 288.800567626953);

      // Vehicles data
      final vehicles = state.current['vehicles'] as Map<String, dynamic>;
      expect(vehicles.length, 2);
      expect(vehicles['kona']['title'], 'Kona');
      expect(vehicles['kona']['icon'], 'car');
      expect(vehicles['kona']['capacity'], 39);
      expect(vehicles['kona']['features'], ['Offline']);
      expect(vehicles['speedy']['title'], 'Speedy');
      expect(vehicles['speedy']['features'], ['CoarseCurrent']);

      // Network data
      final network = state.current['network'] as Map<String, dynamic>;
      expect(network['schema'], 'http');
      expect(network['host'], 'evcc.local');
      expect(network['port'], 7070);

      // MQTT data
      final mqtt = state.current['mqtt'] as Map<String, dynamic>;
      expect(mqtt['broker'], 'core-mosquitto:1883');
      expect(mqtt['topic'], 'evcc');
      expect(mqtt['user'], 'evcc');

      // Statistics data
      final statistics = state.current['statistics'] as Map<String, dynamic>;
      expect(statistics.length, 4);
      expect(statistics['30d']['avgCo2'], 226.23403295505517);
      expect(statistics['30d']['avgPrice'], 0.18243424111025985);
      expect(statistics['30d']['chargedKWh'], 7.25);
      expect(statistics['30d']['solarPercentage'], 13.230163844199263);

      // Forecast data - check a sample of the extensive forecast data
      final forecast = state.current['forecast'] as Map<String, dynamic>;
      expect(forecast.length, 3); // co2, grid, solar

      // Check co2 forecast
      final co2Forecast = forecast['co2'] as List<dynamic>;
      expect(co2Forecast.length, 48);
      expect(co2Forecast[0]['price'], 262);

      // Check grid forecast
      final gridForecast = forecast['grid'] as List<dynamic>;
      expect(gridForecast.length, 48);
      expect(gridForecast[15]['price'], 0.23);

      // Check solar forecast
      final solarForecast = forecast['solar'] as Map<String, dynamic>;
      expect(solarForecast['today']['energy'], 1440.8490576581432);
      expect(solarForecast['today']['complete'], true);
      expect(solarForecast['tomorrow']['energy'], 10710.83241949696);

      // Check solar timeseries
      final solarTimeseries = solarForecast['timeseries'] as List<dynamic>;
      expect(solarTimeseries.length, 72);

      // Verify all original keys are present in the state
      for (final key in jsonData.keys) {
        expect(
          state.current.containsKey(key),
          true,
          reason: 'Missing key: $key',
        );
      }
    });
  });
}
