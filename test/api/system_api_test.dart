import 'package:evcc_api/evcc_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockEvccClient extends Mock implements EvccClient {}

void main() {
  group('SystemApi tests', () {
    late MockEvccClient mockClient;
    late SystemApi systemApi;

    setUp(() {
      mockClient = MockEvccClient();
      systemApi = SystemApiImpl(mockClient);

      // Register fallback values
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('getLogs makes correct request without parameters', () async {
      final mockLogs = ['log line 1', 'log line 2'];

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/system/log',
          queryParams: null,
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': mockLogs});

      final result = await systemApi.getLogs();

      expect(result, mockLogs);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/system/log',
          queryParams: null,
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('getLogs makes correct request with parameters', () async {
      final mockLogs = ['log line 1', 'log line 2'];

      const areas = ['lp-1', 'site'];
      const level = 'DEBUG';
      const count = 100;
      const format = 'txt';

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/system/log',
          queryParams: {
            'areas': areas,
            'level': level,
            'count': count.toString(),
            'format': format,
          },
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': mockLogs});

      final result = await systemApi.getLogs(
        areas: areas,
        level: level,
        count: count,
        format: format,
      );

      expect(result, mockLogs);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/system/log',
          queryParams: {
            'areas': areas,
            'level': level,
            'count': count.toString(),
            'format': format,
          },
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('getLogAreas makes correct request', () async {
      final mockAreas = ['lp-1', 'site', 'db'];

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/system/log/areas',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => {'result': mockAreas});

      final result = await systemApi.getLogAreas();

      expect(result, mockAreas);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/system/log/areas',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('shutdown makes correct request', () async {
      when(
        () => mockClient.post<void>('/system/shutdown'),
      ).thenAnswer((_) async => {});

      await systemApi.shutdown();

      verify(() => mockClient.post<void>('/system/shutdown')).called(1);
    });

    test('getTelemetryStatus makes correct request', () async {
      const enabled = true;
      final mockResult = {'result': enabled};

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/settings/telemetry',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await systemApi.getTelemetryStatus();

      expect(result, enabled);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/settings/telemetry',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setTelemetry makes correct request', () async {
      const enable = true;
      final mockResult = {'result': enable};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/settings/telemetry/${enable ? 'true' : 'false'}',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await systemApi.setTelemetry(enable);

      expect(result, enable);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/settings/telemetry/${enable ? 'true' : 'false'}',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });
  });
}
