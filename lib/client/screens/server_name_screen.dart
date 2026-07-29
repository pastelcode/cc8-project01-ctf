import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import '../providers/app_mode_provider.dart';
import '../providers/server_provider.dart';
import '../widgets/error_toast.dart';
import '../../core/constants.dart';

class ServerNameScreen extends ConsumerStatefulWidget {
  const ServerNameScreen({super.key});

  @override
  ConsumerState<ServerNameScreen> createState() => _ServerNameScreenState();
}

class _ServerNameScreenState extends ConsumerState<ServerNameScreen> {
  final _controller = TextEditingController();

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    try {
      await ref.read(serverProvider.notifier).start(name);
      ref.read(appModeProvider.notifier).startHosting(name);
    } on SocketException catch (e, s) {
      if (mounted) {
        showErrorToast(context, 'Could not start server: ${e.message}', s);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const Text(
              'Host Game',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 280,
              child: FTextField(
                control: FTextFieldControl.managed(controller: _controller),
                label: const Text('Server Name'),
                hint: 'My Server',
                maxLength: Constants.nameMaxLength,
                autofocus: true,
                textInputAction: TextInputAction.go,
                onSubmit: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 8),
            FButton(
              variant: FButtonVariant.primary,
              onPress: _submit,
              child: const Text('Start Server'),
            ),
            const SizedBox(height: 8),
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => ref.read(appModeProvider.notifier).backToMenu(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
