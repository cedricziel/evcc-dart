import 'dart:convert';

import 'package:evcc_api/evcc_api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

void main() {
  group('EvccApi tests', () {
    late EvccApi api;

    setUp(() {
      api = EvccApi();
    });

    test('Client initialization with default parameters', () {
      expect(api.client, isNotNull);
      expect(api.auth, isNotNull);
      expect(api.general, isNotNull);
      expect(api.loadpoints, isNotNull);
      expect(api.vehicles, isNotNull);
      expect(api.battery, isNotNull);
      expect(api.tariffs, isNotNull);
      expect(api.sessions, isNotNull);
      expect(api.system, isNotNull);
    });

    test('Client initialization with custom baseUrl', () {
      final customApi = EvccApi(baseUrl: 'https://custom.evcc.io/api');
      expect(customApi.client, isNotNull);
    });
  });

  group('EvccClient tests', () {
    late MockHttpClient mockHttpClient;
    late EvccClient client;

    setUp(() {
      mockHttpClient = MockHttpClient();
      client = EvccClient(
        baseUrl: 'https://test.evcc.io/api',
        httpClient: mockHttpClient,
      );

      // Register fallback values for when() and verify()
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('GET request', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('{"result": "success"}');

      when(
        () => mockHttpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => mockResponse);

      final result = await client.get<Map<String, dynamic>>(
        '/test',
        converter: (json) => json as Map<String, dynamic>,
      );

      expect(result, {'result': 'success'});

      verify(
        () => mockHttpClient.get(
          Uri.parse('https://test.evcc.io/api/test'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('GET request with query parameters', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('{"result": "success"}');

      when(
        () => mockHttpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => mockResponse);

      await client.get<Map<String, dynamic>>(
        '/test',
        queryParams: {'param1': 'value1', 'param2': 'value2'},
        converter: (json) => json as Map<String, dynamic>,
      );

      verify(
        () => mockHttpClient.get(
          Uri.parse(
            'https://test.evcc.io/api/test?param1=value1&param2=value2',
          ),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('POST request with body', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('{"result": "success"}');

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      await client.post<Map<String, dynamic>>(
        '/test',
        body: {'data': 'test'},
        converter: (json) => json as Map<String, dynamic>,
      );

      verify(
        () => mockHttpClient.post(
          Uri.parse('https://test.evcc.io/api/test'),
          headers: any(named: 'headers'),
          body: jsonEncode({'data': 'test'}),
        ),
      ).called(1);
    });

    test('Error response handling', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(404);
      when(() => mockResponse.body).thenReturn('Not Found');

      when(
        () => mockHttpClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => mockResponse);

      expect(
        () => client.get<Map<String, dynamic>>(
          '/test',
          converter: (json) => json as Map<String, dynamic>,
        ),
        throwsA(
          isA<EvccApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.message, 'message', 'Request failed: Not Found'),
        ),
      );
    });
  });
}
