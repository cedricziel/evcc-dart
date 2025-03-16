import 'package:evcc_api/evcc_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockEvccClient extends Mock implements EvccClient {}

void main() {
  group('VehiclesApi tests', () {
    late MockEvccClient mockClient;
    late VehiclesApi vehiclesApi;
    const String vehicleName = 'vehicle_1';

    setUp(() {
      mockClient = MockEvccClient();
      vehiclesApi = VehiclesApiImpl(mockClient);

      // Register fallback values
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('setMinSoc makes correct request', () async {
      const soc = 20.0;
      final mockResult = {
        'result': {'soc': soc},
      };

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/vehicles/$vehicleName/minsoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await vehiclesApi.setMinSoc(vehicleName, soc);

      expect(result, mockResult['result']);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/vehicles/$vehicleName/minsoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setSocLimit makes correct request', () async {
      const soc = 80.0;
      final mockResult = {
        'result': {'soc': soc},
      };

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/vehicles/$vehicleName/limitsoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await vehiclesApi.setSocLimit(vehicleName, soc);

      expect(result, mockResult['result']);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/vehicles/$vehicleName/limitsoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('deleteSocPlan makes correct request', () async {
      when(
        () => mockClient.delete<void>('/vehicles/$vehicleName/plan/soc'),
      ).thenAnswer((_) async {});

      await vehiclesApi.deleteSocPlan(vehicleName);

      verify(
        () => mockClient.delete<void>('/vehicles/$vehicleName/plan/soc'),
      ).called(1);
    });

    test('setSocPlan makes correct request', () async {
      const soc = 80.0;
      const timestamp = '2025-07-19T12:30:00.000Z';
      final mockResult = {
        'result': {'soc': soc, 'time': timestamp},
      };

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/vehicles/$vehicleName/plan/soc/$soc/$timestamp',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await vehiclesApi.setSocPlan(vehicleName, soc, timestamp);

      expect(result, mockResult['result']);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/vehicles/$vehicleName/plan/soc/$soc/$timestamp',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('updateRepeatingPlans makes correct request', () async {
      final plans = {
        'plans': [
          {
            'active': true,
            'soc': 80,
            'time': '08:00',
            'tz': 'Europe/Berlin',
            'weekdays': [1, 2, 3, 4, 5],
          },
        ],
      };

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/vehicles/$vehicleName/plan/repeating',
          body: plans,
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': plans});

      final result = await vehiclesApi.updateRepeatingPlans(vehicleName, plans);

      expect(result, plans);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/vehicles/$vehicleName/plan/repeating',
          body: plans,
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });
  });
}
