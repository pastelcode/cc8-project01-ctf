import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/messages.dart';

/// The client-side game world state, updated by server messages.
class GameWorld {
  final GamePhase phase;
  final List<LobbyPlayer> lobbyPlayers;
  final int countdownSeconds;
  final Flag? flag;
  final List<GamePlayer> gamePlayers;
  final String? playerId;
  final String? winnerId;

  const GameWorld({
    this.phase = GamePhase.lobby,
    this.lobbyPlayers = const [],
    this.countdownSeconds = 5,
    this.flag,
    this.gamePlayers = const [],
    this.playerId,
    this.winnerId,
  });

  GameWorld copyWith({
    GamePhase? phase,
    List<LobbyPlayer>? lobbyPlayers,
    int? countdownSeconds,
    Flag? flag,
    List<GamePlayer>? gamePlayers,
    String? playerId,
    String? winnerId,
  }) {
    return GameWorld(
      phase: phase ?? this.phase,
      lobbyPlayers: lobbyPlayers ?? this.lobbyPlayers,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      flag: flag ?? this.flag,
      gamePlayers: gamePlayers ?? this.gamePlayers,
      playerId: playerId ?? this.playerId,
      winnerId: winnerId ?? this.winnerId,
    );
  }
}

class GameStateNotifier extends Notifier<GameWorld> {
  @override
  GameWorld build() => const GameWorld();

  /// Process any [ServerMessage] and update state accordingly.
  void handleMessage(ServerMessage msg) {
    switch (msg) {
      case Welcome(:final playerId):
        state = state.copyWith(playerId: playerId);
      case Lobby(:final players):
        state = GameWorld(
          phase: GamePhase.lobby,
          lobbyPlayers: players,
          countdownSeconds: 5,
          playerId: state.playerId,
        );
      case Countdown(:final seconds):
        state = state.copyWith(
          phase: GamePhase.countdown,
          countdownSeconds: seconds,
        );
      case Start():
        state = state.copyWith(phase: GamePhase.playing);
      case StateMsg(:final flag, :final players):
        state = state.copyWith(flag: flag, gamePlayers: players);
      case GameOver(:final winner):
        state = state.copyWith(phase: GamePhase.gameOver, winnerId: winner);
      case ErrorMsg():
        // Don't change state on errors.
        break;
    }
  }

  /// Find the local player in the game players list.
  GamePlayer? get localPlayer {
    final id = state.playerId;
    if (id == null) return null;
    for (final p in state.gamePlayers) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Whether the local player is the flag carrier.
  bool get isCarrier => state.flag?.owner == state.playerId;
}

final gameStateProvider = NotifierProvider<GameStateNotifier, GameWorld>(
  GameStateNotifier.new,
);
