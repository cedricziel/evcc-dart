import 'package:evcc_api/evcc_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockEvccClient extends Mock implements EvccClient {}

void main() {
  group('SessionsApi tests', () {
    late MockEvccClient mockClient;
    late SessionsApi sessionsApi;
    const int sessionId = 1;

    setUp(() {
      mockClient = MockEvccClient();
      sessionsApi = SessionsApiImpl(mockClient);

      // Register fallback values
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('getSessions makes correct request without parameters', () async {
      final mockSessions = [
        {
          'id': 1,
          'created': '2025-03-15T10:00:00Z',
          'finished': '2025-03-15T12:00:00Z',
          'loadpoint': 'Garage',
          'vehicle': 'vehicle_1',
          'chargedEnergy': 10.5,
          'chargeDuration': 7200,
          'solarPercentage': 80.0,
          'price': 2.5,
          'pricePerKWh': 0.25,
          'co2PerKWh': 100,
        },
      ];

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/sessions',
          queryParams: null,
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': mockSessions});

      final result = await sessionsApi.getSessions();

      expect(result, mockSessions);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/sessions',
          queryParams: null,
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('getSessions makes correct request with parameters', () async {
      final mockSessions = [
        {
          'id': 1,
          'created': '2025-03-15T10:00:00Z',
          'finished': '2025-03-15T12:00:00Z',
          'loadpoint': 'Garage',
          'vehicle': 'vehicle_1',
          'chargedEnergy': 10.5,
          'chargeDuration': 7200,
          'solarPercentage': 80.0,
          'price': 2.5,
          'pricePerKWh': 0.25,
          'co2PerKWh': 100,
        },
      ];

      const format = 'csv';
      const lang = 'de';
      const month = 3;
      const year = 2025;

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/sessions',
          queryParams: {
            'format': format,
            'lang': lang,
            'month': month.toString(),
            'year': year.toString(),
          },
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': mockSessions});

      final result = await sessionsApi.getSessions(
        format: format,
        lang: lang,
        month: month,
        year: year,
      );

      expect(result, mockSessions);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/sessions',
          queryParams: {
            'format': format,
            'lang': lang,
            'month': month.toString(),
            'year': year.toString(),
          },
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('updateSession makes correct request', () async {
      const vehicle = 'vehicle_2';
      const loadpoint = 'Carport';

      when(
        () => mockClient.put<void>(
          '/session/$sessionId',
          body: {'vehicle': vehicle, 'loadpoint': loadpoint},
        ),
      ).thenAnswer((_) async => {});

      await sessionsApi.updateSession(sessionId, vehicle, loadpoint);

      verify(
        () => mockClient.put<void>(
          '/session/$sessionId',
          body: {'vehicle': vehicle, 'loadpoint': loadpoint},
        ),
      ).called(1);
    });

    test('deleteSession makes correct request', () async {
      when(
        () => mockClient.delete<void>('/session/$sessionId'),
      ).thenAnswer((_) async {});

      await sessionsApi.deleteSession(sessionId);

      verify(() => mockClient.delete<void>('/session/$sessionId')).called(1);
    });
  });
}
