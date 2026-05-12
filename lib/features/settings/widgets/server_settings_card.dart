import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/utils/network_utils.dart';
import 'settings_widgets.dart';

class ServerSettingsCard extends ConsumerWidget {
  const ServerSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(printerConfigProvider).valueOrNull;
    final isRunning = ref.watch(serverLifecycleProvider);
    final alwaysOnMode = ref.watch(alwaysOnModeProvider).valueOrNull ?? false;

    if (config == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsCard(
          label: 'INTERNAL HTTP SERVER',
          children: [
            SettingsRow(
              label: 'Port',
              value: config.serverPort.toString(),
              onTap: alwaysOnMode
                  ? () => _showAlwaysOnLocked(context)
                  : () => _showPortDialog(context, ref, config.serverPort),
            ),
            ToggleRow(
              label: 'Start with app',
              value: config.autoStartServer,
              onChanged: alwaysOnMode
                  ? null
                  : (value) async {
                      await ref
                          .read(printerConfigProvider.notifier)
                          .save(config.copyWith(autoStartServer: value));
                    },
            ),
            ToggleRow(
              label: 'Server active',
              value: alwaysOnMode || isRunning,
              onChanged: alwaysOnMode
                  ? null
                  : (value) async {
                      final notifier = ref.read(
                        serverLifecycleProvider.notifier,
                      );
                      if (value) {
                        await notifier.start(config.serverPort);
                      } else {
                        await notifier.stop();
                      }
                    },
            ),
            ToggleRow(
              label: 'Always-on mode',
              value: alwaysOnMode,
              onChanged: (value) async {
                final notifier = ref.read(alwaysOnModeProvider.notifier);
                if (value) {
                  await notifier.enable();
                } else {
                  await notifier.disable();
                }
              },
            ),
            ActionRow(
              label: 'Restart server',
              icon: Icons.refresh,
              color: const Color(0xFFA32D2D),
              onTap: () async {
                if (alwaysOnMode) {
                  await ref.read(foregroundServiceProvider).restart();
                } else {
                  await ref
                      .read(serverLifecycleProvider.notifier)
                      .restart(config.serverPort);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Server restarted.')),
                  );
                }
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 12, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  alwaysOnMode
                      ? 'Always-on mode keeps the server running even when '
                            'the app is closed or the device restarts.'
                      : 'When always-on is disabled, the server only runs '
                            'while the app is open.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showPortDialog(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final controller = TextEditingController(text: current.toString());
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Server port'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '8080'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final port = int.tryParse(result);
    if (port == null || !NetworkUtils.isValidPort(port)) return;
    final config = ref.read(printerConfigProvider).valueOrNull;
    if (config == null) return;
    await ref
        .read(printerConfigProvider.notifier)
        .save(config.copyWith(serverPort: port));
  }

  void _showAlwaysOnLocked(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Disable always-on mode first to change the port.'),
      ),
    );
  }
}
