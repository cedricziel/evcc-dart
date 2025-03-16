import 'package:evcc_api/evcc_api.dart';
import 'package:test/test.dart';

void main() {
  group('EvccApi tests', () {
    final api = EvccApi();

    setUp(() {
      // Additional setup goes here.
    });

    test('Client initialization', () {
      expect(api.client, isNotNull);
    });
  });
}
