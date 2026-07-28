import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:capture_the_flag/core/messages.dart';
import 'package:capture_the_flag/network/tcp_framing.dart';
import 'package:capture_the_flag/network/tcp_server.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper: collects framed JSON messages from [socket].
///
/// Returns a [Future] that completes when at least [count] messages have
/// been received, or after [timeout] (returning whatever was collected).
Future<List<Map<String, dynamic>>> _collectMessages(
  Socket socket, {
  required int count,
  Duration timeout = const Duration(seconds: 3),
}) async {
  final framing = TcpFraming();
  final messages = <Map<String, dynamic>>[];
  final completer = Completer<void>();
  late StreamSubscription sub;

  sub = socket.listen(
    (data) {
      try {
        final lines = framing.feed(data);
        for (final line in lines) {
          var json = jsonDecode(line) as Map<String, dynamic>;
          json = canonicalizeDiscriminator(json);
          messages.add(json);
        }
        if (messages.length >= count && !completer.isCompleted) {
          sub.cancel();
          completer.complete();
        }
      } catch (_) {}
    },
    onError: (Object _) {
      if (!completer.isCompleted) completer.completeError('Socket error');
    },
    onDone: () {
      if (!completer.isCompleted) completer.complete();
    },
  );

  try {
    await completer.future.timeout(timeout);
  } on TimeoutException {
    sub.cancel();
  } catch (_) {
    sub.cancel();
  }

  return messages;
}

