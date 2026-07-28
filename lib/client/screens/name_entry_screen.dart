import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../core/constants.dart';
import '../../core/validation.dart';
import '../providers/app_mode_provider.dart';

class NameEntryScreen extends ConsumerStatefulWidget {
  const NameEntryScreen({super.key});

  @override
  ConsumerState<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends ConsumerState<NameEntryScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text;
    final error = ProtocolValidator.validateName(name);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    final mode = ref.read(appModeProvider);
    if (mode is NameEntry) {
      ref
          .read(appModeProvider.notifier)
          .joinServer(mode.ip, mode.port, playerName: name);
    }
  }

  void _onChanged(String value) {
    if (_error != null) {
      setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appModeProvider);
    final ip = mode is NameEntry ? mode.ip : '';
    final port = mode is NameEntry ? mode.port : 0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          const Text(
            'Enter Name',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            'Server: $ip:$port',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(
            width: 280,
            child: FTextField(
              control: FTextFieldControl.managed(
                controller: _controller,
                onChange: (_) => _onChanged(_controller.text),
              ),
              label: const Text('Display Name'),
              hint: 'Enter your display name',
              maxLength: Constants.nameMaxLength,
              error: _error != null ? Text(_error!) : null,
              autofocus: true,
              textInputAction: TextInputAction.go,
              onSubmit: (_) => _submit(),
            ),
          ),
          FButton(
            variant: .primary,
            onPress: _submit,
            child: const Text('Join'),
          ),
          FButton(
            variant: .secondary,
            onPress: () => ref.read(appModeProvider.notifier).selectJoin(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
