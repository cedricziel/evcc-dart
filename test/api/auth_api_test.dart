
import 'package:evcc_api/evcc_api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class MockEvccClient extends Mock implements EvccClient {}

void main() {
  group('AuthApi tests', () {
    late MockEvccClient mockClient;
    late AuthApi authApi;

    setUp(() {
      mockClient = MockEvccClient();
      authApi = AuthApiImpl(mockClient);

      // Register fallback values
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('login makes correct request', () async {
      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/auth/login',
          body: {'password': 'testpassword'},
          includeAuth: false,
        ),
      ).thenAnswer((_) async => {});

      await authApi.login('testpassword');

      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/auth/login',
          body: {'password': 'testpassword'},
          includeAuth: false,
        ),
      ).called(1);
    });

    test('logout makes correct request', () async {
      when(
        () => mockClient.post<void>('/auth/logout'),
      ).thenAnswer((_) async => {});

      await authApi.logout();

      verify(() => mockClient.post<void>('/auth/logout')).called(1);
    });

    test('changePassword makes correct request', () async {
      when(
        () => mockClient.put<void>(
          '/auth/password',
          body: {'current': 'oldpass', 'new': 'newpass'},
        ),
      ).thenAnswer((_) async => {});

      await authApi.changePassword('oldpass', 'newpass');

      verify(
        () => mockClient.put<void>(
          '/auth/password',
          body: {'current': 'oldpass', 'new': 'newpass'},
        ),
      ).called(1);
    });

    test('getStatus makes correct request and returns true', () async {
      when(
        () => mockClient.get<String>(
          '/auth/status',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => 'true');

      final result = await authApi.getStatus();

      expect(result, isTrue);
      verify(
        () => mockClient.get<String>(
          '/auth/status',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('getStatus makes correct request and returns false', () async {
      when(
        () => mockClient.get<String>(
          '/auth/status',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => 'false');

      final result = await authApi.getStatus();

      expect(result, isFalse);
      verify(
        () => mockClient.get<String>(
          '/auth/status',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });
  });
}