void main() {
  group('TcpServer', () {
    late TcpServer server;

    setUp(() async {
      server = TcpServer();
    });

    tearDown(() async {
      try {
        await server.stop();
      } catch (_) {
        // Server may already be stopped.
      }
    });

    // -----------------------------------------------------------------------
    // Start / stop
    // -----------------------------------------------------------------------

    test('start and stop server', () async {
      expect(server.isRunning, isFalse);
      expect(server.port, -1);

      await server.start(port: 0);
      expect(server.isRunning, isTrue);
      expect(server.port, greaterThan(0));

      await server.stop();
      expect(server.isRunning, isFalse);
      expect(server.port, -1);
    });

    test('start on already-running server throws', () async {
      await server.start(port: 0);
      expect(() => server.start(port: 0), throwsA(isA<StateError>()));
    });

    // -----------------------------------------------------------------------
    // Client connect
    // -----------------------------------------------------------------------

    test('client connects — onJoin emits ClientSession', () async {
      await server.start(port: 0);

      // MUST subscribe before connecting — broadcast stream drops events
      // that fire before any listener is registered.
      final joinFuture = server.onJoin.first;

      final socket = await Socket.connect('127.0.0.1', server.port);

      final session = await joinFuture.timeout(const Duration(seconds: 2));

      expect(session, isA<ClientSession>());
      expect(session.isActive, isTrue);
      expect(session.playerId, isNull);

      socket.destroy();
    });

    // -----------------------------------------------------------------------
    // Client → Server message
    // -----------------------------------------------------------------------

    test(
      'client sends message — server session receives parsed Join',
      () async {
        await server.start(port: 0);

        final sessionFuture = server.onJoin.first;
        final socket = await Socket.connect('127.0.0.1', server.port);
        final session = await sessionFuture;

        // Listen for messages before sending.
        final msgFuture = session.messages.first;

        socket.write('{"type":"join","v":1,"name":"test"}\n');
        await socket.flush();

        final msg = await msgFuture.timeout(const Duration(seconds: 2));

        expect(msg, isA<Join>());
        final join = msg as Join;
        expect(join.name, 'test');
        expect(join.v, 1);

        socket.destroy();
      },
    );

    test('client sends malformed JSON — session closes', () async {
      await server.start(port: 0);

      final sessionFuture = server.onJoin.first;
      final socket = await Socket.connect('127.0.0.1', server.port);
      final session = await sessionFuture;

      // Drain the message stream so it doesn't hang.
      unawaited(session.messages.drain().catchError((_) {}));

      socket.write('not json at all\n');
      await socket.flush();

      // Give the server a moment to process and close the session.
      await Future.delayed(const Duration(milliseconds: 300));

      expect(session.isActive, isFalse);
      socket.destroy();
    });

    // -----------------------------------------------------------------------
    // Broadcast
    // -----------------------------------------------------------------------

    test('broadcast to all clients', () async {
      await server.start(port: 0);

      // MUST subscribe to onJoin before connecting.
      final sessionsFuture = server.onJoin.take(2).toList();

      final s1 = await Socket.connect('127.0.0.1', server.port);
      final s2 = await Socket.connect('127.0.0.1', server.port);

      final sessions = await sessionsFuture;
      server.registerSession('p1', sessions[0]);
      server.registerSession('p2', sessions[1]);

      // Set up message collectors before broadcast.
      final msgs1Future = _collectMessages(s1, count: 1);
      final msgs2Future = _collectMessages(s2, count: 1);

      // Small delay to let collectors register their listeners.
      await Future.delayed(const Duration(milliseconds: 50));

      server.broadcast(
        ServerMessage.lobby(
          players: [
            LobbyPlayer(id: 'p1', name: 'Alice'),
            LobbyPlayer(id: 'p2', name: 'Bob'),
          ],
        ),
      );

      final msgs1 = await msgs1Future;
      final msgs2 = await msgs2Future;

      expect(msgs1, hasLength(1));
      expect(msgs1[0]['type'], 'lobby');

      expect(msgs2, hasLength(1));
      expect(msgs2[0]['type'], 'lobby');

      s1.destroy();
      s2.destroy();
    });

    // -----------------------------------------------------------------------
    // Coalescible broadcast
    // -----------------------------------------------------------------------

    test(
      'coalescible broadcast — slow client receives fewer messages',
      () async {
        await server.start(port: 0);

        final sessionFuture = server.onJoin.first;
        final socket = await Socket.connect('127.0.0.1', server.port);
        final session = await sessionFuture;
        server.registerSession('p1', session);

        // Collect messages from the client.
        final framing = TcpFraming();
        final messages = <Map<String, dynamic>>[];
        final completer = Completer<void>();
        late StreamSubscription sub;

        sub = socket.listen(
          (data) {
            try {
              final lines = framing.feed(data);
              for (final line in lines) {
                var json = jsonDecode(line) as Map<String, dynamic>;
                json = canonicalizeDiscriminator(json);
                messages.add(json);
              }
            } catch (_) {}
          },
          onError: (_) {
            if (!completer.isCompleted) completer.complete();
          },
          onDone: () {
            if (!completer.isCompleted) completer.complete();
          },
        );

        // Small delay so listener is registered.
        await Future.delayed(const Duration(milliseconds: 50));

        // Fire three state messages rapidly without awaiting.
        final flag = Flag(owner: null, x: 500, y: 500);
        server.broadcastCoalescible(
          ServerMessage.state(flag: flag, players: []) as StateMsg,
        );
        server.broadcastCoalescible(
          ServerMessage.state(
                flag: flag,
                players: [GamePlayer(id: 'p1', x: 500, y: 500)],
              )
              as StateMsg,
        );
        server.broadcastCoalescible(
          ServerMessage.state(
                flag: Flag(owner: 'p1', x: 600, y: 600),
                players: [GamePlayer(id: 'p1', x: 600, y: 600)],
              )
              as StateMsg,
        );

        // Wait for coalescence loop to settle.
        await Future.delayed(const Duration(milliseconds: 500));

        sub.cancel();

        // Count state messages received. Due to coalescence, we expect fewer
        // than 3 (ideally 1–2 — the first + the last coalesced).
        final stateMsgs = messages.where((m) => m['type'] == 'state').toList();

        expect(stateMsgs.length, lessThan(3));
        expect(stateMsgs.length, greaterThanOrEqualTo(1));

        // The last message received should have the flag owner set to 'p1'
        // (the third message's data).
        expect(stateMsgs.last['flag']['owner'], 'p1');

        socket.destroy();
      },
    );

    // -----------------------------------------------------------------------
    // Client disconnect
    // -----------------------------------------------------------------------

    test('client disconnect removes session', () async {
      await server.start(port: 0);

      final sessionFuture = server.onJoin.first;
      final socket = await Socket.connect('127.0.0.1', server.port);
      final session = await sessionFuture;

      server.registerSession('p1', session);
      expect(server.connectionCount, 1);

      // Close the client socket.
      socket.destroy();

      // Give the server a moment to detect the disconnection.
      await Future.delayed(const Duration(milliseconds: 300));

      // The session should be inactive now.
      expect(session.isActive, isFalse);

      // Removing it explicitly cleans up.
      server.removeSession('p1');
      expect(server.connectionCount, 0);
    });

    // -----------------------------------------------------------------------
    // Send to specific client
    // -----------------------------------------------------------------------

    test('sendTo delivers message only to the targeted player', () async {
      await server.start(port: 0);

      final sessionsFuture = server.onJoin.take(2).toList();
      final s1 = await Socket.connect('127.0.0.1', server.port);
      final s2 = await Socket.connect('127.0.0.1', server.port);
      final sessions = await sessionsFuture;

      server.registerSession('p1', sessions[0]);
      server.registerSession('p2', sessions[1]);

      final msgs1Future = _collectMessages(s1, count: 1);

      // Small delay for listener registration.
      await Future.delayed(const Duration(milliseconds: 50));

      // Send welcome only to p1.
      server.sendTo(
        'p1',
        ServerMessage.welcome(
          playerId: 'p1',
          config: WelcomeConfig(
            mapSize: 1000,
            circleRadius: 300,
            playerRadius: 15,
            interactRadius: 40,
            speed: 200,
            tickRate: 20,
          ),
        ),
      );

      final msgs1 = await msgs1Future;
      expect(msgs1, hasLength(1));
      expect(msgs1[0]['type'], 'welcome');
      expect(msgs1[0]['player_id'], 'p1');

      // p2 should not have received welcome — collect with short timeout.
      final msgs2 = await _collectMessages(s2, count: 1);
      final welcomeForP2 = msgs2.where((m) => m['type'] == 'welcome').toList();
      expect(welcomeForP2, isEmpty);

      s1.destroy();
      s2.destroy();
    });

    // -----------------------------------------------------------------------
    // Server stop disconnects all
    // -----------------------------------------------------------------------

    test('server stop disconnects all clients', () async {
      await server.start(port: 0);

      final sessionsFuture = server.onJoin.take(2).toList();
      final s1 = await Socket.connect('127.0.0.1', server.port);
      final s2 = await Socket.connect('127.0.0.1', server.port);
      final sessions = await sessionsFuture;

      server.registerSession('p1', sessions[0]);
      server.registerSession('p2', sessions[1]);

      expect(server.connectionCount, 2);

      await server.stop();

      // Both sessions should be inactive.
      expect(sessions[0].isActive, isFalse);
      expect(sessions[1].isActive, isFalse);
      expect(server.connectionCount, 0);
      expect(server.isRunning, isFalse);

      // Client sockets should be closed from the remote side.
      try {
        s1.write('test\n');
        await s1.flush();
      } catch (_) {
        // Expected.
      }
      s1.destroy();
      s2.destroy();
    });

    // -----------------------------------------------------------------------
    // Connection count tracking
    // -----------------------------------------------------------------------

    test('connectionCount reflects registered sessions', () async {
      await server.start(port: 0);

      expect(server.connectionCount, 0);

      final session1Future = server.onJoin.first;
      final s1 = await Socket.connect('127.0.0.1', server.port);
      final session1 = await session1Future;
      server.registerSession('a', session1);
      expect(server.connectionCount, 1);

      final session2Future = server.onJoin.first;
      final s2 = await Socket.connect('127.0.0.1', server.port);
      final session2 = await session2Future;
      server.registerSession('b', session2);
      expect(server.connectionCount, 2);

      // Re-registering same playerId replaces.
      server.registerSession('a', session2);
      expect(server.connectionCount, 2);

      server.removeSession('a');
      expect(server.connectionCount, 1);

      server.removeSession('b');
      expect(server.connectionCount, 0);

      s1.destroy();
      s2.destroy();
    });
  });
}
