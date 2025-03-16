import 'package:evcc_api/evcc_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockEvccClient extends Mock implements EvccClient {}

void main() {
  group('GeneralApi tests', () {
    late MockEvccClient mockClient;
    late GeneralApi generalApi;

    setUp(() {
      mockClient = MockEvccClient();
      generalApi = GeneralApiImpl(mockClient);

      // Register fallback values
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('getHealth makes correct request', () async {
      when(
        () => mockClient.get<String>(
          '/health',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => 'OK');

      final result = await generalApi.getHealth();

      expect(result, 'OK');
      verify(
        () => mockClient.get<String>(
          '/health',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('getState makes correct request without filter', () async {
      final mockState = {'key': 'value'};

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/state',
          queryParams: null,
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockState);

      final result = await generalApi.getState();

      expect(result, mockState);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/state',
          queryParams: null,
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('getState makes correct request with filter', () async {
      final mockState = {'key': 'value'};
      final jqFilter = '.loadpoints[0]';

      when(
        () => mockClient.get<Map<String, dynamic>>(
          '/state',
          queryParams: {'jq': jqFilter},
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockState);

      final result = await generalApi.getState(jqFilter: jqFilter);

      expect(result, mockState);
      verify(
        () => mockClient.get<Map<String, dynamic>>(
          '/state',
          queryParams: {'jq': jqFilter},
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });
  });
}
