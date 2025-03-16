import 'package:evcc_api/evcc_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockEvccClient extends Mock implements EvccClient {}

void main() {
  group('TariffsApi tests', () {
    late MockEvccClient mockClient;
    late TariffsApi tariffsApi;

    setUp(() {
      mockClient = MockEvccClient();
      tariffsApi = TariffsApiImpl(mockClient);

      // Register fallback values
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('getTariff makes correct request for grid tariff', () async {
      const type = 'grid';
      final mockRates = {
        'rates': [
          {
            'start': '2025-03-16T00:00:00Z',
            'end': '2025-03-16T01:00:00Z',
            'price': 0.25,
          },
        ],
      };

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/tariff/$type',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': mockRates});

      final result = await tariffsApi.getTariff(type);

      expect(result, mockRates);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/tariff/$type',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('getTariff makes correct request for feedin tariff', () async {
      const type = 'feedin';
      final mockRates = {
        'rates': [
          {
            'start': '2025-03-16T00:00:00Z',
            'end': '2025-03-16T01:00:00Z',
            'price': 0.08,
          },
        ],
      };

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/tariff/$type',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': mockRates});

      final result = await tariffsApi.getTariff(type);

      expect(result, mockRates);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/tariff/$type',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('getTariff makes correct request for co2 tariff', () async {
      const type = 'co2';
      final mockRates = {
        'rates': [
          {
            'start': '2025-03-16T00:00:00Z',
            'end': '2025-03-16T01:00:00Z',
            'price': 100,
          },
        ],
      };

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/tariff/$type',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': mockRates});

      final result = await tariffsApi.getTariff(type);

      expect(result, mockRates);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/tariff/$type',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('getTariff makes correct request for planner tariff', () async {
      const type = 'planner';
      final mockRates = {
        'rates': [
          {
            'start': '2025-03-16T00:00:00Z',
            'end': '2025-03-16T01:00:00Z',
            'price': 0.20,
          },
        ],
      };

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/tariff/$type',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': mockRates});

      final result = await tariffsApi.getTariff(type);

      expect(result, mockRates);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/tariff/$type',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });
  });
}
