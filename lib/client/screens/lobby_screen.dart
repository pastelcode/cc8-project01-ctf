import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../providers/app_mode_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/game_state_provider.dart';
import '../providers/server_provider.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final bool isHost;
  final String serverName;
  final String? ip;
  final int? port;
  final String? playerName;

  const LobbyScreen({
    super.key,
    this.isHost = false,
    this.serverName = '',
    this.ip,
    this.port,
    this.playerName,
  });

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  StreamSubscription<ServerMessage>? _msgSub;
  bool _hostConnected = false;
  bool _transitioning = false;

  bool get _isHost => widget.isHost;

  @override
  void initState() {
    super.initState();
    if (!_isHost) {
      _connectAsJoiner();
    }
  }

  // ---------------------------------------------------------------------------
  // Connection
  // ---------------------------------------------------------------------------

  Future<void> _connectAsJoiner() async {
    final connNotifier = ref.read(connectionProvider.notifier);
    try {
      await connNotifier.connect(widget.ip!, widget.port!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection failed: $e')));
        ref.read(appModeProvider.notifier).backToMenu();
      }
      return;
    }

    // Subscribe to server messages → game state provider.
    _msgSub = connNotifier.messages.listen(
      (msg) {
        ref.read(gameStateProvider.notifier).handleMessage(msg);
      },
      onError: (Object error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Connection error: $error')));
        }
      },
    );

    // Small delay so the subscription is active before the server responds.
    await Future.delayed(const Duration(milliseconds: 100));
    connNotifier.send(
      ClientMessage.join(v: 1, name: widget.playerName ?? 'Player'),
    );
  }

  Future<void> _connectAsHost(int port) async {
    final connNotifier = ref.read(connectionProvider.notifier);
    try {
      await connNotifier.connect('localhost', port);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to own server: $e')),
        );
      }
      return;
    }

    // Subscribe to server messages → game state provider.
    _msgSub = connNotifier.messages.listen((msg) {
      ref.read(gameStateProvider.notifier).handleMessage(msg);
    });

    await Future.delayed(const Duration(milliseconds: 100));
    connNotifier.send(ClientMessage.join(v: 1, name: 'Host'));
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _startGame() {
    ref.read(serverProvider.notifier).startCountdown();
  }

  void _maybeTransitionToGame(GameWorld gameState) {
    if (_transitioning) return;
    if (gameState.phase != GamePhase.playing) return;

    _transitioning = true;
    final playerId = gameState.playerId ?? (_isHost ? 'host' : 'unknown');

    // Defer so we don't mutate providers during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(appModeProvider.notifier)
          .enterGame(playerId, isSpectator: _isHost);
    });
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _msgSub?.cancel();
    // Only disconnect if the user is navigating away (not transitioning to
    // the game screen, which needs the connection to stay alive).
    if (!_transitioning) {
      ref.read(connectionProvider.notifier).disconnect();
      if (_isHost) {
        ref.read(serverProvider.notifier).stop();
      }
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final serverHostState = _isHost ? ref.watch(serverProvider) : null;

    // Auto-connect the host client when the server is ready.
    if (_isHost &&
        !_hostConnected &&
        serverHostState != null &&
        serverHostState.isRunning) {
      _hostConnected = true;
      final port = serverHostState.server?.port;
      if (port != null && port > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _connectAsHost(port);
        });
      }
    }

    // Transition to game screen when phase changes to playing.
    _maybeTransitionToGame(gameState);

    // Player list: server state for host, game state for joiner.
    final players = _isHost
        ? (serverHostState?.gameState?.lobbyPlayers ?? const [])
        : gameState.lobbyPlayers;

    final phase = gameState.phase;
    final title = _isHost ? widget.serverName : 'Lobby';

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title.isNotEmpty ? title : 'Lobby',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Show connection info for the joiner.
            if (!_isHost && widget.ip != null && widget.port != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Players on this server',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
            if (_isHost && players.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Waiting for players to join...',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (_, i) {
                    final player = players[i];
                    final isMe = player.id == gameState.playerId;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(player.name),
                      trailing: isMe
                          ? const Text(
                              '(You)',
                              style: TextStyle(color: Colors.grey),
                            )
                          : null,
                    );
                  },
                ),
              ),

            // Host connection status (show port info).
            if (_isHost && serverHostState != null && serverHostState.isRunning)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Port: ${serverHostState.server?.port ?? '—'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
          ],
        ),

        // Countdown overlay.
        if (phase == GamePhase.countdown)
          Center(
            child: Text(
              '${gameState.countdownSeconds}',
              style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
            ),
          ),

        // Start button (host only, lobby phase, >= minPlayers).
        if (_isHost &&
            phase == GamePhase.lobby &&
            players.length >= Constants.minPlayers)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: FButton(
                onPress: _startGame,
                child: const Text('Start Game'),
              ),
            ),
          ),
      ],
    );
  }
}
