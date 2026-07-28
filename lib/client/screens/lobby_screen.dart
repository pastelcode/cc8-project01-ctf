import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../providers/app_mode_provider.dart';
import '../providers/connection_provider.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final String? ip;
  final int? port;
  final String? playerName;
  final bool isHost;
  final String? serverName;

  const LobbyScreen({
    super.key,
    this.ip,
    this.port,
    this.playerName,
    this.isHost = false,
    this.serverName,
  });

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final List<LobbyPlayer> _players = [];
  GamePhase _phase = GamePhase.lobby;
  int _countdownSeconds = Constants.countdownSeconds;
  String? _myPlayerId;
  StreamSubscription<ServerMessage>? _sub;

  bool get _isHost => widget.isHost;

  @override
  void initState() {
    super.initState();
    if (!_isHost) {
      _connectAsClient();
    }
  }

  Future<void> _connectAsClient() async {
    final ip = widget.ip!;
    final port = widget.port!;
    final name = widget.playerName ?? 'Player';

    final connNotifier = ref.read(connectionProvider.notifier);
    await connNotifier.connect(ip, port);

    // Subscribe before sending to avoid missing any server message.
    _sub = connNotifier.messages.listen(
      _handleMessage,
      onError: (Object error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Connection error: $error')));
        }
      },
    );

    connNotifier.send(ClientMessage.join(v: 1, name: name));
  }

  void _handleMessage(ServerMessage msg) {
    if (!mounted) return;

    setState(() {
      switch (msg) {
        case Welcome(:final playerId):
          _myPlayerId = playerId;
          ref.read(connectionProvider.notifier).setPlayerId(playerId);
        case Lobby(:final players):
          _players
            ..clear()
            ..addAll(players);
          _phase = GamePhase.lobby;
          _countdownSeconds = Constants.countdownSeconds;
        case Countdown(:final seconds):
          _phase = GamePhase.countdown;
          _countdownSeconds = seconds;
        case Start():
          _phase = GamePhase.playing;
          ref
              .read(appModeProvider.notifier)
              .enterGame(_myPlayerId ?? 'unknown', isSpectator: _isHost);
        case GameOver():
          _phase = GamePhase.gameOver;
        case ErrorMsg(:final reason):
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Server error: $reason')));
          }
        default:
          break; // State, etc. — ignored during lobby phase.
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    ref.read(connectionProvider.notifier).disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isHost ? (widget.serverName ?? 'Your Game') : 'Lobby';

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_isHost && _players.isEmpty) ...[
              const Spacer(),
              const Text(
                'Waiting for players to join...',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const Spacer(),
            ] else
              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (_, i) {
                    final player = _players[i];
                    final isMe = player.id == _myPlayerId;
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
          ],
        ),
        // Countdown overlay
        if (_phase == GamePhase.countdown)
          Center(
            child: Text(
              '$_countdownSeconds',
              style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
            ),
          ),
        // Start button (host only, in lobby phase, >= minPlayers)
        if (_isHost &&
            _phase == GamePhase.lobby &&
            _players.length >= Constants.minPlayers)
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

  void _startGame() {
    // Host triggers countdown — placeholder until server integration.
  }
}
