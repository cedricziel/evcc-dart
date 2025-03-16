/// WebSocket client for the EVCC API.
library;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'websocket_messages.dart';

/// Exception thrown when a WebSocket operation fails.
class EvccWebSocketException implements Exception {
  /// The error message.
  final String message;

  /// The underlying error, if any.
  final Object? error;

  /// Creates a new WebSocket exception.
  EvccWebSocketException(this.message, [this.error]);

  @override
  String toString() {
    if (error != null) {
      return 'EvccWebSocketException: $message (${error.toString()})';
    }
    return 'EvccWebSocketException: $message';
  }
}

/// Connection state of the WebSocket.
enum WebSocketConnectionState {
  /// The WebSocket is disconnected.
  disconnected,

  /// The WebSocket is connecting.
  connecting,

  /// The WebSocket is connected.
  connected,

  /// The WebSocket is reconnecting after a disconnection.
  reconnecting,
}

/// Client for the EVCC WebSocket API.
class EvccWebSocketClient {
  /// The WebSocket URL.
  final String url;

  /// The WebSocket channel.
  WebSocketChannel? _channel;

  /// The connection state.
  WebSocketConnectionState _connectionState =
      WebSocketConnectionState.disconnected;

  /// The message controller.
  final StreamController<EvccWebSocketMessage> _messageController =
      StreamController<EvccWebSocketMessage>.broadcast();

  /// The connection state controller.
  final StreamController<WebSocketConnectionState> _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();

  /// Whether to automatically reconnect on disconnection.
  bool _autoReconnect = true;

  /// The reconnection timer.
  Timer? _reconnectTimer;

  /// The reconnection attempt count.
  int _reconnectAttempt = 0;

  /// The maximum number of reconnection attempts.
  static const int _maxReconnectAttempts = 5;

  /// The base delay between reconnection attempts in milliseconds.
  static const int _reconnectBaseDelayMs = 1000;

  /// Creates a new EVCC WebSocket client.
  ///
  /// [url] - The WebSocket URL.
  EvccWebSocketClient(this.url);

  /// Returns the current connection state.
  WebSocketConnectionState get connectionState => _connectionState;

  /// Returns a stream of connection state changes.
  Stream<WebSocketConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Returns a stream of WebSocket messages.
  Stream<EvccWebSocketMessage> get messages => _messageController.stream;

  /// Sets the connection state and notifies listeners.
  @protected
  void _setConnectionState(WebSocketConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _connectionStateController.add(state);
    }
  }

  /// Connects to the WebSocket.
  ///
  /// [autoReconnect] - Whether to automatically reconnect on disconnection.
  Future<void> connect({bool autoReconnect = true}) async {
    if (_connectionState == WebSocketConnectionState.connected ||
        _connectionState == WebSocketConnectionState.connecting) {
      return;
    }

    _autoReconnect = autoReconnect;
    _reconnectAttempt = 0;

    await _connect();
  }

  /// Internal method to connect to the WebSocket.
  Future<void> _connect() async {
    if (_connectionState == WebSocketConnectionState.connected) {
      return;
    }

    _setConnectionState(
      _reconnectAttempt > 0
          ? WebSocketConnectionState.reconnecting
          : WebSocketConnectionState.connecting,
    );

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _setConnectionState(WebSocketConnectionState.connected);

      // Listen for messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      _setConnectionState(WebSocketConnectionState.disconnected);
      _scheduleReconnect();
      throw EvccWebSocketException('Failed to connect to WebSocket', e);
    }
  }

  /// Disconnects from the WebSocket.
  Future<void> disconnect() async {
    _autoReconnect = false;
    _cancelReconnect();

    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
    }

    _setConnectionState(WebSocketConnectionState.disconnected);
  }

  /// Handles incoming WebSocket messages.
  void _onMessage(dynamic data) {
    if (data is String) {
      try {
        final message = EvccWebSocketMessage.fromJsonString(data);
        if (message != null) {
          _messageController.add(message);
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
  }

  /// Handles WebSocket errors.
  void _onError(Object error) {
    _setConnectionState(WebSocketConnectionState.disconnected);
    _scheduleReconnect();
  }

  /// Handles WebSocket closure.
  void _onDone() {
    _setConnectionState(WebSocketConnectionState.disconnected);
    _scheduleReconnect();
  }

  /// Schedules a reconnection attempt.
  void _scheduleReconnect() {
    if (!_autoReconnect || _reconnectAttempt >= _maxReconnectAttempts) {
      return;
    }

    _cancelReconnect();

    // Exponential backoff with jitter
    final delay = _reconnectBaseDelayMs * (1 << _reconnectAttempt);
    final jitter =
        (delay * 0.2 * (DateTime.now().millisecondsSinceEpoch % 10)) / 10;
    final reconnectDelay = delay + jitter.toInt();

    _reconnectTimer = Timer(Duration(milliseconds: reconnectDelay), () {
      _reconnectAttempt++;
      _connect();
    });
  }

  /// Cancels any scheduled reconnection attempt.
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Closes the WebSocket client and releases resources.
  Future<void> close() async {
    await disconnect();
    await _messageController.close();
    await _connectionStateController.close();
  }
}
