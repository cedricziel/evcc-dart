import 'package:evcc_api/evcc_api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

void main() {
  group('EvccApi integration tests', () {
    late MockHttpClient mockHttpClient;
    late EvccApi api;

    setUp(() {
      mockHttpClient = MockHttpClient();
      api = EvccApi(httpClient: mockHttpClient);

      // Register fallback values
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('Authentication flow', () async {
      // Mock login response
      final loginResponse = MockResponse();
      when(() => loginResponse.statusCode).thenReturn(200);
      when(() => loginResponse.body).thenReturn('{}');
      when(
        () => mockHttpClient.post(
          Uri.parse('https://demo.evcc.io/api/auth/login'),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => loginResponse);

      // Mock status responses
      final statusResponseBefore = MockResponse();
      when(() => statusResponseBefore.statusCode).thenReturn(200);
      when(() => statusResponseBefore.body).thenReturn('false');

      final statusResponseAfter = MockResponse();
      when(() => statusResponseAfter.statusCode).thenReturn(200);
      when(() => statusResponseAfter.body).thenReturn('true');

      // Setup sequence of responses for status endpoint
      when(
        () => mockHttpClient.get(
          Uri.parse('https://demo.evcc.io/api/auth/status'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => statusResponseBefore);

      // Mock logout response
      final logoutResponse = MockResponse();
      when(() => logoutResponse.statusCode).thenReturn(200);
      when(() => logoutResponse.body).thenReturn('{}');
      when(
        () => mockHttpClient.post(
          Uri.parse('https://demo.evcc.io/api/auth/logout'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => logoutResponse);

      // Test authentication flow
      final statusBefore = await api.auth.getStatus();
      expect(statusBefore, isFalse);

      // Update mock for second call to return logged in status
      when(
        () => mockHttpClient.get(
          Uri.parse('https://demo.evcc.io/api/auth/status'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => statusResponseAfter);

      await api.auth.login('password');

      final statusAfter = await api.auth.getStatus();
      expect(statusAfter, isTrue);

      await api.auth.logout();

      // Verify all calls were made
      verify(
        () => mockHttpClient.get(
          Uri.parse('https://demo.evcc.io/api/auth/status'),
          headers: any(named: 'headers'),
        ),
      ).called(2);

      verify(
        () => mockHttpClient.post(
          Uri.parse('https://demo.evcc.io/api/auth/login'),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).called(1);

      verify(
        () => mockHttpClient.post(
          Uri.parse('https://demo.evcc.io/api/auth/logout'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('System state and health', () async {
      // Mock health response
      final healthResponse = MockResponse();
      when(() => healthResponse.statusCode).thenReturn(200);
      when(() => healthResponse.body).thenReturn('"OK"');
      when(
        () => mockHttpClient.get(
          Uri.parse('https://demo.evcc.io/api/health'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => healthResponse);

      // Mock state response
      final stateResponse = MockResponse();
      when(() => stateResponse.statusCode).thenReturn(200);
      when(() => stateResponse.body).thenReturn('{"result": {"key": "value"}}');
      when(
        () => mockHttpClient.get(
          Uri.parse('https://demo.evcc.io/api/state'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => stateResponse);

      // Test health and state
      final health = await api.general.getHealth();
      expect(health, 'OK');

      final state = await api.general.getState();
      expect(state, {'key': 'value'});

      // Verify all calls were made
      verify(
        () => mockHttpClient.get(
          Uri.parse('https://demo.evcc.io/api/health'),
          headers: any(named: 'headers'),
        ),
      ).called(1);

      verify(
        () => mockHttpClient.get(
          Uri.parse('https://demo.evcc.io/api/state'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });

    test('Error handling', () async {
      // Mock error response
      final errorResponse = MockResponse();
      when(() => errorResponse.statusCode).thenReturn(404);
      when(() => errorResponse.body).thenReturn('Not Found');
      when(
        () => mockHttpClient.get(
          Uri.parse('https://demo.evcc.io/api/nonexistent'),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer((_) async => errorResponse);

      // Test error handling
      expect(
        () => api.client.get<Map<String, dynamic>>(
          '/nonexistent',
          converter: (json) => json as Map<String, dynamic>,
        ),
        throwsA(
          isA<EvccApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.message, 'message', 'Request failed: Not Found'),
        ),
      );

      // Verify call was made
      verify(
        () => mockHttpClient.get(
          Uri.parse('https://demo.evcc.io/api/nonexistent'),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });
  });
}
