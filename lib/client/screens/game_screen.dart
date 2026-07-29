import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/messages.dart';
import '../providers/game_state_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/app_mode_provider.dart';
import '../painters/game_painter.dart';
import '../input/virtual_joystick.dart';
import '../input/interact_button.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  StreamSubscription<ServerMessage>? _msgSub;
  final _keysHeld = <LogicalKeyboardKey>{};

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    final conn = ref.read(connectionProvider.notifier);
    _msgSub = conn.messages.listen((msg) {
      ref.read(gameStateProvider.notifier).handleMessage(msg);
    });
  }

  void _onDirectionChanged(Dir dir) {
    ref.read(connectionProvider.notifier).send(ClientMessage.input(dir: dir));
  }

  void _onInteract() {
    ref.read(connectionProvider.notifier).send(const ClientMessage.interact());
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _keysHeld.add(event.logicalKey);
      _updateDirectionFromKeys();
      if (event.logicalKey == LogicalKeyboardKey.keyE ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _onInteract();
      }
      return KeyEventResult.handled;
    } else if (event is KeyUpEvent) {
      _keysHeld.remove(event.logicalKey);
      _updateDirectionFromKeys();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _updateDirectionFromKeys() {
    int dx = 0;
    int dy = 0;

    if (_keysHeld.contains(LogicalKeyboardKey.keyA) ||
        _keysHeld.contains(LogicalKeyboardKey.arrowLeft)) {
      dx = -1;
    }
    if (_keysHeld.contains(LogicalKeyboardKey.keyD) ||
        _keysHeld.contains(LogicalKeyboardKey.arrowRight)) {
      dx = 1;
    }
    if (_keysHeld.contains(LogicalKeyboardKey.keyW) ||
        _keysHeld.contains(LogicalKeyboardKey.arrowUp)) {
      dy = -1;
    }
    if (_keysHeld.contains(LogicalKeyboardKey.keyS) ||
        _keysHeld.contains(LogicalKeyboardKey.arrowDown)) {
      dy = 1;
    }

    _onDirectionChanged(Dir(x: dx, y: dy));
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }

  Color _countdownColor(int seconds) => switch (seconds) {
    5 => Colors.white,
    4 => const Color(0xFFFFEB3B), // yellow
    3 => const Color(0xFFFF9800), // orange
    2 => const Color(0xFFF44336), // red
    1 => const Color(0xFFFF1744), // bright red
    _ => Colors.white,
  };

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final appMode = ref.watch(appModeProvider);
    final isSpectator = appMode is InGame && appMode.isSpectator;
    final phase = gameState.phase;

    // Build a playerId → name map from lobby data.
    final playerNames = <String, String>{};
    for (final lp in gameState.lobbyPlayers) {
      playerNames[lp.id] = lp.name;
    }

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Stack(
        children: [
          // Game canvas — shown during playing and game over phases
          if (phase == GamePhase.playing || phase == GamePhase.gameOver)
            Positioned.fill(
              child: CustomPaint(
                painter: GamePainter(
                  state: gameState,
                  localPlayerId: gameState.playerId,
                  playerNames: playerNames,
                ),
              ),
            ),

          // Player controls (only if not spectator, only in playing phase)
          if (!isSpectator && phase == GamePhase.playing) ...[
            // Joystick — bottom-left
            Positioned(
              left: 24,
              bottom: 24,
              child: VirtualJoystick(onDirectionChanged: _onDirectionChanged),
            ),
            // Interact button — bottom-right
            Positioned(
              right: 24,
              bottom: 24,
              child: InteractButton(onPressed: _onInteract),
            ),
          ],

          // Countdown overlay — animated scale+fade with color ramp
          if (phase == GamePhase.countdown)
            Center(
              child: TweenAnimationBuilder<double>(
                key: ValueKey(gameState.countdownSeconds),
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: scale.clamp(0.0, 1.0),
                      child: Text(
                        '${gameState.countdownSeconds}',
                        style: TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.bold,
                          color: _countdownColor(gameState.countdownSeconds),
                          shadows: [
                            Shadow(
                              color: _countdownColor(
                                gameState.countdownSeconds,
                              ).withValues(alpha: 0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Game over overlay
          if (phase == GamePhase.gameOver)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Winner: ${gameState.winnerId ?? "Unknown"}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF00FF88),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Returning to lobby...',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
