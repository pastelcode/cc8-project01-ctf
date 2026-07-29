import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../providers/app_mode_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/game_state_provider.dart';
import '../providers/server_provider.dart';
import '../widgets/error_toast.dart';

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
  bool _transitioning = false;

  // Saved for safe use in dispose() per Riverpod guidelines.
  late final _connectionNotifier = ref.read(connectionProvider.notifier);
  late final _serverNotifier = ref.read(serverProvider.notifier);
  late final _appModeNotifier = ref.read(appModeProvider.notifier);
  late final _gameStateNotifier = ref.read(gameStateProvider.notifier);

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
    final connNotifier = _connectionNotifier;

    // Already connected by name entry screen.
    if (ref.read(connectionProvider).isConnected) {
      _msgSub = connNotifier.messages.listen((msg) {
        _gameStateNotifier.handleMessage(msg);
        if (msg is ErrorMsg && mounted) {
          showErrorToast(context, msg.reason);
        }
      });
      connNotifier.send(
        ClientMessage.join(v: 1, name: widget.playerName ?? 'Player'),
      );
      return;
    }

    _msgSub = connNotifier.messages.listen(
      (msg) {
        _gameStateNotifier.handleMessage(msg);
        if (msg is ErrorMsg && mounted) {
          showErrorToast(context, msg.reason);
        }
      },
      onError: (Object error, StackTrace s) {
        if (mounted) {
          showErrorToast(context, 'Connection error: $error', s);
        }
      },
    );

    await Future.delayed(const Duration(milliseconds: 100));
    connNotifier.send(
      ClientMessage.join(v: 1, name: widget.playerName ?? 'Player'),
    );
  }

  void _startGame() {
    _serverNotifier.startCountdown();
  }

  void _maybeTransitionToGame(GameWorld gameState) {
    if (_transitioning) return;
    if (gameState.phase != GamePhase.playing) return;

    _transitioning = true;
    final playerId = gameState.playerId ?? (_isHost ? 'host' : 'unknown');

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
    if (!_transitioning) {
      _connectionNotifier.disconnect();
      if (_isHost) {
        _serverNotifier.stop();
      }
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  late final Future<String> _localIpFuture = _resolveLocalIp();

  Future<String> _resolveLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      // Prefer en0 (Wi-Fi) or en1 on macOS.
      for (final name in ['en0', 'en1', 'wlan0', 'eth0']) {
        for (final interface in interfaces) {
          if (interface.name == name) {
            for (final addr in interface.addresses) {
              if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
                return addr.address;
              }
            }
          }
        }
      }
      // Fallback: first non-loopback IPv4.
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return '?.?.?.?';
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final serverHostState = _isHost ? ref.watch(serverProvider) : null;

    _maybeTransitionToGame(gameState);

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
              child: Row(
                children: [
                  if (_isHost && players.isEmpty)
                    FButton(
                      variant: FButtonVariant.ghost,
                      onPress: () {
                        _serverNotifier.stop();
                        _appModeNotifier.backToMenu();
                      },
                      child: const Text('← Back'),
                    ),
                  const Spacer(),
                  Text(
                    title.isNotEmpty ? title : 'Lobby',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            if (_isHost && serverHostState != null && serverHostState.isRunning)
              FutureBuilder<String>(
                future: _localIpFuture,
                builder: (context, snapshot) {
                  final ip = snapshot.data ?? '?.?.?.?';
                  final port = serverHostState.server?.port ?? '—';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Connect to: $ip:$port',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white38,
                      ),
                    ),
                  );
                },
              ),
            if (_isHost && players.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Waiting for players to join...',
                    style: TextStyle(fontSize: 18, color: Colors.white54),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            FLucideIcons.user,
                            size: 20,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isMe)
                            const Text(
                              '(You)',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),

        // Countdown overlay
        if (phase == GamePhase.countdown)
          Center(
            child: Text(
              '${gameState.countdownSeconds}',
              style: const TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

        // Start button (host only)
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
