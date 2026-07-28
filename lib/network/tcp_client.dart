import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'tcp_framing.dart';
import '../core/messages.dart';
import '../shared/logger.dart';

/// TCP client that connects to the game server, handles newline-delimited
/// JSON framing, and exposes a [Stream] of parsed [ServerMessage] objects.
class TcpClient {
  final String host;
  final int port;

  Socket? _socket;
  final TcpFraming _framing = TcpFraming();
  final StreamController<ServerMessage> _messageController =
      StreamController<ServerMessage>.broadcast();

  /// Stream of parsed [ServerMessage] objects received from the server.
  /// Errors are forwarded through the stream's error channel.
  Stream<ServerMessage> get messages => _messageController.stream;

  /// Whether the client is currently connected.
  bool get isConnected => _socket != null;

  TcpClient({required this.host, required this.port});

  /// Connect to the server. Throws on connection failure.
  Future<void> connect() async {
    _socket = await Socket.connect(host, port);

    _socket!.listen(
      (data) {
        try {
          final rawMessages = _framing.feed(data);
          for (final rawJson in rawMessages) {
            final jsonMap = canonicalizeDiscriminator(
              jsonDecode(rawJson) as Map<String, dynamic>,
            );
            final message = ServerMessage.fromJson(jsonMap);
            _messageController.add(message);
          }
        } catch (e) {
          _messageController.addError(e);
        }
      },
      onDone: () {
        if (!_messageController.isClosed) {
          _messageController.close();
        }
      },
      onError: (error) {
        _messageController.addError(error);
      },
      cancelOnError: false,
    );
  }

  /// Send a [ClientMessage] to the server.
  ///
  /// Serializes to JSON with [restoreDiscriminator], appends `\n`,
  /// and logs via [logMessage].
  void send(ClientMessage message) {
    if (_socket == null) {
      throw StateError('Not connected. Call connect() first.');
    }

    final jsonMap = restoreDiscriminator(message.toJson());
    final jsonStr = jsonEncode(jsonMap);
    logMessage('SEND', jsonStr);
    _socket!.write('$jsonStr\n');
  }

  /// Disconnect and clean up resources.
  ///
  /// Safe to call multiple times — does not throw if already closed.
  Future<void> close() async {
    try {
      await _socket?.close();
    } catch (_) {
      // Socket may already be closed.
    }
    _socket = null;

    if (!_messageController.isClosed) {
      await _messageController.close();
    }
  }
}
