import 'package:evcc_api/evcc_api.dart';
import 'package:test/test.dart';

void main() {
  group('EvccWebSocketClient', () {
    test('should initialize with correct URL', () {
      // Arrange & Act
      final client = EvccWebSocketClient('ws://test.example.com/ws');

      // Assert
      expect(client.url, 'ws://test.example.com/ws');
      expect(client.connectionState, WebSocketConnectionState.disconnected);
    });

    test('should derive WebSocket URL correctly in EvccApi', () {
      // Test HTTP to WS conversion
      final api1 = EvccApi(baseUrl: 'http://192.168.1.100:7070/api');
      expect(api1.ws.url, 'ws://192.168.1.100:7070/ws');

      // Test HTTPS to WSS conversion
      final api2 = EvccApi(baseUrl: 'https://demo.evcc.io/api');
      expect(api2.ws.url, 'wss://demo.evcc.io/ws');

      // Test with explicit WebSocket URL
      final api3 = EvccApi(
        baseUrl: 'http://192.168.1.100:7070/api',
        wsUrl: 'ws://custom.example.com/socket',
      );
      expect(api3.ws.url, 'ws://custom.example.com/socket');
    });
  });
}
