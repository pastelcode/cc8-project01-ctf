import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'providers/app_mode_provider.dart';
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
