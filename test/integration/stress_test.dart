import 'dart:math';

import 'package:capture_the_flag/core/messages.dart';
import 'package:capture_the_flag/network/tcp_client.dart';
import 'package:capture_the_flag/network/tcp_server.dart';
import 'package:capture_the_flag/server/server_state.dart';
import 'package:capture_the_flag/server/server_state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    '100 concurrent clients — join, play, no crashes',
    () async {
      // ---- 1. Start server ----
      final server = TcpServer();
      await server.start();

      final gameState = ServerGameState();
      final stateMachine = ServerStateMachine(state: gameState, server: server);

      // Wire inbound client messages to the state machine.
      server.onJoin.listen((session) {
        session.messages.listen((msg) {
          if (msg is Join) {
            stateMachine.handleJoin(session, msg);
          } else if (msg is Input) {
            stateMachine.handleInput(session.playerId ?? '', msg);
          }
        });
      });

      // ---- 2. Connect 100 clients ----
      const clientCount = 100;
      final clients = <TcpClient>[];
      final welcomesReceived = <String>[];

      for (var i = 0; i < clientCount; i++) {
        final client = TcpClient(host: '127.0.0.1', port: server.port);
        await client.connect();

        // Listen for welcome messages from the server.
        client.messages.listen((msg) {
          if (msg is Welcome) {
            welcomesReceived.add(msg.playerId);
          }
        });

        client.send(ClientMessage.join(v: 1, name: 'Player $i'));
        clients.add(client);

        // Brief pause every 10 connects so the server isn't overwhelmed.
        if (i % 10 == 0) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      // Give the server time to process all joins.
      await Future.delayed(const Duration(seconds: 2));

      // ---- 3. Verify all clients joined ----
      expect(gameState.players.length, clientCount);
      expect(welcomesReceived.length, clientCount);

      // ---- 4. Start countdown and wait for the game to begin ----
      stateMachine.triggerCountdown();
      // Countdown is 5 seconds + 1 second buffer.
      await Future.delayed(const Duration(seconds: 6));

      // ---- 5. Send random movement inputs for 5 seconds ----
      final rng = Random();
      const tickCount = 100; // 5 s at 20 Hz (50 ms per tick)

      for (var tick = 0; tick < tickCount; tick++) {
        for (final client in clients) {
          if (rng.nextDouble() < 0.3) {
            // 30 % chance to change direction.
            final dir = Dir(
              x: rng.nextInt(3) - 1, // -1, 0, or 1
              y: rng.nextInt(3) - 1,
            );
            client.send(ClientMessage.input(dir: dir));
          }
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // ---- 6. Verify no crashes — game is still in 'playing' phase ----
      expect(gameState.phase, GamePhase.playing);

      // ---- 7. Clean shutdown ----
      stateMachine.gameLoop?.stop();
      for (final client in clients) {
        await client.close();
      }
      await server.stop();
    },
    timeout: const Timeout(Duration(seconds: 30)),
    tags: ['stress'],
  );
}
