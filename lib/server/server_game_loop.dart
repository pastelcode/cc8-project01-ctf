import 'dart:async';

import '../core/constants.dart';
import '../core/geometry.dart';
import '../core/messages.dart';
import '../network/tcp_server.dart';
import 'server_state.dart';

/// Drives the 20 Hz authoritative game simulation.
///
/// On each tick the loop applies movement, updates the flag position,
/// checks the victory condition, processes queued interactions, and
/// broadcasts the resulting state to all clients.
class ServerGameLoop {
  final ServerGameState state;
  final TcpServer server;

  /// Called when the victory condition is met during a tick.
  final void Function(String winnerId) onVictory;

  /// Called at the end of each tick, after the state broadcast.
  /// Used by the host provider to sync state into the client-side
  /// [gameStateProvider] so the host can spectate its own server.
  void Function()? onTick;

  Timer? _tickTimer;

  /// Tick duration for 20 Hz simulation.
  static const tickDuration = Duration(milliseconds: 50);

  /// Fixed delta‑time used by integration (1 / 20 s).
  static const double dt = 1.0 / 20.0;

  /// Pre‑computed 1 / √2 for diagonal normalization.
  static const double _invSqrt2 = 1.0 / 1.4142135623730951;

  ServerGameLoop({
    required this.state,
    required this.server,
    required this.onVictory,
    this.onTick,
  });

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Starts the periodic tick timer.
  ///
  /// Idempotent — if a timer is already running this is a no‑op.
  void start() {
    if (_tickTimer != null) return;
    _tickTimer = Timer.periodic(tickDuration, (_) => tick());
  }

  /// Stops the tick timer.
  void stop() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  /// Whether the tick timer is currently active.
  bool get isRunning => _tickTimer != null;

  // ---------------------------------------------------------------------------
  // Tick
  // ---------------------------------------------------------------------------

  /// Runs one simulation tick.
  ///
  /// Public so that unit tests can advance the simulation frame‑by‑frame
  /// without a real timer.
  void tick() {
    if (state.phase != GamePhase.playing) return;

    // 1. APPLY MOVEMENT to all players.
    _applyMovement();

    // 2. UPDATE FLAG POSITION (follow carrier).
    _updateFlagPosition();

    // 3. CHECK VICTORY CONDITION (before interactions, per §4.1).
    if (_checkVictory()) return; // tick aborted — game over was triggered

    // 4. PROCESS INTERACTIONS (one per tick, in queue order).
    _processInteractions();

    // 5. BROADCAST STATE.
    server.broadcastCoalescible(state.toStateMsg());

    // 6. NOTIFY HOST (if any) about the new state.
    onTick?.call();
  }

  // ---------------------------------------------------------------------------
  // Private tick steps
  // ---------------------------------------------------------------------------

  /// Applies the current direction of each player, clamped to the map.
  void _applyMovement() {
    for (final player in state.players.values) {
      final dir = player.currentDir;
      if (dir.x == 0 && dir.y == 0) continue;

      double dx = dir.x.toDouble();
      double dy = dir.y.toDouble();

      // Normalize diagonals so speed is identical in all 8 directions.
      if (dx != 0 && dy != 0) {
        dx *= _invSqrt2;
        dy *= _invSqrt2;
      }

      player.x += dx * Constants.speed * dt;
      player.y += dy * Constants.speed * dt;
      player.x = Geometry.clampToMap(player.x);
      player.y = Geometry.clampToMap(player.y);
    }
  }

  /// If the flag is carried, snap its position to the carrier.
  void _updateFlagPosition() {
    final ownerId = state.flag.owner;
    if (ownerId == null) return;

    final carrier = state.players[ownerId];
    if (carrier != null) {
      state.flag = state.flag.copyWith(x: carrier.x, y: carrier.y);
    }
  }

  /// Checks whether the carrier has satisfied the victory condition.
  ///
  /// Returns `true` if the game was ended (the caller should abort the rest
  /// of the tick).
  ///
  /// Per §3.3: the carrier must transition from inside/on the circle
  /// (distance ≤ 315) to completely outside (distance > 315).
  bool _checkVictory() {
    final ownerId = state.flag.owner;
    if (ownerId == null) return false;

    final carrier = state.players[ownerId];
    if (carrier == null) return false;

    final dist = Geometry.distanceToCenter(carrier.x, carrier.y);

    if (carrier.wasInsideCircle && dist > Constants.victoryDistance) {
      onVictory(ownerId);
      return true;
    }

    // Track inside/outside state for the next tick.
    carrier.wasInsideCircle = dist <= Constants.victoryDistance;
    return false;
  }

  /// Processes pending interact requests in arrival order.
  ///
  /// Only one interaction is fully evaluated per tick (the first valid one),
  /// but all queued interactions are drained so the queue doesn't build up
  /// across ticks.  Per §5.3 each `interact` is processed in arrival order.
  void _processInteractions() {
    while (state.interactionQueue.isNotEmpty) {
      final playerId = state.interactionQueue.removeFirst();
      final player = state.players[playerId];
      if (player == null) continue;

      if (state.flag.owner == null) {
        // --- Capture: flag is free ---
        final dist = Geometry.distance(
          player.x,
          player.y,
          Constants.circleCenterX,
          Constants.circleCenterY,
        );
        if (dist <= Constants.interactRadius) {
          state.flag = state.flag.copyWith(owner: playerId);
          player.wasInsideCircle =
              Geometry.distanceToCenter(player.x, player.y) <=
              Constants.victoryDistance;
        }
      } else if (state.flag.owner != playerId) {
        // --- Steal: flag is held by someone else ---
        final carrier = state.players[state.flag.owner];
        if (carrier != null &&
            Geometry.withinInteractRange(
              player.x,
              player.y,
              carrier.x,
              carrier.y,
            )) {
          state.flag = state.flag.copyWith(owner: playerId);
          player.wasInsideCircle =
              Geometry.distanceToCenter(player.x, player.y) <=
              Constants.victoryDistance;
        }
      }
      // If the player is already the carrier, their interact is a no‑op
      // (per §5.3 "Duplicate attempt by the same player").
    }
  }
}
