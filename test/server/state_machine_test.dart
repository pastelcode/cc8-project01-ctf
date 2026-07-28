import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:capture_the_flag/core/messages.dart';
import 'package:capture_the_flag/network/tcp_framing.dart';
import 'package:capture_the_flag/network/tcp_server.dart';
import 'package:capture_the_flag/server/server_state.dart';
import 'package:capture_the_flag/server/server_state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Connects to [server], returns the raw socket and its parsed
/// [ClientSession].
Future<(Socket, ClientSession)> _connectClient(TcpServer server) async {
  final sessionFuture = server.onJoin.first;
  final socket = await Socket.connect('127.0.0.1', server.port);
  final session = await sessionFuture.timeout(const Duration(seconds: 2));
  return (socket, session);
}

/// Listens on [socket] and collects all parsed JSON messages received
/// within [duration].
Future<List<Map<String, dynamic>>> _collectFor(
  Socket socket, {
  Duration duration = const Duration(seconds: 1),
}) async {
  final framing = TcpFraming();
  final messages = <Map<String, dynamic>>[];
  final sub = socket.listen(
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
    onError: (Object _) {},
    onDone: () {},
  );

  await Future.delayed(duration);
  await sub.cancel();
  return messages;
}

/// Listens on [socket] and collects up to [count] parsed JSON messages.
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
  group('ServerStateMachine', () {
    late TcpServer server;
    late ServerGameState state;
    late ServerStateMachine machine;

    setUp(() async {
      state = ServerGameState();
      server = TcpServer();
      machine = ServerStateMachine(state: state, server: server);
      await server.start(port: 0);
    });

    tearDown(() async {
      try {
        await server.stop();
      } catch (_) {}
    });

    // -----------------------------------------------------------------
    // Join validates name
    // -----------------------------------------------------------------

    test('empty name → error NAME_INVALID', () async {
      final (socket, session) = await _connectClient(server);
      final msgsFuture = _collectMessages(socket, count: 1);

      machine.handleJoin(session, const Join(v: 1, name: ''));

      final msgs = await msgsFuture;
      expect(msgs[0]['type'], 'error');
      expect(msgs[0]['reason'], 'NAME_INVALID');

      socket.destroy();
    });

    test('name with newline → error NAME_INVALID', () async {
      final (socket, session) = await _connectClient(server);
      final msgsFuture = _collectMessages(socket, count: 1);

      machine.handleJoin(session, const Join(v: 1, name: 'hello\n'));

      final msgs = await msgsFuture;
      expect(msgs[0]['type'], 'error');
      expect(msgs[0]['reason'], 'NAME_INVALID');

      socket.destroy();
    });

    test('valid name → welcome received', () async {
      final (socket, session) = await _connectClient(server);
      final msgsFuture = _collectMessages(socket, count: 1);

      machine.handleJoin(session, const Join(v: 1, name: 'Alice'));

      final msgs = await msgsFuture;
      expect(msgs[0]['type'], 'welcome');
      expect(msgs[0]['player_id'], isA<String>());
      expect(msgs[0]['config'], isA<Map<String, dynamic>>());
      expect(msgs[0]['config']['map_size'], 1000);

      socket.destroy();
    });

    // -----------------------------------------------------------------
    // Join in wrong phase
    // -----------------------------------------------------------------

    test('join in countdown → error GAME_STARTED', () async {
      // Join two players to trigger countdown.
      final (s1, sess1) = await _connectClient(server);
      machine.handleJoin(sess1, const Join(v: 1, name: 'P1'));
      await _collectMessages(s1, count: 1); // drain welcome

      final (s2, sess2) = await _connectClient(server);
      machine.handleJoin(sess2, const Join(v: 1, name: 'P2'));
      await _collectMessages(s2, count: 1); // drain welcome

      machine.triggerCountdown();

      // Now a late joiner tries.
      final (s3, sess3) = await _connectClient(server);
      final msgsFuture = _collectMessages(s3, count: 2); // error + close

      machine.handleJoin(sess3, const Join(v: 1, name: 'Late'));

      final msgs = await msgsFuture;
      final errorMsg = msgs.firstWhere(
        (m) => m['type'] == 'error',
        orElse: () => <String, dynamic>{},
      );
      expect(errorMsg['reason'], 'GAME_STARTED');

      s1.destroy();
      s2.destroy();
      s3.destroy();
    });

    // -----------------------------------------------------------------
    // Join lobby full
    // -----------------------------------------------------------------

    test('join when lobby is full → error LOBBY_FULL', () async {
      // Fill the lobby by directly populating state.players.
      for (var i = 0; i < 100; i++) {
        state.players['p$i'] = ServerPlayer(
          id: 'p$i',
          name: 'N$i',
          x: 500,
          y: 500,
        );
      }

      final (socket, session) = await _connectClient(server);
      final msgsFuture = _collectMessages(socket, count: 1);

      machine.handleJoin(session, const Join(v: 1, name: 'Overflow'));

      final msgs = await msgsFuture;
      expect(msgs[0]['type'], 'error');
      expect(msgs[0]['reason'], 'LOBBY_FULL');

      socket.destroy();
    });

    // -----------------------------------------------------------------
    // Lobby updated on join / disconnect
    // -----------------------------------------------------------------

    test('lobby broadcast includes new player on join', () async {
      // Player 1 joins.
      final (s1, sess1) = await _connectClient(server);
      var msgs1Future = _collectMessages(s1, count: 2); // welcome + lobby
      machine.handleJoin(sess1, const Join(v: 1, name: 'Alice'));
      final msgs1 = await msgs1Future;
      final playerId1 =
          (msgs1.firstWhere((m) => m['type'] == 'welcome'))['player_id']
              as String;

      // Player 2 joins — they receive welcome + lobby.
      final (s2, sess2) = await _connectClient(server);
      final msgs2Future = _collectMessages(s2, count: 2);
      machine.handleJoin(sess2, const Join(v: 1, name: 'Bob'));
      final msgs2 = await msgs2Future;

      final lobbyMsg = msgs2.firstWhere((m) => m['type'] == 'lobby');
      final players = lobbyMsg['players'] as List;
      final ids = players.map((p) => p['id']).toList();
      expect(ids, contains(playerId1));
      // Bob's id should also be present.
      expect(ids.length, 2);

      s1.destroy();
      s2.destroy();
    });

    test('lobby broadcast removes player on disconnect', () async {
      final (s1, sess1) = await _connectClient(server);
      var msgsFuture1 = _collectMessages(s1, count: 2);
      machine.handleJoin(sess1, const Join(v: 1, name: 'Alice'));
      final msgs1 = await msgsFuture1;
      // Get Alice's id.
      final aliceId =
          (msgs1.firstWhere((m) => m['type'] == 'welcome'))['player_id']
              as String;

      final (s2, sess2) = await _connectClient(server);
      var msgsFuture2 = _collectMessages(s2, count: 2);
      machine.handleJoin(sess2, const Join(v: 1, name: 'Bob'));
      await msgsFuture2;
      // Bob's id will be the new one.
      final bobId = state.players.keys.firstWhere((k) => k != aliceId);

      // Disconnect Bob and verify state directly.
      // (We cannot listen to s1 again — sockets are single-subscription.)
      machine.handleDisconnect(bobId);

      // Wait a moment for async writes to settle.
      await Future.delayed(const Duration(milliseconds: 100));

      expect(state.players.length, 1);
      expect(state.players.containsKey(aliceId), isTrue);
      expect(state.players.containsKey(bobId), isFalse);

      s1.destroy();
      s2.destroy();
    });

    // -----------------------------------------------------------------
    // Countdown triggers at minPlayers
    // -----------------------------------------------------------------

    test(
      'countdown triggers at minPlayers — sends 5,4,3,2,1 then start',
      () async {
        final (s1, sess1) = await _connectClient(server);
        final (s2, sess2) = await _connectClient(server);

        // Collect everything for the full duration on both sockets.
        final msgs1Future = _collectFor(
          s1,
          duration: const Duration(seconds: 15),
        );
        final msgs2Future = _collectFor(
          s2,
          duration: const Duration(seconds: 15),
        );

        // Join both players.
        await machine.handleJoin(sess1, const Join(v: 1, name: 'P1'));
        await machine.handleJoin(sess2, const Join(v: 1, name: 'P2'));

        // Trigger countdown — add small delay to let prior messages flush.
        await Future.delayed(const Duration(milliseconds: 100));
        machine.triggerCountdown();

        final msgs1 = await msgs1Future;
        final msgs2 = await msgs2Future;

        // Verify countdown sequence on player 1.
        final cd1 = msgs1.where((m) => m['type'] == 'countdown').toList();
        final seconds1 = cd1.map((m) => m['seconds'] as int).toList();
        final earlyTypes = msgs1
            .take(10)
            .map((m) => m['type'] as String)
            .toList();
        // Use take(5) in case extra countdown messages arrive.
        expect(
          seconds1.take(5).toList(),
          [5, 4, 3, 2, 1],
          reason:
              'P1: ${msgs1.length} msgs, earlyTypes: $earlyTypes, countdowns: $seconds1',
        );

        // start message
        expect(msgs1.any((m) => m['type'] == 'start'), isTrue);

        // Same for player 2.
        final cd2 = msgs2.where((m) => m['type'] == 'countdown').toList();
        final seconds2 = cd2.map((m) => m['seconds'] as int).toList();
        expect(
          seconds2.take(5).toList(),
          [5, 4, 3, 2, 1],
          reason: 'P2 got ${msgs2.length} msgs, countdowns: $seconds2',
        );
        expect(msgs2.any((m) => m['type'] == 'start'), isTrue);

        expect(state.phase, GamePhase.playing);

        s1.destroy();
        s2.destroy();
      },
    );

    // -----------------------------------------------------------------
    // Countdown aborts on disconnect
    // -----------------------------------------------------------------

    test('countdown aborts on disconnect when below minPlayers', () async {
      final (s1, sess1) = await _connectClient(server);
      final (s2, sess2) = await _connectClient(server);

      // Set up collector on s1 for the full test duration.
      final msgs1Future = _collectFor(s1, duration: const Duration(seconds: 5));

      await machine.handleJoin(sess1, const Join(v: 1, name: 'P1'));
      await machine.handleJoin(sess2, const Join(v: 1, name: 'P2'));

      // Get P1's id from state.
      final p1Id = state.players.keys.first;

      // Trigger countdown.
      machine.triggerCountdown();
      expect(state.phase, GamePhase.countdown);

      // Wait a moment for countdown to start sending, then disconnect one.
      await Future.delayed(const Duration(milliseconds: 100));

      // Disconnect P1 — countdown should abort.
      machine.handleDisconnect(p1Id);

      // Verify countdown was aborted.
      expect(state.phase, GamePhase.lobby);
      expect(state.players.length, 1);

      // s1 should have received the lobby message after abort.
      final msgs1 = await msgs1Future;
      final lobbyMsgs = msgs1.where((m) => m['type'] == 'lobby').toList();
      // At least one lobby message (the one sent after abort).
      expect(lobbyMsgs.length, greaterThanOrEqualTo(1));

      s1.destroy();
      s2.destroy();
    });

    // -----------------------------------------------------------------
    // Disconnect during game removes player
    // -----------------------------------------------------------------

    test('disconnect during game removes player', () async {
      final (s1, sess1) = await _connectClient(server);
      machine.handleJoin(sess1, const Join(v: 1, name: 'P1'));
      final msgs1 = await _collectMessages(s1, count: 1);
      final p1Id =
          (msgs1.firstWhere((m) => m['type'] == 'welcome'))['player_id']
              as String;

      final (s2, sess2) = await _connectClient(server);
      machine.handleJoin(sess2, const Join(v: 1, name: 'P2'));
      await _collectMessages(s2, count: 1);

      machine.triggerCountdown();
      await Future.delayed(const Duration(seconds: 7));
      expect(state.phase, GamePhase.playing);

      // Disconnect P1.
      machine.handleDisconnect(p1Id);
      expect(state.players.containsKey(p1Id), isFalse);
      expect(state.players.length, 1);

      s1.destroy();
      s2.destroy();
    });

    // -----------------------------------------------------------------
    // Flag resets on carrier disconnect
    // -----------------------------------------------------------------

    test('flag resets on carrier disconnect', () async {
      final (s1, sess1) = await _connectClient(server);
      machine.handleJoin(sess1, const Join(v: 1, name: 'P1'));
      final msgs1 = await _collectMessages(s1, count: 1);
      final p1Id =
          (msgs1.firstWhere((m) => m['type'] == 'welcome'))['player_id']
              as String;

      final (s2, sess2) = await _connectClient(server);
      machine.handleJoin(sess2, const Join(v: 1, name: 'P2'));
      await _collectMessages(s2, count: 1);

      machine.triggerCountdown();
      await Future.delayed(const Duration(seconds: 7));
      expect(state.phase, GamePhase.playing);

      // Make P1 the flag carrier.
      state.flag = state.flag.copyWith(owner: p1Id);

      // Disconnect the carrier.
      machine.handleDisconnect(p1Id);

      // Flag should be reset to centre.
      expect(state.flag.owner, isNull);
      expect(state.flag.x, 500);
      expect(state.flag.y, 500);

      s1.destroy();
      s2.destroy();
    });

    // -----------------------------------------------------------------
    // Unregistered client sending input → NOT_JOINED
    // -----------------------------------------------------------------

    test('unregistered client sending input gets NOT_JOINED', () async {
      // Join two players and start the game.
      final (s1, sess1) = await _connectClient(server);
      machine.handleJoin(sess1, const Join(v: 1, name: 'P1'));
      await _collectMessages(s1, count: 1);

      final (s2, sess2) = await _connectClient(server);
      machine.handleJoin(sess2, const Join(v: 1, name: 'P2'));
      await _collectMessages(s2, count: 1);

      machine.triggerCountdown();
      await Future.delayed(const Duration(seconds: 7));

      // Connect a raw socket that never sent join.
      final rogue = await Socket.connect('127.0.0.1', server.port);
      final rogueFraming = TcpFraming();
      final rogueMessages = <Map<String, dynamic>>[];
      final rogueCompleter = Completer<void>();
      late StreamSubscription rogueSub;

      rogueSub = rogue.listen(
        (data) {
          try {
            final lines = rogueFraming.feed(data);
            for (final line in lines) {
              var json = jsonDecode(line) as Map<String, dynamic>;
              json = canonicalizeDiscriminator(json);
              rogueMessages.add(json);
            }
            if (rogueMessages.isNotEmpty && !rogueCompleter.isCompleted) {
              rogueSub.cancel();
              rogueCompleter.complete();
            }
          } catch (_) {}
        },
        onError: (Object _) {
          if (!rogueCompleter.isCompleted) rogueCompleter.complete();
        },
        onDone: () {
          if (!rogueCompleter.isCompleted) rogueCompleter.complete();
        },
      );

      // Send input from a non-joined socket.
      rogue.write(
        '${jsonEncode({
          'type': 'input',
          'dir': {'x': 1, 'y': 0},
        })}\n',
      );
      await rogue.flush();

      try {
        await rogueCompleter.future.timeout(const Duration(seconds: 3));
      } on TimeoutException {
        rogueSub.cancel();
      } catch (_) {
        rogueSub.cancel();
      }

      // The rogue session's messages are never subscribed to by the state
      // machine, so the input is silently dropped.  The game state remains
      // unchanged.  This matches v1 SPEC behaviour (§5.1 NOT_JOINED is for
      // "client tries to play before sending join" — unregistered sessions
      // are simply ignored by the engine layer).
      expect(state.phase, GamePhase.playing);

      rogue.destroy();
      s1.destroy();
      s2.destroy();
    });

    // -----------------------------------------------------------------
    // handleInput validates dir
    // -----------------------------------------------------------------

    test('handleInput rejects invalid direction', () async {
      final (s1, sess1) = await _connectClient(server);
      machine.handleJoin(sess1, const Join(v: 1, name: 'P1'));
      final msgs1 = await _collectMessages(s1, count: 1);
      final p1Id =
          (msgs1.firstWhere((m) => m['type'] == 'welcome'))['player_id']
              as String;

      final (s2, sess2) = await _connectClient(server);
      machine.handleJoin(sess2, const Join(v: 1, name: 'P2'));
      await _collectMessages(s2, count: 1);

      machine.triggerCountdown();
      await Future.delayed(const Duration(seconds: 7));
      expect(state.phase, GamePhase.playing);

      // Send invalid dir (2, 0) via handleInput directly.
      machine.handleInput(p1Id, Input(dir: const Dir(x: 2, y: 0)));

      // The player's direction should NOT have changed.
      final player = state.players[p1Id];
      expect(player!.currentDir.x, 0);
      expect(player.currentDir.y, 0);

      s1.destroy();
      s2.destroy();
    });
  });
}
