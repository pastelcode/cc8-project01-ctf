import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../network/tcp_server.dart';
import '../../server/server_game_loop.dart';
import '../../server/server_state.dart';
import '../../server/server_state_machine.dart';
import '../../shared/logger.dart';
import 'game_state_provider.dart';

/// Snapshot of the host's server, exposed to the UI so the host can
/// spectate its own game.
class HostServerState {
  final bool isRunning;
  final TcpServer? server;
  final ServerGameState? gameState;
  final ServerStateMachine? stateMachine;
  final ServerGameLoop? gameLoop;

  /// Monotonically increasing counter so that Riverpod detects state
  /// changes even when the underlying [gameState] reference is mutated
  /// in-place by the server engine.
  final int version;

  const HostServerState({
    this.isRunning = false,
    this.server,
    this.gameState,
    this.stateMachine,
    this.gameLoop,
    this.version = 0,
  });
}

/// Manages the full server lifecycle when the app is in host mode.
///
/// Responsibilities:
/// - Start / stop the [TcpServer].
/// - Create the [ServerGameState], [ServerStateMachine], and forward
///   inbound client messages to the state machine.
/// - Sync the server-side game world into the client-side [gameStateProvider]
///   so the host can render the game as a spectator.
/// - Respond to UDP [discover] broadcasts with [server_info] responses.
class ServerNotifier extends Notifier<HostServerState> {
  RawDatagramSocket? _discoverySocket;
  Timer? _syncTimer;
  String? _serverName;

