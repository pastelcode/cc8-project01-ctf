import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void backToLobby() {
    state = switch (state) {
      Hosting() || InGame() =>
        state is Hosting
            ? Hosting(serverName: (state as Hosting).serverName)
            : const Discovering(),
      _ => const ModeSelect(),
    };
  }

  void backToMenu() => state = const ModeSelect();
}

final appModeProvider = NotifierProvider<AppModeNotifier, AppMode>(
  AppModeNotifier.new,
);
