import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/tcp_client.dart';
import '../../core/messages.dart';

class ConnectionState {
  final TcpClient? client;
  final String? playerId;
  final bool isConnected;

  const ConnectionState({this.client, this.playerId, this.isConnected = false});
}

class ConnectionNotifier extends Notifier<ConnectionState> {
  @override
  ConnectionState build() => const ConnectionState();

  Future<void> connect(String ip, int port) async {
    final client = TcpClient(host: ip, port: port);
    await client.connect();
    state = ConnectionState(client: client, isConnected: true);
  }

  void send(ClientMessage message) {
    state.client?.send(message);
  }

  Stream<ServerMessage> get messages =>
      state.client?.messages ?? const Stream.empty();

  void setPlayerId(String id) {
    state = ConnectionState(
      client: state.client,
      playerId: id,
      isConnected: state.isConnected,
    );
  }

  Future<void> disconnect() async {
    await state.client?.close();
    state = const ConnectionState();
  }
}

final connectionProvider =
    NotifierProvider<ConnectionNotifier, ConnectionState>(
      ConnectionNotifier.new,
    );
