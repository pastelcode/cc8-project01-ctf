import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import '../core/messages.dart';
import 'providers/app_mode_provider.dart';
import 'providers/game_state_provider.dart';
import 'screens/discovery_screen.dart';
import 'screens/game_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/mode_select_screen.dart';
import 'screens/name_entry_screen.dart';
import 'screens/server_name_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    // When a game ends, the server broadcasts a Lobby message and the client's
    // gameStateProvider resets to phase=lobby. Transition back to the menu.
    ref.listen<GameWorld>(gameStateProvider, (prev, next) {
      if (next.phase == GamePhase.lobby) {
        final currentMode = ref.read(appModeProvider);
        if (currentMode is InGame) {
          ref.read(appModeProvider.notifier).backToMenu();
        }
      }
    });

    return FScaffold(
      child: switch (mode) {
        ModeSelect() => const ModeSelectScreen(),
        HostSetup() => const ServerNameScreen(),
        Hosting(:final serverName) => LobbyScreen(
          isHost: true,
          serverName: serverName,
        ),
        Discovering() => const DiscoveryScreen(),
        NameEntry() => const NameEntryScreen(),
        Joining(:final ip, :final port, :final playerName) => LobbyScreen(
          ip: ip,
          port: port,
          playerName: playerName,
        ),
        InGame() => const GameScreen(),
      },
    );
  }
}
