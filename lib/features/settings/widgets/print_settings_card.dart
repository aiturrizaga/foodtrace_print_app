import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../config/models/printer_media.dart';

import 'settings_widgets.dart';

class PrintSettingsCard extends ConsumerWidget {
  const PrintSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(printerConfigProvider).valueOrNull;
    if (config == null) return const SizedBox.shrink();

    return SettingsCard(
      label: 'PRINT',
      children: [
        SettingsRow(
          label: 'Media',
          value: config.media.displayValue,
          onTap: () => _showMediaPicker(context, ref, config.media),
        ),
        ToggleRow(
          label: 'Auto cut',
          value: config.autoCut,
          onChanged: (value) async {
            await ref
                .read(printerConfigProvider.notifier)
                .save(config.copyWith(autoCut: value));
          },
        ),
      ],
    );
  }

  Future<void> _showMediaPicker(
    BuildContext context,
    WidgetRef ref,
    PrinterMedia current,
  ) async {
    final selected = await showModalBottomSheet<PrinterMedia>(
      context: context,
      builder: (_) => _MediaPickerSheet(current: current),
    );
    if (selected == null) return;

    final config = ref.read(printerConfigProvider).valueOrNull;
    if (config == null) return;

    await ref
        .read(printerConfigProvider.notifier)
        .save(config.copyWith(media: selected));
  }
}

class _MediaPickerSheet extends StatelessWidget {
  const _MediaPickerSheet({required this.current});

  final PrinterMedia current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: PrinterMedia.supported.map((media) {
          return ListTile(
            title: Text(media.name),
            subtitle: Text(media.description),
            trailing: media.id == current.id
                ? const Icon(Icons.check, color: Color(0xFF185FA5))
                : null,
            onTap: () => Navigator.pop(context, media),
          );
        }).toList(),
      ),
    );
  }
}
