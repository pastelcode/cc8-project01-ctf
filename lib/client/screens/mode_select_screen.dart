import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import '../providers/app_mode_provider.dart';

class ModeSelectScreen extends ConsumerWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            'Capture The Flag',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          FButton(
            variant: .primary,
            onPress: () => ref.read(appModeProvider.notifier).selectHost(),
            child: const Text('Host Game'),
          ),
          FButton(
            variant: .secondary,
            onPress: () => ref.read(appModeProvider.notifier).selectJoin(),
            child: const Text('Join Game'),
          ),
        ],
      ),
    );
  }
}
