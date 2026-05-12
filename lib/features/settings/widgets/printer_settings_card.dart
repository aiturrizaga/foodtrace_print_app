import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/network_utils.dart';

import 'settings_widgets.dart';

class PrinterSettingsCard extends ConsumerWidget {
  const PrinterSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(printerConfigProvider).valueOrNull;
    if (config == null) return const SizedBox.shrink();

    return SettingsCard(
      label: 'PRINTER',
      children: [
        SettingsRow(
          label: 'Model',
          value: config.printerModel,
          onTap: () => _showModelPicker(context, ref, config.printerModel),
        ),
        SettingsRow(
          label: 'Printer IP',
          value: config.printerIp,
          onTap: () => _showIpDialog(context, ref, config.printerIp),
        ),
        ActionRow(
          label: 'Test connection',
          icon: Icons.wifi,
          color: const Color(0xFF185FA5),
          onTap: () => _testConnection(context, ref),
        ),
      ],
    );
  }

  Future<void> _showModelPicker(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _ModelPickerSheet(current: current),
    );
    if (selected == null) return;
    final config = ref.read(printerConfigProvider).valueOrNull;
    if (config == null) return;
    await ref
        .read(printerConfigProvider.notifier)
        .save(config.copyWith(printerModel: selected));
  }

  Future<void> _showIpDialog(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Printer IP address'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '192.168.1.32'),
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
    if (result == null || !NetworkUtils.isValidIp(result)) return;
    final config = ref.read(printerConfigProvider).valueOrNull;
    if (config == null) return;
    await ref
        .read(printerConfigProvider.notifier)
        .save(config.copyWith(printerIp: result));
  }

  Future<void> _testConnection(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Testing connection...')),
    );
    await ref.read(printerStatusProvider.notifier).refresh();
    final connected = ref.read(printerStatusProvider).valueOrNull ?? false;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          connected ? 'Printer is reachable.' : 'Printer not found.',
        ),
      ),
    );
  }
}

class _ModelPickerSheet extends StatelessWidget {
  const _ModelPickerSheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppConstants.supportedPrinterModels.map((model) {
          return ListTile(
            title: Text(model),
            trailing: model == current
                ? const Icon(Icons.check, color: Color(0xFF185FA5))
                : null,
            onTap: () => Navigator.pop(context, model),
          );
        }).toList(),
      ),
    );
  }
}
