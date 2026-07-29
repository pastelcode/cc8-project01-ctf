import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_provider.dart';
import 'game_state_provider.dart';

/// The current app mode / screen.
sealed class AppMode {
  const AppMode();
}

class ModeSelect extends AppMode {
  const ModeSelect();
}

class HostSetup extends AppMode {
  const HostSetup();
}

class Hosting extends AppMode {
  final String serverName;
  const Hosting({required this.serverName});
}

class Discovering extends AppMode {
  const Discovering();
}

class Joining extends AppMode {
  final String ip;
  final int port;
  final String playerName;
  const Joining({
    required this.ip,
    required this.port,
    this.playerName = 'Player',
  });
}

class NameEntry extends AppMode {
  final String ip;
  final int port;
  const NameEntry({required this.ip, required this.port});
}

class InGame extends AppMode {
  final String playerId;
  final bool isSpectator;
  const InGame({required this.playerId, required this.isSpectator});
}

class AppModeNotifier extends Notifier<AppMode> {
  @override
  AppMode build() => const ModeSelect();

  void selectHost() => state = const HostSetup();
  void startHosting(String name) => state = Hosting(serverName: name);
  void selectJoin() => state = const Discovering();
  void showNameEntry(String ip, int port) =>
      state = NameEntry(ip: ip, port: port);
  void joinServer(String ip, int port, {String playerName = 'Player'}) =>
      state = Joining(ip: ip, port: port, playerName: playerName);
  void enterGame(String playerId, {bool isSpectator = false}) =>
      state = InGame(playerId: playerId, isSpectator: isSpectator);

  /// Returns to the lobby after a game round ends.
  ///
  /// If the current state is [InGame] and the player was hosting
  /// (isSpectator), go back to [Hosting]; for joiners go back to
  /// [Joining] so they stay in the lobby and can play another round.
  /// Falls back to [ModeSelect] if the connection was lost.
  void backToLobby() {
    switch (state) {
      case InGame(:final isSpectator):
        if (isSpectator) {
          state = const Hosting(serverName: '');
        } else {
          final conn = ref.read(connectionProvider);
          final ip = conn.client?.host;
          final port = conn.client?.port;
          if (ip != null && port != null && conn.isConnected) {
            final gameState = ref.read(gameStateProvider);
            state = Joining(
              ip: ip,
              port: port,
              playerName: _resolvePlayerName(gameState),
            );
          } else {
            // Connection lost — fall back to menu.
            state = const ModeSelect();
          }
        }
      case Hosting(:final serverName):
        state = Hosting(serverName: serverName);
      case _:
        state = const ModeSelect();
    }
  }

  /// Looks up the local player's name from the game state's lobby roster.
  String _resolvePlayerName(GameWorld gameState) {
    final id = gameState.playerId;
    if (id == null) return 'Player';
    for (final p in gameState.lobbyPlayers) {
      if (p.id == id) return p.name;
    }
    return 'Player';
  }

  void backToMenu() => state = const ModeSelect();
}

final appModeProvider = NotifierProvider<AppModeNotifier, AppMode>(
  AppModeNotifier.new,
);
