import 'package:evcc_api/evcc_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockEvccClient extends Mock implements EvccClient {}

void main() {
  group('HomeBatteryApi tests', () {
    late MockEvccClient mockClient;
    late HomeBatteryApi batteryApi;

    setUp(() {
      mockClient = MockEvccClient();
      batteryApi = HomeBatteryApiImpl(mockClient);

      // Register fallback values
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('setBatteryDischargeControl makes correct request', () async {
      const enable = true;
      final mockResult = {'result': enable};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          // ignore: dead_code
          '/batterydischargecontrol/${enable ? 'true' : 'false'}',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await batteryApi.setBatteryDischargeControl(enable);

      expect(result, enable);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          // ignore: dead_code
          '/batterydischargecontrol/${enable ? 'true' : 'false'}',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('removeBatteryGridChargeLimit makes correct request', () async {
      when(
        () => mockClient.delete<void>('/batterygridchargelimit'),
      ).thenAnswer((_) async {});

      await batteryApi.removeBatteryGridChargeLimit();

      verify(
        () => mockClient.delete<void>('/batterygridchargelimit'),
      ).called(1);
    });

    test('setBatteryGridChargeLimit makes correct request', () async {
      const cost = 0.15;
      final mockResult = {'result': cost};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/batterygridchargelimit/$cost',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await batteryApi.setBatteryGridChargeLimit(cost);

      expect(result, cost);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/batterygridchargelimit/$cost',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setBufferSoc makes correct request', () async {
      const soc = 20.0;
      final mockResult = {'result': soc};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/buffersoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await batteryApi.setBufferSoc(soc);

      expect(result, soc);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/buffersoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setBufferStartSoc makes correct request', () async {
      const soc = 10.0;
      final mockResult = {'result': soc};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/bufferstartsoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await batteryApi.setBufferStartSoc(soc);

      expect(result, soc);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/bufferstartsoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setPrioritySoc makes correct request', () async {
      const soc = 50.0;
      final mockResult = {'result': soc};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/prioritysoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await batteryApi.setPrioritySoc(soc);

      expect(result, soc);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/prioritysoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setResidualPower makes correct request', () async {
      const power = 100.0;
      final mockResult = {'result': power};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/residualpower/$power',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await batteryApi.setResidualPower(power);

      expect(result, power);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/residualpower/$power',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });
  });
}
