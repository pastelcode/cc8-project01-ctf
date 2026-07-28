import 'dart:async';
import 'dart:math';

import '../core/constants.dart';
import '../core/messages.dart';
import '../core/validation.dart';
import '../network/tcp_server.dart';
import 'server_game_loop.dart';
import 'server_state.dart';

/// Drives game‑phase transitions and handles inbound protocol messages.
///
/// Owns a [ServerGameState] and a [TcpServer]. Processes [Join], [Input],
/// [Interact], and disconnect events, enforcing the rules defined in SPEC
/// §§3–5.
class ServerStateMachine {
  final ServerGameState state;
  final TcpServer server;

  /// Active game loop, non‑null only while the game is in [GamePhase.playing].
  ServerGameLoop? _gameLoop;

  /// Public accessor so the host provider can reference the active loop.
  ServerGameLoop? get gameLoop => _gameLoop;

  /// Countdown cancellation token.
  bool _countdownActive = false;

  /// Callback set by the host provider, forwarded to [ServerGameLoop] so the
  /// host can spectate its own server.
  void Function()? onTick;

  final Random _random = Random();

  ServerStateMachine({required this.state, required this.server});

  // ---------------------------------------------------------------------------
  // Inbound message handlers
  // ---------------------------------------------------------------------------

  /// Processes a [Join] message from [session].
  ///
  /// Validates the name, checks lobby capacity, enforces phase restrictions,
  /// generates a player id, and sends the appropriate `welcome` or `error`
  /// response.
  Future<void> handleJoin(ClientSession session, Join joinMsg) async {
    // 1. Validate name.
    final nameError = ProtocolValidator.validateName(joinMsg.name);
    if (nameError != null) {
      await session.send(ServerMessage.error(reason: nameError));
      return;
    }
    final name = joinMsg.name.trim();

    // 2. Check lobby capacity.
    if (ProtocolValidator.isLobbyFull(state.players.length)) {
      await session.send(
        ServerMessage.error(reason: ErrorReason.lobbyFull.wireValue),
      );
      session.close();
      return;
    }

    // 3. Check phase — only allow join during lobby.
    if (state.phase != GamePhase.lobby) {
      await session.send(
        ServerMessage.error(reason: ErrorReason.gameStarted.wireValue),
      );
      session.close();
      return;
    }

    // 4. Generate unique player id.
    final playerId =
        'p_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';

    // 5. Create player and add to state.
    final player = ServerPlayer(id: playerId, name: name, x: 500, y: 500);
    state.players[playerId] = player;

    // 6. Register session so the server can send to this player.
    server.registerSession(playerId, session);

    // 7. Send welcome to the client.
    await session.send(
      ServerMessage.welcome(
        playerId: playerId,
        config: const WelcomeConfig(
          mapSize: Constants.mapSize,
          circleRadius: Constants.circleRadius,
          playerRadius: Constants.playerRadius,
          interactRadius: Constants.interactRadius,
          speed: Constants.speed,
          tickRate: Constants.tickRate,
        ),
      ),
    );

    // 8. Broadcast updated lobby to all clients (includes the new player).
    server.broadcast(state.toLobbyMsg());
  }

  /// Processes an [Input] message (movement direction) from [playerId].
  ///
  /// Rejected if the game is not in [GamePhase.playing] or the direction
  /// values are invalid.
  void handleInput(String playerId, Input input) {
    if (state.phase != GamePhase.playing) {
      server.sendTo(
        playerId,
        ServerMessage.error(reason: ErrorReason.invalidPhase.wireValue),
      );
      return;
    }

    final player = state.players[playerId];
    if (player == null) {
      server.sendTo(
        playerId,
        ServerMessage.error(reason: ErrorReason.notJoined.wireValue),
      );
      return;
    }

    if (!ProtocolValidator.isValidDir(input.dir)) {
      server.sendTo(
        playerId,
        ServerMessage.error(reason: ErrorReason.invalidField.wireValue),
      );
      return;
    }

    player.currentDir = input.dir;
  }

  /// Queues an interact request from [playerId] for processing this tick.
  ///
  /// The actual capture / steal validation happens inside
  /// [ServerGameLoop._tick].
  void handleInteract(String playerId) {
    if (state.phase != GamePhase.playing) return;

    final player = state.players[playerId];
    if (player == null) return;

    state.interactionQueue.add(playerId);
  }

  // ---------------------------------------------------------------------------
  // Connection lifecycle
  // ---------------------------------------------------------------------------

