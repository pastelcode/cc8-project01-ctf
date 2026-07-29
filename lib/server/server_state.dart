import 'dart:collection';

import '../core/geometry.dart';
import '../core/messages.dart';

/// Represents a player managed by the server.
///
/// Stores identity, position, direction, and victory‑tracking state.
class ServerPlayer {
  final String id;
  final String name;
  double x, y;
  Dir currentDir;

  /// Tracks the inside→outside transition required for victory (§3.3).
  ///
  /// Set to `true` when the carrier is inside or on the edge of the circle
  /// (distance ≤ 315). Victory is triggered when this is `true` and the
  /// carrier subsequently moves outside (distance > 315).
  bool wasInsideCircle;

  /// Interactions queued for this player during the current tick.
  /// Cleared each tick after processing.
  final Queue<DateTime> pendingInteractions;

  ServerPlayer({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    Dir? currentDir,
    bool? wasInsideCircle,
  }) : currentDir = currentDir ?? const Dir(x: 0, y: 0),
       wasInsideCircle = wasInsideCircle ?? false,
       pendingInteractions = Queue<DateTime>();
}

/// The entire game world state managed by the server.
///
/// Owns all [ServerPlayer] instances, the [Flag], and the current
/// [GamePhase]. Provides convenience projections for protocol messages.
class ServerGameState {
  GamePhase phase = GamePhase.lobby;
  final Map<String, ServerPlayer> players = {};

  /// The flag. `owner` is `null` when the flag is free.
  Flag flag = const Flag(owner: null, x: 500, y: 500);

  /// Pending interact requests for the current tick, in arrival order.
  ///
  /// Each entry is a [playerId] of the player who sent `interact`.
  /// Processed by [ServerGameLoop] during the tick and then cleared.
  final Queue<String> interactionQueue = Queue<String>();

  /// The winner for the current round, or `null` if no round has concluded
  /// yet.
  String? winnerId;

  /// Current countdown second (5 → 1).  Read by [ServerProvider] so the host
  /// spectating view shows the correct countdown tick.
  int countdownSeconds = 5;

  // ---------------------------------------------------------------------------
  // Convenience projections
  // ---------------------------------------------------------------------------

  /// All connected players as [LobbyPlayer] instances (for `lobby` messages).
  List<LobbyPlayer> get lobbyPlayers =>
      players.values.map((p) => LobbyPlayer(id: p.id, name: p.name)).toList();

  /// All connected players as [GamePlayer] instances (for `state` messages).
  List<GamePlayer> get gamePlayers =>
      players.values.map((p) => GamePlayer(id: p.id, x: p.x, y: p.y)).toList();

  /// Creates a [StateMsg] from the current game state.
  StateMsg toStateMsg() =>
      ServerMessage.state(flag: flag, players: gamePlayers) as StateMsg;

  /// Creates a [Lobby] message from the current lobby state.
  Lobby toLobbyMsg() => ServerMessage.lobby(players: lobbyPlayers) as Lobby;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns a random spawn position in the ring outside the victory circle
  /// (§3.3: radius ∈ [350, 450], angle ∈ [0, 2π)).
  ({double x, double y}) spawnPlayer() {
    return Geometry.randomSpawnPosition();
  }

  /// Resets the game state for a new round while preserving player
  /// connections (names and ids).
  ///
  /// After this call the server is back in [GamePhase.lobby], the flag is
  /// returned to the centre, and all per‑player game state is cleared.
  void resetForNewRound() {
    phase = GamePhase.lobby;
    flag = const Flag(owner: null, x: 500, y: 500);
    winnerId = null;
    interactionQueue.clear();
    for (final player in players.values) {
      player.currentDir = const Dir(x: 0, y: 0);
      player.wasInsideCircle = false;
      player.pendingInteractions.clear();
    }
  }
}
