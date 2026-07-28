import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../core/messages.dart';
import '../../network/udp_discovery.dart';
import '../providers/app_mode_provider.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final List<({String ip, ServerInfo info})> _servers = [];
  StreamSubscription<({InternetAddress source, ServerInfo info})>? _listener;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    setState(() => _scanning = true);

    await UdpDiscovery.sendDiscover();
    _listener?.cancel();
    _listener = UdpDiscovery.listenWithSource().listen((record) {
      final ip = record.source.address;
      final info = record.info;
      setState(() {
        final idx = _servers.indexWhere(
          (s) => s.info.name == info.name && s.info.tcpPort == info.tcpPort,
        );
        if (idx >= 0) {
          _servers[idx] = (ip: ip, info: info);
        } else {
          _servers.add((ip: ip, info: info));
        }
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _scanning = false);
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Manual connect
  // ---------------------------------------------------------------------------

  void _showManualConnect() {
    final ipController = TextEditingController();
    final portController = TextEditingController(text: '8889');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Center(
          child: Container(
            width: 320,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manual Connect',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                FTextField(
                  control: FTextFieldControl.managed(controller: ipController),
                  label: const Text('Server IP'),
                  hint: '192.168.1.100',
                ),
                const SizedBox(height: 12),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: portController,
                  ),
                  label: const Text('TCP Port'),
                  hint: '8889',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    FButton(
                      variant: FButtonVariant.ghost,
                      onPress: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    FButton(
                      variant: FButtonVariant.primary,
                      onPress: () {
                        final ip = ipController.text.trim();
                        final portStr = portController.text.trim();
                        if (ip.isEmpty || portStr.isEmpty) return;
                        final port = int.tryParse(portStr);
                        if (port == null || port < 1 || port > 65535) return;

                        Navigator.of(ctx).pop();
                        ref
                            .read(appModeProvider.notifier)
                            .showNameEntry(ip, port);
                      },
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => ref.read(appModeProvider.notifier).backToMenu(),
                child: const Text('← Back'),
              ),
              const Spacer(),
              const Text(
                'Join Game',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              FButton(
                variant: FButtonVariant.ghost,
                onPress: _scanning ? null : _startScanning,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
        // Scanning indicator
        if (_scanning)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(height: 3, child: LinearProgressIndicator()),
          ),
        // Content
        Expanded(
          child: _servers.isEmpty && !_scanning
              ? const Center(
                  child: Text(
                    'No servers found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _servers.length,
                  itemBuilder: (context, index) {
                    final entry = _servers[index];
                    final info = entry.info;
                    final inGame = info.state == ServerState.playing;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: inGame
                            ? null
                            : () => ref
                                  .read(appModeProvider.notifier)
                                  .showNameEntry(entry.ip, info.tcpPort),
                        child: FCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        info.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: inGame
                                              ? Colors.white38
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Players: ${info.players}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: inGame
                                              ? Colors.white38
                                              : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: inGame
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    inGame ? 'In Game' : 'Lobby',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: inGame
                                          ? Colors.white38
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Manual connect button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SizedBox(
            width: double.infinity,
            child: FButton(
              variant: FButtonVariant.secondary,
              onPress: _showManualConnect,
              child: const Text('Manual Connect'),
            ),
          ),
        ),
      ],
    );
  }
}