  /// Handles a client disconnection.
  ///
  /// Removes the player, resets the flag if they were the carrier, aborts
  /// the countdown if below [Constants.minPlayers], and broadcasts the
  /// updated lobby / state.
  void handleDisconnect(String playerId) {
    final player = state.players.remove(playerId);
    if (player == null) return; // already removed

    server.removeSession(playerId);

    // If the disconnected player was the flag carrier, reset the flag.
    if (state.flag.owner == playerId) {
      state.flag = const Flag(owner: null, x: 500, y: 500);
    }

    switch (state.phase) {
      case GamePhase.lobby:
        server.broadcast(state.toLobbyMsg());
        _tryTriggerCountdown();

      case GamePhase.countdown:
        if (state.players.length < Constants.minPlayers) {
          abortCountdown();
        }
        server.broadcast(state.toLobbyMsg());

      case GamePhase.playing:
        // Check if everyone disconnected.
        if (state.players.isEmpty) {
          endGameImmediate(null);
        }
      // Otherwise the next state broadcast will naturally exclude the
      // removed player.

      case GamePhase.gameOver:
        // Player removed; the post‑game timer will broadcast the updated
        // lobby when it fires.
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Countdown
  // ---------------------------------------------------------------------------

  /// Starts the pre‑game countdown if conditions are met.
  ///
  /// Requires [GamePhase.lobby] and at least [Constants.minPlayers] players.
  /// Broadcasts `countdown(5)` through `countdown(1)` at 1‑second intervals,
  /// then calls [startGame].
  void triggerCountdown() {
    if (state.phase != GamePhase.lobby) return;
    if (state.players.length < Constants.minPlayers) return;

    _startCountdownSequence();
  }

  /// Internal helper that always starts the sequence (caller validates).
  void _tryTriggerCountdown() {
    if (state.phase != GamePhase.lobby) return;
    if (state.players.length < Constants.minPlayers) return;

    _startCountdownSequence();
  }

  void _startCountdownSequence() {
    state.phase = GamePhase.countdown;
    _countdownActive = true;

    _sendCountdownTick(5);
  }

  void _sendCountdownTick(int seconds) {
    if (!_countdownActive || state.phase != GamePhase.countdown) return;

    server.broadcast(ServerMessage.countdown(seconds: seconds));

    if (seconds > 1) {
      Future.delayed(const Duration(seconds: 1), () {
        _sendCountdownTick(seconds - 1);
      });
    } else {
      // Final tick — start the game after 1 more second.
      Future.delayed(const Duration(seconds: 1), () {
        if (!_countdownActive || state.phase != GamePhase.countdown) return;
        startGame();
      });
    }
  }

  /// Aborts an active countdown and returns to lobby.
  void abortCountdown() {
    if (state.phase != GamePhase.countdown) return;

    _countdownActive = false;
    state.phase = GamePhase.lobby;
    server.broadcast(state.toLobbyMsg());
  }

  // ---------------------------------------------------------------------------
  // Game start
  // ---------------------------------------------------------------------------

  /// Transitions from countdown to playing, assigns spawn positions, and
  /// starts the game loop.
  void startGame() {
    if (state.phase != GamePhase.countdown) return;

    _countdownActive = false;
    state.phase = GamePhase.playing;

    // Assign random spawn positions to every player.
    for (final player in state.players.values) {
      final pos = state.spawnPlayer();
      player.x = pos.x;
      player.y = pos.y;
      // Players spawn outside the circle, so wasInsideCircle starts false.
      player.wasInsideCircle = false;
    }

    // Reset flag.
    state.flag = const Flag(owner: null, x: 500, y: 500);

    server.broadcast(const ServerMessage.start());

    // Start the game loop.
    _gameLoop = ServerGameLoop(
      state: state,
      server: server,
      onVictory: endGame,
      onTick: onTick,
    );
    _gameLoop!.start();
  }

  // ---------------------------------------------------------------------------
  // Game over
  // ---------------------------------------------------------------------------

  /// Ends the current game with [winnerId] as the victor.
  ///
  /// Broadcasts `game_over`, waits [Constants.postGameSeconds], then resets
  /// for a new round.
  void endGame(String winnerId) {
    if (state.phase != GamePhase.playing) return;

    _gameLoop?.stop();
    _gameLoop = null;

    state.winnerId = winnerId;
    state.phase = GamePhase.gameOver;

    server.broadcast(ServerMessage.gameOver(winner: winnerId));

    // After the post‑game pause, return to lobby.
    Future.delayed(Duration(seconds: Constants.postGameSeconds), () {
      if (state.phase != GamePhase.gameOver) return;
      _returnToLobby();
    });
  }

  /// Ends the game immediately (e.g., all players disconnected) without
  /// broadcasting `game_over`.
  void endGameImmediate(String? winnerId) {
    _gameLoop?.stop();
    _gameLoop = null;

    state.winnerId = winnerId;
    _returnToLobby();
  }

  void _returnToLobby() {
    state.resetForNewRound();
    server.broadcast(state.toLobbyMsg());
    _tryTriggerCountdown();
  }
}
