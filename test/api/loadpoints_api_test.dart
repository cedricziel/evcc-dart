import 'package:evcc_api/evcc_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock classes
class MockEvccClient extends Mock implements EvccClient {}

void main() {
  group('LoadpointsApi tests', () {
    late MockEvccClient mockClient;
    late LoadpointsApi loadpointsApi;
    const int loadpointId = 1;

    setUp(() {
      mockClient = MockEvccClient();
      loadpointsApi = LoadpointsApiImpl(mockClient);

      // Register fallback values
      registerFallbackValue(Uri());
      registerFallbackValue({});
    });

    test('setMode makes correct request', () async {
      const mode = 'pv';
      final mockResult = {'result': mode};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/mode/$mode',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await loadpointsApi.setMode(loadpointId, mode);

      expect(result, mode);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/mode/$mode',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setMinCurrent makes correct request', () async {
      const current = 6.0;
      final mockResult = {'result': current};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/mincurrent/$current',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await loadpointsApi.setMinCurrent(loadpointId, current);

      expect(result, current);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/mincurrent/$current',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setMaxCurrent makes correct request', () async {
      const current = 16.0;
      final mockResult = {'result': current};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/maxcurrent/$current',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await loadpointsApi.setMaxCurrent(loadpointId, current);

      expect(result, current);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/maxcurrent/$current',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setPhases makes correct request', () async {
      const phases = 3;
      final mockResult = {'result': phases};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/phases/$phases',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await loadpointsApi.setPhases(loadpointId, phases);

      expect(result, phases);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/phases/$phases',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setSocLimit makes correct request', () async {
      const soc = 80.0;
      final mockResult = {'result': soc};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/limitsoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await loadpointsApi.setSocLimit(loadpointId, soc);

      expect(result, soc);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/limitsoc/$soc',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });

    test('setEnergyLimit makes correct request', () async {
      const energy = 10.0;
      final mockResult = {'result': energy};

      when(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/limitenergy/$energy',
          converter: any(named: 'converter'),
        ),
      ).thenAnswer((_) async => mockResult);

      final result = await loadpointsApi.setEnergyLimit(loadpointId, energy);

      expect(result, energy);
      verify(
        () => mockClient.post<Map<String, dynamic>>(
          '/loadpoints/$loadpointId/limitenergy/$energy',
          converter: any(named: 'converter'),
        ),
      ).called(1);
    });
  });
}
