import 'package:capture_the_flag/core/messages.dart';
import 'package:capture_the_flag/network/tcp_server.dart';
import 'package:capture_the_flag/server/server_game_loop.dart';
import 'package:capture_the_flag/server/server_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServerGameLoop tick', () {
    late ServerGameState state;
    late List<String> victories;
    late ServerGameLoop loop;

    setUp(() {
      state = ServerGameState();
      state.phase = GamePhase.playing;
      victories = [];
      loop = ServerGameLoop(
        state: state,
        // An unstarted TcpServer is safe to pass — broadcasts are no‑ops
        // because no sessions are registered.
        server: TcpServer(),
        onVictory: (winnerId) => victories.add(winnerId),
      );
    });

    // -----------------------------------------------------------------
    // Movement
    // -----------------------------------------------------------------

    test('movement: dir (1, 0) → x increases by speed * dt', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      player.currentDir = const Dir(x: 1, y: 0);
      state.players['p1'] = player;

      loop.tick();

      // speed = 200, dt = 1/20 = 0.05 → Δ = 10
      expect(player.x, closeTo(510.0, 1e-9));
      expect(player.y, closeTo(500.0, 1e-9));
    });

    test('movement: dir (-1, 0) → x decreases by speed * dt', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      player.currentDir = const Dir(x: -1, y: 0);
      state.players['p1'] = player;

      loop.tick();

      expect(player.x, closeTo(490.0, 1e-9));
    });

    test('movement: dir (0, -1) → y decreases by speed * dt', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      player.currentDir = const Dir(x: 0, y: -1);
      state.players['p1'] = player;

      loop.tick();

      expect(player.y, closeTo(490.0, 1e-9));
    });

    // -----------------------------------------------------------------
    // Diagonal normalization
    // -----------------------------------------------------------------

    test('diagonal (1, 1) → x and y each increase by ~7.071', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      player.currentDir = const Dir(x: 1, y: 1);
      state.players['p1'] = player;

      loop.tick();

      // speed 200 * 0.05 / √2 = 10 / 1.41421356 ≈ 7.07107
      const expected = 200.0 * ServerGameLoop.dt / 1.4142135623730951;
      expect(player.x, closeTo(500.0 + expected, 1e-6));
      expect(player.y, closeTo(500.0 + expected, 1e-6));
    });

    test('diagonal (-1, 1) → x decreases, y increases by same amount', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      player.currentDir = const Dir(x: -1, y: 1);
      state.players['p1'] = player;

      loop.tick();

      const expected = 200.0 * ServerGameLoop.dt / 1.4142135623730951;
      expect(player.x, closeTo(500.0 - expected, 1e-6));
      expect(player.y, closeTo(500.0 + expected, 1e-6));
    });

    // -----------------------------------------------------------------
    // Map clamping
    // -----------------------------------------------------------------

    test('clamping: x below 15 → clamped to 15', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 20, y: 500);
      player.currentDir = const Dir(x: -1, y: 0);
      state.players['p1'] = player;

      // One tick moves x from 20 to 10 (5 px past boundary).
      loop.tick();
      expect(player.x, 15.0);

      // Second tick: should not move further left.
      loop.tick();
      expect(player.x, 15.0);
    });

    test('clamping: x above 985 → clamped to 985', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 980, y: 500);
      player.currentDir = const Dir(x: 1, y: 0);
      state.players['p1'] = player;

      // 980 + 10 = 990 → clamped to 985.
      loop.tick();
      expect(player.x, 985.0);

      // Should not move further right.
      loop.tick();
      expect(player.x, 985.0);
    });

    test('clamping: y below 15 → clamped to 15', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 20);
      player.currentDir = const Dir(x: 0, y: -1);
      state.players['p1'] = player;

      loop.tick();
      expect(player.y, 15.0);
    });

    test('clamping: y above 985 → clamped to 985', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 980);
      player.currentDir = const Dir(x: 0, y: 1);
      state.players['p1'] = player;

      loop.tick();
      expect(player.y, 985.0);
    });

    test('clamping both axes simultaneously', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 10, y: 990);
      player.currentDir = const Dir(x: -1, y: 1);
      state.players['p1'] = player;

      loop.tick();
      expect(player.x, 15.0);
      expect(player.y, 985.0);
    });

    // -----------------------------------------------------------------
    // Flag capture
    // -----------------------------------------------------------------

    test('flag capture: free flag, player at centre, interact → captured', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      state.players['p1'] = player;
      state.flag = const Flag(owner: null, x: 500, y: 500);

      // Queue interact.
      state.interactionQueue.add('p1');

      loop.tick();

      expect(state.flag.owner, 'p1');
    });

    test('flag capture: player too far from centre → no capture', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 450);
      state.players['p1'] = player;
      state.flag = const Flag(owner: null, x: 500, y: 500);

      state.interactionQueue.add('p1');

      loop.tick();

      // Distance from (500,450) to centre (500,500) = 50 > interactRadius (40).
      expect(state.flag.owner, isNull);
    });

    test('flag capture: at boundary of interactRadius (distance = 40)', () {
      // (540, 500) is exactly 40 from (500, 500).
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 540, y: 500);
      state.players['p1'] = player;
      state.flag = const Flag(owner: null, x: 500, y: 500);

      state.interactionQueue.add('p1');

      loop.tick();

      expect(state.flag.owner, 'p1');
    });

    // -----------------------------------------------------------------
    // Flag steal
    // -----------------------------------------------------------------

    test('flag steal: carrier at (500,500), thief at (540,500) → steal', () {
      final carrier = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      final thief = ServerPlayer(id: 'p2', name: 'P2', x: 540, y: 500);
      state.players['p1'] = carrier;
      state.players['p2'] = thief;
      state.flag = const Flag(
        owner: null,
        x: 500,
        y: 500,
      ).copyWith(owner: 'p1');

      state.interactionQueue.add('p2');

      loop.tick();

      expect(state.flag.owner, 'p2');
    });

    test('flag steal: thief too far → no steal', () {
      final carrier = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      final thief = ServerPlayer(id: 'p2', name: 'P2', x: 545, y: 500);
      state.players['p1'] = carrier;
      state.players['p2'] = thief;
      state.flag = const Flag(
        owner: null,
        x: 500,
        y: 500,
      ).copyWith(owner: 'p1');

      state.interactionQueue.add('p2');

      loop.tick();

      // Distance 45 > interactRadius 40.
      expect(state.flag.owner, 'p1');
    });

    // -----------------------------------------------------------------
    // Flag follows carrier
    // -----------------------------------------------------------------

    test('flag follows carrier', () {
      final carrier = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      carrier.currentDir = const Dir(x: 1, y: 0);
      state.players['p1'] = carrier;
      state.flag = const Flag(
        owner: null,
        x: 500,
        y: 500,
      ).copyWith(owner: 'p1');

      loop.tick();

      expect(state.flag.x, carrier.x);
      expect(state.flag.y, carrier.y);
    });

    // -----------------------------------------------------------------
    // Victory detection
    // -----------------------------------------------------------------

    test('victory: carrier was inside circle, moves outside → game ends', () {
      // Place carrier at centre (inside circle).
      final carrier = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      carrier.wasInsideCircle = true;
      state.players['p1'] = carrier;
      state.flag = const Flag(
        owner: null,
        x: 500,
        y: 500,
      ).copyWith(owner: 'p1');

      // Place carrier at boundary and push them over.
      carrier.x = 500;
      carrier.y = 185; // distance = 315, on boundary
      carrier.currentDir = const Dir(x: 0, y: -1); // move up 10 → y=175

      loop.tick();

      // y = 185 - 10 = 175, distance from centre = 325 > 315.
      // wasInsideCircle was true → victory!
      expect(victories, ['p1']);
    });

    test('victory NOT triggered without inside→outside transition', () {
      // Carrier spawns outside and steals flag while outside.
      // wasInsideCircle = false → should NOT win when moving further out.
      final carrier = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 100);
      carrier.wasInsideCircle = false;
      state.players['p1'] = carrier;
      state.flag = const Flag(
        owner: null,
        x: 500,
        y: 500,
      ).copyWith(owner: 'p1');

      // Move further out.
      carrier.currentDir = const Dir(x: 0, y: -1); // y goes from 100 to 90

      loop.tick();

      expect(victories, isEmpty);
    });

    test('wasInsideCircle updated when carrier enters circle', () {
      // Carrier starts outside.
      final carrier = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 100);
      carrier.wasInsideCircle = false;
      carrier.currentDir = const Dir(x: 0, y: 1); // move toward centre
      state.players['p1'] = carrier;
      state.flag = const Flag(
        owner: null,
        x: 500,
        y: 500,
      ).copyWith(owner: 'p1');

      // Move toward centre: y goes from 100 to 110 each tick.
      // Need to reach y ≥ 185 (distance ≤ 315).
      // 185 - 100 = 85, at 10/tick → 9 ticks.
      for (var i = 0; i < 9; i++) {
        loop.tick();
      }

      // After 9 ticks, y = 100 + 9*10 = 190, distance = 310 ≤ 315.
      expect(carrier.wasInsideCircle, isTrue);
    });

    // -----------------------------------------------------------------
    // Interaction processed after movement in same tick
    // -----------------------------------------------------------------

    test(
      'movement before interaction: move into range, interact → capture',
      () {
        // Player starts just outside interact range, moves toward centre.
        final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 545);
        // Distance to centre (500,500) = 45 > interactRadius (40).
        player.currentDir = const Dir(x: 0, y: -1); // move up 10
        state.players['p1'] = player;
        state.flag = const Flag(owner: null, x: 500, y: 500);

        // Queue interact (processed after movement).
        state.interactionQueue.add('p1');

        loop.tick();

        // After movement: y = 545 - 10 = 535, distance to centre = 35 < 40.
        // Interaction should succeed.
        expect(state.flag.owner, 'p1');
      },
    );

    // -----------------------------------------------------------------
    // Victory evaluated before interactions
    // -----------------------------------------------------------------

    test('victory before theft: carrier crosses boundary, thief queued', () {
      // Carrier is at boundary, about to cross out and win.
      // A thief has also queued interact.
      // Per §4.1, movement+victory are evaluated before interactions.
      final carrier = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 185);
      carrier.wasInsideCircle = true;
      carrier.currentDir = const Dir(x: 0, y: -1);
      state.players['p1'] = carrier;
      state.flag = const Flag(
        owner: null,
        x: 500,
        y: 500,
      ).copyWith(owner: 'p1');

      // Thief is right next to carrier.
      final thief = ServerPlayer(id: 'p2', name: 'P2', x: 500, y: 185);
      state.players['p2'] = thief;

      // Queue thief's interact.
      state.interactionQueue.add('p2');

      loop.tick();

      // Carrier should win (victory before theft).
      expect(victories, ['p1']);
      // Flag should still be owned by p1 (theft not processed).
      expect(state.flag.owner, 'p1');
    });

    // -----------------------------------------------------------------
    // Edge cases
    // -----------------------------------------------------------------

    test('tick does nothing when phase is not playing', () {
      state.phase = GamePhase.lobby;
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      player.currentDir = const Dir(x: 1, y: 0);
      state.players['p1'] = player;

      loop.tick();

      // Position should not change.
      expect(player.x, 500.0);
      expect(player.y, 500.0);
    });

    test('idle player (dir 0,0) does not move', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      player.currentDir = const Dir(x: 0, y: 0);
      state.players['p1'] = player;

      loop.tick();

      expect(player.x, 500.0);
      expect(player.y, 500.0);
    });

    test('multiple players move independently', () {
      final p1 = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      p1.currentDir = const Dir(x: 1, y: 0);
      final p2 = ServerPlayer(id: 'p2', name: 'P2', x: 500, y: 500);
      p2.currentDir = const Dir(x: -1, y: 0);
      state.players['p1'] = p1;
      state.players['p2'] = p2;

      loop.tick();

      expect(p1.x, closeTo(510.0, 1e-9));
      expect(p2.x, closeTo(490.0, 1e-9));
    });

    test('interact from flag carrier is no-op', () {
      final carrier = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      state.players['p1'] = carrier;
      state.flag = const Flag(
        owner: null,
        x: 500,
        y: 500,
      ).copyWith(owner: 'p1');

      // Carrier tries to interact — should be ignored.
      state.interactionQueue.add('p1');

      loop.tick();

      expect(state.flag.owner, 'p1'); // unchanged
    });

    test('interact from non-existent player is ignored', () {
      state.interactionQueue.add('ghost');
      // Should not throw.
      loop.tick();
    });

    test('interact queue is fully drained each tick', () {
      final player = ServerPlayer(id: 'p1', name: 'P1', x: 500, y: 500);
      state.players['p1'] = player;
      state.flag = const Flag(owner: null, x: 500, y: 500);

      // Add multiple interactions (duplicates are fine).
      state.interactionQueue.add('p1');
      state.interactionQueue.add('p1');
      state.interactionQueue.add('p1');

      loop.tick();

      expect(state.interactionQueue, isEmpty);
      // Flag should have been captured on the first interaction.
      expect(state.flag.owner, 'p1');
    });
  });
}