  @override
  HostServerState build() => const HostServerState();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Starts the TCP server and all supporting services.
  ///
  /// Binds to an OS-assigned port, wires inbound [ClientMessage] routing,
  /// starts the UDP discovery responder, and begins a periodic sync timer
  /// that copies server-side state into the client-side [gameStateProvider].
  Future<void> start(String name) async {
    _serverName = name;

    // -- 1. TCP server --------------------------------------------------------
    final server = TcpServer();
    await server.start();

    // -- 2. Game state & state machine ----------------------------------------
    final gameState = ServerGameState();
    final stateMachine = ServerStateMachine(state: gameState, server: server);

    // When the state machine creates the game loop (inside startGame), forward
    // its onTick so the host spectates at full 20 Hz during gameplay.
    stateMachine.onTick = () {
      _tickSync();
    };

    // -- 3. Route inbound client messages -> state machine --------------------
    server.onJoin.listen((session) {
      session.messages.listen(
        (msg) async {
          switch (msg) {
            case Join():
              await stateMachine.handleJoin(session, msg);
              _notifyStateChanged();
            case Input():
              stateMachine.handleInput(session.playerId ?? '', msg);
            case Interact():
              stateMachine.handleInteract(session.playerId ?? '');
          }
        },
        onDone: () {
          if (session.playerId != null) {
            stateMachine.handleDisconnect(session.playerId!);
            _notifyStateChanged();
          }
        },
        onError: (Object e, StackTrace s) {
          appLogger.e('Server session error', error: e, stackTrace: s);
          if (session.playerId != null) {
            stateMachine.handleDisconnect(session.playerId!);
            _notifyStateChanged();
          }
        },
      );
    });

    // -- 4. UDP discovery responder -------------------------------------------
    _startDiscoveryResponder(server.port);

    // -- 5. Periodic sync so the host sees lobby / countdown / game-over ------
    //      (the 20 Hz onTick covers the playing phase).
    _syncTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _periodicSync();
    });

    state = HostServerState(
      isRunning: true,
      server: server,
      gameState: gameState,
      stateMachine: stateMachine,
    );
  }

  /// Triggers the pre-game countdown (host taps "Start Game").
  void startCountdown() {
    state.stateMachine?.triggerCountdown();
    _notifyStateChanged();
  }

  /// Stops the server, game loop, discovery responder, and sync timer.
  Future<void> stop() async {
    _syncTimer?.cancel();
    _syncTimer = null;

    _discoverySocket?.close();
    _discoverySocket = null;

    await state.server?.stop();
    state = const HostServerState();
  }

  // ---------------------------------------------------------------------------
  // State helpers
  // ---------------------------------------------------------------------------

  /// Bump the [version] counter so that [serverProvider] watchers rebuild
  /// after in-place mutations of [ServerGameState].
  void _notifyStateChanged() {
    state = HostServerState(
      isRunning: state.isRunning,
      server: state.server,
      gameState: state.gameState,
      stateMachine: state.stateMachine,
      gameLoop: state.gameLoop,
      version: state.version + 1,
    );
  }

  // ---------------------------------------------------------------------------
  // State synchronisation (server → client gameStateProvider)
  // ---------------------------------------------------------------------------

  /// Called from the 20 Hz game loop — pushes a [StateMsg] into the client
  /// provider so the host spectates at full tick rate.
  void _tickSync() {
    final gs = state.gameState;
    if (gs == null || gs.phase != GamePhase.playing) return;

    // The host doesn't receive the Start broadcast via TCP, so fix the phase
    // on the first tick if the client-side provider is still stuck in
    // countdown.
    final hostState = ref.read(gameStateProvider);
    if (hostState.phase == GamePhase.countdown) {
      ref
          .read(gameStateProvider.notifier)
          .handleMessage(const ServerMessage.start());
    }

    ref.read(gameStateProvider.notifier).handleMessage(gs.toStateMsg());

    // Also refresh the gameLoop reference in HostServerState if it changed.
    final gl = state.stateMachine?.gameLoop;
    if (gl != null && state.gameLoop != gl) {
      state = HostServerState(
        isRunning: state.isRunning,
        server: state.server,
        gameState: state.gameState,
        stateMachine: state.stateMachine,
        gameLoop: gl,
      );
    }
  }

  /// Periodic fallback sync for non-playing phases (lobby, countdown,
  /// game-over). Runs at 10 Hz so the host UI stays responsive even when
  /// the game loop isn't running.
  void _periodicSync() {
    final gs = state.gameState;
    if (gs == null) return;

    switch (gs.phase) {
      case GamePhase.lobby:
        ref.read(gameStateProvider.notifier).handleMessage(gs.toLobbyMsg());
      case GamePhase.gameOver:
        if (gs.winnerId != null) {
          ref
              .read(gameStateProvider.notifier)
              .handleMessage(ServerMessage.gameOver(winner: gs.winnerId!));
        }
      case GamePhase.countdown:
        ref
            .read(gameStateProvider.notifier)
            .handleMessage(
              ServerMessage.countdown(seconds: gs.countdownSeconds),
            );
      case GamePhase.playing:
        // Covered by onTick at 20 Hz — no additional work needed here.
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // UDP discovery responder
  // ---------------------------------------------------------------------------

  Future<void> _startDiscoveryResponder(int tcpPort) async {
    try {
      _discoverySocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        Constants.discoveryPort,
        reuseAddress: true,
        reusePort: Platform.isMacOS || Platform.isLinux,
      );

      _discoverySocket!.listen(
        (RawSocketEvent event) {
          if (event != RawSocketEvent.read) return;
          _drainDiscoveryDatagrams(tcpPort);
        },
        onError: (Object e, StackTrace s) {
          appLogger.e('UDP discovery error', error: e, stackTrace: s);
        },
        cancelOnError: false,
      );
    } catch (_) {
      // Discovery responder is optional for MVP.
    }
  }

  void _drainDiscoveryDatagrams(int tcpPort) {
    for (
      Datagram? d = _discoverySocket!.receive();
      d != null;
      d = _discoverySocket!.receive()
    ) {
      final datagram = d;
      try {
        final text = utf8.decode(datagram.data);
        final json = jsonDecode(text) as Map<String, dynamic>;
        if (json['type'] != 'discover') continue;
        if (json['v'] != 1) continue;

        // Build a SPEC-compliant server_info response.
        final gs = state.gameState;
        final playerCount = gs?.players.length ?? 0;
        final serverStateStr = (gs?.phase == GamePhase.lobby)
            ? 'lobby'
            : 'playing';

        final response = jsonEncode({
          'type': 'server_info',
          'v': 1,
          'name': _serverName ?? 'CTF Server',
          'tcp_port': tcpPort,
          'state': serverStateStr,
          'players': playerCount,
        });

        _discoverySocket?.send(
          utf8.encode(response),
          datagram.address,
          datagram.port,
        );
      } catch (_) {
        // Silently discard malformed datagrams per SPEC §1.3.
      }
    }
  }
}

/// The top-level provider for the host's server.
///
/// UI code reads [HostServerState.isRunning] to guard server-only controls
/// and reads [HostServerState.server.port] to display connection info.
final serverProvider = NotifierProvider<ServerNotifier, HostServerState>(
  ServerNotifier.new,
);
